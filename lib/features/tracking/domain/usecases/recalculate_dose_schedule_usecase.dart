import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';
import 'package:uuid/uuid.dart';

/// UseCase to recalculate dose schedules based on updated dosage plan
/// Generates new schedules for the future, preserving past records
class RecalculateDoseScheduleUseCase {
  static const _uuid = Uuid();

  /// Execute schedule recalculation
  /// Returns list of DoseSchedule for the future (after current date)
  List<DoseSchedule> execute(
    DosagePlan plan, {
    DateTime? fromDate,
    int? generationDays = 365,
  }) {
    final startDate = fromDate ?? DateTime.now();
    final schedules = <DoseSchedule>[];

    // Generate schedules starting from startDate
    DateTime currentDate = DateTime(startDate.year, startDate.month, startDate.day);
    DateTime endDate = currentDate.add(Duration(days: generationDays ?? 365));

    // Align to first dose date if plan start is in the future
    if (plan.startDate.isAfter(currentDate)) {
      currentDate = DateTime(plan.startDate.year, plan.startDate.month, plan.startDate.day);
    }

    // Generate schedules
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      final weeksElapsed = _calculateWeeksElapsed(plan.startDate, currentDate);
      final dose = plan.getCurrentDose(weeksElapsed: weeksElapsed);

      final schedule = DoseSchedule(
        id: _uuid.v4(),
        dosagePlanId: plan.id,
        scheduledDate: currentDate,
        scheduledDoseMg: dose,
      );

      schedules.add(schedule);

      // Move to next dose date
      currentDate = currentDate.add(Duration(days: plan.cycleDays));
    }

    return schedules;
  }

  /// Calculate weeks elapsed since plan start date
  int _calculateWeeksElapsed(DateTime startDate, DateTime currentDate) {
    final difference = currentDate.difference(startDate);
    return (difference.inDays / 7).floor();
  }
}
