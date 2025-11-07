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
    if (await isKakaoTalkInstalled()) {
      try {
        return await UserApi.instance.loginWithKakaoTalk();
      } catch (error) {
        // If user cancels, propagate the exception immediately
        if (error is PlatformException && error.code == 'CANCELED') {
          rethrow;
        }

        // For other errors (e.g., KakaoTalk login unavailable),
        // fallback to Account login
        return await UserApi.instance.loginWithKakaoAccount();
      }
    } else {
      // KakaoTalk not installed, use Account login directly
      return await UserApi.instance.loginWithKakaoAccount();
    }
  }

  /// Retrieves Kakao user information.
  ///
  /// Returns the currently logged-in user's profile data.
  ///
  /// Throws:
  /// - [Exception] if not authenticated or API call fails
  Future<User> getUser() async {
    return await UserApi.instance.me();
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
      print('Kakao logout completed: $error');
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
