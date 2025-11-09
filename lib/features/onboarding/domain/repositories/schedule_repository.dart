import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';

/// 투여 스케줄 접근 계약을 정의하는 Repository Interface
abstract class ScheduleRepository {
  /// 여러 투여 스케줄을 한 번에 저장한다.
  Future<void> saveAll(List<DoseSchedule> schedules);

  /// 날짜 범위 내의 투여 스케줄을 조회한다.
  Future<List<DoseSchedule>> getSchedulesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
}
