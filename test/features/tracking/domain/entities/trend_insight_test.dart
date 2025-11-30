import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/domain/entities/trend_insight.dart';

void main() {
  group('TrendInsight Entity', () {
    // TC-TI-01: TrendPeriod enum 값 검증
    test('should have all TrendPeriod enum values', () {
      // Assert
      expect(TrendPeriod.values.length, 2);
      expect(TrendPeriod.values, contains(TrendPeriod.weekly));
      expect(TrendPeriod.values, contains(TrendPeriod.monthly));
    });

    // TC-TI-02: TrendDirection enum 값 검증
    test('should have all TrendDirection enum values', () {
      // Assert
      expect(TrendDirection.values.length, 3);
      expect(TrendDirection.values, contains(TrendDirection.improving));
      expect(TrendDirection.values, contains(TrendDirection.stable));
      expect(TrendDirection.values, contains(TrendDirection.worsening));
    });

    // TC-TI-03: TrendInsight 정상 생성
    test('should create TrendInsight with required fields', () {
      // Arrange
      final frequencies = [
        SymptomFrequency(
          symptomName: '메스꺼움',
          count: 10,
          percentageOfTotal: 50.0,
        ),
      ];
      final severityTrends = [
        SeverityTrend(
          symptomName: '메스꺼움',
          dailyAverages: const [5.0, 4.5, 4.0],
          direction: TrendDirection.improving,
        ),
      ];

      // Act
      final insight = TrendInsight(
        period: TrendPeriod.weekly,
        frequencies: frequencies,
        severityTrends: severityTrends,
        summaryMessage: '이번 주에는 메스꺼움이(가) 가장 많이 기록되었어요',
        overallDirection: TrendDirection.stable,
      );

      // Assert
      expect(insight.period, TrendPeriod.weekly);
      expect(insight.frequencies, frequencies);
      expect(insight.severityTrends, severityTrends);
      expect(insight.summaryMessage, '이번 주에는 메스꺼움이(가) 가장 많이 기록되었어요');
      expect(insight.overallDirection, TrendDirection.stable);
    });

    // TC-TI-04: Equality 비교 (동일한 값)
    test('should compare two TrendInsight entities correctly when equal', () {
      // Arrange
      final frequencies = [
        SymptomFrequency(symptomName: '메스꺼움', count: 10, percentageOfTotal: 50.0),
      ];
      final severityTrends = [
        SeverityTrend(
          symptomName: '메스꺼움',
          dailyAverages: const [5.0, 4.5],
          direction: TrendDirection.improving,
        ),
      ];

      final insight1 = TrendInsight(
        period: TrendPeriod.weekly,
        frequencies: frequencies,
        severityTrends: severityTrends,
        summaryMessage: '테스트',
        overallDirection: TrendDirection.stable,
      );
      final insight2 = TrendInsight(
        period: TrendPeriod.weekly,
        frequencies: frequencies,
        severityTrends: severityTrends,
        summaryMessage: '테스트',
        overallDirection: TrendDirection.stable,
      );

      // Act & Assert
      expect(insight1 == insight2, isTrue);
      expect(insight1.hashCode, insight2.hashCode);
    });

    // TC-TI-05: toString 메서드 존재
    test('should have toString method', () {
      // Arrange
      final insight = TrendInsight(
        period: TrendPeriod.weekly,
        frequencies: const [],
        severityTrends: const [],
        summaryMessage: '테스트',
        overallDirection: TrendDirection.stable,
      );

      // Act
      final str = insight.toString();

      // Assert
      expect(str, isNotEmpty);
      expect(str, contains('TrendInsight'));
      expect(str, contains('weekly'));
    });
  });

  group('SymptomFrequency Entity', () {
    // TC-SF-01: SymptomFrequency 정상 생성
    test('should create SymptomFrequency', () {
      // Arrange & Act
      final frequency = SymptomFrequency(
        symptomName: '메스꺼움',
        count: 15,
        percentageOfTotal: 75.0,
      );

      // Assert
      expect(frequency.symptomName, '메스꺼움');
      expect(frequency.count, 15);
      expect(frequency.percentageOfTotal, 75.0);
    });

    // TC-SF-02: Equality 비교
    test('should compare two SymptomFrequency entities correctly', () {
      // Arrange
      final freq1 = SymptomFrequency(
        symptomName: '메스꺼움',
        count: 10,
        percentageOfTotal: 50.0,
      );
      final freq2 = SymptomFrequency(
        symptomName: '메스꺼움',
        count: 10,
        percentageOfTotal: 50.0,
      );

      // Act & Assert
      expect(freq1 == freq2, isTrue);
      expect(freq1.hashCode, freq2.hashCode);
    });

    // TC-SF-03: toString 메서드 존재
    test('should have toString method', () {
      // Arrange
      final frequency = SymptomFrequency(
        symptomName: '메스꺼움',
        count: 10,
        percentageOfTotal: 50.0,
      );

      // Act
      final str = frequency.toString();

      // Assert
      expect(str, isNotEmpty);
      expect(str, contains('SymptomFrequency'));
      expect(str, contains('메스꺼움'));
    });
  });

  group('SeverityTrend Entity', () {
    // TC-ST-01: SeverityTrend 정상 생성
    test('should create SeverityTrend', () {
      // Arrange & Act
      final trend = SeverityTrend(
        symptomName: '메스꺼움',
        dailyAverages: const [5.0, 4.5, 4.0, 3.5],
        direction: TrendDirection.improving,
      );

      // Assert
      expect(trend.symptomName, '메스꺼움');
      expect(trend.dailyAverages, const [5.0, 4.5, 4.0, 3.5]);
      expect(trend.direction, TrendDirection.improving);
    });

    // TC-ST-02: dailyAverages 빈 리스트 허용
    test('should allow empty dailyAverages', () {
      // Arrange & Act
      final trend = SeverityTrend(
        symptomName: '메스꺼움',
        dailyAverages: const [],
        direction: TrendDirection.stable,
      );

      // Assert
      expect(trend.dailyAverages, isEmpty);
    });

    // TC-ST-03: Equality 비교
    test('should compare two SeverityTrend entities correctly', () {
      // Arrange
      final trend1 = SeverityTrend(
        symptomName: '메스꺼움',
        dailyAverages: const [5.0, 4.0],
        direction: TrendDirection.improving,
      );
      final trend2 = SeverityTrend(
        symptomName: '메스꺼움',
        dailyAverages: const [5.0, 4.0],
        direction: TrendDirection.improving,
      );

      // Act & Assert
      expect(trend1 == trend2, isTrue);
      expect(trend1.hashCode, trend2.hashCode);
    });

    // TC-ST-04: toString 메서드 존재
    test('should have toString method', () {
      // Arrange
      final trend = SeverityTrend(
        symptomName: '메스꺼움',
        dailyAverages: const [5.0, 4.0],
        direction: TrendDirection.improving,
      );

      // Act
      final str = trend.toString();

      // Assert
      expect(str, isNotEmpty);
      expect(str, contains('SeverityTrend'));
      expect(str, contains('메스꺼움'));
    });

    // TC-ST-05: TrendDirection별 생성 검증 (improving)
    test('should create SeverityTrend with improving direction', () {
      // Arrange & Act
      final trend = SeverityTrend(
        symptomName: '메스꺼움',
        dailyAverages: const [5.0, 4.0, 3.0],
        direction: TrendDirection.improving,
      );

      // Assert
      expect(trend.direction, TrendDirection.improving);
    });

    // TC-ST-06: TrendDirection별 생성 검증 (stable)
    test('should create SeverityTrend with stable direction', () {
      // Arrange & Act
      final trend = SeverityTrend(
        symptomName: '메스꺼움',
        dailyAverages: const [5.0, 5.0, 5.0],
        direction: TrendDirection.stable,
      );

      // Assert
      expect(trend.direction, TrendDirection.stable);
    });

    // TC-ST-07: TrendDirection별 생성 검증 (worsening)
    test('should create SeverityTrend with worsening direction', () {
      // Arrange & Act
      final trend = SeverityTrend(
        symptomName: '메스꺼움',
        dailyAverages: const [3.0, 4.0, 5.0],
        direction: TrendDirection.worsening,
      );

      // Assert
      expect(trend.direction, TrendDirection.worsening);
    });
  });
}
