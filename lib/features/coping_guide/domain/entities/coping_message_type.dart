/// 대처법 가이드 메시지 타입
///
/// 부작용 대처법 가이드에 사용되는 메시지의 종류를 정의합니다.
/// Application Layer에서 컨텍스트를 판단하여 타입을 반환하고,
/// Presentation Layer에서 i18n 문자열로 매핑합니다.
///
/// NOTE: 모든 메시지는 MEDICAL REVIEW 태그가 필요합니다.
enum CopingMessageType {
  /// 기본 가이드: 증상명 (일반)
  defaultSymptomName,

  /// 기본 가이드: 짧은 안내
  defaultShortGuide,

  /// 기본 가이드: 안심 메시지
  defaultReassuranceMessage,

  /// 기본 가이드: 즉시 조치
  defaultImmediateAction,
}

/// 대처법 가이드 기본값 데이터
///
/// Application Layer에서 기본 가이드를 생성할 때 사용할 타입 정보를 담습니다.
class CopingGuideDefaultData {
  final CopingMessageType symptomNameType;
  final CopingMessageType shortGuideType;
  final CopingMessageType reassuranceMessageType;
  final CopingMessageType immediateActionType;

  const CopingGuideDefaultData({
    this.symptomNameType = CopingMessageType.defaultSymptomName,
    this.shortGuideType = CopingMessageType.defaultShortGuide,
    this.reassuranceMessageType = CopingMessageType.defaultReassuranceMessage,
    this.immediateActionType = CopingMessageType.defaultImmediateAction,
  });
}
