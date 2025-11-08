import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';
import 'package:n06/features/tracking/domain/usecases/analyze_plan_change_impact_usecase.dart';

void main() {
  group('AnalyzePlanChangeImpactUseCase', () {
    late AnalyzePlanChangeImpactUseCase useCase;

    setUp(() {
      useCase = AnalyzePlanChangeImpactUseCase();
    });

    test('should detect no changes when plans are identical', () {
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
      final impact = useCase.execute(
        oldPlan: plan,
        newPlan: plan,
        fromDate: DateTime.now(),
      );

      // Assert
      expect(impact.hasChanges, false);
      expect(impact.changedFields.isEmpty, true);
      expect(impact.affectedScheduleCount, 0);
    });

    test('should detect medication name change', () {
      // Arrange
      final oldPlan = DosagePlan(
        id: 'plan-1',
        userId: 'user-1',
        medicationName: 'Ozempic',
        startDate: DateTime(2025, 1, 1),
        cycleDays: 7,
        initialDoseMg: 0.25,
      );
      final newPlan = oldPlan.copyWith(medicationName: 'Wegovy');

      // Act
      final impact = useCase.execute(
        oldPlan: oldPlan,
        newPlan: newPlan,
        fromDate: DateTime.now(),
      );

      // Assert
      expect(impact.hasChanges, true);
      expect(impact.changedFields, contains('medicationName'));
    });

    test('should detect start date change', () {
      // Arrange
      final oldPlan = DosagePlan(
        id: 'plan-1',
        userId: 'user-1',
        medicationName: 'Ozempic',
        startDate: DateTime(2025, 1, 1),
        cycleDays: 7,
        initialDoseMg: 0.25,
      );
      final newPlan = oldPlan.copyWith(startDate: DateTime(2025, 1, 15));

      // Act
      final impact = useCase.execute(
        oldPlan: oldPlan,
        newPlan: newPlan,
        fromDate: DateTime.now(),
      );

      // Assert
      expect(impact.hasChanges, true);
      expect(impact.changedFields, contains('startDate'));
    });

    test('should detect cycle days change', () {
      // Arrange
      final oldPlan = DosagePlan(
        id: 'plan-1',
        userId: 'user-1',
        medicationName: 'Ozempic',
        startDate: DateTime(2025, 1, 1),
        cycleDays: 7,
        initialDoseMg: 0.25,
      );
      final newPlan = oldPlan.copyWith(cycleDays: 14);

      // Act
      final impact = useCase.execute(
        oldPlan: oldPlan,
        newPlan: newPlan,
        fromDate: DateTime.now(),
      );

      // Assert
      expect(impact.hasChanges, true);
      expect(impact.changedFields, contains('cycleDays'));
    });

    test('should detect initial dose change', () {
      // Arrange
      final oldPlan = DosagePlan(
        id: 'plan-1',
        userId: 'user-1',
        medicationName: 'Ozempic',
        startDate: DateTime(2025, 1, 1),
        cycleDays: 7,
        initialDoseMg: 0.25,
      );
      final newPlan = oldPlan.copyWith(initialDoseMg: 0.5);

      // Act
      final impact = useCase.execute(
        oldPlan: oldPlan,
        newPlan: newPlan,
        fromDate: DateTime.now(),
      );

      // Assert
      expect(impact.hasChanges, true);
      expect(impact.changedFields, contains('initialDoseMg'));
    });

    test('should detect escalation plan change', () {
      // Arrange
      final oldPlan = DosagePlan(
        id: 'plan-1',
        userId: 'user-1',
        medicationName: 'Ozempic',
        startDate: DateTime(2025, 1, 1),
        cycleDays: 7,
        initialDoseMg: 0.25,
        escalationPlan: [
          const EscalationStep(weeksFromStart: 4, doseMg: 0.5),
        ],
      );
      final newPlan = oldPlan.copyWith(
        escalationPlan: [
          const EscalationStep(weeksFromStart: 4, doseMg: 1.0),
        ],
      );

      // Act
      final impact = useCase.execute(
        oldPlan: oldPlan,
        newPlan: newPlan,
        fromDate: DateTime.now(),
      );

      // Assert
      expect(impact.hasChanges, true);
      expect(impact.changedFields, contains('escalationPlan'));
      expect(impact.hasEscalationChange, true);
    });

    test('should calculate affected schedule count', () {
      // Arrange
      final oldPlan = DosagePlan(
        id: 'plan-1',
        userId: 'user-1',
        medicationName: 'Ozempic',
        startDate: DateTime(2025, 1, 1),
        cycleDays: 7,
        initialDoseMg: 0.25,
      );
      final newPlan = oldPlan.copyWith(cycleDays: 14);

      // Act
      final impact = useCase.execute(
        oldPlan: oldPlan,
        newPlan: newPlan,
        fromDate: DateTime.now(),
      );

      // Assert
      expect(impact.affectedScheduleCount, greaterThan(0));
    });

    test('should generate warning for significant dose change', () {
      // Arrange
      final oldPlan = DosagePlan(
        id: 'plan-1',
        userId: 'user-1',
        medicationName: 'Ozempic',
        startDate: DateTime(2025, 1, 1),
        cycleDays: 7,
        initialDoseMg: 0.25,
      );
      final newPlan = oldPlan.copyWith(initialDoseMg: 0.6); // > 20% increase

      // Act
      final impact = useCase.execute(
        oldPlan: oldPlan,
        newPlan: newPlan,
        fromDate: DateTime.now(),
      );

      // Assert
      expect(impact.warningMessage, isNotNull);
      expect(impact.warningMessage, contains('용량'));
    });

    test('should detect multiple changes', () {
      // Arrange
      final oldPlan = DosagePlan(
        id: 'plan-1',
        userId: 'user-1',
        medicationName: 'Ozempic',
        startDate: DateTime(2025, 1, 1),
        cycleDays: 7,
        initialDoseMg: 0.25,
      );
      final newPlan = oldPlan.copyWith(
        medicationName: 'Wegovy',
        cycleDays: 14,
        initialDoseMg: 0.5,
      );

      // Act
      final impact = useCase.execute(
        oldPlan: oldPlan,
        newPlan: newPlan,
        fromDate: DateTime.now(),
      );

      // Assert
      expect(impact.changedFields.length, 3);
      expect(impact.changedFields, contains('medicationName'));
      expect(impact.changedFields, contains('cycleDays'));
      expect(impact.changedFields, contains('initialDoseMg'));
    });
  });
}
