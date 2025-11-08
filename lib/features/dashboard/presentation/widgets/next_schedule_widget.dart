import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:n06/features/dashboard/domain/entities/next_schedule.dart';

class NextScheduleWidget extends StatelessWidget {
  final NextSchedule nextSchedule;

  const NextScheduleWidget({
    super.key,
    required this.nextSchedule,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('M월 d일 (EEEE)', 'ko_KR');

    return Card(
      elevation: 0,
      color: Colors.orange[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '다음 예정',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _ScheduleItem(
              icon: Icons.calendar_today,
              title: '다음 투여',
              date: dateFormat.format(nextSchedule.nextDoseDate),
              subtitle: '${nextSchedule.nextDoseMg} mg',
            ),
            const SizedBox(height: 12),
            if (nextSchedule.nextEscalationDate != null)
              _ScheduleItem(
                icon: Icons.trending_up,
                title: '다음 증량',
                date: dateFormat.format(nextSchedule.nextEscalationDate!),
              ),
            if (nextSchedule.nextEscalationDate != null) const SizedBox(height: 12),
            if (nextSchedule.goalEstimateDate != null)
              _ScheduleItem(
                icon: Icons.flag,
                title: '목표 달성 예상',
                date: dateFormat.format(nextSchedule.goalEstimateDate!),
              ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String date;
  final String? subtitle;

  const _ScheduleItem({
    required this.icon,
    required this.title,
    required this.date,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(date, style: const TextStyle(fontWeight: FontWeight.w500)),
                  if (subtitle != null)
                    Text(subtitle!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
