import 'package:equatable/equatable.dart';
import 'package:n06/features/dashboard/domain/entities/dashboard_message_type.dart';

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
  final DashboardMessageType titleMessageType;
  final String? doseMg; // For treatmentStart and escalation
  final int? milestonePercent; // For weightMilestone
  final String? weightKg; // For weightMilestone
  final String? metadata; // JSON string for additional data

  const TimelineEvent({
    required this.id,
    required this.dateTime,
    required this.eventType,
    required this.titleMessageType,
    this.doseMg,
    this.milestonePercent,
    this.weightKg,
    this.metadata,
  });

  TimelineEvent copyWith({
    String? id,
    DateTime? dateTime,
    TimelineEventType? eventType,
    DashboardMessageType? titleMessageType,
    String? doseMg,
    int? milestonePercent,
    String? weightKg,
    String? metadata,
  }) {
    return TimelineEvent(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      eventType: eventType ?? this.eventType,
      titleMessageType: titleMessageType ?? this.titleMessageType,
      doseMg: doseMg ?? this.doseMg,
      milestonePercent: milestonePercent ?? this.milestonePercent,
      weightKg: weightKg ?? this.weightKg,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        dateTime,
        eventType,
        titleMessageType,
        doseMg,
        milestonePercent,
        weightKg,
        metadata
      ];

  @override
  String toString() =>
      'TimelineEvent(dateTime: $dateTime, eventType: $eventType, titleMessageType: $titleMessageType)';
}
