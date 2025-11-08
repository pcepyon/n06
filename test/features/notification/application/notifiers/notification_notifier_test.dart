import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:n06/features/notification/application/notifiers/notification_notifier.dart';
import 'package:n06/features/notification/domain/entities/notification_settings.dart';
import 'package:n06/features/notification/domain/repositories/notification_repository.dart';
import 'package:n06/features/notification/domain/services/notification_scheduler.dart';
import 'package:n06/features/tracking/application/providers.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';
import 'package:n06/features/tracking/domain/repositories/medication_repository.dart';

// Type-safe matchers for null safety
T anyOfType<T>() => any as T;
T anyNamedOfType<T>(String name) => anyNamed(name) as T;

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

class MockNotificationScheduler extends Mock implements NotificationScheduler {}

class MockMedicationRepository extends Mock implements MedicationRepository {}

void main() {
  group('NotificationNotifier', () {
    late MockNotificationRepository mockRepository;
    late MockNotificationScheduler mockScheduler;
    late MockMedicationRepository mockMedicationRepository;

    setUp(() {
      mockRepository = MockNotificationRepository();
      mockScheduler = MockNotificationScheduler();
      mockMedicationRepository = MockMedicationRepository();
    });

    test('should initialize with loading state', () {
      // Arrange
      when(mockRepository.getNotificationSettings('user123'))
          .thenAnswer((_) async => null);

      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider
              .overrideWithValue(mockRepository),
          notificationSchedulerProvider
              .overrideWithValue(mockScheduler),
          medicationRepositoryProvider
              .overrideWithValue(mockMedicationRepository),
        ],
      );

      // Act & Assert
      expect(
        container.read(notificationNotifierProvider),
        isA<AsyncLoading<NotificationSettings>>(),
      );
    });

    test('should load notification settings on build', () async {
      // Arrange
      final mockSettings = NotificationSettings(
        userId: 'user123',
        notificationTime: const TimeOfDay(hour: 9, minute: 0),
        notificationEnabled: true,
      );
      when(mockRepository.getNotificationSettings('user123'))
          .thenAnswer((_) async => mockSettings);

      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider
              .overrideWithValue(mockRepository),
          notificationSchedulerProvider
              .overrideWithValue(mockScheduler),
          medicationRepositoryProvider
              .overrideWithValue(mockMedicationRepository),
        ],
      );

      // Act
      await container.read(notificationNotifierProvider.future);

      // Assert
      final state = container.read(notificationNotifierProvider);
      expect(state.value, mockSettings);
    });

    test('should return default settings when none exist', () async {
      // Arrange
      when(mockRepository.getNotificationSettings('user123'))
          .thenAnswer((_) async => null);

      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider
              .overrideWithValue(mockRepository),
          notificationSchedulerProvider
              .overrideWithValue(mockScheduler),
          medicationRepositoryProvider
              .overrideWithValue(mockMedicationRepository),
        ],
      );

      // Act
      await container.read(notificationNotifierProvider.future);

      // Assert
      final state = container.read(notificationNotifierProvider);
      expect(state.value!.notificationTime.hour, 9);
      expect(state.value!.notificationEnabled, true);
    });

    test('should update notification time and reschedule', () async {
      // Arrange
      final mockSettings = NotificationSettings(
        userId: 'user123',
        notificationTime: const TimeOfDay(hour: 9, minute: 0),
        notificationEnabled: true,
      );
      final doseSchedule = DoseSchedule(
        id: 'schedule1',
        dosagePlanId: 'plan1',
        scheduledDate: DateTime.now().add(const Duration(days: 1)),
        scheduledDoseMg: 0.5,
      );

      when(mockRepository.getNotificationSettings('user123'))
          .thenAnswer((_) async => mockSettings);
      when(mockRepository.saveNotificationSettings(anyOfType<NotificationSettings>()))
          .thenAnswer((_) async => {});
      when(mockScheduler.cancelAllNotifications())
          .thenAnswer((_) async => {});
      when(mockScheduler.scheduleNotifications(
        doseSchedules: anyNamedOfType<List<DoseSchedule>>('doseSchedules'),
        notificationTime: anyNamedOfType<TimeOfDay>('notificationTime'),
      )).thenAnswer((_) async => {});
      when(mockMedicationRepository.getDoseSchedules(anyOfType<String>()))
          .thenAnswer((_) async => [doseSchedule]);

      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider
              .overrideWithValue(mockRepository),
          notificationSchedulerProvider
              .overrideWithValue(mockScheduler),
          medicationRepositoryProvider
              .overrideWithValue(mockMedicationRepository),
        ],
      );

      // Act
      final notifier =
          container.read(notificationNotifierProvider.notifier);
      await notifier.updateNotificationTime(
        const TimeOfDay(hour: 21, minute: 0),
      );

      // Assert
      verify(mockRepository.saveNotificationSettings(anyOfType<NotificationSettings>())).called(1);
      verify(mockScheduler.cancelAllNotifications()).called(1);
      verify(mockScheduler.scheduleNotifications(
        doseSchedules: anyNamedOfType<List<DoseSchedule>>('doseSchedules'),
        notificationTime: anyNamedOfType<TimeOfDay>('notificationTime'),
      )).called(1);
    });

    test('should toggle notification enabled with permission check', () async {
      // Arrange
      final mockSettings = NotificationSettings(
        userId: 'user123',
        notificationTime: const TimeOfDay(hour: 9, minute: 0),
        notificationEnabled: true,
      );
      final doseSchedule = DoseSchedule(
        id: 'schedule1',
        dosagePlanId: 'plan1',
        scheduledDate: DateTime.now().add(const Duration(days: 1)),
        scheduledDoseMg: 0.5,
      );

      when(mockRepository.getNotificationSettings('user123'))
          .thenAnswer((_) async => mockSettings);
      when(mockScheduler.checkPermission())
          .thenAnswer((_) async => true);
      when(mockRepository.saveNotificationSettings(anyOfType<NotificationSettings>()))
          .thenAnswer((_) async => {});
      when(mockScheduler.cancelAllNotifications())
          .thenAnswer((_) async => {});
      when(mockScheduler.scheduleNotifications(
        doseSchedules: anyNamedOfType<List<DoseSchedule>>('doseSchedules'),
        notificationTime: anyNamedOfType<TimeOfDay>('notificationTime'),
      )).thenAnswer((_) async => {});
      when(mockMedicationRepository.getDoseSchedules(anyOfType<String>()))
          .thenAnswer((_) async => [doseSchedule]);

      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider
              .overrideWithValue(mockRepository),
          notificationSchedulerProvider
              .overrideWithValue(mockScheduler),
          medicationRepositoryProvider
              .overrideWithValue(mockMedicationRepository),
        ],
      );

      // Act
      final notifier =
          container.read(notificationNotifierProvider.notifier);
      await notifier.toggleNotificationEnabled();

      // Assert
      verify(mockScheduler.checkPermission()).called(1);
      verify(mockRepository.saveNotificationSettings(anyOfType<NotificationSettings>())).called(1);
    });

    test('should request permission when toggling without permission', () async {
      // Arrange
      final mockSettings = NotificationSettings(
        userId: 'user123',
        notificationTime: const TimeOfDay(hour: 9, minute: 0),
        notificationEnabled: true,
      );
      final doseSchedule = DoseSchedule(
        id: 'schedule1',
        dosagePlanId: 'plan1',
        scheduledDate: DateTime.now().add(const Duration(days: 1)),
        scheduledDoseMg: 0.5,
      );

      when(mockRepository.getNotificationSettings('user123'))
          .thenAnswer((_) async => mockSettings);
      when(mockScheduler.checkPermission())
          .thenAnswer((_) async => false);
      when(mockScheduler.requestPermission())
          .thenAnswer((_) async => true);
      when(mockRepository.saveNotificationSettings(anyOfType<NotificationSettings>()))
          .thenAnswer((_) async => {});
      when(mockScheduler.scheduleNotifications(
        doseSchedules: anyNamedOfType<List<DoseSchedule>>('doseSchedules'),
        notificationTime: anyNamedOfType<TimeOfDay>('notificationTime'),
      )).thenAnswer((_) async => {});
      when(mockMedicationRepository.getDoseSchedules(anyOfType<String>()))
          .thenAnswer((_) async => [doseSchedule]);

      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider
              .overrideWithValue(mockRepository),
          notificationSchedulerProvider
              .overrideWithValue(mockScheduler),
          medicationRepositoryProvider
              .overrideWithValue(mockMedicationRepository),
        ],
      );

      // Act
      final notifier =
          container.read(notificationNotifierProvider.notifier);
      await notifier.toggleNotificationEnabled();

      // Assert
      verify(mockScheduler.requestPermission()).called(1);
      verify(mockRepository.saveNotificationSettings(anyOfType<NotificationSettings>())).called(1);
    });

    test('should not enable when permission denied', () async {
      // Arrange
      final mockSettings = NotificationSettings(
        userId: 'user123',
        notificationTime: const TimeOfDay(hour: 9, minute: 0),
        notificationEnabled: true,
      );

      when(mockRepository.getNotificationSettings('user123'))
          .thenAnswer((_) async => mockSettings);
      when(mockScheduler.checkPermission())
          .thenAnswer((_) async => false);
      when(mockScheduler.requestPermission())
          .thenAnswer((_) async => false);

      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider
              .overrideWithValue(mockRepository),
          notificationSchedulerProvider
              .overrideWithValue(mockScheduler),
          medicationRepositoryProvider
              .overrideWithValue(mockMedicationRepository),
        ],
      );

      // Act
      final notifier =
          container.read(notificationNotifierProvider.notifier);
      await notifier.toggleNotificationEnabled();

      // Assert
      verifyNever(mockRepository.saveNotificationSettings(anyOfType<NotificationSettings>()));
    });

    test('should cancel all notifications when disabling', () async {
      // Arrange
      final mockSettings = NotificationSettings(
        userId: 'user123',
        notificationTime: const TimeOfDay(hour: 9, minute: 0),
        notificationEnabled: true,
      );

      when(mockRepository.getNotificationSettings('user123'))
          .thenAnswer((_) async => mockSettings);
      when(mockScheduler.checkPermission())
          .thenAnswer((_) async => true);
      when(mockRepository.saveNotificationSettings(anyOfType<NotificationSettings>()))
          .thenAnswer((_) async => {});
      when(mockScheduler.cancelAllNotifications())
          .thenAnswer((_) async => {});

      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider
              .overrideWithValue(mockRepository),
          notificationSchedulerProvider
              .overrideWithValue(mockScheduler),
          medicationRepositoryProvider
              .overrideWithValue(mockMedicationRepository),
        ],
      );

      // Act
      final notifier =
          container.read(notificationNotifierProvider.notifier);
      await notifier.toggleNotificationEnabled();

      // Assert
      verify(mockScheduler.cancelAllNotifications()).called(1);
    });
  });
}
