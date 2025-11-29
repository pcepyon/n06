import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import '../../domain/entities/timeline_event.dart';

class TimelineWidget extends StatelessWidget {
  final List<TimelineEvent> events;

  const TimelineWidget({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          '치료 여정',
          style: AppTypography.heading3,
        ),

        SizedBox(height: 16), // md spacing

        // Timeline Events
        Column(
          children: List.generate(events.length, (index) {
            final event = events[index];
            final isLast = index == events.length - 1;

            return _TimelineEventItem(
              event: event,
              isLast: isLast,
            );
          }),
        ),
      ],
    );
  }
}

class _TimelineEventItem extends StatelessWidget {
  final TimelineEvent event;
  final bool isLast;

  const _TimelineEventItem({
    required this.event,
    required this.isLast,
  });

  Color _getEventColor(TimelineEventType type) {
    switch (type) {
      case TimelineEventType.treatmentStart:
        return AppColors.info;
      case TimelineEventType.escalation:
        return AppColors.warning;
      case TimelineEventType.weightMilestone:
        return AppColors.success;
      case TimelineEventType.badgeAchievement:
        return AppColors.gold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventColor = _getEventColor(event.eventType);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dot and Connector Column
          SizedBox(
            width: 16,
            child: Column(
              children: [
                // Timeline Dot
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border: Border.all(
                      color: eventColor,
                      width: 3,
                    ),
                  ),
                ),

                // Connector Line (if not last)
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 3,
                      color: AppColors.borderDark,
                      margin: EdgeInsets.only(top: 4, bottom: 4),
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(width: 16), // md spacing

          // Event Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    event.description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
