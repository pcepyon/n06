import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/main.dart';

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
    // Use global ScaffoldMessengerKey to show SnackBars above Dialogs/BottomSheets
    // Fallback to context's ScaffoldMessenger if global key is not available
    final messenger = rootScaffoldMessengerKey.currentState ??
                      ScaffoldMessenger.of(context);
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: config.borderColor,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral900.withValues(alpha: 0.10),
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
              style: AppTypography.bodySmall.copyWith(
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
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          borderColor: AppColors.error,
          textColor: const Color(0xFF991B1B),
          iconColor: AppColors.error,
          icon: Icons.error_outline,
        );
      case GabiumToastVariant.success:
        return _ToastConfig(
          backgroundColor: AppColors.success.withValues(alpha: 0.1),
          borderColor: AppColors.success,
          textColor: const Color(0xFF065F46),
          iconColor: AppColors.success,
          icon: Icons.check_circle_outline,
        );
      case GabiumToastVariant.warning:
        return _ToastConfig(
          backgroundColor: AppColors.warning.withValues(alpha: 0.15),
          borderColor: AppColors.warning,
          textColor: const Color(0xFF92400E),
          iconColor: AppColors.warning,
          icon: Icons.warning_amber_outlined,
        );
      case GabiumToastVariant.info:
        return _ToastConfig(
          backgroundColor: AppColors.info.withValues(alpha: 0.1),
          borderColor: AppColors.info,
          textColor: const Color(0xFF1E3A8A),
          iconColor: AppColors.info,
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
