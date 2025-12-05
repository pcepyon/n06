/// 앱 기능 소개 카드 데이터 모델
class AppFeatureData {
  final String id;
  final String icon;
  final String title;
  final List<String> painPoints;
  final String description;
  final String encouragement;
  final String relatedFeatureId;

  const AppFeatureData({
    required this.id,
    required this.icon,
    required this.title,
    required this.painPoints,
    required this.description,
    required this.encouragement,
    required this.relatedFeatureId,
  });
}
