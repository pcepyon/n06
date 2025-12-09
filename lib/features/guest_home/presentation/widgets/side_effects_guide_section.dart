import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/guest_home/data/guest_home_content.dart';
import 'package:n06/features/guest_home/domain/entities/symptom_preview_data.dart';
import 'package:n06/features/guest_home/presentation/widgets/demo/demo_bottom_sheet.dart';
import 'package:n06/features/guest_home/presentation/widgets/demo/daily_checkin_demo.dart';

/// 부작용 대처 가이드 섹션
/// P0 인터랙션: Expandable Card with Content Reveal
/// P1 인터랙션: Symptom Severity Progress Bar
class SideEffectsGuideSection extends StatefulWidget {
  /// 섹션이 뷰포트에 보이는지 여부 (스크롤 기반 트리거)
  final bool isVisible;

  const SideEffectsGuideSection({
    super.key,
    this.isVisible = false,
  });

  @override
  State<SideEffectsGuideSection> createState() =>
      _SideEffectsGuideSectionState();
}

class _SideEffectsGuideSectionState extends State<SideEffectsGuideSection> {
  int? _expandedIndex;

  void _toggleExpand(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_expandedIndex == index) {
        _expandedIndex = null;
      } else {
        _expandedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더 (간결화)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                GuestHomeContent.symptomsSectionTitle,
                style: AppTypography.heading2.copyWith(
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                GuestHomeContent.symptomsSectionSubtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // 증상 카드 리스트
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: List.generate(
              GuestHomeContent.symptomPreviews.length,
              (index) => _SymptomCard(
                symptom: GuestHomeContent.symptomPreviews[index],
                isExpanded: _expandedIndex == index,
                onTap: () => _toggleExpand(index),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // 체험하기 버튼
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: OutlinedButton.icon(
              onPressed: () => showDemoBottomSheet(
                context: context,
                title: '데일리 체크인 체험',
                child: DailyCheckinDemo(
                  onComplete: () {},
                ),
              ),
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text('체험하기'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SymptomCard extends StatefulWidget {
  final SymptomPreviewData symptom;
  final bool isExpanded;
  final VoidCallback onTap;

  const _SymptomCard({
    required this.symptom,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  State<_SymptomCard> createState() => _SymptomCardState();
}

class _SymptomCardState extends State<_SymptomCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(_SymptomCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded && !oldWidget.isExpanded) {
      // 확장 시 프로그레스 바 애니메이션 시작
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _progressController.forward(from: 0);
        }
      });
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: widget.isExpanded ? AppColors.surface : AppColors.neutral50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isExpanded
                ? AppColors.secondary.withValues(alpha: 0.3)
                : AppColors.border,
            width: widget.isExpanded ? 1.5 : 1,
          ),
          boxShadow: widget.isExpanded
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 항상 보이는 헤더 부분
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.symptom.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.symptom.name,
                              style: AppTypography.heading3.copyWith(
                                color: widget.isExpanded
                                    ? AppColors.secondary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            if (!widget.isExpanded) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.symptom.shortDescription,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      AnimatedRotation(
                        turns: widget.isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: widget.isExpanded
                                ? AppColors.secondary.withValues(alpha: 0.1)
                                : AppColors.neutral200,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            size: 20,
                            color: widget.isExpanded
                                ? AppColors.secondary
                                : AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 확장된 콘텐츠 - AnimatedSize 사용으로 부드러운 전환
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: widget.isExpanded
                  ? _buildExpandedContent()
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 전체 설명
          Text(
            widget.symptom.fullDescription,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          // 구분선
          Container(
            height: 1,
            color: AppColors.border,
          ),
          const SizedBox(height: 16),
          // 대처법 섹션
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                '이렇게 해보세요',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 팁 리스트
          ...widget.symptom.tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 구분선
          Container(
            height: 1,
            color: AppColors.border,
          ),
          const SizedBox(height: 16),
          // P1: 발생 빈도 프로그레스 바
          _buildProgressSection(
            label: '발생 빈도',
            value: widget.symptom.frequencyPercent,
            displayText: _getFrequencyText(widget.symptom.frequencyPercent),
          ),
          const SizedBox(height: 12),
          // 회복 정보
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.successBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Text('📊', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.symptom.recoveryInfo,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 접기 버튼
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: widget.onTap,
              icon: const Icon(Icons.keyboard_arrow_up, size: 18),
              label: const Text('접기'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textTertiary,
                textStyle: AppTypography.labelSmall,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFrequencyText(double percent) {
    if (percent >= 0.6) return '높음 (약 ${(percent * 100).toInt()}%)';
    if (percent >= 0.4) return '중간 (약 ${(percent * 100).toInt()}%)';
    return '낮음 (약 ${(percent * 100).toInt()}%)';
  }

  Widget _buildProgressSection({
    required String label,
    required double value,
    required String displayText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            Text(
              displayText,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // 프로그레스 바
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.neutral200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value * _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondary,
                        AppColors.secondary.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
