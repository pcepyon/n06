import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/coping_guide/domain/entities/coping_guide.dart';
import 'package:n06/features/tracking/domain/entities/pattern_insight.dart';
import 'package:n06/features/tracking/presentation/widgets/pattern_insight_card.dart';

/// 컨텍스트 인식 가이드 카드
///
/// Phase 2: InlineSymptomGuideCard 확장 버전
/// - Phase 1 안심 메시지 (InlineSymptomGuideCard 기능 포함)
/// - 패턴 인사이트 섹션 추가
/// - 이전 기록 기반 맞춤 메시지
///
/// Design Tokens:
/// - Background: Neutral-50 (#F8FAFC)
/// - Border: Neutral-200 (#E2E8F0), 1px
/// - Border Radius: 12px (md)
/// - Padding: 16px (md)
/// - Animation: 300ms
class ContextualGuideCard extends ConsumerStatefulWidget {
  final CopingGuide guide;
  final List<PatternInsight> insights;
  final VoidCallback? onMoreInfoTap;
  final VoidCallback? onDismissInsight;

  const ContextualGuideCard({
    super.key,
    required this.guide,
    this.insights = const [],
    this.onMoreInfoTap,
    this.onDismissInsight,
  });

  @override
  ConsumerState<ContextualGuideCard> createState() =>
      _ContextualGuideCardState();
}

class _ContextualGuideCardState extends ConsumerState<ContextualGuideCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 패턴 인사이트 (있을 경우 먼저 표시)
            if (widget.insights.isNotEmpty) ...[
              ...widget.insights.take(2).map((insight) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PatternInsightCard(
                      insight: insight,
                      onDismiss: widget.onDismissInsight,
                    ),
                  )),
            ],

            // 기본 안심 가이드 카드
            Container(
              decoration: BoxDecoration(
                color: AppColors.neutral50,
                border: Border.all(color: AppColors.neutral200, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 타이틀
                  Row(
                    children: [
                      const Text('😌', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '몸이 적응하는 중이에요',
                          style: AppTypography.heading3.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 안심 메시지
                  Text(
                    widget.guide.reassuranceMessage,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.neutral700,
                    ),
                  ),

                  // 통계적 안심 (선택사항)
                  if (widget.guide.reassuranceStat != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.guide.reassuranceStat!,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.neutral600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // 구분선
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.neutral200, height: 1),
                  const SizedBox(height: 16),

                  // 즉시 행동
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💧', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.neutral700,
                            ),
                            children: [
                              const TextSpan(
                                text: '지금 바로: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.neutral800,
                                ),
                              ),
                              TextSpan(text: widget.guide.immediateAction),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 더 알아보기 링크
                  if (widget.onMoreInfoTap != null) ...[
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: widget.onMoreInfoTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '더 알아보기',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.primary,
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
            ),
          ],
        ),
      ),
    );
  }
}
