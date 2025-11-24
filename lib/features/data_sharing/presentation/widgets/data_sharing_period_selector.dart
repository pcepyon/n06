import 'package:flutter/material.dart';
import 'package:n06/features/data_sharing/domain/repositories/date_range.dart';

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
        color: const Color(0xFFF8FAFC), // Neutral-50
        border: Border.all(
          color: const Color(0xFFE2E8F0), // Neutral-200
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12), // md
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600, // Semibold
              color: Color(0xFF334155), // Neutral-700
            ),
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
                        ? Colors.white
                        : const Color(0xFF334155), // Neutral-700
                  ),
                ),
                onSelected: (selected) => onPeriodChanged(period),
                selected: isSelected,
                backgroundColor: const Color(0xFFF1F5F9), // Neutral-100
                selectedColor: const Color(0xFF4ADE80), // Primary
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // sm
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF4ADE80)
                        : const Color(0xFFCBD5E1), // Neutral-300
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
