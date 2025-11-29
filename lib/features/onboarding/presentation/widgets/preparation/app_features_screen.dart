import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
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
      title: '이렇게 함께할 거예요',
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
              children: const [
                _FeatureCard(
                  emoji: '📅',
                  title: '투여 알림',
                  description: '잊지 않도록 챙겨드려요',
                  color: Color(0xFFEFF6FF), // Blue-50
                  iconColor: Color(0xFF3B82F6), // Blue-500
                ),
                _FeatureCard(
                  emoji: '📊',
                  title: '변화 기록',
                  description: '체중, 증상을 한눈에',
                  color: Color(0xFFF0FDF4), // Green-50
                  iconColor: Color(0xFF22C55E), // Green-500
                ),
                _FeatureCard(
                  emoji: '🆘',
                  title: '부작용 가이드',
                  description: '불편할 땐 바로 확인',
                  color: Color(0xFFFEF3C7), // Yellow-50
                  iconColor: Color(0xFFF59E0B), // Yellow-500
                ),
                _FeatureCard(
                  emoji: '📋',
                  title: '의료진 공유',
                  description: '진료 시 보여드리기 편해요',
                  color: Color(0xFFFCE7F3), // Pink-50
                  iconColor: Color(0xFFEC4899), // Pink-500
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
              effect: const WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: Color(0xFF4ADE80), // Primary
                dotColor: Color(0xFFE2E8F0), // Neutral-200
                spacing: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Swipe instruction
          const Text(
            '스와이프해서 더 보기 →',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF94A3B8), // Neutral-400
              height: 1.43,
            ),
          ),
        ],
      ),
      onNext: widget.onNext,
      nextButtonText: '다음',
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
