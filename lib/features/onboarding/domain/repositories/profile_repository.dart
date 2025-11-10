import 'package:n06/features/onboarding/domain/entities/user_profile.dart';

/// 사용자 프로필 접근 계약을 정의하는 Repository Interface
abstract class ProfileRepository {
  /// 사용자 프로필을 저장한다.
  Future<void> saveUserProfile(UserProfile profile);

  /// 사용자 프로필을 조회한다.
  Future<UserProfile?> getUserProfile(String userId);

  /// 사용자 프로필을 업데이트한다.
  Future<void> updateUserProfile(UserProfile profile);

  /// 사용자 프로필 변경사항을 실시간으로 구독한다.
  Stream<UserProfile> watchUserProfile(String userId);

  /// 주간 목표를 업데이트한다.
  ///
  /// 사용자 프로필의 주간 체중 기록 목표와 주간 부작용 기록 목표를 업데이트한다.
  /// 목표 값은 0-7 범위여야 한다.
  ///
  /// Parameters:
  ///   - userId: 대상 사용자 ID
  ///   - weeklyWeightRecordGoal: 주간 체중 기록 목표 (0-7)
  ///   - weeklySymptomRecordGoal: 주간 부작용 기록 목표 (0-7)
  ///
  /// Throws [Exception] if user profile not found
  Future<void> updateWeeklyGoals(
    String userId,
    int weeklyWeightRecordGoal,
    int weeklySymptomRecordGoal,
  );
}
