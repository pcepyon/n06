import 'package:isar/isar.dart';

import '../../domain/entities/guide_feedback.dart';

part 'guide_feedback_dto.g.dart';

/// 가이드 피드백 DTO (Isar 모델)
@Collection()
class GuideFeedbackDto {
  Id id = Isar.autoIncrement;
  late String symptomName;
  late bool helpful;
  late DateTime timestamp;

  /// Entity로 변환
  GuideFeedback toEntity() => GuideFeedback(
        symptomName: symptomName,
        helpful: helpful,
        timestamp: timestamp,
      );

  /// Entity에서 DTO로 생성
  static GuideFeedbackDto fromEntity(GuideFeedback entity) {
    return GuideFeedbackDto()
      ..symptomName = entity.symptomName
      ..helpful = entity.helpful
      ..timestamp = entity.timestamp;
  }
}
