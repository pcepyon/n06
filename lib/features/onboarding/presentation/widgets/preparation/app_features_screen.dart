import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/onboarding/presentation/widgets/common/onboarding_page_template.dart';

class AppFeaturesScreen extends StatefulWidget {
  final VoidCallback onNext;

  const AppFeaturesScreen({super.key, required this.onNext});

  @override
  State<AppFeaturesScreen> createState() => _AppFeaturesScreenState();
}

class _AppFeaturesScreenState extends State<AppFeaturesScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingPageTemplate(
      title: context.l10n.onboarding_appFeatures_title,
      subtitle: null,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // PageView carousel
          SizedBox(
            height: 420,
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                HapticFeedback.lightImpact();
              },
              children: [
                _FeatureCard(
                  emoji: '📅',
                  title: context.l10n.onboarding_appFeatures_feature1Title,
                  description: context.l10n.onboarding_appFeatures_feature1Description,
                  color: AppColors.educationBackground, // Blue-50
                  iconColor: AppColors.education, // Blue-500
                ),
                _FeatureCard(
                  emoji: '📊',
                  title: context.l10n.onboarding_appFeatures_feature2Title,
                  description: context.l10n.onboarding_appFeatures_feature2Description,
                  color: AppColors.historyBackground, // Purple-50
                  iconColor: AppColors.history, // Purple-500
                ),
                _FeatureCard(
                  emoji: '🆘',
                  title: context.l10n.onboarding_appFeatures_feature3Title,
                  description: context.l10n.onboarding_appFeatures_feature3Description,
                  color: AppColors.educationBackground, // Blue-50
                  iconColor: AppColors.education, // Blue-500
                ),
                _FeatureCard(
                  emoji: '📋',
                  title: context.l10n.onboarding_appFeatures_feature4Title,
                  description: context.l10n.onboarding_appFeatures_feature4Description,
                  color: AppColors.educationBackground, // Blue-50
                  iconColor: AppColors.education, // Blue-500
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Page indicator
          Center(
            child: SmoothPageIndicator(
              controller: _pageController,
              count: 4,
              effect: WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: AppColors.primary,
                dotColor: AppColors.border,
                spacing: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Swipe instruction
          Text(
            context.l10n.onboarding_appFeatures_swipeInstruction,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
      onNext: widget.onNext,
      nextButtonText: context.l10n.onboarding_common_nextButton,
      isNextEnabled: true,
      showSkip: false,
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final Color color;
  final Color iconColor;

  const _FeatureCard({
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color.lerp(iconColor, Colors.white, 0.8)!,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xB3FFFFFF),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 56),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: iconColor,
              height: 1.33,
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF334155), // Neutral-700
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
