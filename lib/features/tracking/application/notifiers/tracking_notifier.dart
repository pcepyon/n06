import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';
import 'package:n06/features/tracking/domain/repositories/tracking_repository.dart';

class TrackingState {
  final AsyncValue<List<WeightLog>> weights;
  final AsyncValue<List<SymptomLog>> symptoms;

  const TrackingState({
    required this.weights,
    required this.symptoms,
  });

  TrackingState copyWith({
    AsyncValue<List<WeightLog>>? weights,
    AsyncValue<List<SymptomLog>>? symptoms,
  }) {
    return TrackingState(
      weights: weights ?? this.weights,
      symptoms: symptoms ?? this.symptoms,
    );
  }
}

class TrackingNotifier extends StateNotifier<AsyncValue<TrackingState>> {
  final TrackingRepository _repository;
  final String? _userId;

  TrackingNotifier({
    required TrackingRepository repository,
    String? userId,
  })  : _repository = repository,
        _userId = userId,
        super(const AsyncValue.loading()) {
    _init();
  }

  void _init() async {
    // userId가 없으면 초기 상태 설정
    if (_userId == null) {
      state = const AsyncValue.data(TrackingState(
        weights: AsyncValue.data([]),
        symptoms: AsyncValue.data([]),
      ));
      return;
    }

    // userId가 있으면 데이터 로드
    final userId = _userId;
    final result = await AsyncValue.guard(() async {
      final weights = await _repository.getWeightLogs(userId);
      final symptoms = await _repository.getSymptomLogs(userId);

      return TrackingState(
        weights: AsyncValue.data(weights),
        symptoms: AsyncValue.data(symptoms),
      );
    });

    state = result;
  }

  // 체중 기록 저장
  Future<void> saveWeightLog(WeightLog log) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.saveWeightLog(log);

      final userId = _userId;
      if (userId != null) {
        final weights = await _repository.getWeightLogs(userId);
        final currentState = state.asData!.value;

        return currentState.copyWith(
          weights: AsyncValue.data(weights),
        );
      }

      return state.asData!.value;
    });
  }

  // 증상 기록 저장
  Future<void> saveSymptomLog(SymptomLog log) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.saveSymptomLog(log);

      if (_userId != null) {
        final symptoms = await _repository.getSymptomLogs(_userId);
        final currentState = state.asData!.value;

        return currentState.copyWith(
          symptoms: AsyncValue.data(symptoms),
        );
      }

      return state.asData!.value;
    });
  }

  // 체중 기록 삭제
  Future<void> deleteWeightLog(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteWeightLog(id);

      if (_userId != null) {
        final weights = await _repository.getWeightLogs(_userId);
        final currentState = state.asData!.value;

        return currentState.copyWith(
          weights: AsyncValue.data(weights),
        );
      }

      return state.asData!.value;
    });
  }

  // 증상 기록 삭제
  Future<void> deleteSymptomLog(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteSymptomLog(id);

      if (_userId != null) {
        final symptoms = await _repository.getSymptomLogs(_userId);
        final currentState = state.asData!.value;

        return currentState.copyWith(
          symptoms: AsyncValue.data(symptoms),
        );
      }

      return state.asData!.value;
    });
  }

  // 체중 기록 업데이트
  Future<void> updateWeightLog(String id, double newWeight) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.updateWeightLog(id, newWeight);

      if (_userId != null) {
        final weights = await _repository.getWeightLogs(_userId);
        final currentState = state.asData!.value;

        return currentState.copyWith(
          weights: AsyncValue.data(weights),
        );
      }

      return state.asData!.value;
    });
  }

  // 증상 기록 업데이트
  Future<void> updateSymptomLog(String id, SymptomLog updatedLog) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.updateSymptomLog(id, updatedLog);

      if (_userId != null) {
        final symptoms = await _repository.getSymptomLogs(_userId);
        final currentState = state.asData!.value;

        return currentState.copyWith(
          symptoms: AsyncValue.data(symptoms),
        );
      }

      return state.asData!.value;
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
