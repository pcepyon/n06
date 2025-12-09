import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/guest_home/data/guest_home_content.dart';

/// 작동 원리 섹션 위젯
/// P0 인터랙션: Sequential Card Entry with Icon Animation
class HowItWorksSection extends StatefulWidget {
  const HowItWorksSection({super.key});

  @override
  State<HowItWorksSection> createState() => _HowItWorksSectionState();
}

class _HowItWorksSectionState extends State<HowItWorksSection>
    with TickerProviderStateMixin {
  late final AnimationController _headerController;
  late final AnimationController _mechanismsController;
  late final AnimationController _checksController;
  late final AnimationController _footerController;

  late final Animation<double> _headerOpacity;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _mechanismsOpacity;
  late final Animation<double> _checksOpacity;
  late final Animation<Offset> _checksSlide;
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

    // Mechanisms animation
    _mechanismsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _mechanismsOpacity = CurvedAnimation(
      parent: _mechanismsController,
      curve: Curves.easeOut,
    );

    // Checks animation
    _checksController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _checksOpacity = CurvedAnimation(
      parent: _checksController,
      curve: Curves.easeOut,
    );
    _checksSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _checksController,
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
    _mechanismsController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _checksController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _footerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _mechanismsController.dispose();
    _checksController.dispose();
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
                    GuestHomeContent.howItWorksSectionTitle,
                    style: AppTypography.heading1.copyWith(
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    GuestHomeContent.howItWorksSubtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          // 메커니즘 카드들
          FadeTransition(
            opacity: _mechanismsOpacity,
            child: Column(
              children: GuestHomeContent.howItWorksMechanisms
                  .asMap()
                  .entries
                  .map((entry) => _MechanismCard(
                        mechanism: entry.value,
                        delay: entry.key * 150,
                        controller: _mechanismsController,
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 32),
          // 체크 아이템들
          SlideTransition(
            position: _checksSlide,
            child: FadeTransition(
              opacity: _checksOpacity,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...GuestHomeContent.howItWorksChecks.map(
                      (check) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                check,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
            child: Text(
              GuestHomeContent.howItWorksFooter,
              style: AppTypography.heading3.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 메커니즘 카드 위젯
class _MechanismCard extends StatefulWidget {
  final Map<String, String> mechanism;
  final int delay;
  final AnimationController controller;

  const _MechanismCard({
    required this.mechanism,
    required this.delay,
    required this.controller,
  });

  @override
  State<_MechanismCard> createState() => _MechanismCardState();
}

class _MechanismCardState extends State<_MechanismCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _iconController;
  late final Animation<double> _iconScale;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _iconScale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.easeOutBack,
    ));

    // 카드가 보일 때 아이콘 애니메이션 시작
    widget.controller.addListener(() {
      if (widget.controller.value > 0.3 && !_iconController.isAnimating) {
        Future.delayed(Duration(milliseconds: widget.delay), () {
          if (mounted) {
            _iconController.forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아이콘
          ScaleTransition(
            scale: _iconScale,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.mechanism['icon'] ?? '',
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 텍스트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.mechanism['title'] ?? '',
                  style: AppTypography.heading3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.mechanism['description'] ?? '',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
