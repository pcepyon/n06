import 'package:equatable/equatable.dart';

enum TimelineEventType {
  treatmentStart,
  escalation,
  weightMilestone,
  badgeAchievement,
}

class TimelineEvent extends Equatable {
  final String id;
  final DateTime dateTime;
  final TimelineEventType eventType;
  final String title;
  final String description;
  final String? metadata; // JSON string for additional data

  const TimelineEvent({
    required this.id,
    required this.dateTime,
    required this.eventType,
    required this.title,
    required this.description,
    this.metadata,
  });

  TimelineEvent copyWith({
    String? id,
    DateTime? dateTime,
    TimelineEventType? eventType,
    String? title,
    String? description,
    String? metadata,
  }) {
    return TimelineEvent(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      eventType: eventType ?? this.eventType,
      title: title ?? this.title,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props =>
      [id, dateTime, eventType, title, description, metadata];

  @override
  String toString() =>
      'TimelineEvent(dateTime: $dateTime, eventType: $eventType, title: $title)';
}
