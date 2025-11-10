import 'package:isar/isar.dart';
import 'package:n06/features/onboarding/domain/entities/user_profile.dart';
import 'package:n06/features/onboarding/domain/value_objects/weight.dart';

part 'user_profile_dto.g.dart';

@collection
class UserProfileDto {
  Id isarId = Isar.autoIncrement;

  late String userId;
  late String? userName;
  late double targetWeightKg;
  late double currentWeightKg;
  late int? targetPeriodWeeks;
  late double? weeklyLossGoalKg;
  late int weeklyWeightRecordGoal;
  late int weeklySymptomRecordGoal;

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
    return UserProfileDto()
      ..userId = entity.userId
      ..userName = entity.userName
      ..targetWeightKg = entity.targetWeight.value
      ..currentWeightKg = entity.currentWeight.value
      ..targetPeriodWeeks = entity.targetPeriodWeeks
      ..weeklyLossGoalKg = entity.weeklyLossGoalKg
      ..weeklyWeightRecordGoal = entity.weeklyWeightRecordGoal
      ..weeklySymptomRecordGoal = entity.weeklySymptomRecordGoal;
  }
}
