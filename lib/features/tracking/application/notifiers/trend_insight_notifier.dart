import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:n06/features/daily_checkin/application/providers.dart';
import 'package:n06/features/tracking/domain/entities/trend_insight.dart';
import 'package:n06/features/tracking/domain/services/trend_insight_analyzer.dart';

part 'trend_insight_notifier.g.dart';

/// 트렌드 인사이트 Notifier
///
/// 데일리 체크인 기반 트렌드 분석
/// - 기간별 데이터 조회 (주간/월간)
/// - 트렌드 분석 실행
/// - 결과 캐싱 (기간 변경 시 재계산)
@riverpod
class TrendInsightNotifier extends _$TrendInsightNotifier {
  late final TrendInsightAnalyzer _analyzer;

  @override
  Future<TrendInsight> build({
    required String userId,
    required TrendPeriod period,
  }) async {
    _analyzer = TrendInsightAnalyzer();
    return _fetchAndAnalyze();
  }

  /// 트렌드 분석 새로고침
  Future<void> refresh() async {
    state = const AsyncValue.loading();

    final link = ref.keepAlive();
    try {
      state = await AsyncValue.guard(() async {
        if (!ref.mounted) return state.value ?? TrendInsight.empty(period);
        return _fetchAndAnalyze();
      });
    } finally {
      link.close();
    }
  }

  /// 데이터 조회 및 분석
  Future<TrendInsight> _fetchAndAnalyze() async {
    final repository = ref.read(dailyCheckinRepositoryProvider);

    // 기간 계산
    final today = DateTime.now();
    final periodDays = period == TrendPeriod.weekly ? 7 : 30;
    final startDate = today.subtract(Duration(days: periodDays - 1));

    // 현재 기간 데이터 조회
    final checkins = await repository.getByDateRange(
      userId,
      startDate,
      today,
    );

    // 이전 기간 데이터 조회 (비교용)
    final previousStartDate = startDate.subtract(Duration(days: periodDays));
    final previousEndDate = startDate.subtract(const Duration(days: 1));
    final previousCheckins = await repository.getByDateRange(
      userId,
      previousStartDate,
      previousEndDate,
    );

    // 연속 기록 일수 조회
    final consecutiveDays = await repository.getConsecutiveDays(userId);

    // 분석 실행
    return _analyzer.analyze(
      checkins: checkins,
      previousPeriodCheckins: previousCheckins,
      period: period,
      consecutiveDays: consecutiveDays,
    );
  }

  /// 특정 기간의 트렌드 분석
  Future<TrendInsight> analyzeCustomPeriod({
    required DateTime startDate,
    required DateTime endDate,
    required TrendPeriod customPeriod,
  }) async {
    final repository = ref.read(dailyCheckinRepositoryProvider);

    final checkins = await repository.getByDateRange(
      userId,
      startDate,
      endDate,
    );

    final consecutiveDays = await repository.getConsecutiveDays(userId);

    return _analyzer.analyze(
      checkins: checkins,
      previousPeriodCheckins: null,
      period: customPeriod,
      consecutiveDays: consecutiveDays,
    );
  }
}
