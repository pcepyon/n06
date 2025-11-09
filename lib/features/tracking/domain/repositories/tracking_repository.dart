import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';

/// 체중 및 증상 추적 데이터 저장소 인터페이스
///
/// 이 Repository는 다음 데이터를 관리합니다:
/// - weight_logs: 체중 기록 (공통 테이블)
/// - symptom_logs: 부작용 기록
/// - symptom_context_tags: 부작용 컨텍스트 태그
///
/// weight_logs는 여러 기능에서 공통으로 사용되는 독립 테이블입니다.
/// Repository Pattern에 따라 단일 구현체를 통해 데이터 접근을 추상화합니다.
///
/// Phase 0: IsarTrackingRepository (로컬 DB)
/// Phase 1: SupabaseTrackingRepository (클라우드 DB) - 1줄 변경으로 전환 가능
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

  // 증상 기록
  Future<void> saveSymptomLog(SymptomLog log);
  Future<SymptomLog?> getSymptomLogById(String id);
  Future<List<SymptomLog>> getSymptomLogs(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<void> deleteSymptomLog(String id, {bool cascade = true});
  Future<void> updateSymptomLog(String id, SymptomLog updatedLog);
  Stream<List<SymptomLog>> watchSymptomLogs(String userId);

  // 태그 기반 조회
  Future<List<SymptomLog>> getSymptomLogsByTag(String tagName);
  Future<List<String>> getAllTags(String userId);

  // 경과일 계산을 위한 최근 증량일 조회
  Future<DateTime?> getLatestDoseEscalationDate(String userId);
}
