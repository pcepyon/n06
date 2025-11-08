import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:n06/features/notification/infrastructure/services/local_notification_scheduler.dart';
import 'package:n06/features/notification/infrastructure/services/permission_service.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';

class MockPermissionService extends Mock implements PermissionService {}

void main() {
  group('LocalNotificationScheduler', () {
    late LocalNotificationScheduler scheduler;
    late MockPermissionService mockPermissionService;

    setUp(() async {
      mockPermissionService = MockPermissionService();
      scheduler = LocalNotificationScheduler(mockPermissionService);
      await scheduler.initialize();
    });

    test('should initialize notification plugin', () async {
      // Assert
      expect(scheduler.isInitialized, true);
    });

    test('should check notification permission via PermissionService', () async {
      // Arrange
      when(mockPermissionService.checkPermission())
          .thenAnswer((_) async => true);
      final checkerScheduler =
          LocalNotificationScheduler(mockPermissionService);

      // Act
      final hasPermission = await checkerScheduler.checkPermission();

      // Assert
      expect(hasPermission, true);
      verify(mockPermissionService.checkPermission()).called(1);
    });

    test('should request notification permission via PermissionService', () async {
      // Arrange
      when(mockPermissionService.requestPermission())
          .thenAnswer((_) async => true);
      final requesterScheduler =
          LocalNotificationScheduler(mockPermissionService);

      // Act
      final granted = await requesterScheduler.requestPermission();

      // Assert
      expect(granted, true);
      verify(mockPermissionService.requestPermission()).called(1);
    });

    test('should schedule notifications for dose schedules', () async {
      // Arrange
      final doseSchedules = [
        DoseSchedule(
          id: 'schedule1',
          dosagePlanId: 'plan1',
          scheduledDate: DateTime.now().add(const Duration(days: 1)),
          scheduledDoseMg: 0.5,
        ),
        DoseSchedule(
          id: 'schedule2',
          dosagePlanId: 'plan1',
          scheduledDate: DateTime.now().add(const Duration(days: 8)),
          scheduledDoseMg: 1.0,
        ),
      ];

      // Act
      await scheduler.scheduleNotifications(
        doseSchedules: doseSchedules,
        notificationTime: const TimeOfDay(hour: 9, minute: 0),
      );

      // Assert
      final pendingNotifications = await scheduler.getPendingNotifications();
      expect(pendingNotifications.length, 2);
    });

    test('should cancel all notifications', () async {
      // Arrange
      final doseSchedule = DoseSchedule(
        id: 'schedule1',
        dosagePlanId: 'plan1',
        scheduledDate: DateTime.now().add(const Duration(days: 1)),
        scheduledDoseMg: 0.5,
      );
      await scheduler.scheduleNotifications(
        doseSchedules: [doseSchedule],
        notificationTime: const TimeOfDay(hour: 9, minute: 0),
      );

      // Act
      await scheduler.cancelAllNotifications();

      // Assert
      final pendingNotifications = await scheduler.getPendingNotifications();
      expect(pendingNotifications, isEmpty);
    });

    test('should not schedule notification for past dates', () async {
      // Arrange
      final pastSchedule = DoseSchedule(
        id: 'schedule1',
        dosagePlanId: 'plan1',
        scheduledDate: DateTime.now().subtract(const Duration(days: 1)),
        scheduledDoseMg: 0.5,
      );

      // Act
      await scheduler.scheduleNotifications(
        doseSchedules: [pastSchedule],
        notificationTime: const TimeOfDay(hour: 9, minute: 0),
      );

      // Assert
      final pendingNotifications = await scheduler.getPendingNotifications();
      expect(pendingNotifications, isEmpty);
    });

    test('should schedule only one notification per date', () async {
      // Arrange
      final sameDate = DateTime.now().add(const Duration(days: 1));
      final doseSchedules = [
        DoseSchedule(
          id: 'schedule1',
          dosagePlanId: 'plan1',
          scheduledDate: sameDate,
          scheduledDoseMg: 0.5,
        ),
        DoseSchedule(
          id: 'schedule2',
          dosagePlanId: 'plan1',
          scheduledDate: sameDate,
          scheduledDoseMg: 0.5,
        ),
      ];

      // Act
      await scheduler.scheduleNotifications(
        doseSchedules: doseSchedules,
        notificationTime: const TimeOfDay(hour: 9, minute: 0),
      );

      // Assert
      final pendingNotifications = await scheduler.getPendingNotifications();
      expect(pendingNotifications.length, 1);
    });
  });
}
