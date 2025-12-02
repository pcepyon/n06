import 'package:n06/features/tracking/domain/entities/weight_log.dart';

/// 체중 추적 데이터 저장소 인터페이스
///
/// 이 Repository는 다음 데이터를 관리합니다:
/// - weight_logs: 체중 기록 (공통 테이블)
///
/// weight_logs는 여러 기능에서 공통으로 사용되는 독립 테이블입니다.
/// Repository Pattern에 따라 단일 구현체를 통해 데이터 접근을 추상화합니다.
///
/// Current: SupabaseTrackingRepository (cloud-first architecture)
abstract class TrackingRepository {
  // 체중 기록
  Future<void> saveWeightLog(WeightLog log);
  Future<WeightLog?> getWeightLog(String userId, DateTime logDate);
  Future<WeightLog?> getWeightLogById(String id);
  Future<List<WeightLog>> getWeightLogs(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<void> deleteWeightLog(String id);
  Future<void> updateWeightLog(String id, double newWeight);
  Future<void> updateWeightLogWithDate(String id, double newWeight, DateTime newDate);
  Stream<List<WeightLog>> watchWeightLogs(String userId);

  // 경과일 계산을 위한 최근 증량일 조회
  Future<DateTime?> getLatestDoseEscalationDate(String userId);
}
