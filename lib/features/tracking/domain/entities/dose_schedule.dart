import 'package:equatable/equatable.dart';
import 'package:n06/features/notification/domain/value_objects/notification_time.dart';

class DoseSchedule extends Equatable {
  final String id;
  final String dosagePlanId;
  final DateTime scheduledDate;
  final double scheduledDoseMg;
  final NotificationTime? notificationTime;
  final DateTime createdAt;

  DoseSchedule({
    required this.id,
    required this.dosagePlanId,
    required this.scheduledDate,
    required this.scheduledDoseMg,
    this.notificationTime,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Check if schedule is overdue (before today)
  bool isOverdue() {
    final today = DateTime.now();
    final scheduleDate = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
    );
    final todayDate = DateTime(today.year, today.month, today.day);
    return scheduleDate.isBefore(todayDate);
  }

  /// Check if schedule is today
  bool isToday() {
    final today = DateTime.now();
    return scheduledDate.year == today.year &&
        scheduledDate.month == today.month &&
        scheduledDate.day == today.day;
  }

  /// Check if schedule is in the future (after today)
  bool isUpcoming() {
    final today = DateTime.now();
    final scheduleDate = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
    );
    final todayDate = DateTime(today.year, today.month, today.day);
    return scheduleDate.isAfter(todayDate);
  }

  /// Calculate days until/since scheduled date
  /// Positive number = future, Negative = past
  int daysUntil() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final scheduleDate = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
    );
    return scheduleDate.difference(todayDate).inDays;
  }

  @override
  List<Object?> get props => [
    id,
    dosagePlanId,
    scheduledDate,
    scheduledDoseMg,
    notificationTime,
    createdAt,
  ];

  DoseSchedule copyWith({
    String? id,
    String? dosagePlanId,
    DateTime? scheduledDate,
    double? scheduledDoseMg,
    NotificationTime? notificationTime,
    DateTime? createdAt,
  }) {
    return DoseSchedule(
      id: id ?? this.id,
      dosagePlanId: dosagePlanId ?? this.dosagePlanId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledDoseMg: scheduledDoseMg ?? this.scheduledDoseMg,
      notificationTime: notificationTime ?? this.notificationTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
