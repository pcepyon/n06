import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/features/onboarding/presentation/widgets/common/onboarding_page_template.dart';

class SideEffectsScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback? onSkip;

  const SideEffectsScreen({
    super.key,
    required this.onNext,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingPageTemplate(
      title: context.l10n.onboarding_sideEffects_title,
      subtitle: context.l10n.onboarding_sideEffects_subtitle,
      showSkip: true,
      onSkip: onSkip,
      onNext: onNext,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 증상 1: 속 불편함
          _buildSymptomCard(
            context: context,
            icon: '😮‍💨',
            title: context.l10n.onboarding_sideEffects_symptom1Title,
            tips: [
              context.l10n.onboarding_sideEffects_symptom1Tip1,
              context.l10n.onboarding_sideEffects_symptom1Tip2,
              context.l10n.onboarding_sideEffects_symptom1Tip3,
            ],
            badge: context.l10n.onboarding_sideEffects_symptom1Badge,
            badgeColor: const Color(0xFF4ADE80), // Primary
          ),

          const SizedBox(height: 16),

          // 증상 2: 입맛 변화
          _buildSymptomCard(
            context: context,
            icon: '🍽️',
            title: context.l10n.onboarding_sideEffects_symptom2Title,
            tips: [
              context.l10n.onboarding_sideEffects_symptom2Tip1,
              context.l10n.onboarding_sideEffects_symptom2Tip2,
            ],
            badge: null,
            badgeColor: null,
          ),

          const SizedBox(height: 16),

          // 증상 3: 피로감
          _buildSymptomCard(
            context: context,
            icon: '😴',
            title: context.l10n.onboarding_sideEffects_symptom3Title,
            tips: [
              context.l10n.onboarding_sideEffects_symptom3Tip1,
              context.l10n.onboarding_sideEffects_symptom3Tip2,
              context.l10n.onboarding_sideEffects_symptom3Tip3,
            ],
            badge: null,
            badgeColor: null,
          ),

          const SizedBox(height: 24),

          // 경고 카드
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB), // Warning Yellow-50
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0x4DD97706), // Yellow-600 with 30% opacity
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 20,
                      color: Color(0xFFD97706), // Warning Yellow-600
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.l10n.onboarding_sideEffects_warning,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD97706), // Warning Yellow-600
                          height: 1.43,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 의료적 면책 조항
          Text(
            context.l10n.onboarding_sideEffects_disclaimer,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF94A3B8), // Neutral-400
              height: 1.33,
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSymptomCard({
    required BuildContext context,
    required String icon,
    required String title,
    required List<String> tips,
    String? badge,
    Color? badgeColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.educationBackground, // Blue-50 for education
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.education.withValues(alpha: 0.2),
        ),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          leading: Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
              if (badge != null && badgeColor != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: badgeColor,
                    ),
                  ),
                ),
            ],
          ),
          trailing: Icon(
            Icons.expand_more,
            color: AppColors.education,
          ),
          onExpansionChanged: (isExpanded) {
            if (isExpanded) {
              HapticFeedback.lightImpact();
            }
          },
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: tips.map((tip) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '•',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.education,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tip,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
