import 'package:n06/features/onboarding/domain/entities/user_profile.dart';
import 'package:n06/features/onboarding/domain/value_objects/weight.dart';

/// 주간 감량 목표를 계산하는 UseCase
class CalculateWeeklyGoalUseCase {
  /// 주간 감량 목표를 계산한다.
  ///
  /// 반환값: {'weeklyGoal': double?, 'hasWarning': bool}
  /// - weeklyGoal: 계산된 주간 감량 목표 (null이면 계산 불가)
  /// - hasWarning: 주간 목표가 1kg을 초과하는 경우 true
  Map<String, dynamic> execute({
    required Weight currentWeight,
    required Weight targetWeight,
    int? periodWeeks,
  }) {
    if (currentWeight.value <= targetWeight.value) {
      throw ArgumentError('현재 체중은 목표 체중보다 커야 합니다.');
    }

    final weeklyGoal = UserProfile.calculateWeeklyGoal(
      currentWeight,
      targetWeight,
      periodWeeks,
    );

    final hasWarning = weeklyGoal != null && weeklyGoal > 1.0;

    return {
      'weeklyGoal': weeklyGoal,
      'hasWarning': hasWarning,
    };
  }
}
