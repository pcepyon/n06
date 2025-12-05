import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/guest_home/data/guest_home_content.dart';
import 'package:n06/features/guest_home/presentation/widgets/evidence_card.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// 과학적 근거 섹션 위젯
/// P0 인터랙션: Card Stack Effect 캐러셀, 자동 슬라이드
class ScientificEvidenceSection extends StatefulWidget {
  const ScientificEvidenceSection({super.key});

  @override
  State<ScientificEvidenceSection> createState() =>
      _ScientificEvidenceSectionState();
}

class _ScientificEvidenceSectionState extends State<ScientificEvidenceSection> {
  late final PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentPage = 0;
  bool _userInteracting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_userInteracting && mounted) {
        final nextPage =
            (_currentPage + 1) % GuestHomeContent.evidenceCards.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onUserInteractionStart() {
    _userInteracting = true;
    _autoSlideTimer?.cancel();
  }

  void _onUserInteractionEnd() {
    _userInteracting = false;
    // 3초 후 자동 슬라이드 재개
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_userInteracting) {
        _startAutoSlide();
      }
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                GuestHomeContent.evidenceSectionTitle,
                style: AppTypography.heading1.copyWith(
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                GuestHomeContent.evidenceSectionSubtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // 카드 캐러셀
        SizedBox(
          height: 480,
          child: GestureDetector(
            onPanDown: (_) => _onUserInteractionStart(),
            onPanEnd: (_) => _onUserInteractionEnd(),
            onPanCancel: () => _onUserInteractionEnd(),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
                HapticFeedback.lightImpact();
              },
              itemCount: GuestHomeContent.evidenceCards.length,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double scale = 1.0;
                    double opacity = 1.0;

                    if (_pageController.position.haveDimensions) {
                      final page = _pageController.page ?? 0;
                      final diff = (index - page).abs();
                      scale = 1.0 - (diff * 0.05).clamp(0.0, 0.1);
                      opacity = 1.0 - (diff * 0.3).clamp(0.0, 0.5);
                    }

                    return Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: opacity,
                        child: EvidenceCard(
                          data: GuestHomeContent.evidenceCards[index],
                          isVisible: _currentPage == index,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 페이지 인디케이터
        Center(
          child: SmoothPageIndicator(
            controller: _pageController,
            count: GuestHomeContent.evidenceCards.length,
            effect: ExpandingDotsEffect(
              dotHeight: 8,
              dotWidth: 8,
              activeDotColor: AppColors.primary,
              dotColor: AppColors.neutral300,
              spacing: 6,
              expansionFactor: 2,
            ),
          ),
        ),
        const SizedBox(height: 32),
        // 푸터 메시지
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.infoBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  GuestHomeContent.evidenceFooterMessage,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.w500,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  GuestHomeContent.evidenceFooterSubtext,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
