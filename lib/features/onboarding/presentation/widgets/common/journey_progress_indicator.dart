import 'package:flutter/material.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

class JourneyProgressIndicator extends StatelessWidget {
  final int currentStep; // 0-13
  final int totalSteps; // 14

  const JourneyProgressIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 14,
  });

  // Part 계산: 0-2 → empathy, 3-6 → understanding, 7-10 → setup, 11-13 → preparation
  int get _currentPart {
    if (currentStep <= 2) return 0;
    if (currentStep <= 6) return 1;
    if (currentStep <= 10) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    final parts = [
      context.l10n.onboarding_progress_empathy,
      context.l10n.onboarding_progress_understanding,
      context.l10n.onboarding_progress_setup,
      context.l10n.onboarding_progress_preparation,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        children: [
          // Part 라벨
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) {
              final isActive = index <= _currentPart;
              final isCurrent = index == _currentPart;
              return Text(
                parts[index],
                style: AppTypography.caption.copyWith(
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? AppColors.primary : AppColors.textDisabled,
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          // Progress dots with lines
          Row(
            children: List.generate(7, (index) {
              if (index.isOdd) {
                // Line
                final partIndex = index ~/ 2;
                final isCompleted = partIndex < _currentPart;
                return Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted ? AppColors.primary : AppColors.border,
                  ),
                );
              } else {
                // Dot
                final partIndex = index ~/ 2;
                final isActive = partIndex <= _currentPart;
                return Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? AppColors.primary : AppColors.border,
                  ),
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}
