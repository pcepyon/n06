import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

/// 긴급 증상 체크리스트 항목 컴포넌트
///
/// 개별 증상에 대한 체크박스와 텍스트를 표시합니다.
/// Gabium Design System 토큰을 적용하여 일관된 스타일 제공합니다.
///
/// Features:
/// - 44x44px 터치 영역 (WCAG 기준 충족)
/// - 커스텀 체크박스 (Design System 색상 적용)
/// - 명확한 상태 전환 애니메이션
/// - 의미론적 색상 사용 (Primary, Neutral)
class EmergencyChecklistItem extends StatelessWidget {
  /// 표시할 증상 텍스트
  final String symptom;

  /// 현재 체크 상태
  final bool isChecked;

  /// 상태 변경 콜백
  final ValueChanged<bool?> onChanged;

  const EmergencyChecklistItem({
    super.key,
    required this.symptom,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        constraints: const BoxConstraints(minHeight: 44),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Checkbox (44x44px touch area)
            SizedBox(
              width: 44,
              height: 44,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isChecked ? AppColors.primary : AppColors.textDisabled,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    color: isChecked ? AppColors.primary : AppColors.surface,
                  ),
                  child: isChecked
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
            ),
            // Symptom Text
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  symptom,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
