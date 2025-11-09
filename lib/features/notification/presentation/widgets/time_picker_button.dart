import 'package:flutter/material.dart';

/// 시간 선택 버튼 위젯
class TimePickerButton extends StatelessWidget {
  final TimeOfDay currentTime;
  final Function(TimeOfDay) onTimeSelected;

  const TimePickerButton({super.key, required this.currentTime, required this.onTimeSelected});

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        key: const Key('notification_time_button'),
        onPressed: () async {
          final selectedTime = await showTimePicker(context: context, initialTime: currentTime);
          if (selectedTime != null) {
            onTimeSelected(selectedTime);
          }
        },
        icon: const Icon(Icons.access_time),
        label: Text(_formatTime(currentTime)),
        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
      ),
    );
  }
}
