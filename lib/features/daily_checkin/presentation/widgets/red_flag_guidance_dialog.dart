import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/daily_checkin/domain/entities/red_flag_detection.dart';

/// Red Flag 안내 다이얼로그
///
/// Red Flag 감지 시 사용자에게 부드럽게 안내하는 다이얼로그입니다.
/// 톤: 부드럽고 지지적이며, 금지 용어 사용하지 않음
class RedFlagGuidanceDialog extends StatelessWidget {
  final RedFlagDetection redFlag;
  final String message;

  const RedFlagGuidanceDialog({
    super.key,
    required this.redFlag,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 이모지
            Text(
              _getEmoji(),
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 16),
            // 제목
            Text(
              _getTitle(),
              textAlign: TextAlign.center,
              style: AppTypography.heading2.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 16),
            // 메시지
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.neutral700,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            // 버튼
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.neutral700,
                      side: BorderSide(color: AppColors.neutral300),
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '알겠어요',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getEmoji() {
    switch (redFlag.type) {
      case RedFlagType.pancreatitis:
      case RedFlagType.cholecystitis:
      case RedFlagType.severeDehydration:
        return '💛';
      case RedFlagType.bowelObstruction:
      case RedFlagType.hypoglycemia:
      case RedFlagType.renalImpairment:
        return '💛';
    }
  }

  String _getTitle() {
    switch (redFlag.severity) {
      case RedFlagSeverity.warning:
        return '확인이 필요해 보여요';
      case RedFlagSeverity.urgent:
        return '조금 확인이 필요해 보여요';
    }
  }
}

/// Red Flag 안내 다이얼로그 표시 헬퍼 함수
Future<void> showRedFlagGuidanceDialog({
  required BuildContext context,
  required RedFlagDetection redFlag,
  required String message,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => RedFlagGuidanceDialog(
      redFlag: redFlag,
      message: message,
    ),
  );
}
