import 'package:equatable/equatable.dart';

const List<String> validInjectionSites = [
  'abdomen_upper_left',   // 복부 좌측상단
  'abdomen_upper_right',  // 복부 우측상단
  'abdomen_lower_left',   // 복부 좌측하단
  'abdomen_lower_right',  // 복부 우측하단
  'thigh_left',           // 허벅지 좌
  'thigh_right',          // 허벅지 우
  'arm_left',             // 상완 좌
  'arm_right',            // 상완 우
];

/// Helper function for display labels
String getInjectionSiteLabel(String siteCode) {
  const labels = {
    'abdomen_upper_left': '복부 좌측상단',
    'abdomen_upper_right': '복부 우측상단',
    'abdomen_lower_left': '복부 좌측하단',
    'abdomen_lower_right': '복부 우측하단',
    'thigh_left': '허벅지 좌측',
    'thigh_right': '허벅지 우측',
    'arm_left': '상완 좌측',
    'arm_right': '상완 우측',
  };
  return labels[siteCode] ?? siteCode;
}

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

  /// Calculate days since administration (날짜만 비교, 시간 제외)
  int daysSinceAdministration() {
    final now = DateTime.now();
    final nowDate = DateTime(now.year, now.month, now.day);
    final doseDate = DateTime(administeredAt.year, administeredAt.month, administeredAt.day);
    return nowDate.difference(doseDate).inDays;
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
