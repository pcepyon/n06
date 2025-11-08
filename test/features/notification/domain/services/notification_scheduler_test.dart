import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:n06/features/notification/domain/services/notification_scheduler.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';

class MockNotificationScheduler extends Mock implements NotificationScheduler {}

void main() {
  group('NotificationScheduler Interface', () {
    late MockNotificationScheduler mockScheduler;

    setUp(() {
      mockScheduler = MockNotificationScheduler();
    });

    test('should define checkPermission method', () async {
      // Arrange
      when(mockScheduler.checkPermission())
          .thenAnswer((_) async => true);

      // Act
      final hasPermission = await mockScheduler.checkPermission();

      // Assert
      expect(hasPermission, isA<bool>());
      expect(hasPermission, true);
      verify(mockScheduler.checkPermission()).called(1);
    });

    test('should define requestPermission method', () async {
      // Arrange
      when(mockScheduler.requestPermission())
          .thenAnswer((_) async => true);

      // Act
      final granted = await mockScheduler.requestPermission();

      // Assert
      expect(granted, isTrue);
      verify(mockScheduler.requestPermission()).called(1);
    });

    test('should define scheduleNotifications method', () async {
      // Arrange
      final doseSchedule = DoseSchedule(
        id: 'schedule1',
        dosagePlanId: 'plan1',
        scheduledDate: DateTime.now().add(const Duration(days: 1)),
        scheduledDoseMg: 0.5,
      );
      when(mockScheduler.scheduleNotifications(
        doseSchedules: [doseSchedule],
        notificationTime: const TimeOfDay(hour: 9, minute: 0),
      )).thenAnswer((_) async => {});

      // Act
      await mockScheduler.scheduleNotifications(
        doseSchedules: [doseSchedule],
        notificationTime: const TimeOfDay(hour: 9, minute: 0),
      );

      // Assert
      verify(mockScheduler.scheduleNotifications(
        doseSchedules: [doseSchedule],
        notificationTime: const TimeOfDay(hour: 9, minute: 0),
      )).called(1);
    });

    test('should define cancelAllNotifications method', () async {
      // Arrange
      when(mockScheduler.cancelAllNotifications())
          .thenAnswer((_) async => {});

      // Act
      await mockScheduler.cancelAllNotifications();

      // Assert
      verify(mockScheduler.cancelAllNotifications()).called(1);
    });

    test('should return false when permission check fails', () async {
      // Arrange
      when(mockScheduler.checkPermission())
          .thenAnswer((_) async => false);

      // Act
      final hasPermission = await mockScheduler.checkPermission();

      // Assert
      expect(hasPermission, false);
    });

    test('should return false when permission request denied', () async {
      // Arrange
      when(mockScheduler.requestPermission())
          .thenAnswer((_) async => false);

      // Act
      final granted = await mockScheduler.requestPermission();

      // Assert
      expect(granted, false);
    });
  });
}
