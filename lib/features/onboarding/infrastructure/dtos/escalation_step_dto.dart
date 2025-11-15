import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';

/// Supabase embedded DTO for EscalationStep.
///
/// Used as JSONB data in dosage_plans and plan_change_history tables.
class EscalationStepDto {
  final int weeksFromStart;
  final double doseMg;

  const EscalationStepDto({
    required this.weeksFromStart,
    required this.doseMg,
  });

  /// Creates DTO from Supabase JSON.
  factory EscalationStepDto.fromJson(Map<String, dynamic> json) {
    return EscalationStepDto(
      weeksFromStart: json['weeks_from_start'] as int,
      doseMg: (json['dose_mg'] as num).toDouble(),
    );
  }

  /// Converts DTO to Supabase JSON.
  Map<String, dynamic> toJson() {
    return {
      'weeks_from_start': weeksFromStart,
      'dose_mg': doseMg,
    };
  }

  /// DTO를 Domain Entity로 변환한다.
  EscalationStep toEntity() {
    return EscalationStep(
      weeksFromStart: weeksFromStart,
      doseMg: doseMg,
    );
  }

  /// Domain Entity를 DTO로 변환한다.
  static EscalationStepDto fromEntity(EscalationStep entity) {
    return EscalationStepDto(
      weeksFromStart: entity.weeksFromStart,
      doseMg: entity.doseMg,
    );
  }
}
