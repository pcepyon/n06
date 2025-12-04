import 'package:flutter/material.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/features/dashboard/domain/entities/dashboard_message_type.dart';
import 'package:n06/features/dashboard/domain/entities/timeline_event.dart';

/// DashboardMessageType을 i18n 문자열로 변환하는 확장
extension DashboardMessageTypeExtension on DashboardMessageType {
  String toLocalizedString(BuildContext context) {
    final l10n = context.l10n;

    switch (this) {
      case DashboardMessageType.errorNotAuthenticated:
        return l10n.dashboard_errorNotAuthenticated;
      case DashboardMessageType.errorProfileNotFound:
        return l10n.dashboard_errorProfileNotFound;
      case DashboardMessageType.errorActivePlanNotFound:
        return l10n.dashboard_errorActivePlanNotFound;
      case DashboardMessageType.timelineTreatmentStart:
        return l10n.dashboard_timelineTreatmentStart;
      case DashboardMessageType.timelineEscalation:
        return l10n.dashboard_timelineEscalation;
      case DashboardMessageType.timelineWeightMilestone:
        return l10n.dashboard_timelineWeightMilestone(0); // Default, use getTitle on TimelineEvent for actual value
      case DashboardMessageType.insight30DaysStreak:
        return l10n.dashboard_insight30DaysStreak;
      case DashboardMessageType.insightWeeklyStreak:
        return l10n.dashboard_insightWeeklyStreakWithDays(0); // Default, use toLocalizedString on InsightMessageData for actual value
      case DashboardMessageType.insightWeight10Percent:
        return l10n.dashboard_insightWeight10Percent;
      case DashboardMessageType.insightWeight5Percent:
        return l10n.dashboard_insightWeight5Percent;
      case DashboardMessageType.insightWeight1Percent:
        return l10n.dashboard_insightWeight1Percent;
      case DashboardMessageType.insightKeepRecording:
        return l10n.dashboard_insightKeepRecordingWithDays(0); // Default, use toLocalizedString on InsightMessageData for actual value
      case DashboardMessageType.insightFirstRecord:
        return l10n.dashboard_insightFirstRecord;
    }
  }
}

/// InsightMessageData 헬퍼 확장
extension InsightMessageDataExtension on InsightMessageData {
  /// 동적 파라미터를 포함한 완전한 메시지 반환
  String toLocalizedString(BuildContext context) {
    final l10n = context.l10n;

    switch (type) {
      case DashboardMessageType.insightWeeklyStreak:
        return l10n.dashboard_insightWeeklyStreakWithDays(
            continuousRecordDays ?? 0);
      case DashboardMessageType.insightKeepRecording:
        return l10n.dashboard_insightKeepRecordingWithDays(
            continuousRecordDays ?? 0);
      default:
        return type.toLocalizedString(context);
    }
  }
}

/// TimelineEvent 헬퍼 - title과 description 생성
extension TimelineEventExtension on TimelineEvent {
  /// 타임라인 타이틀 반환 (i18n)
  String getTitle(BuildContext context) {
    final l10n = context.l10n;

    switch (titleMessageType) {
      case DashboardMessageType.timelineTreatmentStart:
        return l10n.dashboard_timelineTreatmentStart;
      case DashboardMessageType.timelineEscalation:
        return l10n.dashboard_timelineEscalation;
      case DashboardMessageType.timelineWeightMilestone:
        return l10n.dashboard_timelineWeightMilestoneTitle(milestonePercent ?? 0);
      default:
        return titleMessageType.toLocalizedString(context);
    }
  }

  /// 타임라인 서브타이틀/설명 반환 (i18n, 동적 파라미터 포함)
  String getSubtitle(BuildContext context, TimelineEvent event) {
    final l10n = context.l10n;

    switch (titleMessageType) {
      case DashboardMessageType.timelineTreatmentStart:
        return l10n.dashboard_timelineTreatmentStartDesc(doseMg ?? '0');
      case DashboardMessageType.timelineEscalation:
        return l10n.dashboard_timelineEscalationDesc(doseMg ?? '0');
      case DashboardMessageType.timelineWeightMilestone:
        return l10n.dashboard_timelineWeightMilestoneDesc(weightKg ?? '0');
      default:
        return '';
    }
  }
}
