import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/guest_home/data/guest_home_content.dart';

/// CTA 섹션
/// P0 인터랙션: Pulsing CTA Button, Button Tap Feedback
/// P1 인터랙션: Scroll-Triggered CTA Reveal
class CtaSection extends StatefulWidget {
  final VoidCallback? onSignUp;
  final VoidCallback? onLearnMore;

  const CtaSection({
    super.key,
    this.onSignUp,
    this.onLearnMore,
  });

  @override
  State<CtaSection> createState() => _CtaSectionState();
}

class _CtaSectionState extends State<CtaSection>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _revealController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<Color?> _backgroundAnimation;
  bool _hasRevealed = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Pulsing animation for CTA button
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Reveal animation
    _revealController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeOutCubic,
    ));

    _backgroundAnimation = ColorTween(
      begin: AppColors.surface,
      end: AppColors.primary.withValues(alpha: 0.05),
    ).animate(_revealController);

    // 자동 reveal (스크롤 시 viewport 진입 대신)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerReveal();
    });
  }

  void _triggerReveal() {
    if (!_hasRevealed && mounted) {
      _hasRevealed = true;
      _revealController.forward();
      HapticFeedback.lightImpact();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          decoration: BoxDecoration(
            color: _backgroundAnimation.value,
            border: Border(
              top: BorderSide(
                color: AppColors.border,
                width: 1,
              ),
            ),
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // 제목
                  Text(
                    GuestHomeContent.ctaTitle,
                    style: AppTypography.heading1.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // 설명
                  Text(
                    GuestHomeContent.ctaDescription,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Primary CTA Button with Pulse
                  _buildPulsingButton(),
                  const SizedBox(height: 12),
                  // Secondary Button
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      widget.onLearnMore?.call();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      textStyle: AppTypography.labelMedium,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(GuestHomeContent.ctaSecondaryButton),
                  ),
                  const SizedBox(height: 32),
                  // 마무리 메시지
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.successBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('💚', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            GuestHomeContent.ctaFooterMessage,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPulsingButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.03);
        final shadowOpacity = 0.2 + (_pulseController.value * 0.1);
        final shadowBlur = 8.0 + (_pulseController.value * 4);

        return GestureDetector(
          onTapDown: (_) {
            setState(() => _isPressed = true);
          },
          onTapUp: (_) {
            setState(() => _isPressed = false);
            HapticFeedback.heavyImpact();
            widget.onSignUp?.call();
          },
          onTapCancel: () {
            setState(() => _isPressed = false);
          },
          child: Transform.scale(
            scale: _isPressed ? 0.98 : scale,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryHover,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: shadowOpacity),
                    blurRadius: shadowBlur,
                    spreadRadius: _pulseController.value * 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    GuestHomeContent.ctaPrimaryButton,
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
