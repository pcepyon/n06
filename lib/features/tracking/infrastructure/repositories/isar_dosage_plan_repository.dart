import 'package:isar/isar.dart';
import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';
import 'package:n06/features/tracking/domain/entities/plan_change_history.dart';
import 'package:n06/features/tracking/domain/repositories/dosage_plan_repository.dart';
import 'package:n06/features/tracking/infrastructure/dtos/dosage_plan_dto.dart';
import 'package:n06/features/tracking/infrastructure/dtos/plan_change_history_dto.dart';

/// Isar-based implementation of DosagePlanRepository
///
/// Provides persistent storage and retrieval of dosage plans and their change history
/// using the local Isar database.
class IsarDosagePlanRepository implements DosagePlanRepository {
  final Isar isar;

  IsarDosagePlanRepository(this.isar);

  @override
  Future<DosagePlan?> getActiveDosagePlan(String userId) async {
    final dto = await isar.dosagePlanDtos
        .filter()
        .userIdEqualTo(userId)
        .isActiveEqualTo(true)
        .findFirst();

    return dto?.toEntity();
  }

  @override
  Future<DosagePlan?> getDosagePlan(String planId) async {
    final dto = await isar.dosagePlanDtos
        .filter()
        .planIdEqualTo(planId)
        .findFirst();

    return dto?.toEntity();
  }

  @override
  Future<void> saveDosagePlan(DosagePlan plan) async {
    final dto = DosagePlanDto.fromEntity(plan);
    await isar.writeTxn(() => isar.dosagePlanDtos.put(dto));
  }

  @override
  Future<void> updateDosagePlan(DosagePlan plan) async {
    final dto = DosagePlanDto.fromEntity(plan);
    await isar.writeTxn(() => isar.dosagePlanDtos.put(dto));
  }

  @override
  Future<List<PlanChangeHistory>> getPlanChangeHistory(String planId) async {
    final dtos = await isar.planChangeHistoryDtos
        .filter()
        .dosagePlanIdEqualTo(planId)
        .sortByIndexedChangedAtDesc()
        .findAll();

    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<void> savePlanChangeHistory(PlanChangeHistory history) async {
    final dto = PlanChangeHistoryDto.fromEntity(history);
    await isar.writeTxn(() => isar.planChangeHistoryDtos.put(dto));
  }

  @override
  Future<void> updatePlanWithHistory(
    DosagePlan plan,
    PlanChangeHistory history,
  ) async {
    final planDto = DosagePlanDto.fromEntity(plan);
    final historyDto = PlanChangeHistoryDto.fromEntity(history);

    await isar.writeTxn(() async {
      await isar.dosagePlanDtos.put(planDto);
      await isar.planChangeHistoryDtos.put(historyDto);
    });
  }

  @override
  Stream<DosagePlan?> watchActiveDosagePlan(String userId) {
    return isar.dosagePlanDtos
        .filter()
        .userIdEqualTo(userId)
        .isActiveEqualTo(true)
        .watch(fireImmediately: true)
        .map((dtos) => dtos.isNotEmpty ? dtos.first.toEntity() : null);
  }
}
