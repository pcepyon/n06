import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/authentication/domain/entities/user.dart';
import 'package:n06/features/authentication/infrastructure/dtos/user_dto.dart';

void main() {
  group('UserDto', () {
    group('toEntity', () {
      test('should convert UserDto to User entity', () {
        // Arrange
        final dto = UserDto(
          id: '123',
          oauthProvider: 'kakao',
          oauthUserId: 'kakao_123',
          name: '홍길동',
          email: 'test@example.com',
          profileImageUrl: 'https://example.com/image.jpg',
          lastLoginAt: DateTime(2025, 1, 1),
        );

        // Act
        final entity = dto.toEntity();

        // Assert
        expect(entity.id, '123');
        expect(entity.oauthProvider, 'kakao');
        expect(entity.oauthUserId, 'kakao_123');
        expect(entity.name, '홍길동');
        expect(entity.email, 'test@example.com');
        expect(entity.profileImageUrl, 'https://example.com/image.jpg');
        expect(entity.lastLoginAt, DateTime(2025, 1, 1));
      });

      test('should handle null profileImageUrl', () {
        // Arrange
        final dto = UserDto(
          id: '123',
          oauthProvider: 'kakao',
          oauthUserId: 'kakao_123',
          name: '홍길동',
          email: 'test@example.com',
          profileImageUrl: null,
          lastLoginAt: DateTime(2025, 1, 1),
        );

        // Act
        final entity = dto.toEntity();

        // Assert
        expect(entity.profileImageUrl, isNull);
      });
    });

    group('fromEntity', () {
      test('should convert User entity to UserDto', () {
        // Arrange
        final entity = User(
          id: '123',
          oauthProvider: 'kakao',
          oauthUserId: 'kakao_123',
          name: '홍길동',
          email: 'test@example.com',
          profileImageUrl: 'https://example.com/image.jpg',
          lastLoginAt: DateTime(2025, 1, 1),
        );

        // Act
        final dto = UserDto.fromEntity(entity);

        // Assert
        expect(dto.id, '123');
        expect(dto.oauthProvider, 'kakao');
        expect(dto.oauthUserId, 'kakao_123');
        expect(dto.name, '홍길동');
        expect(dto.email, 'test@example.com');
        expect(dto.profileImageUrl, 'https://example.com/image.jpg');
        expect(dto.lastLoginAt, DateTime(2025, 1, 1));
      });

      test('should handle null profileImageUrl', () {
        // Arrange
        final entity = User(
          id: '456',
          oauthProvider: 'kakao',
          oauthUserId: 'kakao_123',
          name: '홍길동',
          email: 'test@example.com',
          profileImageUrl: null,
          lastLoginAt: DateTime(2025, 1, 1),
        );

        // Act
        final dto = UserDto.fromEntity(entity);

        // Assert
        expect(dto.id, '456');
        expect(dto.profileImageUrl, isNull);
      });
    });

    group('JSON serialization', () {
      test('should convert from JSON', () {
        // Arrange
        final json = {
          'id': '123',
          'oauth_provider': 'kakao',
          'oauth_user_id': 'kakao_123',
          'name': '홍길동',
          'email': 'test@example.com',
          'profile_image_url': 'https://example.com/image.jpg',
          'last_login_at': '2025-01-01T00:00:00.000',
        };

        // Act
        final dto = UserDto.fromJson(json);

        // Assert
        expect(dto.id, '123');
        expect(dto.oauthProvider, 'kakao');
        expect(dto.email, 'test@example.com');
      });

      test('should convert to JSON', () {
        // Arrange
        final dto = UserDto(
          id: '123',
          oauthProvider: 'kakao',
          oauthUserId: 'kakao_123',
          name: '홍길동',
          email: 'test@example.com',
          profileImageUrl: 'https://example.com/image.jpg',
          lastLoginAt: DateTime(2025, 1, 1),
        );

        // Act
        final json = dto.toJson();

        // Assert
        expect(json['id'], '123');
        expect(json['oauth_provider'], 'kakao');
        expect(json['email'], 'test@example.com');
      });
    });
  });
}
