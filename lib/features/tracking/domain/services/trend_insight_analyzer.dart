import 'package:n06/features/daily_checkin/domain/entities/daily_checkin.dart';
import '../entities/trend_insight.dart';

/// 트렌드 인사이트 분석 서비스
///
/// 데일리 체크인 데이터를 분석하여 트렌드 인사이트 생성
class TrendInsightAnalyzer {
  /// 데일리 체크인 기반 트렌드 인사이트 생성
  TrendInsight analyze({
    required List<DailyCheckin> checkins,
    required List<DailyCheckin>? previousPeriodCheckins,
    required TrendPeriod period,
    required int consecutiveDays,
  }) {
    if (checkins.isEmpty) {
      return TrendInsight.empty(period);
    }

    final periodDays = period == TrendPeriod.weekly ? 7 : 30;

    // 1. 일별 컨디션 요약 생성
    final dailyConditions = _buildDailyConditions(checkins, period);

    // 2. 6개 질문별 트렌드 계산
    final questionTrends = _calculateQuestionTrends(
      checkins,
      previousPeriodCheckins,
      period,
    );

    // 3. 패턴 인사이트 생성
    final patternInsight = _generatePatternInsight(checkins, questionTrends);

    // 4. 전체 방향 평가
    final overallDirection = _evaluateOverallDirection(questionTrends);

    // 5. Red Flag 카운트
    final redFlagCount =
        checkins.where((c) => c.redFlagDetected != null).length;

    // 6. 평균 식욕 점수
    final appetiteScores =
        checkins.where((c) => c.appetiteScore != null).map((c) => c.appetiteScore!).toList();
    final averageAppetiteScore = appetiteScores.isEmpty
        ? null
        : appetiteScores.reduce((a, b) => a + b) / appetiteScores.length;

    // 7. 기록률 계산
    final completionRate = checkins.length / periodDays * 100;

    // 8. 요약 메시지 생성
    final summaryMessage = _generateSummaryMessage(
      questionTrends: questionTrends,
      overallDirection: overallDirection,
      period: period,
      redFlagCount: redFlagCount,
      completionRate: completionRate,
    );

    return TrendInsight(
      period: period,
      dailyConditions: dailyConditions,
      questionTrends: questionTrends,
      patternInsight: patternInsight,
      overallDirection: overallDirection,
      summaryMessage: summaryMessage,
      redFlagCount: redFlagCount,
      averageAppetiteScore: averageAppetiteScore,
      consecutiveDays: consecutiveDays,
      completionRate: completionRate.clamp(0, 100),
    );
  }

  /// 일별 컨디션 요약 생성
  List<DailyConditionSummary> _buildDailyConditions(
    List<DailyCheckin> checkins,
    TrendPeriod period,
  ) {
    final periodDays = period == TrendPeriod.weekly ? 7 : 30;
    final today = DateTime.now();
    final startDate = today.subtract(Duration(days: periodDays - 1));

    final checkinMap = <String, DailyCheckin>{};
    for (final checkin in checkins) {
      final key = _dateKey(checkin.checkinDate);
      checkinMap[key] = checkin;
    }

    final conditions = <DailyConditionSummary>[];
    for (var i = 0; i < periodDays; i++) {
      final date = startDate.add(Duration(days: i));
      final key = _dateKey(date);
      final checkin = checkinMap[key];

      if (checkin != null) {
        final score = _calculateOverallScore(checkin);
        conditions.add(DailyConditionSummary(
          date: date,
          overallScore: score,
          grade: _scoreToGrade(score),
          hasRedFlag: checkin.redFlagDetected != null,
          redFlagType: checkin.redFlagDetected?.type,
          hasCheckin: true,
          isPostInjection: checkin.context?.isPostInjection ?? false,
        ));
      } else {
        conditions.add(DailyConditionSummary(
          date: date,
          overallScore: 0,
          grade: ConditionGrade.bad,
          hasRedFlag: false,
          hasCheckin: false,
          isPostInjection: false,
        ));
      }
    }

    return conditions;
  }

  /// 체크인에서 전체 점수 계산 (0-100)
  /// 6개 항목의 평균 점수 (각 항목: good=100, moderate=50, bad=0)
  int _calculateOverallScore(DailyCheckin checkin) {
    final totalScore = _conditionLevelToScore(checkin.mealCondition) +
        _hydrationLevelToScore(checkin.hydrationLevel) +
        _giComfortLevelToScore(checkin.giComfort) +
        _bowelConditionToScore(checkin.bowelCondition) +
        _energyLevelToScore(checkin.energyLevel) +
        _moodLevelToScore(checkin.mood);

    // 6개 항목 평균
    var score = (totalScore / 6).round();

    // Red Flag 감점
    if (checkin.redFlagDetected != null) {
      score -= 20;
    }

    return score.clamp(0, 100);
  }

  /// 통일된 점수 체계: good=100, moderate=50, bad=0
  int _conditionLevelToScore(ConditionLevel level) {
    switch (level) {
      case ConditionLevel.good:
        return 100;
      case ConditionLevel.moderate:
        return 50;
      case ConditionLevel.difficult:
        return 0;
    }
  }

  int _hydrationLevelToScore(HydrationLevel level) {
    switch (level) {
      case HydrationLevel.good:
        return 100;
      case HydrationLevel.moderate:
        return 50;
      case HydrationLevel.poor:
        return 0;
    }
  }

  int _giComfortLevelToScore(GiComfortLevel level) {
    switch (level) {
      case GiComfortLevel.good:
        return 100;
      case GiComfortLevel.uncomfortable:
        return 50;
      case GiComfortLevel.veryUncomfortable:
        return 0;
    }
  }

  int _bowelConditionToScore(BowelCondition level) {
    switch (level) {
      case BowelCondition.normal:
        return 100;
      case BowelCondition.irregular:
        return 50;
      case BowelCondition.difficult:
        return 0;
    }
  }

  int _energyLevelToScore(EnergyLevel level) {
    switch (level) {
      case EnergyLevel.good:
        return 100;
      case EnergyLevel.normal:
        return 50;
      case EnergyLevel.tired:
        return 0;
    }
  }

  int _moodLevelToScore(MoodLevel level) {
    switch (level) {
      case MoodLevel.good:
        return 100;
      case MoodLevel.neutral:
        return 50;
      case MoodLevel.low:
        return 0;
    }
  }

  ConditionGrade _scoreToGrade(int score) {
    if (score >= 90) return ConditionGrade.excellent;
    if (score >= 70) return ConditionGrade.good;
    if (score >= 50) return ConditionGrade.fair;
    if (score >= 30) return ConditionGrade.poor;
    return ConditionGrade.bad;
  }

  /// 6개 질문별 트렌드 계산
  List<QuestionTrend> _calculateQuestionTrends(
    List<DailyCheckin> checkins,
    List<DailyCheckin>? previousCheckins,
    TrendPeriod period,
  ) {
    final periodDays = period == TrendPeriod.weekly ? 7 : 30;
    final today = DateTime.now();
    final startDate = today.subtract(Duration(days: periodDays - 1));

    final checkinMap = <String, DailyCheckin>{};
    for (final checkin in checkins) {
      checkinMap[_dateKey(checkin.checkinDate)] = checkin;
    }

    return [
      _buildQuestionTrend(
        QuestionType.meal,
        '식사',
        checkins,
        previousCheckins,
        (c) => _conditionLevelToScore(c.mealCondition),
        startDate,
        periodDays,
        checkinMap,
      ),
      _buildQuestionTrend(
        QuestionType.hydration,
        '수분',
        checkins,
        previousCheckins,
        (c) => _hydrationLevelToScore(c.hydrationLevel),
        startDate,
        periodDays,
        checkinMap,
      ),
      _buildQuestionTrend(
        QuestionType.giComfort,
        '속 편안함',
        checkins,
        previousCheckins,
        (c) => _giComfortLevelToScore(c.giComfort),
        startDate,
        periodDays,
        checkinMap,
      ),
      _buildQuestionTrend(
        QuestionType.bowel,
        '배변',
        checkins,
        previousCheckins,
        (c) => _bowelConditionToScore(c.bowelCondition),
        startDate,
        periodDays,
        checkinMap,
      ),
      _buildQuestionTrend(
        QuestionType.energy,
        '에너지',
        checkins,
        previousCheckins,
        (c) => _energyLevelToScore(c.energyLevel),
        startDate,
        periodDays,
        checkinMap,
      ),
      _buildQuestionTrend(
        QuestionType.mood,
        '기분',
        checkins,
        previousCheckins,
        (c) => _moodLevelToScore(c.mood),
        startDate,
        periodDays,
        checkinMap,
      ),
    ];
  }

  QuestionTrend _buildQuestionTrend(
    QuestionType type,
    String label,
    List<DailyCheckin> checkins,
    List<DailyCheckin>? previousCheckins,
    int Function(DailyCheckin) getScore,
    DateTime startDate,
    int periodDays,
    Map<String, DailyCheckin> checkinMap,
  ) {
    // 평균 점수 계산 (good=100, moderate=50, bad=0)
    final totalScore = checkins.fold<int>(0, (sum, c) => sum + getScore(c));
    final averageScore = checkins.isEmpty ? 0.0 : totalScore / checkins.length;

    // 이전 기간 대비 방향
    TrendDirection direction = TrendDirection.stable;
    if (previousCheckins != null && previousCheckins.isNotEmpty) {
      final prevTotalScore =
          previousCheckins.fold<int>(0, (sum, c) => sum + getScore(c));
      final prevAverageScore = prevTotalScore / previousCheckins.length;
      final diff = averageScore - prevAverageScore;

      if (diff > 10) {
        direction = TrendDirection.improving;
      } else if (diff < -10) {
        direction = TrendDirection.worsening;
      }
    }

    // 일별 상태
    final dailyStatuses = <DailyQuestionStatus>[];
    for (var i = 0; i < periodDays; i++) {
      final date = startDate.add(Duration(days: i));
      final key = _dateKey(date);
      final checkin = checkinMap[key];

      if (checkin != null) {
        dailyStatuses.add(DailyQuestionStatus(
          date: date,
          score: getScore(checkin),
          noData: false,
        ));
      } else {
        dailyStatuses.add(DailyQuestionStatus(
          date: date,
          score: 0,
          noData: true,
        ));
      }
    }

    return QuestionTrend(
      questionType: type,
      label: label,
      averageScore: averageScore,
      direction: direction,
      dailyStatuses: dailyStatuses,
    );
  }

  /// 패턴 인사이트 생성
  WeeklyPatternInsight _generatePatternInsight(
    List<DailyCheckin> checkins,
    List<QuestionTrend> questionTrends,
  ) {
    // 주사 후 패턴 분석
    final postInjectionCheckins =
        checkins.where((c) => c.context?.isPostInjection == true).toList();
    final hasPostInjectionPattern = postInjectionCheckins.length >= 2;

    String? postInjectionInsight;
    if (hasPostInjectionPattern) {
      // 주사 후 가장 흔한 문제 찾기
      final giIssues = postInjectionCheckins
          .where((c) => c.giComfort != GiComfortLevel.good)
          .length;
      final mealIssues = postInjectionCheckins
          .where((c) => c.mealCondition != ConditionLevel.good)
          .length;

      if (giIssues > mealIssues && giIssues >= 2) {
        postInjectionInsight =
            '주사 다음날 속이 불편한 경향이 있어요. 소화가 잘 되는 음식으로 드셔보세요.';
      } else if (mealIssues >= 2) {
        postInjectionInsight =
            '주사 후에는 식사가 어려운 경향이 있어요. 조금씩 나눠 드셔보세요.';
      }
    }

    // 가장 신경써야 할 영역 (평균 점수가 가장 낮은 것)
    QuestionType? topConcernArea;
    QuestionType? improvementArea;

    if (questionTrends.isNotEmpty) {
      final sorted = List<QuestionTrend>.from(questionTrends)
        ..sort((a, b) => a.averageScore.compareTo(b.averageScore));
      if (sorted.first.averageScore < 50) {
        topConcernArea = sorted.first.questionType;
      }

      // 개선된 영역
      final improving =
          questionTrends.where((t) => t.direction == TrendDirection.improving);
      if (improving.isNotEmpty) {
        improvementArea = improving.first.questionType;
      }
    }

    // 추천 사항
    final recommendations = <String>[];

    if (topConcernArea != null) {
      switch (topConcernArea) {
        case QuestionType.meal:
          recommendations.add('식사가 어려울 때는 조금씩 자주 드셔보세요');
          break;
        case QuestionType.hydration:
          recommendations.add('수분 섭취를 늘려보세요. 탈수 예방이 중요해요');
          break;
        case QuestionType.giComfort:
          recommendations.add('소화가 잘 되는 부드러운 음식을 드셔보세요');
          break;
        case QuestionType.bowel:
          recommendations.add('식이섬유와 충분한 수분 섭취를 해보세요');
          break;
        case QuestionType.energy:
          recommendations.add('충분한 휴식과 가벼운 산책을 추천드려요');
          break;
        case QuestionType.mood:
          recommendations.add('기분이 나아지지 않으면 전문가와 상담해보세요');
          break;
      }
    }

    if (improvementArea != null) {
      final label = questionTrends
          .firstWhere((t) => t.questionType == improvementArea)
          .label;
      recommendations.add('$label 상태가 좋아지고 있어요! 계속 유지해주세요');
    }

    return WeeklyPatternInsight(
      hasPostInjectionPattern: hasPostInjectionPattern,
      postInjectionInsight: postInjectionInsight,
      topConcernArea: topConcernArea,
      improvementArea: improvementArea,
      recommendations: recommendations,
    );
  }

  /// 전체 방향 평가
  TrendDirection _evaluateOverallDirection(List<QuestionTrend> questionTrends) {
    if (questionTrends.isEmpty) return TrendDirection.stable;

    int improvingCount = 0;
    int worseningCount = 0;

    for (final trend in questionTrends) {
      if (trend.direction == TrendDirection.improving) {
        improvingCount++;
      } else if (trend.direction == TrendDirection.worsening) {
        worseningCount++;
      }
    }

    if (improvingCount > worseningCount && improvingCount >= 2) {
      return TrendDirection.improving;
    } else if (worseningCount > improvingCount && worseningCount >= 2) {
      return TrendDirection.worsening;
    }

    return TrendDirection.stable;
  }

  /// 요약 메시지 생성
  String _generateSummaryMessage({
    required List<QuestionTrend> questionTrends,
    required TrendDirection overallDirection,
    required TrendPeriod period,
    required int redFlagCount,
    required double completionRate,
  }) {
    final periodText = period == TrendPeriod.weekly ? '이번 주' : '이번 달';

    if (completionRate < 30) {
      return '$periodText 기록이 부족해요. 매일 체크인으로 컨디션을 관리해보세요!';
    }

    if (redFlagCount > 0) {
      return '$periodText 주의가 필요한 증상이 ${redFlagCount}회 있었어요. 상태를 확인해주세요.';
    }

    // 가장 좋은 영역과 나쁜 영역 찾기
    final sorted = List<QuestionTrend>.from(questionTrends)
      ..sort((a, b) => b.averageScore.compareTo(a.averageScore));
    final best = sorted.isNotEmpty ? sorted.first : null;
    final worst = sorted.isNotEmpty ? sorted.last : null;

    switch (overallDirection) {
      case TrendDirection.improving:
        return '$periodText 컨디션이 좋아지고 있어요! 잘하고 계세요.';
      case TrendDirection.worsening:
        if (worst != null && worst.averageScore < 50) {
          return '$periodText ${worst.label} 상태가 조금 걱정되네요. 관리가 필요해요.';
        }
        return '$periodText 컨디션이 조금 떨어졌어요. 몸 관리에 신경써주세요.';
      case TrendDirection.stable:
        if (best != null && best.averageScore >= 80) {
          return '$periodText ${best.label} 상태가 특히 좋았어요! 유지해주세요.';
        }
        return '$periodText 컨디션이 안정적이에요. 계속 유지해주세요!';
    }
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
