import 'package:n06/features/tracking/domain/entities/dose_record.dart';

/// Supabase DTO for DoseRecord entity.
///
/// Stores dose record information in Supabase database.
class DoseRecordDto {
  final String id;
  final String? doseScheduleId;
  final String dosagePlanId;
  final DateTime administeredAt;
  final double actualDoseMg;
  final String? injectionSite;
  final bool isCompleted;
  final String? note;
  final DateTime createdAt;

  const DoseRecordDto({
    required this.id,
    this.doseScheduleId,
    required this.dosagePlanId,
    required this.administeredAt,
    required this.actualDoseMg,
    this.injectionSite,
    required this.isCompleted,
    this.note,
    required this.createdAt,
  });

  /// Creates DTO from Supabase JSON.
  factory DoseRecordDto.fromJson(Map<String, dynamic> json) {
    return DoseRecordDto(
      id: json['id'] as String,
      doseScheduleId: json['dose_schedule_id'] as String?,
      dosagePlanId: json['dosage_plan_id'] as String,
      administeredAt: DateTime.parse(json['administered_at'] as String).toLocal(),
      actualDoseMg: (json['actual_dose_mg'] as num).toDouble(),
      injectionSite: json['injection_site'] as String?,
      isCompleted: json['is_completed'] as bool,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  /// Converts DTO to Supabase JSON.
  /// DateTime fields are converted to UTC for consistent storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dose_schedule_id': doseScheduleId,
      'dosage_plan_id': dosagePlanId,
      'administered_at': administeredAt.toUtc().toIso8601String(),
      'actual_dose_mg': actualDoseMg,
      'injection_site': injectionSite,
      'is_completed': isCompleted,
      'note': note,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  /// Converts DTO to Domain Entity.
  DoseRecord toEntity() {
    return DoseRecord(
      id: id,
      doseScheduleId: doseScheduleId,
      dosagePlanId: dosagePlanId,
      administeredAt: administeredAt,
      actualDoseMg: actualDoseMg,
      injectionSite: injectionSite,
      isCompleted: isCompleted,
      note: note,
      createdAt: createdAt,
    );
  }

  /// Creates DTO from Domain Entity.
  factory DoseRecordDto.fromEntity(DoseRecord entity) {
    return DoseRecordDto(
      id: entity.id,
      doseScheduleId: entity.doseScheduleId,
      dosagePlanId: entity.dosagePlanId,
      administeredAt: entity.administeredAt,
      actualDoseMg: entity.actualDoseMg,
      injectionSite: entity.injectionSite,
      isCompleted: entity.isCompleted,
      note: entity.note,
      createdAt: entity.createdAt,
    );
  }
}
