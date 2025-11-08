import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:n06/features/authentication/domain/repositories/secure_storage_repository.dart';

/// FlutterSecureStorage implementation of SecureStorageRepository
///
/// Manages OAuth tokens and expiry times using platform-specific secure storage:
/// - iOS: Keychain
/// - Android: KeyStore
/// - Windows/Linux: Encrypted file
class FlutterSecureStorageRepository implements SecureStorageRepository {
  final FlutterSecureStorage _storage;

  static const String _accessTokenKey = 'ACCESS_TOKEN';
  static const String _refreshTokenKey = 'REFRESH_TOKEN';
  static const String _tokenExpiresAtKey = 'TOKEN_EXPIRES_AT';

  FlutterSecureStorageRepository(this._storage);

  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _tokenExpiresAtKey);
  }

  @override
  Future<String?> getAccessToken() async {
    final token = await _storage.read(key: _accessTokenKey);
    if (token == null) return null;

    // Check if token has expired
    final isExpired = await isAccessTokenExpired();
    if (isExpired) return null;

    return token;
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  @override
  Future<DateTime?> getTokenExpiresAt() async {
    final expiresAtString = await _storage.read(key: _tokenExpiresAtKey);
    if (expiresAtString == null) return null;

    try {
      return DateTime.parse(expiresAtString);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isAccessTokenExpired() async {
    final expiresAtString = await _storage.read(key: _tokenExpiresAtKey);
    if (expiresAtString == null) return true;

    try {
      final expiresAt = DateTime.parse(expiresAtString);
      return DateTime.now().isAfter(expiresAt);
    } catch (e) {
      // If parsing fails, consider token expired
      return true;
    }
  }

  @override
  Future<void> saveAccessToken(String token, DateTime expiresAt) async {
    await _storage.write(key: _accessTokenKey, value: token);
    await _storage.write(
      key: _tokenExpiresAtKey,
      value: expiresAt.toIso8601String(),
    );
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }
}
