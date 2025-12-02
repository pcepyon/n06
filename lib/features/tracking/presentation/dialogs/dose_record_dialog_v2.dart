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

  String _getWeekday(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[date.weekday - 1];
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
                '투여 기록',
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
                      '${_recordDate.month}월 ${_recordDate.day}일 (${_getWeekday(_recordDate)})',
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
                              '이 날짜에 실제로 투여하셨나요?',
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
                        '• 예 → 아래에서 주사 부위를 선택하고 기록하세요\n'
                        '• 아니오 → 실제 투여한 날짜를 선택해서 기록하세요',
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
                '${widget.schedule.scheduledDoseMg} mg를 투여합니다.',
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
              ),

              const SizedBox(height: 16),
              Text(
                '메모 (선택사항)',
                style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteController,
                style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '메모를 입력하세요',
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
                      text: '취소',
                      onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                      variant: GabiumButtonVariant.secondary,
                      size: GabiumButtonSize.medium,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GabiumButton(
                      text: '저장',
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
