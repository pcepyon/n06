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
extension MilestoneTypeExtension on int {
  MilestoneType? toMilestoneType() {
    switch (this) {
      case 3:
        return MilestoneType.threeDays;
      case 7:
        return MilestoneType.sevenDays;
      case 14:
        return MilestoneType.fourteenDays;
      case 21:
        return MilestoneType.twentyOneDays;
      case 30:
        return MilestoneType.thirtyDays;
      case 60:
        return MilestoneType.sixtyDays;
      case 90:
        return MilestoneType.ninetyDays;
      default:
        return null;
    }
  }
}
