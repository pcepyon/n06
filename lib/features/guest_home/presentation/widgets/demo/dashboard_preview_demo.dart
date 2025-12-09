import 'package:flutter/material.dart';
import 'package:n06/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:n06/features/dashboard/domain/entities/dashboard_message_type.dart';
import 'package:n06/features/dashboard/domain/entities/next_schedule.dart';
import 'package:n06/features/dashboard/domain/entities/timeline_event.dart';
import 'package:n06/features/dashboard/domain/entities/user_badge.dart';
import 'package:n06/features/dashboard/domain/entities/weekly_progress.dart';
import 'package:n06/features/dashboard/domain/entities/weekly_summary.dart';
import 'package:n06/features/dashboard/presentation/widgets/celebratory_report_widget.dart';
import 'package:n06/features/dashboard/presentation/widgets/emotional_greeting_widget.dart';
import 'package:n06/features/dashboard/presentation/widgets/hopeful_schedule_widget.dart';

/// DashboardPreviewDemo - 게스트를 위한 대시보드 미리보기 체험 위젯
///
/// 실제 Provider/Notifier 없이 하드코딩된 더미 데이터로
/// 대시보드의 주요 위젯들을 렌더링하여 사용자에게 미리보기를 제공합니다.
class DashboardPreviewDemo extends StatelessWidget {
  const DashboardPreviewDemo({super.key});

  /// 하드코딩된 대시보드 더미 데이터 생성
  static DashboardData get _demoData {
    final now = DateTime.now();

    return DashboardData(
      userId: 'demo-user-id',
      userName: '체험 유저',
      continuousRecordDays: 12,
      currentWeek: 4,
      weeklyProgress: const WeeklyProgress(
        doseCompletedCount: 6,
        doseTargetCount: 7,
        doseRate: 85.7,
        weightRecordCount: 7,
        weightTargetCount: 7,
        weightRate: 100.0,
        symptomRecordCount: 5,
        symptomTargetCount: 7,
        symptomRate: 71.4,
      ),
      nextSchedule: NextSchedule(
        nextDoseDate: now.add(const Duration(days: 2)),
        nextDoseMg: 0.5,
        nextEscalationDate: now.add(const Duration(days: 14)),
        goalEstimateDate: now.add(const Duration(days: 90)),
      ),
      weeklySummary: const WeeklySummary(
        doseCompletedCount: 6,
        weightChangeKg: -1.2,
        symptomRecordCount: 3,
        adherencePercentage: 85.7,
      ),
      badges: [
        UserBadge(
          id: 'badge-1',
          userId: 'demo-user-id',
          badgeId: 'first-week',
          status: BadgeStatus.achieved,
          progressPercentage: 100,
          achievedAt: now.subtract(const Duration(days: 5)),
          createdAt: now.subtract(const Duration(days: 12)),
          updatedAt: now.subtract(const Duration(days: 5)),
        ),
        UserBadge(
          id: 'badge-2',
          userId: 'demo-user-id',
          badgeId: 'weight-loss-start',
          status: BadgeStatus.inProgress,
          progressPercentage: 60,
          achievedAt: null,
          createdAt: now.subtract(const Duration(days: 10)),
          updatedAt: now.subtract(const Duration(days: 1)),
        ),
      ],
      timeline: [
        TimelineEvent(
          id: 'timeline-1',
          dateTime: now.subtract(const Duration(days: 12)),
          eventType: TimelineEventType.treatmentStart,
          titleMessageType: DashboardMessageType.timelineTreatmentStart,
          doseMg: '0.25',
        ),
        TimelineEvent(
          id: 'timeline-2',
          dateTime: now.subtract(const Duration(days: 11)),
          eventType: TimelineEventType.firstCheckin,
          titleMessageType: DashboardMessageType.timelineFirstCheckin,
        ),
        TimelineEvent(
          id: 'timeline-3',
          dateTime: now.subtract(const Duration(days: 5)),
          eventType: TimelineEventType.checkinMilestone,
          titleMessageType: DashboardMessageType.timelineCheckinMilestone,
          checkinDays: 7,
        ),
      ],
      insightMessageData: const InsightMessageData(
        type: DashboardMessageType.insightWeeklyStreak,
        continuousRecordDays: 12,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. 감정적 인사 위젯
            EmotionalGreetingWidget(
              dashboardData: _demoData,
            ),

            const SizedBox(height: 16),

            // 2. 축하 스타일 주간 리포트 위젯
            CelebratoryReportWidget(
              summary: _demoData.weeklySummary,
            ),

            const SizedBox(height: 16),

            // 3. 희망적 일정 위젯
            HopefulScheduleWidget(
              schedule: _demoData.nextSchedule,
            ),
          ],
        ),
      ),
    );
  }
}
