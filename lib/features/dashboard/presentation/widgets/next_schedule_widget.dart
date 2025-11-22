import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/next_schedule.dart';

class NextScheduleWidget extends StatelessWidget {
  final NextSchedule schedule;

  const NextScheduleWidget({
    super.key,
    required this.schedule,
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
            color: Color(0x0F0F172A),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(24), // lg padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            '다음 예정',
            style: TextStyle(
              fontSize: 18, // lg
              fontWeight: FontWeight.w600, // Semibold
              color: Color(0xFF1E293B), // Neutral-800
              height: 1.3,
            ),
          ),

          SizedBox(height: 16), // md spacing

          // Next Dose Schedule
          _ScheduleItem(
            icon: Icons.medication_outlined,
            iconColor: Color(0xFFF59E0B), // Warning (urgent)
            title: '다음 투여',
            date: schedule.nextDoseDate,
            subtitle: '${schedule.nextDoseMg} mg',
          ),

          if (schedule.nextEscalationDate != null) ...[
            SizedBox(height: 24), // lg spacing

            // Next Escalation Schedule
            _ScheduleItem(
              icon: Icons.trending_up_outlined,
              iconColor: Color(0xFF475569), // Neutral-600
              title: '다음 증량',
              date: schedule.nextEscalationDate!,
              subtitle: null,
            ),
          ],
        ],
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final DateTime date;
  final String? subtitle;

  const _ScheduleItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.date,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('M월 d일 (E)', 'ko_KR');
    final dateString = dateFormat.format(date);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Icon(
          icon,
          size: 20,
          color: iconColor,
        ),

        SizedBox(width: 16), // md spacing

        // Text Column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12, // xs
                  fontWeight: FontWeight.w400, // Regular
                  color: Color(0xFF64748B), // Neutral-500
                  height: 1.4,
                ),
              ),
              SizedBox(height: 2),
              Text(
                dateString,
                style: TextStyle(
                  fontSize: 16, // base
                  fontWeight: FontWeight.w500, // Medium
                  color: Color(0xFF1E293B), // Neutral-800
                  height: 1.4,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 14, // sm
                    fontWeight: FontWeight.w400, // Regular
                    color: Color(0xFF64748B), // Neutral-500
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
