import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/authentication/domain/entities/user.dart';
import 'package:n06/features/onboarding/domain/entities/user_profile.dart';
import 'package:n06/features/onboarding/domain/value_objects/weight.dart';
import 'package:n06/features/profile/application/notifiers/profile_notifier.dart';
import 'package:n06/features/settings/presentation/screens/settings_screen.dart';

void main() {
  group('SettingsScreen - UserName Display', () {
    testWidgets(
      'should display userName when it is not null',
      (WidgetTester tester) async {
        // Arrange: Create profile with userName
        final profile = UserProfile(
          userId: 'test@example.com',
          userName: '홍길동',
          targetWeight: Weight.create(70.0),
          currentWeight: Weight.create(80.0),
          targetPeriodWeeks: 12,
          weeklyLossGoalKg: 0.83,
        );

        final user = User(
          id: 'test-id',
          oauthProvider: 'email',
          oauthUserId: 'test@example.com',
          name: 'Test User',
          email: 'test@example.com',
          lastLoginAt: DateTime.now(),
        );

        final container = ProviderContainer(
          overrides: [
            authNotifierProvider.overrideWith(
              () => _FakeAuthNotifier(user),
            ),
            profileNotifierProvider.overrideWith(
              () => _FakeProfileNotifier(profile),
            ),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: SettingsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert: Should display userName, not email
        expect(find.text('홍길동'), findsOneWidget);
        expect(find.text('test@example.com'), findsNothing);
      },
    );

    testWidgets(
      'should display email prefix when userName is null',
      (WidgetTester tester) async {
        // Arrange: Create profile without userName
        final profile = UserProfile(
          userId: 'test@example.com',
          userName: null, // userName is null
          targetWeight: Weight.create(70.0),
          currentWeight: Weight.create(80.0),
          targetPeriodWeeks: 12,
          weeklyLossGoalKg: 0.83,
        );

        final user = User(
          id: 'test-id',
          oauthProvider: 'email',
          oauthUserId: 'test@example.com',
          name: 'Test User',
          email: 'test@example.com',
          lastLoginAt: DateTime.now(),
        );

        final container = ProviderContainer(
          overrides: [
            authNotifierProvider.overrideWith(
              () => _FakeAuthNotifier(user),
            ),
            profileNotifierProvider.overrideWith(
              () => _FakeProfileNotifier(profile),
            ),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: SettingsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert: Should display email prefix (test)
        expect(find.text('test'), findsOneWidget);
        expect(find.text('test@example.com'), findsNothing);
      },
    );
  });
}

// Fake AuthNotifier for testing
class _FakeAuthNotifier extends AuthNotifier {
  final User? _user;
  _FakeAuthNotifier(this._user);

  @override
  Future<User?> build() async => _user;
}

// Fake ProfileNotifier for testing
class _FakeProfileNotifier extends ProfileNotifier {
  final UserProfile? _profile;
  _FakeProfileNotifier(this._profile);

  @override
  Future<UserProfile?> build() async => _profile;
}
