import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/onboarding/domain/entities/user_profile.dart';
import 'package:n06/features/onboarding/domain/value_objects/weight.dart';
import 'package:n06/features/profile/presentation/widgets/profile_edit_form.dart';

void main() {
  group('ProfileEditForm - UserName Tests', () {
    testWidgets(
      'should initialize name field with userName when it is not null',
      (WidgetTester tester) async {
        // Arrange
        final profile = UserProfile(
          userId: 'test@example.com',
          userName: '홍길동',
          targetWeight: Weight.create(70.0),
          currentWeight: Weight.create(80.0),
          targetPeriodWeeks: 12,
          weeklyLossGoalKg: 0.83,
        );

        UserProfile? changedProfile;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProfileEditForm(
                profile: profile,
                onProfileChanged: (p) => changedProfile = p,
              ),
            ),
          ),
        );

        // Assert: Name field should show userName, not userId
        final nameField = find.widgetWithText(TextField, '홍길동');
        expect(nameField, findsOneWidget);
        
        // Should NOT show userId
        final userIdField = find.widgetWithText(TextField, 'test@example.com');
        expect(userIdField, findsNothing);
      },
    );

    testWidgets(
      'should initialize name field with empty string when userName is null',
      (WidgetTester tester) async {
        // Arrange
        final profile = UserProfile(
          userId: 'test@example.com',
          userName: null, // null userName
          targetWeight: Weight.create(70.0),
          currentWeight: Weight.create(80.0),
          targetPeriodWeeks: 12,
          weeklyLossGoalKg: 0.83,
        );

        UserProfile? changedProfile;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProfileEditForm(
                profile: profile,
                onProfileChanged: (p) => changedProfile = p,
              ),
            ),
          ),
        );

        // Assert: Name field should be empty
        final nameField = tester.widget<TextField>(
          find.widgetWithText(TextField, '이름').first,
        );
        expect(nameField.controller?.text, isEmpty);
        
        // Should NOT show userId
        final userIdField = find.text('test@example.com');
        expect(userIdField, findsNothing);
      },
    );

    testWidgets(
      'should update userName when name field is changed',
      (WidgetTester tester) async {
        // Arrange
        final profile = UserProfile(
          userId: 'test@example.com',
          userName: '홍길동',
          targetWeight: Weight.create(70.0),
          currentWeight: Weight.create(80.0),
          targetPeriodWeeks: 12,
          weeklyLossGoalKg: 0.83,
        );

        UserProfile? changedProfile;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProfileEditForm(
                profile: profile,
                onProfileChanged: (p) => changedProfile = p,
              ),
            ),
          ),
        );

        // Act: Change name
        final nameField = find.widgetWithText(TextField, '홍길동');
        await tester.enterText(nameField, '김철수');
        await tester.pump();

        // Assert: changedProfile should have new userName
        expect(changedProfile, isNotNull);
        expect(changedProfile!.userName, equals('김철수'));
      },
    );

    testWidgets(
      'should preserve userName when other fields are changed',
      (WidgetTester tester) async {
        // Arrange
        final profile = UserProfile(
          userId: 'test@example.com',
          userName: '홍길동',
          targetWeight: Weight.create(70.0),
          currentWeight: Weight.create(80.0),
          targetPeriodWeeks: 12,
          weeklyLossGoalKg: 0.83,
        );

        UserProfile? changedProfile;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProfileEditForm(
                profile: profile,
                onProfileChanged: (p) => changedProfile = p,
              ),
            ),
          ),
        );

        // Act: Change target weight (not name)
        final targetWeightField = find.widgetWithText(TextField, '목표 체중 (kg)');
        await tester.enterText(targetWeightField, '65.0');
        await tester.pump();

        // Assert: userName should be preserved
        expect(changedProfile, isNotNull);
        expect(changedProfile!.userName, equals('홍길동'));
        expect(changedProfile!.targetWeight.value, equals(65.0));
      },
    );
  });
}
