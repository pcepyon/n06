import 'package:isar/isar.dart';
import 'package:n06/features/onboarding/domain/entities/dose_schedule.dart';
import 'package:n06/features/onboarding/domain/repositories/schedule_repository.dart';
import 'package:n06/features/onboarding/infrastructure/dtos/dose_schedule_dto.dart';

/// Isar 기반 ScheduleRepository 구현
class IsarScheduleRepository implements ScheduleRepository {
  final Isar _isar;

  IsarScheduleRepository(this._isar);

  @override
  Future<void> saveAll(List<DoseSchedule> schedules) async {
    final dtos = schedules.map((s) => DoseScheduleDto.fromEntity(s)).toList();
    await _isar.writeTxn(() async {
      await _isar.doseScheduleDtos.putAll(dtos);
    });
  }

  @override
  Future<List<DoseSchedule>> getSchedulesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final dtos = await _isar.doseScheduleDtos
        .filter()
        .userIdEqualTo(userId)
        .scheduledDateBetween(startDate, endDate)
        .findAll();
    return dtos.map((dto) => dto.toEntity()).toList();
  }
}
