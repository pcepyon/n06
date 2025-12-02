import 'package:equatable/equatable.dart';

/// 체크인 컨텍스트 정보
///
/// JSONB 구조:
/// ```json
/// {
///   "is_post_injection": true,
///   "days_since_last_checkin": 1,
///   "consecutive_days": 5,
///   "greeting_type": "morning",
///   "weight_skipped": true
/// }
/// ```
///
/// 이 정보는 시간대별 인사, 주사 다음날 맞춤 질문,
/// 복귀 사용자 환영 등 감정적 UX 제공에 활용됩니다.
///
class CheckinContext extends Equatable {
  /// 주사 다음날 여부
  /// dose_records 테이블의 administered_at 기준으로 판정
  final bool isPostInjection;

  /// 마지막 체크인 이후 일수
  /// 3일 이상이면 복귀 사용자 환영 메시지 표시
  final int daysSinceLastCheckin;

  /// 연속 체크인 일수
  /// 3일, 7일, 14일, 21일, 30일 마일스톤 축하에 활용
  final int consecutiveDays;

  /// 인사 타입 (시간대별)
  /// "morning" | "afternoon" | "evening" | "night"
  final String? greetingType;

  /// 체중 입력 건너뛰기 여부
  /// true이면 체중 기록 없이 체크인만 완료한 경우
  final bool weightSkipped;

  const CheckinContext({
    required this.isPostInjection,
    required this.daysSinceLastCheckin,
    required this.consecutiveDays,
    this.greetingType,
    required this.weightSkipped,
  });

  CheckinContext copyWith({
    bool? isPostInjection,
    int? daysSinceLastCheckin,
    int? consecutiveDays,
    String? greetingType,
    bool? weightSkipped,
  }) {
    return CheckinContext(
      isPostInjection: isPostInjection ?? this.isPostInjection,
      daysSinceLastCheckin:
          daysSinceLastCheckin ?? this.daysSinceLastCheckin,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      greetingType: greetingType ?? this.greetingType,
      weightSkipped: weightSkipped ?? this.weightSkipped,
    );
  }

  @override
  List<Object?> get props => [
        isPostInjection,
        daysSinceLastCheckin,
        consecutiveDays,
        greetingType,
        weightSkipped,
      ];

  @override
  String toString() => 'CheckinContext('
      'isPostInjection: $isPostInjection, '
      'daysSinceLastCheckin: $daysSinceLastCheckin, '
      'consecutiveDays: $consecutiveDays, '
      'greetingType: $greetingType, '
      'weightSkipped: $weightSkipped'
      ')';
}
