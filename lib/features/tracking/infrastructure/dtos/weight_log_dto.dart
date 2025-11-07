import 'package:isar/isar.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';

part 'weight_log_dto.g.dart';

@collection
class WeightLogDto {
  Id id = Isar.autoIncrement;
  late String userId;
  late DateTime logDate;
  late double weightKg;
  late DateTime createdAt;

  WeightLogDto();

  WeightLog toEntity() {
    return WeightLog(
      id: id.toString(),
      userId: userId,
      logDate: logDate,
      weightKg: weightKg,
      createdAt: createdAt,
    );
  }

  factory WeightLogDto.fromEntity(WeightLog entity) {
    return WeightLogDto()
      ..userId = entity.userId
      ..logDate = entity.logDate
      ..weightKg = entity.weightKg
      ..createdAt = entity.createdAt;
  }

  @override
  String toString() =>
      'WeightLogDto(id: $id, userId: $userId, logDate: $logDate, weightKg: $weightKg, createdAt: $createdAt)';
}
