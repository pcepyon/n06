import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:n06/features/tracking/domain/entities/trend_insight.dart';
import 'package:n06/features/tracking/domain/services/trend_insight_analyzer.dart';

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

    // 증상 로그는 제거되었으므로 빈 분석 반환
    return _analyzer.analyzeTrend(
      logs: [],
      period: period,
    );
  }

  /// 트렌드 분석 새로고침
  Future<void> refresh() async {
    state = const AsyncValue.loading();

    final link = ref.keepAlive();
    try {
      state = await AsyncValue.guard(() async {
        if (!ref.mounted) return state.value ?? _getEmptyInsight();

        // 증상 로그는 제거되었으므로 빈 분석 반환
        return _analyzer.analyzeTrend(
          logs: [],
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
    // 증상 로그는 제거되었으므로 빈 분석 반환
    return _analyzer.analyzeTrend(
      logs: [],
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
