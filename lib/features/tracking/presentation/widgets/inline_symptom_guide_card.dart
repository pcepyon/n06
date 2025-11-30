import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

/// 증상 선택 시 즉시 표시되는 인라인 가이드 카드
///
/// Phase 1: 안심 퍼스트 가이드 리뉴얼 핵심 컴포넌트
/// - 증상 선택 후 같은 화면에 즉시 표시
/// - 안심 메시지 + 통계적 안심 + 즉시 행동 가이드 제공
/// - SlideTransition + FadeTransition 애니메이션
///
/// Design Tokens:
/// - Background: Neutral50 (#F8FAFC)
/// - Border: 1px Neutral200 (#E2E8F0)
/// - Border Radius: 12px (md)
/// - Padding: 16px (md)
/// - Animation: 300ms
class InlineSymptomGuideCard extends StatefulWidget {
  final String symptomName;
  final String reassuranceMessage;
  final String? reassuranceStat;
  final String immediateAction;
  final VoidCallback? onMoreInfoTap;

  const InlineSymptomGuideCard({
    super.key,
    required this.symptomName,
    required this.reassuranceMessage,
    this.reassuranceStat,
    required this.immediateAction,
    this.onMoreInfoTap,
  });

  @override
  State<InlineSymptomGuideCard> createState() => _InlineSymptomGuideCardState();
}

class _InlineSymptomGuideCardState extends State<InlineSymptomGuideCard>
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
        child: Container(
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
                widget.reassuranceMessage,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.neutral700,
                ),
              ),

              // 통계적 안심 (선택사항)
              if (widget.reassuranceStat != null) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.reassuranceStat!,
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
                          TextSpan(text: widget.immediateAction),
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
      ),
    );
  }
}
