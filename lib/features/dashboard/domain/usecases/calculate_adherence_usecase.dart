import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';

class CalculateAdherenceUseCase {
  /// 투여 순응도를 계산합니다.
  /// (실제 완료한 투여 횟수 / 예정된 투여 횟수) × 100
  double execute(
    List<DoseRecord> records,
    List<DoseSchedule> schedules,
  ) {
    // 미래 일정 제외
    final now = DateTime.now();
    final pastSchedules = schedules.where((s) => s.scheduledDate.isBefore(now)).toList();

    if (pastSchedules.isEmpty) {
      return 0.0;
    }

    // 완료된 투여 횟수
    final completedCount = records.where((r) => r.isCompleted).length;

    // 순응도 계산
    final adherence = (completedCount / pastSchedules.length) * 100;
    return adherence.clamp(0.0, 100.0);
  }
}
