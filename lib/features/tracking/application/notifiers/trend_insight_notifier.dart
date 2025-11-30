import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:n06/features/tracking/domain/entities/trend_insight.dart';
import 'package:n06/features/tracking/domain/services/trend_insight_analyzer.dart';
import 'package:n06/features/tracking/application/providers.dart';

part 'trend_insight_notifier.g.dart';

/// 트렌드 인사이트 Notifier
///
/// Phase 3: 트렌드 대시보드
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

    // 기간에 따라 데이터 조회
    final repository = ref.read(trackingRepositoryProvider);
    final now = DateTime.now();
    final startDate = period == TrendPeriod.weekly
        ? now.subtract(const Duration(days: 7))
        : now.subtract(const Duration(days: 30));

    final logs = await repository.getSymptomLogs(
      userId,
      startDate: startDate,
      endDate: now,
    );

    // 트렌드 분석 실행
    return _analyzer.analyzeTrend(
      logs: logs,
      period: period,
    );
  }

  /// 트렌드 분석 새로고침
  Future<void> refresh() async {
    state = const AsyncValue.loading();

    final link = ref.keepAlive();
    try {
      state = await AsyncValue.guard(() async {
        final repository = ref.read(trackingRepositoryProvider);
        final now = DateTime.now();
        final startDate = period == TrendPeriod.weekly
            ? now.subtract(const Duration(days: 7))
            : now.subtract(const Duration(days: 30));

        final logs = await repository.getSymptomLogs(
          userId,
          startDate: startDate,
          endDate: now,
        );

        if (!ref.mounted) return state.value ?? _getEmptyInsight();

        return _analyzer.analyzeTrend(
          logs: logs,
          period: period,
        );
      });
    } finally {
      link.close();
    }
  }

  /// 특정 기간의 트렌드 분석
  Future<TrendInsight> analyzeCustomPeriod({
    required DateTime startDate,
    required DateTime endDate,
    required TrendPeriod customPeriod,
  }) async {
    final repository = ref.read(trackingRepositoryProvider);

    final logs = await repository.getSymptomLogs(
      userId,
      startDate: startDate,
      endDate: endDate,
    );

    return _analyzer.analyzeTrend(
      logs: logs,
      period: customPeriod,
    );
  }

  TrendInsight _getEmptyInsight() {
    return TrendInsight(
      period: period,
      frequencies: const [],
      severityTrends: const [],
      summaryMessage: '기록된 증상이 없어요',
      overallDirection: TrendDirection.stable,
    );
  }
}
