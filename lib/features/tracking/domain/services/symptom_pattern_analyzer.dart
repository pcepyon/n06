import '../entities/pattern_insight.dart';
import '../entities/symptom_log.dart';

/// 증상 패턴 분석 서비스
///
/// Phase 2: 컨텍스트 인식 가이드
/// 최근 N일간 증상 기록 히스토리에서 패턴을 감지하고 인사이트 생성
class SymptomPatternAnalyzer {
  /// 최근 증상 기록에서 패턴 인사이트 생성
  ///
  /// [recentLogs]: 최근 30일간의 증상 기록 (분석 대상)
  /// [currentSymptom]: 현재 선택된 증상명
  ///
  /// 반환: 발견된 패턴 인사이트 리스트 (신뢰도 높은 순)
  List<PatternInsight> analyzePatterns({
    required List<SymptomLog> recentLogs,
    required String currentSymptom,
  }) {
    final insights = <PatternInsight>[];

    // 현재 증상과 관련된 로그만 필터링
    final relevantLogs = recentLogs
        .where((log) => log.symptomName == currentSymptom)
        .toList();

    if (relevantLogs.isEmpty) {
      return insights;
    }

    // 1. 반복 패턴 감지 (최근 7일간 3회 이상)
    final recurringInsight = _detectRecurringPattern(relevantLogs, currentSymptom);
    if (recurringInsight != null) {
      insights.add(recurringInsight);
    }

    // 2. 컨텍스트 연관성 분석 (특정 태그와 함께 3회 이상)
    final contextInsights = _detectContextRelated(relevantLogs, currentSymptom);
    insights.addAll(contextInsights);

    // 3. 개선/악화 추세 감지
    final trendInsight = _detectTrend(relevantLogs, currentSymptom);
    if (trendInsight != null) {
      insights.add(trendInsight);
    }

    // 신뢰도 높은 순 정렬
    insights.sort((a, b) => b.confidence.compareTo(a.confidence));

    return insights;
  }

  /// 반복 패턴 감지: 최근 7일간 3회 이상 동일 증상
  PatternInsight? _detectRecurringPattern(
    List<SymptomLog> logs,
    String symptomName,
  ) {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    final recentLogs = logs
        .where((log) => log.logDate.isAfter(sevenDaysAgo))
        .toList();

    if (recentLogs.length >= 3) {
      final avgSeverity = recentLogs.fold<double>(
            0,
            (sum, log) => sum + log.severity,
          ) /
          recentLogs.length;

      return PatternInsight(
        type: PatternType.recurring,
        symptomName: symptomName,
        message: '$symptomName이(가) 최근 7일간 ${recentLogs.length}번 반복되었어요',
        suggestion: avgSeverity >= 7
            ? '증상이 자주 나타나네요. 담당 의료진과 상담해보세요'
            : '몸이 적응하는 과정이에요. 조금씩 나아질 거예요',
        confidence: 0.9,
      );
    }

    return null;
  }

  /// 컨텍스트 연관성 감지: 특정 태그와 함께 3회 이상
  List<PatternInsight> _detectContextRelated(
    List<SymptomLog> logs,
    String symptomName,
  ) {
    final insights = <PatternInsight>[];

    // 태그 빈도 분석
    final tagFrequency = <String, int>{};
    for (final log in logs) {
      for (final tag in log.tags) {
        tagFrequency[tag] = (tagFrequency[tag] ?? 0) + 1;
      }
    }

    // 3회 이상 반복된 태그 찾기
    for (final entry in tagFrequency.entries) {
      if (entry.value >= 3) {
        final confidence = (entry.value / logs.length).clamp(0.0, 1.0);

        insights.add(PatternInsight(
          type: PatternType.contextRelated,
          symptomName: symptomName,
          message: '$symptomName이(가) #${entry.key}와(과) 함께 ${entry.value}번 기록되었어요',
          suggestion: _getSuggestionForTag(symptomName, entry.key),
          confidence: confidence,
        ));
      }
    }

    return insights;
  }

  /// 개선/악화 추세 감지: 주간 평균 비교 (최근 7일 vs 이전 7일)
  PatternInsight? _detectTrend(
    List<SymptomLog> logs,
    String symptomName,
  ) {
    if (logs.length < 4) return null; // 최소 4개 이상 필요

    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final fourteenDaysAgo = now.subtract(const Duration(days: 14));

    final recentLogs = logs
        .where((log) => log.logDate.isAfter(sevenDaysAgo))
        .toList();

    final previousLogs = logs
        .where((log) =>
            log.logDate.isAfter(fourteenDaysAgo) &&
            log.logDate.isBefore(sevenDaysAgo))
        .toList();

    if (recentLogs.isEmpty || previousLogs.isEmpty) return null;

    final recentAvg = recentLogs.fold<double>(
          0,
          (sum, log) => sum + log.severity,
        ) /
        recentLogs.length;

    final previousAvg = previousLogs.fold<double>(
          0,
          (sum, log) => sum + log.severity,
        ) /
        previousLogs.length;

    final changePercent = ((previousAvg - recentAvg) / previousAvg * 100).abs();

    // 20% 이상 변화가 있을 때만 인사이트 생성
    if (changePercent >= 20) {
      final isImproving = recentAvg < previousAvg;

      return PatternInsight(
        type: isImproving ? PatternType.improving : PatternType.worsening,
        symptomName: symptomName,
        message: isImproving
            ? '좋은 소식! 지난주보다 ${changePercent.toStringAsFixed(0)}% 나아졌어요'
            : '지난주보다 ${changePercent.toStringAsFixed(0)}% 증가했어요',
        suggestion: isImproving
            ? '잘하고 계세요! 현재 관리 방법을 계속 유지해보세요'
            : '증상이 지속되면 담당 의료진과 상담해보세요',
        confidence: 0.8,
      );
    }

    return null;
  }

  /// 태그별 맞춤 제안
  String? _getSuggestionForTag(String symptomName, String tag) {
    // 증상 + 태그 조합에 따른 맞춤 제안
    final suggestionMap = {
      'me스꺼움': {
        '기름진음식': '담백한 음식부터 시작해보세요',
        '과식': '조금씩 나눠서 드시면 도움이 돼요',
        '공복': '가벼운 간식 후 투여해보세요',
      },
      '변비': {
        '수분부족': '물을 더 자주 드셔보세요',
        '운동부족': '가벼운 산책이 도움될 수 있어요',
      },
      '설사': {
        '기름진음식': '담백한 식단으로 바꿔보세요',
        '유제품': '유제품을 일시적으로 줄여보세요',
      },
    };

    return suggestionMap[symptomName]?[tag];
  }
}
