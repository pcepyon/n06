import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

/// 날짜 선택 위젯
///
/// 빠른 선택 버튼("오늘", "어제", "2일 전")과 캘린더 피커를 제공합니다.
/// 미래 날짜 선택은 불가능합니다.
class DateSelectionWidget extends StatefulWidget {
  /// 초기 선택된 날짜
  final DateTime? initialDate;

  /// 날짜가 선택되었을 때 호출되는 콜백
  final ValueChanged<DateTime> onDateSelected;

  const DateSelectionWidget({
    super.key,
    this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<DateSelectionWidget> createState() => _DateSelectionWidgetState();
}

class _DateSelectionWidgetState extends State<DateSelectionWidget> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate ?? _today();
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _yesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return DateTime(yesterday.year, yesterday.month, yesterday.day);
  }

  DateTime _twoDaysAgo() {
    final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
    return DateTime(twoDaysAgo.year, twoDaysAgo.month, twoDaysAgo.day);
  }

  void _selectQuickDate(DateTime date) {
    setState(() {
      selectedDate = date;
    });
    widget.onDateSelected(date);
  }

  Future<void> _openCalendar() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: _today(), // 미래 날짜 선택 불가
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
      widget.onDateSelected(picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 빠른 선택 버튼
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0), // sm
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _QuickDateButton(
                label: '오늘',
                onPressed: () => _selectQuickDate(_today()),
              ),
              _QuickDateButton(
                label: '어제',
                onPressed: () => _selectQuickDate(_yesterday()),
              ),
              _QuickDateButton(
                label: '2일 전',
                onPressed: () => _selectQuickDate(_twoDaysAgo()),
              ),
            ],
          ),
        ),

        // 캘린더 선택 버튼
        Padding(
          padding: const EdgeInsets.only(top: 8.0), // sm
          child: ElevatedButton.icon(
            onPressed: _openCalendar,
            icon: const Icon(Icons.calendar_today, size: 20.0),
            label: Text(
              _formatDate(selectedDate),
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 빠른 선택 버튼 (오늘, 어제, 2일 전)
class _QuickDateButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _QuickDateButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0), // sm
          side: const BorderSide(
            color: Color(0xFF4ADE80), // Primary
            width: 2.0,
          ),
          foregroundColor: const Color(0xFF4ADE80), // Primary
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // sm
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14.0, // sm
            fontWeight: FontWeight.w500, // Medium
          ),
        ),
      ),
    );
  }
}
