import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';

class TimeOfDay {
  final int hour;
  final int minute;

  TimeOfDay({required this.hour, required this.minute});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeOfDay &&
          runtimeType == other.runtimeType &&
          hour == other.hour &&
          minute == other.minute;

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;
}

class ScheduleGeneratorUseCase {
  /// Generate complete schedule from plan start date to end date
  List<DoseSchedule> generateSchedules(
    DosagePlan plan,
    DateTime endDate, {
    Object? notificationTime,
  }) {
    if (endDate.isBefore(plan.startDate)) {
      return [];
    }

    final schedules = <DoseSchedule>[];
    DateTime currentDate = plan.startDate.add(Duration(days: plan.cycleDays));

    while (!currentDate.isAfter(endDate)) {
      final weeksElapsed = _calculateWeeksElapsed(plan.startDate, currentDate);
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
    Object? notificationTime,
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
          _calculateWeeksElapsed(updatedPlan.startDate, currentDate);
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

  /// Calculate weeks elapsed since plan start date
  int _calculateWeeksElapsed(DateTime startDate, DateTime currentDate) {
    final difference = currentDate.difference(startDate);
    return (difference.inDays / 7).ceil();
  }

  /// Generate unique ID for schedule
  String _generateId(String planId, int index) {
    return '${planId}_schedule_$index';
  }
}
