import 'package:flutter/material.dart';

/// Widget for inputting weekly goal values (0-7)
///
/// Provides real-time validation and error messages for weekly goal inputs.
class WeeklyGoalInputWidget extends StatefulWidget {
  final String label;
  final int initialValue;
  final Function(int) onChanged;

  const WeeklyGoalInputWidget({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<WeeklyGoalInputWidget> createState() => _WeeklyGoalInputWidgetState();
}

class _WeeklyGoalInputWidgetState extends State<WeeklyGoalInputWidget> {
  late TextEditingController _controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateInput(String value) {
    setState(() {
      if (value.isEmpty) {
        _errorMessage = null;
        return;
      }

      // Check if non-integer
      if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
        _errorMessage = '정수만 입력 가능합니다';
        return;
      }

      final intValue = int.parse(value);

      // Check range
      if (intValue < 0) {
        _errorMessage = '0 이상의 값을 입력하세요';
      } else if (intValue > 7) {
        _errorMessage = '주간 목표는 최대 7회입니다';
      } else {
        _errorMessage = null;
        // Notify parent of valid change
        widget.onChanged(intValue);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      maxLength: 1,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: '0~7',
        counterText: '',
        suffixText: '회/주',
        suffixStyle: Theme.of(context).textTheme.bodyMedium,
        errorText: _errorMessage,
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red[300]!),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red[300]!),
        ),
        border: const OutlineInputBorder(),
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 12.0,
        ),
      ),
      onChanged: _validateInput,
    );
  }
}
