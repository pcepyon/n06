import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:n06/features/notification/domain/entities/notification_settings.dart';
import 'package:n06/features/notification/domain/repositories/notification_repository.dart';

class MockNotificationRepository extends Mock implements NotificationRepository {}

void main() {
  group('NotificationRepository Interface', () {
    late MockNotificationRepository mockRepository;

    setUp(() {
      mockRepository = MockNotificationRepository();
    });

    test('should define getNotificationSettings method', () async {
      // Arrange
      final mockSettings = NotificationSettings(
        userId: 'user123',
        notificationTime: const TimeOfDay(hour: 9, minute: 0),
        notificationEnabled: true,
      );
      when(mockRepository.getNotificationSettings('user123'))
          .thenAnswer((_) async => mockSettings);

      // Act
      final settings = await mockRepository.getNotificationSettings('user123');

      // Assert
      expect(settings, isA<NotificationSettings>());
      expect(settings!.userId, 'user123');
      verify(mockRepository.getNotificationSettings('user123')).called(1);
    });

    test('should define saveNotificationSettings method', () async {
      // Arrange
      final mockSettings = NotificationSettings(
        userId: 'user123',
        notificationTime: const TimeOfDay(hour: 9, minute: 0),
        notificationEnabled: true,
      );
      when(mockRepository.saveNotificationSettings(mockSettings))
          .thenAnswer((_) async => {});

      // Act
      await mockRepository.saveNotificationSettings(mockSettings);

      // Assert
      verify(mockRepository.saveNotificationSettings(mockSettings)).called(1);
    });

    test('should return null when settings not found', () async {
      // Arrange
      when(mockRepository.getNotificationSettings('nonexistent'))
          .thenAnswer((_) async => null);

      // Act
      final settings =
          await mockRepository.getNotificationSettings('nonexistent');

      // Assert
      expect(settings, isNull);
    });
  });
}
