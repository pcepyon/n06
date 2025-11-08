import 'package:flutter/material.dart';
import 'package:n06/features/dashboard/domain/entities/timeline_event.dart';

class TimelineWidget extends StatelessWidget {
  final List<TimelineEvent> timeline;

  const TimelineWidget({
    super.key,
    required this.timeline,
  });

  @override
  Widget build(BuildContext context) {
    if (timeline.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            '아직 이벤트가 없습니다',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '치료 여정',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: timeline.length,
          itemBuilder: (context, index) {
            final event = timeline[index];
            return _TimelineEventItem(event: event);
          },
        ),
      ],
    );
  }
}

class _TimelineEventItem extends StatelessWidget {
  final TimelineEvent event;

  const _TimelineEventItem({required this.event});

  @override
  Widget build(BuildContext context) {
    final color = _getColorForEventType(event.eventType);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
              if (event != event) // For visual connecting line
                Container(
                  width: 2,
                  height: 40,
                  color: Colors.grey[300],
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  event.description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForEventType(TimelineEventType type) {
    switch (type) {
      case TimelineEventType.treatmentStart:
        return Colors.blue;
      case TimelineEventType.escalation:
        return Colors.orange;
      case TimelineEventType.weightMilestone:
        return Colors.green;
      case TimelineEventType.badgeAchievement:
        return Colors.amber;
    }
  }
}
