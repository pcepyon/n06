import 'package:isar/isar.dart';
import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';
import 'package:n06/features/tracking/domain/entities/plan_change_history.dart';
import 'package:n06/features/tracking/domain/repositories/medication_repository.dart';
import 'package:n06/features/tracking/infrastructure/dtos/dosage_plan_dto.dart';
import 'package:n06/features/tracking/infrastructure/dtos/dose_record_dto.dart';
import 'package:n06/features/tracking/infrastructure/dtos/dose_schedule_dto.dart';
import 'package:n06/features/tracking/infrastructure/dtos/plan_change_history_dto.dart';

class IsarMedicationRepository implements MedicationRepository {
  final Isar isar;

  IsarMedicationRepository(this.isar);

  // ===== DosagePlan =====

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

  // ===== DoseSchedule =====

  @override
  Future<List<DoseSchedule>> getDoseSchedules(String planId) async {
    final dtos = await isar.doseScheduleDtos
        .filter()
        .dosagePlanIdEqualTo(planId)
        .findAll();

    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<void> saveDoseSchedules(List<DoseSchedule> schedules) async {
    final dtos =
        schedules.map((schedule) => DoseScheduleDto.fromEntity(schedule)).toList();

    await isar.writeTxn(() => isar.doseScheduleDtos.putAll(dtos));
  }

  @override
  Future<void> deleteDoseSchedulesFrom(String planId, DateTime fromDate) async {
    await isar.writeTxn(() async {
      final dtos = await isar.doseScheduleDtos
          .filter()
          .dosagePlanIdEqualTo(planId)
          .scheduledDateGreaterThan(fromDate)
          .findAll();

      await isar.doseScheduleDtos.deleteAll(dtos.map((dto) => dto.id!).toList());
    });
  }

  @override
  Future<void> updateDoseSchedule(DoseSchedule schedule) async {
    final dto = DoseScheduleDto.fromEntity(schedule);
    await isar.writeTxn(() => isar.doseScheduleDtos.put(dto));
  }

  // ===== DoseRecord =====

  @override
  Future<List<DoseRecord>> getDoseRecords(String planId) async {
    final dtos = await isar.doseRecordDtos
        .filter()
        .dosagePlanIdEqualTo(planId)
        .findAll();

    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<List<DoseRecord>> getRecentDoseRecords(String planId, int days) async {
    final since = DateTime.now().subtract(Duration(days: days));

    final dtos = await isar.doseRecordDtos
        .filter()
        .dosagePlanIdEqualTo(planId)
        .administeredAtGreaterThan(since)
        .findAll();

    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<void> saveDoseRecord(DoseRecord record) async {
    final dto = DoseRecordDto.fromEntity(record);
    await isar.writeTxn(() => isar.doseRecordDtos.put(dto));
  }

  @override
  Future<void> deleteDoseRecord(String recordId) async {
    await isar.writeTxn(() async {
      final dto = await isar.doseRecordDtos
          .filter()
          .recordIdEqualTo(recordId)
          .findFirst();

      if (dto != null && dto.id != null) {
        await isar.doseRecordDtos.delete(dto.id!);
      }
    });
  }

  @override
  Future<bool> isDuplicateDoseRecord(
    String planId,
    DateTime scheduledDate,
  ) async {
    final date = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
    );

    final endDate = date.add(Duration(days: 1));

    final exists = await isar.doseRecordDtos
        .filter()
        .dosagePlanIdEqualTo(planId)
        .administeredAtBetween(date, endDate)
        .findFirst();

    return exists != null;
  }

  @override
  Future<DoseRecord?> getDoseRecordByDate(
    String planId,
    DateTime date,
  ) async {
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = startDate.add(Duration(days: 1));

    final dto = await isar.doseRecordDtos
        .filter()
        .dosagePlanIdEqualTo(planId)
        .administeredAtBetween(startDate, endDate)
        .findFirst();

    return dto?.toEntity();
  }

  // ===== Plan Change History =====

  @override
  Future<void> savePlanChangeHistory(
    String planId,
    Map<String, dynamic> oldPlan,
    Map<String, dynamic> newPlan,
  ) async {
    final history = PlanChangeHistory(
      id: 'history_${DateTime.now().millisecondsSinceEpoch}',
      dosagePlanId: planId,
      changedAt: DateTime.now(),
      oldPlan: oldPlan,
      newPlan: newPlan,
    );

    final dto = PlanChangeHistoryDto.fromEntity(history);
    await isar.writeTxn(() => isar.planChangeHistoryDtos.put(dto));
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

  // ===== Streams =====

  @override
  Stream<List<DoseRecord>> watchDoseRecords(String planId) {
    return isar.doseRecordDtos
        .filter()
        .dosagePlanIdEqualTo(planId)
        .watch(fireImmediately: true)
        .map((dtos) => dtos.map((dto) => dto.toEntity()).toList());
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

  @override
  Stream<List<DoseSchedule>> watchDoseSchedules(String planId) {
    return isar.doseScheduleDtos
        .filter()
        .dosagePlanIdEqualTo(planId)
        .watch(fireImmediately: true)
        .map((dtos) => dtos.map((dto) => dto.toEntity()).toList());
  }
}
