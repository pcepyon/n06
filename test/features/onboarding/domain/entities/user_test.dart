import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/onboarding/domain/entities/user.dart';

void main() {
  group('User Entity', () {
    test('should create User with all required fields', () {
      // Arrange
      const id = 'user123';
      const name = 'John Doe';
      final createdAt = DateTime(2025, 1, 1);

      // Act
      final user = User(
        id: id,
        name: name,
        createdAt: createdAt,
      );

      // Assert
      expect(user.id, id);
      expect(user.name, name);
      expect(user.createdAt, createdAt);
    });

    test('should throw ArgumentError when id is empty', () {
      // Arrange
      const emptyId = '';
      const name = 'John Doe';
      final createdAt = DateTime(2025, 1, 1);

      // Act & Assert
      expect(
        () => User(
          id: emptyId,
          name: name,
          createdAt: createdAt,
        ),
        throwsArgumentError,
      );
    });

    test('should throw ArgumentError when name is empty', () {
      // Arrange
      const id = 'user123';
      const emptyName = '';
      final createdAt = DateTime(2025, 1, 1);

      // Act & Assert
      expect(
        () => User(
          id: id,
          name: emptyName,
          createdAt: createdAt,
        ),
        throwsArgumentError,
      );
    });

    test('should support equality', () {
      // Arrange
      const id = 'user123';
      const name = 'John Doe';
      final createdAt = DateTime(2025, 1, 1);

      // Act
      final user1 = User(
        id: id,
        name: name,
        createdAt: createdAt,
      );
      final user2 = User(
        id: id,
        name: name,
        createdAt: createdAt,
      );

      // Assert
      expect(user1, user2);
    });

    test('should support copyWith', () {
      // Arrange
      final user = User(
        id: 'user123',
        name: 'John Doe',
        createdAt: DateTime(2025, 1, 1),
      );
      const newName = 'Jane Doe';

      // Act
      final updatedUser = user.copyWith(name: newName);

      // Assert
      expect(updatedUser.id, user.id);
      expect(updatedUser.name, newName);
      expect(updatedUser.createdAt, user.createdAt);
    });

    test('should have meaningful toString', () {
      // Arrange
      final user = User(
        id: 'user123',
        name: 'John Doe',
        createdAt: DateTime(2025, 1, 1),
      );

      // Act & Assert
      expect(user.toString(), contains('John Doe'));
      expect(user.toString(), contains('user123'));
    });
  });
}
