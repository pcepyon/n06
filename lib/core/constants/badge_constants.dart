import 'package:n06/core/constants/weight_constants.dart';

/// 뱃지 관련 상수 SSOT
///
/// 뱃지 획득 조건과 관련된 모든 상수를 정의합니다.
/// 마일스톤/체중 상수는 각각의 SSOT를 참조합니다.
abstract final class BadgeConstants {
  /// 연속 기록 뱃지 조건 (일)
  static const List<int> streakBadgeDays = [7, 30];

  /// 체중 감량 뱃지 조건 (%)
  ///
  /// WeightConstants.weightLossMilestonePercents와 동일
  static List<double> get weightLossBadgePercents =>
      WeightConstants.weightLossMilestonePercents;

  /// 뱃지 ID 생성 헬퍼
  static String streakBadgeId(int days) => 'streak_$days';
  static String weightLossBadgeId(double percent) =>
      'weight_${percent.toInt()}percent';

  /// streak 뱃지 조건 확인
  static bool isStreakBadgeConditionMet(int consecutiveDays, int targetDays) {
    return consecutiveDays >= targetDays;
  }

  /// 체중 감량 뱃지 조건 확인
  static bool isWeightLossBadgeConditionMet(
      double weightLossPercent, double targetPercent) {
    return weightLossPercent >= targetPercent;
  }

  /// streak 뱃지 진행률 계산 (0-100)
  static int calculateStreakProgress(int consecutiveDays, int targetDays) {
    return ((consecutiveDays / targetDays) * 100).toInt().clamp(0, 100);
  }

  /// 체중 감량 뱃지 진행률 계산 (0-100)
  static int calculateWeightLossProgress(
      double weightLossPercent, double targetPercent) {
    return ((weightLossPercent / targetPercent) * 100).toInt().clamp(0, 100);
  }
}
