import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:n06/features/tracking/domain/entities/plan_change_history.dart';

part 'plan_change_history_dto.g.dart';

@collection
class PlanChangeHistoryDto {
  Id? id = Isar.autoIncrement;
  late String historyId; // UUID
  late String dosagePlanId;
  late DateTime changedAt;
  late String oldPlanJson; // JSON string
  late String newPlanJson; // JSON string

  @Index()
  late DateTime indexedChangedAt;

  PlanChangeHistoryDto();

  PlanChangeHistoryDto.fromEntity(PlanChangeHistory entity) {
    historyId = entity.id;
    dosagePlanId = entity.dosagePlanId;
    changedAt = entity.changedAt;
    oldPlanJson = _mapToJson(entity.oldPlan);
    newPlanJson = _mapToJson(entity.newPlan);
    indexedChangedAt = entity.changedAt;
  }

  PlanChangeHistory toEntity() {
    return PlanChangeHistory(
      id: historyId,
      dosagePlanId: dosagePlanId,
      changedAt: changedAt,
      oldPlan: _jsonToMap(oldPlanJson),
      newPlan: _jsonToMap(newPlanJson),
    );
  }

  static String _mapToJson(Map<String, dynamic> map) {
    return jsonEncode(map);
  }

  static Map<String, dynamic> _jsonToMap(String json) {
    return jsonDecode(json) as Map<String, dynamic>;
  }
}
