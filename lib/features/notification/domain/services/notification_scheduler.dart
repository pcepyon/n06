import 'package:n06/features/notification/domain/value_objects/notification_time.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';

/// 알림 스케줄링 계약
abstract class NotificationScheduler {
  /// 알림 권한 확인
  Future<bool> checkPermission();

  /// 알림 권한 요청
  Future<bool> requestPermission();

  /// 투여 스케줄 기반 알림 등록
  Future<void> scheduleNotifications({
    required List<DoseSchedule> doseSchedules,
    required NotificationTime notificationTime,
  });

  /// 모든 알림 취소
  Future<void> cancelAllNotifications();
}
