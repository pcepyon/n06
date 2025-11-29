import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/tracking/domain/value_objects/missed_dose_guidance.dart';
import 'package:n06/features/tracking/presentation/dialogs/dose_record_dialog_v2.dart';
import 'package:n06/features/tracking/presentation/dialogs/off_schedule_dose_dialog.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';
import 'package:n06/core/presentation/widgets/status_badge.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

class SelectedDateDetailCard extends ConsumerWidget {
  final DateTime selectedDate;
  final DoseSchedule? schedule;
  final DoseRecord? record;
  final List<DoseRecord> recentRecords;
  final List<DoseSchedule> allSchedules;
  final List<DoseRecord> allRecords;

  const SelectedDateDetailCard({
    required this.selectedDate,
    required this.schedule,
    required this.record,
    required this.recentRecords,
    required this.allSchedules,
    required this.allRecords,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 이 날짜에 기록된 투여가 있는지 확인 (스케줄 없이 임의 투여된 경우)
    final recordOnThisDate = _getRecordOnDate(selectedDate);

    // 스케줄이 없는 날
    if (schedule == null) {
      // 하지만 이 날짜에 투여 기록이 있는 경우 (임의 투여)
      if (recordOnThisDate != null) {
        return _buildRecordedOnDateCard(context, recordOnThisDate);
      }

      // 미래 날짜는 투여 불가
      final today = DateTime.now();
      final isInFuture = selectedDate.isAfter(DateTime(today.year, today.month, today.day));

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
                '${selectedDate.month}월 ${selectedDate.day}일 (${_getWeekday(selectedDate)})',
                style: AppTypography.heading2,
              ),
              const SizedBox(height: 8),
              Text(
                '투여 예정이 없는 날입니다',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              if (!isInFuture && _canRecordOffSchedule()) ...[
                const SizedBox(height: 16),
                _buildOffScheduleInfo(context),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: GabiumButton(
                    text: '이 날짜에 투여 기록하기',
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜
            Text(
              '${selectedDate.month}월 ${selectedDate.day}일 (${_getWeekday(selectedDate)})',
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
                  type: _guidanceToStatusType(guidance),
                  text: guidance.title,
                  icon: _guidanceToIcon(guidance.type),
                ),
              ],
            ),

            if (guidance.description.isNotEmpty) ...[
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
            const Text(
              '최근 주사 부위 (7일 이내)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 12),
            ..._buildInjectionSiteHistory(),

            const SizedBox(height: 24),

            // 액션 버튼
            SizedBox(
              width: double.infinity,
              child: _buildActionButton(context, guidance),
            ),
          ],
        ),
      ),
    );
  }

  String _getWeekday(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
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

  List<Widget> _buildInjectionSiteHistory() {
    final within7Days = recentRecords.where((r) {
      final daysAgo = DateTime.now().difference(r.administeredAt).inDays;
      return daysAgo <= 7 && r.injectionSite != null;
    }).toList();

    if (within7Days.isEmpty) {
      return [
        const Text(
          '최근 7일 이내 기록 없음',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF94A3B8),
          ),
        ),
      ];
    }

    return within7Days.map((r) {
      final daysAgo = DateTime.now().difference(r.administeredAt).inDays;
      final siteLabel = getInjectionSiteLabel(r.injectionSite!);
      final dateLabel = '${r.administeredAt.month}/${r.administeredAt.day}';

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
              '$siteLabel ($dateLabel, $daysAgo일 전)',
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

    if (!guidance.canAdminister && !isCompleted) {
      return GabiumButton(
        text: '투여 불가 (5일 이상 경과)',
        onPressed: null,
        variant: GabiumButtonVariant.secondary,
        size: GabiumButtonSize.medium,
      );
    }

    return GabiumButton(
      text: isCompleted ? '기록 수정' : '✓ 투여 완료 기록하기',
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
    final actualDateStr =
        '${actualDate.month}/${actualDate.day}(${_getWeekday(actualDate)})';

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
              '${selectedDate.month}월 ${selectedDate.day}일 (${_getWeekday(selectedDate)})',
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
                  text: '투여 완료',
                  icon: Icons.check_circle,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 다른 날짜에 투여됨 안내
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
                        isEarly ? Icons.fast_forward : Icons.history,
                        size: 16,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isEarly
                              ? '$actualDateStr에 조기 투여됨 (${daysDiff.abs()}일 전)'
                              : '$actualDateStr에 지연 투여됨 (${daysDiff.abs()}일 후)',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.info,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (completedRecord.injectionSite != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '주사 부위: ${getInjectionSiteLabel(completedRecord.injectionSite!)}',
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
    incompleteSchedules.sort((a, b) {
      final diffA = (a.scheduledDate.difference(selectedDate).inDays).abs();
      final diffB = (b.scheduledDate.difference(selectedDate).inDays).abs();
      return diffA.compareTo(diffB);
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
                '⚠️ 마지막 투여로부터 48시간이 지나지 않았습니다\nGLP-1 약물은 최소 48시간 간격을 권장합니다',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
              ),
            ),
          ],
        ),
      );
    }

    final daysDiff = nearestSchedule.scheduledDate.difference(selectedDate).inDays;
    final scheduleDate = nearestSchedule.scheduledDate;
    final dateStr = '${scheduleDate.month}/${scheduleDate.day}(${_getWeekday(scheduleDate)})';

    String message;
    Color messageColor;

    if (daysDiff > 0) {
      // 선택한 날짜가 예정일보다 이전 (조기 투여)
      if (daysDiff <= 2) {
        message = '📅 $dateStr 예정 투여를 조기 기록합니다';
        messageColor = AppColors.info;
      } else {
        message = '⚠️ $dateStr 예정보다 $daysDiff일 빠릅니다\n최대 2일 전까지 조기 투여를 권장합니다';
        messageColor = AppColors.warning;
      }
    } else if (daysDiff < 0) {
      // 선택한 날짜가 예정일보다 이후 (지연 투여)
      final daysLate = -daysDiff;
      if (daysLate <= 5) {
        message = '📅 $dateStr 예정 투여를 지연 기록합니다 ($daysLate일 지연)';
        messageColor = AppColors.warning;
      } else {
        message = '⚠️ $dateStr 예정보다 $daysLate일 지연되었습니다\n5일 초과 시 의사 상담을 권장합니다';
        messageColor = AppColors.error;
      }
    } else {
      message = '📅 오늘 예정된 투여입니다';
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
        const SnackBar(content: Text('연결할 수 있는 투여 예정이 없습니다')),
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
              '${selectedDate.month}월 ${selectedDate.day}일 (${_getWeekday(selectedDate)})',
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
                  text: '투여 완료',
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
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppColors.info),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '원래 예정: ${linkedSchedule.scheduledDate.month}/${linkedSchedule.scheduledDate.day}(${_getWeekday(linkedSchedule.scheduledDate)})',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.info,
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
                '주사 부위: ${getInjectionSiteLabel(recordOnDate.injectionSite!)}',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],

            // 메모
            if (recordOnDate.note != null && recordOnDate.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '메모: ${recordOnDate.note}',
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
}
