import 'package:isar/isar.dart';

import '../../domain/entities/guide_feedback.dart';
import '../../domain/repositories/feedback_repository.dart';
import '../dtos/guide_feedback_dto.dart';

/// Isar를 통한 피드백 저장 구현체
class IsarFeedbackRepository implements FeedbackRepository {
  final Isar isar;

  IsarFeedbackRepository(this.isar);

  @override
  Future<void> saveFeedback(GuideFeedback feedback) async {
    final dto = GuideFeedbackDto.fromEntity(feedback);
    await isar.writeTxn(() async {
      await isar.guideFeedbackDtos.put(dto);
    });
  }

  @override
  Future<List<GuideFeedback>> getFeedbacksBySymptom(String symptomName) async {
    final dtos = await isar.guideFeedbackDtos
        .filter()
        .symptomNameEqualTo(symptomName)
        .findAll();
    return dtos.map((dto) => dto.toEntity()).toList();
  }
}
