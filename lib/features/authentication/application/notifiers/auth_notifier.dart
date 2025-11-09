import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:n06/features/authentication/domain/entities/user.dart';
import 'package:n06/features/authentication/domain/repositories/auth_repository.dart';
import 'package:n06/features/authentication/application/providers.dart';

part 'auth_notifier.g.dart';

/// Authentication state notifier
///
/// Manages authentication state including:
/// - Login/logout operations
/// - Current user state
/// - Token validation and refresh
/// - First login detection
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<User?> build() async {
    // Load current user on initialization
    final repository = ref.read(authRepositoryProvider);
    return await repository.getCurrentUser();
  }

  /// Login with Kakao OAuth
  ///
  /// [agreedToTerms] User agreed to terms of service
  /// [agreedToPrivacy] User agreed to privacy policy
  ///
  /// Throws [OAuthCancelledException] if user cancels
  /// Throws [MaxRetriesExceededException] if network fails after 3 retries
  Future<bool> loginWithKakao({
    required bool agreedToTerms,
    required bool agreedToPrivacy,
  }) async {
    if (kDebugMode) {
      developer.log(
        '🔐 loginWithKakao called (terms: $agreedToTerms, privacy: $agreedToPrivacy)',
        name: 'AuthNotifier',
      );
    }

    state = const AsyncValue.loading();

    if (kDebugMode) {
      developer.log('⏳ State set to loading', name: 'AuthNotifier');
    }

    state = await AsyncValue.guard(() async {
      if (kDebugMode) {
        developer.log('📞 Calling repository.loginWithKakao()...', name: 'AuthNotifier');
      }

      final repository = ref.read(authRepositoryProvider);
      final user = await repository.loginWithKakao(
        agreedToTerms: agreedToTerms,
        agreedToPrivacy: agreedToPrivacy,
      );

      if (kDebugMode) {
        developer.log(
          '✅ Repository returned user: ${user.id}',
          name: 'AuthNotifier',
        );
      }

      return user;
    });

    // Check if login succeeded
    if (state.hasError) {
      if (kDebugMode) {
        state.whenOrNull(
          error: (error, stack) {
            developer.log(
              '❌ Login failed with error',
              name: 'AuthNotifier',
              error: error,
              stackTrace: stack,
              level: 1000,
            );
          },
        );
      }
      return false;
    }

    // Return isFirstLogin status
    if (state.hasValue) {
      final user = state.value;

      // CRITICAL: User must not be null
      if (user == null) {
        if (kDebugMode) {
          developer.log(
            '❌ CRITICAL: Login succeeded but user is null!',
            name: 'AuthNotifier',
            level: 1000,
          );
        }
        state = AsyncValue.error(
          Exception('Login failed: User is null'),
          StackTrace.current,
        );
        return false;
      }

      if (kDebugMode) {
        developer.log(
          '✅ User authenticated: ${user.id}',
          name: 'AuthNotifier',
        );
        developer.log('🔍 Checking if first login...', name: 'AuthNotifier');
      }

      final repository = ref.read(authRepositoryProvider);
      final isFirstLogin = await repository.isFirstLogin();

      if (kDebugMode) {
        developer.log(
          '✅ Is first login: $isFirstLogin',
          name: 'AuthNotifier',
        );
      }

      return isFirstLogin;
    }

    if (kDebugMode) {
      developer.log(
        '⚠️ State has no value and no error',
        name: 'AuthNotifier',
        level: 900,
      );
    }

    return false;
  }

  /// Login with Naver OAuth
  ///
  /// [agreedToTerms] User agreed to terms of service
  /// [agreedToPrivacy] User agreed to privacy policy
  ///
  /// Throws exceptions on failure
  Future<bool> loginWithNaver({
    required bool agreedToTerms,
    required bool agreedToPrivacy,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.loginWithNaver(
        agreedToTerms: agreedToTerms,
        agreedToPrivacy: agreedToPrivacy,
      );
      return user;
    });

    // Return isFirstLogin status
    if (state.hasValue) {
      final repository = ref.read(authRepositoryProvider);
      return await repository.isFirstLogin();
    }
    return false;
  }

  /// Logout current user
  ///
  /// Always succeeds even if network request fails (local cleanup guaranteed)
  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(logoutUseCaseProvider);
      await useCase.execute();
      return null;
    });
  }

  /// Ensure access token is valid, refresh if needed
  ///
  /// Returns true if token is valid or successfully refreshed
  /// Returns false if refresh fails (user needs to re-login)
  Future<bool> ensureValidToken() async {
    final repository = ref.read(authRepositoryProvider);
    final isValid = await repository.isAccessTokenValid();

    if (!isValid) {
      // Token expired, need to re-login
      // In Phase 0, we don't have token refresh
      // User will need to re-login
      await logout();
      return false;
    }

    return true;
  }
}

/// Provider for AuthRepository
///
/// Phase 0: Returns IsarAuthRepository
/// Phase 1: Will return SupabaseMedicationRepository
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  // This will be injected properly through providers in main.dart
  throw UnimplementedError(
    'authRepositoryProvider must be overridden in ProviderScope',
  );
}
