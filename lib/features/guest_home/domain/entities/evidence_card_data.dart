/// 과학적 근거 카드 데이터 모델
class EvidenceCardData {
  final String id;
  final String icon;
  final String title;
  final String mainStat;
  final String mainStatUnit;
  final String subStat;
  final String description;
  final String source;
  final String sourceDetail;
  final String? sourceUrl;

  const EvidenceCardData({
    required this.id,
    required this.icon,
    required this.title,
    required this.mainStat,
    required this.mainStatUnit,
    required this.subStat,
    required this.description,
    required this.source,
    required this.sourceDetail,
    this.sourceUrl,
  });
}
