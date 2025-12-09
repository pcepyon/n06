import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

enum InjectionSite { abdomen, thigh, arm }

/// 주사 부위 선택 데모 위젯
///
/// 순수 UI 인터랙션만 제공하며, 데이터를 저장하지 않습니다.
/// StatefulWidget + setState 사용.
class InjectionSiteDemo extends StatefulWidget {
  final VoidCallback? onComplete;

  const InjectionSiteDemo({
    super.key,
    this.onComplete,
  });

  @override
  State<InjectionSiteDemo> createState() => _InjectionSiteDemoState();
}

class _InjectionSiteDemoState extends State<InjectionSiteDemo> {
  InjectionSite? _selectedSite;

  void _selectSite(InjectionSite site) {
    setState(() {
      _selectedSite = site;
    });
    HapticFeedback.mediumImpact();

    // 완료 콜백 호출 (옵션)
    widget.onComplete?.call();
  }

  String _getSiteLabel(InjectionSite site) {
    switch (site) {
      case InjectionSite.abdomen:
        return '복부';
      case InjectionSite.thigh:
        return '허벅지';
      case InjectionSite.arm:
        return '팔';
    }
  }

  String _getSiteDescription(InjectionSite site) {
    switch (site) {
      case InjectionSite.abdomen:
        return '가장 흡수가 빠름';
      case InjectionSite.thigh:
        return '편안하고 접근하기 쉬움';
      case InjectionSite.arm:
        return '보이지 않는 부위';
    }
  }

  IconData _getSiteIcon(InjectionSite site) {
    switch (site) {
      case InjectionSite.abdomen:
        return Icons.account_box;
      case InjectionSite.thigh:
        return Icons.accessibility_new;
      case InjectionSite.arm:
        return Icons.back_hand;
    }
  }

  String _getTipForSite(InjectionSite site) {
    switch (site) {
      case InjectionSite.abdomen:
        return '배꼽 주위 5cm 이상 떨어진 곳에 주사하세요. 복부는 가장 흔히 사용되는 부위로, 약물 흡수가 가장 빠릅니다.';
      case InjectionSite.thigh:
        return '허벅지 앞쪽 또는 바깥쪽에 주사하세요. 앉아있을 때 편하게 접근할 수 있어 많은 분들이 선호합니다.';
      case InjectionSite.arm:
        return '팔 뒤쪽 또는 바깥쪽에 주사하세요. 옷으로 가려지는 부위라 주사 자국이 보이지 않습니다.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 제목
        Text(
          '주사 부위 선택 체험',
          style: AppTypography.heading3.copyWith(
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // 설명
        Text(
          '주사 부위를 선택해보세요',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // 3개 부위 카드
        _buildSiteCard(InjectionSite.abdomen),
        const SizedBox(height: 12),
        _buildSiteCard(InjectionSite.thigh),
        const SizedBox(height: 12),
        _buildSiteCard(InjectionSite.arm),

        // 선택된 부위에 대한 팁 표시
        if (_selectedSite != null) ...[
          const SizedBox(height: 24),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.successBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: AppColors.success,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '주사 팁',
                      style: AppTypography.heading3.copyWith(
                        color: AppColors.success,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _getTipForSite(_selectedSite!),
                  style: AppTypography.bodyMedium.copyWith(
                    color: const Color(0xFF166534), // Green-800
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),

        // 일반 안내
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.educationBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '💡',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '매번 같은 부위에 주사하지 마세요. 부위를 바꿔가며 주사하면 피부 손상을 예방할 수 있습니다.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.education,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSiteCard(InjectionSite site) {
    final isSelected = _selectedSite == site;

    return Material(
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.1)
          : AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _selectSite(site),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // 아이콘
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : AppColors.neutral200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getSiteIcon(site),
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // 텍스트
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getSiteLabel(site),
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getSiteDescription(site),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),

              // 선택 표시
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 24,
                )
              else
                Icon(
                  Icons.circle_outlined,
                  color: AppColors.border,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
