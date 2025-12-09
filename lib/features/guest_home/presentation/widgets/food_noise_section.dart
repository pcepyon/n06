import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/guest_home/data/guest_home_content.dart';
import 'package:n06/features/guest_home/presentation/widgets/demo/demo_bottom_sheet.dart';
import 'package:n06/features/guest_home/presentation/widgets/demo/food_noise_demo.dart';

/// Food Noise 섹션 위젯
/// P0 인터랙션: Sequential Text Reveal + Quote Cards with Fade-in
class FoodNoiseSection extends StatefulWidget {
  const FoodNoiseSection({super.key});

  @override
  State<FoodNoiseSection> createState() => _FoodNoiseSectionState();
}

class _FoodNoiseSectionState extends State<FoodNoiseSection>
    with TickerProviderStateMixin {
  late final AnimationController _headerController;
  late final AnimationController _quotesController;
  late final AnimationController _explanationController;
  late final AnimationController _predictionController;
  late final AnimationController _footerController;

  late final Animation<double> _headerOpacity;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _quotesOpacity;
  late final Animation<double> _explanationOpacity;
  late final Animation<Offset> _explanationSlide;
  late final Animation<double> _predictionOpacity;
  late final Animation<Offset> _predictionSlide;
  late final Animation<double> _footerOpacity;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startSequentialAnimation();
  }

  void _initAnimations() {
    // Header animation
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _headerOpacity = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    ));

    // Quotes animation
    _quotesController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _quotesOpacity = CurvedAnimation(
      parent: _quotesController,
      curve: Curves.easeOut,
    );

    // Explanation animation
    _explanationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _explanationOpacity = CurvedAnimation(
      parent: _explanationController,
      curve: Curves.easeOut,
    );
    _explanationSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _explanationController,
      curve: Curves.easeOutCubic,
    ));

    // Prediction animation
    _predictionController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _predictionOpacity = CurvedAnimation(
      parent: _predictionController,
      curve: Curves.easeOut,
    );
    _predictionSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _predictionController,
      curve: Curves.easeOutCubic,
    ));

    // Footer animation
    _footerController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _footerOpacity = CurvedAnimation(
      parent: _footerController,
      curve: Curves.easeOut,
    );
  }

  Future<void> _startSequentialAnimation() async {
    // Sequential reveal
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _headerController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _quotesController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _explanationController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _predictionController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _footerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _quotesController.dispose();
    _explanationController.dispose();
    _predictionController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          SlideTransition(
            position: _headerSlide,
            child: FadeTransition(
              opacity: _headerOpacity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    GuestHomeContent.foodNoiseSectionTitle,
                    style: AppTypography.heading1.copyWith(
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    GuestHomeContent.foodNoiseSubtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Quote 카드들
          FadeTransition(
            opacity: _quotesOpacity,
            child: Column(
              children: GuestHomeContent.foodNoiseQuotes
                  .asMap()
                  .entries
                  .map((entry) => _QuoteCard(
                        quote: entry.value,
                        delay: entry.key * 100,
                        controller: _quotesController,
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),
          // 설명
          SlideTransition(
            position: _explanationSlide,
            child: FadeTransition(
              opacity: _explanationOpacity,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      GuestHomeContent.foodNoiseExplanation,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // 예측 메시지
          SlideTransition(
            position: _predictionSlide,
            child: FadeTransition(
              opacity: _predictionOpacity,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.successBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      GuestHomeContent.foodNoisePrediction,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 푸터
          FadeTransition(
            opacity: _footerOpacity,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.infoBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                GuestHomeContent.foodNoiseFooter,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 체험하기 버튼
          FadeTransition(
            opacity: _footerOpacity,
            child: Center(
              child: OutlinedButton.icon(
                onPressed: () => showDemoBottomSheet(
                  context: context,
                  title: 'Food Noise 체험',
                  child: FoodNoiseDemo(
                    onComplete: () {},
                  ),
                  onCtaTap: () {
                    Navigator.pop(context);
                    context.go('/login');
                  },
                ),
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text('체험하기'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Quote 카드 위젯
class _QuoteCard extends StatelessWidget {
  final String quote;
  final int delay;
  final AnimationController controller;

  const _QuoteCard({
    required this.quote,
    required this.delay,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"',
            style: AppTypography.heading2.copyWith(
              color: AppColors.neutral300,
              height: 1,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              quote,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
