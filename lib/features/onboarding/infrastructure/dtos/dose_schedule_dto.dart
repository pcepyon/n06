import 'package:isar/isar.dart';
import 'package:n06/features/onboarding/domain/entities/dose_schedule.dart';

part 'dose_schedule_dto.g.dart';

@collection
class DoseScheduleDto {
  Id isarId = Isar.autoIncrement;

  late String id;
  late String userId;
  late String dosagePlanId;
  late DateTime scheduledDate;
  late double scheduledDoseMg;
  late String? notificationTime;

  /// DTO를 Domain Entity로 변환한다.
  DoseSchedule toEntity() {
    return DoseSchedule(
      id: id,
      userId: userId,
      dosagePlanId: dosagePlanId,
      scheduledDate: scheduledDate,
      scheduledDoseMg: scheduledDoseMg,
      notificationTime: notificationTime,
    );
  }

  /// Domain Entity를 DTO로 변환한다.
  static DoseScheduleDto fromEntity(DoseSchedule entity) {
    return DoseScheduleDto()
      ..id = entity.id
      ..userId = entity.userId
      ..dosagePlanId = entity.dosagePlanId
      ..scheduledDate = entity.scheduledDate
      ..scheduledDoseMg = entity.scheduledDoseMg
      ..notificationTime = entity.notificationTime;
  }
}
