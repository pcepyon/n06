import 'package:n06/features/notification/domain/value_objects/notification_time.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:n06/features/notification/domain/entities/notification_settings.dart';
import 'package:n06/features/notification/infrastructure/dtos/notification_settings_dto.dart';
import 'package:n06/features/notification/infrastructure/repositories/isar_notification_repository.dart';

void main() {
  late Isar testIsar;
  late IsarNotificationRepository repository;

  setUp(() async {
    final tempDir = await getTemporaryDirectory();
    // Isar 테스트 환경 초기화
    testIsar = await Isar.open(
      [NotificationSettingsDtoSchema],
      directory: tempDir.path,
      inspector: false,
    );
    repository = IsarNotificationRepository(testIsar);
  });

  tearDown(() async {
    await testIsar.close(deleteFromDisk: true);
  });

  group('IsarNotificationRepository', () {
    test('should save notification settings to Isar', () async {
      // Arrange
      final settings = NotificationSettings(
        userId: 'user123',
        notificationTime: const NotificationTime(hour: 9, minute: 0),
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
      final initial = NotificationSettings(
        userId: 'user456',
        notificationTime: const NotificationTime(hour: 9, minute: 0),
        notificationEnabled: true,
      );
      await repository.saveNotificationSettings(initial);

      // Act
      final updated = NotificationSettings(
        userId: 'user456',
        notificationTime: const NotificationTime(hour: 21, minute: 0),
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
      final settings1 = NotificationSettings(
        userId: 'user789',
        notificationTime: const NotificationTime(hour: 9, minute: 0),
        notificationEnabled: true,
      );
      final settings2 = NotificationSettings(
        userId: 'user999',
        notificationTime: const NotificationTime(hour: 14, minute: 30),
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
