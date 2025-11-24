import 'package:flutter/material.dart';

/// 식욕 조절 점수 선택 칩
///
/// 사용자가 식욕 조절 상태를 선택할 수 있는 커스텀 칩 위젯입니다.
/// Design System의 Primary 색상과 Neutral 색상을 사용합니다.
///
/// Features:
/// - 선택/미선택 상태별 다른 스타일
/// - 터치 영역 44px 이상 보장
/// - 명확한 시각적 피드백
class AppealScoreChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const AppealScoreChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4ADE80) // Primary
              : const Color(0xFFF1F5F9), // Neutral-100
          borderRadius: BorderRadius.circular(8.0), // sm
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 4.0,
                offset: const Offset(0, 2),
              ) // sm shadow
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2.0,
                offset: const Offset(0, 1),
              ), // xs shadow
          ],
        ),
        constraints: const BoxConstraints(
          minHeight: 44.0, // 터치 권장 높이
          minWidth: 60.0,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16.0, // base
            fontWeight:
                isSelected ? FontWeight.w500 : FontWeight.w400, // Medium or Regular
            color: isSelected
                ? Colors.white
                : const Color(0xFF334155), // White or Neutral-700
          ),
        ),
      ),
    );
  }
}
