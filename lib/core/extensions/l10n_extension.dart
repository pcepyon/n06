import 'package:flutter/widgets.dart';
import '../../l10n/generated/app_localizations.dart';

/// Extension to easily access L10n from BuildContext
///
/// Usage:
/// ```dart
/// Text(context.l10n.common_button_confirm)
/// ```
extension L10nExtension on BuildContext {
  L10n get l10n => L10n.of(this);
}
