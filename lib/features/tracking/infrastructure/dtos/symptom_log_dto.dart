import 'package:isar/isar.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';

part 'symptom_log_dto.g.dart';

@collection
class SymptomLogDto {
  Id id = Isar.autoIncrement;
  late String userId;
  late DateTime logDate;
  late String symptomName;
  late int severity; // 1-10
  late int? daysSinceEscalation;
  late bool? isPersistent24h;
  late String? note;
  late DateTime? createdAt;

  SymptomLogDto();

  SymptomLog toEntity({required List<String> tags}) {
    return SymptomLog(
      id: id.toString(),
      userId: userId,
      logDate: logDate,
      symptomName: symptomName,
      severity: severity,
      daysSinceEscalation: daysSinceEscalation,
      isPersistent24h: isPersistent24h,
      note: note,
      tags: tags,
      createdAt: createdAt,
    );
  }

  factory SymptomLogDto.fromEntity(SymptomLog entity) {
    return SymptomLogDto()
      ..userId = entity.userId
      ..logDate = entity.logDate
      ..symptomName = entity.symptomName
      ..severity = entity.severity
      ..daysSinceEscalation = entity.daysSinceEscalation
      ..isPersistent24h = entity.isPersistent24h
      ..note = entity.note
      ..createdAt = entity.createdAt;
  }

  @override
  String toString() =>
      'SymptomLogDto(id: $id, userId: $userId, logDate: $logDate, symptomName: $symptomName, severity: $severity, daysSinceEscalation: $daysSinceEscalation, isPersistent24h: $isPersistent24h, note: $note, createdAt: $createdAt)';
}
