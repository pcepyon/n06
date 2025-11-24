import 'package:flutter/material.dart';

/// 상태 배지 타입
enum StatusBadgeType {
  success,
  error,
  warning,
  info,
}

/// StatusBadge 위젯
/// 상태별 색상과 아이콘을 표시하는 배지 컴포넌트
/// Gabium Design System의 Semantic Colors 사용
class StatusBadge extends StatelessWidget {
  final StatusBadgeType type;
  final String text;
  final IconData icon;

  const StatusBadge({
    super.key,
    required this.type,
    required this.text,
    required this.icon,
  });

  /// 배경 색상 (밝은 배경)
  Color get backgroundColor {
    switch (type) {
      case StatusBadgeType.success:
        return const Color(0xFFECFDF5); // Success Light
      case StatusBadgeType.error:
        return const Color(0xFFFEF2F2); // Error Light
      case StatusBadgeType.warning:
        return const Color(0xFFFFFBEB); // Warning Light
      case StatusBadgeType.info:
        return const Color(0xFFEFF6FF); // Info Light
    }
  }

  /// 텍스트 색상 (진한 계열)
  Color get textColor {
    switch (type) {
      case StatusBadgeType.success:
        return const Color(0xFF065F46); // Success Dark
      case StatusBadgeType.error:
        return const Color(0xFF991B1B); // Error Dark
      case StatusBadgeType.warning:
        return const Color(0xFF92400E); // Warning Dark
      case StatusBadgeType.info:
        return const Color(0xFF1E40AF); // Info Dark
    }
  }

  /// 테두리 색상
  Color get borderColor {
    switch (type) {
      case StatusBadgeType.success:
        return const Color(0xFF10B981); // Success
      case StatusBadgeType.error:
        return const Color(0xFFEF4444); // Error
      case StatusBadgeType.warning:
        return const Color(0xFFF59E0B); // Warning
      case StatusBadgeType.info:
        return const Color(0xFF3B82F6); // Info
    }
  }

  /// 아이콘 색상 (테두리와 동일)
  Color get iconColor => borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 44), // Touch target (44x44px)
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // sm spacing
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(8), // sm radius
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 아이콘 (20x20px)
          Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
          const SizedBox(width: 8), // sm spacing (아이콘-텍스트 간격)
          // 텍스트 (14px, Regular)
          Text(
            text,
            style: TextStyle(
              fontSize: 14, // sm
              fontWeight: FontWeight.w400, // Regular
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
