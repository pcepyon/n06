import 'package:flutter/material.dart';

/// 조건부 UI 섹션 컨테이너
///
/// 심각도에 따라 다른 스타일의 섹션을 표시합니다:
/// - 고심각도 (7-10점): Warning 색상 (주황색) 배경 및 테두리
/// - 저심각도 (1-6점): Info 색상 (파란색) 배경 및 테두리
///
/// Features:
/// - 좌측 강조 테두리 (4px)
/// - 반투명 배경 (8% opacity)
/// - 아이콘 및 라벨 표시
class ConditionalSection extends StatelessWidget {
  final bool isHighSeverity; // true: 고심각도, false: 저심각도
  final Widget child;

  const ConditionalSection({
    super.key,
    required this.isHighSeverity,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isHighSeverity
        ? const Color(0xFFF59E0B).withValues(alpha: 0.08) // Warning at 8%
        : const Color(0xFF3B82F6).withValues(alpha: 0.08); // Info at 8%

    final Color borderColor = isHighSeverity
        ? const Color(0xFFF59E0B) // Warning
        : const Color(0xFF3B82F6); // Info

    final IconData icon = isHighSeverity
        ? Icons.error_outline // alert-circle equivalent
        : Icons.label_outline; // tag equivalent

    final String label = isHighSeverity ? '24시간 지속 여부' : '관련 상황';

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          left: BorderSide(
            color: borderColor,
            width: 4.0,
          ),
        ),
        borderRadius: BorderRadius.circular(8.0), // sm
      ),
      padding: const EdgeInsets.all(16.0), // md
      margin: const EdgeInsets.only(bottom: 16.0), // md
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 라벨
          Row(
            children: [
              Icon(
                icon,
                size: 20.0,
                color: borderColor,
              ),
              const SizedBox(width: 8.0), // sm
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18.0, // lg
                  fontWeight: FontWeight.w600, // Semibold
                  color: Color(0xFF334155), // Neutral-700
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0), // sm + xs
          // 컨텐츠
          child,
        ],
      ),
    );
  }
}
