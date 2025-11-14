import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/tracking/application/providers.dart';
import 'package:n06/features/tracking/application/notifiers/medication_notifier.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:intl/intl.dart';

/// 과거 기록 목록 화면 (체중/증상/투여)
class RecordListScreen extends ConsumerWidget {
  const RecordListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('기록 관리'),
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: '체중'),
              Tab(text: '증상'),
              Tab(text: '투여'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const _WeightRecordsTab(),
            const _SymptomRecordsTab(),
            const _DoseRecordsTab(),
          ],
        ),
      ),
    );
  }
}

/// 체중 기록 탭
class _WeightRecordsTab extends ConsumerWidget {
  const _WeightRecordsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final trackingState = ref.watch(trackingNotifierProvider);

    return authState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('오류: $err')),
      data: (user) {
        if (user == null) {
          return const Center(child: Text('로그인이 필요합니다'));
        }

        return trackingState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('오류: $err')),
          data: (state) {
            final weights = state.weights.asData?.value ?? [];

            if (weights.isEmpty) {
              return const Center(child: Text('기록이 없습니다'));
            }

            // 최신순으로 정렬
            final sortedWeights = List<WeightLog>.from(weights)
              ..sort((a, b) => b.logDate.compareTo(a.logDate));

            return ListView.builder(
              itemCount: sortedWeights.length,
              itemBuilder: (context, index) {
                final record = sortedWeights[index];
                return _WeightRecordTile(
                  record: record,
                  userId: user.id,
                );
              },
            );
          },
        );
      },
    );
  }
}

/// 체중 기록 항목
class _WeightRecordTile extends ConsumerWidget {
  final WeightLog record;
  final String userId;

  const _WeightRecordTile({
    required this.record,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = DateFormat('yyyy-MM-dd').format(record.logDate);
    final timeStr = DateFormat('HH:mm').format(record.createdAt);

    return ListTile(
      title: Text('${record.weightKg} kg'),
      subtitle: Text('$dateStr $timeStr'),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => _showDeleteDialog(
          context,
          ref,
          '${record.weightKg} kg',
          () => _deleteWeight(context, ref),
        ),
      ),
      onLongPress: () => _showDeleteDialog(
        context,
        ref,
        '${record.weightKg} kg',
        () => _deleteWeight(context, ref),
      ),
    );
  }

  Future<void> _deleteWeight(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(trackingNotifierProvider.notifier).deleteWeightLog(record.id);

      if (context.mounted) {
        Navigator.pop(context); // 다이얼로그 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('기록이 삭제되었습니다')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e')),
        );
      }
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    String info,
    VoidCallback onDelete,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('기록 삭제'),
        content: Text('$info 기록을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onDelete();
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// 증상 기록 탭
class _SymptomRecordsTab extends ConsumerWidget {
  const _SymptomRecordsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final trackingState = ref.watch(trackingNotifierProvider);

    return authState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('오류: $err')),
      data: (user) {
        if (user == null) {
          return const Center(child: Text('로그인이 필요합니다'));
        }

        return trackingState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('오류: $err')),
          data: (state) {
            final symptoms = state.symptoms.asData?.value ?? [];

            if (symptoms.isEmpty) {
              return const Center(child: Text('기록이 없습니다'));
            }

            // 최신순으로 정렬
            final sortedSymptoms = List<SymptomLog>.from(symptoms)
              ..sort((a, b) => b.logDate.compareTo(a.logDate));

            return ListView.builder(
              itemCount: sortedSymptoms.length,
              itemBuilder: (context, index) {
                final record = sortedSymptoms[index];
                return _SymptomRecordTile(
                  record: record,
                  userId: user.id,
                );
              },
            );
          },
        );
      },
    );
  }
}

/// 증상 기록 항목
class _SymptomRecordTile extends ConsumerWidget {
  final SymptomLog record;
  final String userId;

  const _SymptomRecordTile({
    required this.record,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = DateFormat('yyyy-MM-dd').format(record.logDate);
    final timeStr = DateFormat('HH:mm').format(record.createdAt ?? DateTime.now());

    return ListTile(
      title: Text('${record.symptomName} (심각도: ${record.severity}/10)'),
      subtitle: Text('$dateStr $timeStr'),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => _showDeleteDialog(
          context,
          ref,
          '${record.symptomName} (심각도: ${record.severity})',
          () => _deleteSymptom(context, ref),
        ),
      ),
      onLongPress: () => _showDeleteDialog(
        context,
        ref,
        '${record.symptomName} (심각도: ${record.severity})',
        () => _deleteSymptom(context, ref),
      ),
    );
  }

  Future<void> _deleteSymptom(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(trackingNotifierProvider.notifier).deleteSymptomLog(record.id);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('기록이 삭제되었습니다')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e')),
        );
      }
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    String info,
    VoidCallback onDelete,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('기록 삭제'),
        content: Text('$info 기록을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onDelete();
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// 투여 기록 탭
class _DoseRecordsTab extends ConsumerWidget {
  const _DoseRecordsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final medicationState = ref.watch(medicationNotifierProvider);

    return authState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('오류: $err')),
      data: (user) {
        if (user == null) {
          return const Center(child: Text('로그인이 필요합니다'));
        }

        return medicationState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('오류: $err')),
          data: (state) {
            final records = state.records;

            if (records.isEmpty) {
              return const Center(child: Text('기록이 없습니다'));
            }

            // 최신순으로 정렬
            final sortedRecords = List<DoseRecord>.from(records)
              ..sort((a, b) => b.administeredAt.compareTo(a.administeredAt));

            return ListView.builder(
              itemCount: sortedRecords.length,
              itemBuilder: (context, index) {
                final record = sortedRecords[index];
                return _DoseRecordTile(
                  record: record,
                  userId: user.id,
                );
              },
            );
          },
        );
      },
    );
  }
}

/// 투여 기록 항목
class _DoseRecordTile extends ConsumerWidget {
  final DoseRecord record;
  final String userId;

  const _DoseRecordTile({
    required this.record,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(record.administeredAt);
    final siteDisplay = record.injectionSite ?? '미지정';

    return ListTile(
      title: Text('${record.actualDoseMg} mg (부위: $siteDisplay)'),
      subtitle: Text(dateStr),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => _showDeleteDialog(
          context,
          ref,
          '${record.actualDoseMg} mg ($siteDisplay)',
          () => _deleteDose(context, ref),
        ),
      ),
      onLongPress: () => _showDeleteDialog(
        context,
        ref,
        '${record.actualDoseMg} mg ($siteDisplay)',
        () => _deleteDose(context, ref),
      ),
    );
  }

  Future<void> _deleteDose(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(doseRecordEditNotifierProvider.notifier).deleteDoseRecord(
            recordId: record.id,
            userId: userId,
          );

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('기록이 삭제되었습니다')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e')),
        );
      }
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    String info,
    VoidCallback onDelete,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('기록 삭제'),
        content: Text('$info 기록을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onDelete();
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
