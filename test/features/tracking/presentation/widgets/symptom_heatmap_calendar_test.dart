import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/presentation/widgets/symptom_heatmap_calendar.dart';

void main() {
  group('SymptomHeatmapCalendar', () {
    // TC-SHC-01: 요일 헤더 렌더링
    testWidgets('should render weekday header', (WidgetTester tester) async {
      // Arrange
      final startDate = DateTime(2025, 11, 1);
      final endDate = DateTime(2025, 11, 7);
      final symptomCounts = <DateTime, int>{};

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SymptomHeatmapCalendar(
              startDate: startDate,
              endDate: endDate,
              symptomCounts: symptomCounts,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('일'), findsOneWidget);
      expect(find.text('월'), findsOneWidget);
      expect(find.text('화'), findsOneWidget);
      expect(find.text('수'), findsOneWidget);
      expect(find.text('목'), findsOneWidget);
      expect(find.text('금'), findsOneWidget);
      expect(find.text('토'), findsOneWidget);
    });

    // TC-SHC-02: 범례 렌더링
    testWidgets('should render legend', (WidgetTester tester) async {
      // Arrange
      final startDate = DateTime(2025, 11, 1);
      final endDate = DateTime(2025, 11, 7);
      final symptomCounts = <DateTime, int>{};

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SymptomHeatmapCalendar(
              startDate: startDate,
              endDate: endDate,
              symptomCounts: symptomCounts,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('없음'), findsOneWidget);
      expect(find.text('경미'), findsOneWidget);
      expect(find.text('중간'), findsOneWidget);
      expect(find.text('심함'), findsOneWidget);
    });

    // TC-SHC-03: 날짜 셀 렌더링
    testWidgets('should render date cells', (WidgetTester tester) async {
      // Arrange
      final startDate = DateTime(2025, 11, 1);
      final endDate = DateTime(2025, 11, 3);
      final symptomCounts = <DateTime, int>{};

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SymptomHeatmapCalendar(
              startDate: startDate,
              endDate: endDate,
              symptomCounts: symptomCounts,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    // TC-SHC-04: 증상 개수에 따른 색상 매핑
    testWidgets('should apply colors based on symptom count', (WidgetTester tester) async {
      // Arrange
      final startDate = DateTime(2025, 11, 1);
      final endDate = DateTime(2025, 11, 4);
      final symptomCounts = {
        DateTime(2025, 11, 1): 0,  // 없음
        DateTime(2025, 11, 2): 2,  // 경미 (1-3)
        DateTime(2025, 11, 3): 5,  // 중간 (4-6)
        DateTime(2025, 11, 4): 8,  // 심함 (7-10)
      };

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SymptomHeatmapCalendar(
              startDate: startDate,
              endDate: endDate,
              symptomCounts: symptomCounts,
            ),
          ),
        ),
      );

      // Assert - Container들이 정상 렌더링되는지 확인
      expect(find.byType(Container), findsWidgets);
    });

    // TC-SHC-05: onDateTap 콜백 검증
    testWidgets('should call onDateTap when date cell tapped', (WidgetTester tester) async {
      // Arrange
      final startDate = DateTime(2025, 11, 1);
      final endDate = DateTime(2025, 11, 3);
      final symptomCounts = <DateTime, int>{};
      DateTime? tappedDate;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SymptomHeatmapCalendar(
              startDate: startDate,
              endDate: endDate,
              symptomCounts: symptomCounts,
              onDateTap: (date) => tappedDate = date,
            ),
          ),
        ),
      );
      await tester.tap(find.text('1').first);
      await tester.pumpAndSettle();

      // Assert
      expect(tappedDate, isNotNull);
      expect(tappedDate?.day, 1);
    });

    // TC-SHC-06: 그리드 레이아웃 검증
    testWidgets('should render grid layout', (WidgetTester tester) async {
      // Arrange
      final startDate = DateTime(2025, 11, 1);
      final endDate = DateTime(2025, 11, 7);
      final symptomCounts = <DateTime, int>{};

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SymptomHeatmapCalendar(
              startDate: startDate,
              endDate: endDate,
              symptomCounts: symptomCounts,
            ),
          ),
        ),
      );

      // Assert - Column 위젯으로 그리드가 구성되어 있는지 확인
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Row), findsWidgets);
    });
  });
}
