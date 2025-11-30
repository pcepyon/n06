import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/tracking/domain/entities/trend_insight.dart';

/// 트렌드 인사이트 카드
///
/// Phase 3: 트렌드 대시보드
/// - 요약 메시지 (큰 텍스트)
/// - TOP 3 증상 리스트
/// - 전체 방향 아이콘 (↑ ↓ →)
///
/// Design Tokens:
/// - Background: White (#FFFFFF)
/// - Border: Neutral-200 (#E2E8F0)
/// - Border Radius: md (12px)
/// - Padding: md (16px)
/// - Shadow: sm
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
          // 헤더 (방향 아이콘 + 기간)
          Row(
            children: [
              Text(
                _getDirectionIcon(insight.overallDirection),
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Text(
                insight.period == TrendPeriod.weekly ? '이번 주' : '이번 달',
                style: AppTypography.heading3.copyWith(
                  color: AppColors.neutral700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 요약 메시지
          Text(
            insight.summaryMessage,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.neutral800,
              fontWeight: FontWeight.w600,
            ),
          ),

          if (insight.frequencies.isNotEmpty) ...[
            const SizedBox(height: 16),

            // 구분선
            Container(
              height: 1,
              color: AppColors.neutral200,
            ),

            const SizedBox(height: 16),

            // TOP 3 증상 리스트
            Text(
              '많이 기록된 증상',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.neutral600,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            ...insight.frequencies.take(3).map((frequency) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      frequency.symptomName,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${frequency.count}회',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${frequency.percentageOfTotal.toStringAsFixed(0)}%)',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          if (onViewDetails != null) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: onViewDetails,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
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

  String _getDirectionIcon(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.improving:
        return '📉';
      case TrendDirection.stable:
        return '➡️';
      case TrendDirection.worsening:
        return '📈';
    }
  }
}
