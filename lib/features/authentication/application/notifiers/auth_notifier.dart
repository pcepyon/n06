import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase, Session;
import 'package:n06/features/authentication/domain/entities/user.dart' as entities;
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
  // ✅ 의존성을 late final 필드로 선언 (keepAlive: true이지만 일관성 유지)
  late final _repository = ref.read(authRepositoryProvider);
  late final _logoutUseCase = ref.read(logoutUseCaseProvider);

  @override
  Future<entities.User?> build() async {
    if (kDebugMode) {
      developer.log('AuthNotifier.build() called', name: 'AuthNotifier');
    }

    // BUG-20251205: 세션 만료 시 로컬 세션 삭제
    //
    // 문제 1: Future.timeout()은 원래 Future를 취소하지 않음
    // → 오프라인에서 refreshSession() 호출 시 "Uncaught error in root zone" 발생
    //
    // 문제 2: GoRouter는 session != null로 판단하므로
    // → 만료된 세션이 있으면 /home으로 리디렉션
    // → AuthNotifier는 null 반환 → 무한 로딩 발생
    //
    // 해결: 세션 만료 시 로컬 세션 삭제 (signOut)
    // → GoRouter의 session != null 체크도 false가 됨
    // → /login으로 정상 리디렉션
    final session = Supabase.instance.client.auth.currentSession;

    // 세션 만료 여부를 직접 계산 (session.isExpired는 expiresAt이 null이면 true 반환)
    // 새 세션은 expiresAt이 아직 설정되지 않았을 수 있으므로, null이면 유효한 것으로 간주
    final isExpired = _isSessionExpired(session);

    if (session != null && isExpired) {
      if (kDebugMode) {
        developer.log(
          'Session expired (expiresAt: ${session.expiresAt}), returning null for re-login',
          name: 'AuthNotifier',
        );
      }
      // 만료된 세션은 null 반환 (로그인 화면으로 이동)
      // signOut() 호출하지 않음 - scope: local이어도 네트워크 요청 발생
      // GoRouter redirect에서 처리
      return null;
    }

    // Load current user on initialization
    return await _repository.getCurrentUser();
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
      if (kDebugMode) {
        developer.log('📞 Calling repository.loginWithKakao()...', name: 'AuthNotifier');
      }

      final user = await _repository.loginWithKakao(
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
      final isFirstLogin = await _repository.isFirstLogin();

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
      final user = await _repository.loginWithNaver(
        agreedToTerms: agreedToTerms,
        agreedToPrivacy: agreedToPrivacy,
      );
      return user;
    });

    // Return isFirstLogin status
    if (state.hasValue) {
      return await _repository.isFirstLogin();
    }
    return false;
  }

  /// Logout current user
  ///
  /// Always succeeds even if network request fails (local cleanup guaranteed)
  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _logoutUseCase.execute();
      return null;
    });
  }

  /// Ensure access token is valid, refresh if needed
  ///
  /// Returns true if token is valid or successfully refreshed
  /// Returns false if refresh fails (user needs to re-login)
  Future<bool> ensureValidToken() async {
    final isValid = await _repository.isAccessTokenValid();

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
  Future<entities.User> signUpWithEmail({
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
      final user = await _repository.signUpWithEmail(
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
      final user = await _repository.signInWithEmail(
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
      await _repository.resetPasswordForEmail(email);

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
      final user = await _repository.updatePassword(
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
      await _repository.deleteAccount();

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

/// BUG-20251205: 세션 만료 여부를 직접 계산
///
/// Supabase SDK의 session.isExpired는 expiresAt이 null이면 true를 반환하지만,
/// 새로 생성된 세션은 expiresAt이 아직 설정되지 않았을 수 있습니다.
/// 따라서 null인 경우는 유효한 것으로 간주합니다.
bool _isSessionExpired(Session? session) {
  if (session == null) return false;

  final expiresAt = session.expiresAt;
  // expiresAt이 null이면 유효한 것으로 간주 (새 세션일 수 있음)
  if (expiresAt == null) return false;

  final expiryDateTime = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
  return DateTime.now().isAfter(expiryDateTime);
}
