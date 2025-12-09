import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/features/guest_home/presentation/widgets/welcome_section.dart';
import 'package:n06/features/guest_home/presentation/widgets/not_your_fault_section.dart';
import 'package:n06/features/guest_home/presentation/widgets/scientific_evidence_section.dart';
import 'package:n06/features/guest_home/presentation/widgets/food_noise_section.dart';
import 'package:n06/features/guest_home/presentation/widgets/how_it_works_section.dart';
import 'package:n06/features/guest_home/presentation/widgets/journey_preview_section.dart';
import 'package:n06/features/guest_home/presentation/widgets/app_features_section.dart';
import 'package:n06/features/guest_home/presentation/widgets/side_effects_guide_section.dart';
import 'package:n06/features/guest_home/presentation/widgets/injection_guide_section.dart';
import 'package:n06/features/guest_home/presentation/widgets/cta_section.dart';
import 'package:n06/features/guest_home/presentation/widgets/section_progress_indicator.dart';

/// 비로그인 홈 화면
/// 앱 스토어 심사 통과 및 신규 사용자 전환을 위한 화면
///
/// 인터랙티브 기능:
/// - Progress Bar + 섹션 네비게이션
/// - 페이지 전환 애니메이션 (스케일 + 페이드)
/// - CTA 체크박스 활성화
/// - 섹션 진입 애니메이션
class GuestHomeScreen extends StatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  State<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends State<GuestHomeScreen>
    with TickerProviderStateMixin {
  // 현재 페이지 인덱스 (0-9: 각 섹션)
  int _currentPageIndex = 0;

  // 방문한 섹션들 (Progress Bar 용, 0-9)
  final Set<int> _visitedSections = {};

  // CTA 체크된 아이템들
  final Set<String> _checkedItems = {};

  // 페이지 전환 애니메이션 컨트롤러
  late final AnimationController _pageTransitionController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  // 전환 중인지 여부
  bool _isTransitioning = false;

  // 전환 방향 (true: forward, false: backward)
  bool _transitionForward = true;

  @override
  void initState() {
    super.initState();
    _pageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeOut,
    );

    // 초기 페이지는 바로 보이도록
    _pageTransitionController.value = 1.0;
  }

  @override
  void dispose() {
    _pageTransitionController.dispose();
    super.dispose();
  }

  /// 페이지 전환 (스케일 + 페이드 애니메이션)
  Future<void> _goToPage(int pageIndex) async {
    if (_isTransitioning || pageIndex == _currentPageIndex) return;
    if (pageIndex < 0 || pageIndex > 9) return;

    _isTransitioning = true;
    _transitionForward = pageIndex > _currentPageIndex;

    // Fade out
    await _pageTransitionController.reverse();

    setState(() {
      _currentPageIndex = pageIndex;
      // 섹션 방문 기록
      _visitedSections.add(pageIndex);
    });

    HapticFeedback.selectionClick();

    // Fade in
    await _pageTransitionController.forward();
    _isTransitioning = false;
  }

  /// 다음 페이지로 이동
  void _goToNextPage() {
    if (_currentPageIndex < 9) {
      _goToPage(_currentPageIndex + 1);
    }
  }

  /// Progress Bar 섹션 탭 핸들러
  void _onSectionTap(int sectionIndex) {
    // Progress Bar의 섹션 인덱스와 페이지 인덱스가 동일 (0-9)
    _goToPage(sectionIndex);
  }

  void _handleSignUp() {
    context.go('/login');
  }

  void _handleLearnMore() {
    // 부작용 가이드 섹션으로 이동 (페이지 인덱스 6)
    _goToPage(6);
    HapticFeedback.lightImpact();
  }

  void _handleCheckItem(String itemId) {
    setState(() {
      if (_checkedItems.contains(itemId)) {
        _checkedItems.remove(itemId);
      } else {
        _checkedItems.add(itemId);
      }
    });
  }

  /// 현재 페이지에 해당하는 Progress Bar 섹션 인덱스
  int get _currentSectionIndex => _currentPageIndex;

  /// 전체 스크롤 진행률 (페이지 기반)
  double get _scrollProgress => _currentPageIndex / 9;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Progress Bar (상단 고정)
          SectionProgressIndicator(
            currentSectionIndex: _currentSectionIndex,
            visitedSections: _visitedSections,
            scrollProgress: _scrollProgress,
            onSectionTap: _onSectionTap,
            onSignUpTap: _handleSignUp,
          ),
          // 페이지 콘텐츠
          Expanded(
            child: AnimatedBuilder(
              animation: _pageTransitionController,
              builder: (context, child) {
                // 전환 방향에 따른 스케일 조정
                final scale = _transitionForward
                    ? _scaleAnimation.value
                    : 2.0 - _scaleAnimation.value; // 뒤로 갈 때는 작아지는 효과

                return Transform.scale(
                  scale: scale.clamp(0.92, 1.0),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: _buildCurrentPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    // key를 사용하여 페이지 전환 시 위젯 재생성 → 스크롤 위치 초기화
    switch (_currentPageIndex) {
      case 0:
        return _PageWrapper(
          key: const ValueKey('page_0'),
          showNextButton: true,
          onNext: _goToNextPage,
          child: const WelcomeSection(),
        );
      case 1:
        return _PageWrapper(
          key: const ValueKey('page_1'),
          showNextButton: true,
          onNext: _goToNextPage,
          child: const NotYourFaultSection(),
        );
      case 2:
        return _PageWrapper(
          key: const ValueKey('page_2'),
          showNextButton: true,
          onNext: _goToNextPage,
          child: ScientificEvidenceSection(
            isVisible: _visitedSections.contains(2) || _currentPageIndex == 2,
          ),
        );
      case 3:
        return _PageWrapper(
          key: const ValueKey('page_3'),
          showNextButton: true,
          onNext: _goToNextPage,
          child: const FoodNoiseSection(),
        );
      case 4:
        return _PageWrapper(
          key: const ValueKey('page_4'),
          showNextButton: true,
          onNext: _goToNextPage,
          child: const HowItWorksSection(),
        );
      case 5:
        return _PageWrapper(
          key: const ValueKey('page_5'),
          showNextButton: true,
          onNext: _goToNextPage,
          child: JourneyPreviewSection(
            isVisible: _visitedSections.contains(5) || _currentPageIndex == 5,
          ),
        );
      case 6:
        return _PageWrapper(
          key: const ValueKey('page_6'),
          showNextButton: true,
          onNext: _goToNextPage,
          child: SideEffectsGuideSection(
            isVisible: _visitedSections.contains(6) || _currentPageIndex == 6,
          ),
        );
      case 7:
        return _PageWrapper(
          key: const ValueKey('page_7'),
          showNextButton: true,
          onNext: _goToNextPage,
          child: AppFeaturesSection(
            isVisible: _visitedSections.contains(7) || _currentPageIndex == 7,
          ),
        );
      case 8:
        return _PageWrapper(
          key: const ValueKey('page_8'),
          showNextButton: true,
          onNext: _goToNextPage,
          child: const InjectionGuideSection(),
        );
      case 9:
        return _PageWrapper(
          key: const ValueKey('page_9'),
          showNextButton: false,
          onNext: null,
          child: CtaSection(
            isVisible: _visitedSections.contains(9) || _currentPageIndex == 9,
            visitedSections: _visitedSections,
            checkedItems: _checkedItems,
            onCheckItem: _handleCheckItem,
            onSignUp: _handleSignUp,
            onLearnMore: _handleLearnMore,
            onNavigateToSection: _goToPage,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

/// 페이지 래퍼 위젯
/// 스크롤 가능한 영역 + 하단 다음 버튼
class _PageWrapper extends StatelessWidget {
  final Widget child;
  final bool showNextButton;
  final VoidCallback? onNext;

  const _PageWrapper({
    super.key,
    required this.child,
    required this.showNextButton,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 스크롤 가능한 콘텐츠 영역
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            child: child,
          ),
        ),
        // 하단 다음 버튼
        if (showNextButton)
          SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: _NextButton(onPressed: onNext),
            ),
          ),
      ],
    );
  }
}

/// 다음 섹션 버튼
class _NextButton extends StatefulWidget {
  final VoidCallback? onPressed;

  const _NextButton({this.onPressed});

  @override
  State<_NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<_NextButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _isPressed
              ? AppColors.primaryHover
              : AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isPressed
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '다음으로',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
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
    );
  }
}
