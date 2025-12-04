import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/onboarding/presentation/widgets/common/onboarding_page_template.dart';

class HowItWorksScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onSkip;

  const HowItWorksScreen({
    super.key,
    required this.onNext,
    this.onSkip,
  });

  @override
  State<HowItWorksScreen> createState() => _HowItWorksScreenState();
}

class _HowItWorksScreenState extends State<HowItWorksScreen> {
  final Set<String> _expandedItems = {};

  bool get _allExpanded =>
      _expandedItems.containsAll({'brain', 'stomach'});

  void _onExpansionChanged(String id, bool isExpanded) {
    setState(() {
      if (isExpanded) {
        _expandedItems.add(id);
      } else {
        _expandedItems.remove(id);
      }
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingPageTemplate(
      title: context.l10n.onboarding_howItWorks_title,
      showSkip: true,
      onSkip: widget.onSkip,
      onNext: widget.onNext,
      isNextEnabled: _allExpanded,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 인터랙션 안내
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.educationBackground, // Blue-50
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.education.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.touch_app,
                  size: 16,
                  color: AppColors.education,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.onboarding_howItWorks_tapInstruction,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.education,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 뇌 설명
          _buildExpandableCard(
            context: context,
            id: 'brain',
            icon: '🧠',
            title: context.l10n.onboarding_howItWorks_brainTitle,
            description: context.l10n.onboarding_howItWorks_brainDescription,
            isExpanded: _expandedItems.contains('brain'),
            onExpansionChanged: (isExpanded) =>
                _onExpansionChanged('brain', isExpanded),
          ),

          const SizedBox(height: 16),

          // 위 설명
          _buildExpandableCard(
            context: context,
            id: 'stomach',
            icon: '🫃',
            title: context.l10n.onboarding_howItWorks_stomachTitle,
            description: context.l10n.onboarding_howItWorks_stomachDescription,
            isExpanded: _expandedItems.contains('stomach'),
            onExpansionChanged: (isExpanded) =>
                _onExpansionChanged('stomach', isExpanded),
          ),

          const SizedBox(height: 32),

          // 체크리스트
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4), // Green-50
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0x4D4ADE80), // Green-400 with 30% opacity
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCheckItem(context.l10n.onboarding_howItWorks_check1),
                const SizedBox(height: 12),
                _buildCheckItem(context.l10n.onboarding_howItWorks_check2),
                const SizedBox(height: 12),
                _buildCheckItem(context.l10n.onboarding_howItWorks_check3),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildExpandableCard({
    required BuildContext context,
    required String id,
    required String icon,
    required String title,
    required String description,
    required bool isExpanded,
    required ValueChanged<bool> onExpansionChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded ? AppColors.primary : AppColors.border,
          width: isExpanded ? 2 : 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          // PageStorageKey 제거: Controlled/Uncontrolled 패턴 혼합 방지
          // (BUG-20251129-EXPANSION-TILE-SETSTATE)
          leading: Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          title: Text(
            title,
            style: AppTypography.heading2.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          trailing: Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            color: AppColors.primary,
          ),
          onExpansionChanged: onExpansionChanged,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  description,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyLarge.copyWith(
              color: const Color(0xFF166534), // Green-800
            ),
          ),
        ),
      ],
    );
  }
}
