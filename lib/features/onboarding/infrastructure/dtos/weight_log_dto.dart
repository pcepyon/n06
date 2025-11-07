import 'package:isar/isar.dart';
import 'package:n06/features/onboarding/domain/entities/weight_log.dart';
import 'package:n06/features/onboarding/domain/value_objects/weight.dart';

part 'weight_log_dto.g.dart';

@collection
class WeightLogDto {
  Id isarId = Isar.autoIncrement;

  late String id;
  late String userId;
  late DateTime logDate;
  late double weightKg;
  late DateTime createdAt;

  /// DTO를 Domain Entity로 변환한다.
  WeightLog toEntity() {
    return WeightLog(
      id: id,
      userId: userId,
      logDate: logDate,
      weight: Weight.create(weightKg),
      createdAt: createdAt,
    );
  }

  /// Domain Entity를 DTO로 변환한다.
  static WeightLogDto fromEntity(WeightLog entity) {
    return WeightLogDto()
      ..id = entity.id
      ..userId = entity.userId
      ..logDate = entity.logDate
      ..weightKg = entity.weight.value
      ..createdAt = entity.createdAt;
  }
}
