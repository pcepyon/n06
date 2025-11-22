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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Color(0xFFE2E8F0), // Neutral-200
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12), // md
        boxShadow: [
          BoxShadow(
            color: Color(0x0F0F172A), // rgba(15, 23, 42, 0.06)
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(24), // lg padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Title
          Text(
            '안녕하세요, ${dashboardData.userName}님',
            style: TextStyle(
              fontSize: 24, // 2xl
              fontWeight: FontWeight.w700, // Bold
              color: Color(0xFF1E293B), // Neutral-800
              height: 1.3,
            ),
          ),
          SizedBox(height: 16), // md spacing

          // Stats Row
          Row(
            children: [
              Expanded(
                child: _StatColumn(
                  label: '연속 기록일',
                  value: '${dashboardData.continuousRecordDays}일',
                ),
              ),
              SizedBox(width: 16), // md spacing
              Expanded(
                child: _StatColumn(
                  label: '현재 주차',
                  value: '${dashboardData.currentWeek}주차',
                ),
              ),
            ],
          ),

          if (dashboardData.insightMessage != null) ...[
            SizedBox(height: 24), // lg spacing

            // Insight Message
            Text(
              dashboardData.insightMessage!,
              style: TextStyle(
                fontSize: 14, // sm
                fontWeight: FontWeight.w500, // Medium
                color: Color(0xFF4ADE80), // Primary
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12, // xs
            fontWeight: FontWeight.w400, // Regular
            color: Color(0xFF64748B), // Neutral-500
            height: 1.4,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18, // lg
            fontWeight: FontWeight.w600, // Semibold
            color: Color(0xFF1E293B), // Neutral-800
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
