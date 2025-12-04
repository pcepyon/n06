import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/core/extensions/l10n_extension.dart';

/// 심각도 변경 시 실시간으로 업데이트되는 피드백 칩
///
/// Phase 1: 안심 퍼스트 가이드 리뉴얼
/// - 심각도 슬라이더 바로 아래 표시
/// - 심각도 1-10에 따라 메시지와 배경색 동적 변경
/// - AnimatedSwitcher로 부드러운 전환
///
/// Design Tokens:
/// - 1-3: Success 배경, "가볍게 지나갈 거예요"
/// - 4-6: Info 배경, "몸이 적응 중이에요"
/// - 7-10: Warning 배경, "불편하시죠. 함께 확인해봐요"
/// - Height: 40px
/// - Padding: 12px 16px
/// - Animation: 200ms
class SeverityFeedbackChip extends StatelessWidget {
  final int severity; // 1-10
  final String symptomName;
  final VoidCallback? onEmergencyCheckTap;

  const SeverityFeedbackChip({
    super.key,
    required this.severity,
    required this.symptomName,
    this.onEmergencyCheckTap,
  });

  String _getEmoji() {
    if (severity <= 3) return '😌';
    if (severity <= 6) return '💪';
    return '🤝';
  }

  String _getMessage(BuildContext context) {
    final l10n = context.l10n;
    if (severity <= 3) return l10n.tracking_severity_feedbackMild;
    if (severity <= 6) return l10n.tracking_severity_feedbackModerate;
    return l10n.tracking_severity_feedbackSevere;
  }

  Color _getBackgroundColor() {
    if (severity <= 3) {
      return AppColors.success.withValues(alpha: 0.1);
    }
    if (severity <= 6) {
      return AppColors.info.withValues(alpha: 0.1);
    }
    return AppColors.warning.withValues(alpha: 0.1);
  }

  Color _getBorderColor() {
    if (severity <= 3) return AppColors.success;
    if (severity <= 6) return AppColors.info;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey<int>(severity),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          border: Border.all(
            color: _getBorderColor().withValues(alpha: 0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 메인 메시지
            Row(
              children: [
                Text(_getEmoji(), style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getMessage(context),
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.neutral800,
                    ),
                  ),
                ),
              ],
            ),

            // 심각도 7-10일 경우 추가 질문
            if (severity >= 7) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: onEmergencyCheckTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.help_outline,
                        size: 16,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.tracking_severity_emergencyCheck,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
