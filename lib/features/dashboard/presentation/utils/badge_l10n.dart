import 'package:flutter/widgets.dart';
import '../../../../core/extensions/l10n_extension.dart';

/// Extension to map badge IDs to localized strings
///
/// This utility provides a centralized way to get localized badge names
/// and descriptions based on badge IDs from the database.
///
/// Usage:
/// ```dart
/// final badgeName = context.getBadgeName('streak_7');
/// final badgeDescription = context.getBadgeDescription('streak_7');
/// ```
extension BadgeL10n on BuildContext {
  /// Get localized badge name from badge ID
  String getBadgeName(String badgeId) {
    return switch (badgeId) {
      'streak_7' => l10n.dashboard_badge_streak7_name,
      'streak_30' => l10n.dashboard_badge_streak30_name,
      'weight_5percent' => l10n.dashboard_badge_weight5percent_name,
      'weight_10percent' => l10n.dashboard_badge_weight10percent_name,
      'first_dose' => l10n.dashboard_badge_firstDose_name,
      _ => l10n.dashboard_badge_default_name,
    };
  }

  /// Get localized badge description from badge ID
  String getBadgeDescription(String badgeId) {
    return switch (badgeId) {
      'streak_7' => l10n.dashboard_badge_streak7_description,
      'streak_30' => l10n.dashboard_badge_streak30_description,
      'weight_5percent' => l10n.dashboard_badge_weight5percent_description,
      'weight_10percent' => l10n.dashboard_badge_weight10percent_description,
      'first_dose' => l10n.dashboard_badge_firstDose_description,
      _ => l10n.dashboard_badge_default_description,
    };
  }
}
