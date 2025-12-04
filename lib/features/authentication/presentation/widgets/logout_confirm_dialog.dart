import 'package:flutter/material.dart';
import 'package:n06/core/extensions/l10n_extension.dart';

/// Logout confirmation dialog
///
/// Shows a confirmation dialog asking the user if they want to logout.
/// Prevents accidental logouts through user confirmation.
class LogoutConfirmDialog extends StatelessWidget {
  /// Callback when user confirms logout
  final VoidCallback onConfirm;

  /// Optional callback when user cancels
  final VoidCallback? onCancel;

  const LogoutConfirmDialog({
    super.key,
    required this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.common_dialog_logoutTitle),
      content: Text(context.l10n.common_dialog_logoutMessage),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onCancel?.call();
          },
          child: Text(context.l10n.common_button_cancel),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: Text(context.l10n.common_button_confirm),
        ),
      ],
    );
  }
}
