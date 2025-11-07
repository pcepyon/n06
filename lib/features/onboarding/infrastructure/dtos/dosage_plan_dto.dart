import 'package:isar/isar.dart';
import 'dart:convert';
import 'package:n06/features/onboarding/domain/entities/dosage_plan.dart';
import 'package:n06/features/onboarding/domain/entities/escalation_step.dart';
import 'package:n06/features/onboarding/domain/value_objects/medication_name.dart';
import 'package:n06/features/onboarding/domain/value_objects/start_date.dart';
import 'escalation_step_dto.dart';

part 'dosage_plan_dto.g.dart';

@collection
class DosagePlanDto {
  Id isarId = Isar.autoIncrement;

  late String id;
  late String userId;
  late String medicationName;
  late DateTime startDate;
  late int cycleDays;
  late double initialDoseMg;
  late String? escalationPlanJson;
  late bool isActive;

  /// DTO를 Domain Entity로 변환한다.
  DosagePlan toEntity() {
    final escalationSteps = _parseEscalationPlan(escalationPlanJson);

    return DosagePlan(
      id: id,
      userId: userId,
      medicationName: MedicationName.create(medicationName),
      startDate: StartDate.create(startDate),
      cycleDays: cycleDays,
      initialDoseMg: initialDoseMg,
      escalationPlan: escalationSteps,
      isActive: isActive,
    );
  }

  /// Domain Entity를 DTO로 변환한다.
  static DosagePlanDto fromEntity(DosagePlan entity) {
    final escalationJson = entity.escalationPlan != null
        ? jsonEncode(
            entity.escalationPlan!
                .map((e) => EscalationStepDto.fromEntity(e).toJson())
                .toList(),
          )
        : null;

    return DosagePlanDto()
      ..id = entity.id
      ..userId = entity.userId
      ..medicationName = entity.medicationName.value
      ..startDate = entity.startDate.value
      ..cycleDays = entity.cycleDays
      ..initialDoseMg = entity.initialDoseMg
      ..escalationPlanJson = escalationJson
      ..isActive = entity.isActive;
  }

  /// JSON 문자열을 EscalationStep 리스트로 파싱한다.
  static List<EscalationStep>? _parseEscalationPlan(String? json) {
    if (json == null || json.isEmpty) {
      return null;
    }

    try {
      final List<dynamic> data = jsonDecode(json);
      return data
          .map((item) => EscalationStepDto.fromJson(item as Map<String, dynamic>)
              .toEntity())
          .toList();
    } catch (e) {
      return null;
    }
  }
}
