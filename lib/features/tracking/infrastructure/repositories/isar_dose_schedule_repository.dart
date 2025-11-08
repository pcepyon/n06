import 'package:isar/isar.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';
import 'package:n06/features/tracking/domain/repositories/dose_schedule_repository.dart';
import 'package:n06/features/tracking/infrastructure/dtos/dose_schedule_dto.dart';

/// Isar-based implementation of DoseScheduleRepository
///
/// Provides persistent storage and retrieval of dose schedules
/// using the local Isar database.
class IsarDoseScheduleRepository implements DoseScheduleRepository {
  final Isar isar;

  IsarDoseScheduleRepository(this.isar);

  @override
  Future<List<DoseSchedule>> getSchedulesByPlanId(String dosagePlanId) async {
    final dtos = await isar.doseScheduleDtos
        .filter()
        .dosagePlanIdEqualTo(dosagePlanId)
        .findAll();

    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<void> saveBatchSchedules(List<DoseSchedule> schedules) async {
    final dtos =
        schedules.map((schedule) => DoseScheduleDto.fromEntity(schedule)).toList();

    await isar.writeTxn(() => isar.doseScheduleDtos.putAll(dtos));
  }

  @override
  Future<void> deleteFutureSchedules(
    String dosagePlanId,
    DateTime fromDate,
  ) async {
    await isar.writeTxn(() async {
      final dtos = await isar.doseScheduleDtos
          .filter()
          .dosagePlanIdEqualTo(dosagePlanId)
          .scheduledDateGreaterThan(fromDate)
          .findAll();

      await isar.doseScheduleDtos.deleteAll(dtos.map((dto) => dto.id!).toList());
    });
  }

  @override
  Stream<List<DoseSchedule>> watchSchedulesByPlanId(String dosagePlanId) {
    return isar.doseScheduleDtos
        .filter()
        .dosagePlanIdEqualTo(dosagePlanId)
        .watch(fireImmediately: true)
        .map((dtos) => dtos.map((dto) => dto.toEntity()).toList());
  }
}
