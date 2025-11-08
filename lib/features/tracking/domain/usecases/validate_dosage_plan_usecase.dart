import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';

class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
  });

  factory ValidationResult.success() {
    return const ValidationResult(isValid: true);
  }

  factory ValidationResult.failure(String message) {
    return ValidationResult(isValid: false, errorMessage: message);
  }
}

class ValidateDosagePlanUseCase {
  ValidationResult validate(DosagePlan plan) {
    // Validate medication name
    if (plan.medicationName.trim().isEmpty) {
      return ValidationResult.failure('약물명을 입력하세요');
    }

    // Validate cycle days
    if (plan.cycleDays < 1) {
      return ValidationResult.failure('투여 주기는 1일 이상이어야 합니다');
    }

    // Validate initial dose
    if (plan.initialDoseMg <= 0) {
      return ValidationResult.failure('초기 용량은 0보다 커야 합니다');
    }

    // Validate escalation plan
    if (plan.escalationPlan != null && plan.escalationPlan!.isNotEmpty) {
      final escalationValidation = validateEscalationPlan(
        plan.initialDoseMg,
        plan.escalationPlan!,
      );
      if (!escalationValidation.isValid) {
        return escalationValidation;
      }
    }

    return ValidationResult.success();
  }

  /// Validate medication name
  ValidationResult validateMedicationName(String name) {
    if (name.trim().isEmpty) {
      return ValidationResult.failure('약물명을 입력하세요');
    }
    return ValidationResult.success();
  }

  /// Validate cycle days
  ValidationResult validateCycleDays(int cycleDays) {
    if (cycleDays < 1) {
      return ValidationResult.failure('투여 주기는 1일 이상이어야 합니다');
    }
    return ValidationResult.success();
  }

  /// Validate initial dose
  ValidationResult validateInitialDose(double dose) {
    if (dose <= 0) {
      return ValidationResult.failure('초기 용량은 0보다 커야 합니다');
    }
    return ValidationResult.success();
  }

  /// Validate escalation plan
  ValidationResult validateEscalationPlan(
    double initialDose,
    List<EscalationStep> escalationPlan,
  ) {
    double previousDose = initialDose;
    int previousWeeks = 0;

    for (final step in escalationPlan) {
      // Check dose is strictly increasing
      if (step.doseMg <= previousDose) {
        return ValidationResult.failure(
          '증량 계획의 용량은 증가해야 합니다 (현재: ${step.doseMg}mg, 이전: ${previousDose}mg)',
        );
      }

      // Check weeks are in increasing order
      if (step.weeksFromStart <= previousWeeks) {
        return ValidationResult.failure(
          '증량 계획은 시간 순서대로 입력해주세요',
        );
      }

      previousDose = step.doseMg;
      previousWeeks = step.weeksFromStart;
    }

    return ValidationResult.success();
  }
}
