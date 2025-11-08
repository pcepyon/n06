import 'package:isar/isar.dart';
import 'package:n06/features/onboarding/domain/entities/user_profile.dart';
import 'package:n06/features/onboarding/domain/value_objects/weight.dart';

part 'user_profile_dto.g.dart';

/// User profile DTO for Isar storage
@collection
class UserProfileDto {
  Id? isarId;
  late String userId;
  late double targetWeightValue;
  late double currentWeightValue;
  int? targetPeriodWeeks;
  double? weeklyLossGoalKg;
  late int weeklyWeightRecordGoal;
  late int weeklySymptomRecordGoal;

  UserProfileDto();

  /// Convert DTO to Entity
  UserProfile toEntity() {
    return UserProfile(
      userId: userId,
      targetWeight: Weight.create(targetWeightValue),
      currentWeight: Weight.create(currentWeightValue),
      targetPeriodWeeks: targetPeriodWeeks,
      weeklyLossGoalKg: weeklyLossGoalKg,
      weeklyWeightRecordGoal: weeklyWeightRecordGoal,
      weeklySymptomRecordGoal: weeklySymptomRecordGoal,
    );
  }

  /// Create DTO from Entity
  factory UserProfileDto.fromEntity(UserProfile entity) {
    return UserProfileDto()
      ..userId = entity.userId
      ..targetWeightValue = entity.targetWeight.value
      ..currentWeightValue = entity.currentWeight.value
      ..targetPeriodWeeks = entity.targetPeriodWeeks
      ..weeklyLossGoalKg = entity.weeklyLossGoalKg
      ..weeklyWeightRecordGoal = entity.weeklyWeightRecordGoal
      ..weeklySymptomRecordGoal = entity.weeklySymptomRecordGoal;
  }
}
