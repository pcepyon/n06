import 'package:n06/features/onboarding/domain/entities/user_profile.dart';
import 'package:n06/features/onboarding/domain/value_objects/weight.dart';

/// Supabase DTO for UserProfile entity.
///
/// Stores user profile information in Supabase database.
class UserProfileDto {
  final String userId;
  final String? userName;
  final double targetWeightKg;
  final double currentWeightKg;
  final int? targetPeriodWeeks;
  final double? weeklyLossGoalKg;
  final int weeklyWeightRecordGoal;
  final int weeklySymptomRecordGoal;

  const UserProfileDto({
    required this.userId,
    this.userName,
    required this.targetWeightKg,
    required this.currentWeightKg,
    this.targetPeriodWeeks,
    this.weeklyLossGoalKg,
    required this.weeklyWeightRecordGoal,
    required this.weeklySymptomRecordGoal,
  });

  /// Creates DTO from Supabase JSON.
  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    return UserProfileDto(
      userId: json['user_id'] as String,
      userName: json['user_name'] as String?,
      targetWeightKg: (json['target_weight_kg'] as num).toDouble(),
      currentWeightKg: (json['current_weight_kg'] as num).toDouble(),
      targetPeriodWeeks: json['target_period_weeks'] as int?,
      weeklyLossGoalKg: json['weekly_loss_goal_kg'] != null
          ? (json['weekly_loss_goal_kg'] as num).toDouble()
          : null,
      weeklyWeightRecordGoal: json['weekly_weight_record_goal'] as int,
      weeklySymptomRecordGoal: json['weekly_symptom_record_goal'] as int,
    );
  }

  /// Converts DTO to Supabase JSON.
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'target_weight_kg': targetWeightKg,
      'current_weight_kg': currentWeightKg,
      'target_period_weeks': targetPeriodWeeks,
      'weekly_loss_goal_kg': weeklyLossGoalKg,
      'weekly_weight_record_goal': weeklyWeightRecordGoal,
      'weekly_symptom_record_goal': weeklySymptomRecordGoal,
    };
  }

  /// DTO를 Domain Entity로 변환한다.
  UserProfile toEntity() {
    return UserProfile(
      userId: userId,
      userName: userName,
      targetWeight: Weight.create(targetWeightKg),
      currentWeight: Weight.create(currentWeightKg),
      targetPeriodWeeks: targetPeriodWeeks,
      weeklyLossGoalKg: weeklyLossGoalKg,
      weeklyWeightRecordGoal: weeklyWeightRecordGoal,
      weeklySymptomRecordGoal: weeklySymptomRecordGoal,
    );
  }

  /// Domain Entity를 DTO로 변환한다.
  static UserProfileDto fromEntity(UserProfile entity) {
    return UserProfileDto(
      userId: entity.userId,
      userName: entity.userName,
      targetWeightKg: entity.targetWeight.value,
      currentWeightKg: entity.currentWeight.value,
      targetPeriodWeeks: entity.targetPeriodWeeks,
      weeklyLossGoalKg: entity.weeklyLossGoalKg,
      weeklyWeightRecordGoal: entity.weeklyWeightRecordGoal,
      weeklySymptomRecordGoal: entity.weeklySymptomRecordGoal,
    );
  }
}
