import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

/// 투여 캘린더 체험용 데모 위젯
///
/// 더미 데이터로 투여 일정을 표시하며, Provider를 사용하지 않는 독립형 위젯입니다.
/// 게스트 홈에서 비로그인 사용자가 투여 캘린더 기능을 미리 체험할 수 있습니다.
class DoseCalendarDemo extends StatefulWidget {
  const DoseCalendarDemo({super.key});

  @override
  State<DoseCalendarDemo> createState() => _DoseCalendarDemoState();
}

class _DoseCalendarDemoState extends State<DoseCalendarDemo> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  // 더미 투여 일정 데이터
  late final Map<DateTime, DoseInfo> _demoDoseSchedule;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = now;
    _selectedDay = now;

    // 더미 데이터 초기화 (날짜의 시/분/초를 0으로 정규화)
    _demoDoseSchedule = {
      _normalizeDate(now.subtract(const Duration(days: 21))): const DoseInfo(
        dose: 0.25,
        completed: true,
        label: '0.25mg',
      ),
      _normalizeDate(now.subtract(const Duration(days: 14))): const DoseInfo(
        dose: 0.25,
        completed: true,
        label: '0.25mg',
      ),
      _normalizeDate(now.subtract(const Duration(days: 7))): const DoseInfo(
        dose: 0.5,
        completed: true,
        label: '0.5mg',
      ),
      _normalizeDate(now): const DoseInfo(
        dose: 0.5,
        completed: false,
        label: '0.5mg',
        isToday: true,
      ),
      _normalizeDate(now.add(const Duration(days: 7))): const DoseInfo(
        dose: 0.5,
        completed: false,
        label: '0.5mg',
      ),
      _normalizeDate(now.add(const Duration(days: 14))): const DoseInfo(
        dose: 1.0,
        completed: false,
        label: '1.0mg',
      ),
      _normalizeDate(now.add(const Duration(days: 21))): const DoseInfo(
        dose: 1.0,
        completed: false,
        label: '1.0mg',
      ),
    };
  }

  /// 날짜를 정규화 (시/분/초를 0으로)
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// 해당 날짜의 투여 정보 조회
  DoseInfo? _getDoseInfoForDay(DateTime day) {
    return _demoDoseSchedule[_normalizeDate(day)];
  }

  /// 다음 투여일 계산
  DateTime? _getNextDoseDate() {
    final now = _normalizeDate(DateTime.now());
    final futureDates =
        _demoDoseSchedule.keys.where((date) => date.isAfter(now)).toList()
          ..sort();
    return futureDates.isNotEmpty ? futureDates.first : null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 다음 투여일 안내
        _buildNextDoseInfo(),
        const SizedBox(height: 16),

        // 캘린더
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: CalendarFormat.month,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: AppTypography.heading3.copyWith(
                color: AppColors.textPrimary,
              ),
              leftChevronIcon: const Icon(
                Icons.chevron_left,
                color: AppColors.textSecondary,
              ),
              rightChevronIcon: const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ),
            calendarStyle: CalendarStyle(
              // 오늘 날짜 스타일
              todayDecoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.warning, width: 2),
              ),
              todayTextStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              // 선택된 날짜 스타일
              selectedDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: AppTypography.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              // 마커 스타일
              markerDecoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 1,
              // 기본 텍스트 스타일
              defaultTextStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              weekendTextStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.error,
              ),
              outsideTextStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.textDisabled,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
              weekendStyle: AppTypography.labelSmall.copyWith(
                color: AppColors.error,
              ),
            ),
            eventLoader: (day) {
              final doseInfo = _getDoseInfoForDay(day);
              // 투여 정보가 있고 완료된 경우에만 마커 표시
              return doseInfo != null && doseInfo.completed
                  ? ['completed']
                  : [];
            },
          ),
        ),

        const SizedBox(height: 16),

        // 선택된 날짜의 투여 정보
        _buildSelectedDateInfo(),
      ],
    );
  }

  Widget _buildNextDoseInfo() {
    final nextDose = _getNextDoseDate();
    if (nextDose == null) {
      return const SizedBox.shrink();
    }

    final doseInfo = _getDoseInfoForDay(nextDose);
    final daysUntil = nextDose
        .difference(_normalizeDate(DateTime.now()))
        .inDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '다음 투여일',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${nextDose.month}월 ${nextDose.day}일 (${daysUntil == 0 ? '오늘' : '$daysUntil일 후'})',
                  style: AppTypography.heading3.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                if (doseInfo != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '용량: ${doseInfo.label}',
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
    );
  }

  Widget _buildSelectedDateInfo() {
    final doseInfo = _getDoseInfoForDay(_selectedDay);

    if (doseInfo == null) {
      // 투여 예정이 없는 날
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.neutral50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.event_busy,
              color: AppColors.textTertiary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '이 날짜에는 투여 예정이 없습니다',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 투여 정보가 있는 날
    final isToday = doseInfo.isToday;
    final isPast = _selectedDay.isBefore(_normalizeDate(DateTime.now()));

    Color backgroundColor;
    Color borderColor;
    IconData icon;
    String statusText;
    Color statusColor;

    if (doseInfo.completed) {
      backgroundColor = AppColors.successBackground;
      borderColor = AppColors.success.withValues(alpha: 0.3);
      icon = Icons.check_circle;
      statusText = '투여 완료';
      statusColor = AppColors.success;
    } else if (isToday) {
      backgroundColor = AppColors.warningBackground;
      borderColor = AppColors.warning.withValues(alpha: 0.3);
      icon = Icons.access_time;
      statusText = '오늘 투여 예정';
      statusColor = AppColors.warning;
    } else if (isPast) {
      backgroundColor = AppColors.errorBackground;
      borderColor = AppColors.error.withValues(alpha: 0.3);
      icon = Icons.event_busy;
      statusText = '미투여';
      statusColor = AppColors.error;
    } else {
      backgroundColor = AppColors.infoBackground;
      borderColor = AppColors.info.withValues(alpha: 0.3);
      icon = Icons.event_available;
      statusText = '투여 예정';
      statusColor = AppColors.info;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜 헤더
          Row(
            children: [
              Icon(icon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Text(
                '${_selectedDay.year}년 ${_selectedDay.month}월 ${_selectedDay.day}일',
                style: AppTypography.heading3.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 투여 정보
          _buildInfoRow('상태', statusText, statusColor),
          const SizedBox(height: 8),
          _buildInfoRow('용량', doseInfo.label, AppColors.textPrimary),

          if (doseInfo.completed) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Text('✅', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '투여를 완료하셨군요! 꾸준한 관리가 좋은 결과를 만듭니다.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (isToday && !doseInfo.completed) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Text('⏰', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '오늘 투여 예정입니다. 정해진 시간에 투여하세요.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// 투여 정보 모델 (데모용)
class DoseInfo {
  final double dose;
  final bool completed;
  final String label;
  final bool isToday;

  const DoseInfo({
    required this.dose,
    required this.completed,
    required this.label,
    this.isToday = false,
  });
}
