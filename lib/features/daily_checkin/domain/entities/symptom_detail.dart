import 'package:equatable/equatable.dart';

/// 증상 타입 (정규화된 값)
///
/// 데일리 체크인의 파생 질문에서 수집되는 증상 유형입니다.
/// JSONB symptom_details의 type 필드에 저장됩니다.
enum SymptomType {
  nausea, // 메스꺼움
  vomiting, // 구토
  lowAppetite, // 입맛 없음
  earlySatiety, // 조기 포만감
  heartburn, // 속쓰림
  abdominalPain, // 복통
  bloating, // 복부 팽만
  constipation, // 변비
  diarrhea, // 설사
  fatigue, // 피로
  dizziness, // 어지러움
  coldSweat, // 식은땀
  swelling, // 부종
}

/// 파생 증상 상세 정보
///
/// JSONB 구조:
/// ```json
/// {
///   "type": "nausea",        // SymptomType enum 값
///   "severity": 2,           // 1(mild), 2(moderate), 3(severe)
///   "details": {             // 증상별 추가 필드 (nullable)
///     "vomit_count": 2,
///     "duration_hours": 4
///   }
/// }
/// ```
///
/// 증상별 details 필드:
///
/// 복통 (abdominalPain):
/// - location: "upper" | "right_upper" | "lower" | "around_navel"
/// - radiates_to_back: bool (췌장염 지표)
/// - duration_hours: int
///
/// 구토 (vomiting):
/// - vomit_count: int (횟수)
/// - can_keep_water: bool (물 마실 수 있는지)
///
/// 변비 (constipation):
/// - days_without: int (변비 일수)
/// - has_gas: bool (가스 배출 여부)
///
class SymptomDetail extends Equatable {
  final SymptomType type;
  final int severity; // 1-3 (mild/moderate/severe)
  final Map<String, dynamic>? details;

  const SymptomDetail({
    required this.type,
    required this.severity,
    this.details,
  }) : assert(severity >= 1 && severity <= 3);

  SymptomDetail copyWith({
    SymptomType? type,
    int? severity,
    Map<String, dynamic>? details,
  }) {
    return SymptomDetail(
      type: type ?? this.type,
      severity: severity ?? this.severity,
      details: details ?? this.details,
    );
  }

  /// JSON 검증
  static bool isValidJson(Map<String, dynamic> json) {
    return json.containsKey('type') &&
        json.containsKey('severity') &&
        json['severity'] is int &&
        json['severity'] >= 1 &&
        json['severity'] <= 3;
  }

  @override
  List<Object?> get props => [type, severity, details];

  @override
  String toString() => 'SymptomDetail('
      'type: $type, '
      'severity: $severity, '
      'details: $details'
      ')';
}
