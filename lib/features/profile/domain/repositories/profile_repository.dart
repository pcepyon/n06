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

  /// Update weekly goals for recording targets
  ///
  /// Updates the weekly weight record goal and weekly symptom record goal
  /// for the user profile. Goals must be in range 0-7.
  ///
  /// Parameters:
  ///   - userId: Target user ID
  ///   - weeklyWeightRecordGoal: Target number of weight logs per week (0-7)
  ///   - weeklySymptomRecordGoal: Target number of symptom logs per week (0-7)
  ///
  /// Throws [Exception] if user profile not found
  Future<void> updateWeeklyGoals(
    String userId,
    int weeklyWeightRecordGoal,
    int weeklySymptomRecordGoal,
  );
}
