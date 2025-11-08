import 'package:isar/isar.dart';
import 'package:n06/features/tracking/domain/entities/emergency_symptom_check.dart';
import 'package:n06/features/tracking/domain/repositories/emergency_check_repository.dart';
import 'package:n06/features/tracking/infrastructure/dtos/emergency_symptom_check_dto.dart';

/// F005: Isar를 사용한 EmergencyCheckRepository 구현체
///
/// Phase 0: Isar 로컬 DB 사용
/// Phase 1: SupabaseEmergencyCheckRepository로 대체됨
/// (Repository Pattern으로 Implementation만 교체됨, Interface는 유지)
class IsarEmergencyCheckRepository implements EmergencyCheckRepository {
  final Isar _isar;

  IsarEmergencyCheckRepository(this._isar);

  @override
  Future<void> saveEmergencyCheck(EmergencySymptomCheck check) async {
    final dto = EmergencySymptomCheckDto.fromEntity(check);
    await _isar.writeTxn(() async {
      await _isar.emergencySymptomCheckDtos.put(dto);
    });
  }

  @override
  Future<List<EmergencySymptomCheck>> getEmergencyChecks(String userId) async {
    final dtos = await _isar.emergencySymptomCheckDtos
        .where()
        .userIdEqualTo(userId)
        .sortByCheckedAtDesc()
        .findAll();

    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<void> deleteEmergencyCheck(String id) async {
    final isarId = int.tryParse(id);
    if (isarId == null) return;

    await _isar.writeTxn(() async {
      await _isar.emergencySymptomCheckDtos.delete(isarId);
    });
  }

  @override
  Future<void> updateEmergencyCheck(EmergencySymptomCheck check) async {
    final isarId = int.tryParse(check.id);
    if (isarId == null) return;

    final dto = EmergencySymptomCheckDto.fromEntity(check);
    dto.id = isarId;

    await _isar.writeTxn(() async {
      await _isar.emergencySymptomCheckDtos.put(dto);
    });
  }
}
