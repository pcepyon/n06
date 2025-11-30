import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/domain/entities/trend_insight.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';
import 'package:n06/features/tracking/domain/services/trend_insight_analyzer.dart';

void main() {
  group('TrendInsightAnalyzer', () {
    late TrendInsightAnalyzer analyzer;

    setUp(() {
      analyzer = TrendInsightAnalyzer();
    });

    group('analyzeTrend', () {
      // TC-TIA-01: 데이터 없음 - 기본 인사이트 반환
      test('should return default insight when no logs provided', () {
        // Arrange
        final logs = <SymptomLog>[];

        // Act
        final insight = analyzer.analyzeTrend(
          logs: logs,
          period: TrendPeriod.weekly,
        );

        // Assert
        expect(insight.period, TrendPeriod.weekly);
        expect(insight.frequencies, isEmpty);
        expect(insight.severityTrends, isEmpty);
        expect(insight.summaryMessage, '기록된 증상이 없어요');
        expect(insight.overallDirection, TrendDirection.stable);
      });

      // TC-TIA-02: 증상별 빈도 집계 검증
      test('should calculate symptom frequencies correctly', () {
        // Arrange
        final now = DateTime.now();
        final logs = [
          SymptomLog(
            id: '1',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 1)),
            symptomName: '메스꺼움',
            severity: 5,
          ),
          SymptomLog(
            id: '2',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 2)),
            symptomName: '메스꺼움',
            severity: 6,
          ),
          SymptomLog(
            id: '3',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 3)),
            symptomName: '변비',
            severity: 4,
          ),
          SymptomLog(
            id: '4',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 4)),
            symptomName: '변비',
            severity: 5,
          ),
          SymptomLog(
            id: '5',
            userId: 'user-001',
            logDate: now.subtract(const Duration(days: 5)),
            symptomName: '피로',
            severity: 3,
          ),
        ];

        // Act
        final insight = analyzer.analyzeTrend(
          logs: logs,
          period: TrendPeriod.weekly,
        );

        // Assert
        expect(insight.frequencies.length, 3);

        // 메스꺼움: 2회 (40%)
        final nausea = insight.frequencies.firstWhere((f) => f.symptomName == '메스꺼움');
        expect(nausea.count, 2);
        expect(nausea.percentageOfTotal, 40.0);

        // 변비: 2회 (40%)
        final constipation = insight.frequencies.firstWhere((f) => f.symptomName == '변비');
        expect(constipation.count, 2);
        expect(constipation.percentageOfTotal, 40.0);

        // 피로: 1회 (20%)
        final fatigue = insight.frequencies.firstWhere((f) => f.symptomName == '피로');
        expect(fatigue.count, 1);
        expect(fatigue.percentageOfTotal, 20.0);
      });

      // TC-TIA-03: 빈도 높은 순 정렬 검증
      test('should sort frequencies by count in descending order', () {
        // Arrange
        final now = DateTime.now();
        final logs = [
          // 메스꺼움: 3회
          SymptomLog(id: '1', userId: 'user-001', logDate: now, symptomName: '메스꺼움', severity: 5),
          SymptomLog(id: '2', userId: 'user-001', logDate: now, symptomName: '메스꺼움', severity: 5),
          SymptomLog(id: '3', userId: 'user-001', logDate: now, symptomName: '메스꺼움', severity: 5),
          // 변비: 5회
          SymptomLog(id: '4', userId: 'user-001', logDate: now, symptomName: '변비', severity: 4),
          SymptomLog(id: '5', userId: 'user-001', logDate: now, symptomName: '변비', severity: 4),
          SymptomLog(id: '6', userId: 'user-001', logDate: now, symptomName: '변비', severity: 4),
          SymptomLog(id: '7', userId: 'user-001', logDate: now, symptomName: '변비', severity: 4),
          SymptomLog(id: '8', userId: 'user-001', logDate: now, symptomName: '변비', severity: 4),
          // 피로: 1회
          SymptomLog(id: '9', userId: 'user-001', logDate: now, symptomName: '피로', severity: 3),
        ];

        // Act
        final insight = analyzer.analyzeTrend(logs: logs, period: TrendPeriod.weekly);

        // Assert
        expect(insight.frequencies.length, 3);
        expect(insight.frequencies[0].symptomName, '변비'); // 5회
        expect(insight.frequencies[1].symptomName, '메스꺼움'); // 3회
        expect(insight.frequencies[2].symptomName, '피로'); // 1회
      });

      // TC-TIA-04: TOP 3 증상에 대한 심각도 추이 계산
      test('should calculate severity trends for top 3 symptoms', () {
        // Arrange
        final now = DateTime.now();
        final logs = [
          // 증상 A: 5회
          SymptomLog(id: '1', userId: 'user-001', logDate: now.subtract(const Duration(days: 1)), symptomName: 'A', severity: 5),
          SymptomLog(id: '2', userId: 'user-001', logDate: now.subtract(const Duration(days: 2)), symptomName: 'A', severity: 6),
          SymptomLog(id: '3', userId: 'user-001', logDate: now.subtract(const Duration(days: 3)), symptomName: 'A', severity: 7),
          SymptomLog(id: '4', userId: 'user-001', logDate: now.subtract(const Duration(days: 4)), symptomName: 'A', severity: 8),
          SymptomLog(id: '5', userId: 'user-001', logDate: now.subtract(const Duration(days: 5)), symptomName: 'A', severity: 9),
          // 증상 B: 3회
          SymptomLog(id: '6', userId: 'user-001', logDate: now.subtract(const Duration(days: 1)), symptomName: 'B', severity: 4),
          SymptomLog(id: '7', userId: 'user-001', logDate: now.subtract(const Duration(days: 2)), symptomName: 'B', severity: 4),
          SymptomLog(id: '8', userId: 'user-001', logDate: now.subtract(const Duration(days: 3)), symptomName: 'B', severity: 4),
          // 증상 C: 2회
          SymptomLog(id: '9', userId: 'user-001', logDate: now.subtract(const Duration(days: 1)), symptomName: 'C', severity: 3),
          SymptomLog(id: '10', userId: 'user-001', logDate: now.subtract(const Duration(days: 2)), symptomName: 'C', severity: 3),
          // 증상 D: 1회 (TOP 3에 미포함)
          SymptomLog(id: '11', userId: 'user-001', logDate: now.subtract(const Duration(days: 1)), symptomName: 'D', severity: 2),
        ];

        // Act
        final insight = analyzer.analyzeTrend(logs: logs, period: TrendPeriod.weekly);

        // Assert
        expect(insight.severityTrends.length, 3);
        expect(insight.severityTrends.map((t) => t.symptomName), containsAll(['A', 'B', 'C']));
        expect(insight.severityTrends.map((t) => t.symptomName), isNot(contains('D')));
      });

      // TC-TIA-05: 날짜별 평균 심각도 계산
      test('should calculate daily averages correctly', () {
        // Arrange
        final now = DateTime.now();
        final baseDate = DateTime(now.year, now.month, now.day);

        final logs = [
          // Day 1: 5, 6 (평균 5.5)
          SymptomLog(id: '1', userId: 'user-001', logDate: baseDate, symptomName: '메스꺼움', severity: 5),
          SymptomLog(id: '2', userId: 'user-001', logDate: baseDate, symptomName: '메스꺼움', severity: 6),
          // Day 2: 4, 8 (평균 6.0)
          SymptomLog(id: '3', userId: 'user-001', logDate: baseDate.subtract(const Duration(days: 1)), symptomName: '메스꺼움', severity: 4),
          SymptomLog(id: '4', userId: 'user-001', logDate: baseDate.subtract(const Duration(days: 1)), symptomName: '메스꺼움', severity: 8),
        ];

        // Act
        final insight = analyzer.analyzeTrend(logs: logs, period: TrendPeriod.weekly);

        // Assert
        final trend = insight.severityTrends.first;
        expect(trend.dailyAverages.length, 2);
        expect(trend.dailyAverages[0], closeTo(6.0, 0.1)); // Day 2 (이전 날)
        expect(trend.dailyAverages[1], closeTo(5.5, 0.1)); // Day 1 (최근 날)
      });

      // TC-TIA-06: 추세 방향 결정 - improving (기울기 < -0.3)
      test('should determine improving trend direction', () {
        // Arrange
        final now = DateTime.now();
        final baseDate = DateTime(now.year, now.month, now.day);

        final logs = [
          // 심각도가 감소하는 패턴
          SymptomLog(id: '1', userId: 'user-001', logDate: baseDate.subtract(const Duration(days: 4)), symptomName: '메스꺼움', severity: 9),
          SymptomLog(id: '2', userId: 'user-001', logDate: baseDate.subtract(const Duration(days: 3)), symptomName: '메스꺼움', severity: 7),
          SymptomLog(id: '3', userId: 'user-001', logDate: baseDate.subtract(const Duration(days: 2)), symptomName: '메스꺼움', severity: 5),
          SymptomLog(id: '4', userId: 'user-001', logDate: baseDate.subtract(const Duration(days: 1)), symptomName: '메스꺼움', severity: 3),
          SymptomLog(id: '5', userId: 'user-001', logDate: baseDate, symptomName: '메스꺼움', severity: 2),
        ];

        // Act
        final insight = analyzer.analyzeTrend(logs: logs, period: TrendPeriod.weekly);

        // Assert
        final trend = insight.severityTrends.first;
        expect(trend.direction, TrendDirection.improving);
      });

      // TC-TIA-07: 추세 방향 결정 - worsening (기울기 > 0.3)
      test('should determine worsening trend direction', () {
        // Arrange
        final now = DateTime.now();
        final baseDate = DateTime(now.year, now.month, now.day);

        final logs = [
          // 심각도가 증가하는 패턴
          SymptomLog(id: '1', userId: 'user-001', logDate: baseDate.subtract(const Duration(days: 4)), symptomName: '메스꺼움', severity: 2),
          SymptomLog(id: '2', userId: 'user-001', logDate: baseDate.subtract(const Duration(days: 3)), symptomName: '메스꺼움', severity: 4),
          SymptomLog(id: '3', userId: 'user-001', logDate: baseDate.subtract(const Duration(days: 2)), symptomName: '메스꺼움', severity: 6),
          SymptomLog(id: '4', userId: 'user-001', logDate: baseDate.subtract(const Duration(days: 1)), symptomName: '메스꺼움', severity: 8),
          SymptomLog(id: '5', userId: 'user-001', logDate: baseDate, symptomName: '메스꺼움', severity: 9),
        ];

        // Act
        final insight = analyzer.analyzeTrend(logs: logs, period: TrendPeriod.weekly);

        // Assert
        final trend = insight.severityTrends.first;
        expect(trend.direction, TrendDirection.worsening);
      });

      // TC-TIA-08: 추세 방향 결정 - stable (기울기 -0.3 ~ 0.3)
      test('should determine stable trend direction', () {
        // Arrange
        final now = DateTime.now();
        final baseDate = DateTime(now.year, now.month, now.day);

        final logs = [
          // 심각도가 거의 일정한 패턴
          SymptomLog(id: '1', userId: 'user-001', logDate: baseDate.subtract(const Duration(days: 4)), symptomName: '메스꺼움', severity: 5),
          SymptomLog(id: '2', userId: 'user-001', logDate: baseDate.subtract(const Duration(days: 3)), symptomName: '메스꺼움', severity: 5),
          SymptomLog(id: '3', userId: 'user-001', logDate: baseDate.subtract(const Duration(days: 2)), symptomName: '메스꺼움', severity: 5),
          SymptomLog(id: '4', userId: 'user-001', logDate: baseDate.subtract(const Duration(days: 1)), symptomName: '메스꺼움', severity: 5),
          SymptomLog(id: '5', userId: 'user-001', logDate: baseDate, symptomName: '메스꺼움', severity: 5),
        ];

        // Act
        final insight = analyzer.analyzeTrend(logs: logs, period: TrendPeriod.weekly);

        // Assert
        final trend = insight.severityTrends.first;
        expect(trend.direction, TrendDirection.stable);
      });

      // TC-TIA-09: 전체 방향 평가 - improving (전반기 > 후반기)
      test('should evaluate overall direction as improving', () {
        // Arrange
        final now = DateTime.now();
        final logs = [
          // 전반기: 평균 8
          SymptomLog(id: '1', userId: 'user-001', logDate: now.subtract(const Duration(days: 6)), symptomName: '메스꺼움', severity: 8),
          SymptomLog(id: '2', userId: 'user-001', logDate: now.subtract(const Duration(days: 5)), symptomName: '메스꺼움', severity: 8),
          SymptomLog(id: '3', userId: 'user-001', logDate: now.subtract(const Duration(days: 4)), symptomName: '메스꺼움', severity: 8),
          // 후반기: 평균 4
          SymptomLog(id: '4', userId: 'user-001', logDate: now.subtract(const Duration(days: 2)), symptomName: '메스꺼움', severity: 4),
          SymptomLog(id: '5', userId: 'user-001', logDate: now.subtract(const Duration(days: 1)), symptomName: '메스꺼움', severity: 4),
          SymptomLog(id: '6', userId: 'user-001', logDate: now, symptomName: '메스꺼움', severity: 4),
        ];

        // Act
        final insight = analyzer.analyzeTrend(logs: logs, period: TrendPeriod.weekly);

        // Assert
        expect(insight.overallDirection, TrendDirection.improving);
      });

      // TC-TIA-10: 전체 방향 평가 - worsening (전반기 < 후반기)
      test('should evaluate overall direction as worsening', () {
        // Arrange
        final now = DateTime.now();
        final logs = [
          // 전반기: 평균 3
          SymptomLog(id: '1', userId: 'user-001', logDate: now.subtract(const Duration(days: 6)), symptomName: '메스꺼움', severity: 3),
          SymptomLog(id: '2', userId: 'user-001', logDate: now.subtract(const Duration(days: 5)), symptomName: '메스꺼움', severity: 3),
          SymptomLog(id: '3', userId: 'user-001', logDate: now.subtract(const Duration(days: 4)), symptomName: '메스꺼움', severity: 3),
          // 후반기: 평균 7
          SymptomLog(id: '4', userId: 'user-001', logDate: now.subtract(const Duration(days: 2)), symptomName: '메스꺼움', severity: 7),
          SymptomLog(id: '5', userId: 'user-001', logDate: now.subtract(const Duration(days: 1)), symptomName: '메스꺼움', severity: 7),
          SymptomLog(id: '6', userId: 'user-001', logDate: now, symptomName: '메스꺼움', severity: 7),
        ];

        // Act
        final insight = analyzer.analyzeTrend(logs: logs, period: TrendPeriod.weekly);

        // Assert
        expect(insight.overallDirection, TrendDirection.worsening);
      });

      // TC-TIA-11: 전체 방향 평가 - stable (변화 10% 미만)
      test('should evaluate overall direction as stable when change < 10%', () {
        // Arrange
        final now = DateTime.now();
        final logs = [
          // 전반기: 평균 5
          SymptomLog(id: '1', userId: 'user-001', logDate: now.subtract(const Duration(days: 6)), symptomName: '메스꺼움', severity: 5),
          SymptomLog(id: '2', userId: 'user-001', logDate: now.subtract(const Duration(days: 5)), symptomName: '메스꺼움', severity: 5),
          // 후반기: 평균 5.2 (변화 4%)
          SymptomLog(id: '3', userId: 'user-001', logDate: now.subtract(const Duration(days: 1)), symptomName: '메스꺼움', severity: 5),
          SymptomLog(id: '4', userId: 'user-001', logDate: now, symptomName: '메스꺼움', severity: 5),
        ];

        // Act
        final insight = analyzer.analyzeTrend(logs: logs, period: TrendPeriod.weekly);

        // Assert
        expect(insight.overallDirection, TrendDirection.stable);
      });

      // TC-TIA-12: 요약 메시지 생성 - improving
      test('should generate summary message for improving trend', () {
        // Arrange
        final now = DateTime.now();
        final logs = [
          SymptomLog(id: '1', userId: 'user-001', logDate: now.subtract(const Duration(days: 6)), symptomName: '메스꺼움', severity: 8),
          SymptomLog(id: '2', userId: 'user-001', logDate: now.subtract(const Duration(days: 5)), symptomName: '메스꺼움', severity: 8),
          SymptomLog(id: '3', userId: 'user-001', logDate: now.subtract(const Duration(days: 4)), symptomName: '메스꺼움', severity: 8),
          SymptomLog(id: '4', userId: 'user-001', logDate: now.subtract(const Duration(days: 2)), symptomName: '메스꺼움', severity: 3),
          SymptomLog(id: '5', userId: 'user-001', logDate: now.subtract(const Duration(days: 1)), symptomName: '메스꺼움', severity: 3),
          SymptomLog(id: '6', userId: 'user-001', logDate: now, symptomName: '메스꺼움', severity: 3),
        ];

        // Act
        final insight = analyzer.analyzeTrend(logs: logs, period: TrendPeriod.weekly);

        // Assert
        expect(insight.summaryMessage, contains('개선되고 있어요'));
        expect(insight.summaryMessage, contains('잘하고 계세요'));
      });

      // TC-TIA-13: 요약 메시지 생성 - stable
      test('should generate summary message for stable trend', () {
        // Arrange
        final now = DateTime.now();
        final logs = [
          SymptomLog(id: '1', userId: 'user-001', logDate: now, symptomName: '메스꺼움', severity: 5),
          SymptomLog(id: '2', userId: 'user-001', logDate: now, symptomName: '메스꺼움', severity: 5),
        ];

        // Act
        final insight = analyzer.analyzeTrend(logs: logs, period: TrendPeriod.weekly);

        // Assert
        expect(insight.summaryMessage, contains('메스꺼움'));
        expect(insight.summaryMessage, contains('가장 많이 기록'));
      });

      // TC-TIA-14: 요약 메시지 생성 - worsening
      test('should generate summary message for worsening trend', () {
        // Arrange
        final now = DateTime.now();
        final logs = [
          SymptomLog(id: '1', userId: 'user-001', logDate: now.subtract(const Duration(days: 6)), symptomName: '메스꺼움', severity: 3),
          SymptomLog(id: '2', userId: 'user-001', logDate: now.subtract(const Duration(days: 5)), symptomName: '메스꺼움', severity: 3),
          SymptomLog(id: '3', userId: 'user-001', logDate: now.subtract(const Duration(days: 4)), symptomName: '메스꺼움', severity: 3),
          SymptomLog(id: '4', userId: 'user-001', logDate: now.subtract(const Duration(days: 2)), symptomName: '메스꺼움', severity: 8),
          SymptomLog(id: '5', userId: 'user-001', logDate: now.subtract(const Duration(days: 1)), symptomName: '메스꺼움', severity: 8),
          SymptomLog(id: '6', userId: 'user-001', logDate: now, symptomName: '메스꺼움', severity: 8),
        ];

        // Act
        final insight = analyzer.analyzeTrend(logs: logs, period: TrendPeriod.weekly);

        // Assert
        expect(insight.summaryMessage, contains('증가했어요'));
        expect(insight.summaryMessage, contains('패턴을 살펴보세요'));
      });

      // TC-TIA-15: 주간 vs 월간 기간 구분
      test('should distinguish between weekly and monthly periods in summary', () {
        // Arrange
        final now = DateTime.now();
        final logs = [
          SymptomLog(id: '1', userId: 'user-001', logDate: now, symptomName: '메스꺼움', severity: 5),
        ];

        // Act
        final weeklyInsight = analyzer.analyzeTrend(logs: logs, period: TrendPeriod.weekly);
        final monthlyInsight = analyzer.analyzeTrend(logs: logs, period: TrendPeriod.monthly);

        // Assert
        expect(weeklyInsight.summaryMessage, contains('이번 주'));
        expect(monthlyInsight.summaryMessage, contains('이번 달'));
      });

      // TC-TIA-16: 경계값 테스트 - 단일 로그
      test('should handle single log correctly', () {
        // Arrange
        final now = DateTime.now();
        final logs = [
          SymptomLog(id: '1', userId: 'user-001', logDate: now, symptomName: '메스꺼움', severity: 5),
        ];

        // Act
        final insight = analyzer.analyzeTrend(logs: logs, period: TrendPeriod.weekly);

        // Assert
        expect(insight.frequencies.length, 1);
        expect(insight.frequencies.first.count, 1);
        expect(insight.frequencies.first.percentageOfTotal, 100.0);
        expect(insight.overallDirection, TrendDirection.stable); // 단일 데이터는 stable
      });

      // TC-TIA-17: 동일 날짜 여러 로그 처리
      test('should handle multiple logs on same date', () {
        // Arrange
        final now = DateTime.now();
        final baseDate = DateTime(now.year, now.month, now.day);

        final logs = [
          SymptomLog(id: '1', userId: 'user-001', logDate: baseDate, symptomName: '메스꺼움', severity: 3),
          SymptomLog(id: '2', userId: 'user-001', logDate: baseDate, symptomName: '메스꺼움', severity: 7),
          SymptomLog(id: '3', userId: 'user-001', logDate: baseDate, symptomName: '메스꺼움', severity: 5),
        ];

        // Act
        final insight = analyzer.analyzeTrend(logs: logs, period: TrendPeriod.weekly);

        // Assert
        final trend = insight.severityTrends.first;
        expect(trend.dailyAverages.length, 1);
        expect(trend.dailyAverages.first, 5.0); // (3 + 7 + 5) / 3 = 5.0
      });
    });
  });
}
