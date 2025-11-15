import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';
import 'package:n06/features/onboarding/infrastructure/dtos/escalation_step_dto.dart';

/// Supabase DTO for DosagePlan entity.
///
/// Stores dosage plan information in Supabase database.
class DosagePlanDto {
  final String id;
  final String userId;
  final String medicationName;
  final DateTime startDate;
  final int cycleDays;
  final double initialDoseMg;
  final List<EscalationStepDto>? escalationPlan;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DosagePlanDto({
    required this.id,
    required this.userId,
    required this.medicationName,
    required this.startDate,
    required this.cycleDays,
    required this.initialDoseMg,
    this.escalationPlan,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates DTO from Supabase JSON.
  factory DosagePlanDto.fromJson(Map<String, dynamic> json) {
    return DosagePlanDto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      medicationName: json['medication_name'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      cycleDays: json['cycle_days'] as int,
      initialDoseMg: (json['initial_dose_mg'] as num).toDouble(),
      escalationPlan: json['escalation_plan'] != null
          ? (json['escalation_plan'] as List)
              .map((e) => EscalationStepDto.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts DTO to Supabase JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'medication_name': medicationName,
      'start_date': startDate.toIso8601String().split('T')[0],
      'cycle_days': cycleDays,
      'initial_dose_mg': initialDoseMg,
      'escalation_plan': escalationPlan?.map((step) => step.toJson()).toList(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Converts DTO to Domain Entity.
  DosagePlan toEntity() {
    return DosagePlan(
      id: id,
      userId: userId,
      medicationName: medicationName,
      startDate: startDate,
      cycleDays: cycleDays,
      initialDoseMg: initialDoseMg,
      escalationPlan: escalationPlan?.map((dto) => dto.toEntity()).toList(),
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates DTO from Domain Entity.
  factory DosagePlanDto.fromEntity(DosagePlan entity) {
    return DosagePlanDto(
      id: entity.id,
      userId: entity.userId,
      medicationName: entity.medicationName,
      startDate: entity.startDate,
      cycleDays: entity.cycleDays,
      initialDoseMg: entity.initialDoseMg,
      escalationPlan: entity.escalationPlan
          ?.map((step) => EscalationStepDto.fromEntity(step))
          .toList(),
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
