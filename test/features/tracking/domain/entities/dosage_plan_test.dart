import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';

void main() {
  group('DosagePlan', () {
    group('constructor validation', () {
      test('should create valid dosage plan with required fields', () {
        final plan = DosagePlan(
          id: 'plan-1',
          userId: 'user-1',
          medicationName: 'Ozempic',
          startDate: DateTime(2025, 1, 1),
          cycleDays: 7,
          initialDoseMg: 0.25,
        );

        expect(plan.id, 'plan-1');
        expect(plan.userId, 'user-1');
        expect(plan.medicationName, 'Ozempic');
        expect(plan.initialDoseMg, 0.25);
        expect(plan.isActive, true);
        expect(plan.escalationPlan, null);
      });

      test('should throw exception when start date is in future', () {
        expect(
          () => DosagePlan(
            id: 'plan-1',
            userId: 'user-1',
            medicationName: 'Ozempic',
            startDate: DateTime.now().add(Duration(days: 1)),
            cycleDays: 7,
            initialDoseMg: 0.25,
          ),
          throwsArgumentError,
        );
      });

      test('should throw exception when cycle days is less than 1', () {
        expect(
          () => DosagePlan(
            id: 'plan-1',
            userId: 'user-1',
            medicationName: 'Ozempic',
            startDate: DateTime(2025, 1, 1),
            cycleDays: 0,
            initialDoseMg: 0.25,
          ),
          throwsArgumentError,
        );
      });

      test('should throw exception when initial dose is negative', () {
        expect(
          () => DosagePlan(
            id: 'plan-1',
            userId: 'user-1',
            medicationName: 'Ozempic',
            startDate: DateTime(2025, 1, 1),
            cycleDays: 7,
            initialDoseMg: -0.25,
          ),
          throwsArgumentError,
        );
      });

      test(
          'should throw exception when escalation plan has decreasing doses',
          () {
        expect(
          () => DosagePlan(
            id: 'plan-1',
            userId: 'user-1',
            medicationName: 'Ozempic',
            startDate: DateTime(2025, 1, 1),
            cycleDays: 7,
            initialDoseMg: 1.0,
            escalationPlan: [
              EscalationStep(weeksFromStart: 4, doseMg: 0.5), // 감량
              EscalationStep(weeksFromStart: 8, doseMg: 1.5),
            ],
          ),
          throwsArgumentError,
        );
      });

      test(
          'should throw exception when escalation dose is not positive',
          () {
        expect(
          () => DosagePlan(
            id: 'plan-1',
            userId: 'user-1',
            medicationName: 'Ozempic',
            startDate: DateTime(2025, 1, 1),
            cycleDays: 7,
            initialDoseMg: 2.0,
            escalationPlan: [
              EscalationStep(weeksFromStart: 4, doseMg: 0), // 0 or negative not allowed
            ],
          ),
          throwsArgumentError,
        );
      });

      test(
          'should throw exception when escalation time order is not maintained',
          () {
        expect(
          () => DosagePlan(
            id: 'plan-1',
            userId: 'user-1',
            medicationName: 'Ozempic',
            startDate: DateTime(2025, 1, 1),
            cycleDays: 7,
            initialDoseMg: 0.25,
            escalationPlan: [
              EscalationStep(weeksFromStart: 8, doseMg: 1.0),
              EscalationStep(weeksFromStart: 4, doseMg: 0.5), // 역순
            ],
          ),
          throwsArgumentError,
        );
      });
    });

    group('dose calculation', () {
      test('should return initial dose when no escalation plan exists', () {
        final plan = DosagePlan(
          id: 'plan-1',
          userId: 'user-1',
          medicationName: 'Ozempic',
          startDate: DateTime(2025, 1, 1),
          cycleDays: 7,
          initialDoseMg: 0.25,
        );

        expect(plan.getCurrentDose(weeksElapsed: 0), 0.25);
        expect(plan.getCurrentDose(weeksElapsed: 10), 0.25);
      });

      test('should return correct dose during escalation period', () {
        final plan = DosagePlan(
          id: 'plan-1',
          userId: 'user-1',
          medicationName: 'Ozempic',
          startDate: DateTime(2025, 1, 1),
          cycleDays: 7,
          initialDoseMg: 0.25,
          escalationPlan: [
            EscalationStep(weeksFromStart: 4, doseMg: 0.5),
            EscalationStep(weeksFromStart: 8, doseMg: 1.0),
          ],
        );

        // Weeks 0-4: 0.25mg (before week 4 completes)
        expect(plan.getCurrentDose(weeksElapsed: 0), 0.25);
        expect(plan.getCurrentDose(weeksElapsed: 3), 0.25);
        expect(plan.getCurrentDose(weeksElapsed: 4), 0.25); // Still initial dose

        // Weeks 5-7: 0.5mg (after week 4 completes)
        expect(plan.getCurrentDose(weeksElapsed: 5), 0.5);
        expect(plan.getCurrentDose(weeksElapsed: 7), 0.5);

        // Weeks 8+: 1.0mg (after week 8 completes)
        expect(plan.getCurrentDose(weeksElapsed: 8), 0.5); // Still 0.5mg at week 8
        expect(plan.getCurrentDose(weeksElapsed: 9), 1.0); // Escalate to 1.0mg after week 8
        expect(plan.getCurrentDose(weeksElapsed: 12), 1.0);
      });

      test('should return max dose after escalation completes', () {
        final plan = DosagePlan(
          id: 'plan-1',
          userId: 'user-1',
          medicationName: 'Ozempic',
          startDate: DateTime(2025, 1, 1),
          cycleDays: 7,
          initialDoseMg: 0.25,
          escalationPlan: [
            EscalationStep(weeksFromStart: 4, doseMg: 0.5),
            EscalationStep(weeksFromStart: 8, doseMg: 1.0),
            EscalationStep(weeksFromStart: 12, doseMg: 2.4),
          ],
        );

        expect(plan.getCurrentDose(weeksElapsed: 20), 2.4);
      });
    });

    group('state checking', () {
      test('should detect if plan is active', () {
        final plan = DosagePlan(
          id: 'plan-1',
          userId: 'user-1',
          medicationName: 'Ozempic',
          startDate: DateTime(2025, 1, 1),
          cycleDays: 7,
          initialDoseMg: 0.25,
          isActive: true,
        );

        expect(plan.isActive, true);
      });

      test('should detect if plan is inactive', () {
        final plan = DosagePlan(
          id: 'plan-1',
          userId: 'user-1',
          medicationName: 'Ozempic',
          startDate: DateTime(2025, 1, 1),
          cycleDays: 7,
          initialDoseMg: 0.25,
          isActive: false,
        );

        expect(plan.isActive, false);
      });
    });

    group('copyWith', () {
      test('should copy plan with updated fields', () {
        final original = DosagePlan(
          id: 'plan-1',
          userId: 'user-1',
          medicationName: 'Ozempic',
          startDate: DateTime(2025, 1, 1),
          cycleDays: 7,
          initialDoseMg: 0.25,
        );

        final updated = original.copyWith(
          medicationName: 'Saxenda',
          cycleDays: 14,
        );

        expect(updated.id, original.id);
        expect(updated.medicationName, 'Saxenda');
        expect(updated.cycleDays, 14);
        expect(updated.initialDoseMg, original.initialDoseMg);
      });
    });
  });
}
