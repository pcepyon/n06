/// 마일스톤 관련 상수 SSOT
///
/// 연속 체크인 마일스톤과 관련된 모든 상수를 정의합니다.
/// 이 파일이 유일한 진실의 원천(Single Source of Truth)입니다.
abstract final class MilestoneConstants {
  /// 연속 체크인 마일스톤 일수
  ///
  /// 3, 7, 14, 21, 30, 60, 90일 달성 시 축하 메시지 표시
  static const List<int> streakDays = [3, 7, 14, 21, 30, 60, 90];

  /// 특별 마일스톤 기준일 (30일 이상)
  ///
  /// 이 일수 이상이면 특별 축하 애니메이션 표시
  static const int specialMilestoneThreshold = 30;

  /// 주어진 일수가 마일스톤인지 확인
  static bool isMilestone(int days) => streakDays.contains(days);

  /// 다음 마일스톤 일수 반환 (없으면 null)
  static int? getNextMilestone(int currentDays) {
    for (final milestone in streakDays) {
      if (milestone > currentDays) {
        return milestone;
      }
    }
    return null;
  }

  /// 다음 마일스톤까지 남은 일수
  static int getDaysUntilNextMilestone(int currentDays) {
    final next = getNextMilestone(currentDays);
    return next != null ? next - currentDays : 0;
  }

  /// 특별 마일스톤 여부 확인
  static bool isSpecialMilestone(int days) =>
      isMilestone(days) && days >= specialMilestoneThreshold;
}
