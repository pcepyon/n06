import 'package:flutter/material.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/onboarding/presentation/widgets/common/onboarding_page_template.dart';

class JourneyRoadmapScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback? onSkip;

  const JourneyRoadmapScreen({
    super.key,
    required this.onNext,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingPageTemplate(
      title: context.l10n.onboarding_journeyRoadmap_title,
      subtitle: context.l10n.onboarding_journeyRoadmap_subtitle,
      showSkip: true,
      onSkip: onSkip,
      onNext: onNext,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Phase 1
          _buildTimelineItem(
            context: context,
            icon: '🌱',
            phase: context.l10n.onboarding_journeyRoadmap_phase1Title,
            description: context.l10n.onboarding_journeyRoadmap_phase1Description,
            color: AppColors.history.withValues(alpha: 0.7), // Purple lighter
            isLast: false,
          ),

          const SizedBox(height: 24),

          // Timeline Phase 2
          _buildTimelineItem(
            context: context,
            icon: '🌿',
            phase: context.l10n.onboarding_journeyRoadmap_phase2Title,
            description: context.l10n.onboarding_journeyRoadmap_phase2Description,
            color: AppColors.history, // Purple
            isLast: false,
          ),

          const SizedBox(height: 24),

          // Timeline Phase 3
          _buildTimelineItem(
            context: context,
            icon: '🌳',
            phase: context.l10n.onboarding_journeyRoadmap_phase3Title,
            description: context.l10n.onboarding_journeyRoadmap_phase3Description,
            color: const Color(0xFF6B21A8), // Purple-800 (darker)
            isLast: true,
          ),

          const SizedBox(height: 32),

          // 팁 카드
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.historyBackground, // Purple-50
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.history.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💡',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.history,
                            height: 1.43,
                          ),
                          children: [
                            TextSpan(
                              text: '${context.l10n.onboarding_journeyRoadmap_tip1}\n',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: context.l10n.onboarding_journeyRoadmap_tip1Part2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(
                  color: AppColors.history.withValues(alpha: 0.5),
                  height: 1,
                  thickness: 0.5,
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💡',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.history,
                            height: 1.43,
                          ),
                          children: [
                            TextSpan(
                              text: '${context.l10n.onboarding_journeyRoadmap_tip2}\n',
                            ),
                            TextSpan(
                              text: context.l10n.onboarding_journeyRoadmap_tip2Part2,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required BuildContext context,
    required String icon,
    required String phase,
    required String description,
    required Color color,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: color,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color,
                      color.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(width: 16),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                phase,
                style: AppTypography.heading2.copyWith(
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
