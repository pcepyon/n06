import 'package:n06/features/onboarding/domain/value_objects/weight.dart';

/// 체중 기록을 나타내는 Entity
class WeightLog {
  final String id;
  final String userId;
  final DateTime logDate;
  final Weight weight;
  final DateTime createdAt;

  /// WeightLog를 생성한다.
  WeightLog({
    required this.id,
    required this.userId,
    required this.logDate,
    required this.weight,
    required this.createdAt,
  });

  /// 현재 WeightLog의 일부 필드를 변경한 새로운 WeightLog을 반환한다.
  WeightLog copyWith({
    String? id,
    String? userId,
    DateTime? logDate,
    Weight? weight,
    DateTime? createdAt,
  }) {
    return WeightLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      logDate: logDate ?? this.logDate,
      weight: weight ?? this.weight,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WeightLog &&
        other.id == id &&
        other.userId == userId &&
        other.logDate == logDate &&
        other.weight == weight &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      logDate.hashCode ^
      weight.hashCode ^
      createdAt.hashCode;

  @override
  String toString() =>
      'WeightLog(id: $id, weight: ${weight.value}kg, logDate: $logDate)';
}
