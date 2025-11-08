/// Secure token storage repository interface
///
/// This interface abstracts token storage operations, allowing for flexible
/// implementations (FlutterSecureStorage, Keychain, etc.)
abstract class SecureStorageRepository {
  /// Clears all stored tokens from secure storage.
  ///
  /// This method will:
  /// 1. Delete access token
  /// 2. Delete refresh token
  /// 3. Delete token expiry information
  ///
  /// Throws exception if deletion fails.
  /// Returns successfully even if tokens don't exist.
  Future<void> clearTokens();

  /// Gets the stored access token if it exists and is valid.
  ///
  /// Returns null if:
  /// - No token exists
  /// - Token has expired
  /// - Reading fails
  Future<String?> getAccessToken();

  /// Gets the stored refresh token.
  ///
  /// Returns null if no refresh token exists.
  Future<String?> getRefreshToken();

  /// Gets the token expiry time.
  ///
  /// Returns null if no expiry time is stored.
  Future<DateTime?> getTokenExpiresAt();

  /// Checks if the access token has expired.
  ///
  /// Returns true if:
  /// - No token exists
  /// - Token has expired
  /// - Expiry time cannot be parsed
  Future<bool> isAccessTokenExpired();

  /// Saves access token with expiry time.
  Future<void> saveAccessToken(String token, DateTime expiresAt);

  /// Saves refresh token.
  Future<void> saveRefreshToken(String token);
}
