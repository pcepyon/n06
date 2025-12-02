import 'package:flutter/material.dart';

import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/tracking/domain/entities/trend_insight.dart';

/// 주간 컨디션 차트 위젯
///
/// 6개 질문별 "good" 비율을 막대그래프로 표시
class WeeklyConditionChart extends StatelessWidget {
  final List<QuestionTrend> questionTrends;
  final void Function(QuestionTrend)? onTrendTap;

  const WeeklyConditionChart({
    super.key,
    required this.questionTrends,
    this.onTrendTap,
  });

  @override
  Widget build(BuildContext context) {
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
          ...questionTrends.map((trend) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildTrendRow(trend),
              )),
        ],
      ),
    );
  }

  Widget _buildTrendRow(QuestionTrend trend) {
    return GestureDetector(
      onTap: onTrendTap != null ? () => onTrendTap!(trend) : null,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 라벨 + 방향 아이콘 + 비율
          Row(
            children: [
              // 질문 아이콘
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _getQuestionColor(trend.questionType).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    _getQuestionEmoji(trend.questionType),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 라벨
              Expanded(
                child: Text(
                  trend.label,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // 방향 아이콘
              _buildDirectionIndicator(trend.direction),
              const SizedBox(width: 8),
              // 점수
              Text(
                '${trend.averageScore.toInt()}%',
                style: AppTypography.bodyMedium.copyWith(
                  color: _getRateColor(trend.averageScore),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 프로그레스 바
          _buildProgressBar(trend),
        ],
      ),
    );
  }

  Widget _buildProgressBar(QuestionTrend trend) {
    return Stack(
      children: [
        // 배경
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        // 진행률
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: 12,
              width: constraints.maxWidth * (trend.averageScore / 100),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getQuestionColor(trend.questionType),
                    _getQuestionColor(trend.questionType).withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDirectionIndicator(TrendDirection direction) {
    IconData icon;
    Color color;
    String tooltip;

    switch (direction) {
      case TrendDirection.improving:
        icon = Icons.trending_up;
        color = const Color(0xFF4CAF50);
        tooltip = '개선';
        break;
      case TrendDirection.stable:
        icon = Icons.trending_flat;
        color = AppColors.neutral500;
        tooltip = '유지';
        break;
      case TrendDirection.worsening:
        icon = Icons.trending_down;
        color = AppColors.error;
        tooltip = '주의';
        break;
    }

    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 2),
            Text(
              tooltip,
              style: AppTypography.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getQuestionColor(QuestionType type) {
    switch (type) {
      case QuestionType.meal:
        return const Color(0xFFFF9800); // Orange
      case QuestionType.hydration:
        return const Color(0xFF2196F3); // Blue
      case QuestionType.giComfort:
        return const Color(0xFF9C27B0); // Purple
      case QuestionType.bowel:
        return const Color(0xFF795548); // Brown
      case QuestionType.energy:
        return const Color(0xFFFFEB3B); // Yellow
      case QuestionType.mood:
        return const Color(0xFFE91E63); // Pink
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

  Color _getRateColor(double rate) {
    if (rate >= 80) return const Color(0xFF4CAF50);
    if (rate >= 60) return const Color(0xFF8BC34A);
    if (rate >= 40) return const Color(0xFFFFC107);
    if (rate >= 20) return const Color(0xFFFF9800);
    return AppColors.error;
  }
}
