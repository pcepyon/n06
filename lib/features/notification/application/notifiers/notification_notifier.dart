import 'package:n06/features/notification/domain/services/notification_scheduler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:n06/features/notification/domain/entities/notification_settings.dart';
import 'package:n06/features/notification/domain/value_objects/notification_time.dart';
import 'package:n06/features/notification/application/providers.dart';
import 'package:n06/features/tracking/application/providers.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';

part 'notification_notifier.g.dart';

/// Notifier Class
@riverpod
class NotificationNotifier extends _$NotificationNotifier {
  // ✅ 의존성을 late final 필드로 선언
  late final _repository = ref.read(notificationRepositoryProvider);
  late final _medicationRepository = ref.read(medicationRepositoryProvider);

  // Scheduler는 비동기 초기화가 필요하므로 build()에서 캡처
  late NotificationScheduler _scheduler;

  @override
  Future<NotificationSettings> build() async {
    // BUG-20251210: ref.watch(provider.future)를 사용하여 비동기 완료를 기다림
    final user = await ref.watch(authNotifierProvider.future);
    final userId = user?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Scheduler 초기화 완료 대기
    _scheduler = await ref.watch(notificationSchedulerProvider.future);

    final settings = await _repository.getNotificationSettings(userId);

    return settings ??
        NotificationSettings(
          userId: userId,
          notificationTime: const NotificationTime(hour: 9, minute: 0),
          notificationEnabled: true,
        );
  }

  /// 알림 시간 업데이트
  Future<void> updateNotificationTime(NotificationTime newTime) async {
    // ✅ 작업 완료 보장을 위한 keepAlive
    final link = ref.keepAlive();

    // 이전 상태 백업
    final previousState = state.value;

    state = const AsyncLoading();

    try {
      state = await AsyncValue.guard(() async {
        if (previousState == null) throw Exception('Settings not loaded');

        final updated = previousState.copyWith(notificationTime: newTime);
        await _repository.saveNotificationSettings(updated);

        // ✅ async gap 후 mounted 체크
        if (!ref.mounted) {
          return updated;
        }

        // 알림 스케줄 재계산
        await _rescheduleNotifications(updated);

        return updated;
      });
    } finally {
      link.close();
    }
  }

  /// 알림 활성화/비활성화 토글
  Future<void> toggleNotificationEnabled() async {
    // ✅ 작업 완료 보장을 위한 keepAlive
    final link = ref.keepAlive();

    // 이전 상태 백업
    final previousState = state.value;

    state = const AsyncLoading();

    try {
      state = await AsyncValue.guard(() async {
        if (previousState == null) throw Exception('Settings not loaded');

        final newEnabled = !previousState.notificationEnabled;

        if (newEnabled) {
          // 활성화할 때 권한 확인 및 요청
          final hasPermission = await _scheduler.checkPermission();
          if (!hasPermission) {
            final granted = await _scheduler.requestPermission();
            if (!granted) {
              // 권한이 거부되면 변경하지 않음
              return previousState;
            }
          }
        }

        final updated = previousState.copyWith(notificationEnabled: newEnabled);
        await _repository.saveNotificationSettings(updated);

        // ✅ async gap 후 mounted 체크
        if (!ref.mounted) {
          return updated;
        }

        // 알림 스케줄 업데이트
        if (newEnabled) {
          await _rescheduleNotifications(updated);
        } else {
          // 비활성화하면 모든 알림 취소
          await _scheduler.cancelAllNotifications();
        }

        return updated;
      });
    } finally {
      link.close();
    }
  }

  /// 알림 스케줄 재계산
  Future<void> _rescheduleNotifications(
    NotificationSettings settings,
  ) async {
    if (!settings.notificationEnabled) return;

    final userId = settings.userId;

    // 기존 알림 취소
    await _scheduler.cancelAllNotifications();

    // 투여 스케줄 조회
    final activePlan = await _medicationRepository.getActiveDosagePlan(userId);
    if (activePlan == null) return;

    final schedules =
        await _medicationRepository.getDoseSchedules(activePlan.id);

    // 새로운 알림 등록
    if (schedules.isNotEmpty) {
      await _scheduler.scheduleNotifications(
        doseSchedules: schedules,
        notificationTime: settings.notificationTime,
      );
    }
  }
}

/// Alias for backwards compatibility
const notificationNotifierProvider = notificationProvider;
