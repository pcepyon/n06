import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:n06/features/daily_checkin/domain/entities/daily_checkin.dart';
import 'package:n06/features/daily_checkin/domain/entities/symptom_detail.dart';
import 'package:n06/features/daily_checkin/domain/entities/red_flag_detection.dart';
import 'package:n06/features/daily_checkin/domain/entities/checkin_feedback.dart';
import 'package:n06/features/daily_checkin/domain/entities/feedback_type.dart';
import 'package:n06/features/coping_guide/domain/repositories/coping_guide_repository.dart';
import 'package:n06/features/coping_guide/application/providers.dart';

part 'checkin_feedback_notifier.g.dart';

@riverpod
class CheckinFeedbackNotifier extends _$CheckinFeedbackNotifier {
  CopingGuideRepository get _copingGuideRepository =>
      ref.read(copingGuideRepositoryProvider);

  @override
  Future<void> build() async {
    // 상태 없음 (stateless service)
  }

  /// 긍정 답변용 피드백
  ///
  /// Application Layer는 타입만 반환하고,
  /// Presentation Layer에서 l10n으로 변환합니다.
  CheckinFeedback getPositiveFeedback(int questionIndex, String answer) {
    final feedbackType = _positiveFeedbackMap[questionIndex]?[answer];
    if (feedbackType != null) {
      return CheckinFeedback.positive(feedbackType);
    }

    // 기본 피드백
    return const CheckinFeedback.positive(PositiveFeedbackType.generic);
  }

  /// 증상 선택 시 피드백 (CopingGuide 연동)
  ///
  /// CopingGuide에 데이터가 있으면 그것을 사용하고,
  /// 없으면 기본 지지 메시지 타입을 반환합니다.
  Future<CheckinFeedback> getSupportiveFeedback(SymptomType symptomType) async {
    final symptomName = _mapSymptomTypeToName(symptomType);
    final guide = await _copingGuideRepository.getGuideBySymptom(symptomName);

    if (guide != null) {
      // CopingGuide 데이터 사용
      return CheckinFeedback.copingGuide(
        message: guide.reassuranceMessage,
        stat: guide.reassuranceStat,
        action: guide.immediateAction,
      );
    }

    // 기본 지지 메시지 타입 반환
    final feedbackType = _symptomToSupportiveType(symptomType);
    return CheckinFeedback.supportive(feedbackType);
  }

  /// 완료 시 종합 피드백
  ///
  /// 긍정적 요소와 격려 요소를 리스트로 반환하고,
  /// Presentation Layer에서 조합하여 표시합니다.
  CheckinFeedback getCompletionFeedback(DailyCheckin checkin) {
    final elements = <CompletionFeedbackElement>[];

    // 긍정적 요소 찾기
    if (checkin.mealCondition == ConditionLevel.good) {
      elements.add(CompletionFeedbackElement.goodMeal);
    }
    if (checkin.hydrationLevel == HydrationLevel.good) {
      elements.add(CompletionFeedbackElement.goodHydration);
    }
    if (checkin.energyLevel == EnergyLevel.good) {
      elements.add(CompletionFeedbackElement.goodEnergy);
    }
    if (checkin.symptomDetails == null || checkin.symptomDetails!.isEmpty) {
      elements.add(CompletionFeedbackElement.noSymptoms);
    }

    // 격려 요소
    if (checkin.symptomDetails != null && checkin.symptomDetails!.isNotEmpty) {
      elements.add(CompletionFeedbackElement.bodyAdapting);
    }

    final consecutiveDays = checkin.context?.consecutiveDays ?? 0;
    if (consecutiveDays >= 3) {
      elements.add(CompletionFeedbackElement.consecutiveDays);
    }

    return CheckinFeedback.completion(
      elements: elements,
      consecutiveDays: consecutiveDays >= 3 ? consecutiveDays : null,
    );
  }

  /// Red Flag 안내 메시지
  ///
  /// RedFlagType을 RedFlagGuidanceType으로 변환하여 반환합니다.
  /// Presentation Layer에서 l10n으로 변환하여 표시합니다.
  CheckinFeedback getRedFlagGuidance(RedFlagType redFlagType) {
    final guidanceType = _redFlagToGuidanceType(redFlagType);
    return CheckinFeedback.redFlag(guidanceType);
  }

  // === Private Helper Methods ===

  /// SymptomType → CopingGuide symptomName 매핑
  String _mapSymptomTypeToName(SymptomType type) {
    switch (type) {
      case SymptomType.nausea:
        return '메스꺼움';
      case SymptomType.vomiting:
        return '구토';
      case SymptomType.lowAppetite:
        return '식욕 감소';
      case SymptomType.earlySatiety:
        return '조기 포만감';
      case SymptomType.heartburn:
        return '속쓰림';
      case SymptomType.abdominalPain:
        return '복통';
      case SymptomType.bloating:
        return '복부 팽만';
      case SymptomType.constipation:
        return '변비';
      case SymptomType.diarrhea:
        return '설사';
      case SymptomType.fatigue:
        return '피로';
      case SymptomType.dizziness:
        return '어지러움';
      case SymptomType.coldSweat:
        return '식은땀';
      case SymptomType.swelling:
        return '부종';
    }
  }

  /// SymptomType → SupportiveFeedbackType 매핑
  SupportiveFeedbackType _symptomToSupportiveType(SymptomType type) {
    switch (type) {
      case SymptomType.nausea:
        return SupportiveFeedbackType.nausea;
      case SymptomType.vomiting:
        return SupportiveFeedbackType.vomiting;
      case SymptomType.lowAppetite:
        return SupportiveFeedbackType.lowAppetite;
      case SymptomType.earlySatiety:
        return SupportiveFeedbackType.earlySatiety;
      case SymptomType.heartburn:
        return SupportiveFeedbackType.heartburn;
      case SymptomType.abdominalPain:
        return SupportiveFeedbackType.abdominalPain;
      case SymptomType.bloating:
        return SupportiveFeedbackType.bloating;
      case SymptomType.constipation:
        return SupportiveFeedbackType.constipation;
      case SymptomType.diarrhea:
        return SupportiveFeedbackType.diarrhea;
      case SymptomType.fatigue:
        return SupportiveFeedbackType.fatigue;
      case SymptomType.dizziness:
        return SupportiveFeedbackType.dizziness;
      case SymptomType.coldSweat:
        return SupportiveFeedbackType.coldSweat;
      case SymptomType.swelling:
        return SupportiveFeedbackType.swelling;
    }
  }

  /// RedFlagType → RedFlagGuidanceType 매핑
  RedFlagGuidanceType _redFlagToGuidanceType(RedFlagType type) {
    switch (type) {
      case RedFlagType.pancreatitis:
        return RedFlagGuidanceType.pancreatitis;
      case RedFlagType.cholecystitis:
        return RedFlagGuidanceType.cholecystitis;
      case RedFlagType.severeDehydration:
        return RedFlagGuidanceType.severeDehydration;
      case RedFlagType.bowelObstruction:
        return RedFlagGuidanceType.bowelObstruction;
      case RedFlagType.hypoglycemia:
        return RedFlagGuidanceType.hypoglycemia;
      case RedFlagType.renalImpairment:
        return RedFlagGuidanceType.renalImpairment;
    }
  }

  // === Static Data ===

  /// 긍정 답변별 피드백 타입 맵
  ///
  /// 문자열 대신 PositiveFeedbackType을 저장합니다.
  /// Presentation Layer에서 l10n으로 변환하여 표시합니다.
  static final Map<int, Map<String, PositiveFeedbackType>>
      _positiveFeedbackMap = {
    1: {
      // Q1 식사
      'good': PositiveFeedbackType.goodMeal,
      'moderate': PositiveFeedbackType.moderateMeal,
    },
    2: {
      // Q2 수분
      'good': PositiveFeedbackType.goodHydration,
      'moderate': PositiveFeedbackType.moderateHydration,
    },
    3: {
      // Q3 속 편안함
      'good': PositiveFeedbackType.goodComfort,
    },
    4: {
      // Q4 화장실
      'normal': PositiveFeedbackType.normalBowel,
    },
    5: {
      // Q5 에너지
      'good': PositiveFeedbackType.goodEnergy,
      'normal': PositiveFeedbackType.normalEnergy,
    },
    6: {
      // Q6 기분
      'good': PositiveFeedbackType.goodMood,
      'neutral': PositiveFeedbackType.neutralMood,
      'low': PositiveFeedbackType.lowMood,
    },
  };
}
