import 'package:flutter/material.dart';
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
          style: TextStyle(
            fontSize: 18, // lg
            fontWeight: FontWeight.w600, // Semibold
            color: Color(0xFF1E293B), // Neutral-800
            height: 1.3,
          ),
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
    final fillColor = isComplete ? Color(0xFF10B981) : Color(0xFF4ADE80); // Success : Primary
    final percentage = (progress * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF8FAFC), // Neutral-50
        border: Border.all(
          color: Color(0xFFE2E8F0), // Neutral-200
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8), // sm
      ),
      padding: EdgeInsets.all(16), // md padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label and Fraction
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16, // base
                  fontWeight: FontWeight.w500, // Medium
                  color: Color(0xFF334155), // Neutral-700
                  height: 1.4,
                ),
              ),
              Text(
                '$current/$total',
                style: TextStyle(
                  fontSize: 14, // sm
                  fontWeight: FontWeight.w400, // Regular
                  color: Color(0xFF64748B), // Neutral-500
                  height: 1.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(999), // full (pill)
            child: SizedBox(
              height: 8,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Color(0xFFE2E8F0), // Neutral-200
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
              style: TextStyle(
                fontSize: 14, // sm
                fontWeight: FontWeight.w500, // Medium
                color: fillColor,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
