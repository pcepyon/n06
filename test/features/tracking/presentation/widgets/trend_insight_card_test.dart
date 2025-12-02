import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/domain/entities/trend_insight.dart';
import 'package:n06/features/tracking/presentation/widgets/trend_insight_card.dart';

void main() {
  group('TrendInsightCard', () {
    TrendInsight _createTestInsight({
      TrendDirection direction = TrendDirection.stable,
      List<QuestionTrend> questionTrends = const [],
      String summaryMessage = '테스트 메시지',
      int redFlagCount = 0,
      int consecutiveDays = 5,
      double completionRate = 70.0,
    }) {
      return TrendInsight(
        period: TrendPeriod.weekly,
        dailyConditions: const [],
        questionTrends: questionTrends,
        patternInsight: const WeeklyPatternInsight(
          hasPostInjectionPattern: false,
          recommendations: [],
        ),
        overallDirection: direction,
        summaryMessage: summaryMessage,
        redFlagCount: redFlagCount,
        consecutiveDays: consecutiveDays,
        completionRate: completionRate,
      );
    }

    // TC-TIC-01: 요약 메시지 렌더링
    testWidgets('should render summary message', (WidgetTester tester) async {
      final insight = _createTestInsight(
        summaryMessage: '이번 주 컨디션이 좋아지고 있어요!',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TrendInsightCard(insight: insight),
            ),
          ),
        ),
      );

      expect(find.text('이번 주 컨디션이 좋아지고 있어요!'), findsOneWidget);
    });

    // TC-TIC-02: 방향 아이콘 렌더링 (improving)
    testWidgets('should render improving direction icon', (WidgetTester tester) async {
      final insight = _createTestInsight(
        direction: TrendDirection.improving,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TrendInsightCard(insight: insight),
            ),
          ),
        ),
      );

      expect(find.text('📈'), findsOneWidget);
      expect(find.text('좋아지고 있어요'), findsOneWidget);
    });

    // TC-TIC-03: 방향 아이콘 렌더링 (worsening)
    testWidgets('should render worsening direction icon', (WidgetTester tester) async {
      final insight = _createTestInsight(
        direction: TrendDirection.worsening,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TrendInsightCard(insight: insight),
            ),
          ),
        ),
      );

      expect(find.text('📉'), findsOneWidget);
      expect(find.text('관리가 필요해요'), findsOneWidget);
    });

    // TC-TIC-04: 주요 지표 렌더링
    testWidgets('should render key metrics', (WidgetTester tester) async {
      final insight = _createTestInsight(
        consecutiveDays: 7,
        redFlagCount: 2,
        completionRate: 85.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TrendInsightCard(insight: insight),
            ),
          ),
        ),
      );

      expect(find.text('7일'), findsOneWidget);
      expect(find.text('연속 기록'), findsOneWidget);
      expect(find.text('2회'), findsOneWidget);
      expect(find.text('주의 신호'), findsOneWidget);
      expect(find.text('기록률 85%'), findsOneWidget);
    });

    // TC-TIC-05: 질문 트렌드 칩 렌더링
    testWidgets('should render question trend chips', (WidgetTester tester) async {
      final insight = _createTestInsight(
        questionTrends: [
          QuestionTrend(
            questionType: QuestionType.meal,
            label: '식사',
            averageScore: 80.0,
            direction: TrendDirection.improving,
            dailyStatuses: const [],
          ),
          QuestionTrend(
            questionType: QuestionType.hydration,
            label: '수분',
            averageScore: 60.0,
            direction: TrendDirection.stable,
            dailyStatuses: const [],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TrendInsightCard(insight: insight),
            ),
          ),
        ),
      );

      expect(find.text('컨디션 요약'), findsOneWidget);
      expect(find.text('식사'), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);
    });

    // TC-TIC-06: 주간/월간 기간 표시
    testWidgets('should display period text correctly', (WidgetTester tester) async {
      final insight = _createTestInsight();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TrendInsightCard(insight: insight),
            ),
          ),
        ),
      );

      expect(find.text('이번 주'), findsOneWidget);
    });

    // TC-TIC-07: onViewDetails 콜백 검증
    testWidgets('should call onViewDetails when tapped', (WidgetTester tester) async {
      final insight = _createTestInsight();
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TrendInsightCard(
                insight: insight,
                onViewDetails: () => tapped = true,
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('상세 보기'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    // TC-TIC-08: onViewDetails 없을 때 버튼 미표시
    testWidgets('should not show details button when onViewDetails is null', (WidgetTester tester) async {
      final insight = _createTestInsight();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TrendInsightCard(insight: insight),
            ),
          ),
        ),
      );

      expect(find.text('상세 보기'), findsNothing);
    });
  });
}
