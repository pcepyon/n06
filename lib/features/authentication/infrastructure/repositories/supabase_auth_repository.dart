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
/// - Automatic session management via Supabase
/// - User profile creation/update in users table
/// - Consent records storage
class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _supabase;

  SupabaseAuthRepository(this._supabase);

  @override
  Future<domain.User?> getCurrentUser() async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) return null;

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
      lastLoginAt: DateTime.parse(userProfile['last_login_at'] as String),
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

    // Check if access token is expired
    final expiresAt = session.expiresAt;
    if (expiresAt == null) return false;

    final expiryDateTime = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
    return DateTime.now().isBefore(expiryDateTime);
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

      // 3. Wait for trigger to complete (small delay)
      // Database trigger automatically creates public.users record
      await Future.delayed(const Duration(milliseconds: 500));

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
      lastLoginAt: DateTime.parse(userProfile['last_login_at'] as String),
    );
  }
}
