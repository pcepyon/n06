import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/features/guest_home/presentation/widgets/welcome_section.dart';
import 'package:n06/features/guest_home/presentation/widgets/scientific_evidence_section.dart';
import 'package:n06/features/guest_home/presentation/widgets/journey_preview_section.dart';
import 'package:n06/features/guest_home/presentation/widgets/app_features_section.dart';
import 'package:n06/features/guest_home/presentation/widgets/side_effects_guide_section.dart';
import 'package:n06/features/guest_home/presentation/widgets/cta_section.dart';
import 'package:n06/features/guest_home/presentation/widgets/section_progress_indicator.dart';

/// 비로그인 홈 화면
/// 앱 스토어 심사 통과 및 신규 사용자 전환을 위한 화면
///
/// 인터랙티브 기능:
/// - Progress Bar + 섹션 네비게이션
/// - 스크롤 기반 섹션 감지 및 애니메이션 트리거
/// - CTA 체크박스 활성화
/// - 섹션 진입 fade-in 애니메이션
class GuestHomeScreen extends StatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  State<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends State<GuestHomeScreen> {
  final ScrollController _scrollController = ScrollController();

  // 섹션 GlobalKey들 (Welcome은 항상 보이므로 제외, 5개 섹션)
  final List<GlobalKey> _sectionKeys = List.generate(
    5,
    (_) => GlobalKey(),
  );

  // 현재 활성 섹션 인덱스
  int _currentSectionIndex = 0;

  // 방문한 섹션들
  final Set<int> _visitedSections = {};

  // 각 섹션의 visibility 상태 (애니메이션 트리거용)
  final List<bool> _sectionVisibility = List.filled(5, false);

  // CTA 체크된 아이템들
  final Set<String> _checkedItems = {};

  // 전체 스크롤 진행률
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final scrollOffset = _scrollController.offset;
    final maxScroll = _scrollController.position.maxScrollExtent;

    // 전체 스크롤 진행률 계산
    setState(() {
      _scrollProgress = maxScroll > 0 ? (scrollOffset / maxScroll) : 0;
    });

    // 현재 뷰포트 정보
    final viewportHeight = _scrollController.position.viewportDimension;
    final viewportTop = scrollOffset;
    final viewportCenter = viewportTop + (viewportHeight / 2);

    // 각 섹션의 위치 확인 및 visibility 업데이트
    for (int i = 0; i < _sectionKeys.length; i++) {
      final key = _sectionKeys[i];
      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;

      if (renderBox != null && renderBox.hasSize) {
        final position = renderBox.localToGlobal(
          Offset.zero,
          ancestor: context.findRenderObject(),
        );
        final sectionTop = scrollOffset + position.dy;
        final sectionBottom = sectionTop + renderBox.size.height;

        // 섹션이 뷰포트에 30% 이상 보이면 visible로 처리
        final visibleThreshold = viewportTop + (viewportHeight * 0.3);
        if (sectionTop < viewportTop + viewportHeight &&
            sectionBottom > visibleThreshold) {
          if (!_sectionVisibility[i]) {
            setState(() {
              _sectionVisibility[i] = true;
              _visitedSections.add(i);
            });
            HapticFeedback.selectionClick();
          }
        }

        // 현재 섹션 결정 (뷰포트 중심에 가장 가까운 섹션)
        if (sectionTop <= viewportCenter && sectionBottom >= viewportCenter) {
          if (_currentSectionIndex != i) {
            setState(() {
              _currentSectionIndex = i;
            });
          }
        }
      }
    }
  }

  void _scrollToSection(int index) {
    final key = _sectionKeys[index];
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox != null) {
      final position = renderBox.localToGlobal(
        Offset.zero,
        ancestor: context.findRenderObject(),
      );
      final targetOffset = _scrollController.offset + position.dy - 80; // Progress bar 높이 고려

      _scrollController.animateTo(
        targetOffset.clamp(0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _handleSignUp() {
    context.go('/sign-up');
  }

  void _handleLearnMore() {
    // 부작용 가이드 섹션으로 스크롤
    _scrollToSection(3);
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
            onSectionTap: _scrollToSection,
          ),
          // 스크롤 가능한 콘텐츠
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. 환영 섹션 (항상 보임)
                const SliverToBoxAdapter(
                  child: WelcomeSection(),
                ),

                // 섹션 간격
                const SliverToBoxAdapter(
                  child: SizedBox(height: 40),
                ),

                // 2. 과학적 근거 섹션
                SliverToBoxAdapter(
                  child: _SectionWrapper(
                    key: _sectionKeys[0],
                    isVisible: _sectionVisibility[0],
                    child: ScientificEvidenceSection(
                      isVisible: _sectionVisibility[0],
                    ),
                  ),
                ),

                // 섹션 간격
                const SliverToBoxAdapter(
                  child: SizedBox(height: 48),
                ),

                // 3. 치료 여정 미리보기 섹션
                SliverToBoxAdapter(
                  child: _SectionWrapper(
                    key: _sectionKeys[1],
                    isVisible: _sectionVisibility[1],
                    child: JourneyPreviewSection(
                      isVisible: _sectionVisibility[1],
                    ),
                  ),
                ),

                // 섹션 간격
                const SliverToBoxAdapter(
                  child: SizedBox(height: 48),
                ),

                // 4. 앱 기능 소개 섹션
                SliverToBoxAdapter(
                  child: _SectionWrapper(
                    key: _sectionKeys[2],
                    isVisible: _sectionVisibility[2],
                    child: AppFeaturesSection(
                      isVisible: _sectionVisibility[2],
                    ),
                  ),
                ),

                // 섹션 간격
                const SliverToBoxAdapter(
                  child: SizedBox(height: 48),
                ),

                // 5. 부작용 대처 가이드 섹션
                SliverToBoxAdapter(
                  child: _SectionWrapper(
                    key: _sectionKeys[3],
                    isVisible: _sectionVisibility[3],
                    child: SideEffectsGuideSection(
                      isVisible: _sectionVisibility[3],
                    ),
                  ),
                ),

                // 섹션 간격
                const SliverToBoxAdapter(
                  child: SizedBox(height: 48),
                ),

                // 6. CTA 섹션
                SliverToBoxAdapter(
                  child: _SectionWrapper(
                    key: _sectionKeys[4],
                    isVisible: _sectionVisibility[4],
                    child: CtaSection(
                      isVisible: _sectionVisibility[4],
                      visitedSections: _visitedSections,
                      checkedItems: _checkedItems,
                      onCheckItem: _handleCheckItem,
                      onSignUp: _handleSignUp,
                      onLearnMore: _handleLearnMore,
                    ),
                  ),
                ),

                // 하단 여백
                const SliverToBoxAdapter(
                  child: SizedBox(height: 32),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 섹션 래퍼 위젯
/// fade-in 애니메이션을 적용
class _SectionWrapper extends StatefulWidget {
  final Widget child;
  final bool isVisible;

  const _SectionWrapper({
    super.key,
    required this.child,
    required this.isVisible,
  });

  @override
  State<_SectionWrapper> createState() => _SectionWrapperState();
}

class _SectionWrapperState extends State<_SectionWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  bool _hasRevealed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(_SectionWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !_hasRevealed) {
      _hasRevealed = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FractionalTranslation(
          translation: _slideAnimation.value,
          child: Opacity(
            opacity: _hasRevealed ? _fadeAnimation.value : 0,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
