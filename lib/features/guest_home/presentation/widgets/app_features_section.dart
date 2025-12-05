import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/guest_home/data/guest_home_content.dart';
import 'package:n06/features/guest_home/domain/entities/app_feature_data.dart';

/// 앱 기능 소개 섹션
/// P0 인터랙션: Staggered Card Entry, Press State with Depth
class AppFeaturesSection extends StatefulWidget {
  const AppFeaturesSection({super.key});

  @override
  State<AppFeaturesSection> createState() => _AppFeaturesSectionState();
}

class _AppFeaturesSectionState extends State<AppFeaturesSection> {
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
                GuestHomeContent.featuresSectionTitle,
                style: AppTypography.heading1.copyWith(
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                GuestHomeContent.featuresSectionSubtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // 기능 카드 리스트
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: List.generate(
              GuestHomeContent.appFeatures.length,
              (index) => _StaggeredFeatureCard(
                feature: GuestHomeContent.appFeatures[index],
                index: index,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Staggered Entry 애니메이션이 적용된 기능 카드
class _StaggeredFeatureCard extends StatefulWidget {
  final AppFeatureData feature;
  final int index;

  const _StaggeredFeatureCard({
    required this.feature,
    required this.index,
  });

  @override
  State<_StaggeredFeatureCard> createState() => _StaggeredFeatureCardState();
}

class _StaggeredFeatureCardState extends State<_StaggeredFeatureCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  bool _hasAnimated = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  void _triggerAnimation() {
    if (!_hasAnimated) {
      _hasAnimated = true;
      Future.delayed(
        Duration(milliseconds: 100 * widget.index),
        () {
          if (mounted) {
            _entryController.forward();
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // VisibilityDetector 대신 첫 빌드 시 애니메이션 시작
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _triggerAnimation();
        });

        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTapDown: (_) {
                setState(() => _isPressed = true);
                HapticFeedback.lightImpact();
              },
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              child: AnimatedScale(
                scale: _isPressed ? 1.02 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Material(
                    elevation: _isPressed ? 6 : 2,
                    borderRadius: BorderRadius.circular(16),
                    shadowColor: Colors.black.withValues(alpha: 0.1),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.border,
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 아이콘 + 제목
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.feature.icon,
                                style: const TextStyle(fontSize: 28),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.feature.title,
                                  style: AppTypography.heading3,
                                ),
                              ),
                            ],
                          ),
                          // 페인 포인트 (있는 경우)
                          if (widget.feature.painPoints.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.neutral100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: widget.feature.painPoints
                                    .map(
                                      (point) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 4),
                                        child: Text(
                                          point,
                                          style:
                                              AppTypography.bodySmall.copyWith(
                                            color: AppColors.textSecondary,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          // 설명
                          Text(
                            widget.feature.description,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // 격려 메시지
                          Row(
                            children: [
                              const Text('💚', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.feature.encouragement,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.primary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
