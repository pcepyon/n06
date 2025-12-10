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
  // ✅ 의존성을 late final 필드로 선언
  late final _repository = ref.read(onboarding_providers.profileRepositoryProvider);
  late final _trackingRepository = ref.read(trackingRepositoryProvider);

  @override
  Future<UserProfile?> build() async {
    // Load current user profile on initialization
    // BUG-20251210: ref.watch(provider.future)를 사용하여 비동기 완료를 기다림
    final user = await ref.watch(authNotifierProvider.future);

    if (user == null) {
      return null;
    }

    try {
      return await _repository.getUserProfile(user.id);
    } catch (e) {
      // Re-throw as AsyncValue will handle error state
      rethrow;
    }
  }

  /// Load profile for a specific user
  Future<void> loadProfile(String userId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _repository.getUserProfile(userId);
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
        final useCase = UpdateProfileUseCase(
          profileRepository: _repository,
          trackingRepository: _trackingRepository,
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
        // Update weekly goals in repository
        await _repository.updateWeeklyGoals(
          userId,
          weeklyWeightRecordGoal,
          weeklySymptomRecordGoal,
        );

        // ✅ async gap 후 mounted 체크
        if (!ref.mounted) {
          return currentState.value;
        }

        // Fetch updated profile
        final updatedProfile = await _repository.getUserProfile(userId);

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
/// Returns ProfileRepository implementation
/// Current: SupabaseProfileRepository (cloud-first architecture)
@riverpod
ProfileRepository profileRepository(Ref ref) {
  throw UnimplementedError(
    'profileRepositoryProvider must be overridden in ProviderScope',
  );
}


// Backwards compatibility alias
const profileNotifierProvider = profileProvider;
