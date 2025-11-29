import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';

class OnboardingPageTemplate extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget content;
  final Widget? bottomWidget;
  final VoidCallback? onNext;
  final String nextButtonText;
  final bool isNextEnabled;
  final bool showSkip;
  final VoidCallback? onSkip;

  const OnboardingPageTemplate({
    super.key,
    this.title,
    this.subtitle,
    required this.content,
    this.bottomWidget,
    this.onNext,
    this.nextButtonText = '다음',
    this.isNextEnabled = true,
    this.showSkip = false,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32), // xl
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Skip button (우상단)
            if (showSkip)
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onSkip?.call();
                  },
                  child: Text(
                    '건너뛰기',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ),

            // Title
            if (title != null) ...[
              const SizedBox(height: 16),
              Text(
                title!,
                style: AppTypography.display,
              ),
            ],

            // Subtitle
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],

            const SizedBox(height: 24), // lg

            // Content (scrollable)
            Expanded(
              child: SingleChildScrollView(
                child: content,
              ),
            ),

            // Bottom section
            if (bottomWidget != null) ...[
              bottomWidget!,
              const SizedBox(height: 16),
            ],

            // Next button
            if (onNext != null) ...[
              GabiumButton(
                text: nextButtonText,
                onPressed: isNextEnabled
                    ? () {
                        HapticFeedback.lightImpact();
                        onNext!();
                      }
                    : null,
                variant: GabiumButtonVariant.primary,
                size: GabiumButtonSize.medium,
              ),
              const SizedBox(height: 32), // xl (하단 여백)
            ],
          ],
        ),
      ),
    );
  }
}
