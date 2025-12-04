/// 긍정 피드백 타입
///
/// 체크인 질문에 대한 긍정적인 답변 시 제공되는 피드백의 종류입니다.
/// Application Layer에서 이 enum을 반환하고,
/// Presentation Layer에서 l10n으로 변환하여 표시합니다.
enum PositiveFeedbackType {
  // Q1 식사
  goodMeal, // '좋아요! 규칙적인 식사가 치료에 도움이 돼요 💚'
  moderateMeal, // '괜찮아요, 소량씩 드시는 것도 좋아요'

  // Q2 수분
  goodHydration, // '잘하셨어요! 수분 섭취가 정말 중요해요 💧'
  moderateHydration, // '내일은 조금 더 챙겨보세요'

  // Q3 속 편안함
  goodComfort, // '다행이에요! 💚'

  // Q4 배변
  normalBowel, // '좋아요! 규칙적인 게 중요해요'

  // Q5 에너지
  goodEnergy, // '좋은 하루였네요! ⚡'
  normalEnergy, // '꾸준히 유지하고 계시네요'

  // Q6 기분
  goodMood, // '좋은 하루였네요! 😊'
  neutralMood, // '그런 날도 있죠. 내일은 더 좋을 거예요'
  lowMood, // '힘든 날도 있어요. 당신은 잘하고 있어요 💚'

  // 기본 (매핑 없을 경우)
  generic, // '좋아요!'
}

/// 지지 피드백 타입
///
/// 증상을 선택했을 때 제공되는 안심/지지 메시지의 종류입니다.
/// CopingGuide에 데이터가 있으면 그것을 사용하고,
/// 없으면 기본 메시지를 표시합니다.
enum SupportiveFeedbackType {
  // SymptomType별 기본 지지 메시지
  nausea, // '메스꺼움은 흔한 증상이에요. 조금씩 나아질 거예요'
  vomiting, // '힘드셨죠. 물을 조금씩 자주 마셔보세요'
  lowAppetite, // '입맛이 없는 건 약이 작용하고 있다는 신호일 수 있어요'
  earlySatiety, // '포만감이 빨리 오는 건 약이 잘 작용하고 있는 거예요'
  heartburn, // '식후 바로 눕지 않는 게 도움이 돼요'
  abdominalPain, // '복통은 잠시 지켜보시고, 계속되면 병원에 연락해주세요'
  bloating, // '배가 빵빵한 건 일시적일 수 있어요'
  constipation, // '수분과 섬유질을 충분히 섭취해보세요'
  diarrhea, // '수분 섭취를 충분히 해주세요'
  fatigue, // '충분히 쉬어주세요. 몸이 적응 중이에요'
  dizziness, // '어지러움이 계속되면 병원에 연락해주세요'
  coldSweat, // '식은땀이 나면 당분을 섭취하고 쉬어주세요'
  swelling, // '붓기가 심하면 병원에서 확인받아 보세요'
}

/// 완료 피드백 요소 타입
///
/// 체크인 완료 시 표시되는 종합 피드백의 구성 요소입니다.
/// 긍정적 요소와 격려 요소를 조합하여 최종 메시지를 생성합니다.
enum CompletionFeedbackElement {
  // 긍정적 요소
  goodMeal, // '식사를 잘 하셨네요'
  goodHydration, // '수분 섭취도 충분히 하셨고요'
  goodEnergy, // '에너지도 괜찮으셨군요'
  noSymptoms, // '오늘 특별한 불편함 없이 잘 보내셨네요'

  // 격려 요소
  bodyAdapting, // '몸이 적응하는 중이에요. 잘 견디고 계세요'
  consecutiveDays, // '벌써 {days}일째 기록 중이시네요!' (placeholder 필요)
}

/// Red Flag 안내 타입
///
/// Red Flag 감지 시 표시되는 안내 메시지의 종류입니다.
/// RedFlagType과 1:1 매핑됩니다.
enum RedFlagGuidanceType {
  pancreatitis, // 급성 췌장염
  cholecystitis, // 담낭염
  severeDehydration, // 심한 탈수
  bowelObstruction, // 장폐색
  hypoglycemia, // 저혈당
  renalImpairment, // 신부전
  generic, // 기본 안내 메시지
}
