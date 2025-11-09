import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';

/// 투여 계획 접근 계약을 정의하는 Repository Interface
abstract class MedicationRepository {
  /// 투여 계획을 저장한다.
  Future<void> saveDosagePlan(DosagePlan plan);

  /// 활성 투여 계획을 조회한다.
  Future<DosagePlan?> getActiveDosagePlan(String userId);

  /// 투여 계획을 업데이트한다.
  Future<void> updateDosagePlan(DosagePlan plan);
}
