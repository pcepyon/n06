import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/tracking/application/notifiers/trend_insight_notifier.dart';
import 'package:n06/features/tracking/domain/entities/trend_insight.dart';

// Provider는 generated 파일에서 생성됨
import 'package:n06/features/tracking/presentation/widgets/condition_calendar.dart';
import 'package:n06/features/tracking/presentation/widgets/question_detail_chart.dart';
import 'package:n06/features/tracking/presentation/widgets/trend_insight_card.dart';
import 'package:n06/features/tracking/presentation/widgets/weekly_condition_chart.dart';
import 'package:n06/features/tracking/presentation/widgets/weekly_pattern_insight_card.dart';

/// 트렌드 대시보드 화면
///
/// 데일리 체크인 기반 트렌드 분석 표시
///
/// 화면 구조:
/// 1. 기간 선택 탭 (주간 | 월간)
/// 2. TrendInsightCard (요약)
/// 3. ConditionCalendar (일상 상태 캘린더)
/// 4. WeeklyConditionChart (주간 컨디션 막대그래프)
/// 5. QuestionDetailChart (개별 질문 상세 차트)
/// 6. WeeklyPatternInsightCard (주간 패턴 인사이트)
class TrendDashboardScreen extends ConsumerStatefulWidget {
  const TrendDashboardScreen({super.key});

  @override
  ConsumerState<TrendDashboardScreen> createState() =>
      _TrendDashboardScreenState();
}

class _TrendDashboardScreenState extends ConsumerState<TrendDashboardScreen> {
  TrendPeriod _selectedPeriod = TrendPeriod.weekly;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final userId = authState.value?.id;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.tracking_trend_title),
        ),
        body: Center(
          child: Text(context.l10n.tracking_trend_loginRequired),
        ),
      );
    }

    final trendState = ref.watch(
      trendInsightProvider(userId: userId, period: _selectedPeriod),
    );

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Text(context.l10n.tracking_trend_title),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.neutral200,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(
                trendInsightProvider(
                        userId: userId, period: _selectedPeriod)
                    .notifier,
              )
              .refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 기간 선택 탭
              _buildPeriodTabs(),

              trendState.when(
                data: (insight) => _buildContent(insight),
                loading: () => _buildLoading(),
                error: (error, stack) => _buildError(error),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildPeriodTab(
              label: context.l10n.tracking_trend_periodWeekly,
              period: TrendPeriod.weekly,
              isSelected: _selectedPeriod == TrendPeriod.weekly,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildPeriodTab(
              label: context.l10n.tracking_trend_periodMonthly,
              period: TrendPeriod.monthly,
              isSelected: _selectedPeriod == TrendPeriod.monthly,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodTab({
    required String label,
    required TrendPeriod period,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.neutral100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.bodyLarge.copyWith(
              color: isSelected ? Colors.white : AppColors.neutral600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(TrendInsight insight) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 요약 카드
          TrendInsightCard(insight: insight),

          const SizedBox(height: 24),

          // 2. 일상 상태 캘린더
          _buildSection(
            title: context.l10n.tracking_trend_calendarTitle,
            subtitle: context.l10n.tracking_trend_calendarSubtitle,
            child: ConditionCalendar(
              dailyConditions: insight.dailyConditions,
              period: _selectedPeriod,
              onDayTap: (condition) {
                _showDayDetail(condition);
              },
            ),
          ),

          const SizedBox(height: 24),

          // 3. 주간 컨디션 차트
          if (insight.questionTrends.isNotEmpty) ...[
            _buildSection(
              title: context.l10n.tracking_trend_conditionTitle,
              subtitle: context.l10n.tracking_trend_conditionSubtitle,
              child: WeeklyConditionChart(
                questionTrends: insight.questionTrends,
                onTrendTap: (trend) {
                  // 해당 질문 상세로 스크롤
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // 4. 개별 질문 상세 차트
          if (insight.questionTrends.isNotEmpty) ...[
            _buildSection(
              title: context.l10n.tracking_trend_detailTitle,
              subtitle: context.l10n.tracking_trend_detailSubtitle,
              child: QuestionDetailChart(
                questionTrends: insight.questionTrends,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // 5. 주간 패턴 인사이트
          WeeklyPatternInsightCard(insight: insight),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.heading3.copyWith(
            color: AppColors.neutral800,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.neutral500,
            ),
          ),
        ],
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  void _showDayDetail(DailyConditionSummary condition) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜 헤더
            Row(
              children: [
                Text(
                  context.l10n.tracking_trend_dayDetailDate(condition.date.month, condition.date.day),
                  style: AppTypography.heading2.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 컨디션 정보
            _buildDetailRow(
              label: context.l10n.tracking_trend_overallCondition,
              value: context.l10n.tracking_trend_scoreDisplay(condition.overallScore),
              icon: _getGradeEmoji(condition.grade),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              label: context.l10n.tracking_trend_gradeLabel,
              value: _getGradeLabel(condition.grade),
              color: _getGradeColor(condition.grade),
            ),
            if (condition.hasRedFlag) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.l10n.tracking_trend_redFlagWarning,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (condition.isPostInjection) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.vaccines, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.l10n.tracking_trend_postInjectionLabel,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    String? icon,
    Color? color,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: color ?? AppColors.neutral800,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
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

  String _getGradeLabel(ConditionGrade grade) {
    switch (grade) {
      case ConditionGrade.excellent:
        return context.l10n.tracking_trend_gradeExcellent;
      case ConditionGrade.good:
        return context.l10n.tracking_trend_gradeGood;
      case ConditionGrade.fair:
        return context.l10n.tracking_trend_gradeFair;
      case ConditionGrade.poor:
        return context.l10n.tracking_trend_gradePoor;
      case ConditionGrade.bad:
        return context.l10n.tracking_trend_gradeBad;
    }
  }

  Color _getGradeColor(ConditionGrade grade) {
    switch (grade) {
      case ConditionGrade.excellent:
        return const Color(0xFF4CAF50);
      case ConditionGrade.good:
        return const Color(0xFF8BC34A);
      case ConditionGrade.fair:
        return const Color(0xFFFFC107);
      case ConditionGrade.poor:
        return const Color(0xFFFF9800);
      case ConditionGrade.bad:
        return const Color(0xFFF44336);
    }
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.all(48),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildError(Object error) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.tracking_trend_errorMessage,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.neutral600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
