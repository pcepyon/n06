import 'package:equatable/equatable.dart';
import 'package:n06/features/dashboard/domain/entities/next_schedule.dart';
import 'package:n06/features/dashboard/domain/entities/timeline_event.dart';
import 'package:n06/features/dashboard/domain/entities/user_badge.dart';
import 'package:n06/features/dashboard/domain/entities/weekly_progress.dart';
import 'package:n06/features/dashboard/domain/entities/weekly_summary.dart';

class DashboardData extends Equatable {
  final String userName;
  final int continuousRecordDays;
  final int currentWeek;
  final WeeklyProgress weeklyProgress;
  final NextSchedule nextSchedule;
  final WeeklySummary weeklySummary;
  final List<UserBadge> badges;
  final List<TimelineEvent> timeline;
  final String? insightMessage;

  const DashboardData({
    required this.userName,
    required this.continuousRecordDays,
    required this.currentWeek,
    required this.weeklyProgress,
    required this.nextSchedule,
    required this.weeklySummary,
    required this.badges,
    required this.timeline,
    this.insightMessage,
  });

  DashboardData copyWith({
    String? userName,
    int? continuousRecordDays,
    int? currentWeek,
    WeeklyProgress? weeklyProgress,
    NextSchedule? nextSchedule,
    WeeklySummary? weeklySummary,
    List<UserBadge>? badges,
    List<TimelineEvent>? timeline,
    String? insightMessage,
  }) {
    return DashboardData(
      userName: userName ?? this.userName,
      continuousRecordDays: continuousRecordDays ?? this.continuousRecordDays,
      currentWeek: currentWeek ?? this.currentWeek,
      weeklyProgress: weeklyProgress ?? this.weeklyProgress,
      nextSchedule: nextSchedule ?? this.nextSchedule,
      weeklySummary: weeklySummary ?? this.weeklySummary,
      badges: badges ?? this.badges,
      timeline: timeline ?? this.timeline,
      insightMessage: insightMessage ?? this.insightMessage,
    );
  }

  @override
  List<Object?> get props => [
        userName,
        continuousRecordDays,
        currentWeek,
        weeklyProgress,
        nextSchedule,
        weeklySummary,
        badges,
        timeline,
        insightMessage,
      ];

  @override
  String toString() =>
      'DashboardData(userName: $userName, continuousRecordDays: $continuousRecordDays, currentWeek: $currentWeek)';
}
