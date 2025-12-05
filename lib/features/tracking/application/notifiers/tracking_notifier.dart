import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/application/providers.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';

part 'tracking_notifier.g.dart';

class TrackingState {
  final List<WeightLog> weights;

  const TrackingState({
    required this.weights,
  });

  TrackingState copyWith({
    List<WeightLog>? weights,
  }) {
    return TrackingState(
      weights: weights ?? this.weights,
    );
  }
}

@riverpod
class TrackingNotifier extends _$TrackingNotifier {
  // ✅ 의존성을 late final 필드로 선언
  late final _repository = ref.read(trackingRepositoryProvider);

  @override
  Future<TrackingState> build() async {
    final userId = ref.watch(authNotifierProvider).value?.id;

    // userId가 없으면 빈 상태 반환
    if (userId == null) {
      return const TrackingState(
        weights: [],
      );
    }

    // userId가 있으면 데이터 로드
    final weights = await _repository.getWeightLogs(userId);

    return TrackingState(
      weights: weights,
    );
  }


  // 체중 기록 저장
  Future<void> saveWeightLog(WeightLog log) async {
    // ✅ 작업 완료 보장을 위한 keepAlive
    final link = ref.keepAlive();

    // 저장 전 현재 상태 백업
    final previousState = state.value ?? const TrackingState(
      weights: [],
    );

    state = const AsyncValue.loading();

    // userId 미리 캡처
    final userId = ref.read(authNotifierProvider).value?.id;

    try {
      state = await AsyncValue.guard(() async {
        await _repository.saveWeightLog(log);

        // ✅ async gap 후 mounted 체크
        if (!ref.mounted) {
          return previousState;
        }

        if (userId != null) {
          final weights = await _repository.getWeightLogs(userId);
          return previousState.copyWith(weights: weights);
        }

        return previousState;
      });
    } finally {
      link.close();
    }
  }


  // 체중 기록 삭제
  Future<void> deleteWeightLog(String id) async {
    // ✅ 작업 완료 보장을 위한 keepAlive
    final link = ref.keepAlive();

    final previousState = state.value ?? const TrackingState(
      weights: [],
    );

    state = const AsyncValue.loading();

    // userId 미리 캡처
    final userId = ref.read(authNotifierProvider).value?.id;

    try {
      state = await AsyncValue.guard(() async {
        await _repository.deleteWeightLog(id);

        // ✅ async gap 후 mounted 체크
        if (!ref.mounted) {
          return previousState;
        }

        if (userId != null) {
          final weights = await _repository.getWeightLogs(userId);
          return previousState.copyWith(weights: weights);
        }

        return previousState;
      });
    } finally {
      link.close();
    }
  }


  // 체중 기록 업데이트
  Future<void> updateWeightLog(String id, double newWeight) async {
    // ✅ 작업 완료 보장을 위한 keepAlive
    final link = ref.keepAlive();

    final previousState = state.value ?? const TrackingState(
      weights: [],
    );

    state = const AsyncValue.loading();

    // userId 미리 캡처
    final userId = ref.read(authNotifierProvider).value?.id;

    try {
      state = await AsyncValue.guard(() async {
        await _repository.updateWeightLog(id, newWeight);

        // ✅ async gap 후 mounted 체크
        if (!ref.mounted) {
          return previousState;
        }

        if (userId != null) {
          final weights = await _repository.getWeightLogs(userId);
          return previousState.copyWith(weights: weights);
        }

        return previousState;
      });
    } finally {
      link.close();
    }
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
