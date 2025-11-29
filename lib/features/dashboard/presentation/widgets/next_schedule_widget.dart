import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
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
        color: AppColors.surface,
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            '다음 예정',
            style: AppTypography.heading3,
          ),

          SizedBox(height: 16), // md spacing

          // Next Dose Schedule
          _ScheduleItem(
            icon: Icons.medication_outlined,
            iconColor: AppColors.warning,
            title: '다음 투여',
            date: schedule.nextDoseDate,
            subtitle: '${schedule.nextDoseMg} mg',
          ),

          if (schedule.nextEscalationDate != null) ...[
            SizedBox(height: 24),

            // Next Escalation Schedule
            _ScheduleItem(
              icon: Icons.trending_up_outlined,
              iconColor: AppColors.textSecondary,
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
                style: AppTypography.caption,
              ),
              SizedBox(height: 2),
              Text(
                dateString,
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: AppTypography.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
