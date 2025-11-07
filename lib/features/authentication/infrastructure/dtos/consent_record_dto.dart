import 'package:isar/isar.dart';
import 'package:n06/features/authentication/domain/entities/consent_record.dart';

part 'consent_record_dto.g.dart';

/// Isar DTO for ConsentRecord entity.
///
/// Stores user consent information in Isar local database.
@collection
class ConsentRecordDto {
  ConsentRecordDto();

  Id id = Isar.autoIncrement;

  @Index()
  late String userId;

  late bool termsOfService;
  late bool privacyPolicy;
  late DateTime agreedAt;

  /// Converts DTO to Domain Entity.
  ConsentRecord toEntity() {
    return ConsentRecord(
      id: id.toString(),
      userId: userId,
      termsOfService: termsOfService,
      privacyPolicy: privacyPolicy,
      agreedAt: agreedAt,
    );
  }

  /// Creates DTO from Domain Entity.
  factory ConsentRecordDto.fromEntity(ConsentRecord entity) {
    return ConsentRecordDto()
      ..id = entity.id.isNotEmpty ? int.tryParse(entity.id) ?? Isar.autoIncrement : Isar.autoIncrement
      ..userId = entity.userId
      ..termsOfService = entity.termsOfService
      ..privacyPolicy = entity.privacyPolicy
      ..agreedAt = entity.agreedAt;
  }
}
