import 'package:flutter/material.dart';

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
      title: const Text('로그아웃'),
      content: const Text('로그아웃하시겠습니까?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onCancel?.call();
          },
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: const Text('확인'),
        ),
      ],
    );
  }
}
