import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';
import 'package:n06/features/data_sharing/domain/entities/shared_data_report.dart';
import 'package:n06/features/tracking/domain/entities/emergency_symptom_check.dart';

void main() {
  group('SharedDataReport', () {
    late DateTime startDate;
    late DateTime endDate;

    setUp(() {
      startDate = DateTime(2024, 1, 1);
      endDate = DateTime(2024, 1, 31);
    });

    test('should create SharedDataReport with all required fields', () {
      // Arrange
      const doseRecords = <DoseRecord>[];
      const weightLogs = <WeightLog>[];
      const symptomLogs = <SymptomLog>[];
      const emergencyChecks = <EmergencySymptomCheck>[];
      const doseSchedules = <DoseSchedule>[];

      // Act
      final report = SharedDataReport(
        dateRangeStart: startDate,
        dateRangeEnd: endDate,
        doseRecords: doseRecords,
        weightLogs: weightLogs,
        symptomLogs: symptomLogs,
        emergencyChecks: emergencyChecks,
        doseSchedules: doseSchedules,
      );

      // Assert
      expect(report.dateRangeStart, startDate);
      expect(report.dateRangeEnd, endDate);
      expect(report.doseRecords, doseRecords);
      expect(report.weightLogs, weightLogs);
      expect(report.symptomLogs, symptomLogs);
      expect(report.emergencyChecks, emergencyChecks);
      expect(report.doseSchedules, doseSchedules);
    });

    test('should calculate adherence rate correctly with perfect adherence', () {
      // Arrange - 5 scheduled, 5 completed
      final schedules = [
        DoseSchedule(
          id: '1',
          dosagePlanId: 'plan1',
          scheduledDate: DateTime(2024, 1, 1),
          scheduledDoseMg: 0.25,
        ),
        DoseSchedule(
          id: '2',
          dosagePlanId: 'plan1',
          scheduledDate: DateTime(2024, 1, 8),
          scheduledDoseMg: 0.25,
        ),
        DoseSchedule(
          id: '3',
          dosagePlanId: 'plan1',
          scheduledDate: DateTime(2024, 1, 15),
          scheduledDoseMg: 0.5,
        ),
        DoseSchedule(
          id: '4',
          dosagePlanId: 'plan1',
          scheduledDate: DateTime(2024, 1, 22),
          scheduledDoseMg: 0.5,
        ),
        DoseSchedule(
          id: '5',
          dosagePlanId: 'plan1',
          scheduledDate: DateTime(2024, 1, 29),
          scheduledDoseMg: 0.5,
        ),
      ];

      final records = [
        DoseRecord(
          id: 'r1',
          dosagePlanId: 'plan1',
          administeredAt: DateTime(2024, 1, 1, 10, 0),
          actualDoseMg: 0.25,
          isCompleted: true,
        ),
        DoseRecord(
          id: 'r2',
          dosagePlanId: 'plan1',
          administeredAt: DateTime(2024, 1, 8, 10, 0),
          actualDoseMg: 0.25,
          isCompleted: true,
        ),
        DoseRecord(
          id: 'r3',
          dosagePlanId: 'plan1',
          administeredAt: DateTime(2024, 1, 15, 10, 0),
          actualDoseMg: 0.5,
          isCompleted: true,
        ),
        DoseRecord(
          id: 'r4',
          dosagePlanId: 'plan1',
          administeredAt: DateTime(2024, 1, 22, 10, 0),
          actualDoseMg: 0.5,
          isCompleted: true,
        ),
        DoseRecord(
          id: 'r5',
          dosagePlanId: 'plan1',
          administeredAt: DateTime(2024, 1, 29, 10, 0),
          actualDoseMg: 0.5,
          isCompleted: true,
        ),
      ];

      // Act
      final report = SharedDataReport(
        dateRangeStart: startDate,
        dateRangeEnd: endDate,
        doseRecords: records,
        weightLogs: const [],
        symptomLogs: const [],
        emergencyChecks: const [],
        doseSchedules: schedules,
      );

      // Assert
      final adherenceRate = report.calculateAdherenceRate();
      expect(adherenceRate, 100.0);
    });

    test('should calculate adherence rate correctly with 80% adherence', () {
      // Arrange - 5 scheduled, 4 completed
      final schedules = [
        DoseSchedule(
          id: '1',
          dosagePlanId: 'plan1',
          scheduledDate: DateTime(2024, 1, 1),
          scheduledDoseMg: 0.25,
        ),
        DoseSchedule(
          id: '2',
          dosagePlanId: 'plan1',
          scheduledDate: DateTime(2024, 1, 8),
          scheduledDoseMg: 0.25,
        ),
        DoseSchedule(
          id: '3',
          dosagePlanId: 'plan1',
          scheduledDate: DateTime(2024, 1, 15),
          scheduledDoseMg: 0.5,
        ),
        DoseSchedule(
          id: '4',
          dosagePlanId: 'plan1',
          scheduledDate: DateTime(2024, 1, 22),
          scheduledDoseMg: 0.5,
        ),
        DoseSchedule(
          id: '5',
          dosagePlanId: 'plan1',
          scheduledDate: DateTime(2024, 1, 29),
          scheduledDoseMg: 0.5,
        ),
      ];

      final records = [
        DoseRecord(
          id: 'r1',
          dosagePlanId: 'plan1',
          administeredAt: DateTime(2024, 1, 1, 10, 0),
          actualDoseMg: 0.25,
          isCompleted: true,
        ),
        DoseRecord(
          id: 'r2',
          dosagePlanId: 'plan1',
          administeredAt: DateTime(2024, 1, 8, 10, 0),
          actualDoseMg: 0.25,
          isCompleted: true,
        ),
        DoseRecord(
          id: 'r3',
          dosagePlanId: 'plan1',
          administeredAt: DateTime(2024, 1, 15, 10, 0),
          actualDoseMg: 0.5,
          isCompleted: true,
        ),
        DoseRecord(
          id: 'r4',
          dosagePlanId: 'plan1',
          administeredAt: DateTime(2024, 1, 22, 10, 0),
          actualDoseMg: 0.5,
          isCompleted: true,
        ),
        // Missing r5 for 2024-01-29
      ];

      // Act
      final report = SharedDataReport(
        dateRangeStart: startDate,
        dateRangeEnd: endDate,
        doseRecords: records,
        weightLogs: const [],
        symptomLogs: const [],
        emergencyChecks: const [],
        doseSchedules: schedules,
      );

      // Assert
      final adherenceRate = report.calculateAdherenceRate();
      expect(adherenceRate, 80.0);
    });

    test('should return 0 adherence rate when no schedules exist', () {
      // Arrange
      final records = [
        DoseRecord(
          id: 'r1',
          dosagePlanId: 'plan1',
          administeredAt: DateTime(2024, 1, 1, 10, 0),
          actualDoseMg: 0.25,
          isCompleted: true,
        ),
      ];

      // Act
      final report = SharedDataReport(
        dateRangeStart: startDate,
        dateRangeEnd: endDate,
        doseRecords: records,
        weightLogs: const [],
        symptomLogs: const [],
        emergencyChecks: const [],
        doseSchedules: const [],
      );

      // Assert
      final adherenceRate = report.calculateAdherenceRate();
      expect(adherenceRate, 0.0);
    });

    test('should aggregate injection site history correctly', () {
      // Arrange
      final records = [
        DoseRecord(
          id: 'r1',
          dosagePlanId: 'plan1',
          administeredAt: DateTime(2024, 1, 1, 10, 0),
          actualDoseMg: 0.25,
          injectionSite: 'abdomen',
          isCompleted: true,
        ),
        DoseRecord(
          id: 'r2',
          dosagePlanId: 'plan1',
          administeredAt: DateTime(2024, 1, 8, 10, 0),
          actualDoseMg: 0.25,
          injectionSite: 'thigh',
          isCompleted: true,
        ),
        DoseRecord(
          id: 'r3',
          dosagePlanId: 'plan1',
          administeredAt: DateTime(2024, 1, 15, 10, 0),
          actualDoseMg: 0.5,
          injectionSite: 'arm',
          isCompleted: true,
        ),
        DoseRecord(
          id: 'r4',
          dosagePlanId: 'plan1',
          administeredAt: DateTime(2024, 1, 22, 10, 0),
          actualDoseMg: 0.5,
          injectionSite: 'abdomen',
          isCompleted: true,
        ),
      ];

      // Act
      final report = SharedDataReport(
        dateRangeStart: startDate,
        dateRangeEnd: endDate,
        doseRecords: records,
        weightLogs: const [],
        symptomLogs: const [],
        emergencyChecks: const [],
        doseSchedules: const [],
      );

      final siteHistory = report.getInjectionSiteHistory();

      // Assert
      expect(siteHistory['abdomen'], 2);
      expect(siteHistory['thigh'], 1);
      expect(siteHistory['arm'], 1);
    });

    test('should handle empty data lists gracefully', () {
      // Act
      final report = SharedDataReport(
        dateRangeStart: startDate,
        dateRangeEnd: endDate,
        doseRecords: const [],
        weightLogs: const [],
        symptomLogs: const [],
        emergencyChecks: const [],
        doseSchedules: const [],
      );

      // Assert
      expect(report.doseRecords, isEmpty);
      expect(report.weightLogs, isEmpty);
      expect(report.symptomLogs, isEmpty);
      expect(report.emergencyChecks, isEmpty);
      expect(report.doseSchedules, isEmpty);
      expect(report.calculateAdherenceRate(), 0.0);
      expect(report.getInjectionSiteHistory(), isEmpty);
    });

    test('should support value equality with Equatable', () {
      // Arrange
      final report1 = SharedDataReport(
        dateRangeStart: startDate,
        dateRangeEnd: endDate,
        doseRecords: const [],
        weightLogs: const [],
        symptomLogs: const [],
        emergencyChecks: const [],
        doseSchedules: const [],
      );

      final report2 = SharedDataReport(
        dateRangeStart: startDate,
        dateRangeEnd: endDate,
        doseRecords: const [],
        weightLogs: const [],
        symptomLogs: const [],
        emergencyChecks: const [],
        doseSchedules: const [],
      );

      // Assert
      expect(report1, report2);
    });

    test('should provide copyWith functionality', () {
      // Arrange
      final report = SharedDataReport(
        dateRangeStart: startDate,
        dateRangeEnd: endDate,
        doseRecords: const [],
        weightLogs: const [],
        symptomLogs: const [],
        emergencyChecks: const [],
        doseSchedules: const [],
      );

      final newEndDate = DateTime(2024, 2, 28);

      // Act
      final updatedReport = report.copyWith(dateRangeEnd: newEndDate);

      // Assert
      expect(updatedReport.dateRangeEnd, newEndDate);
      expect(updatedReport.dateRangeStart, startDate);
      expect(report.dateRangeEnd, endDate); // Original unchanged
    });
  });
}
