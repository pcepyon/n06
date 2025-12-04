import 'package:flutter/material.dart';
import 'package:n06/core/extensions/l10n_extension.dart';

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
        _errorMessage = context.l10n.weeklyGoal_input_error_integerOnly;
        return;
      }

      final intValue = int.parse(value);

      // Check range
      if (intValue < 0) {
        _errorMessage = context.l10n.weeklyGoal_input_error_minimum;
      } else if (intValue > 7) {
        _errorMessage = context.l10n.weeklyGoal_input_error_maximum;
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
        hintText: context.l10n.weeklyGoal_input_hint,
        counterText: '',
        suffixText: context.l10n.weeklyGoal_input_suffix,
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
