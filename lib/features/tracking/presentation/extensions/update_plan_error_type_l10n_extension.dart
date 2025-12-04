import 'package:flutter/widgets.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/features/tracking/domain/entities/update_plan_error_type.dart';

/// Extension to convert UpdatePlanErrorType to localized message
extension UpdatePlanErrorTypeL10nExtension on UpdatePlanErrorType {
  String toLocalizedMessage(BuildContext context) {
    final l10n = context.l10n;

    switch (this) {
      case UpdatePlanErrorType.updateFailed:
        return l10n.tracking_updatePlan_error_updateFailed;
      case UpdatePlanErrorType.networkError:
        return l10n.tracking_updatePlan_error_networkError;
      case UpdatePlanErrorType.validationError:
        return l10n.tracking_updatePlan_error_validationError;
      case UpdatePlanErrorType.permissionError:
        return l10n.tracking_updatePlan_error_permissionError;
    }
  }
}
