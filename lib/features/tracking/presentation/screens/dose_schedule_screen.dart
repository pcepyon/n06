import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/tracking/application/notifiers/medication_notifier.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';
import 'package:n06/features/tracking/presentation/widgets/injection_site_select_widget.dart';
import 'package:n06/features/tracking/presentation/widgets/dose_schedule_card.dart';
import 'package:n06/core/presentation/widgets/empty_state_widget.dart';
import 'package:n06/core/presentation/widgets/status_badge.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';

class DoseScheduleScreen extends ConsumerWidget {
  const DoseScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicationState = ref.watch(medicationNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('투여 스케줄'),
      ),
      body: medicationState.when(
        data: (data) {
          if (data.activePlan == null) {
            return const EmptyStateWidget(
              icon: Icons.assignment_outlined,
              title: '투여 계획이 없습니다',
              description: '온보딩을 완료하여 투여 일정을 등록해주세요',
            );
          }

          final schedules = data.schedules;
          final records = data.records;

          if (schedules.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.calendar_today_outlined,
              title: '투여 계획이 없습니다',
              description: '온보딩을 완료하여 투여 일정을 등록해주세요',
            );
          }

          // Sort schedules by date
          final sortedSchedules = List<DoseSchedule>.from(schedules)
            ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

          return ListView.builder(
            padding: const EdgeInsets.all(16), // md spacing
            itemCount: sortedSchedules.length,
            itemBuilder: (context, index) {
              final schedule = sortedSchedules[index];
              final isCompleted = records.any(
                (record) => record.administeredAt.year == schedule.scheduledDate.year &&
                    record.administeredAt.month == schedule.scheduledDate.month &&
                    record.administeredAt.day == schedule.scheduledDate.day,
              );

              // 상태 결정
              final isOverdue = schedule.isOverdue();
              final isToday = schedule.isToday();

              StatusBadgeType statusType;
              String statusText;
              IconData statusIcon;

              if (isCompleted) {
                statusType = StatusBadgeType.success;
                statusText = '완료됨';
                statusIcon = Icons.check_circle;
              } else if (isOverdue) {
                statusType = StatusBadgeType.error;
                statusText = '연체됨';
                statusIcon = Icons.warning;
              } else if (isToday) {
                statusType = StatusBadgeType.warning;
                statusText = '오늘';
                statusIcon = Icons.flag;
              } else {
                statusType = StatusBadgeType.info;
                statusText = '예정';
                statusIcon = Icons.schedule;
              }

              return DoseScheduleCard(
                doseAmount: '${schedule.scheduledDoseMg} mg',
                scheduledDate: _formatDate(schedule.scheduledDate),
                statusType: statusType,
                statusText: statusText,
                statusIcon: statusIcon,
                onActionPressed: () => _showRecordDialog(context, ref, schedule),
                isLoading: false,
              );
            },
          );
        },
        loading: () => const Center(
          child: SizedBox(
            width: 48, // Large spinner
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFF4ADE80), // Primary color
              ),
            ),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('오류가 발생했습니다: $error'),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final weekDay = ['월', '화', '수', '목', '금', '토', '일'][date.weekday - 1];
    return '$month월 $day일 ($weekDay)';
  }

  void _showRecordDialog(
    BuildContext context,
    WidgetRef ref,
    DoseSchedule schedule,
  ) {
    showDialog(
      context: context,
      builder: (context) => DoseRecordDialog(schedule: schedule),
    );
  }
}

/// Dialog for recording dose
class DoseRecordDialog extends ConsumerStatefulWidget {
  final DoseSchedule schedule;

  const DoseRecordDialog({
    required this.schedule,
    super.key,
  });

  @override
  ConsumerState<DoseRecordDialog> createState() => _DoseRecordDialogState();
}

class _DoseRecordDialogState extends ConsumerState<DoseRecordDialog> {
  String? selectedSite;
  final noteController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // lg radius
      ),
      title: const Text(
        '투여 기록',
        style: TextStyle(
          fontSize: 24, // 2xl
          fontWeight: FontWeight.w700, // Bold
          color: Color(0xFF1E293B), // Neutral-800
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0), // lg padding
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.schedule.scheduledDoseMg} mg를 투여했습니다.',
              style: const TextStyle(
                fontSize: 16, // base
                fontWeight: FontWeight.w400, // Regular
                color: Color(0xFF334155), // Neutral-700
              ),
            ),
            const SizedBox(height: 16), // md spacing
            const Text(
              '주사 부위',
              style: TextStyle(
                fontSize: 14, // sm
                fontWeight: FontWeight.w600, // Semibold
                color: Color(0xFF334155), // Neutral-700
              ),
            ),
            const SizedBox(height: 12),
            InjectionSiteSelectWidget(
              onSiteSelected: (site) {
                setState(() {
                  selectedSite = site;
                });
              },
            ),
            const SizedBox(height: 16), // md spacing
            const Text(
              '메모 (선택사항)',
              style: TextStyle(
                fontSize: 14, // sm
                fontWeight: FontWeight.w600, // Semibold
                color: Color(0xFF334155), // Neutral-700
              ),
            ),
            const SizedBox(height: 8), // sm spacing
            TextField(
              controller: noteController,
              style: const TextStyle(
                fontSize: 16, // base
                fontWeight: FontWeight.w400, // Regular
                color: Color(0xFF1E293B), // Neutral-800
              ),
              decoration: InputDecoration(
                hintText: '메모를 입력하세요',
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8), // Neutral-400
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12, // md
                  horizontal: 16, // md
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), // sm radius
                  borderSide: const BorderSide(
                    color: Color(0xFFCBD5E1), // Neutral-300
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), // sm radius
                  borderSide: const BorderSide(
                    color: Color(0xFF4ADE80), // Primary
                    width: 2,
                  ),
                ),
              ),
              maxLines: 3,
              maxLength: 100,
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.all(24), // lg padding
      actions: [
        Expanded(
          child: GabiumButton(
            text: '취소',
            onPressed: isLoading ? null : () => Navigator.of(context).pop(),
            variant: GabiumButtonVariant.secondary,
            size: GabiumButtonSize.medium,
          ),
        ),
        const SizedBox(width: 16), // md spacing
        Expanded(
          child: GabiumButton(
            text: '저장',
            onPressed: isLoading || selectedSite == null
                ? null
                : () => _saveDoseRecord(),
            variant: GabiumButtonVariant.primary,
            size: GabiumButtonSize.medium,
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }

  Future<void> _saveDoseRecord() async {
    if (selectedSite == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('주사 부위를 선택해주세요')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final medicationNotifier = ref.read(medicationNotifierProvider.notifier);
      final medicationState = ref.read(medicationNotifierProvider);

      final state = medicationState.asData?.value;
      if (state?.activePlan == null) {
        throw Exception('활성 투여 계획이 없습니다');
      }

      final doseRecord = DoseRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        doseScheduleId: widget.schedule.id,
        dosagePlanId: state!.activePlan!.id,
        administeredAt: DateTime.now(),
        actualDoseMg: widget.schedule.scheduledDoseMg,
        injectionSite: selectedSite,
        note: noteController.text.isEmpty ? null : noteController.text,
      );

      await medicationNotifier.recordDose(doseRecord);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('투여 기록이 저장되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
