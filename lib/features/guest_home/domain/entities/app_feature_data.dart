/// 앱 기능 소개 카드 데이터 모델
class AppFeatureData {
  final String id;
  final String icon;
  final String title;

  /// 한 줄 요약 (기본 표시)
  final String summary;

  /// 상세 설명 (확장 시 표시)
  final String description;
  final String encouragement;
  final String relatedFeatureId;

  const AppFeatureData({
    required this.id,
    required this.icon,
    required this.title,
    required this.summary,
    required this.description,
    required this.encouragement,
    required this.relatedFeatureId,
  });
}
