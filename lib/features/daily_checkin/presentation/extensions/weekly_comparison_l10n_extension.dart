import 'package:flutter/widgets.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/features/daily_checkin/application/services/weekly_comparison_service.dart';
import 'package:n06/features/daily_checkin/presentation/extensions/improvement_type_l10n_extension.dart';

/// Extension to convert WeeklyComparison to localized messages
extension WeeklyComparisonL10nExtension on WeeklyComparison {
  /// Generate localized feedback message from improvements
  ///
  /// Returns the top 1-2 improvements as a formatted string,
  /// or a default message if no improvements detected.
  String generateFeedbackMessage(BuildContext context) {
    if (!hasImprovements) {
      return context.l10n.checkin_improvement_noImprovements;
    }

    // Show top 2 improvements
    final topImprovements = improvements.take(2).toList();
    return topImprovements
        .map((i) => i.toLocalizedMessage(context))
        .join('\n');
  }
}
