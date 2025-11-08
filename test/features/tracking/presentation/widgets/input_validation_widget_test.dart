import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/presentation/widgets/input_validation_widget.dart';

void main() {
  group('InputValidationWidget', () {
    group('TC-IVW-01: Range Validation', () {
      testWidgets('should accept valid weight 20kg',
          (WidgetTester tester) async {
        // Arrange
        String? lastValue;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InputValidationWidget(
                fieldName: '체중',
                onChanged: (value) => lastValue = value,
                label: '체중 (kg)',
                hint: '예: 75.5',
              ),
            ),
          ),
        );

        // Act
        await tester.enterText(find.byType(TextField), '20');
        await tester.pump();

        // Assert
        expect(lastValue, '20');
        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      testWidgets('should accept valid weight 75.5kg',
          (WidgetTester tester) async {
        // Arrange
        String? lastValue;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InputValidationWidget(
                fieldName: '체중',
                onChanged: (value) => lastValue = value,
                label: '체중 (kg)',
                hint: '예: 75.5',
              ),
            ),
          ),
        );

        // Act
        await tester.enterText(find.byType(TextField), '75.5');
        await tester.pump();

        // Assert
        expect(lastValue, '75.5');
        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      testWidgets('should accept valid weight 300kg',
          (WidgetTester tester) async {
        // Arrange
        String? lastValue;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InputValidationWidget(
                fieldName: '체중',
                onChanged: (value) => lastValue = value,
                label: '체중 (kg)',
                hint: '예: 75.5',
              ),
            ),
          ),
        );

        // Act
        await tester.enterText(find.byType(TextField), '300');
        await tester.pump();

        // Assert
        expect(lastValue, '300');
        expect(find.byIcon(Icons.check), findsOneWidget);
      });
    });

    group('TC-IVW-02: Weight Below 20kg Rejection', () {
      testWidgets('should reject weight below 20kg',
          (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InputValidationWidget(
                fieldName: '체중',
                onChanged: (_) {},
                label: '체중 (kg)',
                hint: '예: 75.5',
              ),
            ),
          ),
        );

        // Act
        await tester.enterText(find.byType(TextField), '15.0');
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.close), findsOneWidget);
        expect(find.text('20kg 이상이어야 합니다'), findsOneWidget);
      });

      testWidgets('should reject weight 19.9kg',
          (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InputValidationWidget(
                fieldName: '체중',
                onChanged: (_) {},
                label: '체중 (kg)',
                hint: '예: 75.5',
              ),
            ),
          ),
        );

        // Act
        await tester.enterText(find.byType(TextField), '19.9');
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.close), findsOneWidget);
        expect(find.text('20kg 이상이어야 합니다'), findsOneWidget);
      });
    });

    group('TC-IVW-03: Weight Above 300kg Rejection', () {
      testWidgets('should reject weight above 300kg',
          (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InputValidationWidget(
                fieldName: '체중',
                onChanged: (_) {},
                label: '체중 (kg)',
                hint: '예: 75.5',
              ),
            ),
          ),
        );

        // Act
        await tester.enterText(find.byType(TextField), '350.0');
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.close), findsOneWidget);
        expect(find.text('300kg 이하여야 합니다'), findsOneWidget);
      });

      testWidgets('should reject weight 300.1kg',
          (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InputValidationWidget(
                fieldName: '체중',
                onChanged: (_) {},
                label: '체중 (kg)',
                hint: '예: 75.5',
              ),
            ),
          ),
        );

        // Act
        await tester.enterText(find.byType(TextField), '300.1');
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.close), findsOneWidget);
        expect(find.text('300kg 이하여야 합니다'), findsOneWidget);
      });
    });

    group('TC-IVW-04: Zero Weight Rejection', () {
      testWidgets('should reject zero weight',
          (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InputValidationWidget(
                fieldName: '체중',
                onChanged: (_) {},
                label: '체중 (kg)',
                hint: '예: 75.5',
              ),
            ),
          ),
        );

        // Act
        await tester.enterText(find.byType(TextField), '0');
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.close), findsOneWidget);
      });
    });

    group('TC-IVW-05: Negative Weight Rejection', () {
      testWidgets('should reject negative weight',
          (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InputValidationWidget(
                fieldName: '체중',
                onChanged: (_) {},
                label: '체중 (kg)',
                hint: '예: 75.5',
              ),
            ),
          ),
        );

        // Act
        await tester.enterText(find.byType(TextField), '-50');
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.close), findsOneWidget);
      });
    });

    group('TC-IVW-06: Decimal Input Support', () {
      testWidgets('should accept decimal numbers',
          (WidgetTester tester) async {
        // Arrange
        String? lastValue;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InputValidationWidget(
                fieldName: '체중',
                onChanged: (value) => lastValue = value,
                label: '체중 (kg)',
                hint: '예: 75.5',
              ),
            ),
          ),
        );

        // Act
        await tester.enterText(find.byType(TextField), '75.5');
        await tester.pump();

        // Assert
        expect(lastValue, '75.5');
        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      testWidgets('should accept integer numbers',
          (WidgetTester tester) async {
        // Arrange
        String? lastValue;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InputValidationWidget(
                fieldName: '체중',
                onChanged: (value) => lastValue = value,
                label: '체중 (kg)',
                hint: '예: 75.5',
              ),
            ),
          ),
        );

        // Act
        await tester.enterText(find.byType(TextField), '75');
        await tester.pump();

        // Assert
        expect(lastValue, '75');
        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      testWidgets('should accept numbers with multiple decimal places',
          (WidgetTester tester) async {
        // Arrange
        String? lastValue;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InputValidationWidget(
                fieldName: '체중',
                onChanged: (value) => lastValue = value,
                label: '체중 (kg)',
                hint: '예: 75.5',
              ),
            ),
          ),
        );

        // Act
        await tester.enterText(find.byType(TextField), '75.25');
        await tester.pump();

        // Assert
        expect(lastValue, '75.25');
        expect(find.byIcon(Icons.check), findsOneWidget);
      });
    });

    group('TC-IVW-07: Real-Time Validation', () {
      testWidgets('should validate on each character input',
          (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InputValidationWidget(
                fieldName: '체중',
                onChanged: (_) {},
                label: '체중 (kg)',
                hint: '예: 75.5',
              ),
            ),
          ),
        );

        // Act - first character
        await tester.enterText(find.byType(TextField), '7');
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.close), findsOneWidget);
      });

      testWidgets('should update validation state when value changes',
          (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InputValidationWidget(
                fieldName: '체중',
                onChanged: (_) {},
                label: '체중 (kg)',
                hint: '예: 75.5',
              ),
            ),
          ),
        );

        // Act - invalid then valid
        final textField = find.byType(TextField);
        await tester.enterText(textField, '15');
        await tester.pump();

        // Assert invalid
        expect(find.byIcon(Icons.close), findsOneWidget);

        // Act - clear and enter valid
        await tester.enterText(textField, '75');
        await tester.pump();

        // Assert valid
        expect(find.byIcon(Icons.check), findsOneWidget);
      });
    });

    group('TC-IVW-08: Error Message Display', () {
      testWidgets('should show error message for non-numeric input',
          (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InputValidationWidget(
                fieldName: '체중',
                onChanged: (_) {},
                label: '체중 (kg)',
                hint: '예: 75.5',
              ),
            ),
          ),
        );

        // Act
        await tester.enterText(find.byType(TextField), 'abc');
        await tester.pump();

        // Assert
        expect(find.text('숫자를 입력하세요'), findsOneWidget);
      });

      testWidgets('should show correct error for below minimum',
          (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InputValidationWidget(
                fieldName: '체중',
                onChanged: (_) {},
                label: '체중 (kg)',
                hint: '예: 75.5',
              ),
            ),
          ),
        );

        // Act
        await tester.enterText(find.byType(TextField), '10');
        await tester.pump();

        // Assert
        expect(find.text('20kg 이상이어야 합니다'), findsOneWidget);
      });

      testWidgets('should show correct error for above maximum',
          (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InputValidationWidget(
                fieldName: '체중',
                onChanged: (_) {},
                label: '체중 (kg)',
                hint: '예: 75.5',
              ),
            ),
          ),
        );

        // Act
        await tester.enterText(find.byType(TextField), '400');
        await tester.pump();

        // Assert
        expect(find.text('300kg 이하여야 합니다'), findsOneWidget);
      });
    });

    group('TC-IVW-09: Focus Changes', () {
      testWidgets('should handle focus changes correctly',
          (WidgetTester tester) async {
        // Arrange
        String? lastValue;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InputValidationWidget(
                fieldName: '체중',
                onChanged: (value) => lastValue = value,
                label: '체중 (kg)',
                hint: '예: 75.5',
              ),
            ),
          ),
        );

        // Act - enter text and lose focus
        await tester.enterText(find.byType(TextField), '75');
        await tester.pump();

        // Assert
        expect(lastValue, '75');
        expect(find.byIcon(Icons.check), findsOneWidget);
      });
    });

    group('TC-IVW-10: Clear Input', () {
      testWidgets('should show no error for empty input',
          (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InputValidationWidget(
                fieldName: '체중',
                onChanged: (_) {},
                label: '체중 (kg)',
                hint: '예: 75.5',
              ),
            ),
          ),
        );

        // Act
        await tester.enterText(find.byType(TextField), '');
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.close), findsNothing);
      });

      testWidgets('should clear validation icon when input is cleared',
          (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InputValidationWidget(
                fieldName: '체중',
                onChanged: (_) {},
                label: '체중 (kg)',
                hint: '예: 75.5',
              ),
            ),
          ),
        );

        // Act
        final textField = find.byType(TextField);
        await tester.enterText(textField, '75');
        await tester.pump();

        // Assert check icon exists
        expect(find.byIcon(Icons.check), findsOneWidget);

        // Act - clear
        await tester.enterText(textField, '');
        await tester.pump();

        // Assert icon removed
        expect(find.byIcon(Icons.check), findsNothing);
      });
    });
  });
}
