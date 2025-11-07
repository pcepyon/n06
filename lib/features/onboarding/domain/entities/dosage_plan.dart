import 'package:n06/features/onboarding/domain/value_objects/medication_name.dart';
import 'package:n06/features/onboarding/domain/value_objects/start_date.dart';
import 'escalation_step.dart';

/// 투여 계획을 나타내는 Entity
class DosagePlan {
  final String id;
  final String userId;
  final MedicationName medicationName;
  final StartDate startDate;
  final int cycleDays;
  final double initialDoseMg;
  final List<EscalationStep>? escalationPlan;
  final bool isActive;

  /// DosagePlan을 생성한다.
  /// cycleDays와 initialDoseMg는 양수여야 한다.
  DosagePlan({
    required this.id,
    required this.userId,
    required this.medicationName,
    required this.startDate,
    required this.cycleDays,
    required this.initialDoseMg,
    this.escalationPlan,
    this.isActive = true,
  }) {
    if (cycleDays <= 0) {
      throw ArgumentError('주기(cycleDays)는 양수여야 합니다.');
    }
    if (initialDoseMg <= 0) {
      throw ArgumentError('초기 용량(initialDoseMg)은 양수여야 합니다.');
    }
  }

  /// 현재 DosagePlan의 일부 필드를 변경한 새로운 DosagePlan을 반환한다.
  DosagePlan copyWith({
    String? id,
    String? userId,
    MedicationName? medicationName,
    StartDate? startDate,
    int? cycleDays,
    double? initialDoseMg,
    List<EscalationStep>? escalationPlan,
    bool? isActive,
  }) {
    return DosagePlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      medicationName: medicationName ?? this.medicationName,
      startDate: startDate ?? this.startDate,
      cycleDays: cycleDays ?? this.cycleDays,
      initialDoseMg: initialDoseMg ?? this.initialDoseMg,
      escalationPlan: escalationPlan ?? this.escalationPlan,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DosagePlan &&
        other.id == id &&
        other.userId == userId &&
        other.medicationName == medicationName &&
        other.startDate == startDate &&
        other.cycleDays == cycleDays &&
        other.initialDoseMg == initialDoseMg &&
        other.isActive == isActive;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      medicationName.hashCode ^
      startDate.hashCode ^
      cycleDays.hashCode ^
      initialDoseMg.hashCode ^
      isActive.hashCode;

  @override
  String toString() =>
      'DosagePlan(id: $id, medicationName: ${medicationName.value}, cycleDays: $cycleDays)';
}
