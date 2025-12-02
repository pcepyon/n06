import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/domain/entities/trend_insight.dart';

void main() {
  group('TrendInsight Entity', () {
    // TC-TI-01: TrendPeriod enum 값 검증
    test('should have all TrendPeriod enum values', () {
      expect(TrendPeriod.values.length, 2);
      expect(TrendPeriod.values, contains(TrendPeriod.weekly));
      expect(TrendPeriod.values, contains(TrendPeriod.monthly));
    });

    // TC-TI-02: TrendDirection enum 값 검증
    test('should have all TrendDirection enum values', () {
      expect(TrendDirection.values.length, 3);
      expect(TrendDirection.values, contains(TrendDirection.improving));
      expect(TrendDirection.values, contains(TrendDirection.stable));
      expect(TrendDirection.values, contains(TrendDirection.worsening));
    });

    // TC-TI-03: TrendInsight 정상 생성
    test('should create TrendInsight with required fields', () {
      final questionTrends = [
        QuestionTrend(
          questionType: QuestionType.meal,
          label: '식사',
          averageScore: 80.0,
          direction: TrendDirection.improving,
          dailyStatuses: const [],
        ),
      ];

      final insight = TrendInsight(
        period: TrendPeriod.weekly,
        dailyConditions: const [],
        questionTrends: questionTrends,
        patternInsight: const WeeklyPatternInsight(
          hasPostInjectionPattern: false,
          recommendations: [],
        ),
        overallDirection: TrendDirection.stable,
        summaryMessage: '이번 주 컨디션이 안정적이에요',
        redFlagCount: 0,
        consecutiveDays: 5,
        completionRate: 71.4,
      );

      expect(insight.period, TrendPeriod.weekly);
      expect(insight.questionTrends, questionTrends);
      expect(insight.summaryMessage, '이번 주 컨디션이 안정적이에요');
      expect(insight.overallDirection, TrendDirection.stable);
      expect(insight.consecutiveDays, 5);
      expect(insight.completionRate, 71.4);
    });

    // TC-TI-04: TrendInsight.empty 팩토리
    test('should create empty TrendInsight', () {
      final insight = TrendInsight.empty(TrendPeriod.weekly);

      expect(insight.period, TrendPeriod.weekly);
      expect(insight.dailyConditions, isEmpty);
      expect(insight.questionTrends, isEmpty);
      expect(insight.overallDirection, TrendDirection.stable);
      expect(insight.redFlagCount, 0);
      expect(insight.consecutiveDays, 0);
      expect(insight.completionRate, 0);
    });

    // TC-TI-05: Equality 비교
    test('should compare two TrendInsight entities correctly', () {
      final insight1 = TrendInsight.empty(TrendPeriod.weekly);
      final insight2 = TrendInsight.empty(TrendPeriod.weekly);

      expect(insight1 == insight2, isTrue);
      expect(insight1.hashCode, insight2.hashCode);
    });
  });

  group('QuestionTrend Entity', () {
    // TC-QT-01: QuestionTrend 정상 생성
    test('should create QuestionTrend', () {
      final trend = QuestionTrend(
        questionType: QuestionType.meal,
        label: '식사',
        averageScore: 75.0,
        direction: TrendDirection.improving,
        dailyStatuses: const [],
      );

      expect(trend.questionType, QuestionType.meal);
      expect(trend.label, '식사');
      expect(trend.averageScore, 75.0);
      expect(trend.direction, TrendDirection.improving);
    });

    // TC-QT-02: QuestionType enum 값 검증
    test('should have all QuestionType enum values', () {
      expect(QuestionType.values.length, 6);
      expect(QuestionType.values, contains(QuestionType.meal));
      expect(QuestionType.values, contains(QuestionType.hydration));
      expect(QuestionType.values, contains(QuestionType.giComfort));
      expect(QuestionType.values, contains(QuestionType.bowel));
      expect(QuestionType.values, contains(QuestionType.energy));
      expect(QuestionType.values, contains(QuestionType.mood));
    });

    // TC-QT-03: Equality 비교
    test('should compare two QuestionTrend entities correctly', () {
      final trend1 = QuestionTrend(
        questionType: QuestionType.meal,
        label: '식사',
        averageScore: 80.0,
        direction: TrendDirection.stable,
        dailyStatuses: const [],
      );
      final trend2 = QuestionTrend(
        questionType: QuestionType.meal,
        label: '식사',
        averageScore: 80.0,
        direction: TrendDirection.stable,
        dailyStatuses: const [],
      );

      expect(trend1 == trend2, isTrue);
      expect(trend1.hashCode, trend2.hashCode);
    });
  });

  group('DailyConditionSummary Entity', () {
    // TC-DCS-01: DailyConditionSummary 정상 생성
    test('should create DailyConditionSummary', () {
      final summary = DailyConditionSummary(
        date: DateTime(2024, 1, 15),
        overallScore: 85,
        grade: ConditionGrade.good,
        hasRedFlag: false,
        hasCheckin: true,
        isPostInjection: false,
      );

      expect(summary.date, DateTime(2024, 1, 15));
      expect(summary.overallScore, 85);
      expect(summary.grade, ConditionGrade.good);
      expect(summary.hasRedFlag, isFalse);
      expect(summary.hasCheckin, isTrue);
    });

    // TC-DCS-02: ConditionGrade enum 값 검증
    test('should have all ConditionGrade enum values', () {
      expect(ConditionGrade.values.length, 5);
      expect(ConditionGrade.values, contains(ConditionGrade.excellent));
      expect(ConditionGrade.values, contains(ConditionGrade.good));
      expect(ConditionGrade.values, contains(ConditionGrade.fair));
      expect(ConditionGrade.values, contains(ConditionGrade.poor));
      expect(ConditionGrade.values, contains(ConditionGrade.bad));
    });
  });

  group('WeeklyPatternInsight Entity', () {
    // TC-WPI-01: WeeklyPatternInsight 정상 생성
    test('should create WeeklyPatternInsight', () {
      final pattern = WeeklyPatternInsight(
        hasPostInjectionPattern: true,
        postInjectionInsight: '주사 다음날 속이 불편한 경향이 있어요',
        topConcernArea: QuestionType.giComfort,
        improvementArea: QuestionType.meal,
        recommendations: ['소화가 잘 되는 음식을 드세요'],
      );

      expect(pattern.hasPostInjectionPattern, isTrue);
      expect(pattern.postInjectionInsight, isNotNull);
      expect(pattern.topConcernArea, QuestionType.giComfort);
      expect(pattern.improvementArea, QuestionType.meal);
      expect(pattern.recommendations, hasLength(1));
    });

    // TC-WPI-02: Equality 비교
    test('should compare two WeeklyPatternInsight entities correctly', () {
      final pattern1 = WeeklyPatternInsight(
        hasPostInjectionPattern: false,
        recommendations: const [],
      );
      final pattern2 = WeeklyPatternInsight(
        hasPostInjectionPattern: false,
        recommendations: const [],
      );

      expect(pattern1 == pattern2, isTrue);
      expect(pattern1.hashCode, pattern2.hashCode);
    });
  });

  group('DailyQuestionStatus Entity', () {
    // TC-DQS-01: DailyQuestionStatus 정상 생성
    test('should create DailyQuestionStatus', () {
      final status = DailyQuestionStatus(
        date: DateTime(2024, 1, 15),
        score: 100,
        noData: false,
      );

      expect(status.date, DateTime(2024, 1, 15));
      expect(status.score, 100);
      expect(status.noData, isFalse);
    });

    // TC-DQS-02: noData 기본값 확인
    test('should have noData default to false', () {
      final status = DailyQuestionStatus(
        date: DateTime(2024, 1, 15),
        score: 50,
      );

      expect(status.noData, isFalse);
    });
  });
}
