import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/presentation/widgets/input_validation_widget.dart';

void main() {
  group('InputValidationWidget', () {
    group('TC-IVW-01: Range Validation', () {
      testWidgets('should accept valid weight between 20 and 300',
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
        await tester.enterText(
          find.byType(TextField),
          '75.5',
        );
        await tester.pump();

        // Assert
        expect(lastValue, '75.5');
        expect(find.byIcon(Icons.check), findsOneWidget);
      });

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
        await tester.enterText(
          find.byType(TextField),
          '15.0',
        );
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.close), findsOneWidget);
        expect(find.text('20kg 이상이어야 합니다'), findsOneWidget);
      });

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
        await tester.enterText(
          find.byType(TextField),
          '350.0',
        );
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.close), findsOneWidget);
        expect(find.text('300kg 이하여야 합니다'), findsOneWidget);
      });
    });

    group('TC-IVW-02: Error Message Display', () {
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
        await tester.enterText(
          find.byType(TextField),
          'abc',
        );
        await tester.pump();

        // Assert
        expect(find.text('숫자를 입력하세요'), findsOneWidget);
      });

      testWidgets('should show no error message for empty input',
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

        // Act & Assert
        // 빈 입력에는 에러 메시지가 표시되지 않음
        expect(find.byType(Text), findsNothing);
      });
    });

    group('TC-IVW-03: Decimal Input Support', () {
      testWidgets('should accept decimal numbers', (WidgetTester tester) async {
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
        await tester.enterText(
          find.byType(TextField),
          '75.5',
        );
        await tester.pump();

        // Assert
        expect(lastValue, '75.5');
        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      testWidgets('should accept integer numbers', (WidgetTester tester) async {
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
        await tester.enterText(
          find.byType(TextField),
          '75',
        );
        await tester.pump();

        // Assert
        expect(lastValue, '75');
        expect(find.byIcon(Icons.check), findsOneWidget);
      });
    });
  });
}
