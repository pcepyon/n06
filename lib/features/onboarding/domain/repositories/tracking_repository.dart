import 'package:n06/features/onboarding/domain/entities/weight_log.dart';

/// 추적 데이터(체중 등) 접근 계약을 정의하는 Repository Interface
abstract class TrackingRepository {
  /// 체중 기록을 저장한다.
  Future<void> saveWeightLog(WeightLog log);

  /// 사용자의 체중 기록을 조회한다.
  Future<List<WeightLog>> getWeightLogs(String userId);
}
