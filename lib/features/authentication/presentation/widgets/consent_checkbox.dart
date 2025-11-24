import 'package:flutter/material.dart';

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
        height: 44, // Touch target size
        child: Row(
          children: [
            // Checkbox (24x24px visual, 44x44px touch area)
            SizedBox(
              width: 24,
              height: 24,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: value
                        ? const Color(0xFF4ADE80) // Primary
                        : const Color(0xFF94A3B8), // Neutral-400
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  color: value ? const Color(0xFF4ADE80) : Colors.transparent,
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
            const SizedBox(width: 8), // Spacing xs
            // Label
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16, // Typography base
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF334155), // Neutral-700
                        height: 24 / 16,
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
                        color:
                            const Color(0xFFEF4444).withOpacity(0.1), // Error-50
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '필수',
                        style: TextStyle(
                          fontSize: 12, // Typography xs
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFEF4444), // Error
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
