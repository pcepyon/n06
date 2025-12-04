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

class DoseRecordDialogV2 extends ConsumerStatefulWidget {
  final DoseSchedule schedule;
  final List<DoseRecord> recentRecords;
  final DateTime? selectedDate; // null이면 오늘 날짜 사용

  const DoseRecordDialogV2({
    required this.schedule,
    required this.recentRecords,
    this.selectedDate,
    super.key,
  });

  @override
  ConsumerState<DoseRecordDialogV2> createState() => _DoseRecordDialogV2State();
}

class _DoseRecordDialogV2State extends ConsumerState<DoseRecordDialogV2> {
  String? selectedSite;
  final noteController = TextEditingController();
  bool isLoading = false;

  /// 기록할 날짜 (selectedDate가 없으면 예정일 사용)
  DateTime get _recordDate =>
      widget.selectedDate ?? widget.schedule.scheduledDate;

  /// 오늘과 기록 날짜가 다른지 (과거 예정일인 경우)
  bool get _isRecordingPastDate {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final recordDateOnly = DateTime(
      _recordDate.year,
      _recordDate.month,
      _recordDate.day,
    );
    return recordDateOnly.isBefore(todayOnly);
  }

  String _getWeekday(BuildContext context, DateTime date) {
    final weekdayNames = [
      context.l10n.tracking_weekday_monday,
      context.l10n.tracking_weekday_tuesday,
      context.l10n.tracking_weekday_wednesday,
      context.l10n.tracking_weekday_thursday,
      context.l10n.tracking_weekday_friday,
      context.l10n.tracking_weekday_saturday,
      context.l10n.tracking_weekday_sunday,
    ];
    return weekdayNames[date.weekday - 1];
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                context.l10n.tracking_doseRecord_title,
                style: AppTypography.heading1.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),

              // 기록 날짜 표시
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.tracking_doseRecord_dateLabel(
                        _recordDate.month,
                        _recordDate.day,
                        _getWeekday(context, _recordDate),
                      ),
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // 과거 예정일 확인 안내
              if (_isRecordingPastDate) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: AppColors.info,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              context.l10n.tracking_doseRecord_pastDateQuestion,
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.info,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.tracking_doseRecord_pastDateInstructions,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // 콘텐츠
              Text(
                context.l10n.tracking_doseRecord_doseAmount(widget.schedule.scheduledDoseMg),
                style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              InjectionSiteSelectorV2(
                onSiteSelected: (site) {
                  setState(() {
                    selectedSite = site;
                  });
                },
                recentRecords: widget.recentRecords,
                referenceDate: _recordDate,
              ),

              const SizedBox(height: 16),
              Text(
                context.l10n.tracking_doseRecord_noteLabel,
                style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteController,
                style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: context.l10n.tracking_doseRecord_noteHint,
                  hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.textDisabled),
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
                      text: context.l10n.tracking_doseRecord_cancelButton,
                      onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                      variant: GabiumButtonVariant.secondary,
                      size: GabiumButtonSize.medium,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GabiumButton(
                      text: context.l10n.tracking_doseRecord_saveButton,
                      onPressed: isLoading || selectedSite == null
                          ? null
                          : _saveDoseRecord,
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

  // ✅ CORRECT: Presentation Layer에서 네비게이션/스낵바 처리
  Future<void> _saveDoseRecord() async {
    if (selectedSite == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.tracking_doseRecord_siteRequired)),
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
        throw Exception(context.l10n.tracking_doseRecord_noPlanError);
      }

      // 기록 날짜의 정오(12:00)로 설정
      final administeredAt = DateTime(
        _recordDate.year,
        _recordDate.month,
        _recordDate.day,
        12,
        0,
      );

      final doseRecord = DoseRecord(
        id: const Uuid().v4(),
        doseScheduleId: widget.schedule.id,
        dosagePlanId: state!.activePlan!.id,
        administeredAt: administeredAt,
        actualDoseMg: widget.schedule.scheduledDoseMg,
        injectionSite: selectedSite,
        note: noteController.text.isEmpty ? null : noteController.text,
      );

      // ✅ Application Layer: 저장만 수행
      await medicationNotifier.recordDose(doseRecord);

      // ✅ Presentation Layer: 저장 성공 후 네비게이션/스낵바
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.tracking_doseRecord_saveSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.tracking_doseRecord_saveError(e.toString()))),
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
