import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
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
      title: '주사, 생각보다 간단해요',
      subtitle: '처음엔 누구나 긴장돼요\n하지만 한 번 해보면 "이게 끝?" 할 거예요',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Lottie animation placeholder
          _buildLottieWithFallback('assets/lottie/injection.json', height: 180),
          const SizedBox(height: 24),

          // Instruction text
          const Text(
            '부위를 탭해서 자세히 알아보기',
            textAlign: TextAlign.center,
            style: TextStyle(
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
            label: '복부',
            description: '배꼽 주변 5cm 이상 떨어진 곳',
            onTap: () => _showSiteGuide(context, InjectionSite.abdomen),
          ),
          const SizedBox(height: 12),
          _InjectionSiteButton(
            icon: Icons.accessibility_new,
            label: '허벅지',
            description: '허벅지 앞쪽 또는 바깥쪽',
            onTap: () => _showSiteGuide(context, InjectionSite.thigh),
          ),
          const SizedBox(height: 12),
          _InjectionSiteButton(
            icon: Icons.back_hand,
            label: '팔',
            description: '윗팔 뒤쪽',
            onTap: () => _showSiteGuide(context, InjectionSite.arm),
          ),
          const SizedBox(height: 32),

          // Reassurance checklist
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF), // Blue-50
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x333B82F6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CheckItem('바늘이 머리카락보다 가늘어요'),
                const SizedBox(height: 8),
                _CheckItem('대부분 거의 못 느껴요'),
                const SizedBox(height: 8),
                _CheckItem('버튼 누르면 10초 안에 끝'),
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
                    const Text(
                      '꿀팁',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF166534), // Green-800
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _TipItem('매주 부위를 돌아가며'),
                const SizedBox(height: 6),
                _TipItem('주사 전 심호흡 한 번'),
                const SizedBox(height: 6),
                _TipItem('펜의 바늘 가림막으로 안심'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Medical disclaimer
          const Text(
            '*담당 의사의 주사 지도를 최우선으로 따라주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
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
      nextButtonText: '다음',
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
        const Icon(
          Icons.check_circle,
          color: Color(0xFF3B82F6), // Blue-500
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF1E40AF), // Blue-800
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

  String get _title {
    switch (site) {
      case InjectionSite.abdomen:
        return '복부 주사 가이드';
      case InjectionSite.thigh:
        return '허벅지 주사 가이드';
      case InjectionSite.arm:
        return '팔 주사 가이드';
    }
  }

  String get _detailedDescription {
    switch (site) {
      case InjectionSite.abdomen:
        return '배꼽 주변 5cm 이상 떨어진 곳\n가장 일반적인 부위예요';
      case InjectionSite.thigh:
        return '허벅지 앞쪽 또는 바깥쪽\n앉아서 편하게 주사할 수 있어요';
      case InjectionSite.arm:
        return '윗팔 뒤쪽\n다른 사람 도움이 필요할 수 있어요';
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
            _title,
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
            _detailedDescription,
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
            child: const Text(
              '확인',
              style: TextStyle(
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
