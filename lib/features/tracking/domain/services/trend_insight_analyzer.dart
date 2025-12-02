import '../entities/trend_insight.dart';

/// 트렌드 인사이트 분석 서비스
///
/// Phase 3: 트렌드 대시보드
/// 주간/월간 증상 빈도 집계, 심각도 변화 추이 계산, 최다 발생 증상 추출, 개선/악화 종합 평가
class TrendInsightAnalyzer {
  /// 트렌드 인사이트 생성
  ///
  /// [logs]: 분석 대상 증상 기록 (주간: 최근 7일, 월간: 최근 30일)
  /// [period]: 트렌드 기간 (주간/월간)
  ///
  /// 반환: 종합 트렌드 인사이트
  TrendInsight analyzeTrend({
    required List<dynamic> logs,
    required TrendPeriod period,
  }) {
    if (logs.isEmpty) {
      return TrendInsight(
        period: period,
        frequencies: const [],
        severityTrends: const [],
        summaryMessage: '기록된 증상이 없어요',
        overallDirection: TrendDirection.stable,
      );
    }

    // 1. 증상 빈도 집계
    final frequencies = _calculateSymptomFrequencies(logs);

    // 2. 심각도 추이 계산 (TOP 3 증상)
    final severityTrends = _calculateSeverityTrends(logs, frequencies);

    // 3. 전체 방향 평가
    final overallDirection = _evaluateOverallDirection(logs);

    // 4. 요약 메시지 생성
    final summaryMessage = _generateSummaryMessage(
      frequencies: frequencies,
      overallDirection: overallDirection,
      period: period,
    );

    return TrendInsight(
      period: period,
      frequencies: frequencies,
      severityTrends: severityTrends,
      summaryMessage: summaryMessage,
      overallDirection: overallDirection,
    );
  }

  /// 증상별 빈도 집계 (빈도 높은 순 정렬)
  List<SymptomFrequency> _calculateSymptomFrequencies(List<dynamic> logs) {
    // 증상 로그는 제거되었으므로 빈 리스트 반환
    return [];
  }

  /// 심각도 추이 계산 (TOP 3 증상)
  List<SeverityTrend> _calculateSeverityTrends(
    List<dynamic> logs,
    List<SymptomFrequency> frequencies,
  ) {
    // 증상 로그는 제거되었으므로 빈 리스트 반환
    return [];
  }

  /// 전체 방향 평가 (모든 증상의 평균 심각도 추세)
  TrendDirection _evaluateOverallDirection(List<dynamic> logs) {
    // 증상 로그는 제거되었으므로 안정 상태 반환
    return TrendDirection.stable;
  }

  /// 요약 메시지 생성
  String _generateSummaryMessage({
    required List<SymptomFrequency> frequencies,
    required TrendDirection overallDirection,
    required TrendPeriod period,
  }) {
    if (frequencies.isEmpty) {
      return '기록된 증상이 없어요';
    }

    final periodText = period == TrendPeriod.weekly ? '이번 주' : '이번 달';
    final topSymptom = frequencies.first.symptomName;

    switch (overallDirection) {
      case TrendDirection.improving:
        return '$periodText에는 증상이 개선되고 있어요! 잘하고 계세요';
      case TrendDirection.stable:
        return '$periodText에는 $topSymptom이(가) 가장 많이 기록되었어요';
      case TrendDirection.worsening:
        return '$periodText에는 증상이 조금 증가했어요. 패턴을 살펴보세요';
    }
  }
}
