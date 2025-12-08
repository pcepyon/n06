import 'package:flutter/widgets.dart';
import 'package:n06/core/constants/badge_constants.dart';
import 'package:n06/core/constants/weight_constants.dart';
import '../../../../core/extensions/l10n_extension.dart';

/// Extension to map badge IDs to localized strings
///
/// This utility provides a centralized way to get localized badge names
/// and descriptions based on badge IDs from the database.
///
/// Badge IDs are generated from BadgeConstants SSOT:
/// - streak badges: BadgeConstants.streakBadgeId(days) -> 'streak_7', 'streak_30'
/// - weight badges: BadgeConstants.weightLossBadgeId(percent) -> 'weight_5percent', 'weight_10percent'
extension BadgeL10n on BuildContext {
  // Badge ID constants from SSOT
  static final _streak7 =
      BadgeConstants.streakBadgeId(BadgeConstants.streakBadgeDays[0]);
  static final _streak30 =
      BadgeConstants.streakBadgeId(BadgeConstants.streakBadgeDays[1]);
  static final _weight5 =
      BadgeConstants.weightLossBadgeId(WeightConstants.firstMilestonePercent);
  static final _weight10 =
      BadgeConstants.weightLossBadgeId(WeightConstants.secondMilestonePercent);

  /// Get localized badge name from badge ID
  String getBadgeName(String badgeId) {
    if (badgeId == _streak7) return l10n.dashboard_badge_streak7_name;
    if (badgeId == _streak30) return l10n.dashboard_badge_streak30_name;
    if (badgeId == _weight5) return l10n.dashboard_badge_weight5percent_name;
    if (badgeId == _weight10) return l10n.dashboard_badge_weight10percent_name;
    if (badgeId == 'first_dose') return l10n.dashboard_badge_firstDose_name;
    return l10n.dashboard_badge_default_name;
  }

  /// Get localized badge description from badge ID
  String getBadgeDescription(String badgeId) {
    if (badgeId == _streak7) return l10n.dashboard_badge_streak7_description;
    if (badgeId == _streak30) return l10n.dashboard_badge_streak30_description;
    if (badgeId == _weight5) {
      return l10n.dashboard_badge_weight5percent_description;
    }
    if (badgeId == _weight10) {
      return l10n.dashboard_badge_weight10percent_description;
    }
    if (badgeId == 'first_dose') {
      return l10n.dashboard_badge_firstDose_description;
    }
    return l10n.dashboard_badge_default_description;
  }
}
