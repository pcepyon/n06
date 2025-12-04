/// 체크인 인사말 타입
///
/// 체크인 시작 시 표시되는 인사말의 종류를 정의합니다.
/// Application Layer에서 컨텍스트를 판단하여 타입을 반환하고,
/// Presentation Layer에서 i18n 문자열로 매핑합니다.
enum GreetingMessageType {
  /// 복귀 사용자 인사 (7일 이상 공백)
  returningLongGap,

  /// 복귀 사용자 인사 (3-6일 공백)
  returningShortGap,

  /// 주사 다음날 인사
  postInjection,

  /// 아침 인사 1
  morningOne,

  /// 아침 인사 2
  morningTwo,

  /// 아침 인사 3
  morningThree,

  /// 오후 인사 1
  afternoonOne,

  /// 오후 인사 2
  afternoonTwo,

  /// 오후 인사 3
  afternoonThree,

  /// 저녁 인사 1
  eveningOne,

  /// 저녁 인사 2
  eveningTwo,

  /// 저녁 인사 3
  eveningThree,

  /// 밤 인사 1
  nightOne,

  /// 밤 인사 2
  nightTwo,

  /// 밤 인사 3
  nightThree,
}
