import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/guest_home/data/guest_home_content.dart';
import 'package:n06/features/guest_home/presentation/widgets/demo/demo_bottom_sheet.dart';
import 'package:n06/features/guest_home/presentation/widgets/demo/injection_site_demo.dart';

/// 주사 가이드 섹션 위젯
/// P0 인터랙션: Expandable Card with Site Selection Interaction
class InjectionGuideSection extends StatefulWidget {
  const InjectionGuideSection({super.key});

  @override
  State<InjectionGuideSection> createState() => _InjectionGuideSectionState();
}

class _InjectionGuideSectionState extends State<InjectionGuideSection>
    with TickerProviderStateMixin {
  late final AnimationController _headerController;
  late final AnimationController _sitesController;
  late final AnimationController _reassuranceController;
  late final AnimationController _tipsController;
  late final AnimationController _footerController;

  late final Animation<double> _headerOpacity;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _sitesOpacity;
  late final Animation<double> _reassuranceOpacity;
  late final Animation<Offset> _reassuranceSlide;
  late final Animation<double> _tipsOpacity;
  late final Animation<double> _footerOpacity;

  int? _selectedSiteIndex;

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

    // Sites animation
    _sitesController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _sitesOpacity = CurvedAnimation(
      parent: _sitesController,
      curve: Curves.easeOut,
    );

    // Reassurance animation
    _reassuranceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _reassuranceOpacity = CurvedAnimation(
      parent: _reassuranceController,
      curve: Curves.easeOut,
    );
    _reassuranceSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _reassuranceController,
      curve: Curves.easeOutCubic,
    ));

    // Tips animation
    _tipsController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _tipsOpacity = CurvedAnimation(
      parent: _tipsController,
      curve: Curves.easeOut,
    );

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
    _sitesController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _reassuranceController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _tipsController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _footerController.forward();
  }

  void _toggleSiteSelection(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedSiteIndex == index) {
        _selectedSiteIndex = null;
      } else {
        _selectedSiteIndex = index;
      }
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _sitesController.dispose();
    _reassuranceController.dispose();
    _tipsController.dispose();
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
                    GuestHomeContent.injectionGuideSectionTitle,
                    style: AppTypography.heading1.copyWith(
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    GuestHomeContent.injectionGuideSubtitle,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          // 주사 부위 카드들
          FadeTransition(
            opacity: _sitesOpacity,
            child: Column(
              children: GuestHomeContent.injectionSites
                  .asMap()
                  .entries
                  .map((entry) => _InjectionSiteCard(
                        site: entry.value,
                        index: entry.key,
                        isSelected: _selectedSiteIndex == entry.key,
                        onTap: () => _toggleSiteSelection(entry.key),
                        delay: entry.key * 100,
                        controller: _sitesController,
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),
          // 안심 메시지들
          SlideTransition(
            position: _reassuranceSlide,
            child: FadeTransition(
              opacity: _reassuranceOpacity,
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
                    ...GuestHomeContent.injectionReassurance.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 18,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.success,
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
          const SizedBox(height: 20),
          // 팁 리스트
          FadeTransition(
            opacity: _tipsOpacity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      '알아두면 좋은 팁',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...GuestHomeContent.injectionTips.map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tip,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
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
          const SizedBox(height: 24),
          // 푸터
          FadeTransition(
            opacity: _footerOpacity,
            child: Text(
              GuestHomeContent.injectionFooter,
              style: AppTypography.heading3.copyWith(
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
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
                  title: '주사 부위 선택 체험',
                  child: InjectionSiteDemo(
                    onComplete: () {},
                  ),
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

/// 주사 부위 카드 위젯
class _InjectionSiteCard extends StatelessWidget {
  final Map<String, String> site;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  final int delay;
  final AnimationController controller;

  const _InjectionSiteCard({
    required this.site,
    required this.index,
    required this.isSelected,
    required this.onTap,
    required this.delay,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // 아이콘
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.neutral100,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                site['icon'] ?? '',
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 16),
            // 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    site['name'] ?? '',
                    style: AppTypography.heading3.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    site['description'] ?? '',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            // 선택 인디케이터
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.neutral300,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
