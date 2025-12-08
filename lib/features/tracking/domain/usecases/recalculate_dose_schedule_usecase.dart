import 'package:n06/core/domain/services/week_calculator.dart';
import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';
import 'package:uuid/uuid.dart';

/// UseCase to recalculate dose schedules based on updated dosage plan
/// Generates new schedules for the future, preserving past records
class RecalculateDoseScheduleUseCase {
  static const _uuid = Uuid();

  /// Execute schedule recalculation
  /// Returns list of DoseSchedule for the future (after current date)
  /// Schedules are always aligned with plan.startDate
  List<DoseSchedule> execute(
    DosagePlan plan, {
    DateTime? fromDate,
    int? generationDays = 365,
  }) {
    final referenceDate = fromDate ?? DateTime.now();
    final schedules = <DoseSchedule>[];

    // Normalize dates to midnight
    final normalizedFromDate = DateTime(referenceDate.year, referenceDate.month, referenceDate.day);
    final normalizedPlanStart = DateTime(plan.startDate.year, plan.startDate.month, plan.startDate.day);
    final endDate = normalizedFromDate.add(Duration(days: generationDays ?? 365));

    // Find the first schedule date on or after fromDate, aligned with plan.startDate
    DateTime currentDate = _findFirstAlignedDate(
      planStartDate: normalizedPlanStart,
      fromDate: normalizedFromDate,
      cycleDays: plan.cycleDays,
    );

    // Generate schedules
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      final weeksElapsed = WeekCalculator.weeksElapsed(plan.startDate, currentDate);
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

  /// Find the first schedule date on or after fromDate, aligned with planStartDate
  DateTime _findFirstAlignedDate({
    required DateTime planStartDate,
    required DateTime fromDate,
    required int cycleDays,
  }) {
    // If plan starts on or after fromDate, use plan start date
    if (!planStartDate.isBefore(fromDate)) {
      return planStartDate;
    }

    // Calculate how many cycles have passed since plan start
    final daysDiff = fromDate.difference(planStartDate).inDays;
    final cyclesPassed = daysDiff ~/ cycleDays;

    // Calculate the next aligned date
    DateTime alignedDate = planStartDate.add(Duration(days: cyclesPassed * cycleDays));

    // If alignedDate is before fromDate, move to next cycle
    if (alignedDate.isBefore(fromDate)) {
      alignedDate = alignedDate.add(Duration(days: cycleDays));
    }

    return alignedDate;
  }
}
