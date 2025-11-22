import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
          color: Colors.white,
          border: Border.all(
            color: Color(0xFFE2E8F0), // Neutral-200
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12), // md
          boxShadow: [
            BoxShadow(
              color: _isPressed ? Color(0x140F172A) : Color(0x0F0F172A),
              blurRadius: _isPressed ? 8 : 4,
              offset: Offset(0, _isPressed ? 4 : 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(24), // lg padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Text(
              '지난주 요약',
              style: TextStyle(
                fontSize: 18, // lg
                fontWeight: FontWeight.w600, // Semibold
                color: Color(0xFF1E293B), // Neutral-800
                height: 1.3,
              ),
            ),

            SizedBox(height: 16), // md spacing

            // Report Items Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ReportItem(
                  icon: Icons.medication,
                  iconColor: Color(0xFF4ADE80), // Primary
                  label: '투여',
                  value: '${widget.summary.doseCompletedCount}회',
                ),
                _ReportItem(
                  icon: Icons.monitor_weight,
                  iconColor: Color(0xFF10B981), // Success
                  label: '체중',
                  value: _formatWeightChange(widget.summary.weightChangeKg),
                ),
                _ReportItem(
                  icon: Icons.warning_amber,
                  iconColor: Color(0xFFEF4444), // Error
                  label: '부작용',
                  value: '${widget.summary.symptomRecordCount}회',
                ),
              ],
            ),

            SizedBox(height: 16), // md spacing

            // Adherence Container
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFF8FAFC), // Neutral-50
                border: Border.all(
                  color: Color(0xFFE2E8F0), // Neutral-200
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8), // sm
              ),
              padding: EdgeInsets.all(16), // md padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '투여 순응도',
                    style: TextStyle(
                      fontSize: 14, // sm
                      fontWeight: FontWeight.w400, // Regular
                      color: Color(0xFF64748B), // Neutral-500
                      height: 1.5,
                    ),
                  ),
                  Text(
                    '${widget.summary.adherencePercentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 18, // lg
                      fontWeight: FontWeight.w700, // Bold
                      color: Color(0xFF4ADE80), // Primary
                      height: 1.3,
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
          style: TextStyle(
            fontSize: 12, // xs
            fontWeight: FontWeight.w400, // Regular
            color: Color(0xFF64748B), // Neutral-500
            height: 1.4,
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16, // base
            fontWeight: FontWeight.w600, // Semibold
            color: Color(0xFF1E293B), // Neutral-800
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
