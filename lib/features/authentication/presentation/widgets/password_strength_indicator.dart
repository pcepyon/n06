import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/core/utils/validators.dart';
import 'package:n06/core/extensions/l10n_extension.dart';

/// Password Strength Indicator component
/// Visual strength feedback with Gabium semantic colors
class PasswordStrengthIndicator extends StatelessWidget {
  final PasswordStrength strength;

  const PasswordStrengthIndicator({
    super.key,
    required this.strength,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final label = _getLabel(context);
    final progress = _getProgress();

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(999),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.ease,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: color),
        ),
      ],
    );
  }

  Color _getColor() {
    switch (strength) {
      case PasswordStrength.weak:
        return AppColors.error;
      case PasswordStrength.medium:
        return AppColors.warning;
      case PasswordStrength.strong:
        return AppColors.success;
    }
  }

  String _getLabel(BuildContext context) {
    switch (strength) {
      case PasswordStrength.weak:
        return context.l10n.auth_passwordStrength_weak;
      case PasswordStrength.medium:
        return context.l10n.auth_passwordStrength_medium;
      case PasswordStrength.strong:
        return context.l10n.auth_passwordStrength_strong;
    }
  }

  double _getProgress() {
    switch (strength) {
      case PasswordStrength.weak:
        return 0.33;
      case PasswordStrength.medium:
        return 0.66;
      case PasswordStrength.strong:
        return 1.0;
    }
  }
}
