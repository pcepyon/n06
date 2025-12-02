import 'package:n06/features/daily_checkin/presentation/constants/checkin_strings.dart';

/// 메인 질문 정의
///
/// 6개 일상 질문의 구조를 정의합니다.
class MainQuestion {
  final String id;
  final String emoji;
  final String question;
  final List<AnswerOption> options;

  const MainQuestion({
    required this.id,
    required this.emoji,
    required this.question,
    required this.options,
  });
}

/// 답변 선택지
class AnswerOption {
  final String emoji;
  final String text;
  final String value;
  final String? feedback;
  final bool triggersDerived;

  const AnswerOption({
    required this.emoji,
    required this.text,
    required this.value,
    this.feedback,
    this.triggersDerived = false,
  });
}

/// 파생 질문 정의
class DerivedQuestion {
  final String parentQuestionId;
  final String emoji;
  final String question;
  final List<AnswerOption> options;
  final String? condition;

  const DerivedQuestion({
    required this.parentQuestionId,
    required this.emoji,
    required this.question,
    required this.options,
    this.condition,
  });
}

/// 6개 메인 질문 정의
class Questions {
  /// Q1. 식사 질문
  static const meal = MainQuestion(
    id: 'meal',
    emoji: MealQuestionStrings.emoji,
    question: MealQuestionStrings.question,
    options: [
      AnswerOption(
        emoji: MealQuestionStrings.answerGoodEmoji,
        text: MealQuestionStrings.answerGood,
        value: 'good',
        feedback: MealQuestionStrings.feedbackGood,
      ),
      AnswerOption(
        emoji: MealQuestionStrings.answerModerateEmoji,
        text: MealQuestionStrings.answerModerate,
        value: 'moderate',
        feedback: MealQuestionStrings.feedbackModerate,
      ),
      AnswerOption(
        emoji: MealQuestionStrings.answerDifficultEmoji,
        text: MealQuestionStrings.answerDifficult,
        value: 'difficult',
        triggersDerived: true,
      ),
    ],
  );

  /// Q2. 수분 질문
  static const hydration = MainQuestion(
    id: 'hydration',
    emoji: HydrationQuestionStrings.emoji,
    question: HydrationQuestionStrings.question,
    options: [
      AnswerOption(
        emoji: HydrationQuestionStrings.answerGoodEmoji,
        text: HydrationQuestionStrings.answerGood,
        value: 'good',
        feedback: HydrationQuestionStrings.feedbackGood,
      ),
      AnswerOption(
        emoji: HydrationQuestionStrings.answerModerateEmoji,
        text: HydrationQuestionStrings.answerModerate,
        value: 'moderate',
        feedback: HydrationQuestionStrings.feedbackModerate,
      ),
      AnswerOption(
        emoji: HydrationQuestionStrings.answerPoorEmoji,
        text: HydrationQuestionStrings.answerPoor,
        value: 'poor',
        triggersDerived: true,
      ),
    ],
  );

  /// Q3. 속 편안함 질문
  static const giComfort = MainQuestion(
    id: 'gi_comfort',
    emoji: GiComfortQuestionStrings.emoji,
    question: GiComfortQuestionStrings.question,
    options: [
      AnswerOption(
        emoji: GiComfortQuestionStrings.answerGoodEmoji,
        text: GiComfortQuestionStrings.answerGood,
        value: 'good',
        feedback: GiComfortQuestionStrings.feedbackGood,
      ),
      AnswerOption(
        emoji: GiComfortQuestionStrings.answerUncomfortableEmoji,
        text: GiComfortQuestionStrings.answerUncomfortable,
        value: 'uncomfortable',
        triggersDerived: true,
      ),
      AnswerOption(
        emoji: GiComfortQuestionStrings.answerVeryUncomfortableEmoji,
        text: GiComfortQuestionStrings.answerVeryUncomfortable,
        value: 'veryUncomfortable',
        triggersDerived: true,
      ),
    ],
  );

  /// Q4. 화장실 질문
  static const bowel = MainQuestion(
    id: 'bowel',
    emoji: BowelQuestionStrings.emoji,
    question: BowelQuestionStrings.question,
    options: [
      AnswerOption(
        emoji: BowelQuestionStrings.answerNormalEmoji,
        text: BowelQuestionStrings.answerNormal,
        value: 'normal',
        feedback: BowelQuestionStrings.feedbackNormal,
      ),
      AnswerOption(
        emoji: BowelQuestionStrings.answerIrregularEmoji,
        text: BowelQuestionStrings.answerIrregular,
        value: 'irregular',
        triggersDerived: true,
      ),
      AnswerOption(
        emoji: BowelQuestionStrings.answerDifficultEmoji,
        text: BowelQuestionStrings.answerDifficult,
        value: 'difficult',
        triggersDerived: true,
      ),
    ],
  );

  /// Q5. 에너지 질문
  static const energy = MainQuestion(
    id: 'energy',
    emoji: EnergyQuestionStrings.emoji,
    question: EnergyQuestionStrings.question,
    options: [
      AnswerOption(
        emoji: EnergyQuestionStrings.answerGoodEmoji,
        text: EnergyQuestionStrings.answerGood,
        value: 'good',
        feedback: EnergyQuestionStrings.feedbackGood,
      ),
      AnswerOption(
        emoji: EnergyQuestionStrings.answerNormalEmoji,
        text: EnergyQuestionStrings.answerNormal,
        value: 'normal',
        feedback: EnergyQuestionStrings.feedbackNormal,
      ),
      AnswerOption(
        emoji: EnergyQuestionStrings.answerTiredEmoji,
        text: EnergyQuestionStrings.answerTired,
        value: 'tired',
        triggersDerived: true,
      ),
    ],
  );

  /// Q6. 기분 질문
  static const mood = MainQuestion(
    id: 'mood',
    emoji: MoodQuestionStrings.emoji,
    question: MoodQuestionStrings.question,
    options: [
      AnswerOption(
        emoji: MoodQuestionStrings.answerGoodEmoji,
        text: MoodQuestionStrings.answerGood,
        value: 'good',
        feedback: MoodQuestionStrings.feedbackGood,
      ),
      AnswerOption(
        emoji: MoodQuestionStrings.answerNeutralEmoji,
        text: MoodQuestionStrings.answerNeutral,
        value: 'neutral',
        feedback: MoodQuestionStrings.feedbackNeutral,
      ),
      AnswerOption(
        emoji: MoodQuestionStrings.answerLowEmoji,
        text: MoodQuestionStrings.answerLow,
        value: 'low',
        feedback: MoodQuestionStrings.feedbackLow,
      ),
    ],
  );

  /// 전체 질문 리스트 (순서대로)
  static const List<MainQuestion> all = [
    meal,
    hydration,
    giComfort,
    bowel,
    energy,
    mood,
  ];
}

/// 파생 질문 정의
class DerivedQuestions {
  /// Q1-1. 식사가 힘들었던 이유
  static const mealDifficulty = DerivedQuestion(
    parentQuestionId: 'meal',
    emoji: MealQuestionStrings.emoji,
    question: MealQuestionStrings.derivedQuestion,
    options: [
      AnswerOption(
        emoji: MealQuestionStrings.derivedNauseaEmoji,
        text: MealQuestionStrings.derivedNausea,
        value: 'nausea',
        triggersDerived: true, // Q1-1a로
      ),
      AnswerOption(
        emoji: MealQuestionStrings.derivedLowAppetiteEmoji,
        text: MealQuestionStrings.derivedLowAppetite,
        value: 'low_appetite',
        feedback: MealQuestionStrings.feedbackLowAppetite,
      ),
      AnswerOption(
        emoji: MealQuestionStrings.derivedEarlySatietyEmoji,
        text: MealQuestionStrings.derivedEarlySatiety,
        value: 'early_satiety',
        feedback: MealQuestionStrings.feedbackEarlySatiety,
      ),
    ],
  );

  /// Q3-1. 속 불편함의 종류
  static const giDiscomfortType = DerivedQuestion(
    parentQuestionId: 'gi_comfort',
    emoji: GiComfortQuestionStrings.emoji,
    question: GiComfortQuestionStrings.derivedQuestion,
    options: [
      AnswerOption(
        emoji: GiComfortQuestionStrings.derivedHeartburnEmoji,
        text: GiComfortQuestionStrings.derivedHeartburn,
        value: 'heartburn',
        feedback: GiComfortQuestionStrings.feedbackHeartburn,
      ),
      AnswerOption(
        emoji: GiComfortQuestionStrings.derivedPainEmoji,
        text: GiComfortQuestionStrings.derivedPain,
        value: 'abdominal_pain',
        triggersDerived: true, // Q3-2로 (복통 위치)
      ),
      AnswerOption(
        emoji: GiComfortQuestionStrings.derivedBloatingEmoji,
        text: GiComfortQuestionStrings.derivedBloating,
        value: 'bloating',
      ),
    ],
  );

  /// Q4-1. 화장실 어떤 상황
  static const bowelIssueType = DerivedQuestion(
    parentQuestionId: 'bowel',
    emoji: BowelQuestionStrings.emoji,
    question: BowelQuestionStrings.derivedQuestion,
    options: [
      AnswerOption(
        emoji: BowelQuestionStrings.derivedConstipationEmoji,
        text: BowelQuestionStrings.derivedConstipation,
        value: 'constipation',
        triggersDerived: true, // Q4-1a로
      ),
      AnswerOption(
        emoji: BowelQuestionStrings.derivedDiarrheaEmoji,
        text: BowelQuestionStrings.derivedDiarrhea,
        value: 'diarrhea',
        triggersDerived: true, // Q4-1b로
      ),
    ],
  );

  /// Q5-1. 에너지 파생 증상
  static const energySymptoms = DerivedQuestion(
    parentQuestionId: 'energy',
    emoji: EnergyQuestionStrings.emoji,
    question: EnergyQuestionStrings.derivedQuestion,
    options: [
      AnswerOption(
        emoji: EnergyQuestionStrings.derivedDizzinessEmoji,
        text: EnergyQuestionStrings.derivedDizziness,
        value: 'dizziness',
        triggersDerived: true, // Q5-2로 (저혈당 체크)
      ),
      AnswerOption(
        emoji: EnergyQuestionStrings.derivedColdSweatEmoji,
        text: EnergyQuestionStrings.derivedColdSweat,
        value: 'cold_sweat',
        triggersDerived: true, // Q5-2로 (저혈당 체크)
      ),
      AnswerOption(
        emoji: EnergyQuestionStrings.derivedFatigueOnlyEmoji,
        text: EnergyQuestionStrings.derivedFatigueOnly,
        value: 'fatigue_only',
        feedback: EnergyQuestionStrings.feedbackFatigue,
      ),
      AnswerOption(
        emoji: EnergyQuestionStrings.derivedDyspneaEmoji,
        text: EnergyQuestionStrings.derivedDyspnea,
        value: 'dyspnea',
        triggersDerived: true, // Q5-3으로 (신부전 체크)
      ),
      AnswerOption(
        emoji: EnergyQuestionStrings.derivedSwellingEmoji,
        text: EnergyQuestionStrings.derivedSwelling,
        value: 'swelling',
        triggersDerived: true, // Q5-3으로 (신부전 체크)
      ),
    ],
  );

  /// Q1-1a. 메스꺼움 상세
  static const nauseaSeverity = DerivedQuestion(
    parentQuestionId: 'meal',
    emoji: MealQuestionStrings.emoji,
    question: MealQuestionStrings.derivedNauseaSeverityQuestion,
    options: [
      AnswerOption(
        emoji: MealQuestionStrings.nauseaMildEmoji,
        text: MealQuestionStrings.nauseaMild,
        value: 'mild',
        feedback: MealQuestionStrings.feedbackNauseaMild,
      ),
      AnswerOption(
        emoji: MealQuestionStrings.nauseaModerateEmoji,
        text: MealQuestionStrings.nauseaModerate,
        value: 'moderate',
        triggersDerived: true, // Q1-1b로 (구토 여부)
      ),
      AnswerOption(
        emoji: MealQuestionStrings.nauseaSevereEmoji,
        text: MealQuestionStrings.nauseaSevere,
        value: 'severe',
        triggersDerived: true, // Q1-1b로 (구토 여부)
      ),
    ],
  );

  /// Q1-1b. 구토 여부
  static const vomitingCheck = DerivedQuestion(
    parentQuestionId: 'meal',
    emoji: MealQuestionStrings.emoji,
    question: MealQuestionStrings.derivedVomitingQuestion,
    options: [
      AnswerOption(
        emoji: MealQuestionStrings.vomitingNoneEmoji,
        text: MealQuestionStrings.vomitingNone,
        value: 'none',
      ),
      AnswerOption(
        emoji: MealQuestionStrings.vomitingOnceEmoji,
        text: MealQuestionStrings.vomitingOnce,
        value: 'once_twice',
        feedback: MealQuestionStrings.feedbackVomitingOnce,
      ),
      AnswerOption(
        emoji: MealQuestionStrings.vomitingSevereEmoji,
        text: MealQuestionStrings.vomitingSevere,
        value: 'multiple',
      ),
    ],
  );

  /// Q2-1. 수분 섭취 어려움
  static const hydrationDifficulty = DerivedQuestion(
    parentQuestionId: 'hydration',
    emoji: HydrationQuestionStrings.emoji,
    question: HydrationQuestionStrings.derivedQuestion,
    options: [
      AnswerOption(
        emoji: HydrationQuestionStrings.derivedForgotEmoji,
        text: HydrationQuestionStrings.derivedForgot,
        value: 'forgot',
        feedback: HydrationQuestionStrings.feedbackForgot,
      ),
      AnswerOption(
        emoji: HydrationQuestionStrings.derivedNauseaEmoji,
        text: HydrationQuestionStrings.derivedNausea,
        value: 'nausea',
        feedback: HydrationQuestionStrings.feedbackNausea,
      ),
      AnswerOption(
        emoji: HydrationQuestionStrings.derivedCannotKeepEmoji,
        text: HydrationQuestionStrings.derivedCannotKeep,
        value: 'cannot_keep',
      ),
    ],
  );

  /// Q3-2. 복통 위치
  static const painLocation = DerivedQuestion(
    parentQuestionId: 'gi_comfort',
    emoji: GiComfortQuestionStrings.emoji,
    question: GiComfortQuestionStrings.derivedPainLocationQuestion,
    options: [
      AnswerOption(
        emoji: GiComfortQuestionStrings.painUpperAbdomenEmoji,
        text: GiComfortQuestionStrings.painUpperAbdomen,
        value: 'upper_abdomen',
        triggersDerived: true, // Q3-3으로 (췌장염 체크)
      ),
      AnswerOption(
        emoji: GiComfortQuestionStrings.painRightUpperEmoji,
        text: GiComfortQuestionStrings.painRightUpper,
        value: 'right_upper_quadrant',
        triggersDerived: true, // Q3-4로 (담낭염 체크)
      ),
      AnswerOption(
        emoji: GiComfortQuestionStrings.painPeriumbilicalEmoji,
        text: GiComfortQuestionStrings.painPeriumbilical,
        value: 'periumbilical',
        triggersDerived: true, // Q3-3으로 (췌장염 체크)
      ),
      AnswerOption(
        emoji: GiComfortQuestionStrings.painLowerEmoji,
        text: GiComfortQuestionStrings.painLower,
        value: 'lower_abdomen',
        feedback: GiComfortQuestionStrings.feedbackPainLower,
      ),
    ],
  );

  /// Q3-3. 상복부/배꼽 주변 통증 상세 (췌장염 체크)
  static const upperPainSeverity = DerivedQuestion(
    parentQuestionId: 'gi_comfort',
    emoji: GiComfortQuestionStrings.emoji,
    question: GiComfortQuestionStrings.derivedUpperPainSeverityQuestion,
    options: [
      AnswerOption(
        emoji: GiComfortQuestionStrings.painMildEmoji,
        text: GiComfortQuestionStrings.painMild,
        value: 'mild',
      ),
      AnswerOption(
        emoji: GiComfortQuestionStrings.painModerateEmoji,
        text: GiComfortQuestionStrings.painModerate,
        value: 'moderate',
      ),
      AnswerOption(
        emoji: GiComfortQuestionStrings.painSevereEmoji,
        text: GiComfortQuestionStrings.painSevere,
        value: 'severe',
      ),
    ],
  );

  /// Q3-4. 오른쪽 윗배 통증 상세 (담낭염 체크)
  static const rightUpperPainSeverity = DerivedQuestion(
    parentQuestionId: 'gi_comfort',
    emoji: GiComfortQuestionStrings.emoji,
    question: GiComfortQuestionStrings.derivedRightUpperPainSeverityQuestion,
    options: [
      AnswerOption(
        emoji: GiComfortQuestionStrings.painMildEmoji,
        text: GiComfortQuestionStrings.painMild,
        value: 'mild',
      ),
      AnswerOption(
        emoji: GiComfortQuestionStrings.painModerateEmoji,
        text: GiComfortQuestionStrings.painModerate,
        value: 'moderate',
      ),
      AnswerOption(
        emoji: GiComfortQuestionStrings.painSevereEmoji,
        text: GiComfortQuestionStrings.painSevere,
        value: 'severe',
      ),
    ],
  );

  /// Q4-1a. 변비 상세
  static const constipationDays = DerivedQuestion(
    parentQuestionId: 'bowel',
    emoji: BowelQuestionStrings.emoji,
    question: BowelQuestionStrings.derivedConstipationDaysQuestion,
    options: [
      AnswerOption(
        emoji: BowelQuestionStrings.constipation1to2DaysEmoji,
        text: BowelQuestionStrings.constipation1to2Days,
        value: '1-2',
      ),
      AnswerOption(
        emoji: BowelQuestionStrings.constipation3to4DaysEmoji,
        text: BowelQuestionStrings.constipation3to4Days,
        value: '3-4',
      ),
      AnswerOption(
        emoji: BowelQuestionStrings.constipation5PlusDaysEmoji,
        text: BowelQuestionStrings.constipation5PlusDays,
        value: '5+',
      ),
    ],
  );

  /// Q4-1b. 설사 상세
  static const diarrheaFrequency = DerivedQuestion(
    parentQuestionId: 'bowel',
    emoji: BowelQuestionStrings.emoji,
    question: BowelQuestionStrings.derivedDiarrheaFrequencyQuestion,
    options: [
      AnswerOption(
        emoji: BowelQuestionStrings.diarrhea2to3TimesEmoji,
        text: BowelQuestionStrings.diarrhea2to3Times,
        value: '2-3',
        feedback: BowelQuestionStrings.feedbackDiarrheaMild,
      ),
      AnswerOption(
        emoji: BowelQuestionStrings.diarrhea4to5TimesEmoji,
        text: BowelQuestionStrings.diarrhea4to5Times,
        value: '4-5',
        feedback: BowelQuestionStrings.feedbackDiarrheaModerate,
      ),
      AnswerOption(
        emoji: BowelQuestionStrings.diarrhea6PlusTimesEmoji,
        text: BowelQuestionStrings.diarrhea6PlusTimes,
        value: '6+',
      ),
    ],
  );

  /// Q5-2. 저혈당 체크
  static const hypoglycemiaCheck = DerivedQuestion(
    parentQuestionId: 'energy',
    emoji: EnergyQuestionStrings.emoji,
    question: EnergyQuestionStrings.derivedHypoglycemiaQuestion,
    options: [
      AnswerOption(
        emoji: EnergyQuestionStrings.hypoglycemiaNoEmoji,
        text: EnergyQuestionStrings.hypoglycemiaNo,
        value: 'no',
      ),
      AnswerOption(
        emoji: EnergyQuestionStrings.hypoglycemiaYesEmoji,
        text: EnergyQuestionStrings.hypoglycemiaYes,
        value: 'yes',
      ),
    ],
  );

  /// Q5-3. 신부전 체크
  static const renalCheck = DerivedQuestion(
    parentQuestionId: 'energy',
    emoji: EnergyQuestionStrings.emoji,
    question: EnergyQuestionStrings.derivedRenalCheckQuestion,
    options: [
      AnswerOption(
        emoji: EnergyQuestionStrings.urineNormalEmoji,
        text: EnergyQuestionStrings.urineNormal,
        value: 'normal',
      ),
      AnswerOption(
        emoji: EnergyQuestionStrings.urineDecreasedEmoji,
        text: EnergyQuestionStrings.urineDecreased,
        value: 'decreased',
      ),
      AnswerOption(
        emoji: EnergyQuestionStrings.urineSeverelyDecreasedEmoji,
        text: EnergyQuestionStrings.urineSeverelyDecreased,
        value: 'severely_decreased',
      ),
    ],
  );
}
