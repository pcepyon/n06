import 'package:n06/features/tracking/domain/entities/medication.dart';

/// Supabase DTO for Medication entity
///
/// medications 마스터 테이블의 데이터를 변환합니다.
class MedicationMasterDto {
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

  const MedicationMasterDto({
    required this.id,
    required this.nameKo,
    required this.nameEn,
    this.genericName,
    this.manufacturer,
    required this.availableDoses,
    this.recommendedStartDose,
    required this.doseUnit,
    required this.cycleDays,
    required this.isActive,
    required this.displayOrder,
    required this.createdAt,
  });

  /// Supabase JSON에서 DTO 생성
  factory MedicationMasterDto.fromJson(Map<String, dynamic> json) {
    // available_doses는 JSONB로 저장되어 List<dynamic>으로 반환됨
    final dosesJson = json['available_doses'];
    final List<double> doses;
    if (dosesJson is List) {
      doses = dosesJson.map((e) => (e as num).toDouble()).toList();
    } else {
      doses = [];
    }

    return MedicationMasterDto(
      id: json['id'] as String,
      nameKo: json['name_ko'] as String,
      nameEn: json['name_en'] as String,
      genericName: json['generic_name'] as String?,
      manufacturer: json['manufacturer'] as String?,
      availableDoses: doses,
      recommendedStartDose: json['recommended_start_dose'] != null
          ? (json['recommended_start_dose'] as num).toDouble()
          : null,
      doseUnit: json['dose_unit'] as String? ?? 'mg',
      cycleDays: json['cycle_days'] as int? ?? 7,
      isActive: json['is_active'] as bool? ?? true,
      displayOrder: json['display_order'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// DTO를 Supabase JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ko': nameKo,
      'name_en': nameEn,
      'generic_name': genericName,
      'manufacturer': manufacturer,
      'available_doses': availableDoses,
      'recommended_start_dose': recommendedStartDose,
      'dose_unit': doseUnit,
      'cycle_days': cycleDays,
      'is_active': isActive,
      'display_order': displayOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// DTO를 Domain Entity로 변환
  Medication toEntity() {
    return Medication(
      id: id,
      nameKo: nameKo,
      nameEn: nameEn,
      genericName: genericName,
      manufacturer: manufacturer,
      availableDoses: availableDoses,
      recommendedStartDose: recommendedStartDose,
      doseUnit: doseUnit,
      cycleDays: cycleDays,
      isActive: isActive,
      displayOrder: displayOrder,
      createdAt: createdAt,
    );
  }

  /// Domain Entity에서 DTO 생성
  factory MedicationMasterDto.fromEntity(Medication entity) {
    return MedicationMasterDto(
      id: entity.id,
      nameKo: entity.nameKo,
      nameEn: entity.nameEn,
      genericName: entity.genericName,
      manufacturer: entity.manufacturer,
      availableDoses: entity.availableDoses,
      recommendedStartDose: entity.recommendedStartDose,
      doseUnit: entity.doseUnit,
      cycleDays: entity.cycleDays,
      isActive: entity.isActive,
      displayOrder: entity.displayOrder,
      createdAt: entity.createdAt,
    );
  }
}
