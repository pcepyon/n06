import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';

abstract class TrackingRepository {
  // 체중 기록
  Future<void> saveWeightLog(WeightLog log);
  Future<WeightLog?> getWeightLog(String userId, DateTime logDate);
  Future<List<WeightLog>> getWeightLogs(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<void> deleteWeightLog(String id);
  Future<void> updateWeightLog(String id, double newWeight);
  Stream<List<WeightLog>> watchWeightLogs(String userId);

  // 증상 기록
  Future<void> saveSymptomLog(SymptomLog log);
  Future<List<SymptomLog>> getSymptomLogs(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<void> deleteSymptomLog(String id);
  Future<void> updateSymptomLog(String id, SymptomLog updatedLog);
  Stream<List<SymptomLog>> watchSymptomLogs(String userId);

  // 태그 기반 조회
  Future<List<SymptomLog>> getSymptomLogsByTag(String tagName);
  Future<List<String>> getAllTags(String userId);

  // 경과일 계산을 위한 최근 증량일 조회
  Future<DateTime?> getLatestDoseEscalationDate(String userId);
}
