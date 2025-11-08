import 'package:isar/isar.dart';
import 'package:n06/features/tracking/domain/entities/emergency_symptom_check.dart';

part 'emergency_symptom_check_dto.g.dart';

/// F005: Isar를 위한 증상 체크 DTO (Data Transfer Object)
///
/// Isar의 컬렉션으로 등록되며, Domain Entity와 DB 사이의 변환을 담당합니다.
/// - Isar의 자동 증가 ID를 사용합니다.
/// - checkedSymptoms는 PostgreSQL jsonb에 해당하므로 List<String>으로 매핑합니다.
/// - Phase 1 전환 시 Supabase에서는 jsonb 타입으로 직접 사용합니다.
@collection
class EmergencySymptomCheckDto {
  /// Isar 자동 증가 ID
  Id id = Isar.autoIncrement;

  /// 사용자 ID (인덱싱: 사용자별 조회 최적화)
  @Index()
  late String userId;

  /// 증상 체크 일시 (인덱싱: 시간순 정렬 최적화)
  @Index()
  late DateTime checkedAt;

  /// 선택된 증상 목록
  late List<String> checkedSymptoms;

  /// Unnamed constructor (Isar 요구사항)
  EmergencySymptomCheckDto();

  /// Domain Entity로 변환
  EmergencySymptomCheck toEntity() {
    return EmergencySymptomCheck(
      id: id.toString(),
      userId: userId,
      checkedAt: checkedAt,
      checkedSymptoms: checkedSymptoms,
    );
  }

  /// Domain Entity로부터 생성
  factory EmergencySymptomCheckDto.fromEntity(
    EmergencySymptomCheck entity,
  ) {
    return EmergencySymptomCheckDto()
      ..userId = entity.userId
      ..checkedAt = entity.checkedAt
      ..checkedSymptoms = entity.checkedSymptoms;
  }
}
