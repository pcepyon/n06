import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';
import 'package:n06/features/tracking/domain/entities/plan_change_history.dart';
import 'package:n06/features/tracking/infrastructure/dtos/dosage_plan_dto.dart';
import 'package:n06/features/tracking/infrastructure/dtos/plan_change_history_dto.dart';
import 'package:n06/features/tracking/infrastructure/repositories/isar_dosage_plan_repository.dart';

void main() {
  group('IsarDosagePlanRepository', () {
    late Isar isar;
    late IsarDosagePlanRepository repository;

    setUp(() async {
      // In-memory Isar instance for testing
      isar = await Isar.open(
        [
          DosagePlanDtoSchema,
          PlanChangeHistoryDtoSchema,
        ],
        directory: '',
      );
      repository = IsarDosagePlanRepository(isar);
    });

    tearDown(() async {
      await isar.close();
    });

    group('getActiveDosagePlan', () {
      // TC-IDPR-01: Get active dosage plan for user
      test('should get active dosage plan for user', () async {
        // Arrange
        final plan = DosagePlan(
          id: 'plan-1',
          userId: 'user-1',
          medicationName: 'Ozempic',
          startDate: DateTime(2025, 1, 1),
          cycleDays: 7,
          initialDoseMg: 0.25,
          isActive: true,
        );
        await repository.saveDosagePlan(plan);

        // Act
        final result = await repository.getActiveDosagePlan('user-1');

        // Assert
        expect(result, isNotNull);
        expect(result!.id, 'plan-1');
        expect(result.isActive, true);
        expect(result.medicationName, 'Ozempic');
      });

      // TC-IDPR-02: Return null when no active plan
      test('should return null when no active plan exists', () async {
        // Act
        final result = await repository.getActiveDosagePlan('user-1');

        // Assert
        expect(result, isNull);
      });

      // TC-IDPR-03: Return only active plan when multiple plans exist
      test('should return only active plan when multiple plans exist', () async {
        // Arrange
        final activePlan = DosagePlan(
          id: 'plan-1',
          userId: 'user-1',
          medicationName: 'Ozempic',
          startDate: DateTime(2025, 1, 1),
          cycleDays: 7,
          initialDoseMg: 0.25,
          isActive: true,
        );
        final inactivePlan = DosagePlan(
          id: 'plan-2',
          userId: 'user-1',
          medicationName: 'Wegovy',
          startDate: DateTime(2024, 1, 1),
          cycleDays: 14,
          initialDoseMg: 0.5,
          isActive: false,
        );
        await repository.saveDosagePlan(activePlan);
        await repository.saveDosagePlan(inactivePlan);

        // Act
        final result = await repository.getActiveDosagePlan('user-1');

        // Assert
        expect(result!.id, 'plan-1');
        expect(result.isActive, true);
      });
    });

    group('getDosagePlan', () {
      // TC-IDPR-04: Get specific plan by ID
      test('should get specific plan by ID', () async {
        // Arrange
        final plan = DosagePlan(
          id: 'plan-1',
          userId: 'user-1',
          medicationName: 'Ozempic',
          startDate: DateTime(2025, 1, 1),
          cycleDays: 7,
          initialDoseMg: 0.25,
        );
        await repository.saveDosagePlan(plan);

        // Act
        final result = await repository.getDosagePlan('plan-1');

        // Assert
        expect(result, isNotNull);
        expect(result!.id, 'plan-1');
        expect(result.medicationName, 'Ozempic');
      });

      // TC-IDPR-05: Return null when plan doesn't exist
      test('should return null when plan does not exist', () async {
        // Act
        final result = await repository.getDosagePlan('nonexistent-plan');

        // Assert
        expect(result, isNull);
      });
    });

    group('saveDosagePlan', () {
      // TC-IDPR-06: Save new plan
      test('should save new dosage plan', () async {
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
        await repository.saveDosagePlan(plan);

        // Assert
        final saved = await repository.getDosagePlan('plan-1');
        expect(saved, isNotNull);
        expect(saved!.medicationName, 'Ozempic');
      });
    });

    group('updateDosagePlan', () {
      // TC-IDPR-07: Update existing plan
      test('should update existing dosage plan', () async {
        // Arrange
        final originalPlan = DosagePlan(
          id: 'plan-1',
          userId: 'user-1',
          medicationName: 'Ozempic',
          startDate: DateTime(2025, 1, 1),
          cycleDays: 7,
          initialDoseMg: 0.25,
        );
        await repository.saveDosagePlan(originalPlan);

        final updatedPlan = originalPlan.copyWith(
          medicationName: 'Wegovy',
          initialDoseMg: 0.5,
        );

        // Act
        await repository.updateDosagePlan(updatedPlan);

        // Assert
        final saved = await repository.getDosagePlan('plan-1');
        expect(saved!.medicationName, 'Wegovy');
        expect(saved.initialDoseMg, 0.5);
        expect(saved.cycleDays, 7); // Unchanged
      });
    });

    group('savePlanChangeHistory', () {
      // TC-IDPR-08: Save plan change history
      test('should save plan change history', () async {
        // Arrange
        final history = PlanChangeHistory(
          id: 'history-1',
          dosagePlanId: 'plan-1',
          changedAt: DateTime(2025, 2, 1),
          oldPlan: {'initialDoseMg': 0.25},
          newPlan: {'initialDoseMg': 0.5},
        );

        // Act
        await repository.savePlanChangeHistory(history);

        // Assert
        final saved = await repository.getPlanChangeHistory('plan-1');
        expect(saved, isNotEmpty);
        expect(saved.first.oldPlan['initialDoseMg'], 0.25);
        expect(saved.first.newPlan['initialDoseMg'], 0.5);
      });

      // TC-IDPR-09: Multiple history records
      test('should save multiple history records', () async {
        // Arrange
        final history1 = PlanChangeHistory(
          id: 'history-1',
          dosagePlanId: 'plan-1',
          changedAt: DateTime(2025, 1, 1),
          oldPlan: {'initialDoseMg': 0.25},
          newPlan: {'initialDoseMg': 0.5},
        );
        final history2 = PlanChangeHistory(
          id: 'history-2',
          dosagePlanId: 'plan-1',
          changedAt: DateTime(2025, 2, 1),
          oldPlan: {'initialDoseMg': 0.5},
          newPlan: {'initialDoseMg': 1.0},
        );

        // Act
        await repository.savePlanChangeHistory(history1);
        await repository.savePlanChangeHistory(history2);

        // Assert
        final saved = await repository.getPlanChangeHistory('plan-1');
        expect(saved.length, 2);
      });
    });

    group('getPlanChangeHistory', () {
      // TC-IDPR-10: Get history ordered by most recent first
      test('should get history ordered by most recent first', () async {
        // Arrange
        final history1 = PlanChangeHistory(
          id: 'history-1',
          dosagePlanId: 'plan-1',
          changedAt: DateTime(2025, 1, 1),
          oldPlan: {},
          newPlan: {},
        );
        final history2 = PlanChangeHistory(
          id: 'history-2',
          dosagePlanId: 'plan-1',
          changedAt: DateTime(2025, 2, 1),
          oldPlan: {},
          newPlan: {},
        );
        await repository.savePlanChangeHistory(history1);
        await repository.savePlanChangeHistory(history2);

        // Act
        final result = await repository.getPlanChangeHistory('plan-1');

        // Assert
        expect(result[0].id, 'history-2'); // Most recent
        expect(result[1].id, 'history-1');
      });

      // TC-IDPR-11: Return empty when no history
      test('should return empty list when no history exists', () async {
        // Act
        final result = await repository.getPlanChangeHistory('plan-1');

        // Assert
        expect(result, isEmpty);
      });
    });

    group('updatePlanWithHistory', () {
      // TC-IDPR-12: Update plan and save history in transaction
      test('should update plan and save history in transaction', () async {
        // Arrange
        final originalPlan = DosagePlan(
          id: 'plan-1',
          userId: 'user-1',
          medicationName: 'Ozempic',
          startDate: DateTime(2025, 1, 1),
          cycleDays: 7,
          initialDoseMg: 0.25,
        );
        await repository.saveDosagePlan(originalPlan);

        final updatedPlan = originalPlan.copyWith(initialDoseMg: 0.5);
        final history = PlanChangeHistory(
          id: 'history-1',
          dosagePlanId: 'plan-1',
          changedAt: DateTime.now(),
          oldPlan: {'initialDoseMg': 0.25},
          newPlan: {'initialDoseMg': 0.5},
        );

        // Act
        await repository.updatePlanWithHistory(updatedPlan, history);

        // Assert
        final plan = await repository.getDosagePlan('plan-1');
        final histories = await repository.getPlanChangeHistory('plan-1');

        expect(plan!.initialDoseMg, 0.5);
        expect(histories.length, 1);
        expect(histories.first.oldPlan['initialDoseMg'], 0.25);
      });

      // TC-IDPR-13: Transaction atomicity (both or nothing)
      test('should save both plan and history or neither', () async {
        // Arrange
        final originalPlan = DosagePlan(
          id: 'plan-1',
          userId: 'user-1',
          medicationName: 'Ozempic',
          startDate: DateTime(2025, 1, 1),
          cycleDays: 7,
          initialDoseMg: 0.25,
        );
        await repository.saveDosagePlan(originalPlan);

        final updatedPlan = originalPlan.copyWith(initialDoseMg: 0.5);
        final history = PlanChangeHistory(
          id: 'history-1',
          dosagePlanId: 'plan-1',
          changedAt: DateTime.now(),
          oldPlan: {'initialDoseMg': 0.25},
          newPlan: {'initialDoseMg': 0.5},
        );

        // Act
        await repository.updatePlanWithHistory(updatedPlan, history);

        // Assert - both should be saved together
        final plan = await repository.getDosagePlan('plan-1');
        final histories = await repository.getPlanChangeHistory('plan-1');

        expect(plan!.initialDoseMg, 0.5);
        expect(histories.length, 1);
      });
    });

    group('watchActiveDosagePlan', () {
      // TC-IDPR-14: Watch active plan stream
      test('should emit active plan on watch', () async {
        // Arrange
        final plan = DosagePlan(
          id: 'plan-1',
          userId: 'user-1',
          medicationName: 'Ozempic',
          startDate: DateTime(2025, 1, 1),
          cycleDays: 7,
          initialDoseMg: 0.25,
          isActive: true,
        );

        // Act & Assert
        await expectLater(
          repository.watchActiveDosagePlan('user-1'),
          emits(isNull),
        );

        await repository.saveDosagePlan(plan);

        await expectLater(
          repository.watchActiveDosagePlan('user-1'),
          emits(
            isA<DosagePlan>()
                .having((p) => p.id, 'id', 'plan-1')
                .having((p) => p.isActive, 'isActive', true),
          ),
        );
      });
    });
  });
}
