import '../entities/trend_insight.dart';
import '../entities/symptom_log.dart';

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
    required List<SymptomLog> logs,
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
  List<SymptomFrequency> _calculateSymptomFrequencies(List<SymptomLog> logs) {
    final symptomCounts = <String, int>{};

    for (final log in logs) {
      symptomCounts[log.symptomName] = (symptomCounts[log.symptomName] ?? 0) + 1;
    }

    final totalCount = logs.length;

    final frequencies = symptomCounts.entries
        .map((entry) => SymptomFrequency(
              symptomName: entry.key,
              count: entry.value,
              percentageOfTotal: (entry.value / totalCount * 100),
            ))
        .toList();

    // 빈도 높은 순 정렬
    frequencies.sort((a, b) => b.count.compareTo(a.count));

    return frequencies;
  }

  /// 심각도 추이 계산 (TOP 3 증상)
  List<SeverityTrend> _calculateSeverityTrends(
    List<SymptomLog> logs,
    List<SymptomFrequency> frequencies,
  ) {
    final trends = <SeverityTrend>[];

    // TOP 3 증상만 분석
    final topSymptoms = frequencies.take(3).map((f) => f.symptomName).toList();

    for (final symptomName in topSymptoms) {
      final symptomLogs = logs
          .where((log) => log.symptomName == symptomName)
          .toList()
        ..sort((a, b) => a.logDate.compareTo(b.logDate)); // 날짜순 정렬

      if (symptomLogs.isEmpty) continue;

      // 날짜별 평균 심각도 계산
      final dailyAverages = _calculateDailyAverages(symptomLogs);

      // 추세 방향 결정
      final direction = _determineTrendDirection(dailyAverages);

      trends.add(SeverityTrend(
        symptomName: symptomName,
        dailyAverages: dailyAverages,
        direction: direction,
      ));
    }

    return trends;
  }

  /// 날짜별 평균 심각도 계산
  List<double> _calculateDailyAverages(List<SymptomLog> logs) {
    if (logs.isEmpty) return [];

    final dailyGroups = <String, List<int>>{};

    for (final log in logs) {
      final dateKey = '${log.logDate.year}-${log.logDate.month}-${log.logDate.day}';
      dailyGroups[dateKey] = (dailyGroups[dateKey] ?? [])..add(log.severity);
    }

    // 날짜순 정렬 후 평균 계산
    final sortedDates = dailyGroups.keys.toList()..sort();

    return sortedDates.map((date) {
      final severities = dailyGroups[date]!;
      return severities.reduce((a, b) => a + b) / severities.length;
    }).toList();
  }

  /// 추세 방향 결정 (선형 회귀 기울기 기반)
  TrendDirection _determineTrendDirection(List<double> dailyAverages) {
    if (dailyAverages.length < 2) return TrendDirection.stable;

    // 간단한 선형 회귀 기울기 계산
    final n = dailyAverages.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;

    for (int i = 0; i < n; i++) {
      final x = i.toDouble();
      final y = dailyAverages[i];
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);

    // 기울기 기준으로 방향 결정
    if (slope < -0.3) {
      return TrendDirection.improving; // 심각도 감소
    } else if (slope > 0.3) {
      return TrendDirection.worsening; // 심각도 증가
    } else {
      return TrendDirection.stable;
    }
  }

  /// 전체 방향 평가 (모든 증상의 평균 심각도 추세)
  TrendDirection _evaluateOverallDirection(List<SymptomLog> logs) {
    if (logs.length < 2) return TrendDirection.stable;

    final sortedLogs = logs.toList()..sort((a, b) => a.logDate.compareTo(b.logDate));

    // 전반기 vs 후반기 평균 비교
    final half = sortedLogs.length ~/ 2;
    final firstHalf = sortedLogs.sublist(0, half);
    final secondHalf = sortedLogs.sublist(half);

    final firstAvg = firstHalf.fold<double>(0, (sum, log) => sum + log.severity) / firstHalf.length;
    final secondAvg = secondHalf.fold<double>(0, (sum, log) => sum + log.severity) / secondHalf.length;

    final change = ((firstAvg - secondAvg) / firstAvg * 100).abs();

    if (change < 10) {
      return TrendDirection.stable;
    } else if (secondAvg < firstAvg) {
      return TrendDirection.improving;
    } else {
      return TrendDirection.worsening;
    }
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
