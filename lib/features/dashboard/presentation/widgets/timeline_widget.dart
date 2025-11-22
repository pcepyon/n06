import 'package:flutter/material.dart';
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
          style: TextStyle(
            fontSize: 18, // lg
            fontWeight: FontWeight.w600, // Semibold
            color: Color(0xFF1E293B), // Neutral-800
            height: 1.3,
          ),
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
        return Color(0xFF3B82F6); // Info (Blue-500)
      case TimelineEventType.escalation:
        return Color(0xFFF59E0B); // Warning (Amber-500)
      case TimelineEventType.weightMilestone:
        return Color(0xFF10B981); // Success (Emerald-500)
      case TimelineEventType.badgeAchievement:
        return Color(0xFFF59E0B); // Warning (Amber-500, Gold)
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
                    color: Colors.white,
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
                      color: Color(0xFFCBD5E1), // Neutral-300
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
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24), // lg spacing between events
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 16, // base
                      fontWeight: FontWeight.w600, // Semibold
                      color: Color(0xFF1E293B), // Neutral-800
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 14, // sm
                      fontWeight: FontWeight.w400, // Regular
                      color: Color(0xFF475569), // Neutral-600
                      height: 1.5,
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
