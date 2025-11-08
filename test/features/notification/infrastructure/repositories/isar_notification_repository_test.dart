import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:n06/features/notification/domain/entities/notification_settings.dart';
import 'package:n06/features/notification/infrastructure/dtos/notification_settings_dto.dart';
import 'package:n06/features/notification/infrastructure/repositories/isar_notification_repository.dart';

void main() {
  late Isar testIsar;
  late IsarNotificationRepository repository;

  setUpAll(() async {
    // Isar 테스트 환경 초기화
    if (Isar.instanceNames.isEmpty) {
      testIsar = await Isar.open(
        [NotificationSettingsDtoSchema],
        inspector: false,
      );
    } else {
      testIsar = Isar.getInstance();
    }
    repository = IsarNotificationRepository(testIsar);
  });

  tearDownAll(() async {
    await testIsar.close(deleteFromDisk: true);
  });

  group('IsarNotificationRepository', () {
    test('should save notification settings to Isar', () async {
      // Arrange
      const settings = NotificationSettings(
        userId: 'user123',
        notificationTime: TimeOfDay(hour: 9, minute: 0),
        notificationEnabled: true,
      );

      // Act
      await repository.saveNotificationSettings(settings);

      // Assert
      final savedSettings =
          await repository.getNotificationSettings('user123');
      expect(savedSettings, isNotNull);
      expect(savedSettings!.notificationTime.hour, 9);
      expect(savedSettings.notificationEnabled, true);
    });

    test('should return null when settings not found', () async {
      // Arrange & Act
      final settings =
          await repository.getNotificationSettings('nonexistent_user');

      // Assert
      expect(settings, isNull);
    });

    test('should update existing settings', () async {
      // Arrange
      const initial = NotificationSettings(
        userId: 'user456',
        notificationTime: TimeOfDay(hour: 9, minute: 0),
        notificationEnabled: true,
      );
      await repository.saveNotificationSettings(initial);

      // Act
      const updated = NotificationSettings(
        userId: 'user456',
        notificationTime: TimeOfDay(hour: 21, minute: 0),
        notificationEnabled: false,
      );
      await repository.saveNotificationSettings(updated);

      // Assert
      final savedSettings =
          await repository.getNotificationSettings('user456');
      expect(savedSettings!.notificationTime.hour, 21);
      expect(savedSettings.notificationEnabled, false);
    });

    test('should preserve existing settings for different users', () async {
      // Arrange
      const settings1 = NotificationSettings(
        userId: 'user789',
        notificationTime: TimeOfDay(hour: 9, minute: 0),
        notificationEnabled: true,
      );
      const settings2 = NotificationSettings(
        userId: 'user999',
        notificationTime: TimeOfDay(hour: 14, minute: 30),
        notificationEnabled: false,
      );

      // Act
      await repository.saveNotificationSettings(settings1);
      await repository.saveNotificationSettings(settings2);

      // Assert
      final saved1 = await repository.getNotificationSettings('user789');
      final saved2 = await repository.getNotificationSettings('user999');

      expect(saved1!.notificationTime.hour, 9);
      expect(saved2!.notificationTime.hour, 14);
      expect(saved2.notificationTime.minute, 30);
    });
  });
}
