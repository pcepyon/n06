import 'package:isar/isar.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';
import 'package:n06/features/tracking/domain/usecases/schedule_generator_usecase.dart';

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
      final time = entity.notificationTime!;
      notificationTimeStr =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    createdAt = entity.createdAt;
  }

  DoseSchedule toEntity() {
    TimeOfDay? notificationTime;
    if (notificationTimeStr != null) {
      final parts = notificationTimeStr!.split(':');
      notificationTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
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
