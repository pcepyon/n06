/// 뱃지 관련 상수 SSOT
///
/// 뱃지 획득 조건과 관련된 모든 상수를 정의합니다.
/// 데이터베이스의 badge_definitions 테이블과 동기화됩니다.
abstract final class BadgeConstants {
  /// 연속 기록 뱃지 조건 (일)
  static const List<int> streakBadgeDays = [7, 30];

  /// 목표 체중 진행률 뱃지 조건 (%)
  /// 계산: (시작체중 - 현재체중) / (시작체중 - 목표체중) * 100
  static const List<int> weightProgressBadgePercents = [25, 50, 75, 100];

  /// 첫 투여 완료 뱃지 ID
  static const String firstDoseBadgeId = 'first_dose';

  /// 뱃지 ID 생성 헬퍼
  static String streakBadgeId(int days) => 'streak_$days';
  static String weightProgressBadgeId(int percent) =>
      'weight_${percent}percent';

  /// streak 뱃지 조건 확인
  static bool isStreakBadgeConditionMet(int consecutiveDays, int targetDays) {
    return consecutiveDays >= targetDays;
  }

  /// 목표 체중 진행률 뱃지 조건 확인
  static bool isWeightProgressBadgeConditionMet(
      double weightProgressPercent, int targetPercent) {
    return weightProgressPercent >= targetPercent;
  }

  /// streak 뱃지 진행률 계산 (0-100)
  static int calculateStreakProgress(int consecutiveDays, int targetDays) {
    return ((consecutiveDays / targetDays) * 100).toInt().clamp(0, 100);
  }

  /// 목표 체중 진행률 뱃지 진행률 계산 (0-100)
  static int calculateWeightProgressProgress(
      double weightProgressPercent, int targetPercent) {
    return ((weightProgressPercent / targetPercent) * 100).toInt().clamp(0, 100);
  }
}
