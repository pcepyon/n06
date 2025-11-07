import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n06/core/services/secure_storage_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureStorageService service;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    service = SecureStorageService(storage: mockStorage);
  });

  group('SecureStorageService', () {
    group('saveAccessToken', () {
      test('should save access token with expiry time', () async {
        // Arrange
        const token = 'test_access_token';
        final expiresAt = DateTime(2025, 1, 1, 12, 0, 0);

        when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
            .thenAnswer((_) async => {});

        // Act
        await service.saveAccessToken(token, expiresAt);

        // Assert
        verify(() => mockStorage.write(key: 'ACCESS_TOKEN', value: token)).called(1);
        verify(() => mockStorage.write(
              key: 'ACCESS_TOKEN_EXPIRES_AT',
              value: expiresAt.toIso8601String(),
            )).called(1);
      });
    });

    group('getAccessToken', () {
      test('should return access token if valid', () async {
        // Arrange
        const token = 'test_access_token';
        final expiresAt = DateTime.now().add(const Duration(hours: 1));

        when(() => mockStorage.read(key: 'ACCESS_TOKEN'))
            .thenAnswer((_) async => token);
        when(() => mockStorage.read(key: 'ACCESS_TOKEN_EXPIRES_AT'))
            .thenAnswer((_) async => expiresAt.toIso8601String());

        // Act
        final result = await service.getAccessToken();

        // Assert
        expect(result, token);
      });

      test('should return null when no token exists', () async {
        // Arrange
        when(() => mockStorage.read(key: any(named: 'key')))
            .thenAnswer((_) async => null);

        // Act
        final result = await service.getAccessToken();

        // Assert
        expect(result, isNull);
      });

      test('should return null for expired token', () async {
        // Arrange
        const token = 'test_access_token';
        final expiredTime = DateTime.now().subtract(const Duration(hours: 1));

        when(() => mockStorage.read(key: 'ACCESS_TOKEN'))
            .thenAnswer((_) async => token);
        when(() => mockStorage.read(key: 'ACCESS_TOKEN_EXPIRES_AT'))
            .thenAnswer((_) async => expiredTime.toIso8601String());

        // Act
        final result = await service.getAccessToken();

        // Assert
        expect(result, isNull);
      });
    });

    group('isAccessTokenExpired', () {
      test('should return true when token is expired', () async {
        // Arrange
        final expiredTime = DateTime.now().subtract(const Duration(hours: 1));

        when(() => mockStorage.read(key: 'ACCESS_TOKEN_EXPIRES_AT'))
            .thenAnswer((_) async => expiredTime.toIso8601String());

        // Act
        final result = await service.isAccessTokenExpired();

        // Assert
        expect(result, true);
      });

      test('should return false when token is still valid', () async {
        // Arrange
        final validTime = DateTime.now().add(const Duration(hours: 1));

        when(() => mockStorage.read(key: 'ACCESS_TOKEN_EXPIRES_AT'))
            .thenAnswer((_) async => validTime.toIso8601String());

        // Act
        final result = await service.isAccessTokenExpired();

        // Assert
        expect(result, false);
      });

      test('should return true when no expiry time exists', () async {
        // Arrange
        when(() => mockStorage.read(key: 'ACCESS_TOKEN_EXPIRES_AT'))
            .thenAnswer((_) async => null);

        // Act
        final result = await service.isAccessTokenExpired();

        // Assert
        expect(result, true);
      });
    });

    group('saveRefreshToken', () {
      test('should save refresh token securely', () async {
        // Arrange
        const token = 'test_refresh_token';

        when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
            .thenAnswer((_) async => {});

        // Act
        await service.saveRefreshToken(token);

        // Assert
        verify(() => mockStorage.write(key: 'REFRESH_TOKEN', value: token)).called(1);
      });
    });

    group('getRefreshToken', () {
      test('should return refresh token', () async {
        // Arrange
        const token = 'test_refresh_token';

        when(() => mockStorage.read(key: 'REFRESH_TOKEN'))
            .thenAnswer((_) async => token);

        // Act
        final result = await service.getRefreshToken();

        // Assert
        expect(result, token);
      });

      test('should return null when no refresh token exists', () async {
        // Arrange
        when(() => mockStorage.read(key: 'REFRESH_TOKEN'))
            .thenAnswer((_) async => null);

        // Act
        final result = await service.getRefreshToken();

        // Assert
        expect(result, isNull);
      });
    });

    group('deleteAllTokens', () {
      test('should delete all tokens on logout', () async {
        // Arrange
        when(() => mockStorage.delete(key: any(named: 'key')))
            .thenAnswer((_) async => {});

        // Act
        await service.deleteAllTokens();

        // Assert
        verify(() => mockStorage.delete(key: 'ACCESS_TOKEN')).called(1);
        verify(() => mockStorage.delete(key: 'ACCESS_TOKEN_EXPIRES_AT')).called(1);
        verify(() => mockStorage.delete(key: 'REFRESH_TOKEN')).called(1);
      });
    });
  });
}
