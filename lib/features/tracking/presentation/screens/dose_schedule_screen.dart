import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/core/theme/app_colors.dart';
import 'package:n06/core/theme/app_text_styles.dart';
import 'package:n06/core/widgets/app_button.dart';
import 'package:n06/core/widgets/app_card.dart';
import 'package:n06/core/widgets/app_text_field.dart';
import 'package:n06/features/tracking/application/notifiers/medication_notifier.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';
import 'package:n06/features/tracking/presentation/widgets/injection_site_select_widget.dart';

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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.assignment_outlined, size: 48, color: AppColors.gray),
                  const SizedBox(height: 16),
                  Text('투여 계획이 없습니다', style: AppTextStyles.body1),
                  const SizedBox(height: 8),
                  Text(
                    '온보딩을 완료하여 투여 계획을 설정하세요',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body2.copyWith(color: AppColors.gray),
                  ),
                ],
              ),
            );
          }

          final schedules = data.schedules;
          final records = data.records;

          if (schedules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 48, color: AppColors.gray),
                  const SizedBox(height: 16),
                  Text('스케줄이 없습니다', style: AppTextStyles.body1),
                  const SizedBox(height: 8),
                  Text(
                    '투여 계획에 따라 스케줄이 자동으로 생성됩니다',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body2.copyWith(color: AppColors.gray),
                  ),
                ],
              ),
            );
          }

          // Sort schedules by date
          final sortedSchedules = List<DoseSchedule>.from(schedules)
            ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedSchedules.length,
            itemBuilder: (context, index) {
              final schedule = sortedSchedules[index];
              final isCompleted = records.any(
                (record) => record.administeredAt.year == schedule.scheduledDate.year &&
                    record.administeredAt.month == schedule.scheduledDate.month &&
                    record.administeredAt.day == schedule.scheduledDate.day,
              );

              return _buildScheduleCard(
                context,
                ref,
                schedule,
                isCompleted,
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('오류가 발생했습니다: $error', style: AppTextStyles.body1.copyWith(color: AppColors.error)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCard(
    BuildContext context,
    WidgetRef ref,
    DoseSchedule schedule,
    bool isCompleted,
  ) {
    final isOverdue = schedule.isOverdue();
    final isToday = schedule.isToday();
    final isUpcoming = schedule.isUpcoming();

    Color backgroundColor = Colors.white;
    Color borderColor = Colors.grey.shade300;
    Color textColor = Colors.black;

    if (isCompleted) {
      backgroundColor = Colors.green.shade50;
      borderColor = Colors.green.shade300;
      textColor = Colors.green.shade700;
    } else if (isOverdue) {
      backgroundColor = Colors.red.shade50;
      borderColor = Colors.red.shade300;
      textColor = Colors.red.shade700;
    } else if (isToday) {
      backgroundColor = Colors.blue.shade50;
      borderColor = Colors.blue.shade300;
      textColor = Colors.blue.shade700;
    } else if (isUpcoming) {
      backgroundColor = Colors.amber.shade50;
      borderColor = Colors.amber.shade300;
      textColor = Colors.amber.shade700;
    }

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      backgroundColor: backgroundColor,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          title: Text(
            '${schedule.scheduledDoseMg} mg',
            style: AppTextStyles.h3.copyWith(
              color: textColor,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                _formatDate(schedule.scheduledDate),
                style: AppTextStyles.body2.copyWith(color: textColor),
              ),
              if (isToday)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '오늘',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (isCompleted)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '완료됨',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          trailing: isCompleted
              ? Icon(Icons.check_circle, color: AppColors.success)
              : isOverdue
                  ? Icon(Icons.warning, color: AppColors.error)
                  : isToday || isUpcoming
                      ? AppButton(
                          text: '기록',
                          onPressed: () => _showRecordDialog(context, ref, schedule),
                          type: AppButtonType.primary,
                          isFullWidth: false,
                        )
                      : null,
          onTap: isCompleted || isOverdue
              ? null
              : isToday || isUpcoming
                  ? () => _showRecordDialog(context, ref, schedule)
                  : null,
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
      title: Text('투여 기록', style: AppTextStyles.h3),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.schedule.scheduledDoseMg} mg를 투여했습니다.',
              style: AppTextStyles.body1,
            ),
            const SizedBox(height: 24),
            Text(
              '주사 부위',
              style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            InjectionSiteSelectWidget(
              onSiteSelected: (site) {
                setState(() {
                  selectedSite = site;
                });
              },
            ),
            const SizedBox(height: 24),
            Text(
              '메모 (선택사항)',
              style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: noteController,
              hintText: '메모를 입력하세요',
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        AppButton(
          text: '취소',
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          type: AppButtonType.ghost,
          isFullWidth: false,
        ),
        AppButton(
          text: '저장',
          onPressed: isLoading || selectedSite == null
              ? null
              : () => _saveDoseRecord(),
          isLoading: isLoading,
          type: AppButtonType.primary,
          isFullWidth: false,
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
