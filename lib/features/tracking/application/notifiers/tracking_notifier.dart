import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';
import 'package:n06/features/tracking/application/providers.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';

part 'tracking_notifier.g.dart';

class TrackingState {
  final List<WeightLog> weights;
  final List<SymptomLog> symptoms;

  const TrackingState({
    required this.weights,
    required this.symptoms,
  });

  TrackingState copyWith({
    List<WeightLog>? weights,
    List<SymptomLog>? symptoms,
  }) {
    return TrackingState(
      weights: weights ?? this.weights,
      symptoms: symptoms ?? this.symptoms,
    );
  }
}

@riverpod
class TrackingNotifier extends _$TrackingNotifier {
  @override
  Future<TrackingState> build() async {
    // ref.read 사용 (Riverpod 3.0 권장)
    final repository = ref.read(trackingRepositoryProvider);
    final userId = ref.read(authNotifierProvider).value?.id;

    // userId가 없으면 빈 상태 반환
    if (userId == null) {
      return const TrackingState(
        weights: [],
        symptoms: [],
      );
    }

    // userId가 있으면 데이터 로드
    final weights = await repository.getWeightLogs(userId);
    final symptoms = await repository.getSymptomLogs(userId);

    return TrackingState(
      weights: weights,
      symptoms: symptoms,
    );
  }

  /// 데일리 로그 통합 저장 메서드
  ///
  /// 체중 기록과 증상 기록을 한 번에 저장합니다.
  /// 저장 후 네비게이션은 Presentation Layer에서 처리해야 합니다.
  ///
  /// Clean Architecture: Application Layer는 비즈니스 로직만 처리
  Future<void> saveDailyLog({
    required WeightLog weightLog,
    required List<SymptomLog> symptomLogs,
  }) async {
    // 로딩 상태로 전환
    state = const AsyncValue.loading();

    // AsyncValue.guard로 에러 처리 자동화
    state = await AsyncValue.guard(() async {
      final repository = ref.read(trackingRepositoryProvider);
      final userId = ref.read(authNotifierProvider).value?.id;

      // 1. 체중 기록 저장 (appetiteScore 포함)
      await repository.saveWeightLog(weightLog);

      // 2. 증상 기록 저장 (여러 개 가능, 각각 별도 레코드 + 개별 심각도)
      for (final symptomLog in symptomLogs) {
        await repository.saveSymptomLog(symptomLog);
      }

      // 3. 최신 데이터 다시 로드
      if (userId != null) {
        final weights = await repository.getWeightLogs(userId);
        final symptoms = await repository.getSymptomLogs(userId);

        return TrackingState(weights: weights, symptoms: symptoms);
      }

      // userId가 없으면 빈 상태 반환
      return const TrackingState(weights: [], symptoms: []);
    });
  }

  // 체중 기록 저장
  Future<void> saveWeightLog(WeightLog log) async {
    // 저장 전 현재 상태 백업
    final previousState = state.value ?? const TrackingState(
      weights: [],
      symptoms: [],
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(trackingRepositoryProvider);
      final userId = ref.read(authNotifierProvider).value?.id;

      await repository.saveWeightLog(log);

      if (userId != null) {
        final weights = await repository.getWeightLogs(userId);
        return previousState.copyWith(weights: weights);
      }

      // userId가 없으면 이전 상태 유지
      return previousState;
    });
  }

  // 증상 기록 저장
  Future<void> saveSymptomLog(SymptomLog log) async {
    // 저장 전 현재 상태 백업
    final previousState = state.value ?? const TrackingState(
      weights: [],
      symptoms: [],
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(trackingRepositoryProvider);
      final userId = ref.read(authNotifierProvider).value?.id;

      await repository.saveSymptomLog(log);

      if (userId != null) {
        final symptoms = await repository.getSymptomLogs(userId);
        return previousState.copyWith(symptoms: symptoms);
      }

      // userId가 없으면 이전 상태 유지
      return previousState;
    });
  }

  // 체중 기록 삭제
  Future<void> deleteWeightLog(String id) async {
    final previousState = state.value ?? const TrackingState(
      weights: [],
      symptoms: [],
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(trackingRepositoryProvider);
      final userId = ref.read(authNotifierProvider).value?.id;

      await repository.deleteWeightLog(id);

      if (userId != null) {
        final weights = await repository.getWeightLogs(userId);
        return previousState.copyWith(weights: weights);
      }

      return previousState;
    });
  }

  // 증상 기록 삭제
  Future<void> deleteSymptomLog(String id) async {
    final previousState = state.value ?? const TrackingState(
      weights: [],
      symptoms: [],
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(trackingRepositoryProvider);
      final userId = ref.read(authNotifierProvider).value?.id;

      await repository.deleteSymptomLog(id);

      if (userId != null) {
        final symptoms = await repository.getSymptomLogs(userId);
        return previousState.copyWith(symptoms: symptoms);
      }

      return previousState;
    });
  }

  // 체중 기록 업데이트
  Future<void> updateWeightLog(String id, double newWeight) async {
    final previousState = state.value ?? const TrackingState(
      weights: [],
      symptoms: [],
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(trackingRepositoryProvider);
      final userId = ref.read(authNotifierProvider).value?.id;

      await repository.updateWeightLog(id, newWeight);

      if (userId != null) {
        final weights = await repository.getWeightLogs(userId);
        return previousState.copyWith(weights: weights);
      }

      return previousState;
    });
  }

  // 증상 기록 업데이트
  Future<void> updateSymptomLog(String id, SymptomLog updatedLog) async {
    final previousState = state.value ?? const TrackingState(
      weights: [],
      symptoms: [],
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(trackingRepositoryProvider);
      final userId = ref.read(authNotifierProvider).value?.id;

      await repository.updateSymptomLog(id, updatedLog);

      if (userId != null) {
        final symptoms = await repository.getSymptomLogs(userId);
        return previousState.copyWith(symptoms: symptoms);
      }

      return previousState;
    });
  }

  // 특정 날짜의 체중 기록 확인
  Future<bool> hasWeightLogOnDate(String userId, DateTime date) async {
    final repository = ref.read(trackingRepositoryProvider);
    final existing = await repository.getWeightLog(userId, date);
    return existing != null;
  }

  // 특정 날짜의 체중 기록 조회
  Future<WeightLog?> getWeightLog(String userId, DateTime date) async {
    final repository = ref.read(trackingRepositoryProvider);
    return await repository.getWeightLog(userId, date);
  }

  // 최근 증량일 조회
  Future<DateTime?> getLatestDoseEscalationDate(String userId) async {
    final repository = ref.read(trackingRepositoryProvider);
    return await repository.getLatestDoseEscalationDate(userId);
  }
}
