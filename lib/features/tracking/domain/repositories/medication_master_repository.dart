import 'package:n06/features/tracking/domain/entities/medication.dart';

/// 약물 마스터 데이터 Repository 인터페이스
///
/// medications 마스터 테이블에서 약물 정보를 조회합니다.
/// 읽기 전용 Repository입니다 (마스터 데이터 수정은 DB에서 직접).
abstract class MedicationMasterRepository {
  /// 활성화된 모든 약물 목록 조회
  ///
  /// display_order 순으로 정렬됩니다.
  Future<List<Medication>> getActiveMedications();

  /// ID로 약물 조회
  Future<Medication?> getMedicationById(String id);

  /// displayName으로 약물 조회
  ///
  /// 기존 dosage_plans.medication_name과 매칭할 때 사용합니다.
  /// displayName 형식: "Wegovy (세마글루타이드)"
  Future<Medication?> getMedicationByDisplayName(String displayName);
}
