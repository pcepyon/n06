import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:n06/features/onboarding/presentation/widgets/common/onboarding_page_template.dart';

class NotYourFaultScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback? onSkip;

  const NotYourFaultScreen({
    super.key,
    required this.onNext,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingPageTemplate(
      title: '의지력의 문제가 아니었어요',
      content: _buildContent(),
      onNext: onNext,
      nextButtonText: '다음',
      isNextEnabled: true,
      showSkip: true,
      onSkip: onSkip,
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Lottie animation (뇌와 호르몬 균형)
        _buildLottieWithFallback(
          'assets/animations/brain_hormone.json',
          height: 200,
        ),
        const SizedBox(height: 32), // xl

        // Sequential text animations
        _buildSequentialText(
          '체중 관리가 어려웠던 건\n당신의 의지가 약해서가 아니에요',
          delay: 0,
        ),
        const SizedBox(height: 24), // lg

        _buildSequentialText(
          '우리 몸에는 식욕을 조절하는\n호르몬 시스템이 있어요\n\n'
          '이 시스템의 균형이 깨지면\n아무리 노력해도 힘들 수밖에 없죠',
          delay: 400,
        ),
        const SizedBox(height: 24), // lg

        // Info card with delayed animation
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: _buildInfoCard(
            'GLP-1은 이 균형을\n다시 맞춰주는 역할을 해요',
          ),
        ),
      ],
    );
  }

  Widget _buildSequentialText(String text, {required int delay}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        // Start animation after delay
        final adjustedValue = delay > 0
            ? (value * (600 + delay) - delay).clamp(0.0, 600.0) / 600
            : value;

        return Opacity(
          opacity: adjustedValue,
          child: Transform.translate(
            offset: Offset(0, 15 * (1 - adjustedValue)),
            child: child,
          ),
        );
      },
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16, // base
          fontWeight: FontWeight.w400, // Regular
          color: Color(0xFF334155), // Neutral-700
          height: 1.5, // 24/16
        ),
        textAlign: TextAlign.center,
      ),
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
            color: const Color(0xFFF1F5F9), // Neutral-100
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(
              Icons.animation,
              size: 48,
              color: Color(0xFF94A3B8), // Neutral-400
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), // Blue-50
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💡',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1E40AF), // Blue-800
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
