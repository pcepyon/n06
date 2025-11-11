import 'package:n06/features/notification/domain/value_objects/notification_time.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';
import 'package:n06/features/tracking/domain/usecases/schedule_generator_usecase.dart';

void main() {
  group('ScheduleGeneratorUseCase', () {
    late ScheduleGeneratorUseCase useCase;

    setUp(() {
      useCase = ScheduleGeneratorUseCase();
    });

    group('simple schedule generation', () {
      test('should generate schedule for simple plan without escalation', () {
        final startDate = DateTime(2025, 1, 1);
        final plan = DosagePlan(
          id: 'plan-1',
          userId: 'user-1',
          medicationName: 'Ozempic',
          startDate: startDate,
          cycleDays: 7,
          initialDoseMg: 0.25,
        );

        final endDate = DateTime(2025, 1, 29); // 4 weeks

        final schedules = useCase.generateSchedules(
          plan,
          endDate,
          notificationTime: NotificationTime(hour: 9, minute: 0),
        );

        expect(schedules.length, 4);
        expect(schedules[0].scheduledDate, DateTime(2025, 1, 8));
        expect(schedules[0].scheduledDoseMg, 0.25);
        expect(schedules[1].scheduledDate, DateTime(2025, 1, 15));
        expect(schedules[2].scheduledDate, DateTime(2025, 1, 22));
        expect(schedules[3].scheduledDate, DateTime(2025, 1, 29));
      });

      test('should generate empty list when end date before start date', () {
        final startDate = DateTime(2025, 1, 1);
        final plan = DosagePlan(
          id: 'plan-1',
          userId: 'user-1',
          medicationName: 'Ozempic',
          startDate: startDate,
          cycleDays: 7,
          initialDoseMg: 0.25,
        );

        final endDate = DateTime(2024, 12, 31);

        final schedules = useCase.generateSchedules(plan, endDate);

        expect(schedules.isEmpty, true);
      });
    });

    group('escalation plan generation', () {
      test('should generate schedule with escalation plan', () {
        final startDate = DateTime(2025, 1, 1);
        final plan = DosagePlan(
          id: 'plan-1',
          userId: 'user-1',
          medicationName: 'Ozempic',
          startDate: startDate,
          cycleDays: 7,
          initialDoseMg: 0.25,
          escalationPlan: [
            EscalationStep(weeksFromStart: 4, doseMg: 0.5),
            EscalationStep(weeksFromStart: 8, doseMg: 1.0),
          ],
        );

        final endDate = DateTime(2025, 2, 26); // 8+ weeks

        final schedules = useCase.generateSchedules(plan, endDate);

        // Week 1-4: 0.25mg
        expect(schedules[0].scheduledDoseMg, 0.25); // Jan 8
        expect(schedules[1].scheduledDoseMg, 0.25); // Jan 15
        expect(schedules[2].scheduledDoseMg, 0.25); // Jan 22
        expect(schedules[3].scheduledDoseMg, 0.25); // Jan 29

        // Week 5-8: 0.5mg
        expect(schedules[4].scheduledDoseMg, 0.5); // Feb 5
        expect(schedules[5].scheduledDoseMg, 0.5); // Feb 12
        expect(schedules[6].scheduledDoseMg, 0.5); // Feb 19
        expect(schedules[7].scheduledDoseMg, 0.5); // Feb 26
      });
    });

    group('performance', () {
      test('should generate 6 months schedule within 1 second', () {
        final startDate = DateTime(2025, 1, 1);
        final plan = DosagePlan(
          id: 'plan-1',
          userId: 'user-1',
          medicationName: 'Ozempic',
          startDate: startDate,
          cycleDays: 7,
          initialDoseMg: 0.25,
          escalationPlan: [
            EscalationStep(weeksFromStart: 4, doseMg: 0.5),
            EscalationStep(weeksFromStart: 8, doseMg: 1.0),
            EscalationStep(weeksFromStart: 12, doseMg: 2.4),
          ],
        );

        final endDate = DateTime(2025, 7, 1); // 6 months

        final stopwatch = Stopwatch()..start();
        final schedules = useCase.generateSchedules(plan, endDate);
        stopwatch.stop();

        expect(schedules.isNotEmpty, true);
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });

    group('recalculation', () {
      test('should recalculate schedules from specific date', () {
        final startDate = DateTime(2025, 1, 1);
        final plan = DosagePlan(
          id: 'plan-1',
          userId: 'user-1',
          medicationName: 'Ozempic',
          startDate: startDate,
          cycleDays: 7,
          initialDoseMg: 0.25,
          escalationPlan: [
            EscalationStep(weeksFromStart: 4, doseMg: 0.5),
          ],
        );

        final originalEndDate = DateTime(2025, 2, 26);
        final originalSchedules =
            useCase.generateSchedules(plan, originalEndDate);

        // Change plan at week 3
        final changeDate = DateTime(2025, 1, 22); // Week 3
        final updatedPlan = plan.copyWith(
          escalationPlan: [
            EscalationStep(weeksFromStart: 2, doseMg: 0.5),
          ],
        );

        final recalculatedSchedules = useCase.recalculateSchedulesFrom(
          updatedPlan,
          changeDate,
          originalEndDate,
          originalSchedules,
        );

        // Schedules before change date should be unchanged
        expect(
          recalculatedSchedules.where((s) => s.scheduledDate.isBefore(changeDate)).length,
          lessThanOrEqualTo(2),
        );

        // After change date, dose should be 0.5mg
        final afterChangeSchedules = recalculatedSchedules
            .where((s) =>
                s.scheduledDate.isAfter(changeDate) ||
                s.scheduledDate.isAtSameMomentAs(changeDate))
            .toList();

        expect(afterChangeSchedules.isNotEmpty, true);
        expect(afterChangeSchedules.every((s) => s.scheduledDoseMg >= 0.5), true);
      });
    });

    group('notification time', () {
      test('should apply notification time to all schedules', () {
        final startDate = DateTime(2025, 1, 1);
        final plan = DosagePlan(
          id: 'plan-1',
          userId: 'user-1',
          medicationName: 'Ozempic',
          startDate: startDate,
          cycleDays: 7,
          initialDoseMg: 0.25,
        );

        final endDate = DateTime(2025, 1, 29);
        final notificationTime = NotificationTime(hour: 14, minute: 30);

        final schedules = useCase.generateSchedules(
          plan,
          endDate,
          notificationTime: notificationTime,
        );

        for (final schedule in schedules) {
          expect(schedule.notificationTime, isNotNull);
          if (schedule.notificationTime is NotificationTime) {
            final time = schedule.notificationTime as NotificationTime;
            expect(time.hour, 14);
            expect(time.minute, 30);
          }
        }
      });
    });
  });
}
