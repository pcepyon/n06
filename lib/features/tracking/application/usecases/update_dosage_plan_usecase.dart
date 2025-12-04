import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';
import 'package:n06/features/tracking/domain/entities/update_plan_error_type.dart';
import 'package:n06/features/tracking/domain/repositories/medication_repository.dart';
import 'package:n06/features/tracking/domain/usecases/analyze_plan_change_impact_usecase.dart';
import 'package:n06/features/tracking/domain/usecases/recalculate_dose_schedule_usecase.dart';

/// Result of updating a dosage plan
class UpdateDosagePlanResult {
  final bool isSuccess;
  final UpdatePlanErrorType? errorType;
  final String? errorDetails; // Technical error details (for logging)
  final PlanChangeImpact? impact;

  const UpdateDosagePlanResult({
    required this.isSuccess,
    this.errorType,
    this.errorDetails,
    this.impact,
  });

  factory UpdateDosagePlanResult.success({required PlanChangeImpact impact}) {
    return UpdateDosagePlanResult(isSuccess: true, impact: impact);
  }

  factory UpdateDosagePlanResult.failure({
    required UpdatePlanErrorType errorType,
    String? errorDetails,
  }) {
    return UpdateDosagePlanResult(
      isSuccess: false,
      errorType: errorType,
      errorDetails: errorDetails,
    );
  }
}

/// Orchestrates the dosage plan update workflow:
/// 1. Analyze impact of changes
/// 2. Save plan and change history
/// 3. Recalculate schedules
/// 4. Delete future schedules and save new ones
///
/// Note: Validation is handled by DosagePlan entity constructor and UI constraints
class UpdateDosagePlanUseCase {
  final MedicationRepository medicationRepository;
  final AnalyzePlanChangeImpactUseCase analyzeImpactUseCase;
  final RecalculateDoseScheduleUseCase recalculateScheduleUseCase;

  UpdateDosagePlanUseCase({
    required this.medicationRepository,
    required this.analyzeImpactUseCase,
    required this.recalculateScheduleUseCase,
  });

  /// Execute the complete update workflow
  ///
  /// [isRestart] - If true, regenerates schedules from new start date (restart mode).
  ///               If false, preserves past records and regenerates from current date (normal mode).
  Future<UpdateDosagePlanResult> execute({
    required DosagePlan oldPlan,
    required DosagePlan newPlan,
    bool isRestart = false,
  }) async {
    try {
      // Step 1: Analyze impact
      final impact = analyzeImpactUseCase.execute(
        oldPlan: oldPlan,
        newPlan: newPlan,
        fromDate: DateTime.now(),
      );

      // Step 2: Early exit if no changes
      if (!impact.hasChanges) {
        return UpdateDosagePlanResult.success(impact: impact);
      }

      // Step 3: Save plan and change history in transaction
      final oldPlanMap = _serializePlan(oldPlan);
      final newPlanMap = _serializePlan(newPlan);

      await medicationRepository.updateDosagePlan(newPlan);
      await medicationRepository.savePlanChangeHistory(
        oldPlan.id,
        oldPlanMap,
        newPlanMap,
      );

      // Step 4: Determine schedule generation start date
      // Restart mode: Generate from new start date (delete past pending schedules)
      // Normal mode: Preserve past records, generate from max(now, new start date)
      final now = DateTime.now();
      final normalizedNow = DateTime(now.year, now.month, now.day);
      final normalizedNewStart = DateTime(
        newPlan.startDate.year,
        newPlan.startDate.month,
        newPlan.startDate.day,
      );

      final scheduleStartDate = isRestart
          ? normalizedNewStart  // Restart: from new start date
          : DateTime.fromMillisecondsSinceEpoch(
              normalizedNow.millisecondsSinceEpoch > normalizedNewStart.millisecondsSinceEpoch
                  ? normalizedNow.millisecondsSinceEpoch
                  : normalizedNewStart.millisecondsSinceEpoch,
            );  // Normal: from max(now, new start date)

      // Delete schedules
      // Restart mode: delete all past schedules (from far past date)
      // Normal mode: delete from schedule start date only
      final deleteFromDate = isRestart
          ? DateTime(2020, 1, 1)  // Delete all schedules from the beginning
          : scheduleStartDate;

      await medicationRepository.deleteDoseSchedulesFrom(
        newPlan.id,
        deleteFromDate,
      );

      // Recalculate and save new schedules
      final newSchedules = recalculateScheduleUseCase.execute(
        newPlan,
        fromDate: scheduleStartDate,
      );

      await medicationRepository.saveDoseSchedules(newSchedules);

      return UpdateDosagePlanResult.success(impact: impact);
    } catch (e) {
      return UpdateDosagePlanResult.failure(
        errorType: UpdatePlanErrorType.updateFailed,
        errorDetails: e.toString(),
      );
    }
  }

  /// Serialize plan to map for history tracking
  Map<String, dynamic> _serializePlan(DosagePlan plan) {
    return {
      'medicationName': plan.medicationName,
      'startDate': plan.startDate.toIso8601String(),
      'cycleDays': plan.cycleDays,
      'initialDoseMg': plan.initialDoseMg,
      'escalationPlan': plan.escalationPlan?.map((step) => {
            'weeksFromStart': step.weeksFromStart,
            'doseMg': step.doseMg,
          }).toList(),
    };
  }
}
