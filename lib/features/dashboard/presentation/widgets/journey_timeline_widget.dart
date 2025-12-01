import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import '../../domain/entities/timeline_event.dart';

/// 여정 타임라인 위젯
///
/// TimelineWidget의 감정적 UX 개선 버전입니다.
/// - 상단에 여정 요약 (Forest 스타일)
/// - 마일스톤 이벤트 gold glow 효과 (Fitbit 스타일)
/// - 24시간 내 이벤트에 NEW 뱃지 (Fitbit 스타일)
class JourneyTimelineWidget extends StatelessWidget {
  final List<TimelineEvent> events;

  const JourneyTimelineWidget({
    super.key,
    required this.events,
  });

  /// 마일스톤 이벤트 개수 계산
  /// weightMilestone, badgeAchievement 타입만 카운트
  int getMilestoneCount(List<TimelineEvent> events) {
    return events
        .where((e) =>
            e.eventType == TimelineEventType.weightMilestone ||
            e.eventType == TimelineEventType.badgeAchievement)
        .length;
  }

  /// 여정 주차 계산
  /// 가장 오래된 이벤트부터 현재까지의 주 수
  int getWeeksCount(List<TimelineEvent> events) {
    if (events.isEmpty) return 0;
    // events가 내림차순 정렬되어 있다고 가정 (최신이 먼저)
    final earliest = events.last.dateTime;
    return DateTime.now().difference(earliest).inDays ~/ 7 + 1;
  }

  @override
  Widget build(BuildContext context) {
    final milestoneCount = getMilestoneCount(events);
    final weeksCount = getWeeksCount(events);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          '치료 여정',
          style: AppTypography.heading2,
        ),

        const SizedBox(height: 16), // md spacing

        // Journey Summary (NEW - Forest 스타일)
        if (events.isNotEmpty)
          _JourneySummary(
            weeksCount: weeksCount,
            milestoneCount: milestoneCount,
          ),

        if (events.isNotEmpty) const SizedBox(height: 16),

        // Timeline Events
        Column(
          children: List.generate(events.length, (index) {
            final event = events[index];
            final isLast = index == events.length - 1;

            return _JourneyTimelineEventItem(
              event: event,
              isLast: isLast,
            );
          }),
        ),
      ],
    );
  }
}

/// 여정 요약 컨테이너
/// "X주간 X개의 성취를 달성했어요!" 메시지 표시
class _JourneySummary extends StatelessWidget {
  final int weeksCount;
  final int milestoneCount;

  const _JourneySummary({
    required this.weeksCount,
    required this.milestoneCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.historyBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.emoji_events,
            size: 20,
            color: AppColors.achievement,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$weeksCount주간 $milestoneCount개의 성취를 달성했어요!',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.history,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 타임라인 이벤트 아이템
/// 마일스톤은 gold glow, NEW 뱃지 지원
class _JourneyTimelineEventItem extends StatelessWidget {
  final TimelineEvent event;
  final bool isLast;

  const _JourneyTimelineEventItem({
    required this.event,
    required this.isLast,
  });

  /// 24시간 이내 이벤트인지 확인
  bool isNew(DateTime eventDate) {
    return DateTime.now().difference(eventDate).inHours < 24;
  }

  /// 마일스톤 이벤트인지 확인
  bool get isMilestone {
    return event.eventType == TimelineEventType.weightMilestone ||
        event.eventType == TimelineEventType.badgeAchievement;
  }

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
    final showNewBadge = isNew(event.dateTime);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dot and Connector Column
          SizedBox(
            width: 20, // 마일스톤용으로 약간 넓게
            child: Column(
              children: [
                // Timeline Dot
                _buildTimelineDot(eventColor),

                // Connector Line (if not last)
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 3,
                      decoration: BoxDecoration(
                        color: AppColors.neutral300, // Neutral-300
                      ),
                      margin: const EdgeInsets.only(top: 4, bottom: 4),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 16), // md spacing

          // Event Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Row with NEW Badge
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          event.title,
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      // NEW Badge (if within 24h)
                      if (showNewBadge) ...[
                        const SizedBox(width: 8),
                        _NewBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
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

  /// 타임라인 dot 빌드
  /// 일반 이벤트: 16px, 3px border
  /// 마일스톤: 20px, 4px border, gold glow
  Widget _buildTimelineDot(Color eventColor) {
    if (isMilestone) {
      // 마일스톤 dot - gold glow 효과
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFEF3C7), // Gold-100
          border: Border.all(
            color: AppColors.gold,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.4),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
      );
    }

    // 일반 이벤트 dot
    return Container(
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
    );
  }
}

/// NEW 뱃지 위젯
/// 24시간 내 이벤트에 표시
class _NewBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999), // full radius
      ),
      child: Text(
        'NEW',
        style: AppTypography.labelSmall.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
