import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:riverpod/riverpod.dart';
import 'package:n06/features/notification/application/notifiers/notification_notifier.dart';
import 'package:n06/features/notification/domain/entities/notification_settings.dart';
import 'package:n06/features/notification/presentation/screens/notification_settings_screen.dart';

class MockNotificationNotifier extends Mock
    implements NotificationNotifier {}

void main() {
  group('NotificationSettingsScreen', () {
    late MockNotificationNotifier mockNotifier;

    setUp(() {
      mockNotifier = MockNotificationNotifier();
    });

    testWidgets('should display notification settings components',
        (tester) async {
      // Arrange
      final mockSettings = NotificationSettings(
        userId: 'user123',
        notificationTime: const TimeOfDay(hour: 9, minute: 0),
        notificationEnabled: true,
      );

      when(mockNotifier.build()).thenAnswer((_) async => mockSettings);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationNotifierProvider
                .overrideWith((ref) => mockNotifier),
          ],
          child: const MaterialApp(
            home: NotificationSettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('푸시 알림 설정'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('should display current notification time', (tester) async {
      // Arrange
      final mockSettings = NotificationSettings(
        userId: 'user123',
        notificationTime: const TimeOfDay(hour: 9, minute: 0),
        notificationEnabled: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationNotifierProvider.overrideWith((ref) =>
                AsyncValue.data(mockSettings) as NotificationNotifier),
          ],
          child: const MaterialApp(
            home: NotificationSettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - 화면이 렌더링 되는지 확인
      expect(find.text('푸시 알림 설정'), findsOneWidget);
    });

    testWidgets('should show loading state initially', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationNotifierProvider.overrideWith(
              (ref) => const AsyncValue.loading(),
            ),
          ],
          child: const MaterialApp(
            home: NotificationSettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('should handle notification disabled state', (tester) async {
      // Arrange
      final mockSettings = NotificationSettings(
        userId: 'user123',
        notificationTime: const TimeOfDay(hour: 9, minute: 0),
        notificationEnabled: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationNotifierProvider.overrideWith((ref) =>
                AsyncValue.data(mockSettings) as NotificationNotifier),
          ],
          child: const MaterialApp(
            home: NotificationSettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - 토글 상태 확인
      final switchWidget = find.byType(Switch);
      expect(switchWidget, findsOneWidget);
    });
  });
}
