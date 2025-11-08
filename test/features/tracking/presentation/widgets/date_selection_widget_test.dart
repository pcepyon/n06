import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/presentation/widgets/date_selection_widget.dart';

void main() {
  group('DateSelectionWidget', () {
    group('TC-DSW-01: Quick Button Rendering', () {
      testWidgets('should render quick date buttons',
          (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DateSelectionWidget(
                onDateSelected: (_) {},
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('오늘'), findsOneWidget);
        expect(find.text('어제'), findsOneWidget);
        expect(find.text('2일 전'), findsOneWidget);
      });

      testWidgets('should render calendar button', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DateSelectionWidget(
                onDateSelected: (_) {},
              ),
            ),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      });
    });

    group('TC-DSW-02: Quick Button Click', () {
      testWidgets('should select today on button tap',
          (WidgetTester tester) async {
        // Arrange
        DateTime? selectedDate;
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DateSelectionWidget(
                onDateSelected: (date) => selectedDate = date,
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('오늘'));
        await tester.pump();

        // Assert
        expect(selectedDate, today);
      });

      testWidgets('should select yesterday on button tap',
          (WidgetTester tester) async {
        // Arrange
        DateTime? selectedDate;
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final expectedDate = DateTime(yesterday.year, yesterday.month, yesterday.day);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DateSelectionWidget(
                onDateSelected: (date) => selectedDate = date,
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('어제'));
        await tester.pump();

        // Assert
        expect(selectedDate, expectedDate);
      });

      testWidgets('should select 2 days ago on button tap',
          (WidgetTester tester) async {
        // Arrange
        DateTime? selectedDate;
        final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
        final expectedDate = DateTime(twoDaysAgo.year, twoDaysAgo.month, twoDaysAgo.day);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DateSelectionWidget(
                onDateSelected: (date) => selectedDate = date,
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('2일 전'));
        await tester.pump();

        // Assert
        expect(selectedDate, expectedDate);
      });
    });

    group('TC-DSW-03: Calendar Date Selection', () {
      testWidgets('should display calendar when calendar button is tapped',
          (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DateSelectionWidget(
                onDateSelected: (_) {},
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.byIcon(Icons.calendar_today));
        await tester.pumpAndSettle();

        // Assert - CalendarDatePicker가 표시됨
        expect(find.byType(CalendarDatePicker), findsOneWidget);
      });
    });

    group('TC-DSW-04: Future Date Restriction', () {
      testWidgets('should disable future dates in calendar',
          (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DateSelectionWidget(
                onDateSelected: (_) {},
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.byIcon(Icons.calendar_today));
        await tester.pumpAndSettle();

        // Assert - Calendar가 표시되고 미래 날짜는 비활성화됨
        final calendarWidget = tester.widget<CalendarDatePicker>(
          find.byType(CalendarDatePicker),
        );

        // lastDate가 오늘 또는 그 이전이어야 함
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        expect(calendarWidget.lastDate.isAtSameMomentAs(today) ||
            calendarWidget.lastDate.isBefore(today), true);
      });
    });
  });
}
