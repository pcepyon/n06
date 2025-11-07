import 'package:n06/features/onboarding/domain/entities/escalation_step.dart';

/// 투여 계획의 증량 단계를 검증하는 UseCase
class ValidateDosagePlanUseCase {
  /// 증량 계획이 유효한지 검증한다.
  ///
  /// 반환값: {'isValid': bool, 'errors': List<String>}
  /// - isValid: 증량 계획이 유효한 경우 true
  /// - errors: 유효하지 않은 경우 에러 메시지 리스트
  Map<String, dynamic> execute(List<EscalationStep>? escalationPlan) {
    if (escalationPlan == null || escalationPlan.isEmpty) {
      return {
        'isValid': true,
        'errors': <String>[],
      };
    }

    final errors = <String>[];

    // 용량이 증가하지 않는 경우 검사
    for (int i = 1; i < escalationPlan.length; i++) {
      if (escalationPlan[i].doseMg <= escalationPlan[i - 1].doseMg) {
        errors.add('증량 계획의 용량은 점진적으로 증가해야 합니다.');
        break;
      }
    }

    // 시기가 역순인 경우 검사
    for (int i = 1; i < escalationPlan.length; i++) {
      if (escalationPlan[i].weeks <= escalationPlan[i - 1].weeks) {
        errors.add('증량 계획의 시기는 순차적이어야 합니다.');
        break;
      }
    }

    // 중복 시기 검사 (위 검사에서 이미 포함됨)

    return {
      'isValid': errors.isEmpty,
      'errors': errors,
    };
  }
}
