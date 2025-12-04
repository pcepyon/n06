import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/tracking/domain/entities/trend_insight.dart';
import 'package:n06/core/extensions/l10n_extension.dart';

/// 개별 질문 상세 차트 위젯
///
/// 특정 질문의 일별 상태 변화를 라인 차트로 표시
class QuestionDetailChart extends StatefulWidget {
  final List<QuestionTrend> questionTrends;
  final QuestionType? initialSelectedType;

  const QuestionDetailChart({
    super.key,
    required this.questionTrends,
    this.initialSelectedType,
  });

  @override
  State<QuestionDetailChart> createState() => _QuestionDetailChartState();
}

class _QuestionDetailChartState extends State<QuestionDetailChart> {
  late QuestionType _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialSelectedType ?? QuestionType.meal;
  }

  @override
  Widget build(BuildContext context) {
    final selectedTrend = widget.questionTrends.firstWhere(
      (t) => t.questionType == _selectedType,
      orElse: () => widget.questionTrends.first,
    );

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
          // 질문 타입 선택 칩
          _buildQuestionChips(),
          const SizedBox(height: 16),
          // 차트
          SizedBox(
            height: 180,
            child: _buildChart(selectedTrend),
          ),
          const SizedBox(height: 12),
          // 범례
          _buildChartLegend(),
        ],
      ),
    );
  }

  Widget _buildQuestionChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.questionTrends.map((trend) {
          final isSelected = trend.questionType == _selectedType;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedType = trend.questionType;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _getQuestionColor(trend.questionType)
                      : AppColors.neutral100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getQuestionEmoji(trend.questionType),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trend.label,
                      style: AppTypography.bodySmall.copyWith(
                        color: isSelected ? Colors.white : AppColors.neutral700,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChart(QuestionTrend trend) {
    final dailyStatuses = trend.dailyStatuses;
    if (dailyStatuses.isEmpty) {
      return Center(
        child: Text(
          context.l10n.tracking_chart_noData,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.neutral500,
          ),
        ),
      );
    }

    return CustomPaint(
      painter: _LineChartPainter(
        dailyStatuses: dailyStatuses,
        color: _getQuestionColor(trend.questionType),
      ),
      child: SizedBox.expand(),
    );
  }

  Widget _buildChartLegend() {
    final l10n = context.l10n;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(const Color(0xFF4CAF50), l10n.tracking_chart_legendGood),
        const SizedBox(width: 16),
        _buildLegendItem(const Color(0xFFFFC107), l10n.tracking_chart_legendModerate),
        const SizedBox(width: 16),
        _buildLegendItem(const Color(0xFFF44336), l10n.tracking_chart_legendBad),
        const SizedBox(width: 16),
        _buildLegendItem(AppColors.neutral300, l10n.tracking_chart_legendNoRecord),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
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

  Color _getQuestionColor(QuestionType type) {
    switch (type) {
      case QuestionType.meal:
        return const Color(0xFFFF9800);
      case QuestionType.hydration:
        return const Color(0xFF2196F3);
      case QuestionType.giComfort:
        return const Color(0xFF9C27B0);
      case QuestionType.bowel:
        return const Color(0xFF795548);
      case QuestionType.energy:
        return const Color(0xFFFFEB3B);
      case QuestionType.mood:
        return const Color(0xFFE91E63);
    }
  }

  String _getQuestionEmoji(QuestionType type) {
    switch (type) {
      case QuestionType.meal:
        return '🍽️';
      case QuestionType.hydration:
        return '💧';
      case QuestionType.giComfort:
        return '🫃';
      case QuestionType.bowel:
        return '🚽';
      case QuestionType.energy:
        return '⚡';
      case QuestionType.mood:
        return '😊';
    }
  }
}

/// 라인 차트 페인터
class _LineChartPainter extends CustomPainter {
  final List<DailyQuestionStatus> dailyStatuses;
  final Color color;

  _LineChartPainter({
    required this.dailyStatuses,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dailyStatuses.isEmpty) return;

    final chartWidth = size.width;
    final chartHeight = size.height - 30; // 하단 날짜 영역 제외
    final pointSpacing = chartWidth / (dailyStatuses.length - 1).clamp(1, double.infinity);

    // 그리드 라인
    final gridPaint = Paint()
      ..color = AppColors.neutral200
      ..strokeWidth = 1;

    // 수평 그리드 (3단계: 좋음, 보통, 나쁨)
    for (var i = 0; i <= 2; i++) {
      final y = chartHeight - (chartHeight / 2 * i);
      canvas.drawLine(
        Offset(0, y),
        Offset(chartWidth, y),
        gridPaint,
      );
    }

    // 데이터 포인트
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();
    final points = <Offset>[];

    for (var i = 0; i < dailyStatuses.length; i++) {
      final status = dailyStatuses[i];
      final x = i * pointSpacing;

      double y;
      if (status.noData) {
        y = chartHeight; // 기록 없음은 최하단
      } else {
        // score: 0 = bad, 50 = moderate, 100 = good
        y = chartHeight - (status.score * chartHeight / 100);
      }

      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, chartHeight);
        fillPath.lineTo(x, y);
      } else if (!status.noData && !dailyStatuses[i - 1].noData) {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      } else {
        path.moveTo(x, y);
        fillPath.lineTo(x, chartHeight);
        fillPath.moveTo(x, chartHeight);
        fillPath.lineTo(x, y);
      }
    }

    // 채우기 영역
    if (points.isNotEmpty) {
      fillPath.lineTo(points.last.dx, chartHeight);
      fillPath.close();
      canvas.drawPath(fillPath, fillPaint);
    }

    // 라인 그리기
    canvas.drawPath(path, linePaint);

    // 포인트와 날짜 그리기
    for (var i = 0; i < dailyStatuses.length; i++) {
      final status = dailyStatuses[i];
      final point = points[i];

      // 포인트
      Color pointColor;
      if (status.noData) {
        pointColor = AppColors.neutral300;
      } else {
        // score: 0 = bad, 50 = moderate, 100 = good
        if (status.score >= 100) {
          pointColor = const Color(0xFF4CAF50); // good
        } else if (status.score >= 50) {
          pointColor = const Color(0xFFFFC107); // moderate
        } else {
          pointColor = const Color(0xFFF44336); // bad
        }
      }

      canvas.drawCircle(
        point,
        5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        point,
        5,
        Paint()
          ..color = pointColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      canvas.drawCircle(
        point,
        3,
        Paint()
          ..color = pointColor
          ..style = PaintingStyle.fill,
      );

      // 날짜 (주간일 때 요일, 월간일 때 일자)
      final dateFormat = dailyStatuses.length <= 7
          ? DateFormat('E', 'ko_KR')
          : DateFormat('d');
      final dateText = dateFormat.format(status.date);

      final textPainter = TextPainter(
        text: TextSpan(
          text: dateText,
          style: TextStyle(
            color: AppColors.neutral500,
            fontSize: 10,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          point.dx - textPainter.width / 2,
          chartHeight + 10,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.dailyStatuses != dailyStatuses ||
        oldDelegate.color != color;
  }
}
