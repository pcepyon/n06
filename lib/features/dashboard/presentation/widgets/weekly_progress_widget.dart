import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/dashboard/domain/entities/weekly_progress.dart';

class WeeklyProgressWidget extends StatelessWidget {
  final WeeklyProgress weeklyProgress;

  const WeeklyProgressWidget({
    super.key,
    required this.weeklyProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          '주간 목표 진행도',
          style: AppTypography.heading3,
        ),
        SizedBox(height: 16), // md spacing

        // Progress Items
        Column(
          children: [
            _ProgressItem(
              label: '투여',
              current: weeklyProgress.doseCompletedCount,
              total: weeklyProgress.doseTargetCount,
            ),
            SizedBox(height: 16),
            _ProgressItem(
              label: '체중 기록',
              current: weeklyProgress.weightRecordCount,
              total: weeklyProgress.weightTargetCount,
            ),
            SizedBox(height: 16),
            _ProgressItem(
              label: '부작용 기록',
              current: weeklyProgress.symptomRecordCount,
              total: weeklyProgress.symptomTargetCount,
            ),
          ],
        ),
      ],
    );
  }
}

class _ProgressItem extends StatelessWidget {
  final String label;
  final int current;
  final int total;

  const _ProgressItem({
    required this.label,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? current / total : 0.0;
    final isComplete = progress >= 1.0;
    final fillColor = isComplete ? AppColors.success : AppColors.primary;
    final percentage = (progress * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label and Fraction
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.neutral700,
                ),
              ),
              Text(
                '$current/$total',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
          SizedBox(height: 8),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 8,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(fillColor),
              ),
            ),
          ),
          SizedBox(height: 8),

          // Percentage
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$percentage%',
              style: AppTypography.labelMedium.copyWith(
                color: fillColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
