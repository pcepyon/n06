import 'package:n06/core/constants/milestone_constants.dart';

/// Milestone type for consecutive check-in days
///
/// This enum represents different milestone achievements in the check-in streak.
/// Application Layer returns this type, and Presentation Layer converts it to
/// localized messages using l10n.
enum MilestoneType {
  threeDays, // 3 days streak
  sevenDays, // 7 days streak (1 week)
  fourteenDays, // 14 days streak (2 weeks)
  twentyOneDays, // 21 days streak (3 weeks)
  thirtyDays, // 30 days streak (1 month)
  sixtyDays, // 60 days streak (2 months)
  ninetyDays, // 90 days streak (3 months)
  custom, // Custom milestone (for any other day count)
}

/// Extension to map milestone days to MilestoneType
///
/// Uses MilestoneConstants.streakDays as the single source of truth.
extension MilestoneTypeExtension on int {
  /// 일수 → MilestoneType 매핑 테이블
  static const _daysToType = {
    3: MilestoneType.threeDays,
    7: MilestoneType.sevenDays,
    14: MilestoneType.fourteenDays,
    21: MilestoneType.twentyOneDays,
    30: MilestoneType.thirtyDays,
    60: MilestoneType.sixtyDays,
    90: MilestoneType.ninetyDays,
  };

  MilestoneType? toMilestoneType() {
    // SSOT 검증: MilestoneConstants.streakDays에 포함된 경우에만 변환
    if (!MilestoneConstants.isMilestone(this)) {
      return null;
    }
    return _daysToType[this];
  }
}
