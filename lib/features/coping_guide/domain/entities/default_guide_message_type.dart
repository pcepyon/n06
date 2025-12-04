/// 기본 대처 가이드 메시지 타입
///
/// 증상별 가이드가 없을 때 표시되는 기본 메시지의 종류를 정의합니다.
/// Application Layer에서 기본 가이드를 식별하고,
/// Presentation Layer에서 i18n 문자열로 매핑합니다.
///
/// NOTE: 모든 메시지는 MEDICAL REVIEW 태그가 필요합니다.
class DefaultGuideMessageType {
  /// 기본 가이드 마커
  static const String defaultSymptomName = '__default__symptom_name__';
  static const String defaultShortGuide = '__default__short_guide__';
  static const String defaultReassuranceMessage =
      '__default__reassurance_message__';
  static const String defaultImmediateAction = '__default__immediate_action__';
}
