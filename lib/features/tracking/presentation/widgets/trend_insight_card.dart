import 'package:flutter/material.dart';

import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/tracking/domain/entities/trend_insight.dart';

/// 트렌드 인사이트 요약 카드
///
/// 전체 컨디션 요약과 주요 지표 표시
class TrendInsightCard extends StatelessWidget {
  final TrendInsight insight;
  final VoidCallback? onViewDetails;

  const TrendInsightCard({
    super.key,
    required this.insight,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.neutral200),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral900.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Text(
                _getDirectionEmoji(insight.overallDirection),
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.period == TrendPeriod.weekly ? '이번 주' : '이번 달',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                    Text(
                      _getDirectionLabel(insight.overallDirection),
                      style: AppTypography.heading3.copyWith(
                        color: _getDirectionColor(insight.overallDirection),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              // 기록률 배지
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getCompletionColor(insight.completionRate)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '기록률 ${insight.completionRate.toInt()}%',
                  style: AppTypography.caption.copyWith(
                    color: _getCompletionColor(insight.completionRate),
                    fontWeight: FontWeight.w600,
                  ),
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
            child: Text(
              insight.summaryMessage,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.neutral800,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 핵심 지표
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  label: '연속 기록',
                  value: '${insight.consecutiveDays}일',
                  icon: Icons.local_fire_department,
                  color: const Color(0xFFFF9800),
                ),
              ),
              const SizedBox(width: 12),
              if (insight.averageAppetiteScore != null)
                Expanded(
                  child: _buildMetric(
                    label: '평균 식욕',
                    value: insight.averageAppetiteScore!.toStringAsFixed(1),
                    icon: Icons.restaurant,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              if (insight.averageAppetiteScore != null)
                const SizedBox(width: 12),
              Expanded(
                child: _buildMetric(
                  label: '주의 신호',
                  value: '${insight.redFlagCount}회',
                  icon: Icons.warning_amber_rounded,
                  color: insight.redFlagCount > 0
                      ? AppColors.error
                      : AppColors.neutral400,
                ),
              ),
            ],
          ),

          // TOP 3 질문 트렌드
          if (insight.questionTrends.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              '컨디션 요약',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.neutral600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildQuestionSummary(),
          ],

          if (onViewDetails != null) ...[
            const SizedBox(height: 16),
            InkWell(
              onTap: onViewDetails,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '상세 보기',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetric({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.bodyLarge.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
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

  Widget _buildQuestionSummary() {
    // 상위 3개 (가장 좋은 것과 가장 나쁜 것)
    final sorted = List<QuestionTrend>.from(insight.questionTrends)
      ..sort((a, b) => b.goodRate.compareTo(a.goodRate));

    final best = sorted.take(2).toList();
    final worst = sorted.reversed.take(1).toList();
    final items = [...best, ...worst];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((trend) {
        return _buildQuestionChip(trend);
      }).toList(),
    );
  }

  Widget _buildQuestionChip(QuestionTrend trend) {
    final color = _getQuestionColor(trend.questionType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getQuestionEmoji(trend.questionType),
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            trend.label,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${trend.goodRate.toInt()}%',
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 2),
          Icon(
            _getDirectionIcon(trend.direction),
            size: 12,
            color: color,
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

  String _getDirectionLabel(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.improving:
        return '좋아지고 있어요';
      case TrendDirection.stable:
        return '안정적이에요';
      case TrendDirection.worsening:
        return '관리가 필요해요';
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

  IconData _getDirectionIcon(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.improving:
        return Icons.trending_up;
      case TrendDirection.stable:
        return Icons.trending_flat;
      case TrendDirection.worsening:
        return Icons.trending_down;
    }
  }

  Color _getCompletionColor(double rate) {
    if (rate >= 70) return const Color(0xFF4CAF50);
    if (rate >= 40) return const Color(0xFFFFC107);
    return const Color(0xFFFF9800);
  }

  Color _getQuestionColor(QuestionType type) {
    switch (type) {
      case QuestionType.meal:
        return const Color(0xFFFF9800);
      case QuestionType.hydration:
        return const Color(0xFF2196F3);
      case QuestionType.giComfort:
        return const Color(0xFF9C27B0);
      case QuestionType.bowel:
        return const Color(0xFF795548);
      case QuestionType.energy:
        return const Color(0xFFFFEB3B).withValues(red: 0.8, green: 0.7, blue: 0);
      case QuestionType.mood:
        return const Color(0xFFE91E63);
    }
  }

  String _getQuestionEmoji(QuestionType type) {
    switch (type) {
      case QuestionType.meal:
        return '🍽️';
      case QuestionType.hydration:
        return '💧';
      case QuestionType.giComfort:
        return '🫃';
      case QuestionType.bowel:
        return '🚽';
      case QuestionType.energy:
        return '⚡';
      case QuestionType.mood:
        return '😊';
    }
  }
}
