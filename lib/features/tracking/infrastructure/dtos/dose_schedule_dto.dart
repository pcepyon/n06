import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';
import 'package:n06/features/notification/domain/value_objects/notification_time.dart';

/// Supabase DTO for DoseSchedule entity.
///
/// Stores dose schedule information in Supabase database.
class DoseScheduleDto {
  final String id;
  final String dosagePlanId;
  final DateTime scheduledDate;
  final double scheduledDoseMg;
  final NotificationTime? notificationTime;
  final DateTime createdAt;

  const DoseScheduleDto({
    required this.id,
    required this.dosagePlanId,
    required this.scheduledDate,
    required this.scheduledDoseMg,
    this.notificationTime,
    required this.createdAt,
  });

  /// Creates DTO from Supabase JSON.
  factory DoseScheduleDto.fromJson(Map<String, dynamic> json) {
    NotificationTime? notificationTime;
    if (json['notification_time'] != null) {
      final timeStr = json['notification_time'] as String;
      final parts = timeStr.split(':');
      notificationTime = NotificationTime(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    return DoseScheduleDto(
      id: json['id'] as String,
      dosagePlanId: json['dosage_plan_id'] as String,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String).toLocal(),
      scheduledDoseMg: (json['scheduled_dose_mg'] as num).toDouble(),
      notificationTime: notificationTime,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  /// Converts DTO to Supabase JSON.
  Map<String, dynamic> toJson() {
    String? notificationTimeStr;
    if (notificationTime != null) {
      notificationTimeStr =
          '${notificationTime!.hour.toString().padLeft(2, '0')}:${notificationTime!.minute.toString().padLeft(2, '0')}:00';
    }

    return {
      'id': id,
      'dosage_plan_id': dosagePlanId,
      'scheduled_date': scheduledDate.toIso8601String().split('T')[0],
      'scheduled_dose_mg': scheduledDoseMg,
      'notification_time': notificationTimeStr,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  /// Converts DTO to Domain Entity.
  DoseSchedule toEntity() {
    return DoseSchedule(
      id: id,
      dosagePlanId: dosagePlanId,
      scheduledDate: scheduledDate,
      scheduledDoseMg: scheduledDoseMg,
      notificationTime: notificationTime,
      createdAt: createdAt,
    );
  }

  /// Creates DTO from Domain Entity.
  factory DoseScheduleDto.fromEntity(DoseSchedule entity) {
    return DoseScheduleDto(
      id: entity.id,
      dosagePlanId: entity.dosagePlanId,
      scheduledDate: entity.scheduledDate,
      scheduledDoseMg: entity.scheduledDoseMg,
      notificationTime: entity.notificationTime,
      createdAt: entity.createdAt,
    );
  }
}
