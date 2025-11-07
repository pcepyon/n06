import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';

void main() {
  group('DoseSchedule', () {
    test('should create dose schedule with valid data', () {
      final schedule = DoseSchedule(
        id: 'schedule-1',
        dosagePlanId: 'plan-1',
        scheduledDate: DateTime(2025, 1, 8),
        scheduledDoseMg: 0.25,
      );

      expect(schedule.id, 'schedule-1');
      expect(schedule.dosagePlanId, 'plan-1');
      expect(schedule.scheduledDoseMg, 0.25);
    });

    group('date comparisons', () {
      test('should detect if schedule is overdue', () {
        final schedule = DoseSchedule(
          id: 'schedule-1',
          dosagePlanId: 'plan-1',
          scheduledDate: DateTime.now().subtract(Duration(days: 1)),
          scheduledDoseMg: 0.25,
        );

        expect(schedule.isOverdue(), true);
      });

      test('should detect if schedule is today', () {
        final today = DateTime.now();
        final schedule = DoseSchedule(
          id: 'schedule-1',
          dosagePlanId: 'plan-1',
          scheduledDate: DateTime(today.year, today.month, today.day),
          scheduledDoseMg: 0.25,
        );

        expect(schedule.isToday(), true);
      });

      test('should detect if schedule is upcoming', () {
        final schedule = DoseSchedule(
          id: 'schedule-1',
          dosagePlanId: 'plan-1',
          scheduledDate: DateTime.now().add(Duration(days: 1)),
          scheduledDoseMg: 0.25,
        );

        expect(schedule.isUpcoming(), true);
      });

      test('should calculate days until scheduled date', () {
        final schedule = DoseSchedule(
          id: 'schedule-1',
          dosagePlanId: 'plan-1',
          scheduledDate: DateTime.now().add(Duration(days: 5)),
          scheduledDoseMg: 0.25,
        );

        final daysUntil = schedule.daysUntil();
        expect(daysUntil, 5);
      });

      test('should handle negative days (overdue)', () {
        final schedule = DoseSchedule(
          id: 'schedule-1',
          dosagePlanId: 'plan-1',
          scheduledDate: DateTime.now().subtract(Duration(days: 3)),
          scheduledDoseMg: 0.25,
        );

        final daysUntil = schedule.daysUntil();
        expect(daysUntil, -3);
      });
    });

    group('copyWith', () {
      test('should copy schedule with updated fields', () {
        final original = DoseSchedule(
          id: 'schedule-1',
          dosagePlanId: 'plan-1',
          scheduledDate: DateTime(2025, 1, 8),
          scheduledDoseMg: 0.25,
        );

        final updated = original.copyWith(
          scheduledDoseMg: 0.5,
        );

        expect(updated.id, original.id);
        expect(updated.dosagePlanId, original.dosagePlanId);
        expect(updated.scheduledDoseMg, 0.5);
      });
    });
  });
}
