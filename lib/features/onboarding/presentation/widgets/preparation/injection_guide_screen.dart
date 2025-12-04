import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/features/onboarding/presentation/widgets/common/onboarding_page_template.dart';

enum InjectionSite { abdomen, thigh, arm }

class InjectionGuideScreen extends StatelessWidget {
  final VoidCallback onNext;

  const InjectionGuideScreen({super.key, required this.onNext});

  void _showSiteGuide(BuildContext context, InjectionSite site) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _SiteGuideSheet(site: site),
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
        return Container(
          height: effectiveHeight,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(Icons.animation, size: 48, color: Color(0xFF94A3B8)),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingPageTemplate(
      title: context.l10n.onboarding_injection_title,
      subtitle: context.l10n.onboarding_injection_subtitle,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Lottie animation placeholder
          _buildLottieWithFallback('assets/lottie/injection.json', height: 180),
          const SizedBox(height: 24),

          // Instruction text
          Text(
            context.l10n.onboarding_injection_tapInstruction,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF64748B),
              height: 1.43,
            ),
          ),
          const SizedBox(height: 16),

          // Injection site buttons
          _InjectionSiteButton(
            icon: Icons.account_box,
            label: context.l10n.onboarding_injection_abdomenLabel,
            description: context.l10n.onboarding_injection_abdomenDescription,
            onTap: () => _showSiteGuide(context, InjectionSite.abdomen),
          ),
          const SizedBox(height: 12),
          _InjectionSiteButton(
            icon: Icons.accessibility_new,
            label: context.l10n.onboarding_injection_thighLabel,
            description: context.l10n.onboarding_injection_thighDescription,
            onTap: () => _showSiteGuide(context, InjectionSite.thigh),
          ),
          const SizedBox(height: 12),
          _InjectionSiteButton(
            icon: Icons.back_hand,
            label: context.l10n.onboarding_injection_armLabel,
            description: context.l10n.onboarding_injection_armDescription,
            onTap: () => _showSiteGuide(context, InjectionSite.arm),
          ),
          const SizedBox(height: 32),

          // Reassurance checklist
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.educationBackground, // Blue-50
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.education.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CheckItem(context.l10n.onboarding_injection_check1),
                const SizedBox(height: 8),
                _CheckItem(context.l10n.onboarding_injection_check2),
                const SizedBox(height: 8),
                _CheckItem(context.l10n.onboarding_injection_check3),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Tips section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4), // Green-50
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '💡',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.onboarding_injection_tipsTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF166534), // Green-800
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _TipItem(context.l10n.onboarding_injection_tip1),
                const SizedBox(height: 6),
                _TipItem(context.l10n.onboarding_injection_tip2),
                const SizedBox(height: 6),
                _TipItem(context.l10n.onboarding_injection_tip3),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Medical disclaimer
          Text(
            context.l10n.onboarding_injection_disclaimer,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF64748B),
              height: 1.33,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      onNext: onNext,
      nextButtonText: context.l10n.onboarding_common_nextButton,
      isNextEnabled: true,
      showSkip: false,
    );
  }
}

class _InjectionSiteButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  const _InjectionSiteButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF1F5F9), // Neutral-100
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0x1A4ADE80),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF22C55E),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF64748B),
                        height: 1.43,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String text;

  const _CheckItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle,
          color: AppColors.education,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.education,
              height: 1.43,
            ),
          ),
        ),
      ],
    );
  }
}

class _TipItem extends StatelessWidget {
  final String text;

  const _TipItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF166534),
            height: 1.43,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF166534),
              height: 1.43,
            ),
          ),
        ),
      ],
    );
  }
}

class _SiteGuideSheet extends StatelessWidget {
  final InjectionSite site;

  const _SiteGuideSheet({required this.site});

  String _title(BuildContext context) {
    switch (site) {
      case InjectionSite.abdomen:
        return context.l10n.onboarding_injection_abdomenGuideTitle;
      case InjectionSite.thigh:
        return context.l10n.onboarding_injection_thighGuideTitle;
      case InjectionSite.arm:
        return context.l10n.onboarding_injection_armGuideTitle;
    }
  }

  String _detailedDescription(BuildContext context) {
    switch (site) {
      case InjectionSite.abdomen:
        return context.l10n.onboarding_injection_abdomenGuideDetail;
      case InjectionSite.thigh:
        return context.l10n.onboarding_injection_thighGuideDetail;
      case InjectionSite.arm:
        return context.l10n.onboarding_injection_armGuideDetail;
    }
  }

  IconData get _icon {
    switch (site) {
      case InjectionSite.abdomen:
        return Icons.account_box;
      case InjectionSite.thigh:
        return Icons.accessibility_new;
      case InjectionSite.arm:
        return Icons.back_hand;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Icon
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0x1A4ADE80),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _icon,
                color: const Color(0xFF22C55E),
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            _title(context),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            _detailedDescription(context),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Close button
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ADE80),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              context.l10n.onboarding_summary_confirmButton,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
