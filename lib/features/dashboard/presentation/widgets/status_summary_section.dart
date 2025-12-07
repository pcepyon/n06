import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:n06/features/tracking/domain/entities/trend_insight.dart';
import 'package:n06/features/tracking/application/notifiers/trend_insight_notifier.dart';

/// StatusSummarySection - 현재 상태 요약
///
/// Phase 1 요구사항:
/// - 현재 주차 + 진행률 (프로그레스 바)
/// - 다음 투여일 (간결한 카드)
/// - 체중 트렌드 (숫자 또는 미니 표시)
/// - 전반적 컨디션 요약 (TrendInsight 활용)
/// - 기존 DashboardData, NextSchedule, TrendInsight 데이터 활용
class StatusSummarySection extends ConsumerWidget {
  final DashboardData dashboardData;

  const StatusSummarySection({
    super.key,
    required this.dashboardData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          // 섹션 타이틀
          Text(
            '현재 상태',
            style: AppTypography.heading2,
          ),
          const SizedBox(height: 16),

          // 현재 주차 + 진행률
          _buildWeekProgress(context),
          const SizedBox(height: 16),

          // 다음 투여일
          _buildNextSchedule(context),
          const SizedBox(height: 16),

          // 체중 트렌드
          _buildWeightTrend(context),

          // 전반적 컨디션 요약 (TrendInsight) - dashboardData에서 userId 사용
          const SizedBox(height: 16),
          _buildConditionSummary(context, ref, dashboardData.userId),
        ],
      ),
    );
  }

  Widget _buildWeekProgress(BuildContext context) {
    final currentWeek = dashboardData.currentWeek;
    final progress = dashboardData.weeklyProgress;

    // 주간 전체 진행률 계산 (투여, 체중, 증상 기록의 평균)
    final totalProgress = (progress.doseRate + progress.weightRate + progress.symptomRate) / 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$currentWeek주차',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.neutral700,
              ),
            ),
            Text(
              '${(totalProgress * 100).toInt()}%',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.neutral600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 8,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 8,
                  color: AppColors.neutral200,
                ),
                FractionallySizedBox(
                  widthFactor: totalProgress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.6),
                          AppColors.primary,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextSchedule(BuildContext context) {
    final schedule = dashboardData.nextSchedule;
    final dateFormat = DateFormat('M월 d일 (E)', 'ko_KR');
    final dateString = dateFormat.format(schedule.nextDoseDate);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.medication_outlined,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '다음 투여일',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateString,
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightTrend(BuildContext context) {
    final summary = dashboardData.weeklySummary;
    final weightChange = summary.weightChangeKg;
    final isDecrease = weightChange < 0;
    final changeText = isDecrease
        ? '${weightChange.abs().toStringAsFixed(1)}kg 감소'
        : weightChange > 0
            ? '+${weightChange.toStringAsFixed(1)}kg'
            : '변화 없음';

    return Row(
      children: [
        Icon(
          isDecrease ? Icons.trending_down : Icons.trending_flat,
          size: 20,
          color: isDecrease ? AppColors.success : AppColors.neutral600,
        ),
        const SizedBox(width: 8),
        Text(
          '주간 체중 ',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        Text(
          changeText,
          style: AppTypography.bodySmall.copyWith(
            color: isDecrease ? AppColors.success : AppColors.neutral700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildConditionSummary(BuildContext context, WidgetRef ref, String userId) {
    final trendInsightState = ref.watch(
      trendInsightProvider(userId: userId, period: TrendPeriod.weekly),
    );

    return trendInsightState.when(
      loading: () => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.neutral50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '컨디션 분석 중...',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.neutral600,
              ),
            ),
          ],
        ),
      ),
      error: (error, stack) => const SizedBox.shrink(),
      data: (insight) {
        final directionLabel = _getDirectionLabel(insight.overallDirection);
        final directionColor = _getDirectionColor(insight.overallDirection);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(
                _getDirectionEmoji(insight.overallDirection),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
              Text(
                '전반적 컨디션: ',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
              Text(
                directionLabel,
                style: AppTypography.bodySmall.copyWith(
                  color: directionColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getDirectionEmoji(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.improving:
        return '📈';
      case TrendDirection.stable:
        return '➡️';
      case TrendDirection.worsening:
        return '📉';
    }
  }

  String _getDirectionLabel(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.improving:
        return '개선 중';
      case TrendDirection.stable:
        return '안정적';
      case TrendDirection.worsening:
        return '주의 필요';
    }
  }

  Color _getDirectionColor(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.improving:
        return const Color(0xFF4CAF50);
      case TrendDirection.stable:
        return AppColors.neutral700;
      case TrendDirection.worsening:
        return const Color(0xFFFF9800);
    }
  }
}
