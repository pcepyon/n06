import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';

class NotificationPayload {
  final String id;
  final String title;
  final String message;
  final String deepLink;
  final Map<String, dynamic> data;

  NotificationPayload({
    required this.id,
    required this.title,
    required this.message,
    required this.deepLink,
    required this.data,
  });
}

class DoseNotificationUseCase {
  /// Create notification payload from dose schedule
  NotificationPayload createNotificationPayload(DoseSchedule schedule) {
    return NotificationPayload(
      id: schedule.id,
      title: '투여 알림',
      message: '${schedule.scheduledDoseMg}mg 투여 시간입니다.',
      deepLink: '/medication/schedule/${schedule.id}',
      data: {
        'scheduleId': schedule.id,
        'planId': schedule.dosagePlanId,
        'doseMg': schedule.scheduledDoseMg,
        'scheduledDate': schedule.scheduledDate.toIso8601String(),
      },
    );
  }

  /// Check if schedule should have notification scheduled
  bool shouldScheduleNotification(DoseSchedule schedule) {
    final now = DateTime.now();
    // Don't schedule notification for past schedules
    return schedule.scheduledDate.isAfter(now) ||
        schedule.scheduledDate.isAtSameMomentAs(now);
  }

  /// Get notification time for schedule
  String? getNotificationTimeString(DoseSchedule schedule) {
    if (schedule.notificationTime == null) {
      return null;
    }

    return schedule.notificationTime.toString();
  }
}
