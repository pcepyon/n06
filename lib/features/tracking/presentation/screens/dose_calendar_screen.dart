import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:n06/features/tracking/application/notifiers/medication_notifier.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/tracking/domain/value_objects/missed_dose_guidance.dart';
import 'package:n06/features/tracking/presentation/widgets/selected_date_detail_card.dart';
import 'package:n06/core/presentation/widgets/empty_state_widget.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/extensions/l10n_extension.dart';

class DoseCalendarScreen extends ConsumerStatefulWidget {
  const DoseCalendarScreen({super.key});

  @override
  ConsumerState<DoseCalendarScreen> createState() => _DoseCalendarScreenState();
}

class _DoseCalendarScreenState extends ConsumerState<DoseCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  bool _isPastRecordMode = false;

  @override
  Widget build(BuildContext context) {
    final medicationState = ref.watch(medicationNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.tracking_calendar_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
            tooltip: context.l10n.tracking_calendar_todayButton,
          ),
        ],
      ),
      body: medicationState.when(
        data: (data) {
          if (data.activePlan == null) {
            return EmptyStateWidget(
              icon: Icons.assignment_outlined,
              title: context.l10n.tracking_calendar_noPlan,
              description: context.l10n.tracking_calendar_noPlanDescription,
            );
          }

          final schedules = data.schedules;
          final records = data.records;

          return Column(
            children: [
              // 캘린더
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarFormat: CalendarFormat.month,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: AppColors.achievement,
                    shape: BoxShape.circle,
                  ),
                ),
                eventLoader: (day) {
                  return _getEventsForDay(day, schedules, records);
                },
              ),

              const Divider(height: 1),

              // 과거 기록 입력 모드 배너
              if (_isPastRecordMode)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: AppColors.info.withValues(alpha: 0.1),
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_calendar,
                        size: 20,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.l10n.tracking_calendar_pastRecordMode,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.info,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => _isPastRecordMode = false);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          context.l10n.tracking_calendar_pastRecordModeComplete,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // 선택 날짜 상세 카드
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Builder(
                    builder: (context) {
                      final schedule = _getScheduleForDay(_selectedDay, schedules);
                      return SelectedDateDetailCard(
                        selectedDate: _selectedDay,
                        schedule: schedule,
                        record: _getRecordForSchedule(schedule, records),
                        recentRecords: _getRecentRecords(records, 30),
                        allSchedules: schedules,
                        allRecords: records,
                        isPastRecordMode: _isPastRecordMode,
                        onEnterPastRecordMode: () {
                          setState(() => _isPastRecordMode = true);
                        },
                        onExitPastRecordMode: () {
                          setState(() => _isPastRecordMode = false);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(context.l10n.tracking_calendar_error(error.toString())),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _getEventsForDay(
    DateTime day,
    List<DoseSchedule> schedules,
    List<DoseRecord> records,
  ) {
    // 1. 이 날짜에 실제 투여된 기록이 있는지 확인 (administeredAt 기준)
    final recordOnDay = _getRecordOnDate(day, records);

    if (recordOnDay != null) {
      // 이 날짜에 투여가 완료됨 -> 완료 마커 표시
      return [MissedDoseGuidanceType.completed.name];
    }

    // 2. 이 날짜에 예정된 스케줄 확인
    final schedule = _getScheduleForDay(day, schedules);
    if (schedule == null) return [];

    // 3. 해당 스케줄에 연결된 기록 확인 (다른 날짜에 투여됐을 수 있음)
    final recordForSchedule = _getRecordForSchedule(schedule, records);

    if (recordForSchedule != null) {
      // 이 스케줄은 다른 날짜에 투여됨 -> 원래 예정일에는 마커 없음
      // (실제 투여일에 마커가 표시됨)
      return [];
    }

    // 4. 미완료 스케줄 -> 상태에 따른 마커
    final guidance = MissedDoseGuidance.fromSchedule(
      schedule: schedule,
      isCompleted: false,
    );

    return [guidance.type.name];
  }

  /// 특정 날짜에 투여된 기록 찾기 (administeredAt 기준)
  DoseRecord? _getRecordOnDate(DateTime day, List<DoseRecord> records) {
    return records.cast<DoseRecord?>().firstWhere(
      (r) =>
          r != null &&
          r.administeredAt.year == day.year &&
          r.administeredAt.month == day.month &&
          r.administeredAt.day == day.day,
      orElse: () => null,
    );
  }

  DoseSchedule? _getScheduleForDay(DateTime day, List<DoseSchedule> schedules) {
    return schedules.cast<DoseSchedule?>().firstWhere(
      (s) => s != null &&
          s.scheduledDate.year == day.year &&
          s.scheduledDate.month == day.month &&
          s.scheduledDate.day == day.day,
      orElse: () => null,
    );
  }

  /// 스케줄에 해당하는 투여 기록을 찾습니다.
  /// doseScheduleId로 매칭하며, 없으면 administeredAt 날짜로 폴백합니다.
  DoseRecord? _getRecordForSchedule(DoseSchedule? schedule, List<DoseRecord> records) {
    if (schedule == null) return null;

    // 1차: doseScheduleId로 매칭 (정확한 매칭)
    final byScheduleId = records.cast<DoseRecord?>().firstWhere(
      (r) => r != null && r.doseScheduleId == schedule.id,
      orElse: () => null,
    );
    if (byScheduleId != null) return byScheduleId;

    // 2차: administeredAt 날짜로 폴백 (레거시 데이터 호환)
    return records.cast<DoseRecord?>().firstWhere(
      (r) => r != null &&
          r.administeredAt.year == schedule.scheduledDate.year &&
          r.administeredAt.month == schedule.scheduledDate.month &&
          r.administeredAt.day == schedule.scheduledDate.day,
      orElse: () => null,
    );
  }

  List<DoseRecord> _getRecentRecords(List<DoseRecord> records, int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return records.where((r) => r.administeredAt.isAfter(cutoff)).toList()
      ..sort((a, b) => b.administeredAt.compareTo(a.administeredAt));
  }
}
