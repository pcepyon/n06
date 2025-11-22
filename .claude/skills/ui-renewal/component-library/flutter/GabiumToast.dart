import 'package:flutter/material.dart';

enum GabiumToastVariant {
  error,
  success,
  warning,
  info,
}

/// Gabium Toast component
/// Error, Success, Warning, Info variants
/// Custom show function replacing SnackBar
class GabiumToast extends StatelessWidget {
  final String message;
  final GabiumToastVariant variant;

  const GabiumToast({
    super.key,
    required this.message,
    required this.variant,
  });

  static void showError(BuildContext context, String message) {
    _show(context, message, GabiumToastVariant.error);
  }

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, GabiumToastVariant.success);
  }

  static void showWarning(BuildContext context, String message) {
    _show(context, message, GabiumToastVariant.warning);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, GabiumToastVariant.info);
  }

  static void _show(
    BuildContext context,
    String message,
    GabiumToastVariant variant,
  ) {
    final messenger = ScaffoldMessenger.of(context);
    final width = MediaQuery.of(context).size.width * 0.9;
    final maxWidth = width > 360 ? 360.0 : width;

    messenger.showSnackBar(
      SnackBar(
        content: GabiumToast(message: message, variant: variant),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 16,
          left: (MediaQuery.of(context).size.width - maxWidth) / 2,
          right: (MediaQuery.of(context).size.width - maxWidth) / 2,
        ),
        duration: variant == GabiumToastVariant.success
            ? const Duration(seconds: 4)
            : const Duration(seconds: 6),
        padding: EdgeInsets.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();

    return Container(
      padding: const EdgeInsets.all(16), // md
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(12), // md
        border: Border(
          left: BorderSide(
            color: config.borderColor,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0F0F172A).withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            config.icon,
            size: 24,
            color: config.iconColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14, // sm
                fontWeight: FontWeight.w400, // Regular
                color: config.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _ToastConfig _getConfig() {
    switch (variant) {
      case GabiumToastVariant.error:
        return _ToastConfig(
          backgroundColor: const Color(0xFFFEF2F2),
          borderColor: const Color(0xFFEF4444), // Error
          textColor: const Color(0xFF991B1B), // Error dark
          iconColor: const Color(0xFFEF4444),
          icon: Icons.error_outline,
        );
      case GabiumToastVariant.success:
        return _ToastConfig(
          backgroundColor: const Color(0xFFECFDF5),
          borderColor: const Color(0xFF10B981), // Success
          textColor: const Color(0xFF065F46), // Success dark
          iconColor: const Color(0xFF10B981),
          icon: Icons.check_circle_outline,
        );
      case GabiumToastVariant.warning:
        return _ToastConfig(
          backgroundColor: const Color(0xFFFEF3C7),
          borderColor: const Color(0xFFF59E0B), // Warning
          textColor: const Color(0xFF92400E), // Warning dark
          iconColor: const Color(0xFFF59E0B),
          icon: Icons.warning_amber_outlined,
        );
      case GabiumToastVariant.info:
        return _ToastConfig(
          backgroundColor: const Color(0xFFEFF6FF),
          borderColor: const Color(0xFF3B82F6), // Info
          textColor: const Color(0xFF1E3A8A), // Info dark
          iconColor: const Color(0xFF3B82F6),
          icon: Icons.info_outline,
        );
    }
  }
}

class _ToastConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color iconColor;
  final IconData icon;

  _ToastConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.iconColor,
    required this.icon,
  });
}
