import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

/// 답변 버튼 위젯
///
/// 이모지 + 텍스트로 구성된 답변 선택 버튼입니다.
///
/// Features:
/// - 선택/미선택 상태별 다른 스타일
/// - 터치 영역 44px 이상 보장
/// - 긍정 답변은 Primary 색상 강조
/// - 명확한 시각적 피드백
class AnswerButton extends StatelessWidget {
  final String emoji;
  final String text;
  final bool isSelected;
  final bool isPositive; // 긍정 답변 여부 (좋았어요, 잘 먹었어요 등)
  final VoidCallback onTap;

  const AnswerButton({
    super.key,
    required this.emoji,
    required this.text,
    required this.isSelected,
    this.isPositive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getBorderColor(),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
          ],
        ),
        constraints: const BoxConstraints(
          minHeight: 44,
          minWidth: 100,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 이모지
            Text(
              emoji,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            // 텍스트
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: _getTextColor(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (isSelected) {
      // 긍정 답변은 Primary 색상 강조
      return isPositive ? AppColors.primary : AppColors.successBackground;
    }
    return AppColors.surface;
  }

  Color _getBorderColor() {
    if (isSelected) {
      return isPositive ? AppColors.primary : AppColors.primary;
    }
    return AppColors.neutral200;
  }

  Color _getTextColor() {
    if (isSelected) {
      return isPositive ? Colors.white : AppColors.primary;
    }
    return AppColors.neutral700;
  }
}
