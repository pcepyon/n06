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
        value: 'very_uncomfortable',
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
}
