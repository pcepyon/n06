import 'package:flutter/material.dart';

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
                '이번 주 인사이트',
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
          _buildStatsSummary(),
          const SizedBox(height: 16),

          // 주사 후 패턴
          if (pattern.hasPostInjectionPattern &&
              pattern.postInjectionInsight != null) ...[
            _buildInsightItem(
              icon: Icons.vaccines,
              color: AppColors.primary,
              title: '주사 후 패턴',
              content: pattern.postInjectionInsight!,
            ),
            const SizedBox(height: 12),
          ],

          // 주의 영역
          if (pattern.topConcernArea != null) ...[
            _buildInsightItem(
              icon: Icons.warning_amber_rounded,
              color: const Color(0xFFFF9800),
              title: '신경 쓸 영역',
              content:
                  '${_getQuestionLabel(pattern.topConcernArea!)} 상태가 좋지 않아요. 관리가 필요해요.',
            ),
            const SizedBox(height: 12),
          ],

          // 개선 영역
          if (pattern.improvementArea != null) ...[
            _buildInsightItem(
              icon: Icons.trending_up,
              color: const Color(0xFF4CAF50),
              title: '개선된 영역',
              content:
                  '${_getQuestionLabel(pattern.improvementArea!)} 상태가 좋아지고 있어요!',
            ),
            const SizedBox(height: 12),
          ],

          // 추천 사항
          if (pattern.recommendations.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 12),
            Text(
              '추천 사항',
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

  Widget _buildStatsSummary() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            label: '기록률',
            value: '${insight.completionRate.toInt()}%',
            color: insight.completionRate >= 70
                ? const Color(0xFF4CAF50)
                : const Color(0xFFFF9800),
          ),
        ),
        Expanded(
          child: _buildStatItem(
            label: '연속 기록',
            value: '${insight.consecutiveDays}일',
            color: AppColors.primary,
          ),
        ),
        if (insight.averageAppetiteScore != null)
          Expanded(
            child: _buildStatItem(
              label: '평균 식욕',
              value: insight.averageAppetiteScore!.toStringAsFixed(1),
              color: const Color(0xFFFF9800),
            ),
          ),
        if (insight.redFlagCount > 0)
          Expanded(
            child: _buildStatItem(
              label: '주의 신호',
              value: '${insight.redFlagCount}회',
              color: AppColors.error,
            ),
          ),
      ],
    );
  }

  Widget _buildStatItem({
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

  String _getQuestionLabel(QuestionType type) {
    switch (type) {
      case QuestionType.meal:
        return '식사';
      case QuestionType.hydration:
        return '수분';
      case QuestionType.giComfort:
        return '속 편안함';
      case QuestionType.bowel:
        return '배변';
      case QuestionType.energy:
        return '에너지';
      case QuestionType.mood:
        return '기분';
    }
  }
}
