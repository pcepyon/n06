import 'package:n06/features/dashboard/domain/entities/weekly_progress.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';

class CalculateWeeklyProgressUseCase {
  /// 지난 7일간의 주간 목표 달성률을 계산합니다.
  WeeklyProgress execute({
    required List<DoseRecord> doseRecords,
    required List<WeightLog> weightLogs,
    required List<dynamic> symptomLogs,
    required int doseTargetCount,
    required int weightTargetCount,
    required int symptomTargetCount,
  }) {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(Duration(days: 7));

    // 지난 7일 내 완료된 투여 기록 카운트
    final doseCompletedCount = doseRecords
        .where((dose) =>
            dose.administeredAt.isAfter(sevenDaysAgo) &&
            dose.administeredAt.isBefore(now.add(Duration(days: 1))) &&
            dose.isCompleted)
        .length;

    // 지난 7일 내 체중 기록 카운트
    final weightRecordCount = weightLogs
        .where((log) =>
            log.logDate.isAfter(sevenDaysAgo) &&
            log.logDate.isBefore(now.add(Duration(days: 1))))
        .length;

    // 지난 7일 내 부작용 기록 카운트 (빈 리스트 처리)
    final symptomRecordCount = symptomLogs.length;

    // 달성률 계산 (0.0 ~ 1.0)
    final doseRate =
        doseTargetCount > 0 ? (doseCompletedCount / doseTargetCount).clamp(0.0, 1.0) : 0.0;
    final weightRate =
        weightTargetCount > 0 ? (weightRecordCount / weightTargetCount).clamp(0.0, 1.0) : 0.0;
    final symptomRate =
        symptomTargetCount > 0 ? (symptomRecordCount / symptomTargetCount).clamp(0.0, 1.0) : 0.0;

    return WeeklyProgress(
      doseCompletedCount: doseCompletedCount,
      doseTargetCount: doseTargetCount,
      doseRate: doseRate,
      weightRecordCount: weightRecordCount,
      weightTargetCount: weightTargetCount,
      weightRate: weightRate,
      symptomRecordCount: symptomRecordCount,
      symptomTargetCount: symptomTargetCount,
      symptomRate: symptomRate,
    );
  }
}
