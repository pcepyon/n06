import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/tracking/domain/value_objects/missed_dose_guidance.dart';
import 'package:n06/features/tracking/presentation/dialogs/dose_record_dialog_v2.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';
import 'package:n06/core/presentation/widgets/status_badge.dart';

class SelectedDateDetailCard extends ConsumerWidget {
  final DateTime selectedDate;
  final DoseSchedule? schedule;
  final DoseRecord? record;
  final List<DoseRecord> recentRecords;

  const SelectedDateDetailCard({
    required this.selectedDate,
    required this.schedule,
    required this.record,
    required this.recentRecords,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (schedule == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.event_busy_outlined,
                size: 48,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(height: 16),
              Text(
                '${selectedDate.month}월 ${selectedDate.day}일',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '투여 예정이 없는 날입니다',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isCompleted = record != null;
    final guidance = MissedDoseGuidance.fromSchedule(
      schedule: schedule!,
      isCompleted: isCompleted,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜
            Text(
              '${selectedDate.month}월 ${selectedDate.day}일 (${_getWeekday(selectedDate)})',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
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
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
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
}
