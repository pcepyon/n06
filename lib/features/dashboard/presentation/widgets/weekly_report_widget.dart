import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import '../../domain/entities/weekly_summary.dart';

class WeeklyReportWidget extends StatefulWidget {
  final WeeklySummary summary;

  const WeeklyReportWidget({
    super.key,
    required this.summary,
  });

  @override
  State<WeeklyReportWidget> createState() => _WeeklyReportWidgetState();
}

class _WeeklyReportWidgetState extends State<WeeklyReportWidget> {
  bool _isPressed = false;

  String _formatWeightChange(double weightChangeKg) {
    final direction = weightChangeKg < 0 ? '↓' : '↑';
    return '$direction ${weightChangeKg.abs().toStringAsFixed(1)}kg';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        context.push('/data-sharing');
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
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
              color: _isPressed ? Color(0x140F172A) : Color(0x0F0F172A),
              blurRadius: _isPressed ? 8 : 4,
              offset: Offset(0, _isPressed ? 4 : 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Text(
              '지난주 요약',
              style: AppTypography.heading3,
            ),

            SizedBox(height: 16), // md spacing

            // Report Items Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ReportItem(
                  icon: Icons.medication,
                  iconColor: AppColors.primary,
                  label: '투여',
                  value: '${widget.summary.doseCompletedCount}회',
                ),
                _ReportItem(
                  icon: Icons.monitor_weight,
                  iconColor: AppColors.success,
                  label: '체중',
                  value: _formatWeightChange(widget.summary.weightChangeKg),
                ),
                _ReportItem(
                  icon: Icons.warning_amber,
                  iconColor: AppColors.error,
                  label: '부작용',
                  value: '${widget.summary.symptomRecordCount}회',
                ),
              ],
            ),

            SizedBox(height: 16), // md spacing

            // Adherence Container
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '투여 순응도',
                    style: AppTypography.bodySmall,
                  ),
                  Text(
                    '${widget.summary.adherencePercentage.toStringAsFixed(0)}%',
                    style: AppTypography.heading3.copyWith(
                      color: AppColors.primary,
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

class _ReportItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _ReportItem({
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
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.caption,
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
