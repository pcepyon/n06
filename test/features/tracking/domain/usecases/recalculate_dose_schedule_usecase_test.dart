import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';
import 'package:n06/features/tracking/domain/usecases/recalculate_dose_schedule_usecase.dart';

void main() {
  group('RecalculateDoseScheduleUseCase', () {
    late RecalculateDoseScheduleUseCase useCase;

    setUp(() {
      useCase = RecalculateDoseScheduleUseCase();
    });

    test('should generate schedules with correct cycle', () {
      // Arrange
      final startDate = DateTime(2025, 1, 1);
      final plan = DosagePlan(
        id: 'plan-1',
        userId: 'user-1',
        medicationName: 'Ozempic',
        startDate: startDate,
        cycleDays: 7,
        initialDoseMg: 0.25,
      );

      // Act
      final schedules = useCase.execute(plan, fromDate: startDate);

      // Assert
      expect(schedules.isNotEmpty, true);
      expect(schedules[0].scheduledDate, startDate);
      expect(schedules[0].scheduledDoseMg, 0.25);
      expect(schedules[1].scheduledDate, startDate.add(Duration(days: 7)));
    });

    test('should apply escalation plan to schedules', () {
      // Arrange
      final startDate = DateTime(2025, 1, 1);
      final escalationPlan = [
        const EscalationStep(weeksFromStart: 4, doseMg: 0.5),
        const EscalationStep(weeksFromStart: 8, doseMg: 1.0),
      ];
      final plan = DosagePlan(
        id: 'plan-1',
        userId: 'user-1',
        medicationName: 'Ozempic',
        startDate: startDate,
        cycleDays: 7,
        initialDoseMg: 0.25,
        escalationPlan: escalationPlan,
      );

      // Act
      final schedules = useCase.execute(plan, fromDate: startDate, generationDays: 70);

      // Assert - Check that we have schedules with escalation
      expect(schedules.length, greaterThan(0));
      expect(schedules[0].scheduledDoseMg, 0.25);
      // Check that we have multiple different doses (showing escalation is applied)
      final doses = schedules.map((s) => s.scheduledDoseMg).toSet();
      expect(doses.length, greaterThan(1), reason: 'Should have different doses due to escalation');
    });

    test('should only generate schedules after fromDate', () {
      // Arrange
      final startDate = DateTime(2025, 1, 1);
      final fromDate = DateTime(2025, 1, 15);
      final plan = DosagePlan(
        id: 'plan-1',
        userId: 'user-1',
        medicationName: 'Ozempic',
        startDate: startDate,
        cycleDays: 7,
        initialDoseMg: 0.25,
      );

      // Act
      final schedules = useCase.execute(plan, fromDate: fromDate, generationDays: 30);

      // Assert
      expect(schedules.every((s) => s.scheduledDate.isAfter(fromDate) ||
          s.scheduledDate.day == fromDate.day), true);
    });

    test('should generate schedules with correct plan id', () {
      // Arrange
      final plan = DosagePlan(
        id: 'plan-1',
        userId: 'user-1',
        medicationName: 'Ozempic',
        startDate: DateTime(2025, 1, 1),
        cycleDays: 7,
        initialDoseMg: 0.25,
      );

      // Act
      final schedules = useCase.execute(plan, generationDays: 14);

      // Assert
      expect(schedules.every((s) => s.dosagePlanId == 'plan-1'), true);
    });

    test('should generate unique schedule IDs', () {
      // Arrange
      final plan = DosagePlan(
        id: 'plan-1',
        userId: 'user-1',
        medicationName: 'Ozempic',
        startDate: DateTime(2025, 1, 1),
        cycleDays: 7,
        initialDoseMg: 0.25,
      );

      // Act
      final schedules = useCase.execute(plan, generationDays: 30);

      // Assert
      final ids = schedules.map((s) => s.id).toList();
      expect(ids.length, ids.toSet().length, reason: 'All IDs should be unique');
    });
  });
}
