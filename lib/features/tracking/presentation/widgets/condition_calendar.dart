import 'package:flutter/material.dart';

import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/tracking/domain/entities/trend_insight.dart';
import 'package:n06/core/extensions/l10n_extension.dart';

/// 일상 상태 캘린더 위젯
///
/// 날짜별 컨디션 점수를 시각적으로 표시
class ConditionCalendar extends StatelessWidget {
  final List<DailyConditionSummary> dailyConditions;
  final TrendPeriod period;
  final void Function(DailyConditionSummary)? onDayTap;

  const ConditionCalendar({
    super.key,
    required this.dailyConditions,
    required this.period,
    this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    if (period == TrendPeriod.weekly) {
      return _buildWeeklyView();
    } else {
      return _buildMonthlyView();
    }
  }

  Widget _buildWeeklyView() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.neutral200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 요일 헤더
          Builder(
            builder: (context) {
              final l10n = context.l10n;
              return Row(
                children: [
                  l10n.tracking_weekday_mon,
                  l10n.tracking_weekday_tue,
                  l10n.tracking_weekday_wed,
                  l10n.tracking_weekday_thu,
                  l10n.tracking_weekday_fri,
                  l10n.tracking_weekday_sat,
                  l10n.tracking_weekday_sun,
                ]
                    .map((day) => Expanded(
                          child: Center(
                            child: Text(
                              day,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.neutral500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 12),
          // 날짜 셀
          Row(
            children: dailyConditions.map((condition) {
              return Expanded(
                child: _buildDayCell(condition),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // 범례
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildMonthlyView() {
    // 월간 뷰: 5주 그리드
    final weeks = <List<DailyConditionSummary?>>[];
    var currentWeek = <DailyConditionSummary?>[];

    // 첫 날의 요일 계산 (월요일 시작)
    if (dailyConditions.isNotEmpty) {
      final firstDay = dailyConditions.first.date;
      final firstWeekday = firstDay.weekday; // 1 = Monday, 7 = Sunday

      // 첫 주의 빈 셀 채우기
      for (var i = 1; i < firstWeekday; i++) {
        currentWeek.add(null);
      }
    }

    for (final condition in dailyConditions) {
      currentWeek.add(condition);
      if (currentWeek.length == 7) {
        weeks.add(currentWeek);
        currentWeek = [];
      }
    }

    // 마지막 주 남은 셀 처리
    if (currentWeek.isNotEmpty) {
      while (currentWeek.length < 7) {
        currentWeek.add(null);
      }
      weeks.add(currentWeek);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.neutral200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 월 표시
          if (dailyConditions.isNotEmpty)
            Builder(
              builder: (context) {
                final l10n = context.l10n;
                final firstDate = dailyConditions.first.date;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    l10n.tracking_conditionCalendar_monthFormat(firstDate.year, firstDate.month),
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          // 요일 헤더
          Builder(
            builder: (context) {
              final l10n = context.l10n;
              return Row(
                children: [
                  l10n.tracking_weekday_mon,
                  l10n.tracking_weekday_tue,
                  l10n.tracking_weekday_wed,
                  l10n.tracking_weekday_thu,
                  l10n.tracking_weekday_fri,
                  l10n.tracking_weekday_sat,
                  l10n.tracking_weekday_sun,
                ]
                    .map((day) => Expanded(
                          child: Center(
                            child: Text(
                              day,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.neutral500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 8),
          // 주별 행
          ...weeks.map((week) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: week.map((condition) {
                    if (condition == null) {
                      return const Expanded(child: SizedBox(height: 40));
                    }
                    return Expanded(child: _buildDayCell(condition, compact: true));
                  }).toList(),
                ),
              )),
          const SizedBox(height: 16),
          // 범례
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildDayCell(DailyConditionSummary condition, {bool compact = false}) {
    final today = DateTime.now();
    final isToday = condition.date.year == today.year &&
        condition.date.month == today.month &&
        condition.date.day == today.day;

    return GestureDetector(
      onTap: condition.hasCheckin && onDayTap != null
          ? () => onDayTap!(condition)
          : null,
      child: Container(
        margin: EdgeInsets.all(compact ? 2 : 4),
        child: Column(
          children: [
            // 날짜
            Text(
              '${condition.date.day}',
              style: AppTypography.bodySmall.copyWith(
                color: isToday ? AppColors.primary : AppColors.neutral600,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            // 컨디션 인디케이터
            Container(
              width: compact ? 28 : 36,
              height: compact ? 28 : 36,
              decoration: BoxDecoration(
                color: _getGradeColor(condition),
                shape: BoxShape.circle,
                border: isToday
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
              ),
              child: Center(
                child: condition.hasRedFlag
                    ? const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 16,
                      )
                    : condition.hasCheckin
                        ? Text(
                            _getGradeEmoji(condition.grade),
                            style: TextStyle(fontSize: compact ? 12 : 16),
                          )
                        : Icon(
                            Icons.remove,
                            color: AppColors.neutral400,
                            size: compact ? 12 : 16,
                          ),
              ),
            ),
            // 주사 표시
            if (condition.isPostInjection) ...[
              const SizedBox(height: 2),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(DailyConditionSummary condition) {
    if (!condition.hasCheckin) {
      return AppColors.neutral100;
    }

    if (condition.hasRedFlag) {
      return AppColors.error;
    }

    switch (condition.grade) {
      case ConditionGrade.excellent:
        return const Color(0xFF4CAF50); // Green
      case ConditionGrade.good:
        return const Color(0xFF8BC34A); // Light Green
      case ConditionGrade.fair:
        return const Color(0xFFFFC107); // Amber
      case ConditionGrade.poor:
        return const Color(0xFFFF9800); // Orange
      case ConditionGrade.bad:
        return const Color(0xFFF44336); // Red
    }
  }

  String _getGradeEmoji(ConditionGrade grade) {
    switch (grade) {
      case ConditionGrade.excellent:
        return '😊';
      case ConditionGrade.good:
        return '🙂';
      case ConditionGrade.fair:
        return '😐';
      case ConditionGrade.poor:
        return '😕';
      case ConditionGrade.bad:
        return '😢';
    }
  }

  Widget _buildLegend() {
    return Builder(
      builder: (context) {
        final l10n = context.l10n;
        return Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildLegendItem(const Color(0xFF4CAF50), l10n.tracking_conditionCalendar_gradeExcellent),
            _buildLegendItem(const Color(0xFF8BC34A), l10n.tracking_conditionCalendar_gradeGood),
            _buildLegendItem(const Color(0xFFFFC107), l10n.tracking_conditionCalendar_gradeFair),
            _buildLegendItem(const Color(0xFFFF9800), l10n.tracking_conditionCalendar_gradePoor),
            _buildLegendItem(AppColors.error, l10n.tracking_conditionCalendar_gradeBad),
            _buildLegendItem(AppColors.neutral100, l10n.tracking_conditionCalendar_noRecord),
          ],
        );
      },
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
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
}
