import 'package:flutter/widgets.dart';
import 'package:n06/core/constants/badge_constants.dart';
import '../../../../core/extensions/l10n_extension.dart';

/// Extension to map badge IDs to localized strings
///
/// This utility provides a centralized way to get localized badge names
/// and descriptions based on badge IDs from the database.
///
/// Badge IDs are generated from BadgeConstants SSOT:
/// - streak badges: BadgeConstants.streakBadgeId(days) -> 'streak_7', 'streak_30'
/// - weight progress badges: BadgeConstants.weightProgressBadgeId(percent) -> 'weight_25percent', 'weight_50percent', etc.
/// - first dose badge: BadgeConstants.firstDoseBadgeId -> 'first_dose'
extension BadgeL10n on BuildContext {
  // Badge ID constants from SSOT
  static final _streak7 =
      BadgeConstants.streakBadgeId(BadgeConstants.streakBadgeDays[0]);
  static final _streak30 =
      BadgeConstants.streakBadgeId(BadgeConstants.streakBadgeDays[1]);
  static final _weight25 =
      BadgeConstants.weightProgressBadgeId(BadgeConstants.weightProgressBadgePercents[0]);
  static final _weight50 =
      BadgeConstants.weightProgressBadgeId(BadgeConstants.weightProgressBadgePercents[1]);
  static final _weight75 =
      BadgeConstants.weightProgressBadgeId(BadgeConstants.weightProgressBadgePercents[2]);
  static final _weight100 =
      BadgeConstants.weightProgressBadgeId(BadgeConstants.weightProgressBadgePercents[3]);

  /// Get localized badge name from badge ID
  String getBadgeName(String badgeId) {
    if (badgeId == _streak7) return l10n.dashboard_badge_streak7_name;
    if (badgeId == _streak30) return l10n.dashboard_badge_streak30_name;
    if (badgeId == _weight25) {
      return l10n.dashboard_badge_weightProgress25_name;
    }
    if (badgeId == _weight50) {
      return l10n.dashboard_badge_weightProgress50_name;
    }
    if (badgeId == _weight75) {
      return l10n.dashboard_badge_weightProgress75_name;
    }
    if (badgeId == _weight100) {
      return l10n.dashboard_badge_weightProgress100_name;
    }
    if (badgeId == BadgeConstants.firstDoseBadgeId) {
      return l10n.dashboard_badge_firstDose_name;
    }
    return l10n.dashboard_badge_default_name;
  }

  /// Get localized badge description from badge ID
  String getBadgeDescription(String badgeId) {
    if (badgeId == _streak7) return l10n.dashboard_badge_streak7_description;
    if (badgeId == _streak30) return l10n.dashboard_badge_streak30_description;
    if (badgeId == _weight25) {
      return l10n.dashboard_badge_weightProgress25_description;
    }
    if (badgeId == _weight50) {
      return l10n.dashboard_badge_weightProgress50_description;
    }
    if (badgeId == _weight75) {
      return l10n.dashboard_badge_weightProgress75_description;
    }
    if (badgeId == _weight100) {
      return l10n.dashboard_badge_weightProgress100_description;
    }
    if (badgeId == BadgeConstants.firstDoseBadgeId) {
      return l10n.dashboard_badge_firstDose_description;
    }
    return l10n.dashboard_badge_default_description;
  }
}
