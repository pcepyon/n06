import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:n06/features/dashboard/domain/entities/dashboard_message_type.dart';
import 'package:n06/features/dashboard/domain/entities/weekly_progress.dart';
import 'package:n06/features/dashboard/domain/entities/next_schedule.dart';
import 'package:n06/features/dashboard/domain/entities/weekly_summary.dart';

void main() {
  group('DashboardData', () {
    final weeklyProgress = WeeklyProgress(
      doseCompletedCount: 3,
      doseTargetCount: 3,
      doseRate: 1.0,
      weightRecordCount: 3,
      weightTargetCount: 7,
      weightRate: 0.43,
      symptomRecordCount: 2,
      symptomTargetCount: 7,
      symptomRate: 0.29,
    );

    final nextSchedule = NextSchedule(
      nextDoseDate: DateTime(2024, 11, 9),
      nextDoseMg: 0.5,
      nextEscalationDate: DateTime(2024, 11, 23),
      goalEstimateDate: DateTime(2024, 12, 20),
    );

    final weeklySummary = WeeklySummary(
      doseCompletedCount: 3,
      weightChangeKg: -1.2,
      symptomRecordCount: 2,
      adherencePercentage: 100.0,
    );

    final insightData = InsightMessageData(
      type: DashboardMessageType.insightKeepRecording,
      continuousRecordDays: 5,
    );

    final dashboardData = DashboardData(
      userId: 'test-user-id',
      userName: 'John Doe',
      continuousRecordDays: 5,
      currentWeek: 2,
      weeklyProgress: weeklyProgress,
      nextSchedule: nextSchedule,
      weeklySummary: weeklySummary,
      badges: [],
      timeline: [],
      insightMessageData: insightData,
    );

    test('should create valid DashboardData instance', () {
      expect(dashboardData.userName, 'John Doe');
      expect(dashboardData.continuousRecordDays, 5);
      expect(dashboardData.currentWeek, 2);
      expect(dashboardData.weeklyProgress, weeklyProgress);
      expect(dashboardData.nextSchedule, nextSchedule);
      expect(dashboardData.weeklySummary, weeklySummary);
      expect(dashboardData.badges, []);
      expect(dashboardData.timeline, []);
      expect(dashboardData.insightMessageData, insightData);
    });

    test('should support equality comparison', () {
      final dashboardData2 = DashboardData(
        userId: 'test-user-id',
        userName: 'John Doe',
        continuousRecordDays: 5,
        currentWeek: 2,
        weeklyProgress: weeklyProgress,
        nextSchedule: nextSchedule,
        weeklySummary: weeklySummary,
        badges: [],
        timeline: [],
        insightMessageData: insightData,
      );

      expect(dashboardData, dashboardData2);
    });

    test('should support inequality comparison', () {
      final dashboardData2 = DashboardData(
        userId: 'test-user-id',
        userName: 'Jane Doe',
        continuousRecordDays: 5,
        currentWeek: 2,
        weeklyProgress: weeklyProgress,
        nextSchedule: nextSchedule,
        weeklySummary: weeklySummary,
        badges: [],
        timeline: [],
        insightMessageData: null,
      );

      expect(dashboardData, isNot(dashboardData2));
    });

    test('should copyWith correctly', () {
      final copied = dashboardData.copyWith(
        userName: 'Jane Doe',
        continuousRecordDays: 10,
      );

      expect(copied.userName, 'Jane Doe');
      expect(copied.continuousRecordDays, 10);
      expect(copied.currentWeek, 2);
      expect(copied.weeklyProgress, weeklyProgress);
    });
  });
}
