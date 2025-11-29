import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

/// ExitConfirmationDialog - 공유 종료 확인 다이얼로그 (Gabium Design System)
///
/// 데이터 공유를 종료할 때 사용자에게 확인을 요청하는 다이얼로그
/// - Gabium Modal 패턴 적용
/// - 명확한 타이포그래피 계층
/// - Warning 색상 (종료 버튼)
class ExitConfirmationDialog extends StatelessWidget {
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const ExitConfirmationDialog({
    super.key,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // lg
      ),
      elevation: 10, // xl shadow
      title: const Text(
        '공유 종료',
        style: AppTypography.heading2,
      ),
      content: Text(
        '정말로 공유를 종료하시겠습니까?',
        style: AppTypography.bodyLarge.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(),
          child: Text(
            '취소',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.warning,
            foregroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // sm
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            '종료',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600, // Semibold
              color: AppColors.surface,
            ),
          ),
        ),
      ],
    );
  }
}
