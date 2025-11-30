import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

/// 증상 히트맵 캘린더
///
/// Phase 3: 트렌드 대시보드
/// - 7x4~5 그리드 (요일 x 주)
/// - 색상 강도로 증상 빈도 표현
/// - AppColors.success (0개) → AppColors.warning (다수)
///
/// Design Tokens:
/// - None: Neutral-100 (#F1F5F9)
/// - Mild (1-3): Success 30% (#10B981)
/// - Moderate (4-6): Warning 50% (#F59E0B)
/// - Severe (7-10): Error 70% (#EF4444)
/// - Border Radius: 4px
/// - Cell Size: 40x40px
class SymptomHeatmapCalendar extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final Map<DateTime, int> symptomCounts; // 날짜별 증상 개수
  final Function(DateTime)? onDateTap;

  const SymptomHeatmapCalendar({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.symptomCounts,
    this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 요일 헤더
        _buildWeekdayHeader(),
        const SizedBox(height: 8),

        // 히트맵 그리드
        _buildHeatmapGrid(),

        const SizedBox(height: 16),

        // 범례
        _buildLegend(),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays
          .map((day) => SizedBox(
                width: 40,
                child: Center(
                  child: Text(
                    day,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.neutral500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildHeatmapGrid() {
    final weeks = _generateWeeks();

    return Column(
      children: weeks
          .map((week) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: week
                      .map((date) => _buildDateCell(date))
                      .toList(),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildDateCell(DateTime? date) {
    if (date == null) {
      return const SizedBox(width: 40, height: 40);
    }

    final count = symptomCounts[_normalizeDate(date)] ?? 0;
    final color = _getColorForCount(count);

    return GestureDetector(
      onTap: onDateTap != null ? () => onDateTap!(date) : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: AppTypography.caption.copyWith(
              color: count > 0 ? Colors.white : AppColors.neutral600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('없음', AppColors.neutral100),
        const SizedBox(width: 12),
        _buildLegendItem('경미', AppColors.success.withValues(alpha: 0.3)),
        const SizedBox(width: 12),
        _buildLegendItem('중간', AppColors.warning.withValues(alpha: 0.5)),
        const SizedBox(width: 12),
        _buildLegendItem('심함', AppColors.error.withValues(alpha: 0.7)),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.neutral600,
          ),
        ),
      ],
    );
  }

  /// 주차별 날짜 그리드 생성
  List<List<DateTime?>> _generateWeeks() {
    final weeks = <List<DateTime?>>[];

    DateTime current = startDate;

    // 시작일이 일요일이 아니면 null로 패딩
    final startWeekday = current.weekday == 7 ? 0 : current.weekday;
    final currentWeek = <DateTime?>[...List<DateTime?>.filled(startWeekday, null)];

    // 날짜 채우기
    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      if (current.weekday == DateTime.sunday && currentWeek.length == 7) {
        weeks.add(currentWeek.toList());
        currentWeek.clear();
      }

      currentWeek.add(current);
      current = current.add(const Duration(days: 1));
    }

    // 마지막 주 패딩
    while (currentWeek.length < 7) {
      currentWeek.add(null);
    }

    if (currentWeek.isNotEmpty) {
      weeks.add(currentWeek);
    }

    return weeks;
  }

  /// 날짜 정규화 (시간 제거)
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// 증상 개수에 따른 색상 결정
  Color _getColorForCount(int count) {
    if (count == 0) {
      return AppColors.neutral100;
    } else if (count <= 3) {
      return AppColors.success.withValues(alpha: 0.3);
    } else if (count <= 6) {
      return AppColors.warning.withValues(alpha: 0.5);
    } else {
      return AppColors.error.withValues(alpha: 0.7);
    }
  }
}
