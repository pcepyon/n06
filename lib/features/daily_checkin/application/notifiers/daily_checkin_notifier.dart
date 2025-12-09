import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/daily_checkin/application/providers.dart';
import 'package:n06/features/daily_checkin/domain/entities/daily_checkin.dart';
import 'package:n06/features/daily_checkin/domain/entities/symptom_detail.dart';
import 'package:n06/features/daily_checkin/domain/entities/checkin_context.dart';
import 'package:n06/features/daily_checkin/domain/entities/red_flag_detection.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
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

  /// 표시 대기 중인 피드백 메시지 (BUG-20251202-175417)
  final String? pendingFeedback;

  /// 피드백 표시 후 진행할 파생 질문 경로 (BUG-20251209-DERIVEDFEEDBACK)
  final String? pendingDerivedPath;

  /// 피드백 표시 후 진행할 메인 질문 스텝 (BUG-20251209-LASTDERIVED)
  final int? pendingMainStep;

  /// 오늘 이미 체크인이 존재하는지 여부 (수정 확인용)
  final bool hasExistingCheckinToday;

  /// 중복 체크인 확인 완료 여부
  final bool duplicateCheckConfirmed;

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
    this.pendingFeedback,
    this.pendingDerivedPath,
    this.pendingMainStep,
    this.hasExistingCheckinToday = false,
    this.duplicateCheckConfirmed = false,
  });

  DailyCheckinState copyWith({
    int? currentStep,
    double? weight,
    Map<int, String>? answers,
    Map<String, dynamic>? derivedAnswers,
    List<SymptomDetail>? symptomDetails,
    String? currentDerivedPath,
    bool clearCurrentDerivedPath = false, // BUG-20251202-231014: null 설정 지원
    bool? isComplete,
    DailyCheckin? savedCheckin,
    CheckinContext? context,
    String? pendingFeedback,
    String? pendingDerivedPath,
    bool clearPendingDerivedPath = false, // BUG-20251209-DERIVEDFEEDBACK: null 설정 지원
    int? pendingMainStep,
    bool clearPendingMainStep = false, // BUG-20251209-LASTDERIVED: null 설정 지원
    bool? hasExistingCheckinToday,
    bool? duplicateCheckConfirmed,
  }) {
    return DailyCheckinState(
      currentStep: currentStep ?? this.currentStep,
      weight: weight ?? this.weight,
      answers: answers ?? this.answers,
      derivedAnswers: derivedAnswers ?? this.derivedAnswers,
      symptomDetails: symptomDetails ?? this.symptomDetails,
      // BUG-20251202-231014: clearCurrentDerivedPath가 true면 null로 설정
      currentDerivedPath: clearCurrentDerivedPath
          ? null
          : (currentDerivedPath ?? this.currentDerivedPath),
      isComplete: isComplete ?? this.isComplete,
      savedCheckin: savedCheckin ?? this.savedCheckin,
      context: context ?? this.context,
      pendingFeedback: pendingFeedback,
      // BUG-20251209-DERIVEDFEEDBACK: clearPendingDerivedPath가 true면 null로 설정
      pendingDerivedPath: clearPendingDerivedPath
          ? null
          : (pendingDerivedPath ?? this.pendingDerivedPath),
      // BUG-20251209-LASTDERIVED: clearPendingMainStep이 true면 null로 설정
      pendingMainStep: clearPendingMainStep
          ? null
          : (pendingMainStep ?? this.pendingMainStep),
      hasExistingCheckinToday: hasExistingCheckinToday ?? this.hasExistingCheckinToday,
      duplicateCheckConfirmed: duplicateCheckConfirmed ?? this.duplicateCheckConfirmed,
    );
  }
}

@riverpod
class DailyCheckinNotifier extends _$DailyCheckinNotifier {
  // ✅ 의존성을 late final 필드로 선언 (getter 사용 금지 - BUG-20251205)
  late final _repository = ref.read(dailyCheckinRepositoryProvider);
  late final _medicationRepository = ref.read(medicationRepositoryProvider);
  late final _trackingRepository = ref.read(trackingRepositoryProvider);

  @override
  Future<DailyCheckinState> build() async {
    return const DailyCheckinState();
  }

  /// 체크인 시작
  Future<void> startCheckin() async {
    final link = ref.keepAlive();

    // userId 미리 캡처
    final userId = ref.read(authNotifierProvider).value?.id;
    if (userId == null) throw Exception('User not authenticated');

    try {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        // 오늘 체크인 존재 여부 확인
        final today = DateTime.now();
        final existingCheckin = await _repository.getByDate(userId, today);
        final hasExisting = existingCheckin != null;

        // 컨텍스트 로드
        final context = await _loadContext(userId);

        if (!ref.mounted) {
          return const DailyCheckinState();
        }

        return DailyCheckinState(
          context: context,
          hasExistingCheckinToday: hasExisting,
        );
      });
    } finally {
      link.close();
    }
  }

  /// 중복 체크인 확인 완료
  void confirmDuplicateCheckin() {
    final currentState = state.value ?? const DailyCheckinState();
    state = AsyncValue.data(
      currentState.copyWith(duplicateCheckConfirmed: true),
    );
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
  /// [feedback] 파라미터는 Presentation Layer에서 전달 (BUG-20251202-175417)
  Future<void> submitAnswer(
    int questionIndex,
    String answer, {
    String? feedback,
  }) async {
    final currentState = state.value ?? const DailyCheckinState();

    final newAnswers = Map<int, String>.from(currentState.answers);
    newAnswers[questionIndex] = answer;

    // 파생 질문이 필요한지 확인
    final needsDerived = _needsDerivedQuestion(questionIndex, answer);

    if (needsDerived && feedback != null) {
      // 파생 질문이 필요하고 피드백이 있으면: 피드백 표시 대기 + 파생 경로 저장 (BUG-20251209-DERIVEDFEEDBACK)
      final derivedPath = _getDerivedPath(questionIndex);
      state = AsyncValue.data(
        currentState.copyWith(
          answers: newAnswers,
          pendingFeedback: feedback,
          pendingDerivedPath: derivedPath, // 피드백 후 진행할 파생 경로
        ),
      );
    } else if (needsDerived) {
      // 파생 질문으로 분기 (피드백 없음)
      final derivedPath = _getDerivedPath(questionIndex);
      state = AsyncValue.data(
        currentState.copyWith(
          answers: newAnswers,
          currentDerivedPath: derivedPath,
        ),
      );
    } else if (feedback != null) {
      // 피드백이 있으면 표시 대기 상태로 (BUG-20251202-175417)
      state = AsyncValue.data(
        currentState.copyWith(
          answers: newAnswers,
          pendingFeedback: feedback,
        ),
      );
    } else if (questionIndex == 6) {
      // Q6 완료 (피드백 없음) → 바로 체크인 완료 (BUG-20251202-Q6FINISH)
      state = AsyncValue.data(
        currentState.copyWith(
          answers: newAnswers,
          clearCurrentDerivedPath: true, // BUG-20251202-231014
        ),
      );
      await finishCheckin();
    } else {
      // 다음 질문으로 즉시 이동 (피드백 없음)
      state = AsyncValue.data(
        currentState.copyWith(
          answers: newAnswers,
          currentStep: questionIndex + 1,
          clearCurrentDerivedPath: true, // BUG-20251202-231014
        ),
      );
    }
  }

  /// 파생 질문 답변
  /// [feedback] 파라미터는 Presentation Layer에서 전달 (인라인 피드백 표시용)
  Future<void> submitDerivedAnswer(
    String path,
    String answer, {
    String? feedback,
  }) async {
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

    if (nextDerivedPath != null && feedback != null) {
      // 다음 파생 질문이 있고 피드백이 있으면: 피드백 표시 후 파생 질문으로 진행
      // BUG-20251209-DERIVEDFEEDBACK: currentDerivedPath를 명시적으로 현재 경로로 유지
      // → 피드백이 현재 질문 화면에서 표시되고, dismissFeedbackAndProceed 후에 다음 질문으로 전환
      state = AsyncValue.data(
        currentState.copyWith(
          derivedAnswers: newDerivedAnswers,
          symptomDetails: newSymptomDetails,
          pendingFeedback: feedback,
          pendingDerivedPath: nextDerivedPath,
          currentDerivedPath: path, // 명시적으로 현재 경로 유지
        ),
      );
    } else if (nextDerivedPath != null) {
      // 다음 파생 질문으로 (피드백 없음)
      state = AsyncValue.data(
        currentState.copyWith(
          derivedAnswers: newDerivedAnswers,
          symptomDetails: newSymptomDetails,
          currentDerivedPath: nextDerivedPath,
          clearPendingDerivedPath: true,
        ),
      );
    } else if (feedback != null) {
      // 마지막 파생 질문에서 피드백 표시 후 메인 질문으로 복귀
      // BUG-20251209-LASTDERIVED: 현재 파생 질문 화면을 유지하고, pendingMainStep에 다음 스텝 저장
      final currentQuestion = _getQuestionIndexFromPath(path);
      final nextStep = currentQuestion < 6 ? currentQuestion + 1 : currentQuestion;

      state = AsyncValue.data(
        currentState.copyWith(
          derivedAnswers: newDerivedAnswers,
          symptomDetails: newSymptomDetails,
          pendingFeedback: feedback,
          currentDerivedPath: path, // 현재 파생 질문 화면 유지
          clearPendingDerivedPath: true,
          pendingMainStep: nextStep, // 피드백 후 이동할 메인 스텝
        ),
      );
    } else {
      // 메인 질문으로 복귀 (피드백 없음)
      final currentQuestion = _getQuestionIndexFromPath(path);
      final nextStep = currentQuestion < 6 ? currentQuestion + 1 : currentQuestion;

      state = AsyncValue.data(
        currentState.copyWith(
          derivedAnswers: newDerivedAnswers,
          symptomDetails: newSymptomDetails,
          clearCurrentDerivedPath: true,
          clearPendingDerivedPath: true,
          currentStep: nextStep,
        ),
      );
    }
  }

  /// 피드백 확인 후 다음 질문으로 진행 (BUG-20251202-175417)
  Future<void> dismissFeedbackAndProceed() async {
    final currentState = state.value ?? const DailyCheckinState();

    // pendingDerivedPath가 있으면 파생 질문으로 진행 (BUG-20251209-DERIVEDFEEDBACK)
    if (currentState.pendingDerivedPath != null) {
      state = AsyncValue.data(
        currentState.copyWith(
          pendingFeedback: null,
          currentDerivedPath: currentState.pendingDerivedPath,
          clearPendingDerivedPath: true,
          clearPendingMainStep: true,
        ),
      );
      return;
    }

    // pendingMainStep이 있으면 메인 질문으로 복귀 (BUG-20251209-LASTDERIVED)
    // 마지막 파생 질문에서 피드백 표시 후 메인 질문으로 이동
    if (currentState.pendingMainStep != null) {
      state = AsyncValue.data(
        currentState.copyWith(
          pendingFeedback: null,
          clearCurrentDerivedPath: true,
          currentStep: currentState.pendingMainStep,
          clearPendingMainStep: true,
        ),
      );
      return;
    }

    // Q6 피드백 후에는 체크인 완료 (BUG-20251202-Q6FINISH)
    if (currentState.currentStep == 6) {
      state = AsyncValue.data(
        currentState.copyWith(pendingFeedback: null),
      );
      await finishCheckin();
      return;
    }

    // 다음 질문으로 이동
    state = AsyncValue.data(
      currentState.copyWith(
        currentStep: currentState.currentStep + 1,
        pendingFeedback: null,
      ),
    );
  }

  /// 이전 질문으로 이동
  Future<void> goBack() async {
    final currentState = state.value ?? const DailyCheckinState();

    if (currentState.currentDerivedPath != null) {
      // 파생 질문에서 메인 질문으로
      state = AsyncValue.data(
        currentState.copyWith(
          clearCurrentDerivedPath: true, // BUG-20251202-231014
          clearPendingDerivedPath: true, // BUG-20251209-DERIVEDFEEDBACK: 뒤로 가기 시 대기 중인 파생 경로도 클리어
        ),
      );
    } else if (currentState.currentStep > 0) {
      // 이전 메인 질문으로
      state = AsyncValue.data(
        currentState.copyWith(
          currentStep: currentState.currentStep - 1,
          clearPendingDerivedPath: true, // BUG-20251209-DERIVEDFEEDBACK: 뒤로 가기 시 대기 중인 파생 경로도 클리어
        ),
      );
    }
  }

  /// 체크인 완료 및 저장
  Future<void> finishCheckin() async {
    final link = ref.keepAlive();

    // userId 미리 캡처
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

        // 체중 저장 (입력된 경우만, BUG-20251202-WEIGHT)
        if (currentState.weight != null) {
          final weightLog = WeightLog(
            id: const Uuid().v4(),
            userId: userId,
            logDate: DateTime.now(),
            weightKg: currentState.weight!,
            createdAt: DateTime.now(),
          );
          await _trackingRepository.saveWeightLog(weightLog);
        }

        if (!ref.mounted) {
          return currentState;
        }

        // 저장 후 연속 일수 다시 조회 (오늘 체크인 포함)
        final updatedConsecutiveDays = await _repository.getConsecutiveDays(userId);

        // context 업데이트
        final updatedContext = currentState.context?.copyWith(
          consecutiveDays: updatedConsecutiveDays,
        );

        return currentState.copyWith(
          isComplete: true,
          savedCheckin: checkin,
          context: updatedContext,
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

    // 마지막 체크인 이후 일수 (날짜만 비교, 시간 제외)
    final daysSinceLastCheckin = latestCheckin != null
        ? (() {
            final now = DateTime.now();
            final nowDate = DateTime(now.year, now.month, now.day);
            final checkinDate = DateTime(
              latestCheckin.checkinDate.year,
              latestCheckin.checkinDate.month,
              latestCheckin.checkinDate.day,
            );
            return nowDate.difference(checkinDate).inDays;
          })()
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
      case 3: // Q3 속 편안함 (veryUncomfortable만 파생 질문)
        return answer == 'veryUncomfortable';
      case 4: // Q4 화장실 (difficult만 파생 질문)
        return answer == 'difficult';
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
    // Q3-2: 복통 위치 → 통증 강도 (questions.dart value: 'upper', 'general')
    if (currentPath == 'Q3-2' &&
        (answer == 'upper' || answer == 'general')) {
      return 'Q3-3'; // 상복부 통증 상세
    }
    // Q3-3: 췌장염 Red Flag 체크
    if (currentPath == 'Q3-3' && (answer == 'moderate' || answer == 'severe')) {
      return 'Q3-3-radiation'; // 등 방사통 체크
    }
    if (currentPath == 'Q3-3-radiation' &&
        (answer == 'slight' || answer == 'definite' || answer == 'yes')) {
      return 'Q3-3-duration'; // 지속 시간 체크
    }
    // Q3-4: 담낭염 Red Flag 체크 (questions.dart value: 'right_upper')
    if (currentPath == 'Q3-2' && answer == 'right_upper') {
      return 'Q3-4'; // 우상복부 통증 상세
    }
    if (currentPath == 'Q3-4' && (answer == 'moderate' || answer == 'severe')) {
      return 'Q3-4-fever'; // 발열/오한 체크
    }

    // Q4-1 (변비/설사)
    if (currentPath == 'Q4-1' && answer == 'constipation') {
      return 'Q4-1a'; // 변비 상세
    }
    // Q4-1a: 장폐색 Red Flag 체크
    if (currentPath == 'Q4-1a' && (answer == 'several' || answer == 'many')) {
      return 'Q4-1a-bloating'; // 빵빵함 정도
    }
    if (currentPath == 'Q4-1' && answer == 'diarrhea') {
      return 'Q4-1b'; // 설사 상세
    }

    // Q5-1 (피로 관련 증상)
    if (currentPath == 'Q5-1' &&
        (answer == 'dizziness' || answer == 'cold_sweat')) {
      return 'Q5-2'; // 저혈당 체크
    }
    // Q5-2: 저혈당 Red Flag 체크
    if (currentPath == 'Q5-2' && answer == 'yes') {
      return 'Q5-2-tremor'; // 손떨림 체크
    }
    if (currentPath == 'Q5-2-tremor' &&
        (answer == 'mild' || answer == 'severe')) {
      return 'Q5-2-meds'; // 당뇨약 복용 여부
    }
    // Q5-3: 신부전 Red Flag 체크
    if (currentPath == 'Q5-1' &&
        (answer == 'dyspnea' || answer == 'swelling')) {
      return 'Q5-3'; // 신부전 체크
    }
    if (currentPath == 'Q5-3' &&
        (answer == 'decreased' || answer == 'severely_decreased')) {
      return 'Q5-3-urine'; // 소변량 상세
    }
    if (currentPath == 'Q5-3-urine' &&
        (answer == 'decreased' || answer == 'significantly_decreased')) {
      return 'Q5-3-weight'; // 체중 증가 체크
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
    // questions.dart values: 'no', 'once', 'several'
    if (path == 'Q1-1b') {
      final vomitCount = answer == 'no'
          ? 0
          : answer == 'once'
              ? 1
              : 3; // 'several'
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
    // questions.dart values: 'few', 'several', 'many'
    if (path == 'Q4-1a') {
      final days = answer == 'few'
          ? 2
          : answer == 'several'
              ? 4
              : 6; // 'many'
      details.add(SymptomDetail(
        type: SymptomType.constipation,
        severity: days >= 5 ? 3 : 2,
        details: {'days_without': days},
      ));
    }

    // Q4-1b: 설사 상세
    // questions.dart values: 'few', 'several', 'many'
    if (path == 'Q4-1b') {
      final frequency = answer == 'few'
          ? 3
          : answer == 'several'
              ? 5
              : 7; // 'many'
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

    // questions.dart value: 'upper', 'general' (not 'upper_abdomen', 'periumbilical')
    if ((painLocation == 'upper' || painLocation == 'general') &&
        (painSeverity == 'moderate' || painSeverity == 'severe') &&
        (radiationToBack == 'slight' || radiationToBack == 'definite' || radiationToBack == 'yes') &&
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

    // questions.dart value: 'right_upper' (not 'right_upper_quadrant')
    // questions.dart vomiting values: 'no', 'once', 'several'
    if (painLocation == 'right_upper' &&
        (painSeverity == 'moderate' || painSeverity == 'severe') &&
        ((feverChills == 'slight' || feverChills == 'definite' || feverChills == 'yes') ||
            (vomiting == 'once' || vomiting == 'several'))) {
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

    // questions.dart vomiting values: 'no', 'once', 'several'
    if (cannotKeepFluids == 'cannot_keep' ||
        (vomiting == 'several' && hydration == 'poor')) {
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

    if ((constipationDays == 'many') &&
        bloatingSeverity == 'severe') {
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
        (tremor == 'mild' || tremor == 'severe') &&
        (onDiabetesMeds == 'oral' || onDiabetesMeds == 'insulin')) {
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

    // questions.dart vomiting values: 'no', 'once', 'several'
    // questions.dart diarrhea values: 'few', 'several', 'many'
    if ((symptoms == 'dyspnea' || symptoms == 'swelling') &&
        (decreasedUrine == 'decreased' || decreasedUrine == 'significantly_decreased') &&
        (vomiting == 'several' || diarrhea == 'many')) {
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
