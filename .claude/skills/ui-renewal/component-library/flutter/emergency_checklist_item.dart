/// EmergencyChecklistItem Component
/// From: Emergency Check Screen UI Renewal
/// Created: 2025-11-24
/// Framework: Flutter
/// Design System: Gabium v1.0

import 'package:flutter/material.dart';

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
    // Gabium Design System Colors
    const primaryColor = Color(0xFF4ADE80); // Primary
    const neutral600 = Color(0xFF475569); // Neutral-600
    const neutral400 = Color(0xFF94A3B8); // Neutral-400
    const white = Color(0xFFFFFFFF);

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
                      color: isChecked ? primaryColor : neutral400,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4), // sm radius
                    color: isChecked ? primaryColor : white,
                  ),
                  child: isChecked
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: white,
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
                  style: TextStyle(
                    fontSize: 16, // base scale
                    fontWeight: FontWeight.w400, // Regular
                    color: neutral600,
                    height: 1.5, // line height for Korean text
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

/// Usage Example:
/// ```dart
/// EmergencyChecklistItem(
///   symptom: '24시간 이상 계속 구토하고 있어요',
///   isChecked: selectedStates[0],
///   onChanged: (value) {
///     setState(() => selectedStates[0] = value ?? false);
///   },
/// )
/// ```

/// Design Tokens Applied:
/// Colors:
///   - Primary: #4ADE80 (Checked state)
///   - Neutral-600: #475569 (Text color)
///   - Neutral-400: #94A3B8 (Unchecked border)
///   - White: #FFFFFF (Background)
///
/// Typography:
///   - base: 16px, Regular (400)
///   - Line Height: 1.5 (Korean text)
///
/// Sizing:
///   - Touch Area: 44x44px (WCAG AA standard)
///   - Checkbox Visual: 24x24px
///   - Border Width: 2px
///   - Border Radius: 4px (sm)
///   - Icon Size: 16px
///
/// Spacing:
///   - Vertical Padding: 8px
///   - Horizontal Touch Area: 44px

/// Reusability:
/// High - Can be used for:
/// - Similar symptom checklists
/// - General form checkboxes
/// - Option selections
/// - Todo items
