import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/tracking/application/notifiers/medication_notifier.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/tracking/domain/value_objects/missed_dose_guidance.dart';
import 'package:n06/features/tracking/presentation/dialogs/dose_record_dialog_v2.dart';
import 'package:n06/features/tracking/presentation/dialogs/off_schedule_dose_dialog.dart';
import 'package:n06/features/tracking/presentation/dialogs/restart_schedule_dialog.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';
import 'package:n06/core/presentation/widgets/status_badge.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/core/extensions/l10n_extension.dart';

class SelectedDateDetailCard extends ConsumerWidget {
  final DateTime selectedDate;
  final DoseSchedule? schedule;
  final DoseRecord? record;
  final List<DoseRecord> recentRecords;
  final List<DoseSchedule> allSchedules;
  final List<DoseRecord> allRecords;
  final bool isPastRecordMode;
  final VoidCallback? onEnterPastRecordMode;
  final VoidCallback? onExitPastRecordMode;

  const SelectedDateDetailCard({
    required this.selectedDate,
    required this.schedule,
    required this.record,
    required this.recentRecords,
    required this.allSchedules,
    required this.allRecords,
    this.isPastRecordMode = false,
    this.onEnterPastRecordMode,
    this.onExitPastRecordMode,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final selectedDateOnly = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final isInFuture = selectedDateOnly.isAfter(todayOnly);
    final isInPast = selectedDateOnly.isBefore(todayOnly);

    // 2주 이상 공백 체크 (과거 기록 입력 모드에서는 스킵)
    if (!isPastRecordMode) {
      final longBreakInfo = _checkLongBreak();
      if (longBreakInfo != null) {
        return _buildLongBreakCard(context, longBreakInfo);
      }
    }

    // 이 날짜에 기록된 투여가 있는지 확인 (스케줄 없이 임의 투여된 경우)
    final recordOnThisDate = _getRecordOnDate(selectedDate);

    // 스케줄이 없는 날
    if (schedule == null) {
      // 하지만 이 날짜에 투여 기록이 있는 경우 (임의 투여)
      if (recordOnThisDate != null) {
        return _buildRecordedOnDateCard(context, recordOnThisDate);
      }

      // 미래 비예정일: 기록 불가 안내
      if (isInFuture) {
        return _buildFutureNonScheduledCard(context);
      }

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.event_busy_outlined,
                size: 48,
                color: AppColors.textDisabled,
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.tracking_dateDetail_dateMonthDay(
                  selectedDate.month,
                  selectedDate.day,
                  _getWeekday(context, selectedDate),
                ),
                style: AppTypography.heading2,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.tracking_dateDetail_noScheduled,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              if (_canRecordOffSchedule()) ...[
                const SizedBox(height: 16),
                _buildOffScheduleInfo(context),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: GabiumButton(
                    text: context.l10n.tracking_dateDetail_recordOffSchedule,
                    onPressed: _isWithin48Hours()
                        ? null
                        : () => _showOffScheduleDialog(context),
                    variant: GabiumButtonVariant.secondary,
                    size: GabiumButtonSize.medium,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // 이 스케줄에 연결된 기록 찾기 (다른 날짜에 투여됐을 수 있음)
    final recordForSchedule = _getRecordForSchedule(schedule!);
    final isCompletedOnDifferentDay =
        recordForSchedule != null && record == null;

    final isCompleted = record != null || recordForSchedule != null;
    final guidance = MissedDoseGuidance.fromSchedule(
      schedule: schedule!,
      isCompleted: isCompleted,
    );

    // 다른 날짜에 투여 완료된 경우 특별 UI
    if (isCompletedOnDifferentDay) {
      return _buildCompletedOnDifferentDayCard(
        context,
        recordForSchedule,
      );
    }

    // 미래 예정일: 기록 불가, 조기 투여 안내
    if (isInFuture && !isCompleted) {
      return _buildFutureScheduledCard(context, guidance);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜
            Text(
              context.l10n.tracking_dateDetail_dateMonthDay(
                selectedDate.month,
                selectedDate.day,
                _getWeekday(context, selectedDate),
              ),
              style: AppTypography.heading2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // 투여 정보
            Row(
              children: [
                const Text(
                  '💉 ',
                  style: TextStyle(fontSize: 24),
                ),
                Text(
                  '${schedule!.scheduledDoseMg} mg',
                  style: AppTypography.display.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                // 과거 날짜 + 미완료 → "과거 기록" 표시
                if (isInPast && !isCompleted)
                  StatusBadge(
                    type: StatusBadgeType.info,
                    text: context.l10n.tracking_dateDetail_pastRecord,
                    icon: Icons.history,
                  )
                else
                  StatusBadge(
                    type: _guidanceToStatusType(guidance),
                    text: guidance.title,
                    icon: _guidanceToIcon(guidance.type),
                  ),
              ],
            ),

            // 과거 날짜 + 미완료 → 안내 메시지
            if (isInPast && !isCompleted) ...[
              const SizedBox(height: 8),
              Text(
                context.l10n.tracking_dateDetail_pastRecordPrompt,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.info,
                ),
              ),
            ] else if (guidance.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                guidance.description,
                style: TextStyle(
                  fontSize: 14,
                  color: _getDescriptionColor(guidance.type),
                ),
              ),
            ],

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // 주사 부위 이력
            Text(
              context.l10n.tracking_dateDetail_recentSiteHistory,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 12),
            ..._buildInjectionSiteHistory(context),

            const SizedBox(height: 24),

            // 액션 버튼
            SizedBox(
              width: double.infinity,
              child: _buildActionButton(context, guidance),
            ),

            // 삭제 버튼 (미완료 스케줄만)
            if (_canDeleteSchedule(guidance, record)) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _showDeleteConfirmationDialog(context, ref),
                  icon: Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                  label: Text(
                    context.l10n.tracking_dateDetail_deleteSchedule,
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 스케줄 삭제 가능 여부 확인
  bool _canDeleteSchedule(MissedDoseGuidance guidance, DoseRecord? record) {
    if (schedule == null) return false;
    if (record != null) return false; // 기록이 있으면 삭제 불가

    // 연체 또는 미래 예정만 삭제 가능 (오늘은 제외)
    return guidance.type == MissedDoseGuidanceType.missedWithin5Days ||
        guidance.type == MissedDoseGuidanceType.missedOver5Days ||
        guidance.type == MissedDoseGuidanceType.upcoming;
  }

  /// 삭제 확인 다이얼로그
  Future<void> _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.tracking_dateDetail_deleteConfirmTitle,
                style: AppTypography.heading2,
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.tracking_dateDetail_deleteConfirmMessage(
                  selectedDate.month,
                  selectedDate.day,
                  _getWeekday(context, selectedDate),
                  schedule!.scheduledDoseMg,
                ),
                style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.l10n.tracking_dateDetail_deleteWarning,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.warning),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GabiumButton(
                      text: context.l10n.common_button_cancel,
                      onPressed: () => Navigator.of(context).pop(false),
                      variant: GabiumButtonVariant.secondary,
                      size: GabiumButtonSize.medium,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GabiumButton(
                      text: context.l10n.common_button_delete,
                      onPressed: () => Navigator.of(context).pop(true),
                      variant: GabiumButtonVariant.danger,
                      size: GabiumButtonSize.medium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(medicationNotifierProvider.notifier).deleteDoseSchedule(schedule!.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.tracking_dateDetail_deleteSuccess)),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.tracking_dateDetail_deleteFailed(e.toString()))),
          );
        }
      }
    }
  }

  String _getWeekday(BuildContext context, DateTime date) {
    final weekdays = [
      context.l10n.tracking_dateDetail_weekdayMon,
      context.l10n.tracking_dateDetail_weekdayTue,
      context.l10n.tracking_dateDetail_weekdayWed,
      context.l10n.tracking_dateDetail_weekdayThu,
      context.l10n.tracking_dateDetail_weekdayFri,
      context.l10n.tracking_dateDetail_weekdaySat,
      context.l10n.tracking_dateDetail_weekdaySun,
    ];
    return weekdays[date.weekday - 1];
  }

  StatusBadgeType _guidanceToStatusType(MissedDoseGuidance guidance) {
    switch (guidance.type) {
      case MissedDoseGuidanceType.completed:
        return StatusBadgeType.success;
      case MissedDoseGuidanceType.today:
        return StatusBadgeType.warning;
      case MissedDoseGuidanceType.upcoming:
        return StatusBadgeType.info;
      case MissedDoseGuidanceType.missedWithin5Days:
        return StatusBadgeType.warning;
      case MissedDoseGuidanceType.missedOver5Days:
        return StatusBadgeType.error;
    }
  }

  IconData _guidanceToIcon(MissedDoseGuidanceType type) {
    switch (type) {
      case MissedDoseGuidanceType.completed:
        return Icons.check_circle;
      case MissedDoseGuidanceType.today:
        return Icons.flag;
      case MissedDoseGuidanceType.upcoming:
        return Icons.schedule;
      case MissedDoseGuidanceType.missedWithin5Days:
        return Icons.warning_amber;
      case MissedDoseGuidanceType.missedOver5Days:
        return Icons.block;
    }
  }

  Color _getDescriptionColor(MissedDoseGuidanceType type) {
    switch (type) {
      case MissedDoseGuidanceType.missedWithin5Days:
        return const Color(0xFF92400E); // Yellow-800
      case MissedDoseGuidanceType.missedOver5Days:
        return const Color(0xFF991B1B); // Red-800
      default:
        return const Color(0xFF334155); // Neutral-700
    }
  }

  List<Widget> _buildInjectionSiteHistory(BuildContext context) {
    // 과거 기록 입력 모드에서는 선택한 날짜 기준, 아니면 오늘 기준
    final referenceDate = isPastRecordMode ? selectedDate : DateTime.now();

    final within7Days = recentRecords.where((r) {
      final daysAgo = referenceDate.difference(r.administeredAt).inDays;
      return daysAgo >= 0 && daysAgo <= 7 && r.injectionSite != null;
    }).toList();

    if (within7Days.isEmpty) {
      return [
        Text(
          context.l10n.tracking_dateDetail_noRecentHistory,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF94A3B8),
          ),
        ),
      ];
    }

    return within7Days.map((r) {
      final daysAgo = referenceDate.difference(r.administeredAt).inDays;
      final siteLabel = getInjectionSiteLabel(r.injectionSite!);
      final dateLabel = '${r.administeredAt.month}/${r.administeredAt.day}';
      final daysAgoLabel = context.l10n.tracking_dateDetail_daysAgo(daysAgo);

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            const Icon(
              Icons.circle,
              size: 8,
              color: Color(0xFF4ADE80),
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.tracking_dateDetail_siteHistoryItem(
                siteLabel,
                dateLabel,
                daysAgoLabel,
              ),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildActionButton(BuildContext context, MissedDoseGuidance guidance) {
    final isCompleted = record != null;

    // 선택한 날짜가 과거인지 확인
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final selectedDateOnly = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final isRecordingPastDate = selectedDateOnly.isBefore(todayOnly);

    // 과거 날짜 선택 시 또는 과거 기록 입력 모드에서는 제한 무시
    // (연체 제한은 "오늘 투여"할 때만 적용)
    if (!guidance.canAdminister && !isCompleted && !isPastRecordMode && !isRecordingPastDate) {
      return GabiumButton(
        text: context.l10n.tracking_dateDetail_cannotAdminister,
        onPressed: null,
        variant: GabiumButtonVariant.secondary,
        size: GabiumButtonSize.medium,
      );
    }

    return GabiumButton(
      text: isCompleted ? context.l10n.tracking_dateDetail_recordModify : context.l10n.tracking_dateDetail_recordComplete,
      onPressed: () => _showRecordDialog(context),
      variant: GabiumButtonVariant.primary,
      size: GabiumButtonSize.medium,
    );
  }

  void _showRecordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DoseRecordDialogV2(
        schedule: schedule!,
        recentRecords: recentRecords,
        selectedDate: selectedDate,
      ),
    );
  }

  /// 선택한 날짜에 기록된 투여 찾기 (administeredAt 기준)
  DoseRecord? _getRecordOnDate(DateTime date) {
    return allRecords.cast<DoseRecord?>().firstWhere(
      (r) =>
          r != null &&
          r.administeredAt.year == date.year &&
          r.administeredAt.month == date.month &&
          r.administeredAt.day == date.day,
      orElse: () => null,
    );
  }

  /// 스케줄에 연결된 기록 찾기
  DoseRecord? _getRecordForSchedule(DoseSchedule schedule) {
    return allRecords.cast<DoseRecord?>().firstWhere(
      (r) => r != null && r.doseScheduleId == schedule.id,
      orElse: () => null,
    );
  }

  /// 원래 예정일이지만 다른 날짜에 투여 완료된 경우 카드
  Widget _buildCompletedOnDifferentDayCard(
    BuildContext context,
    DoseRecord completedRecord,
  ) {
    final actualDate = completedRecord.administeredAt;
    final actualDateStr = context.l10n.tracking_dateDetail_shortDateFormat(
      actualDate.month,
      actualDate.day,
      _getWeekday(context, actualDate),
    );

    final daysDiff = schedule!.scheduledDate.difference(actualDate).inDays;
    final isEarly = daysDiff > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜
            Text(
              context.l10n.tracking_dateDetail_dateMonthDay(
                selectedDate.month,
                selectedDate.day,
                _getWeekday(context, selectedDate),
              ),
              style: AppTypography.heading2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // 투여 정보
            Row(
              children: [
                const Text('💉 ', style: TextStyle(fontSize: 24)),
                Text(
                  '${schedule!.scheduledDoseMg} mg',
                  style: AppTypography.display.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                StatusBadge(
                  type: StatusBadgeType.success,
                  text: context.l10n.tracking_dateDetail_doseCompleted,
                  icon: Icons.check_circle,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 다른 날짜에 투여됨 안내
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.education.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.education.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isEarly ? Icons.fast_forward : Icons.history,
                        size: 16,
                        color: AppColors.education,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isEarly
                              ? context.l10n.tracking_dateDetail_completedEarly(
                                  actualDateStr,
                                  daysDiff.abs(),
                                )
                              : context.l10n.tracking_dateDetail_completedLate(
                                  actualDateStr,
                                  daysDiff.abs(),
                                ),
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.education,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (completedRecord.injectionSite != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.tracking_dateDetail_injectionSite(
                        getInjectionSiteLabel(completedRecord.injectionSite!),
                      ),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 임의 투여 기록이 가능한지 확인
  bool _canRecordOffSchedule() {
    return _findNearestIncompleteSchedule() != null;
  }

  /// 가장 가까운 미완료 스케줄 찾기
  DoseSchedule? _findNearestIncompleteSchedule() {
    final completedScheduleIds = allRecords
        .where((r) => r.doseScheduleId != null)
        .map((r) => r.doseScheduleId)
        .toSet();

    final incompleteSchedules = allSchedules
        .where((s) => !completedScheduleIds.contains(s.id))
        .toList();

    if (incompleteSchedules.isEmpty) return null;

    // 선택한 날짜와 가장 가까운 스케줄 찾기
    // 같은 거리면 과거 스케줄 우선 (밀린 스케줄 먼저 처리)
    incompleteSchedules.sort((a, b) {
      final diffA = (a.scheduledDate.difference(selectedDate).inDays).abs();
      final diffB = (b.scheduledDate.difference(selectedDate).inDays).abs();
      if (diffA != diffB) {
        return diffA.compareTo(diffB);
      }
      // 같은 거리면 날짜 오름차순 (과거 우선)
      return a.scheduledDate.compareTo(b.scheduledDate);
    });

    return incompleteSchedules.first;
  }

  /// 마지막 투여로부터 48시간 이내인지 확인
  bool _isWithin48Hours() {
    if (allRecords.isEmpty) return false;

    // 가장 최근 투여 기록 찾기
    final sortedRecords = List<DoseRecord>.from(allRecords)
      ..sort((a, b) => b.administeredAt.compareTo(a.administeredAt));
    final lastRecord = sortedRecords.first;

    final hoursSinceLast =
        selectedDate.difference(lastRecord.administeredAt).inHours;
    return hoursSinceLast.abs() < 48;
  }

  /// 임의 투여 안내 위젯
  Widget _buildOffScheduleInfo(BuildContext context) {
    final nearestSchedule = _findNearestIncompleteSchedule();

    if (nearestSchedule == null) {
      return const SizedBox.shrink();
    }

    // 48시간 간격 검증
    final isWithin48Hours = _isWithin48Hours();
    if (isWithin48Hours) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber, size: 20, color: AppColors.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.l10n.tracking_dateDetail_within48HoursWarning,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
              ),
            ),
          ],
        ),
      );
    }

    final daysDiff = nearestSchedule.scheduledDate.difference(selectedDate).inDays;
    final scheduleDate = nearestSchedule.scheduledDate;
    final dateStr = context.l10n.tracking_dateDetail_shortDateFormat(
      scheduleDate.month,
      scheduleDate.day,
      _getWeekday(context, scheduleDate),
    );

    String message;
    Color messageColor;

    if (daysDiff > 0) {
      // 선택한 날짜가 예정일보다 이전 (조기 투여)
      if (daysDiff <= 2) {
        message = context.l10n.tracking_dateDetail_earlyDoseMessage(dateStr);
        messageColor = AppColors.education;
      } else {
        message = context.l10n.tracking_dateDetail_tooEarlyWarning(dateStr, daysDiff);
        messageColor = AppColors.warning;
      }
    } else if (daysDiff < 0) {
      // 선택한 날짜가 예정일보다 이후 (지연 투여)
      final daysLate = -daysDiff;
      if (daysLate <= 5) {
        message = context.l10n.tracking_dateDetail_lateDoseMessage(dateStr, daysLate);
        messageColor = AppColors.warning;
      } else {
        message = context.l10n.tracking_dateDetail_tooLateWarning(dateStr, daysLate);
        messageColor = AppColors.error;
      }
    } else {
      message = context.l10n.tracking_dateDetail_onTimeMessage;
      messageColor = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: messageColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: messageColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(color: messageColor),
            ),
          ),
        ],
      ),
    );
  }

  /// 임의 투여 다이얼로그 표시
  void _showOffScheduleDialog(BuildContext context) {
    final nearestSchedule = _findNearestIncompleteSchedule();

    if (nearestSchedule == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.tracking_dateDetail_offScheduleNoSchedule)),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => OffScheduleDoseDialog(
        selectedDate: selectedDate,
        schedule: nearestSchedule,
        recentRecords: recentRecords,
      ),
    );
  }

  /// 이 날짜에 투여된 기록 카드 (스케줄 없이 임의 투여된 경우)
  Widget _buildRecordedOnDateCard(BuildContext context, DoseRecord recordOnDate) {
    // 연결된 스케줄 찾기
    final linkedSchedule = recordOnDate.doseScheduleId != null
        ? allSchedules.cast<DoseSchedule?>().firstWhere(
              (s) => s?.id == recordOnDate.doseScheduleId,
              orElse: () => null,
            )
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜
            Text(
              context.l10n.tracking_dateDetail_dateMonthDay(
                selectedDate.month,
                selectedDate.day,
                _getWeekday(context, selectedDate),
              ),
              style: AppTypography.heading2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // 투여 정보
            Row(
              children: [
                const Text('💉 ', style: TextStyle(fontSize: 24)),
                Text(
                  '${recordOnDate.actualDoseMg} mg',
                  style: AppTypography.display.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                StatusBadge(
                  type: StatusBadgeType.success,
                  text: context.l10n.tracking_dateDetail_doseCompleted,
                  icon: Icons.check_circle,
                ),
              ],
            ),

            // 원래 예정일 안내
            if (linkedSchedule != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.education.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppColors.education),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.l10n.tracking_dateDetail_originalSchedule(
                          context.l10n.tracking_dateDetail_shortDateFormat(
                            linkedSchedule.scheduledDate.month,
                            linkedSchedule.scheduledDate.day,
                            _getWeekday(context, linkedSchedule.scheduledDate),
                          ),
                        ),
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.education,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 주사 부위
            if (recordOnDate.injectionSite != null) ...[
              const SizedBox(height: 16),
              Text(
                context.l10n.tracking_dateDetail_injectionSite(
                  getInjectionSiteLabel(recordOnDate.injectionSite!),
                ),
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],

            // 메모
            if (recordOnDate.note != null && recordOnDate.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                context.l10n.tracking_dateDetail_note(recordOnDate.note!),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 2주 이상 공백 체크
  /// 반환: (마지막 기록, 건너뛴 스케줄 목록) 또는 null
  ({DoseRecord? lastRecord, List<DoseSchedule> skippedSchedules})? _checkLongBreak() {
    if (allRecords.isEmpty && allSchedules.isEmpty) return null;

    // 완료된 스케줄 ID 목록
    final completedScheduleIds = allRecords
        .where((r) => r.doseScheduleId != null)
        .map((r) => r.doseScheduleId)
        .toSet();

    // 미완료 과거 스케줄 찾기
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    final incompleteOverdueSchedules = allSchedules
        .where((s) {
          final scheduleDate = DateTime(
            s.scheduledDate.year,
            s.scheduledDate.month,
            s.scheduledDate.day,
          );
          return scheduleDate.isBefore(todayOnly) &&
              !completedScheduleIds.contains(s.id);
        })
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    if (incompleteOverdueSchedules.isEmpty) return null;

    // 마지막 투여 기록
    DoseRecord? lastRecord;
    if (allRecords.isNotEmpty) {
      final sortedRecords = List<DoseRecord>.from(allRecords)
        ..sort((a, b) => b.administeredAt.compareTo(a.administeredAt));
      lastRecord = sortedRecords.first;
    }

    // 가장 오래된 미완료 스케줄의 지연일 계산
    // (마지막 투여 이후 첫 번째 미완료 스케줄이 14일 이상 지연되었는지)
    final oldestIncompleteSchedule = incompleteOverdueSchedules.first;
    final oldestScheduleDate = DateTime(
      oldestIncompleteSchedule.scheduledDate.year,
      oldestIncompleteSchedule.scheduledDate.month,
      oldestIncompleteSchedule.scheduledDate.day,
    );
    final daysOverdueForOldest = todayOnly.difference(oldestScheduleDate).inDays;

    // 2주(14일) 이상 지연된 미완료 스케줄이 있으면 재시작 모드
    if (daysOverdueForOldest >= 14) {
      return (
        lastRecord: lastRecord,
        skippedSchedules: incompleteOverdueSchedules,
      );
    }

    return null;
  }

  /// 2주 이상 공백 카드
  Widget _buildLongBreakCard(
    BuildContext context,
    ({DoseRecord? lastRecord, List<DoseSchedule> skippedSchedules}) info,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.schedule,
                size: 48,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.tracking_dateDetail_longBreakTitle,
              style: AppTypography.heading2.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.tracking_dateDetail_longBreakMessage(info.skippedSchedules.length),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 18,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.tracking_dateDetail_longBreakConsultation,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: GabiumButton(
                text: context.l10n.tracking_dateDetail_enterPastRecordMode,
                onPressed: onEnterPastRecordMode,
                variant: GabiumButtonVariant.secondary,
                size: GabiumButtonSize.medium,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: GabiumButton(
                text: context.l10n.tracking_dateDetail_restartSchedule,
                onPressed: () => _showRestartDialog(context, info),
                variant: GabiumButtonVariant.primary,
                size: GabiumButtonSize.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 재시작 다이얼로그 표시
  void _showRestartDialog(
    BuildContext context,
    ({DoseRecord? lastRecord, List<DoseSchedule> skippedSchedules}) info,
  ) {
    showDialog(
      context: context,
      builder: (context) => RestartScheduleDialog(
        lastRecord: info.lastRecord,
        skippedSchedules: info.skippedSchedules,
      ),
    );
  }

  /// 미래 비예정일 카드
  Widget _buildFutureNonScheduledCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 48,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.tracking_dateDetail_dateMonthDay(
                selectedDate.month,
                selectedDate.day,
                _getWeekday(context, selectedDate),
              ),
              style: AppTypography.heading2,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.tracking_dateDetail_noScheduled,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.tracking_dateDetail_futureCannotRecord,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 미래 예정일 카드 (기록 불가, 조기 투여 안내)
  Widget _buildFutureScheduledCard(
    BuildContext context,
    MissedDoseGuidance guidance,
  ) {
    final today = DateTime.now();
    final daysUntil = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    ).difference(DateTime(today.year, today.month, today.day)).inDays;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜
            Text(
              context.l10n.tracking_dateDetail_dateMonthDay(
                selectedDate.month,
                selectedDate.day,
                _getWeekday(context, selectedDate),
              ),
              style: AppTypography.heading2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // 투여 정보
            Row(
              children: [
                const Text(
                  '💉 ',
                  style: TextStyle(fontSize: 24),
                ),
                Text(
                  '${schedule!.scheduledDoseMg} mg',
                  style: AppTypography.display.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                StatusBadge(
                  type: StatusBadgeType.info,
                  text: context.l10n.tracking_dateDetail_daysUntil(daysUntil),
                  icon: Icons.schedule,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 미래 날짜 기록 불가 안내
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
                          context.l10n.tracking_dateDetail_futureCannotRecord,
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
                    context.l10n.tracking_dateDetail_earlyDoseInfo,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
