import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';
import 'package:n06/features/tracking/domain/repositories/tracking_repository.dart';
import 'package:n06/features/tracking/application/providers.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';

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

class TrackingNotifier extends AsyncNotifier<TrackingState> {
  late final TrackingRepository _repository;
  late final String? _userId;

  @override
  Future<TrackingState> build() async {
    // Provider에서 의존성 주입
    _repository = ref.watch(trackingRepositoryProvider);
    _userId = ref.watch(authNotifierProvider).value?.id;

    // userId가 없으면 빈 상태 반환
    if (_userId == null) {
      return const TrackingState(
        weights: [],
        symptoms: [],
      );
    }

    // userId가 있으면 데이터 로드
    final weights = await _repository.getWeightLogs(_userId);
    final symptoms = await _repository.getSymptomLogs(_userId);

    return TrackingState(
      weights: weights,
      symptoms: symptoms,
    );
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
      await _repository.saveWeightLog(log);

      if (_userId != null) {
        final weights = await _repository.getWeightLogs(_userId);
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
      await _repository.saveSymptomLog(log);

      if (_userId != null) {
        final symptoms = await _repository.getSymptomLogs(_userId);
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
      await _repository.deleteWeightLog(id);

      if (_userId != null) {
        final weights = await _repository.getWeightLogs(_userId);
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
      await _repository.deleteSymptomLog(id);

      if (_userId != null) {
        final symptoms = await _repository.getSymptomLogs(_userId);
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
      await _repository.updateWeightLog(id, newWeight);

      if (_userId != null) {
        final weights = await _repository.getWeightLogs(_userId);
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
      await _repository.updateSymptomLog(id, updatedLog);

      if (_userId != null) {
        final symptoms = await _repository.getSymptomLogs(_userId);
        return previousState.copyWith(symptoms: symptoms);
      }

      return previousState;
    });
  }

  // 특정 날짜의 체중 기록 확인
  Future<bool> hasWeightLogOnDate(String userId, DateTime date) async {
    final existing = await _repository.getWeightLog(userId, date);
    return existing != null;
  }

  // 특정 날짜의 체중 기록 조회
  Future<WeightLog?> getWeightLog(String userId, DateTime date) async {
    return await _repository.getWeightLog(userId, date);
  }

  // 최근 증량일 조회
  Future<DateTime?> getLatestDoseEscalationDate(String userId) async {
    return await _repository.getLatestDoseEscalationDate(userId);
  }
}
