import 'package:flutter/widgets.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/features/daily_checkin/application/services/weekly_comparison_service.dart';

/// Extension to convert ImprovementType to localized message
extension ImprovementTypeL10nExtension on ImprovementType {
  String toLocalizedMessage(BuildContext context, {double? weightChange}) {
    final l10n = context.l10n;

    switch (this) {
      case ImprovementType.nauseaDecreased:
        return l10n.checkin_improvement_nauseaDecreased;
      case ImprovementType.appetiteImproved:
        return l10n.checkin_improvement_appetiteImproved;
      case ImprovementType.energyImproved:
        return l10n.checkin_improvement_energyImproved;
      case ImprovementType.weightProgress:
        if (weightChange == null) {
          return l10n.checkin_improvement_noImprovements;
        }
        return l10n.checkin_improvement_weightProgress(
          weightChange.abs().toStringAsFixed(1),
        );
      case ImprovementType.checkinStreak:
        return l10n.checkin_improvement_checkinStreak;
    }
  }
}

/// Extension to convert ImprovementFeedback to localized message
extension ImprovementFeedbackL10nExtension on ImprovementFeedback {
  String toLocalizedMessage(BuildContext context) {
    return type.toLocalizedMessage(context, weightChange: weightChange);
  }
}
