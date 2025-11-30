import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:n06/features/tracking/domain/entities/pattern_insight.dart';
import 'package:n06/features/tracking/domain/services/symptom_pattern_analyzer.dart';
import 'package:n06/features/tracking/application/providers.dart';

part 'symptom_pattern_notifier.g.dart';

/// 증상 패턴 분석 Notifier
///
/// Phase 2: 컨텍스트 인식 가이드
/// - 증상 기록 히스토리 조회
/// - 패턴 분석 실행
/// - 인사이트 캐싱
@riverpod
class SymptomPatternNotifier extends _$SymptomPatternNotifier {
  late final SymptomPatternAnalyzer _analyzer;

  @override
  Future<List<PatternInsight>> build({
    required String userId,
    required String symptomName,
  }) async {
    _analyzer = SymptomPatternAnalyzer();

    // 최근 30일간 증상 기록 조회
    final repository = ref.read(trackingRepositoryProvider);
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final recentLogs = await repository.getSymptomLogs(
      userId,
      startDate: thirtyDaysAgo,
      endDate: now,
    );

    // 패턴 분석 실행
    return _analyzer.analyzePatterns(
      recentLogs: recentLogs,
      currentSymptom: symptomName,
    );
  }

  /// 패턴 분석 새로고침
  Future<void> refresh() async {
    state = const AsyncValue.loading();

    final link = ref.keepAlive();
    try {
      state = await AsyncValue.guard(() async {
        final repository = ref.read(trackingRepositoryProvider);
        final now = DateTime.now();
        final thirtyDaysAgo = now.subtract(const Duration(days: 30));

        final recentLogs = await repository.getSymptomLogs(
          userId,
          startDate: thirtyDaysAgo,
          endDate: now,
        );

        if (!ref.mounted) return state.value ?? [];

        return _analyzer.analyzePatterns(
          recentLogs: recentLogs,
          currentSymptom: symptomName,
        );
      });
    } finally {
      link.close();
    }
  }

  /// 특정 기간의 패턴 분석
  Future<List<PatternInsight>> analyzeCustomPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final repository = ref.read(trackingRepositoryProvider);

    final logs = await repository.getSymptomLogs(
      userId,
      startDate: startDate,
      endDate: endDate,
    );

    return _analyzer.analyzePatterns(
      recentLogs: logs,
      currentSymptom: symptomName,
    );
  }
}
