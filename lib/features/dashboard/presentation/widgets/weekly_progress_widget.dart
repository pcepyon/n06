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
        const Text(
          '주간 목표 진행도',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _ProgressItem(
          label: '투여',
          completed: weeklyProgress.doseCompletedCount,
          target: weeklyProgress.doseTargetCount,
          rate: weeklyProgress.doseRate,
        ),
        const SizedBox(height: 12),
        _ProgressItem(
          label: '체중 기록',
          completed: weeklyProgress.weightRecordCount,
          target: weeklyProgress.weightTargetCount,
          rate: weeklyProgress.weightRate,
        ),
        const SizedBox(height: 12),
        _ProgressItem(
          label: '부작용 기록',
          completed: weeklyProgress.symptomRecordCount,
          target: weeklyProgress.symptomTargetCount,
          rate: weeklyProgress.symptomRate,
        ),
      ],
    );
  }
}

class _ProgressItem extends StatelessWidget {
  final String label;
  final int completed;
  final int target;
  final double rate;

  const _ProgressItem({
    required this.label,
    required this.completed,
    required this.target,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (rate * 100).toStringAsFixed(0);
    final isCompleted = rate >= 1.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                '$completed/$target',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: rate.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? Colors.green : Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$percentage%',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
