import 'package:flutter/material.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/tracking/domain/entities/pattern_insight.dart';

/// 패턴 인사이트 카드
///
/// Phase 2: 컨텍스트 인식 가이드
/// - 패턴 유형별 아이콘/색상
/// - 메시지 + 제안
/// - 신뢰도 표시 (선택적)
///
/// Design Tokens:
/// - Background: Info 10% (#3B82F6)
/// - Border: Info 30%
/// - Border Radius: 12px (md)
/// - Padding: 16px (md)
class PatternInsightCard extends StatelessWidget {
  final PatternInsight insight;
  final VoidCallback? onDismiss;
  final VoidCallback? onLearnMore;
  final bool showConfidence;

  const PatternInsightCard({
    super.key,
    required this.insight,
    this.onDismiss,
    this.onLearnMore,
    this.showConfidence = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColorsForType(insight.type);

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border.all(color: colors.border, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 (아이콘 + 제목 + 닫기 버튼)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getIconForType(insight.type),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.tracking_patternInsight_title,
                  style: AppTypography.heading3.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral800,
                  ),
                ),
              ),
              if (onDismiss != null)
                InkWell(
                  onTap: onDismiss,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.neutral500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // 메시지
          Text(
            insight.message,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.neutral700,
            ),
          ),

          // 제안 (있을 경우)
          if (insight.suggestion != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💬', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight.suggestion!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 신뢰도 표시 (선택적)
          if (showConfidence) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.verified_outlined,
                  size: 14,
                  color: AppColors.neutral500,
                ),
                const SizedBox(width: 4),
                Text(
                  context.l10n.tracking_patternInsight_confidence(
                      (insight.confidence * 100).toStringAsFixed(0)),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ],

          // 더 알아보기 버튼 (선택적)
          if (onLearnMore != null) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: onLearnMore,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: colors.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      context.l10n.tracking_patternInsight_learnMore,
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.accent,
                        fontWeight: FontWeight.w500,
                      ),
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

  String _getIconForType(PatternType type) {
    switch (type) {
      case PatternType.recurring:
        return '🔄';
      case PatternType.contextRelated:
        return '💡';
      case PatternType.improving:
        return '📈';
      case PatternType.worsening:
        return '📉';
    }
  }

  _PatternColors _getColorsForType(PatternType type) {
    switch (type) {
      case PatternType.recurring:
        return _PatternColors(
          background: AppColors.info.withValues(alpha: 0.1),
          border: AppColors.info.withValues(alpha: 0.3),
          accent: AppColors.info,
        );
      case PatternType.contextRelated:
        return _PatternColors(
          background: AppColors.info.withValues(alpha: 0.1),
          border: AppColors.info.withValues(alpha: 0.3),
          accent: AppColors.info,
        );
      case PatternType.improving:
        return _PatternColors(
          background: AppColors.success.withValues(alpha: 0.1),
          border: AppColors.success.withValues(alpha: 0.3),
          accent: AppColors.success,
        );
      case PatternType.worsening:
        return _PatternColors(
          background: AppColors.warning.withValues(alpha: 0.1),
          border: AppColors.warning.withValues(alpha: 0.3),
          accent: AppColors.warning,
        );
    }
  }
}

class _PatternColors {
  final Color background;
  final Color border;
  final Color accent;

  _PatternColors({
    required this.background,
    required this.border,
    required this.accent,
  });
}
