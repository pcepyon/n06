import 'package:flutter/material.dart';
import 'package:n06/features/dashboard/domain/entities/weekly_summary.dart';

class WeeklyReportWidget extends StatelessWidget {
  final WeeklySummary weeklySummary;

  const WeeklyReportWidget({
    super.key,
    required this.weeklySummary,
  });

  @override
  Widget build(BuildContext context) {
    final weightDirection = weeklySummary.weightChangeKg < 0 ? '↓' : '↑';
    final weightColor = weeklySummary.weightChangeKg < 0 ? Colors.green : Colors.red;

    return Card(
      elevation: 0,
      color: Colors.purple[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '지난주 요약',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ReportItem(
                  label: '투여',
                  value: '${weeklySummary.doseCompletedCount}회',
                  icon: Icons.check_circle,
                  color: Colors.blue,
                ),
                _ReportItem(
                  label: '체중',
                  value: '$weightDirection ${weeklySummary.weightChangeKg.abs().toStringAsFixed(1)}kg',
                  icon: Icons.scale,
                  color: weightColor,
                ),
                _ReportItem(
                  label: '부작용',
                  value: '${weeklySummary.symptomRecordCount}회',
                  icon: Icons.favorite,
                  color: Colors.pink,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '투여 순응도',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    '${weeklySummary.adherencePercentage.toStringAsFixed(0)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ReportItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}
