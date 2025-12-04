import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/onboarding/presentation/widgets/common/onboarding_page_template.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback? onSkip;

  const WelcomeScreen({
    super.key,
    required this.onNext,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingPageTemplate(
      title: context.l10n.onboarding_welcome_title,
      content: _buildContent(context),
      onNext: onNext,
      nextButtonText: context.l10n.onboarding_common_nextButton,
      isNextEnabled: true,
      showSkip: true,
      onSkip: onSkip,
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        // Lottie animation with fallback
        _buildLottieWithFallback(
          'assets/animations/welcome.json',
          height: 240,
        ),
        const SizedBox(height: 32), // xl

        // Main message with FadeIn animation
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Text(
            context.l10n.onboarding_welcome_message,
            style: AppTypography.bodyLarge.copyWith(
              color: const Color(0xFF334155), // Neutral-700
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24), // lg

        // Quote card
        _buildQuoteCard(
          context.l10n.onboarding_welcome_quote,
        ),
      ],
    );
  }

  Widget _buildLottieWithFallback(String assetPath, {double? height}) {
    final effectiveHeight = height ?? 200.0;

    return FutureBuilder(
      future: Future.delayed(Duration.zero, () async {
        try {
          await rootBundle.load(assetPath);
          return true;
        } catch (e) {
          return false;
        }
      }),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return Lottie.asset(assetPath, height: effectiveHeight);
        }
        // Placeholder
        return Container(
          height: effectiveHeight,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(
              Icons.animation,
              size: 48,
              color: AppColors.textDisabled,
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuoteCard(String text) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.welcomeBackground, // Orange-50
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warmWelcome.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        text,
        style: AppTypography.bodyLarge.copyWith(
          fontStyle: FontStyle.italic,
          color: AppColors.warmWelcome,
          height: 1.6,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
