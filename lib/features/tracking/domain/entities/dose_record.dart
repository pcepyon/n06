import 'package:equatable/equatable.dart';

const List<String> validInjectionSites = ['abdomen', 'thigh', 'arm'];

class DoseRecord extends Equatable {
  final String id;
  final String? doseScheduleId;
  final String dosagePlanId;
  final DateTime administeredAt;
  final double actualDoseMg;
  final String? injectionSite; // abdomen, thigh, arm
  final bool isCompleted;
  final String? note;
  final DateTime createdAt;

  DoseRecord({
    required this.id,
    this.doseScheduleId,
    required this.dosagePlanId,
    required this.administeredAt,
    required this.actualDoseMg,
    this.injectionSite,
    this.isCompleted = true,
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now() {
    _validate();
  }

  void _validate() {
    // Validate administered date is not in future
    if (administeredAt.isAfter(DateTime.now())) {
      throw ArgumentError('Administered date cannot be in the future');
    }

    // Validate actual dose
    if (actualDoseMg < 0) {
      throw ArgumentError('Actual dose cannot be negative');
    }

    // Validate injection site if provided
    if (injectionSite != null && !validInjectionSites.contains(injectionSite)) {
      throw ArgumentError(
        'Invalid injection site. Must be one of: ${validInjectionSites.join(", ")}',
      );
    }
  }

  /// Calculate days since administration
  int daysSinceAdministration() {
    final now = DateTime.now();
    return now.difference(administeredAt).inDays;
  }

  @override
  List<Object?> get props => [
    id,
    doseScheduleId,
    dosagePlanId,
    administeredAt,
    actualDoseMg,
    injectionSite,
    isCompleted,
    note,
    createdAt,
  ];

  DoseRecord copyWith({
    String? id,
    String? doseScheduleId,
    String? dosagePlanId,
    DateTime? administeredAt,
    double? actualDoseMg,
    String? injectionSite,
    bool? isCompleted,
    String? note,
    DateTime? createdAt,
  }) {
    return DoseRecord(
      id: id ?? this.id,
      doseScheduleId: doseScheduleId ?? this.doseScheduleId,
      dosagePlanId: dosagePlanId ?? this.dosagePlanId,
      administeredAt: administeredAt ?? this.administeredAt,
      actualDoseMg: actualDoseMg ?? this.actualDoseMg,
      injectionSite: injectionSite ?? this.injectionSite,
      isCompleted: isCompleted ?? this.isCompleted,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
