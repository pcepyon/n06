import 'package:flutter/widgets.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/features/daily_checkin/domain/entities/encouragement_message_type.dart';

/// Extension to convert EncouragementMessageType to localized message
extension EncouragementMessageTypeL10nExtension on EncouragementMessageType {
  String toLocalizedMessage(
    BuildContext context, {
    required int days,
    int? nextMilestone,
    int? daysRemaining,
  }) {
    final l10n = context.l10n;

    switch (this) {
      case EncouragementMessageType.firstDay:
        return l10n.checkin_encouragement_firstDay;
      case EncouragementMessageType.secondDay:
        return l10n.checkin_encouragement_secondDay;
      case EncouragementMessageType.almostMilestone:
        if (nextMilestone == null || daysRemaining == null) {
          return l10n.checkin_encouragement_generic(days);
        }
        return l10n.checkin_encouragement_almostMilestone(
          days,
          nextMilestone,
          daysRemaining,
        );
      case EncouragementMessageType.generic:
        return l10n.checkin_encouragement_generic(days);
    }
  }
}
