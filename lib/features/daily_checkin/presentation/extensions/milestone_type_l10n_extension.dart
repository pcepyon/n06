import 'package:flutter/widgets.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/features/daily_checkin/domain/entities/milestone_type.dart';

/// Extension to convert MilestoneType to localized message
extension MilestoneTypeL10nExtension on MilestoneType {
  String toLocalizedMessage(BuildContext context, int days) {
    final l10n = context.l10n;

    switch (this) {
      case MilestoneType.threeDays:
        return l10n.checkin_milestone_threeDays;
      case MilestoneType.sevenDays:
        return l10n.checkin_milestone_sevenDays;
      case MilestoneType.fourteenDays:
        return l10n.checkin_milestone_fourteenDays;
      case MilestoneType.twentyOneDays:
        return l10n.checkin_milestone_twentyOneDays;
      case MilestoneType.thirtyDays:
        return l10n.checkin_milestone_thirtyDays;
      case MilestoneType.sixtyDays:
        return l10n.checkin_milestone_sixtyDays;
      case MilestoneType.ninetyDays:
        return l10n.checkin_milestone_ninetyDays;
      case MilestoneType.custom:
        return l10n.checkin_milestone_custom(days);
    }
  }
}
