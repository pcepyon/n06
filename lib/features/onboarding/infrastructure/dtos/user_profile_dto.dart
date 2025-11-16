import 'package:n06/features/onboarding/domain/entities/user_profile.dart';
import 'package:n06/features/onboarding/domain/value_objects/weight.dart';

/// Supabase DTO for UserProfile entity.
///
/// Stores user profile information in Supabase database.
///
/// SSoT (Single Source of Truth) 원칙 준수:
/// - userName은 users 테이블에만 저장 (조회 시 JOIN)
/// - currentWeight는 weight_logs 테이블에만 저장 (조회 시 최신 레코드 조회)
class UserProfileDto {
  final String userId;
  final double targetWeightKg;
  final int? targetPeriodWeeks;
  final double? weeklyLossGoalKg;
  final int weeklyWeightRecordGoal;
  final int weeklySymptomRecordGoal;

  const UserProfileDto({
    required this.userId,
    required this.targetWeightKg,
    this.targetPeriodWeeks,
    this.weeklyLossGoalKg,
    required this.weeklyWeightRecordGoal,
    required this.weeklySymptomRecordGoal,
  });

  /// Creates DTO from Supabase JSON (user_profiles 테이블 조회 결과).
  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    return UserProfileDto(
      userId: json['user_id'] as String,
      targetWeightKg: (json['target_weight_kg'] as num).toDouble(),
      targetPeriodWeeks: json['target_period_weeks'] as int?,
      weeklyLossGoalKg: json['weekly_loss_goal_kg'] != null
          ? (json['weekly_loss_goal_kg'] as num).toDouble()
          : null,
      weeklyWeightRecordGoal: json['weekly_weight_record_goal'] as int,
      weeklySymptomRecordGoal: json['weekly_symptom_record_goal'] as int,
    );
  }

  /// Converts DTO to Supabase JSON (user_profiles 테이블 INSERT/UPDATE용).
  ///
  /// SSoT 원칙: user_name과 current_weight_kg는 제외
  /// - user_name: users 테이블에서 관리
  /// - current_weight_kg: weight_logs 테이블에서 관리
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'target_weight_kg': targetWeightKg,
      'target_period_weeks': targetPeriodWeeks,
      'weekly_loss_goal_kg': weeklyLossGoalKg,
      'weekly_weight_record_goal': weeklyWeightRecordGoal,
      'weekly_symptom_record_goal': weeklySymptomRecordGoal,
    };
  }

  /// DTO를 Domain Entity로 변환한다.
  ///
  /// [userName]과 [currentWeightKg]는 외부에서 조회한 데이터를 매개변수로 받는다:
  /// - userName: users 테이블에서 조회
  /// - currentWeightKg: weight_logs 테이블에서 최신 레코드 조회 (없으면 0.0)
  UserProfile toEntity({
    required String userName,
    required double currentWeightKg,
  }) {
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

  /// Domain Entity를 DTO로 변환한다 (user_profiles 테이블 저장용).
  ///
  /// SSoT 원칙: userName, currentWeight는 제외
  /// - userName: users 테이블에서 별도 관리
  /// - currentWeight: weight_logs 테이블에서 별도 관리
  static UserProfileDto fromEntity(UserProfile entity) {
    return UserProfileDto(
      userId: entity.userId,
      targetWeightKg: entity.targetWeight.value,
      targetPeriodWeeks: entity.targetPeriodWeeks,
      weeklyLossGoalKg: entity.weeklyLossGoalKg,
      weeklyWeightRecordGoal: entity.weeklyWeightRecordGoal,
      weeklySymptomRecordGoal: entity.weeklySymptomRecordGoal,
    );
  }
}
