import 'package:isar/isar.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';

part 'dose_schedule_dto.g.dart';

@collection
class DoseScheduleDto {
  Id? id = Isar.autoIncrement;
  late String scheduleId; // UUID
  late String dosagePlanId;
  late DateTime scheduledDate;
  late double scheduledDoseMg;
  late String? notificationTimeStr; // HH:mm format
  late DateTime createdAt;

  DoseScheduleDto();

  DoseScheduleDto.fromEntity(DoseSchedule entity) {
    scheduleId = entity.id;
    dosagePlanId = entity.dosagePlanId;
    scheduledDate = entity.scheduledDate;
    scheduledDoseMg = entity.scheduledDoseMg;
    if (entity.notificationTime != null) {
      notificationTimeStr = entity.notificationTime.toString();
    }
    createdAt = entity.createdAt;
  }

  DoseSchedule toEntity() {
    Object? notificationTime;
    if (notificationTimeStr != null) {
      notificationTime = notificationTimeStr; // Store as string
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
