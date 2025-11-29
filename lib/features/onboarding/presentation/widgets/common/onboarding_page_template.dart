import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                  child: const Text(
                    '건너뛰기',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B), // Neutral-500
                    ),
                  ),
                ),
              ),

            // Title
            if (title != null) ...[
              const SizedBox(height: 16),
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 28, // 3xl
                  fontWeight: FontWeight.w700, // Bold
                  color: Color(0xFF1E293B), // Neutral-800
                  height: 1.29, // 36/28
                ),
              ),
            ],

            // Subtitle
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 16, // base
                  fontWeight: FontWeight.w400, // Regular
                  color: Color(0xFF64748B), // Neutral-500
                  height: 1.5,
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
