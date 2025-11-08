import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:n06/features/notification/domain/entities/notification_settings.dart';
import 'package:n06/features/notification/domain/repositories/notification_repository.dart';
import 'package:n06/features/notification/domain/services/notification_scheduler.dart';
import 'package:n06/features/notification/infrastructure/repositories/isar_notification_repository.dart';
import 'package:n06/features/notification/infrastructure/services/local_notification_scheduler.dart';
import 'package:n06/features/notification/infrastructure/services/permission_service.dart';
import 'package:n06/features/tracking/application/providers.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/coping_guide/application/providers.dart';

part 'notification_notifier.g.dart';

/// Repository Provider
@riverpod
NotificationRepository notificationRepository(
  NotificationRepositoryRef ref,
) {
  final isar = ref.watch(isarProvider);
  return IsarNotificationRepository(isar);
}

/// Scheduler Provider
@riverpod
NotificationScheduler notificationScheduler(
  NotificationSchedulerRef ref,
) {
  return LocalNotificationScheduler(PermissionService());
}

/// Notifier Class
@riverpod
class NotificationNotifier extends _$NotificationNotifier {
  @override
  Future<NotificationSettings> build() async {
    final userId = ref.watch(authNotifierProvider).value?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final repository = ref.watch(notificationRepositoryProvider);
    final settings = await repository.getNotificationSettings(userId);

    return settings ??
        NotificationSettings(
          userId: userId,
          notificationTime: const TimeOfDay(hour: 9, minute: 0),
          notificationEnabled: true,
        );
  }

  /// 알림 시간 업데이트
  Future<void> updateNotificationTime(TimeOfDay newTime) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final currentState = state.value;
      if (currentState == null) throw Exception('Settings not loaded');

      final updated = currentState.copyWith(notificationTime: newTime);
      final repository = ref.read(notificationRepositoryProvider);
      await repository.saveNotificationSettings(updated);

      // 알림 스케줄 재계산
      await _rescheduleNotifications(updated);

      return updated;
    });
  }

  /// 알림 활성화/비활성화 토글
  Future<void> toggleNotificationEnabled() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final currentState = state.value;
      if (currentState == null) throw Exception('Settings not loaded');

      final scheduler = ref.read(notificationSchedulerProvider);
      final newEnabled = !currentState.notificationEnabled;

      if (newEnabled) {
        // 활성화할 때 권한 확인 및 요청
        final hasPermission = await scheduler.checkPermission();
        if (!hasPermission) {
          final granted = await scheduler.requestPermission();
          if (!granted) {
            // 권한이 거부되면 변경하지 않음
            return currentState;
          }
        }
      }

      final updated = currentState.copyWith(notificationEnabled: newEnabled);
      final repository = ref.read(notificationRepositoryProvider);
      await repository.saveNotificationSettings(updated);

      // 알림 스케줄 업데이트
      if (newEnabled) {
        await _rescheduleNotifications(updated);
      } else {
        // 비활성화하면 모든 알림 취소
        await scheduler.cancelAllNotifications();
      }

      return updated;
    });
  }

  /// 알림 스케줄 재계산
  Future<void> _rescheduleNotifications(
    NotificationSettings settings,
  ) async {
    if (!settings.notificationEnabled) return;

    final scheduler = ref.read(notificationSchedulerProvider);
    final medicationRepository = ref.read(medicationRepositoryProvider);
    final userId = settings.userId;

    // 기존 알림 취소
    await scheduler.cancelAllNotifications();

    // 투여 스케줄 조회
    final activePlan = await medicationRepository.getActiveDosagePlan(userId);
    if (activePlan == null) return;

    final schedules =
        await medicationRepository.getDoseSchedules(activePlan.id);

    // 새로운 알림 등록
    if (schedules.isNotEmpty) {
      await scheduler.scheduleNotifications(
        doseSchedules: schedules,
        notificationTime: settings.notificationTime,
      );
    }
  }
}
