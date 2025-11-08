import 'package:n06/features/tracking/domain/entities/symptom_log.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';

class CalculateContinuousRecordDaysUseCase {
  /// 마지막 기록부터 현재까지의 연속 기록일을 계산합니다.
  /// 기록 없는 날이 발생하면 0으로 리셋됩니다.
  int execute(List<WeightLog> weights, List<SymptomLog> symptoms) {
    if (weights.isEmpty && symptoms.isEmpty) {
      return 0;
    }

    // 모든 기록 날짜를 수집
    final allDates = <DateTime>{};
    for (final weight in weights) {
      allDates.add(
        DateTime(weight.logDate.year, weight.logDate.month, weight.logDate.day),
      );
    }
    for (final symptom in symptoms) {
      allDates.add(
        DateTime(
          symptom.logDate.year,
          symptom.logDate.month,
          symptom.logDate.day,
        ),
      );
    }

    if (allDates.isEmpty) {
      return 0;
    }

    // 날짜 정렬 (최신순)
    final sortedDates = allDates.toList()..sort((a, b) => b.compareTo(a));

    // 오늘의 자정
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // 연속 기록일 계산
    int continuousDays = 0;
    for (var i = 0; i < sortedDates.length; i++) {
      final expectedDate = todayDate.subtract(Duration(days: i));
      if (sortedDates[i] == expectedDate) {
        continuousDays++;
      } else {
        break;
      }
    }

    return continuousDays;
  }
}
