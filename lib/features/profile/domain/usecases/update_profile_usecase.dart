import 'package:n06/core/errors/domain_exception.dart';
import 'package:n06/features/onboarding/domain/entities/user_profile.dart';
import 'package:n06/features/profile/domain/repositories/profile_repository.dart';
import 'package:n06/features/tracking/domain/repositories/tracking_repository.dart';

/// UseCase for updating user profile
///
/// Validates profile data and persists changes through repository
class UpdateProfileUseCase {
  final ProfileRepository profileRepository;
  final TrackingRepository trackingRepository;

  const UpdateProfileUseCase({
    required this.profileRepository,
    required this.trackingRepository,
  });

  /// Execute profile update with validation
  ///
  /// Throws [DomainException] if:
  /// - Target weight is not less than current weight
  Future<void> execute(UserProfile profile) async {
    // Validate that target weight is less than current weight
    if (profile.targetWeight.value >= profile.currentWeight.value) {
      throw DomainException(
        message: '목표 체중은 현재 체중보다 작아야 합니다.',
        code: 'INVALID_TARGET_WEIGHT',
      );
    }

    // Save profile through repository
    await profileRepository.saveUserProfile(profile);
  }
}
