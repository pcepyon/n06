import 'package:n06/features/tracking/domain/entities/weight_log.dart';

class CalculateWeightGoalEstimateUseCase {
  /// 최근 4주 체중 감량 추세를 기반으로 목표 체중 도달 예상일을 계산합니다.
  /// 충분한 데이터가 없거나 체중 감량 추세가 없으면 null을 반환합니다.
  DateTime? execute({
    required double currentWeight,
    required double targetWeight,
    required List<WeightLog> weightLogs,
  }) {
    // 이미 목표에 도달한 경우
    if (currentWeight <= targetWeight) {
      return DateTime.now();
    }

    // 최근 4주(28일) 데이터 필터링
    final now = DateTime.now();
    final fourWeeksAgo = now.subtract(Duration(days: 28));
    final recentLogs = weightLogs
        .where((log) => log.logDate.isAfter(fourWeeksAgo) && log.logDate.isBefore(now))
        .toList();

    // 충분한 데이터 없음 (2주 미만)
    if (recentLogs.length < 2) {
      return null;
    }

    // 로그 정렬 (최신순)
    recentLogs.sort((a, b) => b.logDate.compareTo(a.logDate));

    // 첫 번째와 마지막 기록으로 선형 회귀 계산
    final firstLog = recentLogs.first;
    final lastLog = recentLogs.last;

    final weightDifference = lastLog.weightKg - firstLog.weightKg;
    final daysDifference = firstLog.logDate.difference(lastLog.logDate).inDays;

    // 체중 감량 추세 없음
    if (weightDifference >= 0 || daysDifference == 0) {
      return null;
    }

    // 일일 체중 감량량
    final dailyLossRate = weightDifference.abs() / daysDifference;

    // 목표까지 필요한 체중 감량량
    final remainingWeight = currentWeight - targetWeight;

    // 목표까지 필요한 일수
    final daysNeeded = (remainingWeight / dailyLossRate).ceil();

    return now.add(Duration(days: daysNeeded));
  }
}
