import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

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
        return AppColors.success.withValues(alpha: 0.1);
      case StatusBadgeType.error:
        return AppColors.error.withValues(alpha: 0.1);
      case StatusBadgeType.warning:
        return AppColors.warning.withValues(alpha: 0.1);
      case StatusBadgeType.info:
        return AppColors.info.withValues(alpha: 0.1);
    }
  }

  /// 텍스트 색상 (진한 계열)
  Color get textColor {
    switch (type) {
      case StatusBadgeType.success:
        return const Color(0xFF065F46);
      case StatusBadgeType.error:
        return const Color(0xFF991B1B);
      case StatusBadgeType.warning:
        return const Color(0xFF92400E);
      case StatusBadgeType.info:
        return const Color(0xFF1E40AF);
    }
  }

  /// 테두리 색상
  Color get borderColor {
    switch (type) {
      case StatusBadgeType.success:
        return AppColors.success;
      case StatusBadgeType.error:
        return AppColors.error;
      case StatusBadgeType.warning:
        return AppColors.warning;
      case StatusBadgeType.info:
        return AppColors.info;
    }
  }

  /// 아이콘 색상 (테두리와 동일)
  Color get iconColor => borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTypography.bodySmall.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}
