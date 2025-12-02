import 'package:equatable/equatable.dart';

/// Red Flag 타입
///
/// GLP-1 치료에서 주의 깊게 모니터링해야 할 잠재적 위험 상황입니다.
/// 체크인 응답을 기반으로 자동 감지되며, 사용자에게 부드럽게 안내합니다.
enum RedFlagType {
  pancreatitis, // 급성 췌장염
  cholecystitis, // 담낭염
  severeDehydration, // 심한 탈수
  bowelObstruction, // 장폐색
  hypoglycemia, // 저혈당
  renalImpairment, // 신부전
}

/// Red Flag 심각도
enum RedFlagSeverity {
  warning, // 확인 권유 수준
  urgent, // 당일 확인 필요
}

/// Red Flag 감지 결과
///
/// JSONB 구조:
/// ```json
/// {
///   "type": "pancreatitis",
///   "severity": "warning",
///   "symptoms": ["severe_abdominal_pain", "radiates_to_back"],
///   "notified_at": "2025-12-02T10:30:00Z",
///   "user_action": "dismissed"
/// }
/// ```
///
/// Red Flag 감지 조건:
///
/// 급성 췌장염 (pancreatitis):
/// - Q3(속 편안함) → 배 아픔 → 상복부
/// - 심한 통증(severity=3) + 등 방사 + 수시간 지속
///
/// 담낭염 (cholecystitis):
/// - Q3 → 배 아픔 → 우상복부
/// - 심한 통증 + 발열/오한
///
/// 심한 탈수 (severeDehydration):
/// - Q1 → 구토 + Q2 → 못 마심
/// - 구토 3회+ AND 물 못 마심
///
/// 장폐색 (bowelObstruction):
/// - Q4 → 변비
/// - 5일+ 변비 + 심한 빵빵함 + 가스 없음
///
/// 저혈당 (hypoglycemia):
/// - Q5 → 어지러움 + 식은땀
/// - 증상 + 당뇨약 병용
///
/// 신부전 (renalImpairment):
/// - Q5 → 피로 + 붓기
/// - 심한 피로 + 부종 + 소변 감소
///
class RedFlagDetection extends Equatable {
  final RedFlagType type;
  final RedFlagSeverity severity;

  /// 감지된 증상 목록 (스네이크 케이스 문자열)
  /// 예: ["severe_abdominal_pain", "radiates_to_back"]
  final List<String> symptoms;

  /// 사용자에게 안내한 시간
  final DateTime? notifiedAt;

  /// 사용자 행동
  /// "dismissed" | "hospital_search" | null
  final String? userAction;

  const RedFlagDetection({
    required this.type,
    required this.severity,
    required this.symptoms,
    this.notifiedAt,
    this.userAction,
  });

  RedFlagDetection copyWith({
    RedFlagType? type,
    RedFlagSeverity? severity,
    List<String>? symptoms,
    DateTime? notifiedAt,
    String? userAction,
  }) {
    return RedFlagDetection(
      type: type ?? this.type,
      severity: severity ?? this.severity,
      symptoms: symptoms ?? this.symptoms,
      notifiedAt: notifiedAt ?? this.notifiedAt,
      userAction: userAction ?? this.userAction,
    );
  }

  @override
  List<Object?> get props => [
        type,
        severity,
        symptoms,
        notifiedAt,
        userAction,
      ];

  @override
  String toString() => 'RedFlagDetection('
      'type: $type, '
      'severity: $severity, '
      'symptoms: $symptoms, '
      'notifiedAt: $notifiedAt, '
      'userAction: $userAction'
      ')';
}
