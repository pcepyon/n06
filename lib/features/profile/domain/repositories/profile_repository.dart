import 'package:n06/features/onboarding/domain/entities/user_profile.dart';

/// ProfileRepository interface for profile data access
abstract class ProfileRepository {
  /// Get user profile by user ID
  ///
  /// Throws [Exception] if user profile not found
  Future<UserProfile> getUserProfile(String userId);

  /// Save or update user profile
  Future<void> saveUserProfile(UserProfile profile);

  /// Watch user profile changes
  Stream<UserProfile> watchUserProfile(String userId);
}
