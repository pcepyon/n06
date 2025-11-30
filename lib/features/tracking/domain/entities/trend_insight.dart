import 'package:flutter/foundation.dart';

/// 트렌드 인사이트 엔티티
///
/// Phase 3: 트렌드 대시보드
/// 주간/월간 증상 트렌드 분석 결과
@immutable
class TrendInsight {
  final TrendPeriod period;
  final List<SymptomFrequency> frequencies;
  final List<SeverityTrend> severityTrends;
  final String summaryMessage;
  final TrendDirection overallDirection;

  const TrendInsight({
    required this.period,
    required this.frequencies,
    required this.severityTrends,
    required this.summaryMessage,
    required this.overallDirection,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrendInsight &&
          runtimeType == other.runtimeType &&
          period == other.period &&
          listEquals(frequencies, other.frequencies) &&
          listEquals(severityTrends, other.severityTrends) &&
          summaryMessage == other.summaryMessage &&
          overallDirection == other.overallDirection;

  @override
  int get hashCode =>
      period.hashCode ^
      Object.hashAll(frequencies) ^
      Object.hashAll(severityTrends) ^
      summaryMessage.hashCode ^
      overallDirection.hashCode;

  @override
  String toString() =>
      'TrendInsight(period: $period, frequencies: $frequencies, severityTrends: $severityTrends, summaryMessage: $summaryMessage, overallDirection: $overallDirection)';
}

/// 증상별 빈도
@immutable
class SymptomFrequency {
  final String symptomName;
  final int count;
  final double percentageOfTotal;

  const SymptomFrequency({
    required this.symptomName,
    required this.count,
    required this.percentageOfTotal,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SymptomFrequency &&
          runtimeType == other.runtimeType &&
          symptomName == other.symptomName &&
          count == other.count &&
          percentageOfTotal == other.percentageOfTotal;

  @override
  int get hashCode =>
      symptomName.hashCode ^ count.hashCode ^ percentageOfTotal.hashCode;

  @override
  String toString() =>
      'SymptomFrequency(symptomName: $symptomName, count: $count, percentageOfTotal: $percentageOfTotal)';
}

/// 심각도 추이
@immutable
class SeverityTrend {
  final String symptomName;
  final List<double> dailyAverages;
  final TrendDirection direction;

  const SeverityTrend({
    required this.symptomName,
    required this.dailyAverages,
    required this.direction,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeverityTrend &&
          runtimeType == other.runtimeType &&
          symptomName == other.symptomName &&
          listEquals(dailyAverages, other.dailyAverages) &&
          direction == other.direction;

  @override
  int get hashCode =>
      symptomName.hashCode ^
      Object.hashAll(dailyAverages) ^
      direction.hashCode;

  @override
  String toString() =>
      'SeverityTrend(symptomName: $symptomName, dailyAverages: $dailyAverages, direction: $direction)';
}

/// 트렌드 기간
enum TrendPeriod {
  weekly,
  monthly,
}

/// 트렌드 방향
enum TrendDirection {
  improving,
  stable,
  worsening,
}
