import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:n06/features/authentication/domain/entities/user.dart';
import 'package:n06/features/authentication/domain/repositories/auth_repository.dart';
import 'package:n06/features/authentication/application/providers.dart';
import 'package:n06/features/authentication/infrastructure/repositories/supabase_auth_repository.dart';
import 'package:n06/core/providers.dart';

part 'auth_notifier.g.dart';

/// Authentication state notifier
///
/// Manages authentication state including:
/// - Login/logout operations
/// - Current user state
/// - Token validation and refresh
/// - First login detection
@Riverpod(keepAlive: true)  // 인증 상태는 글로벌 상태이므로 keepAlive 필수
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<User?> build() async {
    if (kDebugMode) {
      developer.log('AuthNotifier.build() called', name: 'AuthNotifier');
    }
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

    // Use try-catch instead of AsyncValue.guard
    try {
      final repository = ref.read(authRepositoryProvider);

      if (kDebugMode) {
        developer.log('📞 Calling repository.loginWithKakao()...', name: 'AuthNotifier');
      }

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

      // CRITICAL FIX: Explicitly set state with AsyncValue.data
      state = AsyncValue.data(user);

      // Check if this is first login
      final isFirstLogin = await repository.isFirstLogin();

      if (kDebugMode) {
        developer.log(
          '✅ Is first login: $isFirstLogin',
          name: 'AuthNotifier',
        );
      }

      return isFirstLogin;

    } catch (error, stackTrace) {
      // Set error state
      state = AsyncValue.error(error, stackTrace);

      if (kDebugMode) {
        developer.log(
          '❌ Login failed with error',
          name: 'AuthNotifier',
          error: error,
          stackTrace: stackTrace,
          level: 1000,
        );
      }

      return false;
    }
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
      await logout();
      return false;
    }

    return true;
  }

  /// Sign up with email and password
  ///
  /// [email] User email address
  /// [password] User password (must meet strength requirements)
  /// [agreedToTerms] User agreed to terms of service
  /// [agreedToPrivacy] User agreed to privacy policy
  ///
  /// Returns User object on successful signup
  /// Throws exception on validation or network errors
  Future<User> signUpWithEmail({
    required String email,
    required String password,
    required bool agreedToTerms,
    required bool agreedToPrivacy,
  }) async {
    if (kDebugMode) {
      developer.log(
        'signUpWithEmail called (email: $email)',
        name: 'AuthNotifier',
      );
    }

    state = const AsyncValue.loading();

    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.signUpWithEmail(
        email: email,
        password: password,
      );

      // CRITICAL FIX: Explicitly set state with AsyncValue.data
      state = AsyncValue.data(user);

      if (kDebugMode) {
        developer.log(
          'Sign up successful: ${user.id}',
          name: 'AuthNotifier',
        );
      }

      // Return user directly instead of isFirstLogin boolean
      return user;
    } catch (error, stackTrace) {
      // Set error state
      state = AsyncValue.error(error, stackTrace);

      if (kDebugMode) {
        developer.log(
          'Sign up failed',
          name: 'AuthNotifier',
          error: error,
          stackTrace: stackTrace,
          level: 1000,
        );
      }

      rethrow; // Re-throw instead of returning false
    }
  }

  /// Sign in with email and password
  ///
  /// [email] User email address
  /// [password] User password
  ///
  /// Returns true if signin successful, false otherwise
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (kDebugMode) {
      developer.log(
        'signInWithEmail called (email: $email)',
        name: 'AuthNotifier',
      );
    }

    state = const AsyncValue.loading();

    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.signInWithEmail(
        email: email,
        password: password,
      );

      state = AsyncValue.data(user);

      if (kDebugMode) {
        developer.log(
          'Sign in successful: ${user.id}',
          name: 'AuthNotifier',
        );
      }

      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);

      if (kDebugMode) {
        developer.log(
          'Sign in failed',
          name: 'AuthNotifier',
          error: error,
          stackTrace: stackTrace,
          level: 1000,
        );
      }

      return false;
    }
  }

  /// Reset password by sending reset email
  ///
  /// [email] User email address to send reset link
  ///
  /// Throws exception if network error
  Future<void> resetPasswordForEmail(String email) async {
    if (kDebugMode) {
      developer.log(
        'resetPasswordForEmail called (email: $email)',
        name: 'AuthNotifier',
      );
    }

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.resetPasswordForEmail(email);

      if (kDebugMode) {
        developer.log(
          'Password reset email sent',
          name: 'AuthNotifier',
        );
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        developer.log(
          'Password reset failed',
          name: 'AuthNotifier',
          error: error,
          stackTrace: stackTrace,
          level: 1000,
        );
      }
      rethrow;
    }
  }

  /// Update password for logged-in user
  ///
  /// [currentPassword] User's current password
  /// [newPassword] New password (must meet strength requirements)
  ///
  /// Throws exception if current password is wrong or network error
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (kDebugMode) {
      developer.log(
        'updatePassword called',
        name: 'AuthNotifier',
      );
    }

    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      state = AsyncValue.data(user);

      if (kDebugMode) {
        developer.log(
          'Password updated successfully',
          name: 'AuthNotifier',
        );
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);

      if (kDebugMode) {
        developer.log(
          'Password update failed',
          name: 'AuthNotifier',
          error: error,
          stackTrace: stackTrace,
          level: 1000,
        );
      }

      rethrow;
    }
  }

  /// Delete user account permanently
  ///
  /// Deletes all user data and authentication.
  /// This operation is irreversible.
  ///
  /// Throws exception on failure.
  Future<void> deleteAccount() async {
    if (kDebugMode) {
      developer.log(
        'deleteAccount called',
        name: 'AuthNotifier',
      );
    }

    state = const AsyncValue.loading();

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.deleteAccount();

      // 삭제 성공 후 상태를 null로 설정 (로그아웃 상태)
      state = const AsyncValue.data(null);

      if (kDebugMode) {
        developer.log(
          'Account deleted successfully',
          name: 'AuthNotifier',
        );
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);

      if (kDebugMode) {
        developer.log(
          'Delete account failed',
          name: 'AuthNotifier',
          error: error,
          stackTrace: stackTrace,
          level: 1000,
        );
      }

      rethrow;
    }
  }
}

/// Provider for AuthRepository
///
/// Returns SupabaseAuthRepository for cloud-first architecture
@riverpod
AuthRepository authRepository(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseAuthRepository(supabase);
}

/// Alias for backwards compatibility
/// The generated provider is named 'authProvider', but the codebase uses 'authNotifierProvider'
const authNotifierProvider = authProvider;
