import 'package:isar/isar.dart';
import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';
import 'package:n06/features/onboarding/domain/repositories/medication_repository.dart';
import 'package:n06/features/tracking/infrastructure/dtos/dosage_plan_dto.dart';

/// Isar 기반 MedicationRepository 구현
class IsarMedicationRepository implements MedicationRepository {
  final Isar _isar;

  IsarMedicationRepository(this._isar);

  @override
  Future<void> saveDosagePlan(DosagePlan plan) async {
    final dto = DosagePlanDto.fromEntity(plan);
    // 트랜잭션 내에서 호출될 수 있으므로 writeTxn 제거
    await _isar.dosagePlanDtos.put(dto);
  }

  @override
  Future<DosagePlan?> getActiveDosagePlan(String userId) async {
    final dto = await _isar.dosagePlanDtos
        .filter()
        .userIdEqualTo(userId)
        .isActiveEqualTo(true)
        .findFirst();
    return dto?.toEntity();
  }

  @override
  Future<void> updateDosagePlan(DosagePlan plan) async {
    final dto = DosagePlanDto.fromEntity(plan);
    // 트랜잭션 내에서 호출될 수 있으므로 writeTxn 제거
    await _isar.dosagePlanDtos.put(dto);
  }
}
