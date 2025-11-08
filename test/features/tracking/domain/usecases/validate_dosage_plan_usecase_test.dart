import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';
import 'package:n06/features/tracking/domain/usecases/validate_dosage_plan_usecase.dart';

void main() {
  group('ValidateDosagePlanUseCase', () {
    late ValidateDosagePlanUseCase useCase;

    setUp(() {
      useCase = ValidateDosagePlanUseCase();
    });

    group('valid dosage plan', () {
      test('should return success for valid dosage plan', () {
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
        final result = useCase.validate(plan);

        // Assert
        expect(result.isValid, true);
        expect(result.errorMessage, isNull);
      });

      test('should return success for valid dosage plan with escalation', () {
        // Arrange
        final escalationPlan = [
          const EscalationStep(weeksFromStart: 4, doseMg: 0.5),
          const EscalationStep(weeksFromStart: 8, doseMg: 1.0),
        ];
        final plan = DosagePlan(
          id: 'plan-1',
          userId: 'user-1',
          medicationName: 'Ozempic',
          startDate: DateTime(2025, 1, 1),
          cycleDays: 7,
          initialDoseMg: 0.25,
          escalationPlan: escalationPlan,
        );

        // Act
        final result = useCase.validate(plan);

        // Assert
        expect(result.isValid, true);
      });
    });

    group('validates plan structure', () {
      test('should validate medication name is not empty', () {
        // The entity constructor validates this, so we test the logic directly
        final result = useCase.validateMedicationName('');
        expect(result.isValid, false);
        expect(result.errorMessage, contains('약물명'));
      });

      test('should validate cycle days is positive', () {
        final result = useCase.validateCycleDays(0);
        expect(result.isValid, false);
        expect(result.errorMessage, contains('주기'));
      });

      test('should validate initial dose is positive', () {
        final result = useCase.validateInitialDose(0.0);
        expect(result.isValid, false);
        expect(result.errorMessage, contains('용량'));
      });

      test('should validate escalation plan monotonicity', () {
        final steps = [
          const EscalationStep(weeksFromStart: 4, doseMg: 1.0),
          const EscalationStep(weeksFromStart: 8, doseMg: 0.5),
        ];
        final result = useCase.validateEscalationPlan(0.25, steps);
        expect(result.isValid, false);
        expect(result.errorMessage, contains('증량'));
      });
    });
  });
}
