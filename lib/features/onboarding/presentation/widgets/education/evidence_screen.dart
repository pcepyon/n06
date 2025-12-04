import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/onboarding/presentation/widgets/common/onboarding_page_template.dart';

class EvidenceScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onSkip;

  const EvidenceScreen({
    super.key,
    required this.onNext,
    this.onSkip,
  });

  @override
  State<EvidenceScreen> createState() => _EvidenceScreenState();
}

class _EvidenceScreenState extends State<EvidenceScreen> {
  bool _showCounter = false;

  @override
  void initState() {
    super.initState();
    // Start counter animation after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showCounter = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingPageTemplate(
      title: context.l10n.onboarding_evidence_title,
      subtitle: context.l10n.onboarding_evidence_subtitle,
      content: _buildContent(context),
      onNext: widget.onNext,
      nextButtonText: context.l10n.onboarding_common_nextButton,
      isNextEnabled: true,
      showSkip: true,
      onSkip: widget.onSkip,
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        // Main data card with animated counter
        _buildMainDataCard(context),
        const SizedBox(height: 24), // lg

        // Benefits grid
        _buildBenefitsSection(context),
        const SizedBox(height: 24), // lg

        // Closing message
        _buildClosingMessage(context),
      ],
    );
  }

  Widget _buildMainDataCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          // Animated counter
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedFlipCounter(
                value: _showCounter ? 21 : 0,
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutCubic,
                textStyle: AppTypography.numericLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
              Text(
                '%',
                style: AppTypography.numericLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.onboarding_evidence_weightLossAverage,
            style: AppTypography.heading3.copyWith(
              color: const Color(0xFF334155), // Neutral-700
            ),
          ),
          const SizedBox(height: 16),

          // Source link
          InkWell(
            onTap: () async {
              HapticFeedback.lightImpact();
              final uri = Uri.parse(
                'https://www.nejm.org/doi/full/10.1056/NEJMoa2206038',
              );
              if (await canLaunchUrl(uri)) {
                await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.onboarding_evidence_source,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.open_in_new,
                    size: 14,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.onboarding_evidence_tapToConfirm,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF94A3B8), // Neutral-400
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC), // Neutral-50
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.onboarding_evidence_additionalBenefits,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155), // Neutral-700
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBenefitChip(context.l10n.onboarding_evidence_benefit1),
              _buildBenefitChip(context.l10n.onboarding_evidence_benefit2),
              _buildBenefitChip(context.l10n.onboarding_evidence_benefit3),
              _buildBenefitChip(context.l10n.onboarding_evidence_benefit4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Neutral-100
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0), // Neutral-200
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF334155), // Neutral-700
        ),
      ),
    );
  }

  Widget _buildClosingMessage(BuildContext context) {
    return TweenAnimationBuilder<double>(
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
        context.l10n.onboarding_evidence_closingMessage,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF334155), // Neutral-700
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
