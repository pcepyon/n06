import 'package:flutter/material.dart';
import 'package:n06/core/extensions/l10n_extension.dart';

class RecordDeleteDialog extends StatelessWidget {
  final String recordType;
  final String recordInfo;
  final VoidCallback onConfirm;

  const RecordDeleteDialog({
    super.key,
    required this.recordType,
    required this.recordInfo,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.tracking_deleteDialog_title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.tracking_deleteDialog_message, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recordType, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(recordInfo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_outlined, color: Colors.red.shade800, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.tracking_deleteDialog_warning,
                    style: TextStyle(fontSize: 12, color: Colors.red.shade800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.common_button_cancel)),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text(context.l10n.common_button_delete),
        ),
      ],
    );
  }
}
