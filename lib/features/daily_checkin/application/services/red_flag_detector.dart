import 'package:n06/features/daily_checkin/domain/entities/red_flag_detection.dart';
import 'package:n06/features/daily_checkin/application/notifiers/daily_checkin_notifier.dart';

/// Red Flag 감지 서비스
///
/// 체크인 응답에서 Red Flag 조건을 자동으로 감지합니다.
/// 6가지 Red Flag: 급성 췌장염, 담낭염, 심한 탈수, 장폐색, 저혈당, 신부전
///
/// UX 원칙: 감지 로직은 숨겨서 동작, 사용자에게는 자연스러운 안내만
class RedFlagDetector {
  /// 체크인 상태에서 Red Flag 감지
  ///
  /// Red Flag가 감지되면 RedFlagDetection 반환, 없으면 null
  RedFlagDetection? detect(DailyCheckinState state) {
    // 우선순위에 따라 체크 (가장 긴급한 것부터)

    // 1. 급성 췌장염
    final pancreatitis = _checkPancreatitis(state);
    if (pancreatitis != null) return pancreatitis;

    // 2. 담낭염
    final cholecystitis = _checkCholecystitis(state);
    if (cholecystitis != null) return cholecystitis;

    // 3. 심한 탈수
    final dehydration = _checkSevereDehydration(state);
    if (dehydration != null) return dehydration;

    // 4. 장폐색
    final obstruction = _checkBowelObstruction(state);
    if (obstruction != null) return obstruction;

    // 5. 저혈당
    final hypoglycemia = _checkHypoglycemia(state);
    if (hypoglycemia != null) return hypoglycemia;

    // 6. 신부전
    final renal = _checkRenalImpairment(state);
    if (renal != null) return renal;

    return null;
  }

  /// 급성 췌장염 체크
  ///
  /// 조건: 상복부/배꼽 주변 통증 + 심한 정도 + 등 방사 + 수시간 지속
  RedFlagDetection? _checkPancreatitis(DailyCheckinState state) {
    final painLocation = state.derivedAnswers['Q3-2'] as String?;
    final painSeverity = state.derivedAnswers['Q3-3'] as String?;
    final radiationToBack = state.derivedAnswers['Q3-3-radiation'] as String?;
    final duration = state.derivedAnswers['Q3-3-duration'] as String?;

    final isUpperAbdomen = painLocation == 'upper_abdomen' ||
        painLocation == 'periumbilical';
    final isSevere = painSeverity == 'moderate' || painSeverity == 'severe';
    final radiatesToBack = radiationToBack == 'slight' ||
        radiationToBack == 'definite';
    final isProlonged = duration == 'hours' || duration == 'all_day';

    if (isUpperAbdomen && isSevere && radiatesToBack && isProlonged) {
      return RedFlagDetection(
        type: RedFlagType.pancreatitis,
        severity: RedFlagSeverity.urgent,
        symptoms: [
          'severe_abdominal_pain',
          'radiates_to_back',
          'prolonged_duration',
        ],
        notifiedAt: DateTime.now(),
      );
    }
    return null;
  }

  /// 담낭염 체크
  ///
  /// 조건: 우상복부 통증 + 심한 정도 + (발열/오한 또는 구토)
  RedFlagDetection? _checkCholecystitis(DailyCheckinState state) {
    final painLocation = state.derivedAnswers['Q3-2'] as String?;
    final painSeverity = state.derivedAnswers['Q3-4'] as String?;
    final feverChills = state.derivedAnswers['Q3-4-fever'] as String?;
    final vomiting = state.derivedAnswers['Q1-1b'] as String?;

    final isRightUpper = painLocation == 'right_upper_quadrant';
    final isSevere = painSeverity == 'moderate' || painSeverity == 'severe';
    final hasFever = feverChills == 'slight' || feverChills == 'definite';
    final hasVomiting = vomiting == 'once_twice' || vomiting == 'multiple';

    if (isRightUpper && isSevere && (hasFever || hasVomiting)) {
      return RedFlagDetection(
        type: RedFlagType.cholecystitis,
        severity: RedFlagSeverity.urgent,
        symptoms: [
          'right_upper_quadrant_pain',
          if (hasFever) 'fever_chills',
          if (hasVomiting) 'vomiting',
        ],
        notifiedAt: DateTime.now(),
      );
    }
    return null;
  }

  /// 심한 탈수 체크
  ///
  /// 조건: 물 마셔도 토함 OR (구토 3회+ AND 수분 섭취 어려움)
  RedFlagDetection? _checkSevereDehydration(DailyCheckinState state) {
    final hydration = state.answers[2]; // Q2
    final cannotKeepFluids = state.derivedAnswers['Q2-1'] as String?;
    final vomiting = state.derivedAnswers['Q1-1b'] as String?;

    final cannotDrink = cannotKeepFluids == 'cannot_keep';
    final severeVomiting = vomiting == 'multiple';
    final poorHydration = hydration == 'poor';

    if (cannotDrink || (severeVomiting && poorHydration)) {
      return RedFlagDetection(
        type: RedFlagType.severeDehydration,
        severity: RedFlagSeverity.urgent,
        symptoms: [
          if (cannotDrink) 'cannot_keep_fluids',
          if (severeVomiting) 'frequent_vomiting',
          if (poorHydration) 'poor_hydration',
        ],
        notifiedAt: DateTime.now(),
      );
    }
    return null;
  }

  /// 장폐색 체크
  ///
  /// 조건: 변비 5일+ + 심한 빵빵함 + 가스 없음
  RedFlagDetection? _checkBowelObstruction(DailyCheckinState state) {
    final constipationDays = state.derivedAnswers['Q4-1a'] as String?;
    final bloatingSeverity = state.derivedAnswers['Q4-1a-bloating'] as String?;

    final prolongedConstipation = constipationDays == '5_plus';
    final severeNoGas = bloatingSeverity == 'severe_no_gas';

    if (prolongedConstipation && severeNoGas) {
      return RedFlagDetection(
        type: RedFlagType.bowelObstruction,
        severity: RedFlagSeverity.warning,
        symptoms: [
          'prolonged_constipation',
          'severe_bloating',
          'no_gas',
        ],
        notifiedAt: DateTime.now(),
      );
    }
    return null;
  }

  /// 저혈당 체크
  ///
  /// 조건: 어지러움/식은땀 + 손떨림 + 당뇨약 병용
  RedFlagDetection? _checkHypoglycemia(DailyCheckinState state) {
    final symptoms = state.derivedAnswers['Q5-1'] as String?;
    final tremor = state.derivedAnswers['Q5-2-tremor'] as String?;
    final onDiabetesMeds = state.derivedAnswers['Q5-2-meds'] as String?;

    final hasDizzinessOrSweat = symptoms == 'dizziness' ||
        symptoms == 'cold_sweat';
    final hasTremor = tremor == 'yes';
    final takingDiabetesMeds = onDiabetesMeds == 'yes';

    if (hasDizzinessOrSweat && hasTremor && takingDiabetesMeds) {
      return RedFlagDetection(
        type: RedFlagType.hypoglycemia,
        severity: RedFlagSeverity.urgent,
        symptoms: [
          'dizziness',
          'cold_sweat',
          'tremor',
          'on_diabetes_meds',
        ],
        notifiedAt: DateTime.now(),
      );
    }
    return null;
  }

  /// 신부전 체크
  ///
  /// 조건: 심한 피로 + (부종 또는 숨참) + 소변 감소 + 최근 구토/설사
  RedFlagDetection? _checkRenalImpairment(DailyCheckinState state) {
    final symptoms = state.derivedAnswers['Q5-1'] as String?;
    final decreasedUrine = state.derivedAnswers['Q5-3-urine'] as String?;
    final vomiting = state.derivedAnswers['Q1-1b'] as String?;
    final diarrhea = state.derivedAnswers['Q4-1b'] as String?;

    final hasEdemaOrDyspnea = symptoms == 'dyspnea' || symptoms == 'swelling';
    final urineDecreased = decreasedUrine == 'slight' ||
        decreasedUrine == 'severe';
    final recentGI = vomiting == 'multiple' || diarrhea == '6_plus';

    if (hasEdemaOrDyspnea && urineDecreased && recentGI) {
      return RedFlagDetection(
        type: RedFlagType.renalImpairment,
        severity: RedFlagSeverity.warning,
        symptoms: [
          'fatigue',
          if (symptoms == 'swelling') 'edema',
          if (symptoms == 'dyspnea') 'dyspnea',
          'decreased_urine',
          'severe_vomiting_or_diarrhea',
        ],
        notifiedAt: DateTime.now(),
      );
    }
    return null;
  }

}
