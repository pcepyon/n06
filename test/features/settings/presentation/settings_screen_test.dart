import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/settings/presentation/widgets/settings_menu_item_improved.dart';

void main() {
  group('SettingsScreen Widget Tests', () {
    testWidgets('SettingsMenuItemImproved should display title and subtitle',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsMenuItemImproved(
              title: 'Test Title',
              subtitle: 'Test Subtitle',
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Subtitle'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('SettingsMenuItemImproved should be tappable', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsMenuItemImproved(
              title: 'Test Title',
              subtitle: 'Test Subtitle',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(InkWell));

      // Assert
      expect(tapped, isTrue);
    });
  });
}
