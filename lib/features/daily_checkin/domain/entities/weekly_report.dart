import 'package:equatable/equatable.dart';

/// 주간 리포트 엔티티
///
/// 의료진과 공유할 수 있는 구조화된 주간 데이터
class WeeklyReport extends Equatable {
  /// 사용자 ID
  final String userId;

  /// 리포트 기간 시작
  final DateTime periodStart;

  /// 리포트 기간 종료
  final DateTime periodEnd;

  /// 사용자 이름 (표시용)
  final String? userName;

  /// 약제 이름 (예: 위고비 0.5mg)
  final String? medicationName;

  /// 체중 관련 데이터
  final WeightSummary? weightSummary;

  /// 식욕 관련 데이터
  final AppetiteSummary appetiteSummary;

  /// 체크인 달성률
  final CheckinAchievement checkinAchievement;

  /// 증상 발생 현황
  final List<SymptomOccurrence> symptomOccurrences;

  /// Red Flag 기록 (있는 경우)
  final List<RedFlagRecord> redFlagRecords;

  /// 컨디션 추이 (일별 기분/컨디션)
  final List<DailyCondition> dailyConditions;

  /// 리포트 생성 시각
  final DateTime generatedAt;

  const WeeklyReport({
    required this.userId,
    required this.periodStart,
    required this.periodEnd,
    this.userName,
    this.medicationName,
    this.weightSummary,
    required this.appetiteSummary,
    required this.checkinAchievement,
    required this.symptomOccurrences,
    required this.redFlagRecords,
    required this.dailyConditions,
    required this.generatedAt,
  });

  @override
  List<Object?> get props => [
        userId,
        periodStart,
        periodEnd,
        userName,
        medicationName,
        weightSummary,
        appetiteSummary,
        checkinAchievement,
        symptomOccurrences,
        redFlagRecords,
        dailyConditions,
        generatedAt,
      ];
}

/// 체중 요약
class WeightSummary extends Equatable {
  /// 시작 체중
  final double startWeight;

  /// 종료 체중
  final double endWeight;

  /// 변화량 (kg)
  final double change;

  const WeightSummary({
    required this.startWeight,
    required this.endWeight,
    required this.change,
  });

  /// 변화 방향 표시 문자열
  String get changeString {
    if (change > 0) {
      return '▲${change.abs().toStringAsFixed(1)}kg';
    } else if (change < 0) {
      return '▼${change.abs().toStringAsFixed(1)}kg';
    }
    return '→ 유지';
  }

  @override
  List<Object?> get props => [startWeight, endWeight, change];
}

/// 식욕 요약
class AppetiteSummary extends Equatable {
  /// 평균 식욕 점수 (1-5)
  final double averageScore;

  /// 안정도 (stable, improving, declining)
  final String stability;

  const AppetiteSummary({
    required this.averageScore,
    required this.stability,
  });

  String get stabilityKorean {
    switch (stability) {
      case 'stable':
        return '안정적';
      case 'improving':
        return '개선 중';
      case 'declining':
        return '감소 중';
      default:
        return stability;
    }
  }

  @override
  List<Object?> get props => [averageScore, stability];
}

/// 체크인 달성률
class CheckinAchievement extends Equatable {
  /// 체크인한 일수
  final int checkinDays;

  /// 전체 일수 (7일)
  final int totalDays;

  /// 달성률 (%)
  final int percentage;

  const CheckinAchievement({
    required this.checkinDays,
    required this.totalDays,
    required this.percentage,
  });

  @override
  List<Object?> get props => [checkinDays, totalDays, percentage];
}

/// 증상 발생 현황
class SymptomOccurrence extends Equatable {
  /// 증상 이름
  final String symptomName;

  /// 발생 일수
  final int daysOccurred;

  /// 심각도별 횟수
  final Map<String, int> severityCounts; // mild, moderate, severe

  const SymptomOccurrence({
    required this.symptomName,
    required this.daysOccurred,
    required this.severityCounts,
  });

  /// 심각도 요약 문자열
  String get severitySummary {
    final parts = <String>[];
    if (severityCounts['mild'] != null && severityCounts['mild']! > 0) {
      parts.add('경미${severityCounts['mild']}');
    }
    if (severityCounts['moderate'] != null && severityCounts['moderate']! > 0) {
      parts.add('중등도${severityCounts['moderate']}');
    }
    if (severityCounts['severe'] != null && severityCounts['severe']! > 0) {
      parts.add('심각${severityCounts['severe']}');
    }
    return parts.isEmpty ? '' : '(${parts.join(', ')})';
  }

  @override
  List<Object?> get props => [symptomName, daysOccurred, severityCounts];
}

/// Red Flag 기록
class RedFlagRecord extends Equatable {
  /// 발생 날짜
  final DateTime date;

  /// Red Flag 타입
  final String type;

  /// 요약
  final String summary;

  /// 사용자 액션
  final String? userAction;

  const RedFlagRecord({
    required this.date,
    required this.type,
    required this.summary,
    this.userAction,
  });

  @override
  List<Object?> get props => [date, type, summary, userAction];
}

/// 일별 컨디션
class DailyCondition extends Equatable {
  /// 날짜
  final DateTime date;

  /// 요일 (월, 화, ...)
  final String dayOfWeek;

  /// 컨디션 이모지
  final String emoji;

  /// 체크인 여부
  final bool hasCheckin;

  const DailyCondition({
    required this.date,
    required this.dayOfWeek,
    required this.emoji,
    required this.hasCheckin,
  });

  @override
  List<Object?> get props => [date, dayOfWeek, emoji, hasCheckin];
}
