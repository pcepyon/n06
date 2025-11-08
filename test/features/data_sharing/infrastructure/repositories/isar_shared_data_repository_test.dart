import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:n06/features/data_sharing/domain/repositories/date_range.dart';
import 'package:n06/features/data_sharing/infrastructure/repositories/isar_shared_data_repository.dart';
import 'package:n06/features/tracking/infrastructure/dtos/dose_record_dto.dart';
import 'package:n06/features/tracking/infrastructure/dtos/dose_schedule_dto.dart';
import 'package:n06/features/tracking/infrastructure/dtos/weight_log_dto.dart';
import 'package:n06/features/tracking/infrastructure/dtos/symptom_log_dto.dart';

void main() {
  group('IsarSharedDataRepository', () {
    late Isar isar;
    late IsarSharedDataRepository repository;
    final userId = 'test-user-123';
    final now = DateTime.now();

    setUp(() async {
      final tempDir = await getTemporaryDirectory();
      isar = await Isar.open(
        [
          DoseRecordDtoSchema,
          DoseScheduleDtoSchema,
          WeightLogDtoSchema,
          SymptomLogDtoSchema,
        ],
        directory: tempDir.path,
        inspector: true,
      );
      repository = IsarSharedDataRepository(isar);
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('should fetch dose records within date range', () async {
      // Arrange
      final startDate = DateTime(now.year, now.month, 1);
      final endDate = DateTime(now.year, now.month + 1, 0);

      await isar.writeTxn(() async {
        await isar.doseRecordDtos.putAll([
          DoseRecordDto()
            ..dosagePlanId = 'plan1'
            ..administeredAt = startDate.add(const Duration(days: 5))
            ..actualDoseMg = 0.25
            ..isCompleted = true,
          DoseRecordDto()
            ..dosagePlanId = 'plan1'
            ..administeredAt = endDate.add(const Duration(days: 10)) // Outside range
            ..actualDoseMg = 0.25
            ..isCompleted = true,
        ]);
      });

      // Act
      final report = await repository.getReportData(userId, DateRange.lastMonth);

      // Assert
      expect(report.doseRecords.length, 1);
      expect(report.doseRecords.first.id, '1');
    });

    test('should fetch weight logs within date range', () async {
      // Arrange
      final startDate = DateTime(now.year, now.month, 1);

      await isar.writeTxn(() async {
        await isar.weightLogDtos.putAll([
          WeightLogDto()
            ..userId = userId
            ..logDate = startDate.add(const Duration(days: 5))
            ..weightKg = 75.5,
          WeightLogDto()
            ..userId = userId
            ..logDate = startDate.subtract(const Duration(days: 40)) // Outside 30-day range
            ..weightKg = 76.0,
        ]);
      });

      // Act
      final report = await repository.getReportData(userId, DateRange.lastMonth);

      // Assert
      expect(report.weightLogs.length, 1);
      expect(report.weightLogs.first.weightKg, 75.5);
    });

    test('should fetch symptom logs within date range', () async {
      // Arrange
      final startDate = DateTime(now.year, now.month, 1);

      await isar.writeTxn(() async {
        await isar.symptomLogDtos.putAll([
          SymptomLogDto()
            ..userId = userId
            ..logDate = startDate.add(const Duration(days: 5))
            ..symptomName = '메스꺼움'
            ..severity = 5,
          SymptomLogDto()
            ..userId = userId
            ..logDate = startDate.subtract(const Duration(days: 40))
            ..symptomName = '두통'
            ..severity = 3,
        ]);
      });

      // Act
      final report = await repository.getReportData(userId, DateRange.lastMonth);

      // Assert
      expect(report.symptomLogs.length, 1);
      expect(report.symptomLogs.first.symptomName, '메스꺼움');
    });

    test('should return empty report when no data exists', () async {
      // Act
      final report = await repository.getReportData(userId, DateRange.lastMonth);

      // Assert
      expect(report.doseRecords, isEmpty);
      expect(report.weightLogs, isEmpty);
      expect(report.symptomLogs, isEmpty);
      expect(report.emergencyChecks, isEmpty);
    });

    test('should handle partial data correctly', () async {
      // Arrange - Only add dose records, no weight/symptom logs
      final startDate = DateTime(now.year, now.month, 1);

      await isar.writeTxn(() async {
        await isar.doseRecordDtos.put(
          DoseRecordDto()
            ..dosagePlanId = 'plan1'
            ..administeredAt = startDate.add(const Duration(days: 5))
            ..actualDoseMg = 0.25
            ..isCompleted = true,
        );
      });

      // Act
      final report = await repository.getReportData(userId, DateRange.lastMonth);

      // Assert
      expect(report.doseRecords.length, 1);
      expect(report.weightLogs, isEmpty);
      expect(report.symptomLogs, isEmpty);
    });

    test('should fetch dose schedules for adherence calculation', () async {
      // Arrange
      final startDate = DateTime(now.year, now.month, 1);

      await isar.writeTxn(() async {
        await isar.doseScheduleDtos.putAll([
          DoseScheduleDto()
            ..dosagePlanId = 'plan1'
            ..scheduledDate = startDate.add(const Duration(days: 0))
            ..scheduledDoseMg = 0.25,
          DoseScheduleDto()
            ..dosagePlanId = 'plan1'
            ..scheduledDate = startDate.add(const Duration(days: 7))
            ..scheduledDoseMg = 0.25,
        ]);
      });

      // Act
      final report = await repository.getReportData(userId, DateRange.lastMonth);

      // Assert
      expect(report.doseSchedules.length, 2);
    });

    test('should handle allTime date range correctly', () async {
      // Arrange - Add records from different months
      await isar.writeTxn(() async {
        await isar.doseRecordDtos.putAll([
          DoseRecordDto()
            ..dosagePlanId = 'plan1'
            ..administeredAt = DateTime(2024, 1, 15)
            ..actualDoseMg = 0.25
            ..isCompleted = true,
          DoseRecordDto()
            ..dosagePlanId = 'plan1'
            ..administeredAt = DateTime(2024, 6, 15)
            ..actualDoseMg = 0.5
            ..isCompleted = true,
          DoseRecordDto()
            ..dosagePlanId = 'plan1'
            ..administeredAt = DateTime(2024, 12, 15)
            ..actualDoseMg = 1.0
            ..isCompleted = true,
        ]);
      });

      // Act
      final report = await repository.getReportData(userId, DateRange.allTime);

      // Assert
      expect(report.doseRecords.length, 3);
    });

    test('should filter by correct user', () async {
      // Arrange - Add records for different users
      final otherUserId = 'other-user-456';
      final startDate = DateTime(now.year, now.month, 1);

      await isar.writeTxn(() async {
        await isar.weightLogDtos.putAll([
          WeightLogDto()
            ..userId = userId
            ..logDate = startDate.add(const Duration(days: 5))
            ..weightKg = 75.5,
          WeightLogDto()
            ..userId = otherUserId
            ..logDate = startDate.add(const Duration(days: 5))
            ..weightKg = 80.0,
        ]);
      });

      // Act
      final report = await repository.getReportData(userId, DateRange.lastMonth);

      // Assert
      expect(report.weightLogs.length, 1);
      expect(report.weightLogs.first.weightKg, 75.5);
    });
  });
}
