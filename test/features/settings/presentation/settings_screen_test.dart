import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/settings/presentation/widgets/settings_menu_item.dart';

void main() {
  group('SettingsScreen Widget Tests', () {
    testWidgets('SettingsMenuItem should display title and subtitle',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsMenuItem(
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

    testWidgets('SettingsMenuItem should be tappable', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsMenuItem(
              title: 'Test Title',
              subtitle: 'Test Subtitle',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(ListTile));

      // Assert
      expect(tapped, isTrue);
    });
  });
}
