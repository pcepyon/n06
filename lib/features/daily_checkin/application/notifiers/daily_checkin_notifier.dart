import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/daily_checkin/application/providers.dart';
import 'package:n06/features/daily_checkin/domain/entities/daily_checkin.dart';
import 'package:n06/features/daily_checkin/domain/entities/symptom_detail.dart';
import 'package:n06/features/daily_checkin/domain/entities/checkin_context.dart';
import 'package:n06/features/daily_checkin/domain/entities/red_flag_detection.dart';
import 'package:n06/features/daily_checkin/domain/repositories/daily_checkin_repository.dart';
import 'package:n06/features/tracking/domain/repositories/medication_repository.dart';
import 'package:n06/features/tracking/application/providers.dart';
import 'package:uuid/uuid.dart';

part 'daily_checkin_notifier.g.dart';

/// 데일리 체크인 플로우 상태
class DailyCheckinState {
  /// 현재 단계 (0: 체중, 1-6: 질문)
  final int currentStep;

  /// 입력된 체중 (null이면 스킵)
  final double? weight;

  /// 질문별 답변 (1→mealCondition, 2→hydrationLevel 등)
  final Map<int, String> answers;

  /// 파생 질문 답변
  final Map<String, dynamic> derivedAnswers;

  /// 수집된 증상 상세 목록
  final List<SymptomDetail> symptomDetails;

  /// 현재 파생 질문 경로 (예: 'Q1-1', 'Q3-2')
  final String? currentDerivedPath;

  /// 완료 여부
  final bool isComplete;

  /// 저장된 체크인 결과
  final DailyCheckin? savedCheckin;

  /// 컨텍스트 정보
  final CheckinContext? context;

  const DailyCheckinState({
    this.currentStep = 0,
    this.weight,
    this.answers = const {},
    this.derivedAnswers = const {},
    this.symptomDetails = const [],
    this.currentDerivedPath,
    this.isComplete = false,
    this.savedCheckin,
    this.context,
  });

  DailyCheckinState copyWith({
    int? currentStep,
    double? weight,
    Map<int, String>? answers,
    Map<String, dynamic>? derivedAnswers,
    List<SymptomDetail>? symptomDetails,
    String? currentDerivedPath,
    bool? isComplete,
    DailyCheckin? savedCheckin,
    CheckinContext? context,
  }) {
    return DailyCheckinState(
      currentStep: currentStep ?? this.currentStep,
      weight: weight ?? this.weight,
      answers: answers ?? this.answers,
      derivedAnswers: derivedAnswers ?? this.derivedAnswers,
      symptomDetails: symptomDetails ?? this.symptomDetails,
      currentDerivedPath: currentDerivedPath ?? this.currentDerivedPath,
      isComplete: isComplete ?? this.isComplete,
      savedCheckin: savedCheckin ?? this.savedCheckin,
      context: context ?? this.context,
    );
  }
}

@riverpod
class DailyCheckinNotifier extends _$DailyCheckinNotifier {
  DailyCheckinRepository get _repository =>
      ref.read(dailyCheckinRepositoryProvider);
  MedicationRepository get _medicationRepository =>
      ref.read(medicationRepositoryProvider);

  @override
  Future<DailyCheckinState> build() async {
    return const DailyCheckinState();
  }

  /// 체크인 시작
  Future<void> startCheckin() async {
    final link = ref.keepAlive();

    final userId = ref.read(authNotifierProvider).value?.id;
    if (userId == null) throw Exception('User not authenticated');

    try {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        // 컨텍스트 로드
        final context = await _loadContext(userId);

        if (!ref.mounted) {
          return const DailyCheckinState();
        }

        return DailyCheckinState(context: context);
      });
    } finally {
      link.close();
    }
  }

  /// 체중 입력 (null이면 스킵)
  Future<void> submitWeight(double? weight) async {
    final currentState = state.value ?? const DailyCheckinState();

    state = AsyncValue.data(
      currentState.copyWith(
        weight: weight,
        currentStep: 1, // Q1 식사 질문으로 이동
      ),
    );
  }

  /// 메인 질문 답변
  Future<void> submitAnswer(int questionIndex, String answer) async {
    final currentState = state.value ?? const DailyCheckinState();

    final newAnswers = Map<int, String>.from(currentState.answers);
    newAnswers[questionIndex] = answer;

    // 파생 질문이 필요한지 확인
    final needsDerived = _needsDerivedQuestion(questionIndex, answer);

    if (needsDerived) {
      // 파생 질문으로 분기
      final derivedPath = _getDerivedPath(questionIndex);
      state = AsyncValue.data(
        currentState.copyWith(
          answers: newAnswers,
          currentDerivedPath: derivedPath,
        ),
      );
    } else {
      // 다음 질문으로
      final nextStep = questionIndex < 6 ? questionIndex + 1 : questionIndex;
      state = AsyncValue.data(
        currentState.copyWith(
          answers: newAnswers,
          currentStep: nextStep,
          currentDerivedPath: null,
        ),
      );
    }
  }

  /// 파생 질문 답변
  Future<void> submitDerivedAnswer(String path, String answer) async {
    final currentState = state.value ?? const DailyCheckinState();

    final newDerivedAnswers = Map<String, dynamic>.from(
      currentState.derivedAnswers,
    );
    newDerivedAnswers[path] = answer;

    // 증상 상세 수집
    final newSymptomDetails = List<SymptomDetail>.from(
      currentState.symptomDetails,
    );
    _collectSymptomDetails(path, answer, newSymptomDetails, newDerivedAnswers);

    // 다음 파생 질문 또는 메인 질문으로
    final nextDerivedPath = _getNextDerivedPath(path, answer);

    if (nextDerivedPath != null) {
      // 추가 파생 질문
      state = AsyncValue.data(
        currentState.copyWith(
          derivedAnswers: newDerivedAnswers,
          symptomDetails: newSymptomDetails,
          currentDerivedPath: nextDerivedPath,
        ),
      );
    } else {
      // 메인 질문으로 복귀
      final currentQuestion = _getQuestionIndexFromPath(path);
      final nextStep = currentQuestion < 6 ? currentQuestion + 1 : currentQuestion;

      state = AsyncValue.data(
        currentState.copyWith(
          derivedAnswers: newDerivedAnswers,
          symptomDetails: newSymptomDetails,
          currentDerivedPath: null,
          currentStep: nextStep,
        ),
      );
    }
  }

  /// 이전 질문으로 이동
  Future<void> goBack() async {
    final currentState = state.value ?? const DailyCheckinState();

    if (currentState.currentDerivedPath != null) {
      // 파생 질문에서 메인 질문으로
      state = AsyncValue.data(
        currentState.copyWith(currentDerivedPath: null),
      );
    } else if (currentState.currentStep > 0) {
      // 이전 메인 질문으로
      state = AsyncValue.data(
        currentState.copyWith(currentStep: currentState.currentStep - 1),
      );
    }
  }

  /// 체크인 완료 및 저장
  Future<void> finishCheckin() async {
    final link = ref.keepAlive();

    final userId = ref.read(authNotifierProvider).value?.id;
    if (userId == null) throw Exception('User not authenticated');

    final currentState = state.value ?? const DailyCheckinState();

    try {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        // DailyCheckin 엔티티 생성
        final checkin = _buildCheckin(userId, currentState);

        // 저장
        await _repository.save(checkin);

        if (!ref.mounted) {
          return currentState;
        }

        return currentState.copyWith(
          isComplete: true,
          savedCheckin: checkin,
        );
      });
    } finally {
      link.close();
    }
  }

  /// 초기화
  Future<void> reset() async {
    state = const AsyncValue.data(DailyCheckinState());
  }

  // === Private Helper Methods ===

  /// 컨텍스트 로드
  Future<CheckinContext> _loadContext(String userId) async {
    // 마지막 체크인 조회
    final latestCheckin = await _repository.getLatest(userId);

    // 연속 일수 계산
    final consecutiveDays = await _repository.getConsecutiveDays(userId);

    // 마지막 체크인 이후 일수
    final daysSinceLastCheckin = latestCheckin != null
        ? DateTime.now().difference(latestCheckin.checkinDate).inDays
        : 999;

    // 주사 다음날 여부 확인
    final isPostInjection = await _isPostInjectionDay(userId);

    // 시간대별 인사 타입
    final greetingType = _getGreetingType();

    return CheckinContext(
      isPostInjection: isPostInjection,
      daysSinceLastCheckin: daysSinceLastCheckin,
      consecutiveDays: consecutiveDays,
      greetingType: greetingType,
      weightSkipped: false,
    );
  }

  /// 주사 다음날 여부 확인
  Future<bool> _isPostInjectionDay(String userId) async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterday = todayDate.subtract(const Duration(days: 1));

    try {
      final plan = await _medicationRepository.getActiveDosagePlan(userId);
      if (plan == null) return false;

      final records = await _medicationRepository.getDoseRecords(plan.id);
      if (records.isEmpty) return false;

      // 가장 최근 투여 기록 확인
      final latestRecord = records.reduce((a, b) =>
          a.administeredAt.isAfter(b.administeredAt) ? a : b);

      final doseDate = DateTime(
        latestRecord.administeredAt.year,
        latestRecord.administeredAt.month,
        latestRecord.administeredAt.day,
      );

      return doseDate == yesterday;
    } catch (e) {
      return false;
    }
  }

  /// 시간대별 인사 타입
  String _getGreetingType() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return 'morning';
    if (hour >= 11 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 21) return 'evening';
    return 'night';
  }

  /// 파생 질문 필요 여부 확인
  bool _needsDerivedQuestion(int questionIndex, String answer) {
    switch (questionIndex) {
      case 1: // Q1 식사
        return answer == 'difficult';
      case 2: // Q2 수분
        return answer == 'poor';
      case 3: // Q3 속 편안함
        return answer == 'uncomfortable' || answer == 'veryUncomfortable';
      case 4: // Q4 화장실
        return answer == 'irregular' || answer == 'difficult';
      case 5: // Q5 에너지
        return answer == 'tired';
      default:
        return false;
    }
  }

  /// 파생 질문 경로 생성
  String _getDerivedPath(int questionIndex) {
    return 'Q$questionIndex-1';
  }

  /// 다음 파생 질문 경로 (null이면 메인 질문으로)
  String? _getNextDerivedPath(String currentPath, String answer) {
    // Q1-1 (메스꺼움/입맛없음/조기포만감)
    if (currentPath == 'Q1-1' && answer == 'nausea') {
      return 'Q1-1a'; // 메스꺼움 상세
    }
    if (currentPath == 'Q1-1a' && (answer == 'moderate' || answer == 'severe')) {
      return 'Q1-1b'; // 구토 여부
    }

    // Q2-1 (수분 섭취 어려움)
    // 추가 파생 없음

    // Q3-1 (속쓰림/복통/빵빵함)
    if (currentPath == 'Q3-1' && answer == 'abdominal_pain') {
      return 'Q3-2'; // 복통 위치
    }
    if (currentPath == 'Q3-2' &&
        (answer == 'upper_abdomen' || answer == 'periumbilical')) {
      return 'Q3-3'; // 상복부 통증 상세
    }
    if (currentPath == 'Q3-2' && answer == 'right_upper_quadrant') {
      return 'Q3-4'; // 우상복부 통증 상세
    }

    // Q4-1 (변비/설사)
    if (currentPath == 'Q4-1' && answer == 'constipation') {
      return 'Q4-1a'; // 변비 상세
    }
    if (currentPath == 'Q4-1' && answer == 'diarrhea') {
      return 'Q4-1b'; // 설사 상세
    }

    // Q5-1 (피로 관련 증상)
    if (currentPath == 'Q5-1' &&
        (answer == 'dizziness' || answer == 'cold_sweat')) {
      return 'Q5-2'; // 저혈당 체크
    }
    if (currentPath == 'Q5-1' &&
        (answer == 'dyspnea' || answer == 'swelling')) {
      return 'Q5-3'; // 신부전 체크
    }

    return null; // 메인 질문으로 복귀
  }

  /// 파생 경로에서 질문 번호 추출
  int _getQuestionIndexFromPath(String path) {
    final match = RegExp(r'Q(\d+)').firstMatch(path);
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    return 1;
  }

  /// 증상 상세 수집
  void _collectSymptomDetails(
    String path,
    String answer,
    List<SymptomDetail> details,
    Map<String, dynamic> derivedAnswers,
  ) {
    // Q1-1a: 메스꺼움 심각도
    if (path == 'Q1-1a') {
      final severity = answer == 'mild'
          ? 1
          : answer == 'moderate'
              ? 2
              : 3;
      details.add(SymptomDetail(
        type: SymptomType.nausea,
        severity: severity,
      ));
    }

    // Q1-1b: 구토 횟수
    if (path == 'Q1-1b') {
      final vomitCount = answer == 'none'
          ? 0
          : answer == 'once_twice'
              ? 2
              : 4;
      if (vomitCount > 0) {
        details.add(SymptomDetail(
          type: SymptomType.vomiting,
          severity: vomitCount >= 3 ? 3 : 2,
          details: {'vomit_count': vomitCount},
        ));
      }
    }

    // Q3-2, Q3-3: 복통 상세
    if (path == 'Q3-3') {
      final location = derivedAnswers['Q3-2'] as String?;
      final severity = answer == 'mild'
          ? 1
          : answer == 'moderate'
              ? 2
              : 3;

      details.add(SymptomDetail(
        type: SymptomType.abdominalPain,
        severity: severity,
        details: {
          'location': location ?? 'unknown',
        },
      ));
    }

    // Q4-1a: 변비 상세
    if (path == 'Q4-1a') {
      final days = answer == '1_2_days'
          ? 2
          : answer == '3_4_days'
              ? 4
              : 6;
      details.add(SymptomDetail(
        type: SymptomType.constipation,
        severity: days >= 5 ? 3 : 2,
        details: {'days_without': days},
      ));
    }

    // Q4-1b: 설사 상세
    if (path == 'Q4-1b') {
      final frequency = answer == '2_3_times'
          ? 3
          : answer == '4_5_times'
              ? 5
              : 7;
      details.add(SymptomDetail(
        type: SymptomType.diarrhea,
        severity: frequency >= 6 ? 3 : 2,
        details: {'frequency': frequency},
      ));
    }
  }

  /// DailyCheckin 엔티티 생성
  DailyCheckin _buildCheckin(String userId, DailyCheckinState state) {
    // Enum 매핑
    final mealCondition = _parseConditionLevel(state.answers[1] ?? 'good');
    final hydrationLevel = _parseHydrationLevel(state.answers[2] ?? 'good');
    final giComfort = _parseGiComfortLevel(state.answers[3] ?? 'good');
    final bowelCondition = _parseBowelCondition(state.answers[4] ?? 'normal');
    final energyLevel = _parseEnergyLevel(state.answers[5] ?? 'good');
    final mood = _parseMoodLevel(state.answers[6] ?? 'good');

    // 식욕 점수 계산
    final appetiteScore = _calculateAppetiteScore(
      mealCondition,
      state.derivedAnswers,
    );

    // 체중 건너뛰기 여부 반영
    final updatedContext = state.context?.copyWith(
      weightSkipped: state.weight == null,
    );

    return DailyCheckin(
      id: const Uuid().v4(),
      userId: userId,
      checkinDate: DateTime.now(),
      mealCondition: mealCondition,
      hydrationLevel: hydrationLevel,
      giComfort: giComfort,
      bowelCondition: bowelCondition,
      energyLevel: energyLevel,
      mood: mood,
      appetiteScore: appetiteScore,
      symptomDetails: state.symptomDetails.isEmpty ? null : state.symptomDetails,
      context: updatedContext,
      redFlagDetected: _detectRedFlag(state),
      createdAt: DateTime.now(),
    );
  }

  /// Red Flag 감지
  RedFlagDetection? _detectRedFlag(DailyCheckinState state) {
    // 췌장염 체크
    final pancreatitisFlag = _checkPancreatitis(state);
    if (pancreatitisFlag != null) return pancreatitisFlag;

    // 담낭염 체크
    final cholecystitisFlag = _checkCholecystitis(state);
    if (cholecystitisFlag != null) return cholecystitisFlag;

    // 심한 탈수 체크
    final dehydrationFlag = _checkSevereDehydration(state);
    if (dehydrationFlag != null) return dehydrationFlag;

    // 장폐색 체크
    final obstructionFlag = _checkBowelObstruction(state);
    if (obstructionFlag != null) return obstructionFlag;

    // 저혈당 체크
    final hypoglycemiaFlag = _checkHypoglycemia(state);
    if (hypoglycemiaFlag != null) return hypoglycemiaFlag;

    // 신부전 체크
    final renalFlag = _checkRenalImpairment(state);
    if (renalFlag != null) return renalFlag;

    return null;
  }

  /// 췌장염 체크
  RedFlagDetection? _checkPancreatitis(DailyCheckinState state) {
    final painLocation = state.derivedAnswers['Q3-2'] as String?;
    final painSeverity = state.derivedAnswers['Q3-3'] as String?;
    final radiationToBack = state.derivedAnswers['Q3-3-radiation'] as String?;
    final duration = state.derivedAnswers['Q3-3-duration'] as String?;

    if ((painLocation == 'upper_abdomen' || painLocation == 'periumbilical') &&
        (painSeverity == 'moderate' || painSeverity == 'severe') &&
        (radiationToBack == 'slight' || radiationToBack == 'definite') &&
        (duration == 'hours' || duration == 'all_day')) {
      return RedFlagDetection(
        type: RedFlagType.pancreatitis,
        severity: RedFlagSeverity.urgent,
        symptoms: [
          'severe_abdominal_pain',
          'radiates_to_back',
          'prolonged_duration'
        ],
        notifiedAt: DateTime.now(),
      );
    }
    return null;
  }

  /// 담낭염 체크
  RedFlagDetection? _checkCholecystitis(DailyCheckinState state) {
    final painLocation = state.derivedAnswers['Q3-2'] as String?;
    final painSeverity = state.derivedAnswers['Q3-4'] as String?;
    final feverChills = state.derivedAnswers['Q3-4-fever'] as String?;
    final vomiting = state.derivedAnswers['Q1-1b'] as String?;

    if (painLocation == 'right_upper_quadrant' &&
        (painSeverity == 'moderate' || painSeverity == 'severe') &&
        ((feverChills == 'slight' || feverChills == 'definite') ||
            (vomiting == 'once_twice' || vomiting == 'multiple'))) {
      return RedFlagDetection(
        type: RedFlagType.cholecystitis,
        severity: RedFlagSeverity.urgent,
        symptoms: ['right_upper_quadrant_pain', 'fever_or_vomiting'],
        notifiedAt: DateTime.now(),
      );
    }
    return null;
  }

  /// 심한 탈수 체크
  RedFlagDetection? _checkSevereDehydration(DailyCheckinState state) {
    final hydration = state.answers[2]; // Q2
    final cannotKeepFluids = state.derivedAnswers['Q2-1'] as String?;
    final vomiting = state.derivedAnswers['Q1-1b'] as String?;

    if (cannotKeepFluids == 'cannot_keep' ||
        (vomiting == 'multiple' && hydration == 'poor')) {
      return RedFlagDetection(
        type: RedFlagType.severeDehydration,
        severity: RedFlagSeverity.urgent,
        symptoms: ['cannot_keep_fluids', 'frequent_vomiting'],
        notifiedAt: DateTime.now(),
      );
    }
    return null;
  }

  /// 장폐색 체크
  RedFlagDetection? _checkBowelObstruction(DailyCheckinState state) {
    final constipationDays = state.derivedAnswers['Q4-1a'] as String?;
    final bloatingSeverity = state.derivedAnswers['Q4-1a-bloating'] as String?;

    if ((constipationDays == '5_plus') &&
        bloatingSeverity == 'severe_no_gas') {
      return RedFlagDetection(
        type: RedFlagType.bowelObstruction,
        severity: RedFlagSeverity.warning,
        symptoms: ['prolonged_constipation', 'severe_bloating', 'no_gas'],
        notifiedAt: DateTime.now(),
      );
    }
    return null;
  }

  /// 저혈당 체크
  RedFlagDetection? _checkHypoglycemia(DailyCheckinState state) {
    final symptoms = state.derivedAnswers['Q5-1'] as String?;
    final tremor = state.derivedAnswers['Q5-2-tremor'] as String?;
    final onDiabetesMeds = state.derivedAnswers['Q5-2-meds'] as String?;

    if ((symptoms == 'dizziness' || symptoms == 'cold_sweat') &&
        tremor == 'yes' &&
        onDiabetesMeds == 'yes') {
      return RedFlagDetection(
        type: RedFlagType.hypoglycemia,
        severity: RedFlagSeverity.urgent,
        symptoms: ['dizziness', 'cold_sweat', 'tremor', 'on_diabetes_meds'],
        notifiedAt: DateTime.now(),
      );
    }
    return null;
  }

  /// 신부전 체크
  RedFlagDetection? _checkRenalImpairment(DailyCheckinState state) {
    final symptoms = state.derivedAnswers['Q5-1'] as String?;
    final decreasedUrine = state.derivedAnswers['Q5-3-urine'] as String?;
    final vomiting = state.derivedAnswers['Q1-1b'] as String?;
    final diarrhea = state.derivedAnswers['Q4-1b'] as String?;

    if ((symptoms == 'dyspnea' || symptoms == 'swelling') &&
        (decreasedUrine == 'slight' || decreasedUrine == 'severe') &&
        (vomiting == 'multiple' || diarrhea == '6_plus')) {
      return RedFlagDetection(
        type: RedFlagType.renalImpairment,
        severity: RedFlagSeverity.warning,
        symptoms: [
          'fatigue',
          'edema_or_dyspnea',
          'decreased_urine',
          'severe_vomiting_or_diarrhea'
        ],
        notifiedAt: DateTime.now(),
      );
    }
    return null;
  }

  // === Enum Parsing ===

  ConditionLevel _parseConditionLevel(String value) {
    switch (value) {
      case 'good':
        return ConditionLevel.good;
      case 'moderate':
        return ConditionLevel.moderate;
      case 'difficult':
        return ConditionLevel.difficult;
      default:
        return ConditionLevel.good;
    }
  }

  HydrationLevel _parseHydrationLevel(String value) {
    switch (value) {
      case 'good':
        return HydrationLevel.good;
      case 'moderate':
        return HydrationLevel.moderate;
      case 'poor':
        return HydrationLevel.poor;
      default:
        return HydrationLevel.good;
    }
  }

  GiComfortLevel _parseGiComfortLevel(String value) {
    switch (value) {
      case 'good':
        return GiComfortLevel.good;
      case 'uncomfortable':
        return GiComfortLevel.uncomfortable;
      case 'veryUncomfortable':
        return GiComfortLevel.veryUncomfortable;
      default:
        return GiComfortLevel.good;
    }
  }

  BowelCondition _parseBowelCondition(String value) {
    switch (value) {
      case 'normal':
        return BowelCondition.normal;
      case 'irregular':
        return BowelCondition.irregular;
      case 'difficult':
        return BowelCondition.difficult;
      default:
        return BowelCondition.normal;
    }
  }

  EnergyLevel _parseEnergyLevel(String value) {
    switch (value) {
      case 'good':
        return EnergyLevel.good;
      case 'normal':
        return EnergyLevel.normal;
      case 'tired':
        return EnergyLevel.tired;
      default:
        return EnergyLevel.good;
    }
  }

  MoodLevel _parseMoodLevel(String value) {
    switch (value) {
      case 'good':
        return MoodLevel.good;
      case 'neutral':
        return MoodLevel.neutral;
      case 'low':
        return MoodLevel.low;
      default:
        return MoodLevel.good;
    }
  }

  int? _calculateAppetiteScore(
    ConditionLevel mealCondition,
    Map<String, dynamic> derivedAnswers,
  ) {
    switch (mealCondition) {
      case ConditionLevel.good:
        return 5;
      case ConditionLevel.moderate:
        return 3;
      case ConditionLevel.difficult:
        // 파생 질문에서 결정
        final reason = derivedAnswers['Q1-1'] as String?;
        if (reason == 'nausea') {
          final severity = derivedAnswers['Q1-1a'] as String?;
          return severity == 'severe' ? 1 : 2;
        }
        return 2;
    }
  }
}
