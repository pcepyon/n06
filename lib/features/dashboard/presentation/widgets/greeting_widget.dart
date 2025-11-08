import 'package:flutter/material.dart';
import 'package:n06/features/dashboard/domain/entities/dashboard_data.dart';

class GreetingWidget extends StatelessWidget {
  final DashboardData dashboardData;

  const GreetingWidget({
    super.key,
    required this.dashboardData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '안녕하세요, ${dashboardData.userName}님',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('연속 기록일', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text('${dashboardData.continuousRecordDays}일',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('현재 주차', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text('${dashboardData.currentWeek}주차',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            if (dashboardData.insightMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                dashboardData.insightMessage!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
