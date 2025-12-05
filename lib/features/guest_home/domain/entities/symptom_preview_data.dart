/// 증상 미리보기 카드 데이터 모델
class SymptomPreviewData {
  final String id;
  final String icon;
  final String name;
  final String shortDescription;
  final String fullDescription;
  final List<String> tips;
  final String recoveryInfo;
  final double frequencyPercent;
  final String recoveryTime;

  const SymptomPreviewData({
    required this.id,
    required this.icon,
    required this.name,
    required this.shortDescription,
    required this.fullDescription,
    required this.tips,
    required this.recoveryInfo,
    required this.frequencyPercent,
    required this.recoveryTime,
  });
}
