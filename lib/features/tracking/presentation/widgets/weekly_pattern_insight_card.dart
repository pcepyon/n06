import 'package:flutter/material.dart';

import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/tracking/domain/entities/trend_insight.dart';

/// 주간 패턴 인사이트 카드 위젯
///
/// 주사 후 패턴, 개선/주의 영역, 추천 사항 표시
class WeeklyPatternInsightCard extends StatelessWidget {
  final TrendInsight insight;

  const WeeklyPatternInsightCard({
    super.key,
    required this.insight,
  });

  @override
  Widget build(BuildContext context) {
    final pattern = insight.patternInsight;
    final hasContent = pattern.hasPostInjectionPattern ||
        pattern.topConcernArea != null ||
        pattern.improvementArea != null ||
        pattern.recommendations.isNotEmpty;

    if (!hasContent) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.neutral200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                context.l10n.tracking_weeklyInsight_title,
                style: AppTypography.heading3.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 요약 메시지
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.neutral50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getDirectionEmoji(insight.overallDirection),
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    insight.summaryMessage,
                    style: AppTypography.bodyMedium.copyWith(
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 통계 요약
          _buildStatsSummary(context),
          const SizedBox(height: 16),

          // 주사 후 패턴
          if (pattern.hasPostInjectionPattern &&
              pattern.postInjectionInsight != null) ...[
            _buildInsightItem(
              context: context,
              icon: Icons.vaccines,
              color: AppColors.primary,
              title: context.l10n.tracking_weeklyInsight_postInjectionPattern,
              content: pattern.postInjectionInsight!,
            ),
            const SizedBox(height: 12),
          ],

          // 주의 영역
          if (pattern.topConcernArea != null) ...[
            _buildInsightItem(
              context: context,
              icon: Icons.warning_amber_rounded,
              color: const Color(0xFFFF9800),
              title: context.l10n.tracking_weeklyInsight_concernArea,
              content: context.l10n.tracking_weeklyInsight_concernMessage(
                  _getQuestionLabel(context, pattern.topConcernArea!)),
            ),
            const SizedBox(height: 12),
          ],

          // 개선 영역
          if (pattern.improvementArea != null) ...[
            _buildInsightItem(
              context: context,
              icon: Icons.trending_up,
              color: const Color(0xFF4CAF50),
              title: context.l10n.tracking_weeklyInsight_improvementArea,
              content: context.l10n.tracking_weeklyInsight_improvementMessage(
                  _getQuestionLabel(context, pattern.improvementArea!)),
            ),
            const SizedBox(height: 12),
          ],

          // 추천 사항
          if (pattern.recommendations.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 12),
            Text(
              context.l10n.tracking_weeklyInsight_recommendations,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...pattern.recommendations.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rec,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.neutral700,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsSummary(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            context: context,
            label: context.l10n.tracking_weeklyInsight_completionRate,
            value: '${insight.completionRate.toInt()}%',
            color: insight.completionRate >= 70
                ? const Color(0xFF4CAF50)
                : const Color(0xFFFF9800),
          ),
        ),
        Expanded(
          child: _buildStatItem(
            context: context,
            label: context.l10n.tracking_weeklyInsight_consecutiveDays,
            value: context.l10n
                .tracking_weeklyInsight_days(insight.consecutiveDays),
            color: AppColors.primary,
          ),
        ),
        if (insight.averageAppetiteScore != null)
          Expanded(
            child: _buildStatItem(
              context: context,
              label: context.l10n.tracking_weeklyInsight_averageAppetite,
              value: insight.averageAppetiteScore!.toStringAsFixed(1),
              color: const Color(0xFFFF9800),
            ),
          ),
        if (insight.redFlagCount > 0)
          Expanded(
            child: _buildStatItem(
              context: context,
              label: context.l10n.tracking_weeklyInsight_redFlags,
              value: context.l10n
                  .tracking_weeklyInsight_redFlagCount(insight.redFlagCount),
              color: AppColors.error,
            ),
          ),
      ],
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.heading3.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodySmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.neutral700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

  String _getQuestionLabel(BuildContext context, QuestionType type) {
    switch (type) {
      case QuestionType.meal:
        return context.l10n.tracking_weeklyInsight_questionLabel_meal;
      case QuestionType.hydration:
        return context.l10n.tracking_weeklyInsight_questionLabel_hydration;
      case QuestionType.giComfort:
        return context.l10n.tracking_weeklyInsight_questionLabel_giComfort;
      case QuestionType.bowel:
        return context.l10n.tracking_weeklyInsight_questionLabel_bowel;
      case QuestionType.energy:
        return context.l10n.tracking_weeklyInsight_questionLabel_energy;
      case QuestionType.mood:
        return context.l10n.tracking_weeklyInsight_questionLabel_mood;
    }
  }
}
