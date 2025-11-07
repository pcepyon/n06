import '../entities/guide_feedback.dart';

/// 가이드 피드백 저장 인터페이스
abstract class FeedbackRepository {
  /// 피드백 저장
  ///
  /// [feedback]: 저장할 피드백
  Future<void> saveFeedback(GuideFeedback feedback);

  /// 증상별 피드백 조회
  ///
  /// [symptomName]: 증상 이름
  /// 반환: 해당 증상의 피드백 리스트
  Future<List<GuideFeedback>> getFeedbacksBySymptom(String symptomName);
}
