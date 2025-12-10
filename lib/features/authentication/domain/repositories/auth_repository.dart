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

  /// Login with Apple Sign In (iOS/macOS only)
  ///
  /// Returns authenticated [User] on success.
  /// Uses native Sign in with Apple + Supabase signInWithIdToken (OIDC).
  /// Throws exception on failure (user cancellation, network error, etc.)
  Future<User> loginWithApple({
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

  /// Sign up with email and password
  ///
  /// Creates a new user account with email authentication.
  /// Returns authenticated [User] on success.
  /// Throws exception if email already exists or password is weak.
  Future<User> signUpWithEmail({
    required String email,
    required String password,
  });

  /// Sign in with email and password
  ///
  /// Authenticates user with email credentials.
  /// Returns authenticated [User] on success.
  /// Throws exception if credentials are invalid.
  Future<User> signInWithEmail({
    required String email,
    required String password,
  });

  /// Send password reset email
  ///
  /// Sends password reset link to user's email.
  /// Always succeeds even if email doesn't exist (for security).
  /// Link redirects to deep link: n06://reset-password?token=xxx
  Future<void> resetPasswordForEmail(String email);

  /// Update password for logged-in user
  ///
  /// Updates user password. Requires current authentication.
  /// Returns updated [User] on success.
  /// Throws exception if current password is invalid or new password is weak.
  Future<User> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Delete user account permanently
  ///
  /// Deletes all user data including:
  /// - Authentication data (auth.users)
  /// - Profile data (users, user_profiles)
  /// - Activity data (weight_logs, dose_records, daily_checkins, etc.)
  /// - Settings (notification_settings)
  /// - Badges (user_badges)
  /// - Audit logs
  ///
  /// This operation is irreversible.
  /// Throws exception on failure.
  Future<void> deleteAccount();
}
