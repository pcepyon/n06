import 'package:equatable/equatable.dart';

/// F005: 증상 체크 기록의 비즈니스 모델
///
/// 사용자가 긴급 증상 체크리스트에서 선택한 증상 정보를 나타냅니다.
/// - 체크 일시 (checkedAt)
/// - 선택된 증상 목록 (checkedSymptoms)
class EmergencySymptomCheck extends Equatable {
  /// 고유 식별자
  final String id;

  /// 사용자 ID
  final String userId;

  /// 증상 체크 일시 (timezone 포함)
  final DateTime checkedAt;

  /// 선택된 증상 목록
  final List<String> checkedSymptoms;

  const EmergencySymptomCheck({
    required this.id,
    required this.userId,
    required this.checkedAt,
    required this.checkedSymptoms,
  });

  /// 필드 수정하여 새로운 인스턴스 생성 (불변성 보장)
  EmergencySymptomCheck copyWith({
    String? id,
    String? userId,
    DateTime? checkedAt,
    List<String>? checkedSymptoms,
  }) {
    return EmergencySymptomCheck(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      checkedAt: checkedAt ?? this.checkedAt,
      checkedSymptoms: checkedSymptoms ?? this.checkedSymptoms,
    );
  }

  @override
  List<Object?> get props => [id, userId, checkedAt, checkedSymptoms];

  @override
  String toString() =>
      'EmergencySymptomCheck(id: $id, userId: $userId, checkedAt: $checkedAt, checkedSymptoms: $checkedSymptoms)';
}
