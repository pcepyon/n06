import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/core/extensions/dashboard_message_extension.dart';
import 'package:n06/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:n06/features/dashboard/domain/entities/dashboard_message_type.dart';

/// EmotionalGreetingWidget - 감정적으로 지지하고 동기를 부여하는 따뜻한 인사 위젯
///
/// Headspace/Noom 스타일의 따뜻한 UX를 제공합니다:
/// - 시간대별 맞춤 인사
/// - 연속 기록일을 "성장의 증거"로 프레이밍
/// - 격려 메시지를 따뜻한 컨테이너로 표시
class EmotionalGreetingWidget extends StatelessWidget {
  final DashboardData dashboardData;

  const EmotionalGreetingWidget({
    super.key,
    required this.dashboardData,
  });

  /// 시간대별 따뜻한 인사 메시지 생성 (Headspace 스타일)
  String _getTimeBasedGreeting(BuildContext context, String userName) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return context.l10n.dashboard_greeting_morning(userName);
    } else if (hour < 18) {
      return context.l10n.dashboard_greeting_afternoon(userName);
    } else {
      return context.l10n.dashboard_greeting_evening(userName);
    }
  }

  /// 연속 기록일에 의미를 부여하는 텍스트 생성
  String _getContinuousRecordLabel(BuildContext context, int days) {
    if (days >= 30) {
      return context.l10n.dashboard_greeting_continuousRecord_month;
    } else if (days >= 14) {
      return context.l10n.dashboard_greeting_continuousRecord_twoWeeks;
    } else if (days >= 7) {
      return context.l10n.dashboard_greeting_continuousRecord_week;
    }
    return context.l10n.dashboard_greeting_continuousRecord_default;
  }

  /// 연속 기록일에 따른 격려 메시지 생성
  String? _getEncouragementMessage(BuildContext context, int days, InsightMessageData? insightMessageData) {
    // 마일스톤 달성 시 특별 메시지
    if (days >= 30) {
      return context.l10n.dashboard_greeting_encouragement_month;
    } else if (days >= 14) {
      return context.l10n.dashboard_greeting_encouragement_twoWeeks;
    } else if (days >= 7) {
      return context.l10n.dashboard_greeting_encouragement_week;
    }
    // 마일스톤이 아니면 insightMessageData 타입에 따른 메시지 사용
    if (insightMessageData != null) {
      return insightMessageData.type.toLocalizedString(context);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final encouragementMessage = _getEncouragementMessage(
      context,
      dashboardData.continuousRecordDays,
      dashboardData.insightMessageData,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: AppColors.neutral200,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral900.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 시간대별 따뜻한 인사
          Text(
            _getTimeBasedGreeting(context, dashboardData.userName),
            style: AppTypography.display,
          ),
          const SizedBox(height: 16),
          // 통계 Row (2 columns)
          Row(
            children: [
              Expanded(
                child: _EmotionalStatColumn(
                  label: _getContinuousRecordLabel(
                    context,
                    dashboardData.continuousRecordDays,
                  ),
                  value: context.l10n.dashboard_greeting_continuousDays(dashboardData.continuousRecordDays),
                  valueColor: AppColors.achievement,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _EmotionalStatColumn(
                  label: context.l10n.dashboard_greeting_journeyWeek,
                  value: context.l10n.dashboard_greeting_currentWeek(dashboardData.currentWeek),
                  valueColor: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          // 격려 메시지 컨테이너 (존재할 경우)
          if (encouragementMessage != null) ...[
            const SizedBox(height: 16),
            _EncouragementContainer(message: encouragementMessage),
          ],
        ],
      ),
    );
  }
}

/// 감정적 의미가 담긴 통계 컬럼
class _EmotionalStatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _EmotionalStatColumn({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨: 12px Regular, textTertiary
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 4),
        // 값: 20px Semibold
        Text(
          value,
          style: AppTypography.heading2.copyWith(
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

/// 격려 메시지를 따뜻하게 감싸는 컨테이너 (Noom 스타일)
class _EncouragementContainer extends StatelessWidget {
  final String message;

  const _EncouragementContainer({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.welcomeBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // 스파클 아이콘으로 특별함 강조
          Builder(
            builder: (context) => Icon(
              Icons.auto_awesome,
              size: 20,
              color: AppColors.warmWelcome,
              semanticLabel: context.l10n.dashboard_greeting_encouragementIconLabel,
            ),
          ),
          const SizedBox(width: 8),
          // 격려 메시지: 14px Medium, WarmWelcome
          Expanded(
            child: Text(
              message,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.warmWelcome,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
