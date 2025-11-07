import 'package:isar/isar.dart';
import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';

part 'dosage_plan_dto.g.dart';

@collection
class DosagePlanDto {
  Id? id = Isar.autoIncrement;
  late String planId; // UUID
  late String userId;
  late String medicationName;
  late DateTime startDate;
  late int cycleDays;
  late double initialDoseMg;
  late List<EscalationStepDto>? escalationPlan;
  late bool isActive;
  late DateTime createdAt;
  late DateTime updatedAt;

  DosagePlanDto();

  DosagePlanDto.fromEntity(DosagePlan entity) {
    planId = entity.id;
    userId = entity.userId;
    medicationName = entity.medicationName;
    startDate = entity.startDate;
    cycleDays = entity.cycleDays;
    initialDoseMg = entity.initialDoseMg;
    escalationPlan = entity.escalationPlan?.map((step) {
      return EscalationStepDto.withValues(
        weeksFromStart: step.weeksFromStart,
        doseMg: step.doseMg,
      );
    }).toList();
    isActive = entity.isActive;
    createdAt = entity.createdAt;
    updatedAt = entity.updatedAt;
  }

  DosagePlan toEntity() {
    return DosagePlan(
      id: planId,
      userId: userId,
      medicationName: medicationName,
      startDate: startDate,
      cycleDays: cycleDays,
      initialDoseMg: initialDoseMg,
      escalationPlan: escalationPlan?.map((dto) {
        return EscalationStep(
          weeksFromStart: dto.weeksFromStart,
          doseMg: dto.doseMg,
        );
      }).toList(),
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

@embedded
class EscalationStepDto {
  late int weeksFromStart;
  late double doseMg;

  EscalationStepDto();

  EscalationStepDto.withValues({
    required this.weeksFromStart,
    required this.doseMg,
  });
}
