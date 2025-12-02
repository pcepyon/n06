/// 데일리 체크인 문자열 상수
///
/// UX 핵심 원칙:
/// - 일상적 대화 (의료 용어 금지)
/// - 친근한 안부 질문
/// - 격려와 지지 톤
/// - 두려움 최소화
library;

/// 시간대별 인사말
class GreetingStrings {
  /// 아침 (5-11시)
  static const morning = '좋은 아침이에요';

  /// 점심 (11-17시)
  static const afternoon = '오늘 하루 어떠세요?';

  /// 저녁 (17-21시)
  static const evening = '오늘 하루 수고하셨어요';

  /// 밤 (21-5시)
  static const night = '늦은 시간까지 수고 많으셨어요';

  /// 주사 다음날
  static const postInjection = '어제 주사 맞으셨죠? 오늘 컨디션은 어떠세요?';

  /// 복귀 사용자 (3일+ 공백)
  static const returnUser = '''다시 만나서 반가워요 😊
쉬어가는 것도 여정의 일부예요.
오늘부터 다시 함께해요!''';
}

/// 체중 입력 관련 문자열
class WeightInputStrings {
  static const title = '오늘 체중을 입력해주세요';
  static const unit = 'kg';
  static const previousLabel = '어제';
  static const nextButton = '다음';
  static const skipButton = '건너뛰기';
  static const skipHint = '나중에 기록해도 괜찮아요';

  /// 체중 변화 피드백
  static const feedbackDecreased = '조금 줄었네요! 💚';
  static const feedbackSame = '유지하고 계시네요';
  static const feedbackIncreased = '괜찮아요, 하루하루 변화가 있을 수 있어요';
}

/// Q1. 식사 질문
class MealQuestionStrings {
  static const question = '오늘 식사는 어떠셨어요?';
  static const emoji = '🍽️';

  // 답변 선택지
  static const answerGood = '잘 먹었어요';
  static const answerGoodEmoji = '😋';
  static const answerModerate = '적당히 먹었어요';
  static const answerModerateEmoji = '😐';
  static const answerDifficult = '좀 힘들었어요';
  static const answerDifficultEmoji = '😣';

  // 피드백
  static const feedbackGood = '좋아요! 규칙적인 식사가 치료에 도움이 돼요 💚';
  static const feedbackModerate = '괜찮아요, 소량씩 드시는 것도 좋아요';

  // 파생 질문: 힘들었던 이유
  static const derivedQuestion = '혹시 어떤 점이 힘드셨어요?';
  static const derivedNausea = '속이 메스꺼웠어요';
  static const derivedNauseaEmoji = '🤢';
  static const derivedLowAppetite = '입맛이 없었어요';
  static const derivedLowAppetiteEmoji = '😶';
  static const derivedEarlySatiety = '조금만 먹어도 배불러요';
  static const derivedEarlySatietyEmoji = '🍽️';

  // 파생 피드백
  static const feedbackLowAppetite = '입맛이 없는 건 약이 작용하고 있다는 신호일 수 있어요';
  static const feedbackEarlySatiety = '포만감이 빨리 오는 건 약이 잘 작용하고 있는 거예요';

  // Q1-1a: 메스꺼움 상세
  static const derivedNauseaSeverityQuestion = '메스꺼움이 어느 정도였나요?';
  static const nauseaMild = '살짝 느꼈어요';
  static const nauseaMildEmoji = '😐';
  static const nauseaModerate = '식사하기 힘들 정도';
  static const nauseaModerateEmoji = '😣';
  static const nauseaSevere = '물도 힘들었어요';
  static const nauseaSevereEmoji = '🤮';

  // Q1-1a 피드백
  static const feedbackNauseaMild = '가벼운 메스꺼움은 흔히 있어요. 며칠 내에 나아질 거예요';

  // Q1-1b: 구토 여부
  static const derivedVomitingQuestion = '혹시 토하신 적도 있으셨나요?';
  static const vomitingNone = '아니요';
  static const vomitingNoneEmoji = '😌';
  static const vomitingOnce = '1-2번 있었어요';
  static const vomitingOnceEmoji = '😣';
  static const vomitingSevere = '여러 번 (3번 이상)';
  static const vomitingSevereEmoji = '🤮';

  // Q1-1b 피드백
  static const feedbackVomitingOnce = '힘드셨죠. 물을 조금씩 자주 마셔보세요';
}

/// Q2. 수분 질문
class HydrationQuestionStrings {
  static const question = '물은 충분히 드셨나요?';
  static const emoji = '💧';

  // 답변 선택지
  static const answerGood = '충분히 마셨어요';
  static const answerGoodEmoji = '💧';
  static const answerModerate = '좀 적게 마신 것 같아요';
  static const answerModerateEmoji = '💧';
  static const answerPoor = '거의 못 마셨어요';
  static const answerPoorEmoji = '😰';

  // 피드백
  static const feedbackGood = '잘하셨어요! 수분 섭취가 정말 중요해요 💧';
  static const feedbackModerate = '내일은 조금 더 챙겨보세요';

  // Q2-1: 수분 섭취 어려움
  static const derivedQuestion = '물 마시기가 힘드셨나요?';
  static const derivedForgot = '그냥 깜빡했어요';
  static const derivedForgotEmoji = '😶';
  static const derivedNausea = '마시면 속이 안좋아서';
  static const derivedNauseaEmoji = '🤢';
  static const derivedCannotKeep = '마셔도 다 토해요';
  static const derivedCannotKeepEmoji = '🤮';

  // Q2-1 피드백
  static const feedbackForgot = '내일은 알람을 맞춰보는 건 어떨까요?';
  static const feedbackNausea = '조금씩 자주 마셔보세요. 이온음료도 좋아요';
}

/// Q3. 속 편안함 질문
class GiComfortQuestionStrings {
  static const question = '속은 편하셨어요?';
  static const emoji = '😌';

  // 답변 선택지
  static const answerGood = '네, 괜찮았어요';
  static const answerGoodEmoji = '😊';
  static const answerUncomfortable = '좀 불편했어요';
  static const answerUncomfortableEmoji = '😐';
  static const answerVeryUncomfortable = '많이 불편했어요';
  static const answerVeryUncomfortableEmoji = '😣';

  // 피드백
  static const feedbackGood = '다행이에요! 💚';

  // 파생 질문
  static const derivedQuestion = '어떤 불편함이 있으셨어요?';
  static const derivedHeartburn = '속이 쓰렸어요';
  static const derivedHeartburnEmoji = '🔥';
  static const derivedPain = '배가 아팠어요';
  static const derivedPainEmoji = '😣';
  static const derivedBloating = '배가 빵빵했어요';
  static const derivedBloatingEmoji = '🫃';

  // 파생 피드백
  static const feedbackHeartburn = '식후 바로 눕지 않는 게 도움이 돼요';

  // Q3-2: 복통 위치
  static const derivedPainLocationQuestion = '어디가 아프셨어요?';
  static const painUpperAbdomen = '명치/윗배';
  static const painUpperAbdomenEmoji = '😣';
  static const painRightUpper = '오른쪽 윗배';
  static const painRightUpperEmoji = '😣';
  static const painPeriumbilical = '배꼽 주변';
  static const painPeriumbilicalEmoji = '😣';
  static const painLower = '아랫배';
  static const painLowerEmoji = '😣';

  // Q3-2 피드백
  static const feedbackPainLower = '아랫배 불편함은 장이 적응하는 과정일 수 있어요';

  // Q3-3: 상복부/배꼽 주변 통증 상세 (췌장염 체크)
  static const derivedUpperPainSeverityQuestion = '통증이 어느 정도였나요?';
  static const painMild = '약간 거북했어요';
  static const painMildEmoji = '😐';
  static const painModerate = '꽤 신경쓰였어요';
  static const painModerateEmoji = '😣';
  static const painSevere = '많이 아팠어요';
  static const painSevereEmoji = '😰';
}

/// Q4. 화장실 질문
class BowelQuestionStrings {
  static const question = '화장실은 잘 다녀오셨어요?';
  static const emoji = '🚽';

  // 답변 선택지
  static const answerNormal = '네, 잘 봤어요';
  static const answerNormalEmoji = '😊';
  static const answerIrregular = '좀 불규칙했어요';
  static const answerIrregularEmoji = '😐';
  static const answerDifficult = '힘들었어요';
  static const answerDifficultEmoji = '😣';

  // 피드백
  static const feedbackNormal = '좋아요! 규칙적인 게 중요해요';

  // 파생 질문
  static const derivedQuestion = '어떤 상황이었어요?';
  static const derivedConstipation = '변비가 있었어요';
  static const derivedConstipationEmoji = '😣';
  static const derivedDiarrhea = '설사를 했어요';
  static const derivedDiarrheaEmoji = '💨';

  // Q4-1a: 변비 상세
  static const derivedConstipationDaysQuestion = '며칠째 배변이 없으셨어요?';
  static const constipation1to2Days = '1-2일';
  static const constipation1to2DaysEmoji = '😐';
  static const constipation3to4Days = '3-4일';
  static const constipation3to4DaysEmoji = '😣';
  static const constipation5PlusDays = '5일 이상';
  static const constipation5PlusDaysEmoji = '😰';

  // Q4-1b: 설사 상세
  static const derivedDiarrheaFrequencyQuestion = '하루에 몇 번 정도 다녀오셨어요?';
  static const diarrhea2to3Times = '2-3회';
  static const diarrhea2to3TimesEmoji = '😐';
  static const diarrhea4to5Times = '4-5회';
  static const diarrhea4to5TimesEmoji = '😣';
  static const diarrhea6PlusTimes = '6회 이상';
  static const diarrhea6PlusTimesEmoji = '😰';

  // Q4-1b 피드백
  static const feedbackDiarrheaMild = '수분 섭취를 충분히 해주세요';
  static const feedbackDiarrheaModerate = '수분과 전해질 보충이 중요해요. 이온음료 추천해요';
}

/// Q5. 에너지 질문
class EnergyQuestionStrings {
  static const question = '오늘 에너지는 어떠셨어요?';
  static const emoji = '⚡';

  // 답변 선택지
  static const answerGood = '활기 있었어요';
  static const answerGoodEmoji = '😊';
  static const answerNormal = '평소와 비슷했어요';
  static const answerNormalEmoji = '😐';
  static const answerTired = '많이 피곤했어요';
  static const answerTiredEmoji = '😴';

  // 피드백
  static const feedbackGood = '좋은 하루였네요! ⚡';
  static const feedbackNormal = '꾸준히 유지하고 계시네요';

  // 파생 질문
  static const derivedQuestion = '혹시 다른 증상도 함께 있었나요?';
  static const derivedDizziness = '어지러웠어요';
  static const derivedDizzinessEmoji = '💫';
  static const derivedColdSweat = '식은땀이 났어요';
  static const derivedColdSweatEmoji = '💦';
  static const derivedFatigueOnly = '피곤하기만 했어요';
  static const derivedFatigueOnlyEmoji = '😌';
  static const derivedDyspnea = '숨이 찼어요';
  static const derivedDyspneaEmoji = '🫁';
  static const derivedSwelling = '붓기가 있었어요';
  static const derivedSwellingEmoji = '🦵';

  // 파생 피드백
  static const feedbackFatigue = '충분히 쉬어주세요. 몸이 적응 중이에요';

  // Q5-2: 저혈당 체크
  static const derivedHypoglycemiaQuestion = '혹시 손이 떨리거나, 심장이 빨리 뛰었나요?';
  static const hypoglycemiaNo = '아니요';
  static const hypoglycemiaNoEmoji = '😌';
  static const hypoglycemiaYes = '네, 그랬어요';
  static const hypoglycemiaYesEmoji = '😰';

  // Q5-3: 신부전 체크
  static const derivedRenalCheckQuestion = '소변량이 평소보다 줄었나요?';
  static const urineNormal = '아니요';
  static const urineNormalEmoji = '😌';
  static const urineDecreased = '좀 그런 것 같아요';
  static const urineDecreasedEmoji = '🤔';
  static const urineSeverelyDecreased = '많이 줄었어요';
  static const urineSeverelyDecreasedEmoji = '😰';
}

/// Q6. 기분 질문
class MoodQuestionStrings {
  static const question = '마지막으로, 오늘 기분은 어떠셨어요?';
  static const emoji = '😊';

  // 답변 선택지
  static const answerGood = '좋았어요';
  static const answerGoodEmoji = '😊';
  static const answerNeutral = '그저 그랬어요';
  static const answerNeutralEmoji = '😐';
  static const answerLow = '좀 우울했어요';
  static const answerLowEmoji = '😔';

  // 피드백
  static const feedbackGood = '좋은 하루였네요! 😊';
  static const feedbackNeutral = '그런 날도 있죠. 내일은 더 좋을 거예요';
  static const feedbackLow = '힘든 날도 있어요. 당신은 잘하고 있어요 💚';

  // 건너뛰기
  static const skipButton = '건너뛰기';
}

/// 완료 화면 문자열
class CompletionStrings {
  static const title = '오늘의 체크인 완료!';
  static const emoji = '✨';

  /// 연속 기록 축하 메시지
  static String consecutiveDays(int days) {
    if (days == 3) return '벌써 3일째 함께하고 있어요!';
    if (days == 7) return '일주일 완주! 대단해요 🎉';
    if (days == 14) return '2주 동안 꾸준히 기록하셨네요!';
    if (days == 21) return '3주! 이제 습관이 되셨을 거예요';
    if (days == 30) return '한 달 완주! 정말 대단해요 🏆';
    if (days > 1) return '벌써 $days일째 함께하고 있어요.';
    return '';
  }

  /// 일반 완료 메시지 (좋은 날)
  static const goodDay = '''오늘 하루 잘 보내셨네요.
식사도 잘 하시고, 에너지도 좋으셨군요.

내일도 좋은 하루 되세요! 💚''';

  /// 힘든 날
  static const difficultDay = '''오늘 좀 힘드셨군요.
몸이 적응하는 과정이에요.

당신은 잘하고 있어요. 💚''';

  /// 완료 버튼
  static const doneButton = '확인';
}

/// Red Flag 안내 문자열 (부드러운 톤)
class RedFlagStrings {
  static const title = '확인이 필요해 보여요';
  static const emoji = '💛';

  /// 일반 안내 시작
  static const openingGeneral = '오늘 기록해주신 증상이 조금 확인이 필요해 보여요.';

  /// 탈수 위험
  static const dehydration = '''수분 섭취가 어려우시군요.

지금 가장 중요한 건 조금이라도 수분을 유지하는 거예요.
• 이온음료를 한 모금씩 자주 마셔보세요
• 얼음을 입에 물고 있는 것도 도움이 돼요

만약 계속 물을 못 드시겠으면,
오늘 중으로 병원에 들러보시는 게 좋겠어요.''';

  /// 췌장염 의심
  static const pancreatitis = '''윗배 통증이 등 쪽으로도 느껴지고,
몇 시간 이상 지속되셨군요.

이런 경우 드물지만 확인이 필요할 때가 있어요.
오늘 중으로 가까운 병원에 들러서
한 번 확인받아 보시는 게 안심이 될 것 같아요.

💡 응급실이 아니어도 괜찮아요.
   가까운 내과에서 확인받으시면 돼요.''';

  /// 담낭염 의심
  static const cholecystitis = '''오른쪽 윗배 통증과 함께
열감이나 오한이 있으셨군요.

이런 경우 드물지만 확인이 필요할 때가 있어요.
오늘 중으로 병원에서 확인받아 보시는 게 좋겠어요.''';

  /// 장폐색 의심
  static const bowelObstruction = '''변비가 꽤 오래 지속되고,
가스도 안 나오시는군요.

드문 경우지만 확인이 필요할 수 있어요.
오늘 중으로 병원에 들러보시는 게 좋겠어요.''';

  /// 저혈당 의심
  static const hypoglycemia = '''저혈당 증상일 수 있어요.

지금 바로 사탕이나 주스 등 당분을 드셔보세요.

💡 15분 후에도 나아지지 않으면
   병원에 연락해주세요.

다음 진료 때 선생님께 말씀드리시면
약 용량을 조절해주실 수 있어요.''';

  /// 신부전 의심
  static const renalImpairment = '''최근 구토나 설사와 함께
피로, 붓기, 소변 감소가 있으시군요.

탈수로 인해 몸이 힘들어할 수 있어요.
오늘 중으로 병원에서 확인받아 보시는 게 좋겠어요.''';

  /// 버튼
  static const findHospitalButton = '병원 찾기';
  static const dismissButton = '나중에 확인할게요';
}

/// 진행률 표시 문자열
class ProgressStrings {
  static String currentStep(int current, int total) => '$current/$total';
}
