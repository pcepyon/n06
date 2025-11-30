import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/tracking/domain/entities/trend_insight.dart';

/// 증상 트렌드 차트
///
/// Phase 3: 트렌드 대시보드
/// - fl_chart 패키지 사용
/// - LineChart로 심각도 추이 시각화
/// - 증상별 색상 구분
/// - 터치 시 상세 값 표시
///
/// Design Tokens:
/// - Chart Color 1: Primary (#4ADE80)
/// - Chart Color 2: Blue (#3B82F6)
/// - Chart Color 3: Amber (#F59E0B)
/// - Grid Lines: Neutral-200 (#E2E8F0)
/// - Axis: Neutral-500 (#64748B)
/// - Labels: xs (12px Medium)
class SymptomTrendChart extends StatelessWidget {
  final List<SeverityTrend> trends;
  final TrendPeriod period;

  const SymptomTrendChart({
    super.key,
    required this.trends,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 범례
        _buildLegend(),
        const SizedBox(height: 16),

        // 차트
        SizedBox(
          height: 240,
          child: LineChart(_buildChartData()),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 240,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 48,
            color: AppColors.neutral300,
          ),
          const SizedBox(height: 8),
          Text(
            '트렌드 데이터가 부족해요',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: trends.asMap().entries.map((entry) {
        final index = entry.key;
        final trend = entry.value;
        final color = _getColorForIndex(index);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 3,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              trend.symptomName,
              style: AppTypography.caption.copyWith(
                color: AppColors.neutral700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              _getTrendIcon(trend.direction),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  LineChartData _buildChartData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 2,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors.neutral200,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= _getMaxDataPoints()) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${index + 1}일',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            interval: 2,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: AppTypography.caption.copyWith(
                  color: AppColors.neutral500,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: AppColors.neutral300, width: 1),
          left: BorderSide(color: AppColors.neutral300, width: 1),
        ),
      ),
      minX: 0,
      maxX: (_getMaxDataPoints() - 1).toDouble(),
      minY: 0,
      maxY: 10,
      lineBarsData: trends.asMap().entries.map((entry) {
        final index = entry.key;
        final trend = entry.value;
        return _buildLineChartBarData(trend, index);
      }).toList(),
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => AppColors.neutral800,
          tooltipBorder: BorderSide(color: AppColors.neutral700, width: 1),
          tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final trend = trends[spot.barIndex];
              return LineTooltipItem(
                '${trend.symptomName}\n${spot.y.toStringAsFixed(1)}',
                const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  LineChartBarData _buildLineChartBarData(SeverityTrend trend, int index) {
    final color = _getColorForIndex(index);

    return LineChartBarData(
      spots: trend.dailyAverages.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value);
      }).toList(),
      isCurved: true,
      curveSmoothness: 0.3,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: Colors.white,
            strokeWidth: 2,
            strokeColor: color,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.1),
      ),
    );
  }

  int _getMaxDataPoints() {
    if (trends.isEmpty) return 7;
    return trends
        .map((t) => t.dailyAverages.length)
        .reduce((a, b) => a > b ? a : b);
  }

  Color _getColorForIndex(int index) {
    final colors = [
      AppColors.primary,
      AppColors.info,
      AppColors.warning,
    ];
    return colors[index % colors.length];
  }

  String _getTrendIcon(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.improving:
        return '📉';
      case TrendDirection.stable:
        return '➡️';
      case TrendDirection.worsening:
        return '📈';
    }
  }
}
