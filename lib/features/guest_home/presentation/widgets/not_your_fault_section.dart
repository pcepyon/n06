import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/guest_home/data/guest_home_content.dart';

/// 당신 탓 아니에요 섹션 위젯
/// P0 인터랙션: Sequential Text Reveal (순차적 텍스트 공개)
class NotYourFaultSection extends StatefulWidget {
  const NotYourFaultSection({super.key});

  @override
  State<NotYourFaultSection> createState() => _NotYourFaultSectionState();
}

class _NotYourFaultSectionState extends State<NotYourFaultSection>
    with TickerProviderStateMixin {
  late final AnimationController _titleController;
  late final AnimationController _message1Controller;
  late final AnimationController _message2Controller;
  late final AnimationController _message3Controller;
  late final AnimationController _footerController;

  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _message1Opacity;
  late final Animation<Offset> _message1Slide;
  late final Animation<double> _message2Opacity;
  late final Animation<Offset> _message2Slide;
  late final Animation<double> _message3Opacity;
  late final Animation<Offset> _message3Slide;
  late final Animation<double> _footerOpacity;
  late final Animation<Offset> _footerSlide;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startSequentialAnimation();
  }

  void _initAnimations() {
    // Title animation
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _titleOpacity = CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeOut,
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeOutCubic,
    ));

    // Message 1 animation
    _message1Controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _message1Opacity = CurvedAnimation(
      parent: _message1Controller,
      curve: Curves.easeOut,
    );
    _message1Slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _message1Controller,
      curve: Curves.easeOutCubic,
    ));

    // Message 2 animation
    _message2Controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _message2Opacity = CurvedAnimation(
      parent: _message2Controller,
      curve: Curves.easeOut,
    );
    _message2Slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _message2Controller,
      curve: Curves.easeOutCubic,
    ));

    // Message 3 animation
    _message3Controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _message3Opacity = CurvedAnimation(
      parent: _message3Controller,
      curve: Curves.easeOut,
    );
    _message3Slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _message3Controller,
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
    _footerSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _footerController,
      curve: Curves.easeOutCubic,
    ));
  }

  Future<void> _startSequentialAnimation() async {
    // Sequential reveal with 300ms delay between each
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _titleController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _message1Controller.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _message2Controller.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _message3Controller.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _footerController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _message1Controller.dispose();
    _message2Controller.dispose();
    _message3Controller.dispose();
    _footerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.infoBackground,
            AppColors.surface,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 제목
          SlideTransition(
            position: _titleSlide,
            child: FadeTransition(
              opacity: _titleOpacity,
              child: Text(
                GuestHomeContent.notYourFaultSectionTitle,
                style: AppTypography.heading1.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 구분선
          SlideTransition(
            position: _message1Slide,
            child: FadeTransition(
              opacity: _message1Opacity,
              child: Container(
                width: 40,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.info,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 메시지 1
          SlideTransition(
            position: _message1Slide,
            child: FadeTransition(
              opacity: _message1Opacity,
              child: Text(
                GuestHomeContent.notYourFaultMessage1,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 메시지 2
          SlideTransition(
            position: _message2Slide,
            child: FadeTransition(
              opacity: _message2Opacity,
              child: Text(
                GuestHomeContent.notYourFaultMessage2,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 메시지 3 (강조)
          SlideTransition(
            position: _message3Slide,
            child: FadeTransition(
              opacity: _message3Opacity,
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
                child: Text(
                  GuestHomeContent.notYourFaultMessage3,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.w500,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 푸터 메시지
          SlideTransition(
            position: _footerSlide,
            child: FadeTransition(
              opacity: _footerOpacity,
              child: Text(
                GuestHomeContent.notYourFaultFooter,
                style: AppTypography.heading3.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
