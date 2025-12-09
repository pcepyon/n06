import 'package:n06/l10n/generated/app_localizations.dart';

/// 메인 질문 정의
///
/// 6개 일상 질문의 구조를 정의합니다.
class MainQuestion {
  final String id;
  final String Function(L10n) getEmoji;
  final String Function(L10n) getQuestion;
  final List<AnswerOption> options;

  const MainQuestion({
    required this.id,
    required this.getEmoji,
    required this.getQuestion,
    required this.options,
  });
}

/// 답변 선택지
class AnswerOption {
  final String Function(L10n) getEmoji;
  final String Function(L10n) getText;
  final String value;
  final String Function(L10n)? getFeedback;
  final bool triggersDerived;

  const AnswerOption({
    required this.getEmoji,
    required this.getText,
    required this.value,
    this.getFeedback,
    this.triggersDerived = false,
  });
}

/// 파생 질문 정의
class DerivedQuestion {
  final String parentQuestionId;
  final String Function(L10n) getEmoji;
  final String Function(L10n) getQuestion;
  final List<AnswerOption> options;
  final String? condition;

  const DerivedQuestion({
    required this.parentQuestionId,
    required this.getEmoji,
    required this.getQuestion,
    required this.options,
    this.condition,
  });
}

/// 6개 메인 질문 정의
class Questions {
  /// Q1. 식사 질문
  static const meal = MainQuestion(
    id: 'meal',
    getEmoji: _getMealEmoji,
    getQuestion: _getMealQuestion,
    options: [
      AnswerOption(
        getEmoji: _getMealGoodEmoji,
        getText: _getMealGood,
        value: 'good',
        getFeedback: _getMealFeedbackGood,
      ),
      AnswerOption(
        getEmoji: _getMealModerateEmoji,
        getText: _getMealModerate,
        value: 'moderate',
        getFeedback: _getMealFeedbackModerate,
      ),
      AnswerOption(
        getEmoji: _getMealDifficultEmoji,
        getText: _getMealDifficult,
        value: 'difficult',
        triggersDerived: true,
      ),
    ],
  );

  /// Q2. 수분 질문
  static const hydration = MainQuestion(
    id: 'hydration',
    getEmoji: _getHydrationEmoji,
    getQuestion: _getHydrationQuestion,
    options: [
      AnswerOption(
        getEmoji: _getHydrationGoodEmoji,
        getText: _getHydrationGood,
        value: 'good',
        getFeedback: _getHydrationFeedbackGood,
      ),
      AnswerOption(
        getEmoji: _getHydrationModerateEmoji,
        getText: _getHydrationModerate,
        value: 'moderate',
        getFeedback: _getHydrationFeedbackModerate,
      ),
      AnswerOption(
        getEmoji: _getHydrationPoorEmoji,
        getText: _getHydrationPoor,
        value: 'poor',
        triggersDerived: true,
      ),
    ],
  );

  /// Q3. 속 편안함 질문
  static const giComfort = MainQuestion(
    id: 'gi_comfort',
    getEmoji: _getGiComfortEmoji,
    getQuestion: _getGiComfortQuestion,
    options: [
      AnswerOption(
        getEmoji: _getGiComfortGoodEmoji,
        getText: _getGiComfortGood,
        value: 'good',
        getFeedback: _getGiComfortFeedbackGood,
      ),
      AnswerOption(
        getEmoji: _getGiComfortUncomfortableEmoji,
        getText: _getGiComfortUncomfortable,
        value: 'uncomfortable',
        getFeedback: _getGiComfortFeedbackUncomfortable,
      ),
      AnswerOption(
        getEmoji: _getGiComfortVeryUncomfortableEmoji,
        getText: _getGiComfortVeryUncomfortable,
        value: 'veryUncomfortable',
        triggersDerived: true,
      ),
    ],
  );

  /// Q4. 화장실 질문
  static const bowel = MainQuestion(
    id: 'bowel',
    getEmoji: _getBowelEmoji,
    getQuestion: _getBowelQuestion,
    options: [
      AnswerOption(
        getEmoji: _getBowelNormalEmoji,
        getText: _getBowelNormal,
        value: 'normal',
        getFeedback: _getBowelFeedbackNormal,
      ),
      AnswerOption(
        getEmoji: _getBowelIrregularEmoji,
        getText: _getBowelIrregular,
        value: 'irregular',
        getFeedback: _getBowelFeedbackIrregular,
      ),
      AnswerOption(
        getEmoji: _getBowelDifficultEmoji,
        getText: _getBowelDifficult,
        value: 'difficult',
        triggersDerived: true,
      ),
    ],
  );

  /// Q5. 에너지 질문
  static const energy = MainQuestion(
    id: 'energy',
    getEmoji: _getEnergyEmoji,
    getQuestion: _getEnergyQuestion,
    options: [
      AnswerOption(
        getEmoji: _getEnergyGoodEmoji,
        getText: _getEnergyGood,
        value: 'good',
        getFeedback: _getEnergyFeedbackGood,
      ),
      AnswerOption(
        getEmoji: _getEnergyNormalEmoji,
        getText: _getEnergyNormal,
        value: 'normal',
        getFeedback: _getEnergyFeedbackNormal,
      ),
      AnswerOption(
        getEmoji: _getEnergyTiredEmoji,
        getText: _getEnergyTired,
        value: 'tired',
        triggersDerived: true,
      ),
    ],
  );

  /// Q6. 기분 질문
  static const mood = MainQuestion(
    id: 'mood',
    getEmoji: _getMoodEmoji,
    getQuestion: _getMoodQuestion,
    options: [
      AnswerOption(
        getEmoji: _getMoodGoodEmoji,
        getText: _getMoodGood,
        value: 'good',
        getFeedback: _getMoodFeedbackGood,
      ),
      AnswerOption(
        getEmoji: _getMoodNeutralEmoji,
        getText: _getMoodNeutral,
        value: 'neutral',
        getFeedback: _getMoodFeedbackNeutral,
      ),
      AnswerOption(
        getEmoji: _getMoodLowEmoji,
        getText: _getMoodLow,
        value: 'low',
        getFeedback: _getMoodFeedbackLow,
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

  // Meal getters
  static String _getMealEmoji(L10n l10n) => l10n.checkin_meal_emoji;
  static String _getMealQuestion(L10n l10n) => l10n.checkin_meal_question;
  static String _getMealGoodEmoji(L10n l10n) => l10n.checkin_meal_answerGoodEmoji;
  static String _getMealGood(L10n l10n) => l10n.checkin_meal_answerGood;
  static String _getMealFeedbackGood(L10n l10n) => l10n.checkin_meal_feedbackGood;
  static String _getMealModerateEmoji(L10n l10n) => l10n.checkin_meal_answerModerateEmoji;
  static String _getMealModerate(L10n l10n) => l10n.checkin_meal_answerModerate;
  static String _getMealFeedbackModerate(L10n l10n) => l10n.checkin_meal_feedbackModerate;
  static String _getMealDifficultEmoji(L10n l10n) => l10n.checkin_meal_answerDifficultEmoji;
  static String _getMealDifficult(L10n l10n) => l10n.checkin_meal_answerDifficult;

  // Hydration getters
  static String _getHydrationEmoji(L10n l10n) => l10n.checkin_hydration_emoji;
  static String _getHydrationQuestion(L10n l10n) => l10n.checkin_hydration_question;
  static String _getHydrationGoodEmoji(L10n l10n) => l10n.checkin_hydration_answerGoodEmoji;
  static String _getHydrationGood(L10n l10n) => l10n.checkin_hydration_answerGood;
  static String _getHydrationFeedbackGood(L10n l10n) => l10n.checkin_hydration_feedbackGood;
  static String _getHydrationModerateEmoji(L10n l10n) => l10n.checkin_hydration_answerModerateEmoji;
  static String _getHydrationModerate(L10n l10n) => l10n.checkin_hydration_answerModerate;
  static String _getHydrationFeedbackModerate(L10n l10n) => l10n.checkin_hydration_feedbackModerate;
  static String _getHydrationPoorEmoji(L10n l10n) => l10n.checkin_hydration_answerPoorEmoji;
  static String _getHydrationPoor(L10n l10n) => l10n.checkin_hydration_answerPoor;

  // GI Comfort getters
  static String _getGiComfortEmoji(L10n l10n) => l10n.checkin_giComfort_emoji;
  static String _getGiComfortQuestion(L10n l10n) => l10n.checkin_giComfort_question;
  static String _getGiComfortGoodEmoji(L10n l10n) => l10n.checkin_giComfort_answerGoodEmoji;
  static String _getGiComfortGood(L10n l10n) => l10n.checkin_giComfort_answerGood;
  static String _getGiComfortFeedbackGood(L10n l10n) => l10n.checkin_giComfort_feedbackGood;
  static String _getGiComfortUncomfortableEmoji(L10n l10n) => l10n.checkin_giComfort_answerUncomfortableEmoji;
  static String _getGiComfortUncomfortable(L10n l10n) => l10n.checkin_giComfort_answerUncomfortable;
  static String _getGiComfortFeedbackUncomfortable(L10n l10n) => l10n.checkin_giComfort_feedbackUncomfortable;
  static String _getGiComfortVeryUncomfortableEmoji(L10n l10n) => l10n.checkin_giComfort_answerVeryUncomfortableEmoji;
  static String _getGiComfortVeryUncomfortable(L10n l10n) => l10n.checkin_giComfort_answerVeryUncomfortable;

  // Bowel getters
  static String _getBowelEmoji(L10n l10n) => l10n.checkin_bowel_emoji;
  static String _getBowelQuestion(L10n l10n) => l10n.checkin_bowel_question;
  static String _getBowelNormalEmoji(L10n l10n) => l10n.checkin_bowel_answerNormalEmoji;
  static String _getBowelNormal(L10n l10n) => l10n.checkin_bowel_answerNormal;
  static String _getBowelFeedbackNormal(L10n l10n) => l10n.checkin_bowel_feedbackNormal;
  static String _getBowelIrregularEmoji(L10n l10n) => l10n.checkin_bowel_answerIrregularEmoji;
  static String _getBowelIrregular(L10n l10n) => l10n.checkin_bowel_answerIrregular;
  static String _getBowelFeedbackIrregular(L10n l10n) => l10n.checkin_bowel_feedbackIrregular;
  static String _getBowelDifficultEmoji(L10n l10n) => l10n.checkin_bowel_answerDifficultEmoji;
  static String _getBowelDifficult(L10n l10n) => l10n.checkin_bowel_answerDifficult;

  // Energy getters
  static String _getEnergyEmoji(L10n l10n) => l10n.checkin_energy_emoji;
  static String _getEnergyQuestion(L10n l10n) => l10n.checkin_energy_question;
  static String _getEnergyGoodEmoji(L10n l10n) => l10n.checkin_energy_answerGoodEmoji;
  static String _getEnergyGood(L10n l10n) => l10n.checkin_energy_answerGood;
  static String _getEnergyFeedbackGood(L10n l10n) => l10n.checkin_energy_feedbackGood;
  static String _getEnergyNormalEmoji(L10n l10n) => l10n.checkin_energy_answerNormalEmoji;
  static String _getEnergyNormal(L10n l10n) => l10n.checkin_energy_answerNormal;
  static String _getEnergyFeedbackNormal(L10n l10n) => l10n.checkin_energy_feedbackNormal;
  static String _getEnergyTiredEmoji(L10n l10n) => l10n.checkin_energy_answerTiredEmoji;
  static String _getEnergyTired(L10n l10n) => l10n.checkin_energy_answerTired;

  // Mood getters
  static String _getMoodEmoji(L10n l10n) => l10n.checkin_mood_emoji;
  static String _getMoodQuestion(L10n l10n) => l10n.checkin_mood_question;
  static String _getMoodGoodEmoji(L10n l10n) => l10n.checkin_mood_answerGoodEmoji;
  static String _getMoodGood(L10n l10n) => l10n.checkin_mood_answerGood;
  static String _getMoodFeedbackGood(L10n l10n) => l10n.checkin_mood_feedbackGood;
  static String _getMoodNeutralEmoji(L10n l10n) => l10n.checkin_mood_answerNeutralEmoji;
  static String _getMoodNeutral(L10n l10n) => l10n.checkin_mood_answerNeutral;
  static String _getMoodFeedbackNeutral(L10n l10n) => l10n.checkin_mood_feedbackNeutral;
  static String _getMoodLowEmoji(L10n l10n) => l10n.checkin_mood_answerLowEmoji;
  static String _getMoodLow(L10n l10n) => l10n.checkin_mood_answerLow;
  static String _getMoodFeedbackLow(L10n l10n) => l10n.checkin_mood_feedbackLow;
}

/// 파생 질문 정의
class DerivedQuestions {
  /// Q1-1. 식사가 힘들었던 이유
  static const mealDifficulty = DerivedQuestion(
    parentQuestionId: 'meal',
    getEmoji: _getMealEmoji,
    getQuestion: _getMealDerivedQuestion,
    options: [
      AnswerOption(
        getEmoji: _getMealDerivedNauseaEmoji,
        getText: _getMealDerivedNausea,
        value: 'nausea',
        getFeedback: _getMealFeedbackNausea,
        triggersDerived: true,
      ),
      AnswerOption(
        getEmoji: _getMealDerivedLowAppetiteEmoji,
        getText: _getMealDerivedLowAppetite,
        value: 'low_appetite',
        getFeedback: _getMealFeedbackLowAppetite,
      ),
      AnswerOption(
        getEmoji: _getMealDerivedEarlySatietyEmoji,
        getText: _getMealDerivedEarlySatiety,
        value: 'early_satiety',
        getFeedback: _getMealFeedbackEarlySatiety,
      ),
    ],
  );

  /// Q3-1. 속 불편함의 종류
  static const giDiscomfortType = DerivedQuestion(
    parentQuestionId: 'gi_comfort',
    getEmoji: _getGiComfortEmoji,
    getQuestion: _getGiComfortDerivedQuestion,
    options: [
      AnswerOption(
        getEmoji: _getGiComfortDerivedHeartburnEmoji,
        getText: _getGiComfortDerivedHeartburn,
        value: 'heartburn',
        getFeedback: _getGiComfortFeedbackHeartburn,
      ),
      AnswerOption(
        getEmoji: _getGiComfortDerivedPainEmoji,
        getText: _getGiComfortDerivedPain,
        value: 'abdominal_pain',
        getFeedback: _getGiComfortFeedbackAbdominalPain,
        triggersDerived: true,
      ),
      AnswerOption(
        getEmoji: _getGiComfortDerivedBloatingEmoji,
        getText: _getGiComfortDerivedBloating,
        value: 'bloating',
        getFeedback: _getGiComfortFeedbackBloating,
      ),
    ],
  );

  /// Q4-1. 화장실 어떤 상황
  static const bowelIssueType = DerivedQuestion(
    parentQuestionId: 'bowel',
    getEmoji: _getBowelEmoji,
    getQuestion: _getBowelDerivedQuestion,
    options: [
      AnswerOption(
        getEmoji: _getBowelDerivedConstipationEmoji,
        getText: _getBowelDerivedConstipation,
        value: 'constipation',
        getFeedback: _getBowelFeedbackConstipation,
        triggersDerived: true,
      ),
      AnswerOption(
        getEmoji: _getBowelDerivedDiarrheaEmoji,
        getText: _getBowelDerivedDiarrhea,
        value: 'diarrhea',
        getFeedback: _getBowelFeedbackDiarrhea,
        triggersDerived: true,
      ),
    ],
  );

  /// Q5-1. 에너지 파생 증상
  static const energySymptoms = DerivedQuestion(
    parentQuestionId: 'energy',
    getEmoji: _getEnergyEmoji,
    getQuestion: _getEnergyDerivedQuestion,
    options: [
      AnswerOption(
        getEmoji: _getEnergyDerivedDizzinessEmoji,
        getText: _getEnergyDerivedDizziness,
        value: 'dizziness',
        getFeedback: _getEnergyFeedbackDizziness,
        triggersDerived: true,
      ),
      AnswerOption(
        getEmoji: _getEnergyDerivedColdSweatEmoji,
        getText: _getEnergyDerivedColdSweat,
        value: 'cold_sweat',
        getFeedback: _getEnergyFeedbackColdSweat,
        triggersDerived: true,
      ),
      AnswerOption(
        getEmoji: _getEnergyDerivedFatigueOnlyEmoji,
        getText: _getEnergyDerivedFatigueOnly,
        value: 'fatigue_only',
        getFeedback: _getEnergyFeedbackFatigue,
      ),
      AnswerOption(
        getEmoji: _getEnergyDerivedDyspneaEmoji,
        getText: _getEnergyDerivedDyspnea,
        value: 'dyspnea',
        getFeedback: _getEnergyFeedbackDyspnea,
        triggersDerived: true,
      ),
      AnswerOption(
        getEmoji: _getEnergyDerivedSwellingEmoji,
        getText: _getEnergyDerivedSwelling,
        value: 'swelling',
        getFeedback: _getEnergyFeedbackSwelling,
        triggersDerived: true,
      ),
    ],
  );

  /// Q1-1a. 메스꺼움 강도
  static const nauseaSeverity = DerivedQuestion(
    parentQuestionId: 'meal',
    getEmoji: _getMealEmoji,
    getQuestion: _getNauseaSeverityQuestion,
    options: [
      AnswerOption(
        getEmoji: _getNauseaMildEmoji,
        getText: _getNauseaMild,
        value: 'mild',
        getFeedback: _getNauseaFeedbackMild,
      ),
      AnswerOption(
        getEmoji: _getNauseaModerateEmoji,
        getText: _getNauseaModerate,
        value: 'moderate',
        getFeedback: _getNauseaFeedbackModerate,
        triggersDerived: true,
      ),
      AnswerOption(
        getEmoji: _getNauseaSevereEmoji,
        getText: _getNauseaSevere,
        value: 'severe',
        getFeedback: _getNauseaFeedbackSevere,
        triggersDerived: true,
      ),
    ],
  );

  /// Q1-1b. 구토 확인
  static const vomitingCheck = DerivedQuestion(
    parentQuestionId: 'meal',
    getEmoji: _getMealEmoji,
    getQuestion: _getVomitingQuestion,
    options: [
      AnswerOption(
        getEmoji: _getVomitingNoEmoji,
        getText: _getVomitingNo,
        value: 'no',
        getFeedback: _getVomitingFeedbackNone,
      ),
      AnswerOption(
        getEmoji: _getVomitingOnceEmoji,
        getText: _getVomitingOnce,
        value: 'once',
        getFeedback: _getVomitingFeedbackOnce,
      ),
      AnswerOption(
        getEmoji: _getVomitingSeveralEmoji,
        getText: _getVomitingSeveral,
        value: 'several',
        getFeedback: _getVomitingFeedbackSeveral,
      ),
    ],
  );

  /// Q2-1. 수분 섭취 어려움
  static const hydrationDifficulty = DerivedQuestion(
    parentQuestionId: 'hydration',
    getEmoji: _getHydrationEmoji,
    getQuestion: _getHydrationDerivedQuestion,
    options: [
      AnswerOption(
        getEmoji: _getHydrationDerivedForgotEmoji,
        getText: _getHydrationDerivedForgot,
        value: 'forgot',
        getFeedback: _getHydrationFeedbackForgot,
      ),
      AnswerOption(
        getEmoji: _getHydrationDerivedNauseaEmoji,
        getText: _getHydrationDerivedNausea,
        value: 'nausea',
        getFeedback: _getHydrationFeedbackNausea,
      ),
      AnswerOption(
        getEmoji: _getHydrationDerivedCannotKeepEmoji,
        getText: _getHydrationDerivedCannotKeep,
        value: 'cannot_keep',
        getFeedback: _getHydrationFeedbackCannotKeep,
      ),
    ],
  );

  /// Q3-2. 복통 위치
  static const painLocation = DerivedQuestion(
    parentQuestionId: 'gi_comfort',
    getEmoji: _getGiComfortEmoji,
    getQuestion: _getPainLocationQuestion,
    options: [
      AnswerOption(
        getEmoji: _getPainLocationUpperEmoji,
        getText: _getPainLocationUpper,
        value: 'upper',
        getFeedback: _getPainFeedbackUpper,
        triggersDerived: true,
      ),
      AnswerOption(
        getEmoji: _getPainLocationRightUpperEmoji,
        getText: _getPainLocationRightUpper,
        value: 'right_upper',
        getFeedback: _getPainFeedbackRightUpper,
        triggersDerived: true,
      ),
      AnswerOption(
        getEmoji: _getPainLocationLowerEmoji,
        getText: _getPainLocationLower,
        value: 'lower',
        getFeedback: _getPainFeedbackLower,
      ),
      AnswerOption(
        getEmoji: _getPainLocationGeneralEmoji,
        getText: _getPainLocationGeneral,
        value: 'general',
        getFeedback: _getPainFeedbackGeneral,
      ),
    ],
  );

  /// Q3-3. 윗배 통증 강도
  static const upperPainSeverity = DerivedQuestion(
    parentQuestionId: 'gi_comfort',
    getEmoji: _getGiComfortEmoji,
    getQuestion: _getUpperPainSeverityQuestion,
    options: [
      AnswerOption(
        getEmoji: _getPainSeverityMildEmoji,
        getText: _getPainSeverityMild,
        value: 'mild',
        getFeedback: _getPainSeverityFeedbackMild,
      ),
      AnswerOption(
        getEmoji: _getPainSeverityModerateEmoji,
        getText: _getPainSeverityModerate,
        value: 'moderate',
        getFeedback: _getPainSeverityFeedbackModerate,
      ),
      AnswerOption(
        getEmoji: _getPainSeveritySevereEmoji,
        getText: _getPainSeveritySevere,
        value: 'severe',
        getFeedback: _getPainSeverityFeedbackSevere,
        triggersDerived: true,
      ),
    ],
  );

  /// Q3-3-radiation. 등으로 통증 방사
  static const radiationToBack = DerivedQuestion(
    parentQuestionId: 'gi_comfort',
    getEmoji: _getGiComfortEmoji,
    getQuestion: _getRadiationToBackQuestion,
    options: [
      AnswerOption(
        getEmoji: _getRadiationNoEmoji,
        getText: _getRadiationNo,
        value: 'no',
        getFeedback: _getRadiationFeedbackNo,
      ),
      AnswerOption(
        getEmoji: _getRadiationYesEmoji,
        getText: _getRadiationYes,
        value: 'yes',
        triggersDerived: true,
      ),
    ],
  );

//   /// Q3-3-duration. 통증 지속 시간
//   static const painDuration = DerivedQuestion(
//     parentQuestionId: 'gi_comfort',
//     getEmoji: _getGiComfortEmoji,
//     getQuestion: _getPainDurationQuestion,
//     options: [
//       AnswerOption(
//         getEmoji: _getPainDurationShortEmoji,
//         getText: _getPainDurationShort,
//         value: 'short',
//       ),
//       AnswerOption(
//         getEmoji: _getPainDurationLongEmoji,
//         getText: _getPainDurationLong,
//         value: 'long',
//       ),
//     ],
//   );

  /// Q3-4. 오른쪽 윗배 통증 강도
  static const rightUpperPainSeverity = DerivedQuestion(
    parentQuestionId: 'gi_comfort',
    getEmoji: _getGiComfortEmoji,
    getQuestion: _getRightUpperPainSeverityQuestion,
    options: [
      AnswerOption(
        getEmoji: _getPainSeverityMildEmoji,
        getText: _getPainSeverityMild,
        value: 'mild',
        getFeedback: _getPainSeverityFeedbackMild,
      ),
      AnswerOption(
        getEmoji: _getPainSeverityModerateEmoji,
        getText: _getPainSeverityModerate,
        value: 'moderate',
        getFeedback: _getPainSeverityFeedbackModerate,
      ),
      AnswerOption(
        getEmoji: _getPainSeveritySevereEmoji,
        getText: _getPainSeveritySevere,
        value: 'severe',
        getFeedback: _getPainSeverityFeedbackSevere,
        triggersDerived: true,
      ),
    ],
  );

  /// Q3-4-fever. 발열/오한 확인
  static const feverChills = DerivedQuestion(
    parentQuestionId: 'gi_comfort',
    getEmoji: _getGiComfortEmoji,
    getQuestion: _getFeverChillsQuestion,
    options: [
      AnswerOption(
        getEmoji: _getFeverNoEmoji,
        getText: _getFeverNo,
        value: 'no',
        getFeedback: _getFeverFeedbackNo,
      ),
      AnswerOption(
        getEmoji: _getFeverYesEmoji,
        getText: _getFeverYes,
        value: 'yes',
        getFeedback: _getFeverFeedbackYes,
      ),
    ],
  );

  /// Q4-1a. 변비 일수
  static const constipationDays = DerivedQuestion(
    parentQuestionId: 'bowel',
    getEmoji: _getBowelEmoji,
    getQuestion: _getConstipationDaysQuestion,
    options: [
      AnswerOption(
        getEmoji: _getConstipationFewEmoji,
        getText: _getConstipationFew,
        value: 'few',
        getFeedback: _getConstipationFeedbackFew,
      ),
      AnswerOption(
        getEmoji: _getConstipationSeveralEmoji,
        getText: _getConstipationSeveral,
        value: 'several',
        getFeedback: _getConstipationFeedbackSeveral,
        triggersDerived: true,
      ),
      AnswerOption(
        getEmoji: _getConstipationManyEmoji,
        getText: _getConstipationMany,
        value: 'many',
        getFeedback: _getConstipationFeedbackMany,
        triggersDerived: true,
      ),
    ],
  );

  /// Q4-1a-bloating. 배 빵빵함 강도
  static const bloatingSeverity = DerivedQuestion(
    parentQuestionId: 'bowel',
    getEmoji: _getBowelEmoji,
    getQuestion: _getBloatingSeverityQuestion,
    options: [
      AnswerOption(
        getEmoji: _getBloatingMildEmoji,
        getText: _getBloatingMild,
        value: 'mild',
        getFeedback: _getBloatingSeverityFeedbackMild,
      ),
      AnswerOption(
        getEmoji: _getBloatingModerateEmoji,
        getText: _getBloatingModerate,
        value: 'moderate',
        getFeedback: _getBloatingSeverityFeedbackModerate,
      ),
      AnswerOption(
        getEmoji: _getBloatingSevereEmoji,
        getText: _getBloatingSevere,
        value: 'severe',
        getFeedback: _getBloatingSeverityFeedbackSevere,
      ),
    ],
  );

  /// Q4-1b. 설사 빈도
  static const diarrheaFrequency = DerivedQuestion(
    parentQuestionId: 'bowel',
    getEmoji: _getBowelEmoji,
    getQuestion: _getDiarrheaFrequencyQuestion,
    options: [
      AnswerOption(
        getEmoji: _getDiarrheaFewEmoji,
        getText: _getDiarrheaFew,
        value: 'few',
        getFeedback: _getDiarrheaFeedbackFew,
      ),
      AnswerOption(
        getEmoji: _getDiarrheaSeveralEmoji,
        getText: _getDiarrheaSeveral,
        value: 'several',
        getFeedback: _getDiarrheaFeedbackSeveral,
      ),
      AnswerOption(
        getEmoji: _getDiarrheaManyEmoji,
        getText: _getDiarrheaMany,
        value: 'many',
        getFeedback: _getDiarrheaFeedbackMany,
      ),
    ],
  );

  /// Q5-2. 저혈당 확인
  static const hypoglycemiaCheck = DerivedQuestion(
    parentQuestionId: 'energy',
    getEmoji: _getEnergyEmoji,
    getQuestion: _getHypoglycemiaQuestion,
    options: [
      AnswerOption(
        getEmoji: _getHypoglycemiaNoEmoji,
        getText: _getHypoglycemiaNo,
        value: 'no',
        getFeedback: _getHypoglycemiaFeedbackNo,
      ),
      AnswerOption(
        getEmoji: _getHypoglycemiaYesEmoji,
        getText: _getHypoglycemiaYes,
        value: 'yes',
        getFeedback: _getHypoglycemiaFeedbackYes,
        triggersDerived: true,
      ),
    ],
  );

  /// Q5-2-tremor. 손떨림 확인
  static const tremorCheck = DerivedQuestion(
    parentQuestionId: 'energy',
    getEmoji: _getEnergyEmoji,
    getQuestion: _getTremorQuestion,
    options: [
      AnswerOption(
        getEmoji: _getTremorNoEmoji,
        getText: _getTremorNo,
        value: 'no',
        getFeedback: _getTremorFeedbackNo,
      ),
      AnswerOption(
        getEmoji: _getTremorYesEmoji,
        getText: _getTremorYes,
        value: 'yes',
        getFeedback: _getTremorFeedbackYes,
        triggersDerived: true,
      ),
    ],
  );

//   /// Q5-2-meds. 당뇨약 복용 확인
//   static const diabetesMedsCheck = DerivedQuestion(
//     parentQuestionId: 'energy',
//     getEmoji: _getEnergyEmoji,
//     getQuestion: _getDiabetesMedsQuestion,
//     options: [
//       AnswerOption(
//         getEmoji: _getDiabetesMedsNoEmoji,
//         getText: _getDiabetesMedsNo,
//         value: 'no',
//       ),
//       AnswerOption(
//         getEmoji: _getDiabetesMedsYesEmoji,
//         getText: _getDiabetesMedsYes,
//         value: 'yes',
//       ),
//     ],
//   );

//   /// Q5-3. 신장 기능 확인
//   static const renalCheck = DerivedQuestion(
//     parentQuestionId: 'energy',
//     getEmoji: _getEnergyEmoji,
//     getQuestion: _getRenalCheckQuestion,
//     options: [
//       AnswerOption(
//         getEmoji: _getRenalNoEmoji,
//         getText: _getRenalNo,
//         value: 'no',
//       ),
//       AnswerOption(
//         getEmoji: _getRenalYesEmoji,
//         getText: _getRenalYes,
//         value: 'yes',
//         triggersDerived: true,
//       ),
//     ],
//   );

  /// Q5-3-urine. 소변량 확인
  static const urineOutputCheck = DerivedQuestion(
    parentQuestionId: 'energy',
    getEmoji: _getEnergyEmoji,
    getQuestion: _getUrineOutputQuestion,
    options: [
      AnswerOption(
        getEmoji: _getUrineOutputNormalEmoji,
        getText: _getUrineOutputNormal,
        value: 'normal',
        getFeedback: _getUrineOutputFeedbackNormal,
      ),
      AnswerOption(
        getEmoji: _getUrineOutputDecreasedEmoji,
        getText: _getUrineOutputDecreased,
        value: 'decreased',
        getFeedback: _getUrineOutputFeedbackDecreased,
        triggersDerived: true,
      ),
    ],
  );

  /// Q5-3-weight. 체중 증가 확인
  static const weightGainCheck = DerivedQuestion(
    parentQuestionId: 'energy',
    getEmoji: _getEnergyEmoji,
    getQuestion: _getWeightGainQuestion,
    options: [
      AnswerOption(
        getEmoji: _getWeightGainNoEmoji,
        getText: _getWeightGainNo,
        value: 'no',
        getFeedback: _getWeightGainFeedbackNo,
      ),
      AnswerOption(
        getEmoji: _getWeightGainYesEmoji,
        getText: _getWeightGainYes,
        value: 'yes',
        getFeedback: _getWeightGainFeedbackYes,
      ),
    ],
  );

  // Meal derived getters
  static String _getMealEmoji(L10n l10n) => l10n.checkin_meal_emoji;
  static String _getMealDerivedQuestion(L10n l10n) => l10n.checkin_meal_derivedQuestion;
  static String _getMealDerivedNauseaEmoji(L10n l10n) => l10n.checkin_meal_derivedNauseaEmoji;
  static String _getMealDerivedNausea(L10n l10n) => l10n.checkin_meal_derivedNausea;
  static String _getMealDerivedLowAppetiteEmoji(L10n l10n) => l10n.checkin_meal_derivedLowAppetiteEmoji;
  static String _getMealDerivedLowAppetite(L10n l10n) => l10n.checkin_meal_derivedLowAppetite;
  static String _getMealFeedbackLowAppetite(L10n l10n) => l10n.checkin_meal_feedbackLowAppetite;
  static String _getMealDerivedEarlySatietyEmoji(L10n l10n) => l10n.checkin_meal_derivedEarlySatietyEmoji;
  static String _getMealDerivedEarlySatiety(L10n l10n) => l10n.checkin_meal_derivedEarlySatiety;
  static String _getMealFeedbackEarlySatiety(L10n l10n) => l10n.checkin_meal_feedbackEarlySatiety;

  // GI Comfort derived getters
  static String _getGiComfortEmoji(L10n l10n) => l10n.checkin_giComfort_emoji;
  static String _getGiComfortDerivedQuestion(L10n l10n) => l10n.checkin_giComfort_derivedQuestion;
  static String _getGiComfortDerivedHeartburnEmoji(L10n l10n) => l10n.checkin_giComfort_derivedHeartburnEmoji;
  static String _getGiComfortDerivedHeartburn(L10n l10n) => l10n.checkin_giComfort_derivedHeartburn;
  static String _getGiComfortFeedbackHeartburn(L10n l10n) => l10n.checkin_giComfort_feedbackHeartburn;
  static String _getGiComfortDerivedPainEmoji(L10n l10n) => l10n.checkin_giComfort_derivedPainEmoji;
  static String _getGiComfortDerivedPain(L10n l10n) => l10n.checkin_giComfort_derivedPain;
  static String _getGiComfortDerivedBloatingEmoji(L10n l10n) => l10n.checkin_giComfort_derivedBloatingEmoji;
  static String _getGiComfortDerivedBloating(L10n l10n) => l10n.checkin_giComfort_derivedBloating;

  // Bowel derived getters
  static String _getBowelEmoji(L10n l10n) => l10n.checkin_bowel_emoji;
  static String _getBowelDerivedQuestion(L10n l10n) => l10n.checkin_bowel_derivedQuestion;
  static String _getBowelDerivedConstipationEmoji(L10n l10n) => l10n.checkin_bowel_derivedConstipationEmoji;
  static String _getBowelDerivedConstipation(L10n l10n) => l10n.checkin_bowel_derivedConstipation;
  static String _getBowelDerivedDiarrheaEmoji(L10n l10n) => l10n.checkin_bowel_derivedDiarrheaEmoji;
  static String _getBowelDerivedDiarrhea(L10n l10n) => l10n.checkin_bowel_derivedDiarrhea;

  // Energy derived getters
  static String _getEnergyEmoji(L10n l10n) => l10n.checkin_energy_emoji;
  static String _getEnergyDerivedQuestion(L10n l10n) => l10n.checkin_energy_derivedQuestion;
  static String _getEnergyDerivedDizzinessEmoji(L10n l10n) => l10n.checkin_energy_derivedDizzinessEmoji;
  static String _getEnergyDerivedDizziness(L10n l10n) => l10n.checkin_energy_derivedDizziness;
  static String _getEnergyDerivedColdSweatEmoji(L10n l10n) => l10n.checkin_energy_derivedColdSweatEmoji;
  static String _getEnergyDerivedColdSweat(L10n l10n) => l10n.checkin_energy_derivedColdSweat;
  static String _getEnergyDerivedFatigueOnlyEmoji(L10n l10n) => l10n.checkin_energy_derivedFatigueOnlyEmoji;
  static String _getEnergyDerivedFatigueOnly(L10n l10n) => l10n.checkin_energy_derivedFatigueOnly;
  static String _getEnergyFeedbackFatigue(L10n l10n) => l10n.checkin_energy_feedbackFatigue;
  static String _getEnergyDerivedDyspneaEmoji(L10n l10n) => l10n.checkin_energy_derivedDyspneaEmoji;
  static String _getEnergyDerivedDyspnea(L10n l10n) => l10n.checkin_energy_derivedDyspnea;
  static String _getEnergyDerivedSwellingEmoji(L10n l10n) => l10n.checkin_energy_derivedSwellingEmoji;
  static String _getEnergyDerivedSwelling(L10n l10n) => l10n.checkin_energy_derivedSwelling;

  // Hydration derived getters
  static String _getHydrationEmoji(L10n l10n) => l10n.checkin_hydration_emoji;
  static String _getHydrationDerivedQuestion(L10n l10n) => l10n.checkin_hydration_derivedQuestion;
  static String _getHydrationDerivedForgotEmoji(L10n l10n) => l10n.checkin_hydration_derivedForgotEmoji;
  static String _getHydrationDerivedForgot(L10n l10n) => l10n.checkin_hydration_derivedForgot;
  static String _getHydrationFeedbackForgot(L10n l10n) => l10n.checkin_hydration_feedbackForgot;
  static String _getHydrationDerivedNauseaEmoji(L10n l10n) => l10n.checkin_hydration_derivedNauseaEmoji;
  static String _getHydrationDerivedNausea(L10n l10n) => l10n.checkin_hydration_derivedNausea;
  static String _getHydrationFeedbackNausea(L10n l10n) => l10n.checkin_hydration_feedbackNausea;
  static String _getHydrationDerivedCannotKeepEmoji(L10n l10n) => l10n.checkin_hydration_derivedCannotKeepEmoji;
  static String _getHydrationDerivedCannotKeep(L10n l10n) => l10n.checkin_hydration_derivedCannotKeep;

  // Nausea severity getters
  static String _getNauseaSeverityQuestion(L10n l10n) => l10n.checkin_meal_derivedNauseaSeverityQuestion;
  static String _getNauseaMildEmoji(L10n l10n) => l10n.checkin_meal_nauseaMildEmoji;
  static String _getNauseaMild(L10n l10n) => l10n.checkin_meal_nauseaMild;
  static String _getNauseaFeedbackMild(L10n l10n) => l10n.checkin_meal_feedbackNauseaMild;
  static String _getNauseaModerateEmoji(L10n l10n) => l10n.checkin_meal_nauseaModerateEmoji;
  static String _getNauseaModerate(L10n l10n) => l10n.checkin_meal_nauseaModerate;
  static String _getNauseaSevereEmoji(L10n l10n) => l10n.checkin_meal_nauseaSevereEmoji;
  static String _getNauseaSevere(L10n l10n) => l10n.checkin_meal_nauseaSevere;

  // Vomiting check getters
  static String _getVomitingQuestion(L10n l10n) => l10n.checkin_meal_derivedVomitingQuestion;
  static String _getVomitingNoEmoji(L10n l10n) => l10n.checkin_meal_vomitingNoneEmoji;
  static String _getVomitingNo(L10n l10n) => l10n.checkin_meal_vomitingNone;
  static String _getVomitingOnceEmoji(L10n l10n) => l10n.checkin_meal_vomitingOnceEmoji;
  static String _getVomitingOnce(L10n l10n) => l10n.checkin_meal_vomitingOnce;
  static String _getVomitingSeveralEmoji(L10n l10n) => l10n.checkin_meal_vomitingSevereEmoji;
  static String _getVomitingSeveral(L10n l10n) => l10n.checkin_meal_vomitingSevere;

  // Pain location getters
  static String _getPainLocationQuestion(L10n l10n) => l10n.checkin_giComfort_derivedPainLocationQuestion;
  static String _getPainLocationUpperEmoji(L10n l10n) => l10n.checkin_giComfort_painUpperAbdomenEmoji;
  static String _getPainLocationUpper(L10n l10n) => l10n.checkin_giComfort_painUpperAbdomen;
  static String _getPainLocationRightUpperEmoji(L10n l10n) => l10n.checkin_giComfort_painRightUpperEmoji;
  static String _getPainLocationRightUpper(L10n l10n) => l10n.checkin_giComfort_painRightUpper;
  static String _getPainLocationLowerEmoji(L10n l10n) => l10n.checkin_giComfort_painLowerEmoji;
  static String _getPainLocationLower(L10n l10n) => l10n.checkin_giComfort_painLower;
  static String _getPainLocationGeneralEmoji(L10n l10n) => l10n.checkin_giComfort_painPeriumbilicalEmoji;
  static String _getPainLocationGeneral(L10n l10n) => l10n.checkin_giComfort_painPeriumbilical;

  // Pain severity getters
  static String _getUpperPainSeverityQuestion(L10n l10n) => l10n.checkin_giComfort_derivedUpperPainSeverityQuestion;
  static String _getRightUpperPainSeverityQuestion(L10n l10n) => l10n.checkin_giComfort_derivedRightUpperPainSeverityQuestion;
  static String _getPainSeverityMildEmoji(L10n l10n) => l10n.checkin_giComfort_painMildEmoji;
  static String _getPainSeverityMild(L10n l10n) => l10n.checkin_giComfort_painMild;
  static String _getPainSeverityModerateEmoji(L10n l10n) => l10n.checkin_giComfort_painModerateEmoji;
  static String _getPainSeverityModerate(L10n l10n) => l10n.checkin_giComfort_painModerate;
  static String _getPainSeveritySevereEmoji(L10n l10n) => l10n.checkin_giComfort_painSevereEmoji;
  static String _getPainSeveritySevere(L10n l10n) => l10n.checkin_giComfort_painSevere;

  // Radiation to back getters
  static String _getRadiationToBackQuestion(L10n l10n) => l10n.checkin_giComfort_derivedRadiationToBackQuestion;
  static String _getRadiationNoEmoji(L10n l10n) => l10n.checkin_giComfort_radiationNoEmoji;
  static String _getRadiationNo(L10n l10n) => l10n.checkin_giComfort_radiationNo;
  static String _getRadiationYesEmoji(L10n l10n) => l10n.checkin_giComfort_radiationDefiniteEmoji;
  static String _getRadiationYes(L10n l10n) => l10n.checkin_giComfort_radiationDefinite;

  // Fever/chills getters
  static String _getFeverChillsQuestion(L10n l10n) => l10n.checkin_giComfort_derivedFeverChillsQuestion;
  static String _getFeverNoEmoji(L10n l10n) => l10n.checkin_giComfort_feverNoEmoji;
  static String _getFeverNo(L10n l10n) => l10n.checkin_giComfort_feverNo;
  static String _getFeverYesEmoji(L10n l10n) => l10n.checkin_giComfort_feverDefiniteEmoji;
  static String _getFeverYes(L10n l10n) => l10n.checkin_giComfort_feverDefinite;

  // Constipation getters
  static String _getConstipationDaysQuestion(L10n l10n) => l10n.checkin_bowel_derivedConstipationDaysQuestion;
  static String _getConstipationFewEmoji(L10n l10n) => l10n.checkin_bowel_constipation1to2DaysEmoji;
  static String _getConstipationFew(L10n l10n) => l10n.checkin_bowel_constipation1to2Days;
  static String _getConstipationSeveralEmoji(L10n l10n) => l10n.checkin_bowel_constipation3to4DaysEmoji;
  static String _getConstipationSeveral(L10n l10n) => l10n.checkin_bowel_constipation3to4Days;
  static String _getConstipationManyEmoji(L10n l10n) => l10n.checkin_bowel_constipation5PlusDaysEmoji;
  static String _getConstipationMany(L10n l10n) => l10n.checkin_bowel_constipation5PlusDays;

  // Bloating severity getters
  static String _getBloatingSeverityQuestion(L10n l10n) => l10n.checkin_bowel_derivedBloatingSeverityQuestion;
  static String _getBloatingMildEmoji(L10n l10n) => l10n.checkin_bowel_bloatingMildEmoji;
  static String _getBloatingMild(L10n l10n) => l10n.checkin_bowel_bloatingMild;
  static String _getBloatingModerateEmoji(L10n l10n) => l10n.checkin_bowel_bloatingModerateEmoji;
  static String _getBloatingModerate(L10n l10n) => l10n.checkin_bowel_bloatingModerate;
  static String _getBloatingSevereEmoji(L10n l10n) => l10n.checkin_bowel_bloatingSevereEmoji;
  static String _getBloatingSevere(L10n l10n) => l10n.checkin_bowel_bloatingSevere;

  // Diarrhea frequency getters
  static String _getDiarrheaFrequencyQuestion(L10n l10n) => l10n.checkin_bowel_derivedDiarrheaFrequencyQuestion;
  static String _getDiarrheaFewEmoji(L10n l10n) => l10n.checkin_bowel_diarrhea2to3TimesEmoji;
  static String _getDiarrheaFew(L10n l10n) => l10n.checkin_bowel_diarrhea2to3Times;
  static String _getDiarrheaSeveralEmoji(L10n l10n) => l10n.checkin_bowel_diarrhea4to5TimesEmoji;
  static String _getDiarrheaSeveral(L10n l10n) => l10n.checkin_bowel_diarrhea4to5Times;
  static String _getDiarrheaManyEmoji(L10n l10n) => l10n.checkin_bowel_diarrhea6PlusTimesEmoji;
  static String _getDiarrheaMany(L10n l10n) => l10n.checkin_bowel_diarrhea6PlusTimes;

  // Hypoglycemia check getters
  static String _getHypoglycemiaQuestion(L10n l10n) => l10n.checkin_energy_derivedHypoglycemiaQuestion;
  static String _getHypoglycemiaNoEmoji(L10n l10n) => l10n.checkin_energy_hypoglycemiaNoEmoji;
  static String _getHypoglycemiaNo(L10n l10n) => l10n.checkin_energy_hypoglycemiaNo;
  static String _getHypoglycemiaYesEmoji(L10n l10n) => l10n.checkin_energy_hypoglycemiaYesEmoji;
  static String _getHypoglycemiaYes(L10n l10n) => l10n.checkin_energy_hypoglycemiaYes;

  // Tremor check getters
  static String _getTremorQuestion(L10n l10n) => l10n.checkin_energy_derivedTremorQuestion;
  static String _getTremorNoEmoji(L10n l10n) => l10n.checkin_energy_tremorNoEmoji;
  static String _getTremorNo(L10n l10n) => l10n.checkin_energy_tremorNo;
  static String _getTremorYesEmoji(L10n l10n) => l10n.checkin_energy_tremorMildEmoji;
  static String _getTremorYes(L10n l10n) => l10n.checkin_energy_tremorMild;

  // Urine output check getters
  static String _getUrineOutputQuestion(L10n l10n) => l10n.checkin_energy_derivedUrineOutputQuestion;
  static String _getUrineOutputNormalEmoji(L10n l10n) => l10n.checkin_energy_urineOutputNormalEmoji;
  static String _getUrineOutputNormal(L10n l10n) => l10n.checkin_energy_urineOutputNormal;
  static String _getUrineOutputDecreasedEmoji(L10n l10n) => l10n.checkin_energy_urineOutputDecreasedEmoji;
  static String _getUrineOutputDecreased(L10n l10n) => l10n.checkin_energy_urineOutputDecreased;

  // Weight gain check getters
  static String _getWeightGainQuestion(L10n l10n) => l10n.checkin_energy_derivedWeightGainQuestion;
  static String _getWeightGainNoEmoji(L10n l10n) => l10n.checkin_energy_weightGainNoEmoji;
  static String _getWeightGainNo(L10n l10n) => l10n.checkin_energy_weightGainNo;
  static String _getWeightGainYesEmoji(L10n l10n) => l10n.checkin_energy_weightGainSignificantEmoji;
  static String _getWeightGainYes(L10n l10n) => l10n.checkin_energy_weightGainSignificant;

  // === Derived Question Feedback Getters ===

  // GI Comfort bloating feedback
  static String _getGiComfortFeedbackBloating(L10n l10n) => l10n.checkin_derived_feedbackBloating;

  // Nausea severity feedback
  static String _getNauseaFeedbackModerate(L10n l10n) => l10n.checkin_derived_feedbackNauseaModerate;
  static String _getNauseaFeedbackSevere(L10n l10n) => l10n.checkin_derived_feedbackNauseaSevere;

  // Vomiting feedback
  static String _getVomitingFeedbackNone(L10n l10n) => l10n.checkin_derived_feedbackVomitingNone;
  static String _getVomitingFeedbackOnce(L10n l10n) => l10n.checkin_derived_feedbackVomitingOnce;
  static String _getVomitingFeedbackSeveral(L10n l10n) => l10n.checkin_derived_feedbackVomitingSeveral;

  // Hydration cannot keep feedback
  static String _getHydrationFeedbackCannotKeep(L10n l10n) => l10n.checkin_derived_feedbackCannotKeep;

  // Pain location feedback
  static String _getPainFeedbackUpper(L10n l10n) => l10n.checkin_derived_feedbackPainUpper;
  static String _getPainFeedbackRightUpper(L10n l10n) => l10n.checkin_derived_feedbackPainRightUpper;
  static String _getPainFeedbackLower(L10n l10n) => l10n.checkin_giComfort_feedbackPainLower;
  static String _getPainFeedbackGeneral(L10n l10n) => l10n.checkin_derived_feedbackPainGeneral;

  // Pain severity feedback
  static String _getPainSeverityFeedbackMild(L10n l10n) => l10n.checkin_derived_feedbackPainMild;
  static String _getPainSeverityFeedbackModerate(L10n l10n) => l10n.checkin_derived_feedbackPainModerate;
  static String _getPainSeverityFeedbackSevere(L10n l10n) => l10n.checkin_derived_feedbackPainSevere;

  // Radiation to back feedback
  static String _getRadiationFeedbackNo(L10n l10n) => l10n.checkin_derived_feedbackRadiationNo;

  // Fever feedback
  static String _getFeverFeedbackNo(L10n l10n) => l10n.checkin_derived_feedbackFeverNo;
  static String _getFeverFeedbackYes(L10n l10n) => l10n.checkin_derived_feedbackFeverYes;

  // Constipation feedback
  static String _getConstipationFeedbackFew(L10n l10n) => l10n.checkin_derived_feedbackConstipationFew;
  static String _getConstipationFeedbackSeveral(L10n l10n) => l10n.checkin_derived_feedbackConstipationSeveral;
  static String _getConstipationFeedbackMany(L10n l10n) => l10n.checkin_derived_feedbackConstipationMany;

  // Bloating severity feedback
  static String _getBloatingSeverityFeedbackMild(L10n l10n) => l10n.checkin_derived_feedbackBloatingMild;
  static String _getBloatingSeverityFeedbackModerate(L10n l10n) => l10n.checkin_derived_feedbackBloatingModerate;
  static String _getBloatingSeverityFeedbackSevere(L10n l10n) => l10n.checkin_derived_feedbackBloatingSevere;

  // Diarrhea feedback
  static String _getDiarrheaFeedbackFew(L10n l10n) => l10n.checkin_derived_feedbackDiarrheaFew;
  static String _getDiarrheaFeedbackSeveral(L10n l10n) => l10n.checkin_derived_feedbackDiarrheaSeveral;
  static String _getDiarrheaFeedbackMany(L10n l10n) => l10n.checkin_derived_feedbackDiarrheaMany;

  // Energy symptoms feedback
  static String _getEnergyFeedbackDizziness(L10n l10n) => l10n.checkin_derived_feedbackDizziness;
  static String _getEnergyFeedbackColdSweat(L10n l10n) => l10n.checkin_derived_feedbackColdSweat;
  static String _getEnergyFeedbackDyspnea(L10n l10n) => l10n.checkin_derived_feedbackDyspnea;
  static String _getEnergyFeedbackSwelling(L10n l10n) => l10n.checkin_derived_feedbackSwelling;

  // Hypoglycemia feedback
  static String _getHypoglycemiaFeedbackNo(L10n l10n) => l10n.checkin_derived_feedbackHypoglycemiaNo;
  static String _getHypoglycemiaFeedbackYes(L10n l10n) => l10n.checkin_derived_feedbackHypoglycemiaYes;

  // Tremor feedback
  static String _getTremorFeedbackNo(L10n l10n) => l10n.checkin_derived_feedbackTremorNo;
  static String _getTremorFeedbackYes(L10n l10n) => l10n.checkin_derived_feedbackTremorYes;

  // Urine output feedback
  static String _getUrineOutputFeedbackNormal(L10n l10n) => l10n.checkin_derived_feedbackUrineNormal;
  static String _getUrineOutputFeedbackDecreased(L10n l10n) => l10n.checkin_derived_feedbackUrineDecreased;

  // Weight gain feedback
  static String _getWeightGainFeedbackNo(L10n l10n) => l10n.checkin_derived_feedbackWeightGainNo;
  static String _getWeightGainFeedbackYes(L10n l10n) => l10n.checkin_derived_feedbackWeightGainYes;

  // Additional derived question feedback (for triggersDerived options)
  static String _getMealFeedbackNausea(L10n l10n) => l10n.checkin_derived_feedbackNausea;
  static String _getGiComfortFeedbackAbdominalPain(L10n l10n) => l10n.checkin_derived_feedbackAbdominalPain;
  static String _getBowelFeedbackConstipation(L10n l10n) => l10n.checkin_derived_feedbackConstipation;
  static String _getBowelFeedbackDiarrhea(L10n l10n) => l10n.checkin_derived_feedbackDiarrhea;
}
