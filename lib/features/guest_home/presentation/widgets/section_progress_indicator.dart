import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

/// 게스트 홈 섹션 정보
enum GuestHomeSection {
  evidence(label: '과학', icon: Icons.science_outlined),
  journey(label: '여정', icon: Icons.timeline_outlined),
  features(label: '기능', icon: Icons.apps_outlined),
  sideEffects(label: '부작용', icon: Icons.health_and_safety_outlined),
  cta(label: '시작', icon: Icons.rocket_launch_outlined);

  final String label;
  final IconData icon;

  const GuestHomeSection({required this.label, required this.icon});
}

/// 섹션 진행률 인디케이터 위젯
/// 상단에 고정되어 현재 섹션 위치를 표시하고 탭하여 이동 가능
class SectionProgressIndicator extends StatelessWidget {
  final int currentSectionIndex;
  final Set<int> visitedSections;
  final ValueChanged<int> onSectionTap;
  final double scrollProgress;

  const SectionProgressIndicator({
    super.key,
    required this.currentSectionIndex,
    required this.visitedSections,
    required this.onSectionTap,
    this.scrollProgress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 진행률 바
            _buildProgressBar(),
            const SizedBox(height: 12),
            // 섹션 도트 네비게이션
            _buildSectionDots(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        color: AppColors.neutral200,
        borderRadius: BorderRadius.circular(1.5),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: constraints.maxWidth * scrollProgress.clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryHover],
                  ),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        GuestHomeSection.values.length,
        (index) => _SectionDot(
          section: GuestHomeSection.values[index],
          isActive: index == currentSectionIndex,
          isVisited: visitedSections.contains(index),
          onTap: () => onSectionTap(index),
        ),
      ),
    );
  }
}

class _SectionDot extends StatelessWidget {
  final GuestHomeSection section;
  final bool isActive;
  final bool isVisited;
  final VoidCallback onTap;

  const _SectionDot({
    required this.section,
    required this.isActive,
    required this.isVisited,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 도트
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 32 : 24,
              height: isActive ? 32 : 24,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : isVisited
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : AppColors.neutral200,
                shape: BoxShape.circle,
                border: isVisited && !isActive
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: isVisited && !isActive
                    ? Icon(
                        Icons.check,
                        size: 14,
                        color: AppColors.primary,
                      )
                    : Icon(
                        section.icon,
                        size: isActive ? 16 : 12,
                        color: isActive
                            ? Colors.white
                            : isVisited
                                ? AppColors.primary
                                : AppColors.textTertiary,
                      ),
              ),
            ),
            const SizedBox(height: 4),
            // 라벨
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTypography.caption.copyWith(
                color: isActive
                    ? AppColors.primary
                    : isVisited
                        ? AppColors.textSecondary
                        : AppColors.textTertiary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                fontSize: isActive ? 11 : 10,
              ),
              child: Text(section.label),
            ),
          ],
        ),
      ),
    );
  }
}
