import 'package:n06/features/onboarding/domain/value_objects/weight.dart';

/// 사용자 프로필 및 목표를 나타내는 Entity
class UserProfile {
  final String userId;
  final String? userName;
  final Weight targetWeight;
  final Weight currentWeight;
  final int? targetPeriodWeeks;
  final double? weeklyLossGoalKg;
  final int weeklyWeightRecordGoal;
  final int weeklySymptomRecordGoal;

  /// UserProfile을 생성한다.
  /// weeklyWeightRecordGoal과 weeklySymptomRecordGoal의 기본값은 7이다.
  UserProfile({
    required this.userId,
    this.userName,
    required this.targetWeight,
    required this.currentWeight,
    this.targetPeriodWeeks,
    this.weeklyLossGoalKg,
    this.weeklyWeightRecordGoal = 7,
    this.weeklySymptomRecordGoal = 7,
  });

  /// 주간 감량 목표를 계산한다.
  /// targetPeriodWeeks가 null이면 null을 반환한다.
  static double? calculateWeeklyGoal(
    Weight currentWeight,
    Weight targetWeight,
    int? periodWeeks,
  ) {
    if (periodWeeks == null || periodWeeks <= 0) {
      return null;
    }

    final totalWeightLoss = currentWeight.value - targetWeight.value;
    if (totalWeightLoss <= 0) {
      return null;
    }

    return double.parse(
      (totalWeightLoss / periodWeeks).toStringAsFixed(2),
    );
  }

  /// 현재 UserProfile의 일부 필드를 변경한 새로운 UserProfile을 반환한다.
  UserProfile copyWith({
    String? userId,
    String? userName,
    Weight? targetWeight,
    Weight? currentWeight,
    int? targetPeriodWeeks,
    double? weeklyLossGoalKg,
    int? weeklyWeightRecordGoal,
    int? weeklySymptomRecordGoal,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      targetWeight: targetWeight ?? this.targetWeight,
      currentWeight: currentWeight ?? this.currentWeight,
      targetPeriodWeeks: targetPeriodWeeks ?? this.targetPeriodWeeks,
      weeklyLossGoalKg: weeklyLossGoalKg ?? this.weeklyLossGoalKg,
      weeklyWeightRecordGoal:
          weeklyWeightRecordGoal ?? this.weeklyWeightRecordGoal,
      weeklySymptomRecordGoal:
          weeklySymptomRecordGoal ?? this.weeklySymptomRecordGoal,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserProfile &&
        other.userId == userId &&
        other.userName == userName &&
        other.targetWeight == targetWeight &&
        other.currentWeight == currentWeight &&
        other.targetPeriodWeeks == targetPeriodWeeks &&
        other.weeklyLossGoalKg == weeklyLossGoalKg &&
        other.weeklyWeightRecordGoal == weeklyWeightRecordGoal &&
        other.weeklySymptomRecordGoal == weeklySymptomRecordGoal;
  }

  @override
  int get hashCode =>
      userId.hashCode ^
      userName.hashCode ^
      targetWeight.hashCode ^
      currentWeight.hashCode ^
      targetPeriodWeeks.hashCode ^
      weeklyLossGoalKg.hashCode ^
      weeklyWeightRecordGoal.hashCode ^
      weeklySymptomRecordGoal.hashCode;

  @override
  String toString() =>
      'UserProfile(userId: $userId, targetWeight: ${targetWeight.value}kg, currentWeight: ${currentWeight.value}kg)';
}
