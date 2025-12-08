import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/core/extensions/dashboard_message_extension.dart';
import 'package:n06/features/dashboard/application/notifiers/dashboard_notifier.dart';
import '../../domain/entities/timeline_event.dart';

/// 전체 여정 상세 화면
///
/// 대시보드의 치료 여정 섹션에서 "더보기" 클릭 시 이동
/// 모든 타임라인 이벤트를 스크롤 가능한 리스트로 표시
class JourneyDetailScreen extends ConsumerWidget {
  const JourneyDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          context.l10n.dashboard_journeyDetail_title,
          style: AppTypography.heading2,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.neutral700,
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.border,
            height: 1,
          ),
        ),
      ),
      body: dashboardState.when(
        loading: () => Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 4.0,
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 60,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.dashboard_error_loadFailed,
                  style: AppTypography.heading3,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        data: (dashboardData) {
          final events = dashboardData.timeline;

          if (events.isEmpty) {
            return _EmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final isLast = index == events.length - 1;

              return _JourneyTimelineEventItem(
                event: event,
                isLast: isLast,
              );
            },
          );
        },
      ),
    );
  }
}

/// 빈 상태 위젯
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timeline,
              size: 64,
              color: AppColors.neutral300,
            ),
            const SizedBox(height: 16),
            Text(
              '아직 기록된 여정이 없어요',
              style: AppTypography.heading3.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '첫 체크인을 하면 여정이 시작됩니다',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// 타임라인 이벤트 아이템 (journey_timeline_widget.dart와 동일한 디자인)
class _JourneyTimelineEventItem extends StatelessWidget {
  final TimelineEvent event;
  final bool isLast;

  const _JourneyTimelineEventItem({
    required this.event,
    required this.isLast,
  });

  bool isNew(DateTime eventDate) {
    return DateTime.now().difference(eventDate).inHours < 24;
  }

  bool get isMilestone {
    return event.eventType == TimelineEventType.weightMilestone ||
        event.eventType == TimelineEventType.badgeAchievement ||
        event.eventType == TimelineEventType.checkinMilestone;
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
        return AppColors.achievement;
      case TimelineEventType.checkinMilestone:
        return AppColors.achievement;
      case TimelineEventType.firstCheckin:
        return AppColors.history;
      case TimelineEventType.firstWeightLog:
        return AppColors.history;
      case TimelineEventType.firstDose:
        return AppColors.primary;
      case TimelineEventType.doseChange:
        return AppColors.info;
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
            width: 20,
            child: Column(
              children: [
                _buildTimelineDot(eventColor),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 3,
                      decoration: BoxDecoration(
                        color: AppColors.neutral300,
                      ),
                      margin: const EdgeInsets.only(top: 4, bottom: 4),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 16),

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
                          event.getTitle(context),
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (showNewBadge) ...[
                        const SizedBox(width: 8),
                        _NewBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.getSubtitle(context, event),
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

  Widget _buildTimelineDot(Color eventColor) {
    if (isMilestone) {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFEF3C7),
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
class _NewBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
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
