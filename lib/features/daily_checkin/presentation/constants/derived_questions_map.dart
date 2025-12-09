import 'package:n06/features/daily_checkin/presentation/constants/questions.dart';

/// 경로에 해당하는 파생 질문 반환
///
/// [path]는 'Q1-1', 'Q3-2' 등의 형식입니다.
DerivedQuestion? getDerivedQuestion(String path) {
  switch (path) {
    case 'Q1-1':
      return DerivedQuestions.mealDifficulty;
    case 'Q1-1a':
      return DerivedQuestions.nauseaSeverity;
    case 'Q1-1b':
      return DerivedQuestions.vomitingCheck;
    case 'Q2-1':
      return DerivedQuestions.hydrationDifficulty;
    case 'Q3-1':
      return DerivedQuestions.giDiscomfortType;
    case 'Q3-2':
      return DerivedQuestions.painLocation;
    case 'Q3-3':
      return DerivedQuestions.upperPainSeverity;
    case 'Q3-3-radiation':
      return DerivedQuestions.radiationToBack;
    case 'Q3-4':
      return DerivedQuestions.rightUpperPainSeverity;
    case 'Q3-4-fever':
      return DerivedQuestions.feverChills;
    case 'Q4-1':
      return DerivedQuestions.bowelIssueType;
    case 'Q4-1a':
      return DerivedQuestions.constipationDays;
    case 'Q4-1a-bloating':
      return DerivedQuestions.bloatingSeverity;
    case 'Q4-1b':
      return DerivedQuestions.diarrheaFrequency;
    case 'Q5-1':
      return DerivedQuestions.energySymptoms;
    case 'Q5-2':
      return DerivedQuestions.hypoglycemiaCheck;
    case 'Q5-2-tremor':
      return DerivedQuestions.tremorCheck;
    case 'Q5-3-urine':
      return DerivedQuestions.urineOutputCheck;
    case 'Q5-3-weight':
      return DerivedQuestions.weightGainCheck;
    default:
      return null;
  }
}
