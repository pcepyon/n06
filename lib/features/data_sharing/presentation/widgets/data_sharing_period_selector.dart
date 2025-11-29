import 'package:flutter/material.dart';
import 'package:n06/features/data_sharing/domain/repositories/date_range.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

/// DataSharingPeriodSelector - 기간 선택 칩 그룹 (Gabium Design System)
///
/// 기록 공유 기간을 선택하는 컴포넌트
/// - Card 패턴 적용 (배경, 테두리, 그림자)
/// - FilterChip로 기간 선택 구현
/// - Design System 토큰 100% 적용
class DataSharingPeriodSelector extends StatelessWidget {
  final DateRange selectedPeriod;
  final Function(DateRange) onPeriodChanged;
  final String label;

  const DataSharingPeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.label = '표시 기간',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12), // md
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral900.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16), // md
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelMedium,
          ),
          const SizedBox(height: 8), // sm
          Wrap(
            spacing: 8, // sm
            runSpacing: 8,
            children: DateRange.values.map<Widget>((period) {
              final isSelected = selectedPeriod == period;
              return FilterChip(
                label: Text(
                  period.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.w500 // Medium
                        : FontWeight.w400, // Regular
                    color: isSelected
                        ? AppColors.surface
                        : AppColors.textPrimary,
                  ),
                ),
                onSelected: (selected) => onPeriodChanged(period),
                selected: isSelected,
                backgroundColor: AppColors.surfaceVariant,
                selectedColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // sm
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.borderDark,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
