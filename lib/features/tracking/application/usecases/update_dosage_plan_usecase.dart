import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';
import 'package:n06/features/tracking/domain/repositories/medication_repository.dart';
import 'package:n06/features/tracking/domain/usecases/analyze_plan_change_impact_usecase.dart';
import 'package:n06/features/tracking/domain/usecases/recalculate_dose_schedule_usecase.dart';
import 'package:n06/features/tracking/domain/usecases/validate_dosage_plan_usecase.dart';

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
/// 1. Validate the new plan
/// 2. Analyze impact of changes
/// 3. Save plan and change history
/// 4. Recalculate schedules
/// 5. Delete future schedules and save new ones
class UpdateDosagePlanUseCase {
  final MedicationRepository medicationRepository;
  final ValidateDosagePlanUseCase validateUseCase;
  final AnalyzePlanChangeImpactUseCase analyzeImpactUseCase;
  final RecalculateDoseScheduleUseCase recalculateScheduleUseCase;

  UpdateDosagePlanUseCase({
    required this.medicationRepository,
    required this.validateUseCase,
    required this.analyzeImpactUseCase,
    required this.recalculateScheduleUseCase,
  });

  /// Execute the complete update workflow
  Future<UpdateDosagePlanResult> execute({
    required DosagePlan oldPlan,
    required DosagePlan newPlan,
  }) async {
    try {
      // Step 1: Validate new plan
      final validation = validateUseCase.validate(newPlan);
      if (!validation.isValid) {
        return UpdateDosagePlanResult.failure(
          validation.errorMessage ?? '투여 계획이 유효하지 않습니다',
        );
      }

      // Step 2: Analyze impact
      final impact = analyzeImpactUseCase.execute(
        oldPlan: oldPlan,
        newPlan: newPlan,
        fromDate: DateTime.now(),
      );

      // Step 3: Early exit if no changes
      if (!impact.hasChanges) {
        return UpdateDosagePlanResult.success(impact: impact);
      }

      // Step 4: Save plan and change history in transaction
      final oldPlanMap = _serializePlan(oldPlan);
      final newPlanMap = _serializePlan(newPlan);

      await medicationRepository.updateDosagePlan(newPlan);
      await medicationRepository.savePlanChangeHistory(
        oldPlan.id,
        oldPlanMap,
        newPlanMap,
      );

      // Step 5: Recalculate and update schedules
      await medicationRepository.deleteDoseSchedulesFrom(
        newPlan.id,
        DateTime.now(),
      );

      final newSchedules = recalculateScheduleUseCase.execute(
        newPlan,
        fromDate: DateTime.now(),
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
