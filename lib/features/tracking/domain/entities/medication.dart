import 'package:equatable/equatable.dart';

/// GLP-1 약물 정보 엔티티
///
/// DB medications 마스터 테이블에서 조회되는 약물 정보입니다.
/// 앱 배포 없이 새 약물을 추가할 수 있습니다.
///
/// 사용 예시:
/// ```dart
/// final medications = await ref.read(activeMedicationsProvider.future);
/// final wegovy = medications.firstWhere((m) => m.id == 'wegovy');
/// print(wegovy.displayName); // "Wegovy (세마글루타이드)"
/// ```
class Medication extends Equatable {
  final String id;
  final String nameKo;
  final String nameEn;
  final String? genericName;
  final String? manufacturer;
  final List<double> availableDoses;
  final double? recommendedStartDose;
  final String doseUnit;
  final int cycleDays;
  final bool isActive;
  final int displayOrder;
  final DateTime createdAt;

  const Medication({
    required this.id,
    required this.nameKo,
    required this.nameEn,
    this.genericName,
    this.manufacturer,
    required this.availableDoses,
    this.recommendedStartDose,
    this.doseUnit = 'mg',
    this.cycleDays = 7,
    this.isActive = true,
    required this.displayOrder,
    required this.createdAt,
  });

  /// 기존 dosage_plans.medication_name과 호환되는 표시명
  ///
  /// 형식: "Wegovy (세마글루타이드)"
  /// 기존 MedicationTemplate.displayName과 동일한 형식을 유지합니다.
  String get displayName {
    if (genericName != null && genericName!.isNotEmpty) {
      return '$nameEn ($genericName)';
    }
    return nameEn;
  }

  /// 권장 시작 용량 (없으면 첫 번째 용량)
  double get startDose => recommendedStartDose ?? availableDoses.first;

  /// 용량이 유효한지 확인
  bool isValidDose(double dose) => availableDoses.contains(dose);

  Medication copyWith({
    String? id,
    String? nameKo,
    String? nameEn,
    String? genericName,
    String? manufacturer,
    List<double>? availableDoses,
    double? recommendedStartDose,
    String? doseUnit,
    int? cycleDays,
    bool? isActive,
    int? displayOrder,
    DateTime? createdAt,
  }) {
    return Medication(
      id: id ?? this.id,
      nameKo: nameKo ?? this.nameKo,
      nameEn: nameEn ?? this.nameEn,
      genericName: genericName ?? this.genericName,
      manufacturer: manufacturer ?? this.manufacturer,
      availableDoses: availableDoses ?? this.availableDoses,
      recommendedStartDose: recommendedStartDose ?? this.recommendedStartDose,
      doseUnit: doseUnit ?? this.doseUnit,
      cycleDays: cycleDays ?? this.cycleDays,
      isActive: isActive ?? this.isActive,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nameKo,
        nameEn,
        genericName,
        manufacturer,
        availableDoses,
        recommendedStartDose,
        doseUnit,
        cycleDays,
        isActive,
        displayOrder,
        createdAt,
      ];

  @override
  String toString() => 'Medication(id: $id, displayName: $displayName)';
}
