/// 투여 스케줄을 나타내는 Entity
class DoseSchedule {
  final String id;
  final String userId;
  final String dosagePlanId;
  final DateTime scheduledDate;
  final double scheduledDoseMg;
  final String? notificationTime;

  /// DoseSchedule을 생성한다.
  /// scheduledDoseMg는 양수여야 한다.
  DoseSchedule({
    required this.id,
    required this.userId,
    required this.dosagePlanId,
    required this.scheduledDate,
    required this.scheduledDoseMg,
    this.notificationTime,
  }) {
    if (scheduledDoseMg <= 0) {
      throw ArgumentError('용량(scheduledDoseMg)은 양수여야 합니다.');
    }
  }

  /// 현재 DoseSchedule의 일부 필드를 변경한 새로운 DoseSchedule을 반환한다.
  DoseSchedule copyWith({
    String? id,
    String? userId,
    String? dosagePlanId,
    DateTime? scheduledDate,
    double? scheduledDoseMg,
    String? notificationTime,
  }) {
    return DoseSchedule(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dosagePlanId: dosagePlanId ?? this.dosagePlanId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledDoseMg: scheduledDoseMg ?? this.scheduledDoseMg,
      notificationTime: notificationTime ?? this.notificationTime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DoseSchedule &&
        other.id == id &&
        other.userId == userId &&
        other.dosagePlanId == dosagePlanId &&
        other.scheduledDate == scheduledDate &&
        other.scheduledDoseMg == scheduledDoseMg;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      dosagePlanId.hashCode ^
      scheduledDate.hashCode ^
      scheduledDoseMg.hashCode;

  @override
  String toString() =>
      'DoseSchedule(id: $id, scheduledDate: $scheduledDate, doseMg: $scheduledDoseMg)';
}
