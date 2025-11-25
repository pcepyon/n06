import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:n06/features/onboarding/domain/entities/user_profile.dart';
import 'package:n06/features/onboarding/domain/repositories/profile_repository.dart';
import 'package:n06/features/onboarding/application/providers.dart' as onboarding_providers;
import 'package:n06/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/dashboard/application/notifiers/dashboard_notifier.dart';
import 'package:n06/features/tracking/application/providers.dart';

part 'profile_notifier.g.dart';

/// Profile state notifier
///
/// Manages user profile state including:
/// - Loading user profile
/// - Updating user profile
/// - Profile data caching
@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  Future<UserProfile?> build() async {
    // Load current user profile on initialization
    final authState = ref.watch(authNotifierProvider);

    if (!authState.hasValue || authState.value == null) {
      return null;
    }

    try {
      final repository = ref.read(onboarding_providers.profileRepositoryProvider);
      return await repository.getUserProfile(authState.value!.id);
    } catch (e) {
      // Re-throw as AsyncValue will handle error state
      rethrow;
    }
  }

  /// Load profile for a specific user
  Future<void> loadProfile(String userId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(onboarding_providers.profileRepositoryProvider);
      return await repository.getUserProfile(userId);
    });
  }

  /// Update user profile using UpdateProfileUseCase
  ///
  /// Also invalidates dashboard notifier to refresh dashboard data
  Future<void> updateProfile(UserProfile profile) async {
    // ✅ 작업 완료 보장을 위한 keepAlive
    final link = ref.keepAlive();

    state = const AsyncValue.loading();

    try {
      state = await AsyncValue.guard(() async {
        final repository = ref.read(onboarding_providers.profileRepositoryProvider);
        final trackingRepository = ref.read(trackingRepositoryProvider);
        final useCase = UpdateProfileUseCase(
          profileRepository: repository,
          trackingRepository: trackingRepository,
        );

        await useCase.execute(profile);

        // ✅ async gap 후 mounted 체크
        if (!ref.mounted) {
          return profile;
        }

        // Invalidate dashboard to refresh dashboard data
        ref.invalidate(dashboardNotifierProvider);

        return profile;
      });
    } finally {
      link.close();
    }
  }

  /// Update weekly recording goals
  ///
  /// Updates the target number of weight logs and symptom logs per week.
  /// Goals must be in range 0-7.
  ///
  /// Invalidates dashboard notifier to refresh weekly progress data.
  ///
  /// Throws [Exception] if user profile not found
  Future<void> updateWeeklyGoals(
    int weeklyWeightRecordGoal,
    int weeklySymptomRecordGoal,
  ) async {
    // ✅ 작업 완료 보장을 위한 keepAlive
    final link = ref.keepAlive();

    final currentState = state;

    // Get current profile to extract userId
    if (!currentState.hasValue || currentState.value == null) {
      link.close();
      throw Exception('User profile not loaded');
    }

    final userId = currentState.value!.userId;

    state = const AsyncValue.loading();

    try {
      state = await AsyncValue.guard(() async {
        final repository = ref.read(onboarding_providers.profileRepositoryProvider);

        // Update weekly goals in repository
        await repository.updateWeeklyGoals(
          userId,
          weeklyWeightRecordGoal,
          weeklySymptomRecordGoal,
        );

        // ✅ async gap 후 mounted 체크
        if (!ref.mounted) {
          return currentState.value;
        }

        // Fetch updated profile
        final updatedProfile = await repository.getUserProfile(userId);

        // Invalidate dashboard to refresh weekly progress
        ref.invalidate(dashboardNotifierProvider);

        return updatedProfile;
      });
    } finally {
      link.close();
    }
  }
}

/// Provider for ProfileRepository
///
/// Phase 0: Returns IsarProfileRepository
/// Phase 1: Will return SupabaseProfileRepository
@riverpod
ProfileRepository profileRepository(Ref ref) {
  throw UnimplementedError(
    'profileRepositoryProvider must be overridden in ProviderScope',
  );
}


// Backwards compatibility alias
const profileNotifierProvider = profileProvider;
