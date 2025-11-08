import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:n06/features/onboarding/domain/entities/user_profile.dart';
import 'package:n06/features/profile/domain/repositories/profile_repository.dart';
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
      final repository = ref.read(profileRepositoryProvider);
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
      final repository = ref.read(profileRepositoryProvider);
      return await repository.getUserProfile(userId);
    });
  }

  /// Update user profile using UpdateProfileUseCase
  ///
  /// Also invalidates dashboard notifier to refresh dashboard data
  Future<void> updateProfile(UserProfile profile) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(profileRepositoryProvider);
      final trackingRepository = ref.read(trackingRepositoryProvider);
      final useCase = UpdateProfileUseCase(
        profileRepository: repository,
        trackingRepository: trackingRepository,
      );

      await useCase.execute(profile);

      // Invalidate dashboard to refresh dashboard data
      ref.invalidate(dashboardNotifierProvider);

      return profile;
    });
  }
}

/// Provider for ProfileRepository
///
/// Phase 0: Returns IsarProfileRepository
/// Phase 1: Will return SupabaseProfileRepository
@riverpod
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  throw UnimplementedError(
    'profileRepositoryProvider must be overridden in ProviderScope',
  );
}
