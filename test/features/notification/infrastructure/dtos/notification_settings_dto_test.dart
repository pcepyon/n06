import 'package:n06/features/notification/domain/value_objects/notification_time.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/notification/domain/entities/notification_settings.dart';
import 'package:n06/features/notification/infrastructure/dtos/notification_settings_dto.dart';

void main() {
  group('NotificationSettingsDto', () {
    test('should convert NotificationSettingsDto to NotificationSettings entity',
        () {
      // Arrange
      final dto = NotificationSettingsDto()
        ..userId = 'user123'
        ..notificationHour = 9
        ..notificationMinute = 0
        ..notificationEnabled = true;

      // Act
      final entity = dto.toEntity();

      // Assert
      expect(entity.userId, 'user123');
      expect(entity.notificationTime.hour, 9);
      expect(entity.notificationTime.minute, 0);
      expect(entity.notificationEnabled, true);
    });

    test('should convert NotificationSettings entity to NotificationSettingsDto',
        () {
      // Arrange
      final entity = NotificationSettings(
        userId: 'user123',
        notificationTime: const NotificationTime(hour: 21, minute: 30),
        notificationEnabled: false,
      );

      // Act
      final dto = NotificationSettingsDto.fromEntity(entity);

      // Assert
      expect(dto.userId, 'user123');
      expect(dto.notificationHour, 21);
      expect(dto.notificationMinute, 30);
      expect(dto.notificationEnabled, false);
    });

    test('should handle midnight time (00:00)', () {
      // Arrange
      final entity = NotificationSettings(
        userId: 'user123',
        notificationTime: const NotificationTime(hour: 0, minute: 0),
        notificationEnabled: true,
      );

      // Act
      final dto = NotificationSettingsDto.fromEntity(entity);
      final convertedEntity = dto.toEntity();

      // Assert
      expect(convertedEntity.notificationTime.hour, 0);
      expect(convertedEntity.notificationTime.minute, 0);
    });

    test('should handle end of day time (23:59)', () {
      // Arrange
      final entity = NotificationSettings(
        userId: 'user123',
        notificationTime: const NotificationTime(hour: 23, minute: 59),
        notificationEnabled: true,
      );

      // Act
      final dto = NotificationSettingsDto.fromEntity(entity);
      final convertedEntity = dto.toEntity();

      // Assert
      expect(convertedEntity.notificationTime.hour, 23);
      expect(convertedEntity.notificationTime.minute, 59);
    });

    test('should round-trip conversion preserve all values', () {
      // Arrange
      final original = NotificationSettings(
        userId: 'user456',
        notificationTime: const NotificationTime(hour: 14, minute: 45),
        notificationEnabled: false,
      );

      // Act
      final dto = NotificationSettingsDto.fromEntity(original);
      final restored = dto.toEntity();

      // Assert
      expect(restored, equals(original));
    });
  });
}
