import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/presentation/dialogs/weight_edit_dialog.dart';

void main() {
  group('WeightEditDialog', () {
    late WeightLog currentLog;

    setUp(() {
      currentLog = WeightLog(
        id: 'log1',
        userId: 'user123',
        logDate: DateTime(2025, 1, 15),
        weightKg: 75.5,
        createdAt: DateTime.now(),
      );
    });

    group('TC-WED-01: Display Current Weight', () {
      testWidgets('should display current weight value', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: WeightEditDialog(
                  currentLog: currentLog,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('75.5'), findsWidgets);
        expect(find.text('체중 수정'), findsOneWidget);
      });

      testWidgets('should show current weight in text field', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: WeightEditDialog(
                  currentLog: currentLog,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        // Assert
        final textField = find.byType(TextField);
        expect(textField, findsWidgets);
      });

      testWidgets('should display date when provided', (WidgetTester tester) async {
        // Arrange
        final logWithDate = WeightLog(
          id: 'log1',
          userId: 'user123',
          logDate: DateTime(2025, 1, 15),
          weightKg: 75.5,
          createdAt: DateTime.now(),
        );

        // Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: WeightEditDialog(
                  currentLog: logWithDate,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        // Assert
        expect(find.textContaining('2025'), findsOneWidget);
      });
    });

    group('TC-WED-02: Update Weight and Save', () {
      testWidgets('should allow editing weight value', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: WeightEditDialog(
                  currentLog: currentLog,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        // Find and edit weight field
        final textFields = find.byType(TextField);
        expect(textFields, findsWidgets);

        // Enter new weight
        await tester.enterText(textFields.first, '73.5');
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('73.5'), findsOneWidget);
      });

      testWidgets('should display save button', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: WeightEditDialog(
                  currentLog: currentLog,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('저장'), findsOneWidget);
      });

      testWidgets('should accept valid weight and enable save', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: WeightEditDialog(
                  currentLog: currentLog,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        final textField = find.byType(TextField).first;
        await tester.enterText(textField, '72.5');
        await tester.pumpAndSettle();

        // Assert save button exists
        expect(find.text('저장'), findsOneWidget);
      });
    });

    group('TC-WED-03: Show Validation Error', () {
      testWidgets('should show error for weight below 20kg', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: WeightEditDialog(
                  currentLog: currentLog,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        // Enter invalid weight
        final textField = find.byType(TextField).first;
        await tester.enterText(textField, '15');
        await tester.pumpAndSettle();

        // Assert - error should be shown
        expect(find.textContaining('20'), findsOneWidget);
      });

      testWidgets('should show error for weight above 300kg', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: WeightEditDialog(
                  currentLog: currentLog,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        // Enter invalid weight
        final textField = find.byType(TextField).first;
        await tester.enterText(textField, '350');
        await tester.pumpAndSettle();

        // Assert
        expect(find.textContaining('300'), findsOneWidget);
      });

      testWidgets('should show error for negative weight', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: WeightEditDialog(
                  currentLog: currentLog,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        // Enter negative weight
        final textField = find.byType(TextField).first;
        await tester.enterText(textField, '-5');
        await tester.pumpAndSettle();

        // Assert
        expect(find.textContaining('양수'), findsOneWidget);
      });

      testWidgets('should show warning for borderline weight', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: WeightEditDialog(
                  currentLog: currentLog,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        // Enter borderline weight (very low but within 20-300 range)
        final textField = find.byType(TextField).first;
        await tester.enterText(textField, '25');
        await tester.pumpAndSettle();

        // Assert - should show warning
        expect(find.textContaining('비정상'), findsOneWidget);
      });

      testWidgets('should validate weight in real-time', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: WeightEditDialog(
                  currentLog: currentLog,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        // Enter weight and check validation
        final textField = find.byType(TextField).first;
        await tester.enterText(textField, '500');
        await tester.pump();

        // Assert error appears in real-time
        expect(find.textContaining('300'), findsOneWidget);
      });
    });
  });
}
