import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import '../../domain/entities/weekly_summary.dart';

/// CelebratoryReportWidget: 주간 요약을 축하의 관점으로 전환
///
/// 심리학적 근거:
/// - Duolingo 스타일 임계값 축하: 70%도 "잘하고 있어요!"
/// - Noom 스타일 긍정적 재해석: 모든 데이터를 성취로 프레이밍
/// - 피해자 → 극복자 언어 변환: "부작용 3회" → "3일을 잘 견뎌냈어요"
///
/// CRITICAL 변경사항:
/// - 부작용 아이콘: AppColors.error → AppColors.warning (#F59E0B)
/// - 부작용 라벨: "부작용" → "적응기"
/// - 70%+ 순응도: AppColors.primary → AppColors.success + 격려 메시지
class CelebratoryReportWidget extends StatefulWidget {
  final WeeklySummary summary;

  const CelebratoryReportWidget({
    super.key,
    required this.summary,
  });

  @override
  State<CelebratoryReportWidget> createState() =>
      _CelebratoryReportWidgetState();
}

class _CelebratoryReportWidgetState extends State<CelebratoryReportWidget> {
  bool _isPressed = false;

  /// 냉정한 숫자를 축하의 언어로 변환
  ///
  /// 심리학적 근거:
  /// - "3회 발생" → "3일을 잘 견뎌냈어요" : 피해자 → 극복자
  /// - "72%" → "목표의 72% 달성!" : 부족함 → 성취
  /// - "2회 투여" → "2회 투여 완료" : 완료 = 성취
  String _getCelebratoryValue(BuildContext context, String type, dynamic value) {
    final l10n = context.l10n;
    switch (type) {
      case 'dose':
        return l10n.dashboard_report_dose_value(value as int);
      case 'weight':
        final double weightValue = value as double;
        final weight = weightValue.abs().toStringAsFixed(1);
        return weightValue < 0
            ? l10n.dashboard_report_weight_decreased(weight)
            : l10n.dashboard_report_weight_increased(weight);
      case 'symptom':
        final int count = value as int;
        if (count == 0) {
          return l10n.dashboard_report_symptom_none;
        } else if (count <= 2) {
          return l10n.dashboard_report_symptom_mild;
        } else if (count <= 5) {
          return l10n.dashboard_report_symptom_moderate(count);
        } else {
          return l10n.dashboard_report_symptom_adapting;
        }
      case 'adherence':
        // This is not used in the current code, but keeping for compatibility
        final double adherenceValue = value as double;
        return l10n.dashboard_report_adherence_fallback(adherenceValue.toStringAsFixed(0));
      default:
        return value.toString();
    }
  }

  /// 순응도에 따른 격려 메시지
  ///
  /// 심리학적 근거 (Duolingo 스타일):
  /// - 70%도 칭찬: "잘하고 있어요" (Duolingo는 50%도 칭찬)
  /// - 100%는 특별: "완벽해요!"
  /// - 70% 미만도 비난 없음 (빈 문자열)
  String _getAdherenceMessage(BuildContext context, double percentage) {
    final l10n = context.l10n;
    if (percentage >= 100) return l10n.dashboard_report_adherence_perfect;
    if (percentage >= 90) return l10n.dashboard_report_adherence_almostThere;
    if (percentage >= 70) return l10n.dashboard_report_adherence_doingWell;
    return '';
  }

  /// 순응도에 따른 색상 결정
  /// 70%+ : Success (성취감 강조)
  /// 70% 미만 : Primary (기본)
  Color _getAdherenceColor(double percentage) {
    return percentage >= 70 ? AppColors.success : AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final adherenceMessage = _getAdherenceMessage(context, widget.summary.adherencePercentage);
    final adherenceColor = _getAdherenceColor(widget.summary.adherencePercentage);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        context.push('/trend-dashboard');
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(0, _isPressed ? -2 : 0, 0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _isPressed
                  ? const Color(0x140F172A)
                  : const Color(0x0F0F172A),
              blurRadius: _isPressed ? 8 : 4,
              offset: Offset(0, _isPressed ? 4 : 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Text(
              context.l10n.dashboard_report_title,
              style: AppTypography.heading2,
            ),

            const SizedBox(height: 16),

            // Report Items Row - 축하의 언어로 변환
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _CelebratoryReportItem(
                  icon: Icons.medication,
                  iconColor: AppColors.primary,
                  label: context.l10n.dashboard_report_dose,
                  value: _getCelebratoryValue(
                    context,
                    'dose',
                    widget.summary.doseCompletedCount,
                  ),
                ),
                _CelebratoryReportItem(
                  icon: Icons.monitor_weight,
                  iconColor: AppColors.success,
                  label: context.l10n.dashboard_report_weight,
                  value: _getCelebratoryValue(
                    context,
                    'weight',
                    widget.summary.weightChangeKg,
                  ),
                ),
                // CRITICAL: 부작용 → 적응기, error → warning
                _CelebratoryReportItem(
                  icon: Icons.favorite_border, // 더 부드러운 아이콘
                  iconColor: AppColors.warning, // NOT error!
                  label: context.l10n.dashboard_report_symptom, // NOT "부작용"!
                  value: _getCelebratoryValue(
                    context,
                    'symptom',
                    widget.summary.symptomRecordCount,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Adherence Container with 축하 메시지
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left Column: Label + Encouragement Message
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.dashboard_report_adherence,
                        style: AppTypography.bodySmall,
                      ),
                      // 70%+ 일 때 격려 메시지 표시
                      if (adherenceMessage.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          adherenceMessage,
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Right: Percentage with conditional color
                  Text(
                    '${widget.summary.adherencePercentage.toStringAsFixed(0)}%',
                    style: AppTypography.heading2.copyWith(
                      color: adherenceColor,
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

/// 축하 언어로 표현되는 리포트 아이템
class _CelebratoryReportItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _CelebratoryReportItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: iconColor,
          semanticLabel: label,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.caption,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
