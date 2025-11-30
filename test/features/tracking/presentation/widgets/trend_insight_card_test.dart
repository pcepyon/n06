import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/domain/entities/trend_insight.dart';
import 'package:n06/features/tracking/presentation/widgets/trend_insight_card.dart';

void main() {
  group('TrendInsightCard', () {
    // TC-TIC-01: 요약 메시지 렌더링
    testWidgets('should render summary message', (WidgetTester tester) async {
      // Arrange
      final insight = TrendInsight(
        period: TrendPeriod.weekly,
        frequencies: [
          SymptomFrequency(symptomName: '메스꺼움', count: 10, percentageOfTotal: 50.0),
        ],
        severityTrends: const [],
        summaryMessage: '이번 주에는 증상이 개선되고 있어요! 잘하고 계세요',
        overallDirection: TrendDirection.improving,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrendInsightCard(insight: insight),
          ),
        ),
      );

      // Assert
      expect(find.text('이번 주에는 증상이 개선되고 있어요! 잘하고 계세요'), findsOneWidget);
    });

    // TC-TIC-02: 방향 아이콘 렌더링 (improving)
    testWidgets('should render improving direction icon', (WidgetTester tester) async {
      // Arrange
      final insight = TrendInsight(
        period: TrendPeriod.weekly,
        frequencies: const [],
        severityTrends: const [],
        summaryMessage: '테스트',
        overallDirection: TrendDirection.improving,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrendInsightCard(insight: insight),
          ),
        ),
      );

      // Assert
      expect(find.text('📉'), findsOneWidget); // improving icon
    });

    // TC-TIC-03: 방향 아이콘 렌더링 (worsening)
    testWidgets('should render worsening direction icon', (WidgetTester tester) async {
      // Arrange
      final insight = TrendInsight(
        period: TrendPeriod.weekly,
        frequencies: const [],
        severityTrends: const [],
        summaryMessage: '테스트',
        overallDirection: TrendDirection.worsening,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrendInsightCard(insight: insight),
          ),
        ),
      );

      // Assert
      expect(find.text('📈'), findsOneWidget); // worsening icon
    });

    // TC-TIC-04: TOP 3 증상 리스트 렌더링
    testWidgets('should render top 3 symptoms list', (WidgetTester tester) async {
      // Arrange
      final insight = TrendInsight(
        period: TrendPeriod.weekly,
        frequencies: [
          SymptomFrequency(symptomName: '메스꺼움', count: 10, percentageOfTotal: 50.0),
          SymptomFrequency(symptomName: '변비', count: 6, percentageOfTotal: 30.0),
          SymptomFrequency(symptomName: '피로', count: 4, percentageOfTotal: 20.0),
        ],
        severityTrends: const [],
        summaryMessage: '테스트',
        overallDirection: TrendDirection.stable,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrendInsightCard(insight: insight),
          ),
        ),
      );

      // Assert
      expect(find.text('많이 기록된 증상'), findsOneWidget);
      expect(find.text('메스꺼움'), findsOneWidget);
      expect(find.text('10회'), findsOneWidget);
      expect(find.text('(50%)'), findsOneWidget);
      expect(find.text('변비'), findsOneWidget);
      expect(find.text('6회'), findsOneWidget);
      expect(find.text('피로'), findsOneWidget);
      expect(find.text('4회'), findsOneWidget);
    });

    // TC-TIC-05: 주간/월간 기간 표시
    testWidgets('should display period text correctly', (WidgetTester tester) async {
      // Arrange
      final weeklyInsight = TrendInsight(
        period: TrendPeriod.weekly,
        frequencies: const [],
        severityTrends: const [],
        summaryMessage: '테스트',
        overallDirection: TrendDirection.stable,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrendInsightCard(insight: weeklyInsight),
          ),
        ),
      );

      // Assert
      expect(find.text('이번 주'), findsOneWidget);
    });

    // TC-TIC-06: onViewDetails 콜백 검증
    testWidgets('should call onViewDetails when tapped', (WidgetTester tester) async {
      // Arrange
      final insight = TrendInsight(
        period: TrendPeriod.weekly,
        frequencies: const [],
        severityTrends: const [],
        summaryMessage: '테스트',
        overallDirection: TrendDirection.stable,
      );
      bool tapped = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrendInsightCard(
              insight: insight,
              onViewDetails: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('상세 보기'));
      await tester.pumpAndSettle();

      // Assert
      expect(tapped, isTrue);
    });

    // TC-TIC-07: onViewDetails 없을 때 버튼 미표시
    testWidgets('should not show details button when onViewDetails is null', (WidgetTester tester) async {
      // Arrange
      final insight = TrendInsight(
        period: TrendPeriod.weekly,
        frequencies: const [],
        severityTrends: const [],
        summaryMessage: '테스트',
        overallDirection: TrendDirection.stable,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrendInsightCard(insight: insight),
          ),
        ),
      );

      // Assert
      expect(find.text('상세 보기'), findsNothing);
    });
  });
}
