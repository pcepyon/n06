import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';
import 'package:n06/features/tracking/infrastructure/dtos/dose_schedule_dto.dart';
import 'package:n06/features/tracking/infrastructure/repositories/isar_dose_schedule_repository.dart';

void main() {
  group('IsarDoseScheduleRepository', () {
    late Isar isar;
    late IsarDoseScheduleRepository repository;

    setUp(() async {
      // In-memory Isar instance for testing
      isar = await Isar.open(
        [DoseScheduleDtoSchema],
        directory: '',
      );
      repository = IsarDoseScheduleRepository(isar);
    });

    tearDown(() async {
      await isar.close();
    });

    group('saveBatchSchedules', () {
      // TC-IDSR-01: Save batch of schedules
      test('should save batch of schedules', () async {
        // Arrange
        final schedules = [
          DoseSchedule(
            id: 'schedule-1',
            dosagePlanId: 'plan-1',
            scheduledDate: DateTime(2025, 1, 1),
            scheduledDoseMg: 0.25,
          ),
          DoseSchedule(
            id: 'schedule-2',
            dosagePlanId: 'plan-1',
            scheduledDate: DateTime(2025, 1, 8),
            scheduledDoseMg: 0.25,
          ),
          DoseSchedule(
            id: 'schedule-3',
            dosagePlanId: 'plan-1',
            scheduledDate: DateTime(2025, 1, 15),
            scheduledDoseMg: 0.5,
          ),
        ];

        // Act
        await repository.saveBatchSchedules(schedules);

        // Assert
        final saved = await repository.getSchedulesByPlanId('plan-1');
        expect(saved.length, 3);
        expect(saved[0].id, 'schedule-1');
        expect(saved[1].id, 'schedule-2');
        expect(saved[2].id, 'schedule-3');
      });

      // TC-IDSR-02: Save many schedules efficiently
      test('should save many schedules efficiently', () async {
        // Arrange
        final schedules = List.generate(
          100,
          (i) => DoseSchedule(
            id: 'schedule-$i',
            dosagePlanId: 'plan-1',
            scheduledDate: DateTime(2025, 1, 1).add(Duration(days: i * 7)),
            scheduledDoseMg: 0.25,
          ),
        );

        // Act
        final stopwatch = Stopwatch()..start();
        await repository.saveBatchSchedules(schedules);
        stopwatch.stop();

        // Assert
        final saved = await repository.getSchedulesByPlanId('plan-1');
        expect(saved.length, 100);
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Should be fast
      });
    });

    group('getSchedulesByPlanId', () {
      // TC-IDSR-03: Get schedules by plan ID
      test('should get schedules by plan ID', () async {
        // Arrange
        final schedules = [
          DoseSchedule(
            id: 'schedule-1',
            dosagePlanId: 'plan-1',
            scheduledDate: DateTime(2025, 1, 1),
            scheduledDoseMg: 0.25,
          ),
          DoseSchedule(
            id: 'schedule-2',
            dosagePlanId: 'plan-1',
            scheduledDate: DateTime(2025, 1, 8),
            scheduledDoseMg: 0.25,
          ),
        ];
        await repository.saveBatchSchedules(schedules);

        // Act
        final result = await repository.getSchedulesByPlanId('plan-1');

        // Assert
        expect(result.length, 2);
        expect(result.every((s) => s.dosagePlanId == 'plan-1'), true);
      });

      // TC-IDSR-04: Return empty when plan has no schedules
      test('should return empty list when plan has no schedules', () async {
        // Act
        final result = await repository.getSchedulesByPlanId('plan-1');

        // Assert
        expect(result, isEmpty);
      });

      // TC-IDSR-05: Get schedules for different plans separately
      test('should get schedules for different plans separately', () async {
        // Arrange
        final plan1Schedules = [
          DoseSchedule(
            id: 'schedule-1',
            dosagePlanId: 'plan-1',
            scheduledDate: DateTime(2025, 1, 1),
            scheduledDoseMg: 0.25,
          ),
        ];
        final plan2Schedules = [
          DoseSchedule(
            id: 'schedule-2',
            dosagePlanId: 'plan-2',
            scheduledDate: DateTime(2025, 1, 1),
            scheduledDoseMg: 0.5,
          ),
        ];
        await repository.saveBatchSchedules([...plan1Schedules, ...plan2Schedules]);

        // Act
        final plan1Result = await repository.getSchedulesByPlanId('plan-1');
        final plan2Result = await repository.getSchedulesByPlanId('plan-2');

        // Assert
        expect(plan1Result.length, 1);
        expect(plan1Result.first.dosagePlanId, 'plan-1');
        expect(plan1Result.first.scheduledDoseMg, 0.25);

        expect(plan2Result.length, 1);
        expect(plan2Result.first.dosagePlanId, 'plan-2');
        expect(plan2Result.first.scheduledDoseMg, 0.5);
      });
    });

    group('deleteFutureSchedules', () {
      // TC-IDSR-06: Delete schedules from specific date onwards
      test('should delete schedules from specific date onwards', () async {
        // Arrange
        final schedules = [
          DoseSchedule(
            id: 'schedule-1',
            dosagePlanId: 'plan-1',
            scheduledDate: DateTime(2025, 1, 1),
            scheduledDoseMg: 0.25,
          ),
          DoseSchedule(
            id: 'schedule-2',
            dosagePlanId: 'plan-1',
            scheduledDate: DateTime(2025, 1, 15),
            scheduledDoseMg: 0.25,
          ),
          DoseSchedule(
            id: 'schedule-3',
            dosagePlanId: 'plan-1',
            scheduledDate: DateTime(2025, 2, 1),
            scheduledDoseMg: 0.5,
          ),
        ];
        await repository.saveBatchSchedules(schedules);

        // Act
        await repository.deleteFutureSchedules('plan-1', DateTime(2025, 1, 10));

        // Assert
        final remaining = await repository.getSchedulesByPlanId('plan-1');
        expect(remaining.length, 1);
        expect(remaining.first.id, 'schedule-1');
      });

      // TC-IDSR-07: Preserve past schedules
      test('should preserve past schedules when deleting future ones', () async {
        // Arrange
        final now = DateTime.now();
        final schedules = [
          DoseSchedule(
            id: 'schedule-1',
            dosagePlanId: 'plan-1',
            scheduledDate: now.subtract(Duration(days: 30)),
            scheduledDoseMg: 0.25,
          ),
          DoseSchedule(
            id: 'schedule-2',
            dosagePlanId: 'plan-1',
            scheduledDate: now.add(Duration(days: 30)),
            scheduledDoseMg: 0.25,
          ),
        ];
        await repository.saveBatchSchedules(schedules);

        // Act
        await repository.deleteFutureSchedules('plan-1', now);

        // Assert
        final remaining = await repository.getSchedulesByPlanId('plan-1');
        expect(remaining.length, 1);
        expect(remaining.first.id, 'schedule-1');
      });

      // TC-IDSR-08: Delete all future schedules when date is today
      test('should delete all future schedules when date is today', () async {
        // Arrange
        final today = DateTime.now();
        final schedules = [
          DoseSchedule(
            id: 'schedule-1',
            dosagePlanId: 'plan-1',
            scheduledDate: today.add(Duration(days: 1)),
            scheduledDoseMg: 0.25,
          ),
          DoseSchedule(
            id: 'schedule-2',
            dosagePlanId: 'plan-1',
            scheduledDate: today.add(Duration(days: 7)),
            scheduledDoseMg: 0.25,
          ),
        ];
        await repository.saveBatchSchedules(schedules);

        // Act
        await repository.deleteFutureSchedules('plan-1', today);

        // Assert
        final remaining = await repository.getSchedulesByPlanId('plan-1');
        expect(remaining, isEmpty);
      });

      // TC-IDSR-09: No effect when deleting from future date
      test('should have no effect when deleting from future date', () async {
        // Arrange
        final schedules = [
          DoseSchedule(
            id: 'schedule-1',
            dosagePlanId: 'plan-1',
            scheduledDate: DateTime(2025, 1, 1),
            scheduledDoseMg: 0.25,
          ),
          DoseSchedule(
            id: 'schedule-2',
            dosagePlanId: 'plan-1',
            scheduledDate: DateTime(2025, 1, 8),
            scheduledDoseMg: 0.25,
          ),
        ];
        await repository.saveBatchSchedules(schedules);

        // Act
        await repository.deleteFutureSchedules('plan-1', DateTime(2030, 1, 1));

        // Assert
        final remaining = await repository.getSchedulesByPlanId('plan-1');
        expect(remaining.length, 2); // No deletion
      });

      // TC-IDSR-10: Only affects specified plan
      test('should only affect specified plan', () async {
        // Arrange
        final schedules = [
          DoseSchedule(
            id: 'schedule-1',
            dosagePlanId: 'plan-1',
            scheduledDate: DateTime(2025, 2, 1),
            scheduledDoseMg: 0.25,
          ),
          DoseSchedule(
            id: 'schedule-2',
            dosagePlanId: 'plan-2',
            scheduledDate: DateTime(2025, 2, 1),
            scheduledDoseMg: 0.5,
          ),
        ];
        await repository.saveBatchSchedules(schedules);

        // Act
        await repository.deleteFutureSchedules('plan-1', DateTime(2025, 1, 1));

        // Assert
        final plan1Schedules = await repository.getSchedulesByPlanId('plan-1');
        final plan2Schedules = await repository.getSchedulesByPlanId('plan-2');

        expect(plan1Schedules, isEmpty);
        expect(plan2Schedules.length, 1);
        expect(plan2Schedules.first.id, 'schedule-2');
      });
    });

    group('watchSchedulesByPlanId', () {
      // TC-IDSR-11: Watch schedules stream
      test('should emit schedules on watch', () async {
        // Arrange
        final schedules = [
          DoseSchedule(
            id: 'schedule-1',
            dosagePlanId: 'plan-1',
            scheduledDate: DateTime(2025, 1, 1),
            scheduledDoseMg: 0.25,
          ),
        ];

        // Act & Assert
        await expectLater(
          repository.watchSchedulesByPlanId('plan-1'),
          emits(isEmpty),
        );

        await repository.saveBatchSchedules(schedules);

        await expectLater(
          repository.watchSchedulesByPlanId('plan-1'),
          emits(
            isA<List<DoseSchedule>>()
                .having((list) => list.length, 'length', 1)
                .having(
                  (list) => list.first.id,
                  'first.id',
                  'schedule-1',
                ),
          ),
        );
      });
    });
  });
}
