import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/guest_home/data/guest_home_content.dart';
import 'package:n06/features/guest_home/domain/entities/journey_phase_data.dart';

/// 치료 여정 미리보기 섹션
/// P0 인터랙션: Progressive Disclosure Timeline, Milestone Celebration
class JourneyPreviewSection extends StatefulWidget {
  /// 섹션이 뷰포트에 보이는지 여부 (스크롤 기반 트리거)
  final bool isVisible;

  const JourneyPreviewSection({
    super.key,
    this.isVisible = false,
  });

  @override
  State<JourneyPreviewSection> createState() => _JourneyPreviewSectionState();
}

class _JourneyPreviewSectionState extends State<JourneyPreviewSection> {
  int? _expandedIndex;

  void _toggleExpand(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_expandedIndex == index) {
        _expandedIndex = null;
      } else {
        _expandedIndex = index;
        // 마지막 단계(그 이후) 열었을 때 마일스톤 축하
        if (index == GuestHomeContent.journeyPhases.length - 1) {
          HapticFeedback.mediumImpact();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                GuestHomeContent.journeySectionTitle,
                style: AppTypography.heading1.copyWith(
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                GuestHomeContent.journeySectionSubtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // 타임라인
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: List.generate(
              GuestHomeContent.journeyPhases.length,
              (index) {
                final phase = GuestHomeContent.journeyPhases[index];
                final isExpanded = _expandedIndex == index;
                final isLast = index == GuestHomeContent.journeyPhases.length - 1;

                return _JourneyPhaseItem(
                  phase: phase,
                  index: index,
                  isExpanded: isExpanded,
                  isLast: isLast,
                  onTap: () => _toggleExpand(index),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _JourneyPhaseItem extends StatefulWidget {
  final JourneyPhaseData phase;
  final int index;
  final bool isExpanded;
  final bool isLast;
  final VoidCallback onTap;

  const _JourneyPhaseItem({
    required this.phase,
    required this.index,
    required this.isExpanded,
    required this.isLast,
    required this.onTap,
  });

  @override
  State<_JourneyPhaseItem> createState() => _JourneyPhaseItemState();
}

class _JourneyPhaseItemState extends State<_JourneyPhaseItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _celebrationController;
  late final Animation<double> _celebrationAnimation;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _celebrationAnimation = CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void didUpdateWidget(_JourneyPhaseItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 마일스톤 축하 애니메이션 (마지막 단계 확장 시)
    if (widget.isExpanded && widget.isLast && !oldWidget.isExpanded) {
      _celebrationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 타임라인 마커 (고정 크기)
        SizedBox(
          width: 40,
          child: Column(
            children: [
              // 마커
              AnimatedBuilder(
                animation: _celebrationAnimation,
                builder: (context, child) {
                  final scale = widget.isLast && widget.isExpanded
                      ? 1.0 + (_celebrationAnimation.value * 0.3)
                      : (widget.isExpanded ? 1.2 : 1.0);

                  return Transform.scale(
                    scale: scale,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isExpanded
                            ? AppColors.primary
                            : AppColors.neutral300,
                        boxShadow: widget.isExpanded
                            ? [
                                BoxShadow(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: widget.isExpanded
                          ? const Icon(
                              Icons.check,
                              size: 10,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  );
                },
              ),
              // 연결선 - 고정 높이로 카드 아래까지 확장
              if (!widget.isLast)
                Container(
                  width: 2,
                  height: 80, // 기본 연결선 높이
                  margin: const EdgeInsets.only(top: 4),
                  color: widget.isExpanded
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : AppColors.neutral200,
                ),
            ],
          ),
        ),
        // 콘텐츠
        Expanded(
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.isExpanded
                    ? (widget.isLast
                        ? AppColors.successBackground
                        : AppColors.surface)
                    : AppColors.neutral50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.isExpanded
                      ? AppColors.primary.withValues(alpha: 0.3)
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
                  // 헤더
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: widget.isExpanded
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : AppColors.neutral200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.phase.weekRange,
                          style: AppTypography.labelSmall.copyWith(
                            color: widget.isExpanded
                                ? AppColors.primary
                                : AppColors.textTertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.phase.shortLabel,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const Spacer(),
                      AnimatedRotation(
                        turns: widget.isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: 20,
                          color: widget.isExpanded
                              ? AppColors.primary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 제목
                  Text(
                    widget.phase.title,
                    style: AppTypography.heading3.copyWith(
                      color: widget.isExpanded
                          ? AppColors.primary
                          : AppColors.textPrimary,
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
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedContent() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 설명
          Text(
            widget.phase.description,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          // 기대 사항 (있는 경우)
          if (widget.phase.expectations.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              widget.phase.expectationsTitle,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ...widget.phase.expectations.map(
              (expectation) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    Expanded(
                      child: Text(
                        expectation,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          // 격려 메시지
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isLast ? '🎉' : '💚',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.phase.encouragement,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 접기 버튼
          const SizedBox(height: 12),
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
}
