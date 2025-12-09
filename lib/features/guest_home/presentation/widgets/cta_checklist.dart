import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

/// CTA 체크리스트 데이터
class CtaCheckItem {
  final String id;
  final String label;
  final int requiredSectionIndex;

  const CtaCheckItem({
    required this.id,
    required this.label,
    required this.requiredSectionIndex,
  });
}

/// CTA 체크리스트 위젯
/// 사용자가 각 섹션을 확인했는지 체크하고 커밋먼트를 유도
class CtaChecklist extends StatefulWidget {
  final Set<int> visitedSections;
  final Set<String> checkedItems;
  final ValueChanged<String> onItemChecked;
  final bool allChecked;
  final ValueChanged<int>? onNavigateToSection;

  const CtaChecklist({
    super.key,
    required this.visitedSections,
    required this.checkedItems,
    required this.onItemChecked,
    required this.allChecked,
    this.onNavigateToSection,
  });

  /// 섹션 인덱스 매핑 (게스트홈 페이지 인덱스 기준)
  /// 0: Welcome, 1: NotYourFault, 2: ScientificEvidence, 3: FoodNoise,
  /// 4: HowItWorks, 5: JourneyPreview, 6: SideEffects, 7: AppFeatures,
  /// 8: InjectionGuide, 9: CTA
  static const List<CtaCheckItem> items = [
    CtaCheckItem(
      id: 'evidence',
      label: '과학적 근거를 확인했습니다',
      requiredSectionIndex: 2, // ScientificEvidenceSection
    ),
    CtaCheckItem(
      id: 'journey',
      label: '나의 여정을 이해했습니다',
      requiredSectionIndex: 5, // JourneyPreviewSection
    ),
    CtaCheckItem(
      id: 'sideEffects',
      label: '부작용 대처법을 확인했습니다',
      requiredSectionIndex: 6, // SideEffectsGuideSection
    ),
  ];

  @override
  State<CtaChecklist> createState() => _CtaChecklistState();
}

class _CtaChecklistState extends State<CtaChecklist>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void didUpdateWidget(CtaChecklist oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 새로 방문한 섹션이 있으면 펄스 애니메이션
    if (widget.visitedSections.length > oldWidget.visitedSections.length) {
      _pulseController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  bool _canCheck(CtaCheckItem item) {
    return widget.visitedSections.contains(item.requiredSectionIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.allChecked
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Icon(
                widget.allChecked ? Icons.check_circle : Icons.checklist,
                color: widget.allChecked
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '시작하기 전에 확인해주세요',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 체크리스트 아이템
          ...CtaChecklist.items.map((item) => _buildCheckItem(item)),
          // 완료 메시지
          if (widget.allChecked) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.successBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Text('✨', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '준비 완료! 이제 여정을 시작해보세요',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckItem(CtaCheckItem item) {
    final isChecked = widget.checkedItems.contains(item.id);
    final canCheck = _canCheck(item);
    final needsPulse = canCheck && !isChecked;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: canCheck
            ? () {
                HapticFeedback.lightImpact();
                widget.onItemChecked(item.id);
              }
            : null,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final pulseValue = needsPulse
                ? (1 + (_pulseController.value * 0.05))
                : 1.0;
            return Transform.scale(
              scale: pulseValue,
              child: child,
            );
          },
          child: Row(
            children: [
              // 체크박스
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isChecked
                      ? AppColors.primary
                      : canCheck
                          ? AppColors.surface
                          : AppColors.neutral100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isChecked
                        ? AppColors.primary
                        : canCheck
                            ? AppColors.primary.withValues(alpha: 0.5)
                            : AppColors.neutral300,
                    width: canCheck && !isChecked ? 2 : 1,
                  ),
                  boxShadow: canCheck && !isChecked
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: isChecked
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // 라벨
              Expanded(
                child: Text(
                  item.label,
                  style: AppTypography.bodySmall.copyWith(
                    color: isChecked
                        ? AppColors.textSecondary
                        : canCheck
                            ? AppColors.textPrimary
                            : AppColors.textDisabled,
                    decoration:
                        isChecked ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              // 상태 표시 - 클릭하면 해당 섹션으로 이동
              if (!canCheck)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onNavigateToSection?.call(item.requiredSectionIndex);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back,
                          size: 12,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '확인하러 가기',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
