import 'package:n06/features/onboarding/domain/entities/user_profile.dart';

/// 사용자 프로필 접근 계약을 정의하는 Repository Interface
abstract class ProfileRepository {
  /// 사용자 프로필을 저장한다.
  Future<void> saveUserProfile(UserProfile profile);

  /// 사용자 프로필을 조회한다.
  Future<UserProfile?> getUserProfile(String userId);

  /// 사용자 프로필을 업데이트한다.
  Future<void> updateUserProfile(UserProfile profile);
}
