/// 대시보드 메시지 타입
///
/// 대시보드에 표시되는 각종 메시지의 종류를 정의합니다.
/// Application Layer에서 컨텍스트를 판단하여 타입을 반환하고,
/// Presentation Layer에서 i18n 문자열로 매핑합니다.
enum DashboardMessageType {
  /// 에러: 인증되지 않은 사용자
  errorNotAuthenticated,

  /// 에러: 프로필 없음 (온보딩 필요)
  errorProfileNotFound,

  /// 에러: 활성 투여 계획 없음
  errorActivePlanNotFound,

  /// 타임라인: 치료 시작
  timelineTreatmentStart,

  /// 타임라인: 용량 증량
  timelineEscalation,

  /// 타임라인: 체중 마일스톤 (25%, 50%, 75%, 100%)
  timelineWeightMilestone,

  /// 인사이트: 30일 연속 기록 달성
  insight30DaysStreak,

  /// 인사이트: 7일 이상 연속 기록
  insightWeeklyStreak,

  /// 인사이트: 체중 감량 10% 달성
  insightWeight10Percent,

  /// 인사이트: 체중 감량 5% 달성
  insightWeight5Percent,

  /// 인사이트: 체중 감량 1% 달성
  insightWeight1Percent,

  /// 인사이트: 기록 지속 격려
  insightKeepRecording,

  /// 인사이트: 첫 기록 권장
  insightFirstRecord,
}

/// 타임라인 이벤트 데이터
///
/// 타임라인 메시지 생성에 필요한 동적 데이터를 담습니다.
class TimelineEventData {
  final DashboardMessageType type;
  final String? doseMg;
  final int? milestonePercent;
  final String? weightKg;

  const TimelineEventData({
    required this.type,
    this.doseMg,
    this.milestonePercent,
    this.weightKg,
  });
}

/// 인사이트 메시지 데이터
///
/// 인사이트 메시지 생성에 필요한 동적 데이터를 담습니다.
class InsightMessageData {
  final DashboardMessageType type;
  final int? continuousRecordDays;

  const InsightMessageData({
    required this.type,
    this.continuousRecordDays,
  });
}
