import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';

/// F005: 전문가 상담 권장 다이얼로그
///
/// 사용자가 긴급 증상 중 하나라도 선택했을 때,
/// 전문가와의 상담이 필요함을 안내하는 모달 다이얼로그
///
/// Gabium Design System 적용:
/// - Error 색상 강조 (비상 상황)
/// - Alert Banner 패턴 (경고 메시지)
/// - Modal 컴포넌트 구조 (헤더, 컨텐츠, 푸터)
/// - 타이포그래피 계층화 (2xl, base, sm)
class ConsultationRecommendationDialog extends StatelessWidget {
  /// 사용자가 선택한 증상 목록
  final List<String> selectedSymptoms;

  const ConsultationRecommendationDialog({super.key, required this.selectedSymptoms});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Error accent
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.05),
                border: Border(
                  left: BorderSide(color: AppColors.error, width: 4),
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '전문가와 상담이 필요합니다',
                      style: AppTypography.heading1.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.close,
                      color: AppColors.error,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label
                  Text(
                    '선택하신 증상:',
                    style: AppTypography.heading3.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Symptom List
                  ...selectedSymptoms.map(
                    (symptom) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.warning_rounded,
                              color: AppColors.error,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              symptom,
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Alert Banner (Warning pattern)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.05),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outlined,
                          color: AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '선택하신 증상으로 보아 전문가의 상담이 필요해 보입니다. '
                            '가능한 한 빨리 의료진에게 연락하시기 바랍니다.',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Footer with action button
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.surfaceVariant,
                    width: 1,
                  ),
                ),
              ),
              child: GabiumButton(
                text: '확인',
                onPressed: () => Navigator.of(context).pop(),
                variant: GabiumButtonVariant.danger,
                size: GabiumButtonSize.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
