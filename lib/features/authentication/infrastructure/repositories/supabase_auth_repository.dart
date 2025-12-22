import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/repositories/auth_repository.dart';
import '../../domain/exceptions/auth_exceptions.dart';

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

      // BUG-20251205: 30분 이내 만료 시 refresh 호출 제거
      //
      // 문제: Future.timeout()은 원래 Future를 취소하지 않음
      // → 타임아웃 후에도 HTTP 요청이 백그라운드에서 계속 진행
      // → 오프라인 상태에서 "Uncaught error in root zone" 발생
      //
      // 해결: Supabase SDK의 autoRefreshToken (기본 활성화)에 의존
      // → 세션이 아직 유효하면 사용자 정보 반환
      // → SDK가 백그라운드에서 자동으로 토큰 갱신 처리
      final timeUntilExpiry = expiryDateTime.difference(now);
      if (timeUntilExpiry.inMinutes < 30 && kDebugMode) {
        developer.log(
          'Session expiring soon (${timeUntilExpiry.inMinutes} minutes), relying on autoRefreshToken',
          name: 'SupabaseAuthRepository',
        );
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
          // BUG-20251222: 카카오톡 앱에서 취소한 경우 감지
          if (_isKakaoUserCancellation(error)) {
            throw OAuthCancelledException('Kakao login cancelled by user');
          }
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
    } on OAuthCancelledException {
      // BUG-20251222: 사용자 취소 예외는 그대로 rethrow
      rethrow;
    } catch (e) {
      // BUG-20251222: 외부 브라우저에서 뒤로 가기로 취소한 경우 감지
      if (_isKakaoUserCancellation(e)) {
        throw OAuthCancelledException('Kakao login cancelled by user');
      }
      throw Exception('Kakao login failed: $e');
    }
  }

  /// BUG-20251222: 카카오 SDK 취소 예외 감지 헬퍼
  ///
  /// 카카오 SDK는 사용자 취소 시 다음 중 하나의 예외를 throw:
  /// - PlatformException with code 'CANCELED' (공식 문서)
  /// - KakaoAuthException (인증 관련 예외)
  /// - 메시지에 'cancel' 또는 'CANCELED' 포함
  bool _isKakaoUserCancellation(dynamic error) {
    // PlatformException with code 'CANCELED' (Kakao SDK 공식 패턴)
    if (error is PlatformException && error.code == 'CANCELED') {
      return true;
    }

    // 에러 메시지에 cancel 또는 CANCELED 포함 확인
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('cancel') ||
        errorString.contains('canceled') ||
        errorString.contains('cancelled')) {
      return true;
    }

    return false;
  }

  // ============================================
  // Naver Login (Native SDK + Edge Function + Supabase Auth)
  // ============================================
  //
  // 네이버는 OIDC를 지원하지 않아 signInWithIdToken() 사용 불가.
  // 대신 Edge Function을 통해 Admin API로 세션을 생성하는 패턴 사용:
  //
  // 1. Naver SDK로 access_token 획득
  // 2. Edge Function 호출 → Naver API로 토큰 검증
  // 3. Edge Function이 Admin API로 사용자 생성/조회
  // 4. Edge Function이 generateLink + verifyOtp로 세션 생성
  // 5. Flutter에서 setSession으로 세션 설정
  // 6. RLS 정책 (auth.uid() = user_id) 정상 작동
  //
  // 참고: https://github.com/supabase/supabase/discussions/18682

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

      // 2. Naver Access Token 획득
      final naverToken = await FlutterNaverLogin.getCurrentAccessToken();
      final accessToken = naverToken.accessToken;

      if (accessToken.isEmpty) {
        throw Exception('Failed to get Naver access token');
      }

      if (kDebugMode) {
        developer.log(
          'Naver login successful, calling Edge Function',
          name: 'SupabaseAuthRepository',
        );
      }

      // 3. Edge Function 호출 (서버 측에서 토큰 검증 + 세션 생성)
      final response = await _supabase.functions.invoke(
        'naver-auth',
        body: {
          'access_token': accessToken,
          'agreed_to_terms': agreedToTerms,
          'agreed_to_privacy': agreedToPrivacy,
        },
      );

      // 4. Edge Function 응답 처리
      if (response.status != 200) {
        final errorMsg = response.data?['error'] ?? 'Unknown error';
        throw Exception('Edge Function error: $errorMsg');
      }

      final data = response.data;
      if (data == null || data['success'] != true) {
        throw Exception('Authentication failed: ${data?['error'] ?? 'Unknown error'}');
      }

      final String refreshToken = data['refresh_token'] as String;

      if (kDebugMode) {
        developer.log(
          'Edge Function returned session, setting up Supabase auth',
          name: 'SupabaseAuthRepository',
        );
      }

      // 5. Supabase 세션 설정
      // Flutter SDK의 setSession은 refresh_token을 받아 새 세션 생성
      final authResponse = await _supabase.auth.setSession(refreshToken);

      if (authResponse.session == null) {
        throw Exception('Failed to set Supabase session');
      }

      // 6. 세션 새로고침으로 최신 상태 확보
      await _supabase.auth.refreshSession();

      final authUser = authResponse.user;
      if (authUser == null) {
        throw Exception('User not found after session setup');
      }

      if (kDebugMode) {
        developer.log(
          'Naver login complete. User ID: ${authUser.id}',
          name: 'SupabaseAuthRepository',
        );
      }

      // 7. public.users에서 사용자 프로필 조회
      // Edge Function이 이미 생성/업데이트했으므로 조회만 수행
      final userProfile = await _supabase
          .from('users')
          .select()
          .eq('id', authUser.id)
          .single();

      // 8. domain.User 반환
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
      if (kDebugMode) {
        developer.log(
          'Naver login AuthException: ${e.message}',
          name: 'SupabaseAuthRepository',
          error: e,
        );
      }
      throw Exception('Naver login failed: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Naver login error: $e',
          name: 'SupabaseAuthRepository',
          error: e,
        );
      }
      throw Exception('Naver login failed: $e');
    }
  }

  // ============================================
  // Apple Login (Native SDK + Supabase OIDC)
  // ============================================
  //
  // Apple은 OIDC를 지원하므로 Kakao와 동일한 signInWithIdToken() 패턴 사용.
  // Edge Function 없이 직접 Supabase Auth와 연동 가능.
  //
  // 흐름:
  // 1. Nonce 생성 (보안 필수)
  // 2. Apple Native SDK로 로그인 → idToken 획득
  // 3. signInWithIdToken(provider: apple, idToken, nonce)
  // 4. DB 트리거 완료 대기
  // 5. 프로필 업데이트 (Apple은 첫 로그인 시에만 이름 제공)
  // 6. 동의 기록 저장
  //
  // 주의: Apple은 첫 로그인 이후 fullName을 제공하지 않음

  @override
  Future<domain.User> loginWithApple({
    required bool agreedToTerms,
    required bool agreedToPrivacy,
  }) async {
    try {
      if (kDebugMode) {
        developer.log(
          'Starting Apple login...',
          name: 'SupabaseAuthRepository',
        );
      }

      // 1. Nonce 생성 (보안 필수 - CSRF 공격 방지)
      final rawNonce = _supabase.auth.generateRawNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      if (kDebugMode) {
        developer.log(
          'Generated nonce for Apple Sign In',
          name: 'SupabaseAuthRepository',
        );
      }

      // 2. Apple Native SDK로 로그인
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw Exception('Apple ID token is null');
      }

      if (kDebugMode) {
        developer.log(
          'Apple login successful, received ID token',
          name: 'SupabaseAuthRepository',
        );
      }

      // 3. Supabase에 ID Token 전달 (Kakao와 동일 패턴)
      final authResponse = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      if (authResponse.user == null) {
        throw Exception('Supabase authentication failed');
      }

      if (kDebugMode) {
        developer.log(
          'Supabase session created. User ID: ${authResponse.user!.id}',
          name: 'SupabaseAuthRepository',
        );
      }

      // 4. DB 트리거 완료 대기 (기존 헬퍼 재사용)
      await _waitForUserRecord(authResponse.user!.id);

      // 5. 프로필 업데이트 (Apple은 첫 로그인 시에만 이름 제공)
      // Note: credential.givenName, familyName은 첫 로그인 이후 null
      final fullName = _buildAppleFullName(
        credential.givenName,
        credential.familyName,
      );

      if (fullName != null && fullName.isNotEmpty) {
        await _updateUserProfile(
          authResponse.user!.id,
          fullName,
          null, // Apple은 프로필 이미지를 제공하지 않음
        );
      }

      // 6. 동의 기록 저장 (기존 헬퍼 재사용)
      await _saveConsentRecord(
        authResponse.user!.id,
        agreedToTerms,
        agreedToPrivacy,
      );

      if (kDebugMode) {
        developer.log(
          'Apple login complete. User ID: ${authResponse.user!.id}',
          name: 'SupabaseAuthRepository',
        );
      }

      // 7. domain.User 반환 (기존 헬퍼 재사용)
      return await _mapToAppUser(authResponse.user!);
    } on SignInWithAppleAuthorizationException catch (e) {
      // BUG-20251222: 사용자가 로그인 취소한 경우 OAuthCancelledException throw
      if (e.code == AuthorizationErrorCode.canceled) {
        if (kDebugMode) {
          developer.log(
            'Apple login cancelled by user',
            name: 'SupabaseAuthRepository',
          );
        }
        throw OAuthCancelledException('Apple login cancelled by user');
      }
      if (kDebugMode) {
        developer.log(
          'Apple login authorization error: ${e.message}',
          name: 'SupabaseAuthRepository',
          error: e,
        );
      }
      throw Exception('Apple login failed: ${e.message}');
    } on AuthException catch (e) {
      if (kDebugMode) {
        developer.log(
          'Apple login AuthException: ${e.message}',
          name: 'SupabaseAuthRepository',
          error: e,
        );
      }
      throw Exception('Apple login failed: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Apple login error: $e',
          name: 'SupabaseAuthRepository',
          error: e,
        );
      }
      throw Exception('Apple login failed: $e');
    }
  }

  /// Apple 이름 조합 헬퍼
  ///
  /// Apple은 givenName, familyName을 별도로 제공.
  /// 한국어 이름의 경우 familyName + givenName 순서로 조합.
  String? _buildAppleFullName(String? givenName, String? familyName) {
    if (givenName == null && familyName == null) return null;

    final parts = <String>[];
    if (familyName != null && familyName.isNotEmpty) {
      parts.add(familyName);
    }
    if (givenName != null && givenName.isNotEmpty) {
      parts.add(givenName);
    }

    return parts.isEmpty ? null : parts.join(' ');
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

  // ============================================
  // Account Deletion
  // ============================================

  @override
  Future<void> deleteAccount() async {
    try {
      // 1. 현재 세션 확인
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('Not authenticated');
      }

      if (kDebugMode) {
        developer.log(
          'Calling delete-account Edge Function',
          name: 'SupabaseAuthRepository',
        );
      }

      // 2. Edge Function 호출 (서버 측에서 auth.admin.deleteUser 실행)
      final response = await _supabase.functions.invoke(
        'delete-account',
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      // 3. 응답 처리
      if (response.status != 200) {
        final errorMsg = response.data?['error'] ?? 'Unknown error';
        throw Exception('Delete account failed: $errorMsg');
      }

      final data = response.data;
      if (data == null || data['success'] != true) {
        throw Exception(
            'Delete account failed: ${data?['error'] ?? 'Unknown error'}');
      }

      if (kDebugMode) {
        developer.log(
          'Account deleted successfully',
          name: 'SupabaseAuthRepository',
        );
      }

      // 4. 로컬 세션 정리 (Kakao/Naver SDK 로그아웃 포함)
      try {
        await kakao.UserApi.instance.logout();
      } catch (_) {
        // Kakao 로그아웃 실패는 무시
      }

      try {
        await FlutterNaverLogin.logOut();
      } catch (_) {
        // Naver 로그아웃 실패는 무시
      }

      // 5. Supabase 로컬 세션 정리
      // 서버에서 이미 사용자가 삭제되었으므로 signOut은 로컬 정리만 수행
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      if (kDebugMode) {
        developer.log(
          'Delete account AuthException: ${e.message}',
          name: 'SupabaseAuthRepository',
          error: e,
        );
      }
      throw Exception('Delete account failed: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Delete account error: $e',
          name: 'SupabaseAuthRepository',
          error: e,
        );
      }
      throw Exception('Delete account failed: $e');
    }
  }
}
