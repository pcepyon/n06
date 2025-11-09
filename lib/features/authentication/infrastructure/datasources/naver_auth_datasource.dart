import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_token.dart';
import 'package:flutter_naver_login/interface/types/naver_account_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';

/// Data source for Naver OAuth 2.0 authentication.
///
/// Implements the official Naver Flutter SDK login pattern:
/// 1. Call FlutterNaverLogin.logIn()
/// 2. Check NaverLoginStatus
/// 3. Throw exception if status is not loggedIn
class NaverAuthDataSource {
  /// Performs Naver login and validates the result.
  ///
  /// Throws:
  /// - [Exception] if login fails or user cancels
  /// - [Exception] if status is not NaverLoginStatus.loggedIn
  Future<NaverLoginResult> login() async {
    final NaverLoginResult result = await FlutterNaverLogin.logIn();

    if (result.status == NaverLoginStatus.error) {
      throw Exception('Naver login failed');
    } else if (result.status != NaverLoginStatus.loggedIn) {
      throw Exception('Naver login cancelled or failed');
    }

    return result;
  }

  /// Logs out from Naver and deletes local token.
  ///
  /// The SDK always deletes the local token regardless of API success,
  /// so errors are ignored to ensure local cleanup.
  Future<void> logout() async {
    try {
      await FlutterNaverLogin.logOutAndDeleteToken();
    } catch (error) {
      // SDK guarantees local token is deleted even if API fails
      // Log error but don't throw to ensure logout completes
      if (kDebugMode) {
        developer.log(
          'Naver logout completed with error (local token still deleted)',
          name: 'NaverAuthDataSource',
          error: error,
          level: 900,
        );
      }
    }
  }

  /// Retrieves Naver user information.
  ///
  /// The SDK automatically uses the current access token.
  /// No parameters needed.
  ///
  /// Throws:
  /// - [Exception] if not authenticated or API call fails
  Future<NaverAccountResult> getUser() async {
    return await FlutterNaverLogin.getCurrentAccount();
  }

  /// Gets the current access token and validates it.
  ///
  /// Throws:
  /// - [Exception] if token is expired or invalid
  Future<NaverToken> getCurrentToken() async {
    final NaverToken token =
        await FlutterNaverLogin.getCurrentAccessToken();

    if (!token.isValid()) {
      throw Exception('Naver token expired');
    }

    return token;
  }
}
