import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:n06/features/authentication/infrastructure/repositories/flutter_secure_storage_repository.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late FlutterSecureStorageRepository repository;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    repository = FlutterSecureStorageRepository(mockStorage);
  });

  group('FlutterSecureStorageRepository', () {
    group('clearTokens', () {
      test('should delete accessToken when clearTokens is called', () async {
        // Arrange
        when(() => mockStorage.delete(key: 'ACCESS_TOKEN')).thenAnswer(
          (_) => Future.value(),
        );
        when(() => mockStorage.delete(key: 'REFRESH_TOKEN')).thenAnswer(
          (_) => Future.value(),
        );
        when(() => mockStorage.delete(key: 'TOKEN_EXPIRES_AT')).thenAnswer(
          (_) => Future.value(),
        );

        // Act
        await repository.clearTokens();

        // Assert
        verify(() => mockStorage.delete(key: 'ACCESS_TOKEN')).called(1);
      });

      test('should delete refreshToken when clearTokens is called', () async {
        // Arrange
        when(() => mockStorage.delete(key: 'ACCESS_TOKEN')).thenAnswer(
          (_) => Future.value(),
        );
        when(() => mockStorage.delete(key: 'REFRESH_TOKEN')).thenAnswer(
          (_) => Future.value(),
        );
        when(() => mockStorage.delete(key: 'TOKEN_EXPIRES_AT')).thenAnswer(
          (_) => Future.value(),
        );

        // Act
        await repository.clearTokens();

        // Assert
        verify(() => mockStorage.delete(key: 'REFRESH_TOKEN')).called(1);
      });

      test('should delete tokenExpiresAt when clearTokens is called', () async {
        // Arrange
        when(() => mockStorage.delete(key: 'ACCESS_TOKEN')).thenAnswer(
          (_) => Future.value(),
        );
        when(() => mockStorage.delete(key: 'REFRESH_TOKEN')).thenAnswer(
          (_) => Future.value(),
        );
        when(() => mockStorage.delete(key: 'TOKEN_EXPIRES_AT')).thenAnswer(
          (_) => Future.value(),
        );

        // Act
        await repository.clearTokens();

        // Assert
        verify(() => mockStorage.delete(key: 'TOKEN_EXPIRES_AT')).called(1);
      });

      test('should throw exception when delete fails', () async {
        // Arrange
        when(() => mockStorage.delete(key: any(named: 'key'))).thenThrow(
          Exception('Storage access error'),
        );

        // Act & Assert
        expect(
          () => repository.clearTokens(),
          throwsException,
        );
      });

      test('should delete all tokens in correct order', () async {
        // Arrange
        final callOrder = <String>[];

        when(() => mockStorage.delete(key: 'ACCESS_TOKEN')).thenAnswer((_) {
          callOrder.add('ACCESS_TOKEN');
          return Future.value();
        });

        when(() => mockStorage.delete(key: 'REFRESH_TOKEN')).thenAnswer((_) {
          callOrder.add('REFRESH_TOKEN');
          return Future.value();
        });

        when(() => mockStorage.delete(key: 'TOKEN_EXPIRES_AT')).thenAnswer((_) {
          callOrder.add('TOKEN_EXPIRES_AT');
          return Future.value();
        });

        // Act
        await repository.clearTokens();

        // Assert
        expect(callOrder.length, 3);
        expect(callOrder.contains('ACCESS_TOKEN'), true);
        expect(callOrder.contains('REFRESH_TOKEN'), true);
        expect(callOrder.contains('TOKEN_EXPIRES_AT'), true);
      });
    });

    group('getAccessToken', () {
      test('should return access token when it exists and is valid', () async {
        // Arrange
        const token = 'test_token_123';
        when(() => mockStorage.read(key: 'ACCESS_TOKEN')).thenAnswer(
          (_) => Future.value(token),
        );
        when(() => mockStorage.read(key: 'TOKEN_EXPIRES_AT')).thenAnswer(
          (_) => Future.value(
            DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
          ),
        );

        // Act
        final result = await repository.getAccessToken();

        // Assert
        expect(result, token);
      });

      test('should return null when token does not exist', () async {
        // Arrange
        when(() => mockStorage.read(key: 'ACCESS_TOKEN')).thenAnswer(
          (_) => Future.value(null),
        );

        // Act
        final result = await repository.getAccessToken();

        // Assert
        expect(result, null);
      });

      test('should return null when token is expired', () async {
        // Arrange
        const token = 'test_token_123';
        when(() => mockStorage.read(key: 'ACCESS_TOKEN')).thenAnswer(
          (_) => Future.value(token),
        );
        when(() => mockStorage.read(key: 'TOKEN_EXPIRES_AT')).thenAnswer(
          (_) => Future.value(
            DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
          ),
        );

        // Act
        final result = await repository.getAccessToken();

        // Assert
        expect(result, null);
      });
    });

    group('getRefreshToken', () {
      test('should return refresh token when it exists', () async {
        // Arrange
        const token = 'refresh_token_123';
        when(() => mockStorage.read(key: 'REFRESH_TOKEN')).thenAnswer(
          (_) => Future.value(token),
        );

        // Act
        final result = await repository.getRefreshToken();

        // Assert
        expect(result, token);
      });

      test('should return null when refresh token does not exist', () async {
        // Arrange
        when(() => mockStorage.read(key: 'REFRESH_TOKEN')).thenAnswer(
          (_) => Future.value(null),
        );

        // Act
        final result = await repository.getRefreshToken();

        // Assert
        expect(result, null);
      });
    });

    group('isAccessTokenExpired', () {
      test('should return false when token is not expired', () async {
        // Arrange
        when(() => mockStorage.read(key: 'TOKEN_EXPIRES_AT')).thenAnswer(
          (_) => Future.value(
            DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
          ),
        );

        // Act
        final result = await repository.isAccessTokenExpired();

        // Assert
        expect(result, false);
      });

      test('should return true when token is expired', () async {
        // Arrange
        when(() => mockStorage.read(key: 'TOKEN_EXPIRES_AT')).thenAnswer(
          (_) => Future.value(
            DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
          ),
        );

        // Act
        final result = await repository.isAccessTokenExpired();

        // Assert
        expect(result, true);
      });

      test('should return true when expiry time does not exist', () async {
        // Arrange
        when(() => mockStorage.read(key: 'TOKEN_EXPIRES_AT')).thenAnswer(
          (_) => Future.value(null),
        );

        // Act
        final result = await repository.isAccessTokenExpired();

        // Assert
        expect(result, true);
      });
    });

    group('saveAccessToken', () {
      test('should save access token with expiry time', () async {
        // Arrange
        const token = 'new_token_123';
        final expiresAt = DateTime.now().add(const Duration(hours: 2));

        when(() => mockStorage.write(
          key: 'ACCESS_TOKEN',
          value: token,
        )).thenAnswer((_) => Future.value());

        when(() => mockStorage.write(
          key: 'TOKEN_EXPIRES_AT',
          value: any(named: 'value'),
        )).thenAnswer((_) => Future.value());

        // Act
        await repository.saveAccessToken(token, expiresAt);

        // Assert
        verify(() => mockStorage.write(
          key: 'ACCESS_TOKEN',
          value: token,
        )).called(1);

        verify(() => mockStorage.write(
          key: 'TOKEN_EXPIRES_AT',
          value: any(named: 'value'),
        )).called(1);
      });
    });

    group('saveRefreshToken', () {
      test('should save refresh token', () async {
        // Arrange
        const token = 'refresh_token_123';

        when(() => mockStorage.write(
          key: 'REFRESH_TOKEN',
          value: token,
        )).thenAnswer((_) => Future.value());

        // Act
        await repository.saveRefreshToken(token);

        // Assert
        verify(() => mockStorage.write(
          key: 'REFRESH_TOKEN',
          value: token,
        )).called(1);
      });
    });

    group('getTokenExpiresAt', () {
      test('should return expiry time when it exists', () async {
        // Arrange
        final expiresAt = DateTime.now().add(const Duration(hours: 1));
        when(() => mockStorage.read(key: 'TOKEN_EXPIRES_AT')).thenAnswer(
          (_) => Future.value(expiresAt.toIso8601String()),
        );

        // Act
        final result = await repository.getTokenExpiresAt();

        // Assert
        expect(result, isNotNull);
        expect(result!.difference(expiresAt).inSeconds.abs(), lessThan(1));
      });

      test('should return null when expiry time does not exist', () async {
        // Arrange
        when(() => mockStorage.read(key: 'TOKEN_EXPIRES_AT')).thenAnswer(
          (_) => Future.value(null),
        );

        // Act
        final result = await repository.getTokenExpiresAt();

        // Assert
        expect(result, null);
      });
    });
  });
}
