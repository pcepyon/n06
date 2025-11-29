import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

/// 동의 체크박스 컴포넌트
///
/// 44x44px 터치 영역을 제공하는 접근성이 높은 체크박스입니다.
/// 필수/선택 상태를 뱃지로 표시합니다.
///
/// 사용 예시:
/// ```dart
/// ConsentCheckbox(
///   label: '이용약관에 동의합니다',
///   isRequired: true,
///   value: _agreedToTerms,
///   onChanged: (val) => setState(() => _agreedToTerms = val),
/// )
/// ```
class ConsentCheckbox extends StatelessWidget {
  /// 체크박스 레이블 텍스트
  final String label;

  /// 필수 여부
  final bool isRequired;

  /// 현재 체크 상태
  final bool value;

  /// 상태 변경 콜백
  final ValueChanged<bool> onChanged;

  const ConsentCheckbox({
    Key? key,
    required this.label,
    this.isRequired = false,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            // Checkbox (24x24px visual, 44x44px touch area)
            SizedBox(
              width: 24,
              height: 24,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: value ? AppColors.primary : AppColors.neutral400,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  color: value ? AppColors.primary : Colors.transparent,
                ),
                child: value
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            // Label
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.neutral700,
                      ),
                    ),
                  ),
                  if (isRequired)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '필수',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
