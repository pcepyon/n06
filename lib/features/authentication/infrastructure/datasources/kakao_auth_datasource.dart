import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

/// Data source for Kakao OAuth 2.0 authentication.
///
/// Implements the official Kakao Flutter SDK login pattern:
/// 1. Check if KakaoTalk is installed
/// 2. Try KakaoTalk login first
/// 3. Fallback to Account login if KakaoTalk fails
/// 4. Propagate CANCELED exception without retry
class KakaoAuthDataSource {
  /// Performs Kakao login following official best practices.
  ///
  /// Login flow:
  /// - If KakaoTalk is installed: try loginWithKakaoTalk()
  /// - If KakaoTalk fails (except user cancel): fallback to loginWithKakaoAccount()
  /// - If KakaoTalk is not installed: use loginWithKakaoAccount() directly
  ///
  /// Throws:
  /// - [PlatformException] with code 'CANCELED' if user cancels (no retry needed)
  /// - [Exception] for other authentication failures
  Future<OAuthToken> login() async {
    try {
      if (kDebugMode) {
        developer.log('🚀 Starting Kakao login...', name: 'KakaoAuthDataSource');
      }

      if (await isKakaoTalkInstalled()) {
        if (kDebugMode) {
          developer.log('📱 KakaoTalk installed, trying KakaoTalk login', name: 'KakaoAuthDataSource');
        }
        try {
          final token = await UserApi.instance.loginWithKakaoTalk();
          if (kDebugMode) {
            developer.log('✅ KakaoTalk login successful', name: 'KakaoAuthDataSource');
          }
          return token;
        } catch (error) {
          if (kDebugMode) {
            developer.log('⚠️ KakaoTalk login failed: $error', name: 'KakaoAuthDataSource');
          }
          // If user cancels, propagate the exception immediately
          if (error is PlatformException && error.code == 'CANCELED') {
            rethrow;
          }

          // For other errors (e.g., KakaoTalk login unavailable),
          // fallback to Account login
          if (kDebugMode) {
            developer.log('🔄 Falling back to Account login', name: 'KakaoAuthDataSource');
          }
          final token = await UserApi.instance.loginWithKakaoAccount();
          if (kDebugMode) {
            developer.log('✅ Account login successful', name: 'KakaoAuthDataSource');
          }
          return token;
        }
      } else {
        // KakaoTalk not installed, use Account login directly
        if (kDebugMode) {
          developer.log('🌐 KakaoTalk not installed, using Account login', name: 'KakaoAuthDataSource');
        }
        final token = await UserApi.instance.loginWithKakaoAccount();
        if (kDebugMode) {
          developer.log('✅ Account login successful', name: 'KakaoAuthDataSource');
        }
        return token;
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        developer.log(
          '❌ Kakao login failed',
          name: 'KakaoAuthDataSource',
          error: error,
          stackTrace: stackTrace,
          level: 1000,
        );
      }
      rethrow;
    }
  }

  /// Retrieves Kakao user information.
  ///
  /// Returns the currently logged-in user's profile data.
  ///
  /// Throws:
  /// - [Exception] if not authenticated or API call fails
  Future<User> getUser() async {
    try {
      if (kDebugMode) {
        developer.log('🔍 Calling UserApi.instance.me()...', name: 'KakaoAuthDataSource');
      }
      final user = await UserApi.instance.me();
      if (kDebugMode) {
        developer.log(
          '✅ User info fetched successfully: id=${user.id}, nickname=${user.kakaoAccount?.profile?.nickname}',
          name: 'KakaoAuthDataSource',
        );
      }
      return user;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        developer.log(
          '❌ Failed to fetch user info',
          name: 'KakaoAuthDataSource',
          error: error,
          stackTrace: stackTrace,
          level: 1000,
        );
      }
      rethrow;
    }
  }

  /// Logs out from Kakao.
  ///
  /// The SDK always deletes the local token regardless of API success,
  /// so errors are ignored to ensure local cleanup.
  Future<void> logout() async {
    try {
      await UserApi.instance.logout();
    } catch (error) {
      // SDK guarantees local token is deleted even if API fails
      // Log error but don't throw to ensure logout completes
      if (kDebugMode) {
        developer.log(
          'Kakao logout completed with error (local token still deleted)',
          name: 'KakaoAuthDataSource',
          error: error,
          level: 900,
        );
      }
    }
  }

  /// Checks if the current access token is valid.
  ///
  /// Returns:
  /// - true if token exists and is valid
  /// - false if no token or token is invalid/expired
  Future<bool> isTokenValid() async {
    // Check if token exists
    if (!await AuthApi.instance.hasToken()) {
      return false;
    }

    try {
      // Verify token validity by requesting token info
      await UserApi.instance.accessTokenInfo();
      return true;
    } catch (error) {
      // Token is invalid or expired
      return false;
    }
  }
}
