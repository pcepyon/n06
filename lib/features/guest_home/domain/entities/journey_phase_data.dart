/// 치료 여정 단계 데이터 모델
class JourneyPhaseData {
  final String id;
  final String title;
  final String weekRange;
  final String shortLabel;
  final String description;
  final String expectationsTitle;
  final List<String> expectations;
  final String encouragement;

  const JourneyPhaseData({
    required this.id,
    required this.title,
    required this.weekRange,
    required this.shortLabel,
    required this.description,
    required this.expectationsTitle,
    required this.expectations,
    required this.encouragement,
  });
}
