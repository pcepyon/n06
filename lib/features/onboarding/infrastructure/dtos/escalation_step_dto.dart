import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';

class EscalationStepDto {
  final int weeksFromStart;
  final double doseMg;

  EscalationStepDto({
    required this.weeksFromStart,
    required this.doseMg,
  });

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

  /// JSON 맵으로 변환한다.
  Map<String, dynamic> toJson() {
    return {
      'weeksFromStart': weeksFromStart,
      'doseMg': doseMg,
    };
  }

  /// JSON 맵에서 생성한다.
  factory EscalationStepDto.fromJson(Map<String, dynamic> json) {
    return EscalationStepDto(
      weeksFromStart: json['weeksFromStart'] as int,
      doseMg: json['doseMg'] as double,
    );
  }
}
