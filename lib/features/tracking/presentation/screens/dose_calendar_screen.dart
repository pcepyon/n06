import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:n06/features/tracking/application/notifiers/medication_notifier.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/tracking/domain/value_objects/missed_dose_guidance.dart';
import 'package:n06/features/tracking/presentation/widgets/selected_date_detail_card.dart';
import 'package:n06/core/presentation/widgets/empty_state_widget.dart';

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
                    color: const Color(0x4DFB923C), // 30% opacity
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFF4ADE80),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Color(0xFF4ADE80),
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
                  child: SelectedDateDetailCard(
                    selectedDate: _selectedDay,
                    schedule: _getScheduleForDay(_selectedDay, schedules),
                    record: _getRecordForDay(_selectedDay, records),
                    recentRecords: _getRecentRecords(records, 30),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4ADE80)),
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

    final isCompleted = _getRecordForDay(day, records) != null;
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

  DoseRecord? _getRecordForDay(DateTime day, List<DoseRecord> records) {
    return records.cast<DoseRecord?>().firstWhere(
      (r) => r != null &&
          r.administeredAt.year == day.year &&
          r.administeredAt.month == day.month &&
          r.administeredAt.day == day.day,
      orElse: () => null,
    );
  }

  List<DoseRecord> _getRecentRecords(List<DoseRecord> records, int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return records.where((r) => r.administeredAt.isAfter(cutoff)).toList()
      ..sort((a, b) => b.administeredAt.compareTo(a.administeredAt));
  }
}
