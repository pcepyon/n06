import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/tracking/presentation/dialogs/weight_edit_dialog.dart';
import 'package:n06/features/tracking/presentation/dialogs/symptom_edit_dialog.dart';
import 'package:n06/features/tracking/presentation/dialogs/dose_edit_dialog.dart';
import 'package:n06/features/tracking/presentation/dialogs/record_delete_dialog.dart';
import 'package:n06/features/tracking/application/providers.dart';

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

String _formatDateTime(DateTime dateTime) {
  return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}

class RecordDetailSheet extends ConsumerWidget {
  final dynamic record;
  final String userId;
  final VoidCallback? onRecordUpdated;

  const RecordDetailSheet({
    Key? key,
    required this.record,
    required this.userId,
    this.onRecordUpdated,
  }) : super(key: key);

  factory RecordDetailSheet.weight({
    required WeightLog log,
    required String userId,
    VoidCallback? onRecordUpdated,
  }) {
    return RecordDetailSheet(
      record: log,
      userId: userId,
      onRecordUpdated: onRecordUpdated,
    );
  }

  factory RecordDetailSheet.symptom({
    required SymptomLog log,
    required String userId,
    VoidCallback? onRecordUpdated,
  }) {
    return RecordDetailSheet(
      record: log,
      userId: userId,
      onRecordUpdated: onRecordUpdated,
    );
  }

  factory RecordDetailSheet.dose({
    required DoseRecord record,
    required String userId,
    VoidCallback? onRecordUpdated,
  }) {
    return RecordDetailSheet(
      record: record,
      userId: userId,
      onRecordUpdated: onRecordUpdated,
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    if (record is WeightLog) {
      showDialog(
        context: context,
        builder: (_) => WeightEditDialog(
          currentLog: record as WeightLog,
          userId: userId,
          onSaveSuccess: () {
            onRecordUpdated?.call();
            Navigator.pop(context); // Close sheet
          },
        ),
      );
    } else if (record is SymptomLog) {
      showDialog(
        context: context,
        builder: (_) => SymptomEditDialog(
          currentLog: record as SymptomLog,
          userId: userId,
          onSaveSuccess: () {
            onRecordUpdated?.call();
            Navigator.pop(context);
          },
        ),
      );
    } else if (record is DoseRecord) {
      showDialog(
        context: context,
        builder: (_) => DoseEditDialog(
          currentRecord: record as DoseRecord,
          userId: userId,
          onSaveSuccess: () {
            onRecordUpdated?.call();
            Navigator.pop(context);
          },
        ),
      );
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    String recordType = '';
    String recordInfo = '';
    Future<void> Function() deleteCallback = () async {};

    if (record is WeightLog) {
      final log = record as WeightLog;
      recordType = '체중 기록';
      recordInfo = '${log.weightKg}kg (${_formatDate(log.logDate)})';
      deleteCallback = () async {
        final notifier = ref.read(weightRecordEditNotifierProvider.notifier);
        await notifier.deleteWeight(
          recordId: log.id,
          userId: userId,
        );
      };
    } else if (record is SymptomLog) {
      final log = record as SymptomLog;
      recordType = '증상 기록';
      recordInfo = '${log.symptomName} (${_formatDate(log.logDate)})';
      deleteCallback = () async {
        final notifier = ref.read(symptomRecordEditNotifierProvider.notifier);
        await notifier.deleteSymptom(
          recordId: log.id,
          userId: userId,
        );
      };
    } else if (record is DoseRecord) {
      final dose = record as DoseRecord;
      recordType = '투여 기록';
      recordInfo = '${dose.actualDoseMg}mg (${_formatDateTime(dose.administeredAt)})';
      deleteCallback = () async {
        final notifier = ref.read(doseRecordEditNotifierProvider.notifier);
        await notifier.deleteDoseRecord(
          recordId: dose.id,
          userId: userId,
        );
      };
    }

    showDialog(
      context: context,
      builder: (_) => RecordDeleteDialog(
        recordType: recordType,
        recordInfo: recordInfo,
        onConfirm: () async {
          try {
            await deleteCallback();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$recordType가 삭제되었습니다'),
                  backgroundColor: Colors.green,
                ),
              );
              onRecordUpdated?.call();
              Navigator.pop(context); // Close sheet
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('삭제 실패: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget contentWidget = const SizedBox.shrink();

    if (record is WeightLog) {
      final log = record as WeightLog;
      contentWidget = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('체중 기록'),
          const SizedBox(height: 16),
          _buildInfoRow('날짜', _formatDate(log.logDate)),
          _buildInfoRow('체중', '${log.weightKg} kg'),
          _buildInfoRow(
            '기록 시간',
            '${log.createdAt.hour.toString().padLeft(2, '0')}:${log.createdAt.minute.toString().padLeft(2, '0')}',
          ),
        ],
      );
    } else if (record is SymptomLog) {
      final log = record as SymptomLog;
      contentWidget = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('증상 기록'),
          const SizedBox(height: 16),
          _buildInfoRow('날짜', _formatDate(log.logDate)),
          _buildInfoRow('증상', log.symptomName),
          _buildInfoRow('심각도', '${log.severity}/10'),
          if (log.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '컨텍스트',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: log.tags
                  .map((tag) => Chip(
                        label: Text(tag),
                        labelStyle: const TextStyle(fontSize: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ))
                  .toList(),
            ),
          ],
          if (log.note != null && log.note!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '메모',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            Text(log.note!),
          ],
        ],
      );
    } else if (record is DoseRecord) {
      final dose = record as DoseRecord;
      contentWidget = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('투여 기록'),
          const SizedBox(height: 16),
          _buildInfoRow(
            '날짜',
            _formatDate(dose.administeredAt),
          ),
          _buildInfoRow(
            '시간',
            '${dose.administeredAt.hour.toString().padLeft(2, '0')}:${dose.administeredAt.minute.toString().padLeft(2, '0')}',
          ),
          _buildInfoRow('투여량', '${dose.actualDoseMg} mg'),
          if (dose.injectionSite != null)
            _buildInfoRow('투여 부위', dose.injectionSite!),
          _buildInfoRow('상태', dose.isCompleted ? '완료' : '미완료'),
          if (dose.note != null && dose.note!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '메모',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            Text(dose.note!),
          ],
        ],
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            contentWidget,
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showEditDialog(context, ref),
                  icon: const Icon(Icons.edit),
                  label: const Text('수정'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showDeleteDialog(context, ref),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('삭제'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade100,
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
