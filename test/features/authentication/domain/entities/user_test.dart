import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/authentication/domain/entities/user.dart';

void main() {
  group('User Entity', () {
    final testDate = DateTime(2025, 1, 1);

    test('should create User with all required fields', () {
      // Arrange & Act
      final user = User(
        id: 'user123',
        oauthProvider: 'kakao',
        oauthUserId: 'kakao_123',
        name: '홍길동',
        email: 'test@example.com',
        lastLoginAt: testDate,
      );

      // Assert
      expect(user.id, 'user123');
      expect(user.oauthProvider, 'kakao');
      expect(user.oauthUserId, 'kakao_123');
      expect(user.name, '홍길동');
      expect(user.email, 'test@example.com');
      expect(user.lastLoginAt, testDate);
    });

    test('should create User with optional profileImageUrl', () {
      // Arrange & Act
      final user = User(
        id: 'user123',
        oauthProvider: 'naver',
        oauthUserId: 'naver_123',
        name: '김철수',
        email: 'test@naver.com',
        profileImageUrl: 'https://example.com/image.jpg',
        lastLoginAt: testDate,
      );

      // Assert
      expect(user.profileImageUrl, 'https://example.com/image.jpg');
    });

    test('should create User with null profileImageUrl', () {
      // Arrange & Act
      final user = User(
        id: 'user123',
        oauthProvider: 'kakao',
        oauthUserId: 'kakao_123',
        name: '홍길동',
        email: 'test@example.com',
        lastLoginAt: testDate,
      );

      // Assert
      expect(user.profileImageUrl, isNull);
    });

    test('should support copyWith for immutability', () {
      // Arrange
      final user = User(
        id: 'user123',
        oauthProvider: 'kakao',
        oauthUserId: 'kakao_123',
        name: '홍길동',
        email: 'test@example.com',
        lastLoginAt: testDate,
      );

      // Act
      final updatedUser = user.copyWith(
        name: '홍길순',
        profileImageUrl: 'https://example.com/new.jpg',
      );

      // Assert
      expect(updatedUser.id, 'user123');
      expect(updatedUser.name, '홍길순');
      expect(updatedUser.profileImageUrl, 'https://example.com/new.jpg');
      expect(updatedUser.email, 'test@example.com');
    });

    test('should support equality comparison', () {
      // Arrange
      final user1 = User(
        id: 'user123',
        oauthProvider: 'kakao',
        oauthUserId: 'kakao_123',
        name: '홍길동',
        email: 'test@example.com',
        lastLoginAt: testDate,
      );

      final user2 = User(
        id: 'user123',
        oauthProvider: 'kakao',
        oauthUserId: 'kakao_123',
        name: '홍길동',
        email: 'test@example.com',
        lastLoginAt: testDate,
      );

      final user3 = User(
        id: 'user456',
        oauthProvider: 'naver',
        oauthUserId: 'naver_456',
        name: '김철수',
        email: 'other@example.com',
        lastLoginAt: testDate,
      );

      // Assert
      expect(user1, equals(user2));
      expect(user1, isNot(equals(user3)));
    });

    test('should have same hashCode for equal users', () {
      // Arrange
      final user1 = User(
        id: 'user123',
        oauthProvider: 'kakao',
        oauthUserId: 'kakao_123',
        name: '홍길동',
        email: 'test@example.com',
        lastLoginAt: testDate,
      );

      final user2 = User(
        id: 'user123',
        oauthProvider: 'kakao',
        oauthUserId: 'kakao_123',
        name: '홍길동',
        email: 'test@example.com',
        lastLoginAt: testDate,
      );

      // Assert
      expect(user1.hashCode, equals(user2.hashCode));
    });
  });
}
