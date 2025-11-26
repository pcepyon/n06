import 'package:n06/features/tracking/domain/entities/emergency_symptom_check.dart';

/// F005: 증상 체크 데이터 접근 계약 인터페이스
///
/// Domain Layer에서 정의하는 Repository Interface는
/// Infrastructure Layer의 구현체로 대체됩니다 (Repository Pattern).
/// Current: SupabaseEmergencyCheckRepository (cloud-first architecture)
abstract class EmergencyCheckRepository {
  /// 증상 체크 정보 저장 또는 생성
  Future<void> saveEmergencyCheck(EmergencySymptomCheck check);

  /// 사용자의 증상 체크 이력 조회 (최신순 정렬)
  Future<List<EmergencySymptomCheck>> getEmergencyChecks(String userId);

  /// 증상 체크 기록 삭제
  Future<void> deleteEmergencyCheck(String id);

  /// 증상 체크 기록 수정 (업데이트)
  Future<void> updateEmergencyCheck(EmergencySymptomCheck check);
}
