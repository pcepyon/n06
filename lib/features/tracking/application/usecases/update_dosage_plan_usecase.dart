import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';
import 'package:n06/features/tracking/domain/repositories/medication_repository.dart';
import 'package:n06/features/tracking/domain/usecases/analyze_plan_change_impact_usecase.dart';
import 'package:n06/features/tracking/domain/usecases/recalculate_dose_schedule_usecase.dart';

/// Result of updating a dosage plan
class UpdateDosagePlanResult {
  final bool isSuccess;
  final String? errorMessage;
  final PlanChangeImpact? impact;

  const UpdateDosagePlanResult({
    required this.isSuccess,
    this.errorMessage,
    this.impact,
  });

  factory UpdateDosagePlanResult.success({required PlanChangeImpact impact}) {
    return UpdateDosagePlanResult(isSuccess: true, impact: impact);
  }

  factory UpdateDosagePlanResult.failure(String message) {
    return UpdateDosagePlanResult(isSuccess: false, errorMessage: message);
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
  Future<UpdateDosagePlanResult> execute({
    required DosagePlan oldPlan,
    required DosagePlan newPlan,
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
      // If startDate changed, generate from new startDate (past or future)
      // Otherwise, generate from current date (preserve past records)
      final now = DateTime.now();
      final normalizedNow = DateTime(now.year, now.month, now.day);
      final normalizedOldStart = DateTime(
        oldPlan.startDate.year,
        oldPlan.startDate.month,
        oldPlan.startDate.day,
      );
      final normalizedNewStart = DateTime(
        newPlan.startDate.year,
        newPlan.startDate.month,
        newPlan.startDate.day,
      );

      final startDateChanged = normalizedOldStart != normalizedNewStart;
      final scheduleStartDate = startDateChanged ? normalizedNewStart : normalizedNow;

      // Delete schedules from schedule start date onwards
      await medicationRepository.deleteDoseSchedulesFrom(
        newPlan.id,
        scheduleStartDate,
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
        '투여 계획 업데이트 중 오류가 발생했습니다: $e',
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
