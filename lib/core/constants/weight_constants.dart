/// 체중 관련 상수 SSOT
///
/// 체중 기본값, 감량 마일스톤 등 체중 관련 모든 상수를 정의합니다.
/// 이 파일이 유일한 진실의 원천(Single Source of Truth)입니다.
abstract final class WeightConstants {
  /// 체중 미입력 시 목표체중 대비 기본 오프셋 (kg)
  ///
  /// 체중 기록이 없을 때 currentWeight = targetWeight + defaultWeightOffset
  static const double defaultWeightOffset = 5.0;

  /// 체중 감량 마일스톤 퍼센트 목록
  ///
  /// 목표 체중 대비 감량 진행률 마일스톤
  static const List<double> weightLossMilestonePercents = [5.0, 10.0];

  /// 첫 번째 마일스톤 (5% 감량)
  static const double firstMilestonePercent = 5.0;

  /// 두 번째 마일스톤 (10% 감량)
  static const double secondMilestonePercent = 10.0;

  /// 체중 마일스톤 달성 여부 확인
  static bool isMilestoneAchieved(
      double weightLossPercent, double milestonePercent) {
    return weightLossPercent >= milestonePercent;
  }
}
