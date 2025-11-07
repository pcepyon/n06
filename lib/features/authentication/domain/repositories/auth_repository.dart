import 'package:n06/features/authentication/domain/entities/user.dart';

/// Authentication repository interface
///
/// This interface defines the contract for authentication operations.
/// Implementations should handle OAuth flow, token management, and user persistence.
abstract class AuthRepository {
  /// Login with Kakao OAuth
  ///
  /// Returns authenticated [User] on success.
  /// Throws exception on failure (network error, OAuth cancellation, etc.)
  Future<User> loginWithKakao({
    required bool agreedToTerms,
    required bool agreedToPrivacy,
  });

  /// Login with Naver OAuth
  ///
  /// Returns authenticated [User] on success.
  /// Throws exception on failure (network error, OAuth cancellation, etc.)
  Future<User> loginWithNaver({
    required bool agreedToTerms,
    required bool agreedToPrivacy,
  });

  /// Logout current user
  ///
  /// Clears all tokens and session data.
  /// Always succeeds even if network request fails (local cleanup guaranteed).
  Future<void> logout();

  /// Get currently authenticated user
  ///
  /// Returns [User] if authenticated, null otherwise.
  Future<User?> getCurrentUser();

  /// Check if this is user's first login
  ///
  /// Returns true if user has never logged in before (lastLoginAt is null).
  /// Returns false for returning users.
  Future<bool> isFirstLogin();

  /// Check if access token is still valid
  ///
  /// Returns true if token exists and not expired.
  /// Returns false otherwise.
  Future<bool> isAccessTokenValid();

  /// Refresh access token using refresh token
  ///
  /// Returns new access token on success.
  /// Throws exception if refresh token is also expired.
  Future<String> refreshAccessToken(String refreshToken);
}
