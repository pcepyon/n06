import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/core/extensions/dashboard_message_extension.dart';
import '../../domain/entities/timeline_event.dart';

/// 여정 타임라인 위젯
///
/// TimelineWidget의 감정적 UX 개선 버전입니다.
/// - 상단에 여정 요약 (Forest 스타일)
/// - 마일스톤 이벤트 gold glow 효과 (Fitbit 스타일)
/// - 24시간 내 이벤트에 NEW 뱃지 (Fitbit 스타일)
/// - 최근 4개 이벤트만 표시, 나머지는 "더보기"로 이동
class JourneyTimelineWidget extends StatelessWidget {
  final List<TimelineEvent> events;

  /// 대시보드에 표시할 최대 이벤트 수
  static const int maxDisplayCount = 4;

  const JourneyTimelineWidget({
    super.key,
    required this.events,
  });

  /// 마일스톤 이벤트 개수 계산
  /// 성취 관련 이벤트만 카운트 (체중 마일스톤, 뱃지, 체크인 마일스톤)
  int getMilestoneCount(List<TimelineEvent> events) {
    return events
        .where((e) =>
            e.eventType == TimelineEventType.weightMilestone ||
            e.eventType == TimelineEventType.badgeAchievement ||
            e.eventType == TimelineEventType.checkinMilestone)
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

    // 최근 4개만 표시 (events는 최신순 정렬)
    final displayEvents = events.take(maxDisplayCount).toList();
    final hasMore = events.length > maxDisplayCount;
    final remainingCount = events.length - maxDisplayCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          context.l10n.dashboard_timeline_title,
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

        // Timeline Events (최근 4개만)
        Column(
          children: List.generate(displayEvents.length, (index) {
            final event = displayEvents[index];
            // 더보기 버튼이 있으면 마지막 아이템도 연결선 표시
            final isLast = !hasMore && index == displayEvents.length - 1;

            return _JourneyTimelineEventItem(
              event: event,
              isLast: isLast,
            );
          }),
        ),

        // 더보기 버튼
        if (hasMore)
          _ViewMoreButton(
            remainingCount: remainingCount,
            totalCount: events.length,
            onTap: () => context.push('/journey-detail'),
          ),
      ],
    );
  }
}

/// 더보기 버튼 위젯
class _ViewMoreButton extends StatelessWidget {
  final int remainingCount;
  final int totalCount;
  final VoidCallback onTap;

  const _ViewMoreButton({
    required this.remainingCount,
    required this.totalCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // 연결선 (타임라인 dot 위치에 맞춤)
            SizedBox(
              width: 20,
              child: Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.neutral300,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 버튼 텍스트
            Expanded(
              child: Row(
                children: [
                  Text(
                    context.l10n.dashboard_timeline_viewMore(remainingCount),
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
            child: Builder(
              builder: (context) => Text(
                context.l10n.dashboard_timeline_summary(weeksCount, milestoneCount),
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.history,
                ),
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

  /// 마일스톤 이벤트인지 확인 (gold glow 효과 적용 대상)
  bool get isMilestone {
    return event.eventType == TimelineEventType.weightMilestone ||
        event.eventType == TimelineEventType.badgeAchievement ||
        event.eventType == TimelineEventType.checkinMilestone;
  }

  /// "첫 기록" 이벤트인지 확인 (특별한 스타일 적용)
  bool get isFirstEvent {
    return event.eventType == TimelineEventType.firstCheckin ||
        event.eventType == TimelineEventType.firstWeightLog ||
        event.eventType == TimelineEventType.firstDose;
  }

  Color _getEventColor(TimelineEventType type) {
    switch (type) {
      // 기존 이벤트
      case TimelineEventType.treatmentStart:
        return AppColors.info;
      case TimelineEventType.escalation:
        return AppColors.warning;
      case TimelineEventType.weightMilestone:
        return AppColors.success;
      case TimelineEventType.badgeAchievement:
        return AppColors.achievement;
      // 신규 이벤트
      case TimelineEventType.checkinMilestone:
        return AppColors.achievement; // 연속 체크인 - 성취
      case TimelineEventType.firstCheckin:
        return AppColors.history; // 첫 체크인 - 히스토리
      case TimelineEventType.firstWeightLog:
        return AppColors.history; // 첫 체중 기록 - 히스토리
      case TimelineEventType.firstDose:
        return AppColors.primary; // 첫 투여 - 건강/완료
      case TimelineEventType.doseChange:
        return AppColors.info; // 용량 변경 - 정보
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
                  Builder(
                    builder: (context) => Row(
                      children: [
                        Flexible(
                          child: Text(
                            event.getTitle(context),
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
                  ),
                  const SizedBox(height: 4),
                  Builder(
                    builder: (context) => Text(
                      event.getSubtitle(context, event),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
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
