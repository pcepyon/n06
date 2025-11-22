import 'package:flutter/material.dart';
import 'package:n06/core/utils/validators.dart';

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
    final label = _getLabel();
    final progress = _getProgress();

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0), // Neutral-200
              borderRadius: BorderRadius.circular(999), // full
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.ease,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(999), // full
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12, // xs
            fontWeight: FontWeight.w500, // Medium
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getColor() {
    switch (strength) {
      case PasswordStrength.weak:
        return const Color(0xFFEF4444); // Error
      case PasswordStrength.medium:
        return const Color(0xFFF59E0B); // Warning
      case PasswordStrength.strong:
        return const Color(0xFF10B981); // Success
    }
  }

  String _getLabel() {
    switch (strength) {
      case PasswordStrength.weak:
        return '약함';
      case PasswordStrength.medium:
        return '보통';
      case PasswordStrength.strong:
        return '강함';
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
