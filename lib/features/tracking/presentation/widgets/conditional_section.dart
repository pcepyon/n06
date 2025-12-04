import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/core/extensions/l10n_extension.dart';

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
    final l10n = context.l10n;
    final Color bgColor = isHighSeverity
        ? AppColors.warning.withValues(alpha: 0.08)
        : AppColors.info.withValues(alpha: 0.08);

    final Color borderColor = isHighSeverity
        ? AppColors.warning
        : AppColors.info;

    final IconData icon = isHighSeverity
        ? Icons.error_outline
        : Icons.label_outline;

    final String label = isHighSeverity
        ? l10n.tracking_conditional_highSeverity
        : l10n.tracking_conditional_lowSeverity;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          left: BorderSide(
            color: borderColor,
            width: 4.0,
          ),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 16.0),
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
              const SizedBox(width: 8.0),
              Text(
                label,
                style: AppTypography.heading3.copyWith(
                  color: AppColors.textSecondary,
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
