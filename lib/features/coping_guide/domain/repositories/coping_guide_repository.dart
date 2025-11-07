import '../entities/coping_guide.dart';

/// 부작용 대처 가이드 조회 인터페이스
abstract class CopingGuideRepository {
  /// 증상명으로 가이드 조회
  ///
  /// [symptomName]: 증상 이름
  /// 반환: 해당 증상의 가이드, 없으면 null
  Future<CopingGuide?> getGuideBySymptom(String symptomName);

  /// 모든 증상의 가이드 목록 조회
  ///
  /// 반환: 모든 증상의 가이드 리스트
  Future<List<CopingGuide>> getAllGuides();
}
