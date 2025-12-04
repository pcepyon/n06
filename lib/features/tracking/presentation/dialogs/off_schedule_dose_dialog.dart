import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/tracking/application/notifiers/medication_notifier.dart';
import 'package:n06/features/tracking/presentation/widgets/injection_site_selector_v2.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/core/extensions/l10n_extension.dart';

/// 예정 외 날짜에 투여를 기록하는 다이얼로그
/// 가장 가까운 미완료 스케줄에 연결하여 기록합니다.
class OffScheduleDoseDialog extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final DoseSchedule schedule;
  final List<DoseRecord> recentRecords;

  const OffScheduleDoseDialog({
    required this.selectedDate,
    required this.schedule,
    required this.recentRecords,
    super.key,
  });

  @override
  ConsumerState<OffScheduleDoseDialog> createState() =>
      _OffScheduleDoseDialogState();
}

class _OffScheduleDoseDialogState extends ConsumerState<OffScheduleDoseDialog> {
  String? selectedSite;
  final noteController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  String _getWeekday(BuildContext context, DateTime date) {
    final l10n = context.l10n;
    final weekdays = [
      l10n.tracking_weekday_mon,
      l10n.tracking_weekday_tue,
      l10n.tracking_weekday_wed,
      l10n.tracking_weekday_thu,
      l10n.tracking_weekday_fri,
      l10n.tracking_weekday_sat,
      l10n.tracking_weekday_sun,
    ];
    return weekdays[date.weekday - 1];
  }

  int get _daysDiff =>
      widget.schedule.scheduledDate.difference(widget.selectedDate).inDays;

  bool get _isEarlyDose => _daysDiff > 0;
  bool get _isLateDose => _daysDiff < 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheduleDate = widget.schedule.scheduledDate;
    final scheduleDateStr =
        '${scheduleDate.month}/${scheduleDate.day}(${_getWeekday(context, scheduleDate)})';
    final selectedDateStr =
        '${widget.selectedDate.month}/${widget.selectedDate.day}(${_getWeekday(context, widget.selectedDate)})';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              Text(
                l10n.tracking_offSchedule_title,
                style: AppTypography.heading1.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 24),

              // 날짜 안내
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isLateDose
                      ? AppColors.warning.withValues(alpha: 0.1)
                      : _isEarlyDose
                          ? AppColors.info.withValues(alpha: 0.1)
                          : AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isLateDose
                        ? AppColors.warning.withValues(alpha: 0.3)
                        : _isEarlyDose
                            ? AppColors.info.withValues(alpha: 0.3)
                            : AppColors.borderDark,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isLateDose
                              ? Icons.history
                              : _isEarlyDose
                                  ? Icons.fast_forward
                                  : Icons.today,
                          size: 20,
                          color: _isLateDose
                              ? AppColors.warning
                              : _isEarlyDose
                                  ? AppColors.info
                                  : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _isLateDose
                                ? l10n.tracking_offSchedule_delayedDose(-_daysDiff)
                                : _isEarlyDose
                                    ? l10n.tracking_offSchedule_earlyDose(_daysDiff)
                                    : l10n.tracking_offSchedule_regularDose,
                            style: AppTypography.labelMedium.copyWith(
                              color: _isLateDose
                                  ? AppColors.warning
                                  : _isEarlyDose
                                      ? AppColors.info
                                      : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.tracking_offSchedule_originalSchedule(scheduleDateStr),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    Text(
                      l10n.tracking_offSchedule_recordDate(selectedDateStr),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Text(
                l10n.tracking_offSchedule_doseInfo(widget.schedule.scheduledDoseMg),
                style:
                    AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              InjectionSiteSelectorV2(
                onSiteSelected: (site) {
                  setState(() {
                    selectedSite = site;
                  });
                },
                recentRecords: widget.recentRecords,
                referenceDate: widget.selectedDate,
              ),

              const SizedBox(height: 16),
              Text(
                l10n.tracking_offSchedule_memoLabel,
                style: AppTypography.labelMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteController,
                style:
                    AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: l10n.tracking_offSchedule_memoHint,
                  hintStyle: AppTypography.bodyLarge
                      .copyWith(color: AppColors.textDisabled),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.borderDark,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
                maxLines: 3,
                maxLength: 100,
              ),
              const SizedBox(height: 24),

              // 액션 버튼
              Row(
                children: [
                  Expanded(
                    child: GabiumButton(
                      text: l10n.common_button_cancel,
                      onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                      variant: GabiumButtonVariant.secondary,
                      size: GabiumButtonSize.medium,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GabiumButton(
                      text: l10n.common_button_save,
                      onPressed:
                          isLoading || selectedSite == null ? null : _saveDoseRecord,
                      variant: GabiumButtonVariant.primary,
                      size: GabiumButtonSize.medium,
                      isLoading: isLoading,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveDoseRecord() async {
    if (selectedSite == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.tracking_offSchedule_errorSiteRequired)),
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
        throw Exception(context.l10n.tracking_offSchedule_errorNoPlan);
      }

      // 선택한 날짜의 정오(12:00)로 설정 (과거 날짜 일관성 유지)
      final administeredAt = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        12,
        0,
      );

      final doseRecord = DoseRecord(
        id: const Uuid().v4(),
        doseScheduleId: widget.schedule.id, // 가장 가까운 스케줄에 연결
        dosagePlanId: state!.activePlan!.id,
        administeredAt: administeredAt,
        actualDoseMg: widget.schedule.scheduledDoseMg,
        injectionSite: selectedSite,
        note: noteController.text.isEmpty ? null : noteController.text,
      );

      await medicationNotifier.recordDose(doseRecord);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.tracking_offSchedule_saveSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.tracking_offSchedule_saveFailed(e.toString()))),
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
