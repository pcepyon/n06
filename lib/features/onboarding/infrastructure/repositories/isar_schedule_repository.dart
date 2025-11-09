import 'package:isar/isar.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';
import 'package:n06/features/onboarding/domain/repositories/schedule_repository.dart';
import 'package:n06/features/tracking/infrastructure/dtos/dose_schedule_dto.dart';
import 'package:n06/features/tracking/infrastructure/dtos/dosage_plan_dto.dart';

/// Isar 기반 ScheduleRepository 구현
class IsarScheduleRepository implements ScheduleRepository {
  final Isar _isar;

  IsarScheduleRepository(this._isar);

  @override
  Future<void> saveAll(List<DoseSchedule> schedules) async {
    final dtos = schedules.map((s) => DoseScheduleDto.fromEntity(s)).toList();
    // 트랜잭션 내에서 호출될 수 있으므로 writeTxn 제거
    await _isar.doseScheduleDtos.putAll(dtos);
  }

  @override
  Future<List<DoseSchedule>> getSchedulesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // DoseSchedule에는 userId가 없으므로 dosagePlanId를 통해 간접 필터링 필요
    // 우선 userId로 활성 dosagePlan을 찾음
    final dosagePlan = await _isar.dosagePlanDtos
        .filter()
        .userIdEqualTo(userId)
        .isActiveEqualTo(true)
        .findFirst();

    if (dosagePlan == null) {
      return [];
    }

    // dosagePlanId로 스케줄 필터링
    final dtos = await _isar.doseScheduleDtos
        .filter()
        .dosagePlanIdEqualTo(dosagePlan.planId)
        .scheduledDateBetween(startDate, endDate)
        .findAll();
    return dtos.map((dto) => dto.toEntity()).toList();
  }
}
