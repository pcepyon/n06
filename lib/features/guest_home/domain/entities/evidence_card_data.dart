/// 과학적 근거 카드 데이터 모델
class EvidenceCardData {
  final String id;
  final String icon;
  final String title;
  final String mainStat;
  final String mainStatUnit;
  final String subStat;

  /// 한 줄 요약 (기본 표시)
  final String summary;

  /// 상세 설명 (확장 시 표시)
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
    required this.summary,
    required this.description,
    required this.source,
    required this.sourceDetail,
    this.sourceUrl,
  });
}
