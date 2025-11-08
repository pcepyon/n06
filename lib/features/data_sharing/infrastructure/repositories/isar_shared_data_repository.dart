import 'package:isar/isar.dart';
import 'package:n06/features/data_sharing/domain/entities/emergency_symptom_check.dart';
import 'package:n06/features/data_sharing/domain/entities/shared_data_report.dart';
import 'package:n06/features/data_sharing/domain/repositories/date_range.dart';
import 'package:n06/features/data_sharing/domain/repositories/shared_data_repository.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';
import 'package:n06/features/tracking/infrastructure/dtos/dose_record_dto.dart';
import 'package:n06/features/tracking/infrastructure/dtos/dose_schedule_dto.dart';
import 'package:n06/features/tracking/infrastructure/dtos/weight_log_dto.dart';
import 'package:n06/features/tracking/infrastructure/dtos/symptom_log_dto.dart';
import 'package:n06/features/tracking/infrastructure/dtos/symptom_context_tag_dto.dart';

class IsarSharedDataRepository implements SharedDataRepository {
  final Isar isar;

  IsarSharedDataRepository(this.isar);

  @override
  Future<SharedDataReport> getReportData(String userId, DateRange dateRange) async {
    // Calculate date range
    final now = DateTime.now();
    final endDate = DateTime(now.year, now.month, now.day);
    final startDate = dateRange.getStartDate(endDate);

    // Fetch dose records within date range
    final doseRecordDtos = await isar.doseRecordDtos
        .where()
        .indexedDateBetween(startDate, endDate)
        .findAll();
    final doseRecords = doseRecordDtos.map((dto) => dto.toEntity()).toList();

    // Fetch dose schedules within date range (for adherence calculation)
    final doseScheduleDtos = await isar.doseScheduleDtos.where().findAll();
    final doseSchedulesInRange = doseScheduleDtos.where((dto) {
      return !dto.scheduledDate.isBefore(startDate) &&
          !dto.scheduledDate.isAfter(endDate);
    }).toList();
    final doseSchedules = doseSchedulesInRange.map((dto) => dto.toEntity()).toList();

    // Fetch weight logs within date range, filtered by user
    final weightLogDtos = await isar.weightLogDtos.where().findAll();
    final weightLogsInRange = weightLogDtos
        .where((dto) {
          final dtoDate = DateTime(dto.logDate.year, dto.logDate.month, dto.logDate.day);
          return dto.userId == userId &&
              !dtoDate.isBefore(startDate) &&
              !dtoDate.isAfter(endDate);
        })
        .map((dto) => dto.toEntity())
        .toList();

    // Fetch symptom logs within date range, filtered by user
    final symptomLogDtos = await isar.symptomLogDtos.where().findAll();
    final filteredSymptomDtos = symptomLogDtos
        .where((dto) => dto.userId == userId)
        .toList();

    final List<dynamic> symptomLogsInRange = [];
    for (final symptomDto in filteredSymptomDtos) {
      final dtoDate = DateTime(symptomDto.logDate.year, symptomDto.logDate.month, symptomDto.logDate.day);
      if (!dtoDate.isBefore(startDate) && !dtoDate.isAfter(endDate)) {
        // Fetch associated tags for this symptom
        final tags = await isar.symptomContextTagDtos.where().findAll();
        final tagsForSymptom = tags
            .where((tagDto) => tagDto.symptomLogIsarId == symptomDto.id)
            .map((tagDto) => tagDto.tagName)
            .toList();

        symptomLogsInRange.add(symptomDto.toEntity(tags: tagsForSymptom));
      }
    }

    // For now, emergency checks are empty as they're not yet implemented
    // TODO: Implement emergency symptom check storage
    final emergencyChecks = <EmergencySymptomCheck>[];

    // Cast symptom logs to proper type
    final List<dynamic> symptomLogsCasted = List<dynamic>.from(symptomLogsInRange);

    return SharedDataReport(
      dateRangeStart: startDate,
      dateRangeEnd: endDate,
      doseRecords: doseRecords,
      weightLogs: weightLogsInRange,
      symptomLogs: symptomLogsCasted.cast<SymptomLog>(),
      emergencyChecks: emergencyChecks,
      doseSchedules: doseSchedules,
    );
  }
}
