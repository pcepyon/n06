import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for securely storing OAuth tokens with expiry time management.
///
/// Uses FlutterSecureStorage to encrypt and store tokens in platform-specific
/// secure storage (Keychain on iOS, KeyStore on Android).
class SecureStorageService {
  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'ACCESS_TOKEN';
  static const _accessTokenExpiresAtKey = 'ACCESS_TOKEN_EXPIRES_AT';
  static const _refreshTokenKey = 'REFRESH_TOKEN';

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Saves access token with its expiry time.
  ///
  /// [token] The access token string.
  /// [expiresAt] The exact DateTime when the token expires.
  Future<void> saveAccessToken(String token, DateTime expiresAt) async {
    await _storage.write(key: _accessTokenKey, value: token);
    await _storage.write(
      key: _accessTokenExpiresAtKey,
      value: expiresAt.toIso8601String(),
    );
  }

  /// Gets the access token if it's still valid.
  ///
  /// Returns null if:
  /// - No token exists
  /// - Token has expired
  /// - Expiry time cannot be parsed
  Future<String?> getAccessToken() async {
    final token = await _storage.read(key: _accessTokenKey);
    if (token == null) return null;

    // Check expiry
    final isExpired = await isAccessTokenExpired();
    if (isExpired) return null;

    return token;
  }

  /// Checks if the access token has expired.
  ///
  /// Returns true if:
  /// - No expiry time is stored
  /// - Expiry time has passed
  /// - Expiry time cannot be parsed
  Future<bool> isAccessTokenExpired() async {
    final expiresAtString = await _storage.read(key: _accessTokenExpiresAtKey);
    if (expiresAtString == null) return true;

    try {
      final expiresAt = DateTime.parse(expiresAtString);
      return DateTime.now().isAfter(expiresAt);
    } catch (e) {
      // If parsing fails, consider token expired
      return true;
    }
  }

  /// Saves refresh token securely.
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Gets the refresh token.
  ///
  /// Returns null if no refresh token exists.
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Deletes all stored tokens.
  ///
  /// This should be called on logout to ensure clean state.
  Future<void> deleteAllTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _accessTokenExpiresAtKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
