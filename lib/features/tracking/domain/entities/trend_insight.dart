import 'package:flutter/foundation.dart';

import 'package:n06/features/daily_checkin/domain/entities/red_flag_detection.dart';

/// 트렌드 인사이트 엔티티
///
/// 데일리 체크인 기반 주간/월간 트렌드 분석 결과
@immutable
class TrendInsight {
  final TrendPeriod period;

  /// 일별 컨디션 요약 (캘린더용)
  final List<DailyConditionSummary> dailyConditions;

  /// 6개 질문별 트렌드
  final List<QuestionTrend> questionTrends;

  /// 주간 패턴 인사이트
  final WeeklyPatternInsight patternInsight;

  /// 전체 방향
  final TrendDirection overallDirection;

  /// 요약 메시지
  final String summaryMessage;

  /// 기간 내 Red Flag 발생 횟수
  final int redFlagCount;

  /// 평균 식욕 점수
  final double? averageAppetiteScore;

  /// 연속 기록 일수
  final int consecutiveDays;

  /// 기록률 (기간 내 체크인 완료 비율)
  final double completionRate;

  const TrendInsight({
    required this.period,
    required this.dailyConditions,
    required this.questionTrends,
    required this.patternInsight,
    required this.overallDirection,
    required this.summaryMessage,
    required this.redFlagCount,
    this.averageAppetiteScore,
    required this.consecutiveDays,
    required this.completionRate,
  });

  /// 빈 인사이트 생성
  factory TrendInsight.empty(TrendPeriod period) {
    return TrendInsight(
      period: period,
      dailyConditions: const [],
      questionTrends: const [],
      patternInsight: const WeeklyPatternInsight(
        hasPostInjectionPattern: false,
        postInjectionInsight: null,
        topConcernArea: null,
        improvementArea: null,
        recommendations: [],
      ),
      overallDirection: TrendDirection.stable,
      summaryMessage: '아직 기록이 없어요. 오늘부터 시작해보세요!',
      redFlagCount: 0,
      averageAppetiteScore: null,
      consecutiveDays: 0,
      completionRate: 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrendInsight &&
          runtimeType == other.runtimeType &&
          period == other.period &&
          listEquals(dailyConditions, other.dailyConditions) &&
          listEquals(questionTrends, other.questionTrends) &&
          patternInsight == other.patternInsight &&
          overallDirection == other.overallDirection &&
          summaryMessage == other.summaryMessage;

  @override
  int get hashCode =>
      period.hashCode ^
      Object.hashAll(dailyConditions) ^
      Object.hashAll(questionTrends) ^
      patternInsight.hashCode ^
      overallDirection.hashCode ^
      summaryMessage.hashCode;
}

/// 일별 컨디션 요약 (캘린더 셀용)
@immutable
class DailyConditionSummary {
  final DateTime date;

  /// 전반적 컨디션 점수 (0-100)
  final int overallScore;

  /// 컨디션 레벨
  final ConditionGrade grade;

  /// Red Flag 발생 여부
  final bool hasRedFlag;

  /// Red Flag 타입 (있을 경우)
  final RedFlagType? redFlagType;

  /// 체크인 완료 여부
  final bool hasCheckin;

  /// 주사 후 상태인지
  final bool isPostInjection;

  const DailyConditionSummary({
    required this.date,
    required this.overallScore,
    required this.grade,
    required this.hasRedFlag,
    this.redFlagType,
    required this.hasCheckin,
    required this.isPostInjection,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyConditionSummary &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          overallScore == other.overallScore &&
          grade == other.grade &&
          hasRedFlag == other.hasRedFlag;

  @override
  int get hashCode =>
      date.hashCode ^
      overallScore.hashCode ^
      grade.hashCode ^
      hasRedFlag.hashCode;
}

/// 컨디션 등급
enum ConditionGrade {
  excellent, // 90-100: 아주 좋음
  good, // 70-89: 좋음
  fair, // 50-69: 보통
  poor, // 30-49: 주의
  bad, // 0-29: 나쁨
}

/// 질문별 트렌드
@immutable
class QuestionTrend {
  /// 질문 타입
  final QuestionType questionType;

  /// 질문 라벨
  final String label;

  /// "good" 비율 (0-100)
  final double goodRate;

  /// 지난 기간 대비 변화
  final TrendDirection direction;

  /// 일별 상태 (차트용)
  final List<DailyQuestionStatus> dailyStatuses;

  const QuestionTrend({
    required this.questionType,
    required this.label,
    required this.goodRate,
    required this.direction,
    required this.dailyStatuses,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionTrend &&
          runtimeType == other.runtimeType &&
          questionType == other.questionType &&
          goodRate == other.goodRate &&
          direction == other.direction;

  @override
  int get hashCode =>
      questionType.hashCode ^ goodRate.hashCode ^ direction.hashCode;
}

/// 질문 타입
enum QuestionType {
  meal, // 식사
  hydration, // 수분
  giComfort, // 속 편안함
  bowel, // 배변
  energy, // 에너지
  mood, // 기분
}

/// 일별 질문 상태
@immutable
class DailyQuestionStatus {
  final DateTime date;

  /// 상태 값 (0: bad, 1: moderate, 2: good)
  final int statusValue;

  /// 체크인 없음
  final bool noData;

  const DailyQuestionStatus({
    required this.date,
    required this.statusValue,
    this.noData = false,
  });
}

/// 주간 패턴 인사이트
@immutable
class WeeklyPatternInsight {
  /// 주사 후 패턴이 있는지
  final bool hasPostInjectionPattern;

  /// 주사 후 인사이트 메시지
  final String? postInjectionInsight;

  /// 가장 신경써야 할 영역
  final QuestionType? topConcernArea;

  /// 개선된 영역
  final QuestionType? improvementArea;

  /// 추천 사항
  final List<String> recommendations;

  const WeeklyPatternInsight({
    required this.hasPostInjectionPattern,
    this.postInjectionInsight,
    this.topConcernArea,
    this.improvementArea,
    required this.recommendations,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyPatternInsight &&
          runtimeType == other.runtimeType &&
          hasPostInjectionPattern == other.hasPostInjectionPattern &&
          topConcernArea == other.topConcernArea &&
          improvementArea == other.improvementArea;

  @override
  int get hashCode =>
      hasPostInjectionPattern.hashCode ^
      topConcernArea.hashCode ^
      improvementArea.hashCode;
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

// 이전 버전 호환을 위한 deprecated 클래스들
@Deprecated('Use QuestionTrend instead')
class SymptomFrequency {
  final String symptomName;
  final int count;
  final double percentageOfTotal;

  const SymptomFrequency({
    required this.symptomName,
    required this.count,
    required this.percentageOfTotal,
  });
}

@Deprecated('Use QuestionTrend instead')
class SeverityTrend {
  final String symptomName;
  final List<double> dailyAverages;
  final TrendDirection direction;

  const SeverityTrend({
    required this.symptomName,
    required this.dailyAverages,
    required this.direction,
  });
}
