import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// DatePickerField: GabiumTextField 스타일을 따르는 날짜 선택 필드
///
/// Design System 준수:
/// - Height: 48px
/// - Border: 2px solid #CBD5E1 (Neutral-300)
/// - Focus: Primary color (#4ADE80)
/// - Label: sm (14px, Semibold)
/// - Disabled: Neutral-50 배경
class DatePickerField extends StatefulWidget {
  final String label;
  final DateTime value;
  final Function(DateTime) onChanged;
  final DateTime firstDate;
  final DateTime lastDate;
  final bool enabled;
  final String? helperText;

  const DatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    this.enabled = true,
    this.helperText,
  });

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  late bool _isFocused;

  @override
  void initState() {
    super.initState();
    _isFocused = false;
  }

  Future<void> _selectDate(BuildContext context) async {
    if (!widget.enabled) return;

    final picked = await showDatePicker(
      context: context,
      initialDate: widget.value,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4ADE80), // Primary
              surface: Colors.white,
              onSurface: Color(0xFF1E293B), // Neutral-800
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != widget.value) {
      widget.onChanged(picked);
    }

    if (mounted) {
      setState(() => _isFocused = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(widget.value);
    final isFocused = _isFocused;
    final isDisabled = !widget.enabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨
        Text(
          widget.label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: const Color(0xFF334155), // Neutral-700
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),

        // 입력 필드
        GestureDetector(
          onTap: widget.enabled ? () async {
            setState(() => _isFocused = true);
            await _selectDate(context);
          } : null,
          child: MouseRegion(
            cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isFocused && widget.enabled
                    ? const Color(0xFF4ADE80) // Primary (focus)
                    : const Color(0xFFCBD5E1), // Neutral-300
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8), // sm
                color: isDisabled
                  ? const Color(0xFFF8FAFC) // Neutral-50
                  : Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formattedDate,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDisabled
                        ? const Color(0xFFCBD5E1) // Neutral-300
                        : const Color(0xFF334155), // Neutral-700
                      fontSize: 16,
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    size: 24,
                    color: isDisabled
                      ? const Color(0xFFCBD5E1) // Neutral-300
                      : const Color(0xFF475569), // Neutral-600
                  ),
                ],
              ),
            ),
          ),
        ),

        // 헬퍼 텍스트
        if (widget.helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.helperText!,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: const Color(0xFF94A3B8), // Neutral-400
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
