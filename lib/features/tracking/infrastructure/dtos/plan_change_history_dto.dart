import 'package:n06/features/tracking/domain/entities/plan_change_history.dart';

/// Supabase DTO for PlanChangeHistory entity.
///
/// Stores plan change history in Supabase database.
class PlanChangeHistoryDto {
  final String id;
  final String dosagePlanId;
  final DateTime changedAt;
  final Map<String, dynamic> oldPlan;
  final Map<String, dynamic> newPlan;

  const PlanChangeHistoryDto({
    required this.id,
    required this.dosagePlanId,
    required this.changedAt,
    required this.oldPlan,
    required this.newPlan,
  });

  /// Creates DTO from Supabase JSON.
  factory PlanChangeHistoryDto.fromJson(Map<String, dynamic> json) {
    return PlanChangeHistoryDto(
      id: json['id'] as String,
      dosagePlanId: json['dosage_plan_id'] as String,
      changedAt: DateTime.parse(json['changed_at'] as String).toLocal(),
      oldPlan: json['old_plan'] as Map<String, dynamic>,
      newPlan: json['new_plan'] as Map<String, dynamic>,
    );
  }

  /// Converts DTO to Supabase JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dosage_plan_id': dosagePlanId,
      'changed_at': changedAt.toIso8601String(),
      'old_plan': oldPlan,
      'new_plan': newPlan,
    };
  }

  /// Converts DTO to Domain Entity.
  PlanChangeHistory toEntity() {
    return PlanChangeHistory(
      id: id,
      dosagePlanId: dosagePlanId,
      changedAt: changedAt,
      oldPlan: oldPlan,
      newPlan: newPlan,
    );
  }

  /// Creates DTO from Domain Entity.
  factory PlanChangeHistoryDto.fromEntity(PlanChangeHistory entity) {
    return PlanChangeHistoryDto(
      id: entity.id,
      dosagePlanId: entity.dosagePlanId,
      changedAt: entity.changedAt,
      oldPlan: entity.oldPlan,
      newPlan: entity.newPlan,
    );
  }
}
