import 'package:isar/isar.dart';
import 'package:n06/features/onboarding/domain/entities/weight_log.dart';
import 'package:n06/features/onboarding/domain/repositories/tracking_repository.dart';
import 'package:n06/features/onboarding/infrastructure/dtos/weight_log_dto.dart';

/// Isar 기반 TrackingRepository 구현
class IsarTrackingRepository implements TrackingRepository {
  final Isar _isar;

  IsarTrackingRepository(this._isar);

  @override
  Future<void> saveWeightLog(WeightLog log) async {
    final dto = WeightLogDto.fromEntity(log);
    await _isar.writeTxn(() async {
      await _isar.weightLogDtos.put(dto);
    });
  }

  @override
  Future<List<WeightLog>> getWeightLogs(String userId) async {
    final dtos = await _isar.weightLogDtos
        .filter()
        .userIdEqualTo(userId)
        .findAll();
    return dtos.map((dto) => dto.toEntity()).toList();
  }
}
