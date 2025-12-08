import 'package:n06/core/domain/services/week_calculator.dart';
import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';
import 'package:n06/features/notification/domain/value_objects/notification_time.dart';

class ScheduleGeneratorUseCase {
  /// Generate complete schedule from plan start date to end date
  List<DoseSchedule> generateSchedules(
    DosagePlan plan,
    DateTime endDate, {
    NotificationTime? notificationTime,
  }) {
    if (endDate.isBefore(plan.startDate)) {
      return [];
    }

    final schedules = <DoseSchedule>[];
    DateTime currentDate = plan.startDate.add(Duration(days: plan.cycleDays));

    while (!currentDate.isAfter(endDate)) {
      final weeksElapsed = WeekCalculator.weeksElapsed(plan.startDate, currentDate);
      final currentDose = plan.getCurrentDose(weeksElapsed: weeksElapsed);

      final schedule = DoseSchedule(
        id: _generateId(plan.id, schedules.length),
        dosagePlanId: plan.id,
        scheduledDate: currentDate,
        scheduledDoseMg: currentDose,
        notificationTime: notificationTime,
      );

      schedules.add(schedule);
      currentDate = currentDate.add(Duration(days: plan.cycleDays));
    }

    return schedules;
  }

  /// Recalculate schedules from a specific change date
  List<DoseSchedule> recalculateSchedulesFrom(
    DosagePlan updatedPlan,
    DateTime changeDate,
    DateTime endDate,
    List<DoseSchedule> existingSchedules, {
    NotificationTime? notificationTime,
  }) {
    // Keep schedules before change date
    final keepSchedules = existingSchedules
        .where((s) => s.scheduledDate.isBefore(changeDate))
        .toList();

    // Generate new schedules from change date
    final newSchedules = <DoseSchedule>[];
    DateTime currentDate = changeDate;

    if (keepSchedules.isNotEmpty) {
      final lastKeptSchedule = keepSchedules.last;
      currentDate = lastKeptSchedule.scheduledDate
          .add(Duration(days: updatedPlan.cycleDays));
    }

    while (!currentDate.isAfter(endDate)) {
      final weeksElapsed =
          WeekCalculator.weeksElapsed(updatedPlan.startDate, currentDate);
      final currentDose = updatedPlan.getCurrentDose(weeksElapsed: weeksElapsed);

      final schedule = DoseSchedule(
        id: _generateId(updatedPlan.id, keepSchedules.length + newSchedules.length),
        dosagePlanId: updatedPlan.id,
        scheduledDate: currentDate,
        scheduledDoseMg: currentDose,
        notificationTime: notificationTime,
      );

      newSchedules.add(schedule);
      currentDate = currentDate.add(Duration(days: updatedPlan.cycleDays));
    }

    return [...keepSchedules, ...newSchedules];
  }

  /// Generate unique ID for schedule
  String _generateId(String planId, int index) {
    return '${planId}_schedule_$index';
  }
}
