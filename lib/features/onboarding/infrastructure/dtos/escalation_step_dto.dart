import 'package:n06/features/onboarding/domain/entities/escalation_step.dart';

class EscalationStepDto {
  final int weeks;
  final double doseMg;

  EscalationStepDto({
    required this.weeks,
    required this.doseMg,
  });

  /// DTO를 Domain Entity로 변환한다.
  EscalationStep toEntity() {
    return EscalationStep(
      weeks: weeks,
      doseMg: doseMg,
    );
  }

  /// Domain Entity를 DTO로 변환한다.
  static EscalationStepDto fromEntity(EscalationStep entity) {
    return EscalationStepDto(
      weeks: entity.weeks,
      doseMg: entity.doseMg,
    );
  }

  /// JSON 맵으로 변환한다.
  Map<String, dynamic> toJson() {
    return {
      'weeks': weeks,
      'doseMg': doseMg,
    };
  }

  /// JSON 맵에서 생성한다.
  factory EscalationStepDto.fromJson(Map<String, dynamic> json) {
    return EscalationStepDto(
      weeks: json['weeks'] as int,
      doseMg: json['doseMg'] as double,
    );
  }
}
