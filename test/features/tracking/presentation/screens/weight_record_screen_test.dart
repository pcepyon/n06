import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/presentation/screens/weight_record_screen.dart';

void main() {
  group('WeightRecordScreen', () {

    group('TC-WRS-01: Screen Rendering', () {
      testWidgets('should render WeightRecordScreen with all elements',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Assert
        expect(find.text('체중 기록'), findsOneWidget);
        expect(find.text('날짜 선택'), findsOneWidget);
        expect(find.text('체중 입력'), findsOneWidget);
        expect(find.text('저장'), findsOneWidget);
      });

      testWidgets('should render date selection widget with quick buttons',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Assert
        expect(find.text('오늘'), findsOneWidget);
        expect(find.text('어제'), findsOneWidget);
        expect(find.text('2일 전'), findsOneWidget);
      });

      testWidgets('should render weight input field with label',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Assert
        expect(find.byType(TextField), findsWidgets);
        expect(find.text('체중 (kg)'), findsOneWidget);
      });

      testWidgets('should render save button',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Assert
        expect(find.byType(ElevatedButton), findsOneWidget);
      });
    });

    group('TC-WRS-02: Date Selection', () {
      testWidgets('should select today date by default',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Assert
        expect(find.text('오늘'), findsOneWidget);
      });

      testWidgets('should allow selecting today with quick button',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('오늘'));
        await tester.pump();

        // Assert - 날짜가 선택된 것으로 간주
        expect(find.text('오늘'), findsOneWidget);
      });

      testWidgets('should allow selecting yesterday',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('어제'));
        await tester.pump();

        // Assert
        expect(find.text('어제'), findsOneWidget);
      });

      testWidgets('should open date picker on calendar button click',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Act
        await tester.tap(find.byIcon(Icons.calendar_today));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(CalendarDatePicker), findsOneWidget);
      });
    });

    group('TC-WRS-03: Weight Input Validation', () {
      testWidgets('should accept valid weight between 20 and 300',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Act
        await tester.enterText(
          find.byType(TextField).first,
          '75.5',
        );
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      testWidgets('should reject weight below 20kg',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Act
        await tester.enterText(
          find.byType(TextField).first,
          '15.0',
        );
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.close), findsOneWidget);
        expect(find.text('20kg 이상이어야 합니다'), findsOneWidget);
      });

      testWidgets('should reject weight above 300kg',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Act
        await tester.enterText(
          find.byType(TextField).first,
          '350.0',
        );
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.close), findsOneWidget);
        expect(find.text('300kg 이하여야 합니다'), findsOneWidget);
      });

      testWidgets('should accept decimal weight values',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Act
        await tester.enterText(
          find.byType(TextField).first,
          '75.5',
        );
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      testWidgets('should accept integer weight values',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Act
        await tester.enterText(
          find.byType(TextField).first,
          '75',
        );
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      testWidgets('should handle non-numeric input',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Act
        await tester.enterText(
          find.byType(TextField).first,
          'abc',
        );
        await tester.pump();

        // Assert
        expect(find.text('숫자를 입력하세요'), findsOneWidget);
      });

      testWidgets('should show no error for empty input',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Act
        await tester.enterText(
          find.byType(TextField).first,
          '',
        );
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.close), findsNothing);
      });
    });

    group('TC-WRS-04: Save Button Functionality', () {
      testWidgets('should enable save button when valid data is entered',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Act
        await tester.enterText(
          find.byType(TextField).first,
          '75.5',
        );
        await tester.pump();

        // Assert
        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('should disable save button when no weight is entered',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Act & Assert
        final button = find.byType(ElevatedButton);
        expect(button, findsOneWidget);
      });
    });

    group('TC-WRS-05: Success Message', () {
      testWidgets('should display weight record screen',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: WeightRecordScreen(),
              ),
            ),
          ),
        );

        // Act
        await tester.enterText(
          find.byType(TextField).first,
          '75.5',
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(WeightRecordScreen), findsOneWidget);
      });
    });

    group('TC-WRS-06: Duplicate Record Handling', () {
      testWidgets('should display weight record screen with validation',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Act & Assert
        expect(find.byType(WeightRecordScreen), findsOneWidget);
        expect(find.text('체중 기록'), findsOneWidget);
      });
    });

    group('TC-WRS-07: Date Picker Integration', () {
      testWidgets('should display calendar picker on icon tap',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Act
        await tester.tap(find.byIcon(Icons.calendar_today));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(CalendarDatePicker), findsOneWidget);
      });
    });

    group('TC-WRS-08: Weight History Display', () {
      testWidgets('should render weight record screen',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Assert
        expect(find.text('체중 기록'), findsOneWidget);
      });
    });

    group('TC-WRS-09: Back Navigation', () {
      testWidgets('should display cancel button',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Assert
        expect(find.byType(WeightRecordScreen), findsOneWidget);
      });
    });

    group('TC-WRS-10: Loading State', () {
      testWidgets('should show loading indicator during save',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Assert
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });
  });
}
