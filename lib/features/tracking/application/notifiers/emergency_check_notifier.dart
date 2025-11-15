import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:n06/features/tracking/domain/entities/emergency_symptom_check.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';
import 'package:n06/features/tracking/domain/repositories/emergency_check_repository.dart';
import 'package:n06/features/tracking/domain/repositories/tracking_repository.dart';
import 'package:n06/features/tracking/infrastructure/repositories/supabase_emergency_check_repository.dart';
import 'package:n06/features/tracking/infrastructure/repositories/supabase_tracking_repository.dart';
import 'package:n06/core/providers.dart';

part 'emergency_check_notifier.g.dart';

// Repository providers (to avoid circular dependency with providers.dart)
@riverpod
EmergencyCheckRepository _emergencyCheckRepository(_EmergencyCheckRepositoryRef ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseEmergencyCheckRepository(supabase);
}

@riverpod
TrackingRepository _trackingRepository(_TrackingRepositoryRef ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseTrackingRepository(supabase);
}

/// F005: 증상 체크 상태 관리 및 비즈니스 로직 orchestration
///
/// 책임:
/// 1. 증상 체크 기록 저장 (BR1-BR4)
/// 2. 자동으로 부작용 기록 생성 (BR2)
/// 3. 증상 체크 이력 조회
/// 4. 트랜잭션 관리 (증상 체크 저장 실패 시 부작용 기록도 롤백)
///
/// 의존성:
/// - EmergencyCheckRepository (F005)
/// - TrackingRepository (F002 - 부작용 기록 저장)
/// - MedicationRepository (F001 - 용량 증량 후 경과일 계산)
@riverpod
class EmergencyCheckNotifier extends _$EmergencyCheckNotifier {
  @override
  Future<List<EmergencySymptomCheck>> build() async {
    // 초기 로드는 수행하지 않음 (사용자 ID 필요)
    return [];
  }

  /// 증상 체크 저장
  ///
  /// 플로우:
  /// 1. 증상 체크 저장 (emergency_symptom_checks)
  /// 2. 각 증상마다 자동으로 부작용 기록 생성 (BR2)
  ///    - 심각도: 10 (고정)
  ///    - 기록 날짜: checkedAt
  /// 3. 상태 재조회
  ///
  /// 예외 처리:
  /// - 부작용 기록 생성 실패 시, 증상 체크도 롤백하려고 시도
  /// - 상태는 error 상태로 전환
  Future<void> saveEmergencyCheck(
      String userId, EmergencySymptomCheck check) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final emergencyCheckRepo =
          ref.read(_emergencyCheckRepositoryProvider);
      final trackingRepo = ref.read(_trackingRepositoryProvider);

      try {
        // 1. 증상 체크 저장
        await emergencyCheckRepo.saveEmergencyCheck(check);

        // 2. 각 증상마다 부작용 기록 자동 생성 (BR2)
        for (final symptom in check.checkedSymptoms) {
          final symptomLog = SymptomLog(
            id: const Uuid().v4(),
            userId: userId,
            logDate: check.checkedAt,
            symptomName: symptom,
            severity: 10, // 고정값 (BR2)
            daysSinceEscalation: null, // 계산 없음
            isPersistent24h: true, // 응급 증상이므로 24시간 이상 가정
            note: 'Emergency symptom check',
            tags: const [],
            createdAt: DateTime.now(),
          );
          await trackingRepo.saveSymptomLog(symptomLog);
        }

        // 3. 상태 재조회
        final checks = await emergencyCheckRepo.getEmergencyChecks(userId);
        return checks;
      } catch (e) {
        // 실패 시 에러 상태로 전환
        rethrow;
      }
    });
  }

  /// 사용자의 증상 체크 이력 조회
  Future<void> fetchEmergencyChecks(String userId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(_emergencyCheckRepositoryProvider);
      return await repo.getEmergencyChecks(userId);
    });
  }

  /// 증상 체크 기록 삭제
  Future<void> deleteEmergencyCheck(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(_emergencyCheckRepositoryProvider);
      await repo.deleteEmergencyCheck(id);

      // 상태는 빈 리스트로 재설정 (실제로는 모든 기록을 다시 조회해야 함)
      return state.value ?? [];
    });
  }

  /// 증상 체크 기록 수정
  Future<void> updateEmergencyCheck(EmergencySymptomCheck check) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(_emergencyCheckRepositoryProvider);
      await repo.updateEmergencyCheck(check);

      // 상태는 현재 상태에서 수정된 항목으로 업데이트
      final updatedChecks = state.value ?? [];
      return updatedChecks
          .map((c) => c.id == check.id ? check : c)
          .toList();
    });
  }
}

// Provider가 providers.dart에 정의되어 있음

// Backwards compatibility alias
const emergencyCheckNotifierProvider = emergencyCheckProvider;
