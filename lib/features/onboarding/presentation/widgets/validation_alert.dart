import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

enum ValidationAlertType {
  error,
  warning,
  info,
  success,
}

/// Semantic alert banner for validation feedback
/// Supports error, warning, info, success types
/// Uses semantic color system with icons
class ValidationAlert extends StatelessWidget {
  final ValidationAlertType type;
  final String message;
  final IconData? icon;

  const ValidationAlert({
    super.key,
    required this.type,
    required this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getAlertConfig();

    return Container(
      padding: const EdgeInsets.all(16), // md
      decoration: BoxDecoration(
        color: config.backgroundColor,
        border: Border(
          left: BorderSide(
            color: config.borderColor,
            width: 4,
          ),
        ),
        borderRadius: BorderRadius.circular(8), // sm
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon ?? config.defaultIcon,
            size: 24,
            color: config.textColor,
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

  _AlertConfig _getAlertConfig() {
    switch (type) {
      case ValidationAlertType.error:
        return _AlertConfig(
          backgroundColor: const Color(0xFFFEF2F2), // Error background at 5%
          borderColor: AppColors.error,
          textColor: const Color(0xFF991B1B), // Dark Error
          defaultIcon: Icons.error_outline,
        );
      case ValidationAlertType.warning:
        return _AlertConfig(
          backgroundColor: const Color(0xFFFFFBEB), // Warning background at 5%
          borderColor: AppColors.warning,
          textColor: const Color(0xFF92400E), // Dark Warning
          defaultIcon: Icons.warning_amber_outlined,
        );
      case ValidationAlertType.info:
        return _AlertConfig(
          backgroundColor: const Color(0xFFEFF6FF), // Info background at 5%
          borderColor: AppColors.info,
          textColor: const Color(0xFF1E40AF), // Dark Info
          defaultIcon: Icons.info_outline,
        );
      case ValidationAlertType.success:
        return _AlertConfig(
          backgroundColor: const Color(0xFFECFDF5), // Success background at 5%
          borderColor: AppColors.success,
          textColor: const Color(0xFF065F46), // Dark Success
          defaultIcon: Icons.check_circle_outline,
        );
    }
  }
}

class _AlertConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final IconData defaultIcon;

  _AlertConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.defaultIcon,
  });
}
