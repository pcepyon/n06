import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/guest_home/data/guest_home_content.dart';

/// 환영 섹션 위젯
/// P0 인터랙션: Sequential Text Reveal (순차적 텍스트 공개)
class WelcomeSection extends StatefulWidget {
  const WelcomeSection({super.key});

  @override
  State<WelcomeSection> createState() => _WelcomeSectionState();
}

class _WelcomeSectionState extends State<WelcomeSection>
    with TickerProviderStateMixin {
  late final AnimationController _greetingController;
  late final AnimationController _message1Controller;
  late final AnimationController _message2Controller;
  late final AnimationController _message3Controller;

  late final Animation<double> _greetingOpacity;
  late final Animation<Offset> _greetingSlide;
  late final Animation<double> _message1Opacity;
  late final Animation<Offset> _message1Slide;
  late final Animation<double> _message2Opacity;
  late final Animation<Offset> _message2Slide;
  late final Animation<double> _message3Opacity;
  late final Animation<Offset> _message3Slide;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startSequentialAnimation();
  }

  void _initAnimations() {
    // Greeting animation
    _greetingController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _greetingOpacity = CurvedAnimation(
      parent: _greetingController,
      curve: Curves.easeOut,
    );
    _greetingSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _greetingController,
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
  }

  Future<void> _startSequentialAnimation() async {
    // Sequential reveal with 300ms delay between each
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _greetingController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _message1Controller.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _message2Controller.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _message3Controller.forward();
  }

  @override
  void dispose() {
    _greetingController.dispose();
    _message1Controller.dispose();
    _message2Controller.dispose();
    _message3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final greeting = GuestHomeContent.getGreeting(DateTime.now().hour);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.successBackground,
            AppColors.surface,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 시간대별 인사
          SlideTransition(
            position: _greetingSlide,
            child: FadeTransition(
              opacity: _greetingOpacity,
              child: Text(
                greeting,
                style: AppTypography.heading1.copyWith(
                  color: AppColors.textPrimary,
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
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 환영 메시지 1
          SlideTransition(
            position: _message1Slide,
            child: FadeTransition(
              opacity: _message1Opacity,
              child: Text(
                GuestHomeContent.welcomeMessage1,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // 환영 메시지 2
          SlideTransition(
            position: _message2Slide,
            child: FadeTransition(
              opacity: _message2Opacity,
              child: Text(
                GuestHomeContent.welcomeMessage2,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 환영 메시지 3 (강조)
          SlideTransition(
            position: _message3Slide,
            child: FadeTransition(
              opacity: _message3Opacity,
              child: Text(
                GuestHomeContent.welcomeMessage3,
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
