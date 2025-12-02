import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/tracking/domain/entities/trend_insight.dart';
import 'package:n06/features/tracking/presentation/widgets/trend_insight_card.dart';
// import 'package:n06/features/tracking/presentation/widgets/symptom_heatmap_calendar.dart'; // DEPRECATED - removed
// import 'package:n06/features/tracking/presentation/widgets/symptom_trend_chart.dart'; // DEPRECATED - removed
import 'package:n06/features/tracking/presentation/widgets/pattern_insight_card.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/tracking/application/notifiers/trend_insight_notifier.dart';
// import 'package:n06/features/tracking/application/notifiers/symptom_pattern_notifier.dart'; // DEPRECATED - removed

/// 트렌드 대시보드 화면
///
/// Phase 3: 트렌드 대시보드
///
/// 화면 구조:
/// 1. 기간 선택 탭 (주간 | 월간)
/// 2. TrendInsightCard (요약)
/// 3. SymptomHeatmapCalendar
/// 4. SymptomTrendChart
/// 5. PatternInsightCard 리스트 (Phase 2 재사용)
class TrendDashboardScreen extends ConsumerStatefulWidget {
  const TrendDashboardScreen({super.key});

  @override
  ConsumerState<TrendDashboardScreen> createState() => _TrendDashboardScreenState();
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
          title: const Text('트렌드 대시보드'),
        ),
        body: const Center(
          child: Text('로그인이 필요합니다'),
        ),
      );
    }

    final trendState = ref.watch(
      trendInsightProvider(userId: userId, period: _selectedPeriod),
    );

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('트렌드 대시보드'),
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
          await ref.read(
            trendInsightProvider(userId: userId, period: _selectedPeriod).notifier,
          ).refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 기간 선택 탭
              _buildPeriodTabs(),

              trendState.when(
                data: (insight) => _buildContent(insight, userId),
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
              label: '주간',
              period: TrendPeriod.weekly,
              isSelected: _selectedPeriod == TrendPeriod.weekly,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildPeriodTab(
              label: '월간',
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

  Widget _buildContent(TrendInsight insight, String userId) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. TrendInsightCard (요약)
          TrendInsightCard(insight: insight),

          const SizedBox(height: 24),

          // 2. 히트맵 캘린더
          _buildSection(
            title: '증상 빈도 캘린더',
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.neutral200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text('Symptom tracking removed')),
            ),
          ),

          const SizedBox(height: 24),

          // 3. 트렌드 차트
          _buildSection(
            title: '심각도 추이',
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.neutral200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text('Symptom tracking removed')),
            ),
          ),

          const SizedBox(height: 24),

          // 4. PatternInsightCard 리스트 (Phase 2 재사용)
          if (insight.frequencies.isNotEmpty) ...[
            _buildSection(
              title: '패턴 인사이트',
              child: _buildPatternInsights(userId, insight),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
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
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildPatternInsights(String userId, TrendInsight insight) {
    // TOP 증상에 대한 패턴 분석 표시
    final topSymptom = insight.frequencies.first.symptomName;

    // Symptom pattern provider is removed
    return const SizedBox.shrink();

    /*
    final patternState = ref.watch(
      // symptomPatternProvider(userId: userId, symptomName: topSymptom), // DEPRECATED
    );

    return patternState.when(
      data: (patterns) {
        if (patterns.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.neutral200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '패턴을 찾기 위해서는 더 많은 기록이 필요해요',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutral500,
                ),
              ),
            ),
          );
        }

        return Column(
          children: patterns.map((pattern) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PatternInsightCard(insight: pattern),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const SizedBox.shrink(),
    );
    */
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
              '데이터를 불러오는 중 오류가 발생했어요',
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

  DateTime _getStartDate() {
    final now = DateTime.now();
    return _selectedPeriod == TrendPeriod.weekly
        ? now.subtract(const Duration(days: 7))
        : now.subtract(const Duration(days: 30));
  }

  Map<DateTime, int> _buildSymptomCountMap(TrendInsight insight) {
    // 간단한 예시: 빈도 데이터를 날짜별로 분산
    // 실제로는 일별 증상 개수를 정확히 집계해야 함
    final map = <DateTime, int>{};
    final now = DateTime.now();

    for (int i = 0; i < (_selectedPeriod == TrendPeriod.weekly ? 7 : 30); i++) {
      final date = now.subtract(Duration(days: i));
      final normalizedDate = DateTime(date.year, date.month, date.day);

      // 임시: 랜덤 개수 대신 빈도 기반으로 예측
      final count = insight.frequencies.isEmpty ? 0 : (insight.frequencies.first.count / 7).round();
      map[normalizedDate] = count;
    }

    return map;
  }
}
