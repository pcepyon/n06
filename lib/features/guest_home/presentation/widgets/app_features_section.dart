import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/guest_home/data/guest_home_content.dart';
import 'package:n06/features/guest_home/domain/entities/app_feature_data.dart';
import 'package:n06/features/guest_home/presentation/widgets/demo/demo_bottom_sheet.dart';
import 'package:n06/features/guest_home/presentation/widgets/demo/dose_calendar_demo.dart';
import 'package:n06/features/guest_home/presentation/widgets/demo/share_report_demo.dart';
import 'package:n06/features/guest_home/presentation/widgets/demo/trend_report_demo.dart';

/// 앱 기능 소개 섹션
/// P0 인터랙션: Staggered Card Entry, Press State with Depth, Expandable Details
/// 스크롤에 따라 카드가 순차적으로 나타남
class AppFeaturesSection extends StatefulWidget {
  /// 섹션이 뷰포트에 보이는지 여부 (스크롤 기반 트리거)
  final bool isVisible;

  const AppFeaturesSection({
    super.key,
    this.isVisible = false,
  });

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
                style: AppTypography.heading2.copyWith(
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                GuestHomeContent.featuresSectionSubtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // 기능 카드 리스트
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: List.generate(
              GuestHomeContent.appFeatures.length,
              (index) => _ScrollRevealFeatureCard(
                feature: GuestHomeContent.appFeatures[index],
                index: index,
                // 처음 2개는 바로 보이고, 나머지는 스크롤에 따라
                immediateReveal: index < 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 스크롤 기반 Reveal 애니메이션이 적용된 기능 카드
/// 간결한 형태: 아이콘 + 제목 + 한 줄 요약 (확장 시 상세)
class _ScrollRevealFeatureCard extends StatefulWidget {
  final AppFeatureData feature;
  final int index;
  final bool immediateReveal;

  const _ScrollRevealFeatureCard({
    required this.feature,
    required this.index,
    this.immediateReveal = false,
  });

  @override
  State<_ScrollRevealFeatureCard> createState() =>
      _ScrollRevealFeatureCardState();

  /// 특정 기능에 대한 데모 위젯 반환
  static Widget? _getDemoWidget(String featureId) {
    switch (featureId) {
      case 'schedule':
        return const DoseCalendarDemo();
      case 'record':
        return const TrendReportDemo();
      case 'report':
        return const ShareReportDemo();
      default:
        return null;
    }
  }

  /// 특정 기능에 대한 데모 타이틀 반환
  static String? _getDemoTitle(String featureId) {
    switch (featureId) {
      case 'schedule':
        return '투여 캘린더 체험';
      case 'record':
        return '트렌드 리포트 체험';
      case 'report':
        return '의료진 공유하기 체험';
      default:
        return null;
    }
  }
}

class _ScrollRevealFeatureCardState extends State<_ScrollRevealFeatureCard>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final AnimationController _expandController;
  late final Animation<double> _expandAnimation;
  bool _hasAnimated = false;
  bool _isPressed = false;
  bool _isExpanded = false;
  final GlobalKey _cardKey = GlobalKey();

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

    _expandController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
    );

    // immediateReveal인 경우 staggered 딜레이로 바로 애니메이션
    if (widget.immediateReveal) {
      Future.delayed(
        Duration(milliseconds: 100 * widget.index),
        () {
          if (mounted && !_hasAnimated) {
            _hasAnimated = true;
            _entryController.forward();
          }
        },
      );
    } else {
      // 스크롤 기반: 프레임마다 visibility 체크
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startVisibilityCheck();
      });
    }
  }

  void _startVisibilityCheck() {
    if (!mounted || _hasAnimated) return;
    _checkVisibility();
  }

  void _checkVisibility() {
    if (!mounted || _hasAnimated) return;

    final renderBox =
        _cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      final position = renderBox.localToGlobal(Offset.zero);
      final screenHeight = MediaQuery.of(context).size.height;

      final triggerPoint = screenHeight * 0.85;
      if (position.dy < triggerPoint) {
        _hasAnimated = true;
        _entryController.forward();
        HapticFeedback.selectionClick();
        return;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
    HapticFeedback.selectionClick();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      key: _cardKey,
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTapDown: (_) {
            setState(() => _isPressed = true);
          },
          onTapUp: (_) {
            setState(() => _isPressed = false);
            _toggleExpand();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isExpanded ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 아이콘 + 제목 + 확장 인디케이터
                  Row(
                    children: [
                      Text(
                        widget.feature.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.feature.title,
                              style: AppTypography.labelLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.feature.summary,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.textTertiary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  // 확장 가능한 상세 섹션
                  SizeTransition(
                    sizeFactor: _expandAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.neutral100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.feature.description,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
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
                                ),
                              ),
                            ),
                          ],
                        ),
                        // 체험하기 버튼 (특정 기능에만 표시)
                        if (_ScrollRevealFeatureCard._getDemoWidget(widget.feature.id) != null) ...[
                          const SizedBox(height: 12),
                          Center(
                            child: TextButton.icon(
                              onPressed: () {
                                final demoWidget = _ScrollRevealFeatureCard._getDemoWidget(widget.feature.id);
                                final demoTitle = _ScrollRevealFeatureCard._getDemoTitle(widget.feature.id);
                                if (demoWidget != null && demoTitle != null) {
                                  showDemoBottomSheet(
                                    context: context,
                                    title: demoTitle,
                                    child: demoWidget,
                                  );
                                }
                              },
                              icon: const Icon(Icons.play_arrow, size: 16),
                              label: const Text('체험하기'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                textStyle: AppTypography.labelSmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
