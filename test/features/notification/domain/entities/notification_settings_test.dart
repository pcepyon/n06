import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/notification/domain/entities/notification_settings.dart';

void main() {
  group('NotificationSettings', () {
    test('should create NotificationSettings with default values', () {
      // Arrange & Act
      final settings = NotificationSettings(
        userId: 'user123',
        notificationTime: const TimeOfDay(hour: 9, minute: 0),
        notificationEnabled: true,
      );

      // Assert
      expect(settings.userId, 'user123');
      expect(settings.notificationTime.hour, 9);
      expect(settings.notificationTime.minute, 0);
      expect(settings.notificationEnabled, true);
    });

    test('should create NotificationSettings with disabled state', () {
      // Arrange & Act
      final settings = NotificationSettings(
        userId: 'user123',
        notificationTime: const TimeOfDay(hour: 21, minute: 30),
        notificationEnabled: false,
      );

      // Assert
      expect(settings.notificationEnabled, false);
    });

    test('should support copyWith for immutability', () {
      // Arrange
      final original = NotificationSettings(
        userId: 'user123',
        notificationTime: const TimeOfDay(hour: 9, minute: 0),
        notificationEnabled: true,
      );

      // Act
      final updated = original.copyWith(
        notificationTime: const TimeOfDay(hour: 21, minute: 0),
      );

      // Assert
      expect(updated.notificationTime.hour, 21);
      expect(updated.notificationEnabled, true);
      expect(updated.userId, 'user123');
    });

    test('should support copyWith with multiple fields', () {
      // Arrange
      final original = NotificationSettings(
        userId: 'user123',
        notificationTime: const TimeOfDay(hour: 9, minute: 0),
        notificationEnabled: true,
      );

      // Act
      final updated = original.copyWith(
        notificationTime: const TimeOfDay(hour: 14, minute: 30),
        notificationEnabled: false,
      );

      // Assert
      expect(updated.notificationTime.hour, 14);
      expect(updated.notificationTime.minute, 30);
      expect(updated.notificationEnabled, false);
    });

    test('should support equality comparison', () {
      // Arrange
      final settings1 = NotificationSettings(
        userId: 'user123',
        notificationTime: const TimeOfDay(hour: 9, minute: 0),
        notificationEnabled: true,
      );
      final settings2 = NotificationSettings(
        userId: 'user123',
        notificationTime: const TimeOfDay(hour: 9, minute: 0),
        notificationEnabled: true,
      );

      // Assert
      expect(settings1, equals(settings2));
    });

    test('should not be equal when userId differs', () {
      // Arrange
      final settings1 = NotificationSettings(
        userId: 'user123',
        notificationTime: const TimeOfDay(hour: 9, minute: 0),
        notificationEnabled: true,
      );
      final settings2 = NotificationSettings(
        userId: 'user456',
        notificationTime: const TimeOfDay(hour: 9, minute: 0),
        notificationEnabled: true,
      );

      // Assert
      expect(settings1, isNot(equals(settings2)));
    });

    test('should not be equal when notificationTime differs', () {
      // Arrange
      final settings1 = NotificationSettings(
        userId: 'user123',
        notificationTime: const TimeOfDay(hour: 9, minute: 0),
        notificationEnabled: true,
      );
      final settings2 = NotificationSettings(
        userId: 'user123',
        notificationTime: const TimeOfDay(hour: 10, minute: 0),
        notificationEnabled: true,
      );

      // Assert
      expect(settings1, isNot(equals(settings2)));
    });

    test('should not be equal when notificationEnabled differs', () {
      // Arrange
      final settings1 = NotificationSettings(
        userId: 'user123',
        notificationTime: const TimeOfDay(hour: 9, minute: 0),
        notificationEnabled: true,
      );
      final settings2 = NotificationSettings(
        userId: 'user123',
        notificationTime: const TimeOfDay(hour: 9, minute: 0),
        notificationEnabled: false,
      );

      // Assert
      expect(settings1, isNot(equals(settings2)));
    });
  });
}
