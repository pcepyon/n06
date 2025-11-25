import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:flutter_naver_login/interface/types/naver_account_result.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/repositories/auth_repository.dart';

/// Supabase implementation of AuthRepository
///
/// Phase 1.3: Complete implementation with native OAuth SDK integration.
///
/// This implementation provides:
/// - Kakao Native SDK + Supabase Auth integration
/// - Naver Native SDK + Supabase Auth integration
/// - Automatic session management via Supabase onAuthStateChange
/// - User profile creation/update in users table
/// - Consent records storage
/// - Session lifecycle management (BUG-2025-1119-002 fix)
class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _supabase;
  StreamSubscription<AuthState>? _authStateSubscription;

  SupabaseAuthRepository(this._supabase) {
    // BUG-2025-1119-002 FIX: Subscribe to auth state changes
    // This ensures we detect session expiration, token refresh, and sign out events
    _authStateSubscription = _supabase.auth.onAuthStateChange.listen(
      (AuthState data) {
        final event = data.event;
        final session = data.session;

        if (kDebugMode) {
          developer.log(
            'Auth state changed: $event, session: ${session != null ? "present" : "null"}',
            name: 'SupabaseAuthRepository',
          );
        }

        // Handle different auth state events
        switch (event) {
          case AuthChangeEvent.signedOut:
            // Session expired or user logged out
            if (kDebugMode) {
              developer.log(
                'Session expired or user signed out',
                name: 'SupabaseAuthRepository',
              );
            }
            // AuthNotifier will detect this via getCurrentUser() returning null
            break;

          case AuthChangeEvent.tokenRefreshed:
            // Token was automatically refreshed by Supabase SDK
            if (kDebugMode) {
              developer.log(
                'Access token refreshed automatically',
                name: 'SupabaseAuthRepository',
              );
            }
            break;

          case AuthChangeEvent.signedIn:
            if (kDebugMode) {
              developer.log(
                'User signed in successfully',
                name: 'SupabaseAuthRepository',
              );
            }
            break;

          default:
            break;
        }
      },
      onError: (error) {
        if (kDebugMode) {
          developer.log(
            'Auth state change error: $error',
            name: 'SupabaseAuthRepository',
            error: error,
          );
        }
      },
    );
  }

  /// Dispose of resources (particularly the auth state subscription)
  void dispose() {
    _authStateSubscription?.cancel();
  }

  @override
  Future<domain.User?> getCurrentUser() async {
    // BUG-2025-1119-002 FIX: Validate session before returning user
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) return null;

    // Check if session exists and is valid
    final session = _supabase.auth.currentSession;
    if (session == null) {
      if (kDebugMode) {
        developer.log(
          'No valid session found, user state is stale',
          name: 'SupabaseAuthRepository',
        );
      }
      return null;
    }

    // Check if session is expired or about to expire
    final expiresAt = session.expiresAt;
    if (expiresAt != null) {
      final expiryDateTime = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
      final now = DateTime.now();

      // If session already expired, return null
      if (now.isAfter(expiryDateTime)) {
        if (kDebugMode) {
          developer.log(
            'Session expired at $expiryDateTime',
            name: 'SupabaseAuthRepository',
          );
        }
        return null;
      }

      // If session expires in less than 30 minutes, try to refresh
      final timeUntilExpiry = expiryDateTime.difference(now);
      if (timeUntilExpiry.inMinutes < 30) {
        if (kDebugMode) {
          developer.log(
            'Session expiring soon (${timeUntilExpiry.inMinutes} minutes), attempting refresh',
            name: 'SupabaseAuthRepository',
          );
        }

        try {
          await _supabase.auth.refreshSession();
          if (kDebugMode) {
            developer.log(
              'Session refreshed successfully',
              name: 'SupabaseAuthRepository',
            );
          }
        } catch (e) {
          if (kDebugMode) {
            developer.log(
              'Failed to refresh session: $e',
              name: 'SupabaseAuthRepository',
              error: e,
            );
          }
          // If refresh fails, return null (user needs to re-login)
          return null;
        }
      }
    }

    // Fetch user profile from users table
    final userProfile = await _supabase
        .from('users')
        .select()
        .eq('id', authUser.id)
        .maybeSingle();

    if (userProfile == null) return null;

    return domain.User(
      id: authUser.id,
      oauthProvider: userProfile['oauth_provider'] as String,
      oauthUserId: userProfile['oauth_user_id'] as String,
      name: userProfile['name'] as String,
      email: userProfile['email'] as String? ?? '',
      profileImageUrl: userProfile['profile_image_url'] as String?,
      lastLoginAt: DateTime.parse(userProfile['last_login_at'] as String).toLocal(),
    );
  }

  @override
  Future<bool> isFirstLogin() async {
    final user = await getCurrentUser();
    if (user == null) return true;

    // Check if user profile exists (onboarding completed)
    final response = await _supabase
        .from('user_profiles')
        .select()
        .eq('user_id', user.id)
        .limit(1);

    return (response as List).isEmpty;
  }

  @override
  Future<bool> isAccessTokenValid() async {
    final session = _supabase.auth.currentSession;
    if (session == null) return false;

    // Check if access token is expired or expiring soon
    final expiresAt = session.expiresAt;
    if (expiresAt == null) return false;

    final expiryDateTime = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
    final now = DateTime.now();

    // BUG-2025-1119-002 FIX: Consider token invalid if expiring in less than 30 minutes
    // This gives time for proper refresh before actual expiration
    final timeUntilExpiry = expiryDateTime.difference(now);
    return timeUntilExpiry.inMinutes >= 30;
  }

  @override
  Future<String> refreshAccessToken(String refreshToken) async {
    final response = await _supabase.auth.refreshSession();
    final session = response.session;

    if (session == null) {
      throw Exception('Failed to refresh access token');
    }

    return session.accessToken;
  }

  @override
  Future<void> logout() async {
    try {
      // 1. Kakao SDK 로그아웃 (가능하면)
      try {
        await kakao.UserApi.instance.logout();
      } catch (_) {
        // Kakao 로그아웃 실패는 무시 (Supabase 로그아웃이 중요)
      }

      // 2. Naver SDK 로그아웃 (가능하면)
      try {
        await FlutterNaverLogin.logOut();
      } catch (_) {
        // Naver 로그아웃 실패는 무시 (Supabase 로그아웃이 중요)
      }

      // 3. Supabase 로그아웃 (세션 삭제)
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  // ============================================
  // Kakao Login (Native SDK + Supabase)
  // ============================================

  @override
  Future<domain.User> loginWithKakao({
    required bool agreedToTerms,
    required bool agreedToPrivacy,
  }) async {
    try {
      // 1. Kakao Native SDK로 로그인
      kakao.OAuthToken kakaoToken;

      if (await kakao.isKakaoTalkInstalled()) {
        try {
          kakaoToken = await kakao.UserApi.instance.loginWithKakaoTalk();
        } catch (error) {
          // KakaoTalk 앱 로그인 실패 시 웹 로그인
          kakaoToken = await kakao.UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        // KakaoTalk 앱이 없으면 웹 로그인
        kakaoToken = await kakao.UserApi.instance.loginWithKakaoAccount();
      }

      // 2. Kakao 토큰을 Supabase에 전달하여 세션 생성
      // Supabase가 카카오 서버에 토큰을 검증하고 JWT 세션을 생성함
      final authResponse = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.kakao,
        idToken: kakaoToken.idToken!,
        accessToken: kakaoToken.accessToken,
      );

      if (authResponse.user == null) {
        throw Exception('Supabase authentication failed');
      }

      // 3. Wait for database trigger to create public.users record
      // BUG-2025-1119-006 FIX: Polling instead of fixed delay to prevent Race Condition
      await _waitForUserRecord(authResponse.user!.id);

      // 4. Kakao 사용자 정보 가져오기 (추가 프로필 데이터용)
      final kakaoUser = await kakao.UserApi.instance.me();

      // 5. Update profile with Kakao data (trigger already created base record)
      await _updateUserProfile(
        authResponse.user!.id,
        kakaoUser.kakaoAccount?.profile?.nickname,
        kakaoUser.kakaoAccount?.profile?.profileImageUrl,
      );

      // 6. 동의 기록 저장
      await _saveConsentRecord(
        authResponse.user!.id,
        agreedToTerms,
        agreedToPrivacy,
      );

      // 6. domain.User로 변환
      return await _mapToAppUser(authResponse.user!);
    } catch (e) {
      throw Exception('Kakao login failed: $e');
    }
  }

  // ============================================
  // Naver Login (Native SDK + Supabase)
  // ============================================

  @override
  Future<domain.User> loginWithNaver({
    required bool agreedToTerms,
    required bool agreedToPrivacy,
  }) async {
    try {
      // 1. Naver Native SDK로 로그인
      final NaverLoginResult result = await FlutterNaverLogin.logIn();

      if (result.status != NaverLoginStatus.loggedIn) {
        throw Exception('Naver login was cancelled or failed');
      }

      // 2. Naver 계정 정보 조회
      final NaverAccountResult naverAccount = await FlutterNaverLogin.getCurrentAccount();

      // 3. 사용자 ID 생성 (naver_ 접두사)
      final userId = 'naver_${naverAccount.id ?? DateTime.now().millisecondsSinceEpoch}';

      // 4. users 테이블에서 사용자 확인 또는 생성
      final existingUser = await _supabase
          .from('users')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (existingUser == null) {
        // 신규 사용자 생성
        await _supabase.from('users').insert({
          'id': userId,
          'oauth_provider': 'naver',
          'oauth_user_id': naverAccount.id,
          'name': naverAccount.nickname ?? naverAccount.name ?? 'User',
          'email': naverAccount.email ?? '',
          'profile_image_url': naverAccount.profileImage,
          'last_login_at': DateTime.now().toIso8601String(),
        });

        // BUG-2025-1119-006 FIX: Wait for INSERT to complete before consent record
        await _waitForUserRecord(userId);
      } else {
        // 기존 사용자 업데이트
        await _supabase.from('users').update({
          'last_login_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);
      }

      // 5. 동의 기록 저장
      await _saveConsentRecord(userId, agreedToTerms, agreedToPrivacy);

      // 6. domain.User 반환
      return domain.User(
        id: userId,
        oauthProvider: 'naver',
        oauthUserId: naverAccount.id ?? userId,
        name: naverAccount.nickname ?? naverAccount.name ?? 'User',
        email: naverAccount.email ?? '',
        profileImageUrl: naverAccount.profileImage,
        lastLoginAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Naver login failed: $e');
    }
  }

  // ============================================
  // Helper Methods
  // ============================================

  /// Update user profile with OAuth provider data
  /// Note: Trigger automatically creates base record on auth.users insert
  Future<void> _updateUserProfile(
    String userId,
    String? nickname,
    String? profileImageUrl,
  ) async {
    // Only update if we have data from OAuth provider
    if (nickname != null || profileImageUrl != null) {
      final updates = <String, dynamic>{};

      if (nickname != null) {
        updates['name'] = nickname;
      }

      if (profileImageUrl != null) {
        updates['profile_image_url'] = profileImageUrl;
      }

      updates['last_login_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from('users')
          .update(updates)
          .eq('id', userId);
    }
  }

  /// Wait for user record to be created in public.users table
  ///
  /// This method polls the users table to wait for the database trigger
  /// to complete creating the user record. This prevents Race Condition
  /// errors when trying to insert foreign key references (e.g., consent_records).
  ///
  /// Maximum wait time: 2 seconds (10 retries * 200ms)
  /// Throws: Exception if user record is not created within timeout
  Future<void> _waitForUserRecord(String userId) async {
    for (int i = 0; i < 10; i++) {
      final user = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (user != null) {
        // User record exists, proceed
        return;
      }

      // Wait 200ms before next attempt
      await Future.delayed(const Duration(milliseconds: 200));
    }

    // Timeout: user record not created after 2 seconds
    throw Exception('User record not created after 2 seconds');
  }

  Future<void> _saveConsentRecord(
    String userId,
    bool agreedToTerms,
    bool agreedToPrivacy,
  ) async {
    await _supabase.from('consent_records').insert({
      'user_id': userId,
      'terms_of_service': agreedToTerms,
      'privacy_policy': agreedToPrivacy,
    });
  }

  Future<domain.User> _mapToAppUser(User authUser) async {
    final userProfile = await _supabase
        .from('users')
        .select()
        .eq('id', authUser.id)
        .single();

    return domain.User(
      id: authUser.id,
      oauthProvider: userProfile['oauth_provider'] as String,
      oauthUserId: userProfile['oauth_user_id'] as String,
      name: userProfile['name'] as String,
      email: userProfile['email'] as String? ?? '',
      profileImageUrl: userProfile['profile_image_url'] as String?,
      lastLoginAt: DateTime.parse(userProfile['last_login_at'] as String).toLocal(),
    );
  }

  // ============================================
  // Email Authentication Methods
  // ============================================

  @override
  Future<domain.User> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Sign up with Supabase Auth
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'email': email,
        },
      );

      final authUser = response.user;
      if (authUser == null) {
        throw Exception('Sign up failed: user is null');
      }

      // 2. Create user profile record
      // BUG-2025-1123-001 FIX: Use UPSERT to avoid PK conflict with Database Trigger
      // Database Trigger (handle_new_user) automatically creates public.users record
      // when auth.users is inserted. UPSERT ensures safe operation regardless of
      // whether Trigger runs first or app code runs first.
      await _supabase.from('users').upsert({
        'id': authUser.id,
        'email': email,
        'name': email.split('@')[0], // Use email prefix as default name
        'oauth_provider': 'email',
        'oauth_user_id': email,
        'last_login_at': DateTime.now().toIso8601String(),
      });

      // 3. Wait for user record to be created
      // BUG-2025-1119-006 FIX: Ensure users INSERT completes before consent record
      await _waitForUserRecord(authUser.id);

      // 4. Save consent record (default: both consents true for email signup)
      // BUG-2025-1119-006 FIX: Email signup was missing consent record
      await _saveConsentRecord(
        authUser.id,
        true,  // terms_of_service: true (email signup implies agreement)
        true,  // privacy_policy: true (email signup implies agreement)
      );

      // 5. Return domain user
      return domain.User(
        id: authUser.id,
        oauthProvider: 'email',
        oauthUserId: email,
        name: email.split('@')[0],
        email: email,
        lastLoginAt: DateTime.now(),
      );
    } on AuthException catch (e) {
      // Catch specific Supabase auth errors
      if (e.message.contains('already registered')) {
        throw Exception('Email already exists');
      }
      if (e.message.contains('weak password')) {
        throw Exception('Password is too weak');
      }
      throw Exception('Sign up failed: ${e.message}');
    } catch (e) {
      throw Exception('Sign up error: $e');
    }
  }

  @override
  Future<domain.User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Sign in with Supabase Auth
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final authUser = response.user;
      if (authUser == null) {
        throw Exception('Sign in failed: user is null');
      }

      // 2. Update last login time
      await _supabase.from('users').update({
        'last_login_at': DateTime.now().toIso8601String(),
      }).eq('id', authUser.id);

      // 3. Fetch user profile
      final userProfile = await _supabase
          .from('users')
          .select()
          .eq('id', authUser.id)
          .single();

      // 4. Return domain user
      return domain.User(
        id: authUser.id,
        oauthProvider: userProfile['oauth_provider'] as String,
        oauthUserId: userProfile['oauth_user_id'] as String,
        name: userProfile['name'] as String,
        email: userProfile['email'] as String? ?? '',
        profileImageUrl: userProfile['profile_image_url'] as String?,
        lastLoginAt: DateTime.parse(userProfile['last_login_at'] as String).toLocal(),
      );
    } on AuthException catch (e) {
      if (e.message.contains('invalid credentials')) {
        throw Exception('Invalid email or password');
      }
      if (e.message.contains('Email not confirmed')) {
        throw Exception('Email not confirmed');
      }
      throw Exception('Sign in failed: ${e.message}');
    } catch (e) {
      throw Exception('Sign in error: $e');
    }
  }

  @override
  Future<void> resetPasswordForEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'n06://reset-password',
      );
    } on AuthException catch (e) {
      // For security, we don't tell whether email exists or not
      // Always return success
      if (e.statusCode == '422') {
        // Email not found - still return success for security
        return;
      }
      rethrow;
    } catch (e) {
      // Log but don't throw for security
      // Password reset email errors are silently ignored for security reasons
    }
  }

  @override
  Future<domain.User> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Note: Supabase doesn't provide a direct way to verify current password
      // Current approach:
      // 1. Get current user email
      // 2. Try to re-authenticate with current password
      // 3. If successful, update password

      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Re-authenticate with current password
      final currentEmail = currentUser.email;
      if (currentEmail == null) {
        throw Exception('User email not found');
      }

      try {
        // Try to sign in with current password to verify it
        await _supabase.auth.signInWithPassword(
          email: currentEmail,
          password: currentPassword,
        );
      } on AuthException {
        throw Exception('Current password is incorrect');
      }

      // Update password
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      // Fetch and return updated user
      final userProfile = await _supabase
          .from('users')
          .select()
          .eq('id', currentUser.id)
          .single();

      return domain.User(
        id: currentUser.id,
        oauthProvider: userProfile['oauth_provider'] as String,
        oauthUserId: userProfile['oauth_user_id'] as String,
        name: userProfile['name'] as String,
        email: userProfile['email'] as String? ?? '',
        profileImageUrl: userProfile['profile_image_url'] as String?,
        lastLoginAt: DateTime.parse(userProfile['last_login_at'] as String).toLocal(),
      );
    } on AuthException catch (e) {
      throw Exception('Update password failed: ${e.message}');
    } catch (e) {
      throw Exception('Update password error: $e');
    }
  }
}
