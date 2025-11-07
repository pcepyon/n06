import 'package:isar/isar.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';

part 'dose_record_dto.g.dart';

@collection
class DoseRecordDto {
  Id? id = Isar.autoIncrement;
  late String recordId; // UUID
  late String? doseScheduleId;
  late String dosagePlanId;
  late DateTime administeredAt;
  late double actualDoseMg;
  late String? injectionSite; // abdomen, thigh, arm
  late bool isCompleted;
  late String? note;
  late DateTime createdAt;

  @Index()
  late DateTime indexedDate; // For efficient date-based queries

  DoseRecordDto();

  DoseRecordDto.fromEntity(DoseRecord entity) {
    recordId = entity.id;
    doseScheduleId = entity.doseScheduleId;
    dosagePlanId = entity.dosagePlanId;
    administeredAt = entity.administeredAt;
    actualDoseMg = entity.actualDoseMg;
    injectionSite = entity.injectionSite;
    isCompleted = entity.isCompleted;
    note = entity.note;
    createdAt = entity.createdAt;
    indexedDate = DateTime(
      entity.administeredAt.year,
      entity.administeredAt.month,
      entity.administeredAt.day,
    );
  }

  DoseRecord toEntity() {
    return DoseRecord(
      id: recordId,
      doseScheduleId: doseScheduleId,
      dosagePlanId: dosagePlanId,
      administeredAt: administeredAt,
      actualDoseMg: actualDoseMg,
      injectionSite: injectionSite,
      isCompleted: isCompleted,
      note: note,
      createdAt: createdAt,
    );
  }
}
