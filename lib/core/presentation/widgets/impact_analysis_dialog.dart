import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/tracking/domain/usecases/analyze_plan_change_impact_usecase.dart';
import 'package:n06/core/extensions/l10n_extension.dart';

/// ImpactAnalysisDialog: 투여 계획 변경 영향 분석 다이얼로그
///
/// Design System 준수:
/// - Max Width: 480px
/// - Border Radius: 16px (lg)
/// - Shadow: xl
/// - Modal 패턴 준수
/// - 색상: Primary (#4ADE80), Warning (#F59E0B), Info (#3B82F6), Success (#10B981)
class ImpactAnalysisDialog extends StatelessWidget {
  final PlanChangeImpact impact;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ImpactAnalysisDialog({
    super.key,
    required this.impact,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.neutral900.withValues(alpha: 0.12),
              blurRadius: 32,
              spreadRadius: 8,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: AppColors.neutral900.withValues(alpha: 0.08),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ====== 헤더 ======
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.common_dialog_impactAnalysisTitle,
                    style: AppTypography.heading1,
                  ),
                  GestureDetector(
                    onTap: onCancel,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Icon(
                        Icons.close,
                        size: 24,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ====== 바디 ======
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.common_dialog_impactAnalysisMessage,
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  // 영향받는 스케줄 수
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info,
                          size: 20,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            context.l10n.common_dialog_impactAnalysisAffectedSchedules(impact.affectedScheduleCount),
                            style: AppTypography.bodyLarge.copyWith(
                              color: const Color(0xFF065F46),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 변경되는 항목 (칩 형식)
                  if (impact.changedFields.isNotEmpty) ...[
                    Text(
                      context.l10n.common_dialog_impactAnalysisChangedFields,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.neutral700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: impact.changedFields.map((field) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.1),
                            border: Border.all(
                              color: AppColors.info.withValues(alpha: 0.3),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            field,
                            style: AppTypography.labelSmall.copyWith(
                              color: const Color(0xFF1E40AF),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 경고 메시지
                  if (impact.warningMessage != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.4),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber,
                            size: 20,
                            color: AppColors.secondaryPressed,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              impact.warningMessage!,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.secondaryPressed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // ====== 푸터 (버튼) ======
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: onCancel,
                        child: Text(
                          context.l10n.common_button_cancel,
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: onConfirm,
                        child: Text(
                          context.l10n.common_button_confirm,
                          style: AppTypography.labelMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
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
