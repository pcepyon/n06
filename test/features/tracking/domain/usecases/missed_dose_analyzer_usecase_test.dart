import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';
import 'package:n06/features/tracking/domain/usecases/missed_dose_analyzer_usecase.dart';

void main() {
  group('MissedDoseAnalyzerUseCase', () {
    late MissedDoseAnalyzerUseCase useCase;

    setUp(() {
      useCase = MissedDoseAnalyzerUseCase();
    });

    test('should return no missed doses when all completed', () {
      final now = DateTime.now();
      final schedules = [
        DoseSchedule(
          id: 'schedule-1',
          dosagePlanId: 'plan-1',
          scheduledDate: now.subtract(Duration(days: 7)),
          scheduledDoseMg: 0.25,
        ),
        DoseSchedule(
          id: 'schedule-2',
          dosagePlanId: 'plan-1',
          scheduledDate: now,
          scheduledDoseMg: 0.25,
        ),
      ];

      final records = [
        DoseRecord(
          id: 'record-1',
          dosagePlanId: 'plan-1',
          administeredAt: now.subtract(Duration(days: 7)),
          actualDoseMg: 0.25,
        ),
        DoseRecord(
          id: 'record-2',
          dosagePlanId: 'plan-1',
          administeredAt: now,
          actualDoseMg: 0.25,
        ),
      ];

      final result = useCase.analyzeMissedDoses(schedules, records);

      expect(result.missedDoses.isEmpty, true);
    });

    test('should detect missed dose within 5 days', () {
      final now = DateTime.now();
      final schedules = [
        DoseSchedule(
          id: 'schedule-1',
          dosagePlanId: 'plan-1',
          scheduledDate: now.subtract(Duration(days: 3)),
          scheduledDoseMg: 0.25,
        ),
      ];

      final result = useCase.analyzeMissedDoses(schedules, []);

      expect(result.missedDoses.length, 1);
      expect(result.guidanceType, GuidanceType.immediateAdministration);
    });

    test('should detect missed dose over 5 days', () {
      final now = DateTime.now();
      final schedules = [
        DoseSchedule(
          id: 'schedule-1',
          dosagePlanId: 'plan-1',
          scheduledDate: now.subtract(Duration(days: 7)),
          scheduledDoseMg: 0.25,
        ),
      ];

      final result = useCase.analyzeMissedDoses(schedules, []);

      expect(result.missedDoses.length, 1);
      expect(result.guidanceType, GuidanceType.waitForNext);
    });

    test('should recommend expert consultation for 7+ days missed', () {
      final now = DateTime.now();
      final schedules = [
        DoseSchedule(
          id: 'schedule-1',
          dosagePlanId: 'plan-1',
          scheduledDate: now.subtract(Duration(days: 10)),
          scheduledDoseMg: 0.25,
        ),
      ];

      final result = useCase.analyzeMissedDoses(schedules, []);

      expect(result.missedDoses.length, 1);
      expect(result.requiresExpertConsultation, true);
    });

    test('should handle multiple missed doses', () {
      final now = DateTime.now();
      final schedules = [
        DoseSchedule(
          id: 'schedule-1',
          dosagePlanId: 'plan-1',
          scheduledDate: now.subtract(Duration(days: 2)),
          scheduledDoseMg: 0.25,
        ),
        DoseSchedule(
          id: 'schedule-2',
          dosagePlanId: 'plan-1',
          scheduledDate: now.subtract(Duration(days: 6)),
          scheduledDoseMg: 0.25,
        ),
        DoseSchedule(
          id: 'schedule-3',
          dosagePlanId: 'plan-1',
          scheduledDate: now.subtract(Duration(days: 11)),
          scheduledDoseMg: 0.25,
        ),
      ];

      final result = useCase.analyzeMissedDoses(schedules, []);

      expect(result.missedDoses.length, 3);
      expect(result.requiresExpertConsultation, true);
    });

    test('should calculate days elapsed for each missed dose', () {
      final now = DateTime.now();
      final schedules = [
        DoseSchedule(
          id: 'schedule-1',
          dosagePlanId: 'plan-1',
          scheduledDate: now.subtract(Duration(days: 5)),
          scheduledDoseMg: 0.25,
        ),
      ];

      final result = useCase.analyzeMissedDoses(schedules, []);

      expect(result.missedDoses[0].daysElapsed, 5);
    });
  });
}
