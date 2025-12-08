import 'package:equatable/equatable.dart';
import 'package:n06/features/dashboard/domain/entities/dashboard_message_type.dart';

enum TimelineEventType {
  /// 치료 시작
  treatmentStart,

  /// 용량 증량 (escalation plan에 따른 예정된 증량)
  escalation,

  /// 체중 마일스톤 (25%, 50%, 75%, 100%)
  weightMilestone,

  /// 뱃지 달성
  badgeAchievement,

  /// 연속 체크인 마일스톤 (3, 7, 14, 21, 30, 60, 90일)
  checkinMilestone,

  /// 첫 체크인
  firstCheckin,

  /// 첫 체중 기록
  firstWeightLog,

  /// 첫 투여 기록
  firstDose,

  /// 용량 변경 (새로운 용량 첫 투여)
  doseChange,
}

class TimelineEvent extends Equatable {
  final String id;
  final DateTime dateTime;
  final TimelineEventType eventType;
  final DashboardMessageType titleMessageType;
  final String? doseMg; // For treatmentStart, escalation, doseChange
  final int? milestonePercent; // For weightMilestone
  final String? weightKg; // For weightMilestone, firstWeightLog
  final String? metadata; // JSON string for additional data
  final int? checkinDays; // For checkinMilestone (3, 7, 14, 21, 30, 60, 90)
  final String? badgeId; // For badgeAchievement
  final String? badgeName; // For badgeAchievement (localized name)

  const TimelineEvent({
    required this.id,
    required this.dateTime,
    required this.eventType,
    required this.titleMessageType,
    this.doseMg,
    this.milestonePercent,
    this.weightKg,
    this.metadata,
    this.checkinDays,
    this.badgeId,
    this.badgeName,
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
    int? checkinDays,
    String? badgeId,
    String? badgeName,
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
      checkinDays: checkinDays ?? this.checkinDays,
      badgeId: badgeId ?? this.badgeId,
      badgeName: badgeName ?? this.badgeName,
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
        metadata,
        checkinDays,
        badgeId,
        badgeName,
      ];

  @override
  String toString() =>
      'TimelineEvent(dateTime: $dateTime, eventType: $eventType, titleMessageType: $titleMessageType)';
}
