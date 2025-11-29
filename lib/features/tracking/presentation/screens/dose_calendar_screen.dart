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

class DoseCalendarScreen extends ConsumerStatefulWidget {
  const DoseCalendarScreen({super.key});

  @override
  ConsumerState<DoseCalendarScreen> createState() => _DoseCalendarScreenState();
}

class _DoseCalendarScreenState extends ConsumerState<DoseCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final medicationState = ref.watch(medicationNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('투여 스케줄'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
            tooltip: '오늘',
          ),
        ],
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
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                eventLoader: (day) {
                  return _getEventsForDay(day, schedules, records);
                },
              ),

              const Divider(height: 1),

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
              Text('오류가 발생했습니다: $error'),
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
    final schedule = _getScheduleForDay(day, schedules);
    if (schedule == null) return [];

    final isCompleted = _getRecordForSchedule(schedule, records) != null;
    final guidance = MissedDoseGuidance.fromSchedule(
      schedule: schedule,
      isCompleted: isCompleted,
    );

    return [guidance.type.name];
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
