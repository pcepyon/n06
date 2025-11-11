import 'package:isar/isar.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';
import 'package:n06/features/notification/domain/value_objects/notification_time.dart';

part 'dose_schedule_dto.g.dart';

@collection
class DoseScheduleDto {
  Id? id = Isar.autoIncrement;
  late String scheduleId; // UUID
  late String dosagePlanId;
  late DateTime scheduledDate;
  late double scheduledDoseMg;
  int? notificationHour;    // 0-23 or null
  int? notificationMinute;  // 0-59 or null
  late DateTime createdAt;

  DoseScheduleDto();

  DoseScheduleDto.fromEntity(DoseSchedule entity) {
    scheduleId = entity.id;
    dosagePlanId = entity.dosagePlanId;
    scheduledDate = entity.scheduledDate;
    scheduledDoseMg = entity.scheduledDoseMg;

    // NotificationTime → hour/minute
    if (entity.notificationTime != null) {
      notificationHour = entity.notificationTime!.hour;
      notificationMinute = entity.notificationTime!.minute;
    } else {
      notificationHour = null;
      notificationMinute = null;
    }

    createdAt = entity.createdAt;
  }

  DoseSchedule toEntity() {
    // hour/minute → NotificationTime
    NotificationTime? notificationTime;
    if (notificationHour != null && notificationMinute != null) {
      notificationTime = NotificationTime(
        hour: notificationHour!,
        minute: notificationMinute!,
      );
    }

    return DoseSchedule(
      id: scheduleId,
      dosagePlanId: dosagePlanId,
      scheduledDate: scheduledDate,
      scheduledDoseMg: scheduledDoseMg,
      notificationTime: notificationTime,
      createdAt: createdAt,
    );
  }
}
