/// 체중 관련 상수 SSOT
///
/// 체중 기본값, 감량 마일스톤 등 체중 관련 모든 상수를 정의합니다.
/// 이 파일이 유일한 진실의 원천(Single Source of Truth)입니다.
abstract final class WeightConstants {
  /// 체중 미입력 시 목표체중 대비 기본 오프셋 (kg)
  ///
  /// 체중 기록이 없을 때 currentWeight = targetWeight + defaultWeightOffset
  static const double defaultWeightOffset = 5.0;

  /// 목표 체중까지 진행률 마일스톤 (%)
  ///
  /// 시작 체중에서 목표 체중까지의 진행도를 나타내는 마일스톤
  /// 예: 25% = 목표까지 25% 진행, 100% = 목표 달성
  static const List<int> weightProgressMilestones = [25, 50, 75, 100];

  /// 목표 체중 진행률 계산
  ///
  /// 반환값: 0-100 (%)
  static double calculateProgressToGoal({
    required double currentWeight,
    required double startWeight,
    required double targetWeight,
  }) {
    if (startWeight <= targetWeight) return 0.0;
    final totalLoss = startWeight - targetWeight;
    final currentLoss = startWeight - currentWeight;
    return ((currentLoss / totalLoss) * 100).clamp(0.0, 100.0);
  }
}
