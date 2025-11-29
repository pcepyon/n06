import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n06/features/onboarding/presentation/widgets/common/journey_progress_indicator.dart';
import 'package:n06/features/profile/application/notifiers/profile_notifier.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/tracking/application/providers.dart';
// PART 1: 공감과 희망
import 'package:n06/features/onboarding/presentation/widgets/education/welcome_screen.dart';
import 'package:n06/features/onboarding/presentation/widgets/education/not_your_fault_screen.dart';
import 'package:n06/features/onboarding/presentation/widgets/education/evidence_screen.dart';
// PART 2: 이해와 확신
import 'package:n06/features/onboarding/presentation/widgets/education/food_noise_screen.dart';
import 'package:n06/features/onboarding/presentation/widgets/education/how_it_works_screen.dart';
import 'package:n06/features/onboarding/presentation/widgets/education/journey_roadmap_screen.dart';
import 'package:n06/features/onboarding/presentation/widgets/education/side_effects_screen.dart';
// PART 3: 설정
import 'package:n06/features/onboarding/presentation/widgets/basic_profile_form.dart';
import 'package:n06/features/onboarding/presentation/widgets/weight_goal_form.dart';
import 'package:n06/features/onboarding/presentation/widgets/dosage_plan_form.dart';
import 'package:n06/features/onboarding/presentation/widgets/summary_screen.dart';
// PART 4: 준비와 시작
import 'package:n06/features/onboarding/presentation/widgets/preparation/injection_guide_screen.dart';
import 'package:n06/features/onboarding/presentation/widgets/preparation/app_features_screen.dart';
import 'package:n06/features/onboarding/presentation/widgets/preparation/commitment_screen.dart';

/// Part 구분
enum OnboardingPart {
  empathy, // 1-3 (공감과 희망)
  understanding, // 4-7 (이해와 확신)
  setup, // 8-11 (설정)
  preparation // 12-14 (준비와 시작)
}

/// 온보딩 14단계 화면 네비게이션
///
/// [isReviewMode]: true일 경우 리뷰 모드로 동작
/// - 기존 프로필 데이터를 불러와 입력 폼에 표시
/// - 입력값 수정은 가능하나 DB에 저장하지 않음
/// - Summary 화면에서 "완료" 버튼으로 표시 (저장 없이 종료)
class OnboardingScreen extends ConsumerStatefulWidget {
  final String? userId;
  final VoidCallback? onComplete;
  final bool isReviewMode;

  const OnboardingScreen({
    super.key,
    this.userId,
    this.onComplete,
    this.isReviewMode = false,
  });

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _pageController;
  int _currentStep = 0;
  static const int _totalSteps = 14;

  // PART 1-2 스킵 가능 여부
  bool _canSkipEducation = false;

  // Step 1 데이터 (기본 프로필)
  String _name = '';

  // Step 2 데이터 (체중 목표)
  double _currentWeight = 0;
  double _targetWeight = 0;
  int? _targetPeriodWeeks;

  // Step 3 데이터 (투여 계획)
  String _medicationName = '';
  DateTime _startDate = DateTime.now();
  int _cycleDays = 7;
  double _initialDose = 0.25;

  // [4] Food Noise 데이터
  int? _initialFoodNoiseLevel;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadEducationCompletedFlag();
    if (widget.isReviewMode) {
      _loadExistingProfileData();
    }
  }

  Future<void> _loadEducationCompletedFlag() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _canSkipEducation = prefs.getBool('education_completed') ?? false;
    });
  }

  /// 리뷰 모드: 기존 프로필 및 투여 계획 데이터를 로드하여 초기값으로 설정
  Future<void> _loadExistingProfileData() async {
    // 1. 프로필 데이터 로드
    final profileState = ref.read(profileNotifierProvider);
    profileState.whenData((profile) {
      if (profile != null && mounted) {
        setState(() {
          _name = profile.userName ?? '';
          _currentWeight = profile.currentWeight.value;
          _targetWeight = profile.targetWeight.value;
          _targetPeriodWeeks = profile.targetPeriodWeeks;
        });
      }
    });

    // 2. 투여 계획 데이터 로드
    final authState = ref.read(authNotifierProvider);
    if (authState.hasValue && authState.value != null) {
      final userId = authState.value!.id;
      final dosagePlanRepo = ref.read(dosagePlanRepositoryProvider);
      final dosagePlan = await dosagePlanRepo.getActiveDosagePlan(userId);
      if (dosagePlan != null && mounted) {
        setState(() {
          _medicationName = dosagePlan.medicationName;
          _startDate = dosagePlan.startDate;
          _cycleDays = dosagePlan.cycleDays;
          _initialDose = dosagePlan.initialDoseMg;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onStepChanged(int index) {
    setState(() {
      _currentStep = index;
    });
  }

  /// Part 1-2 스킵 → Part 3 설정 시작 (8번째 스크린, index 7)
  void _skipToSetup() {
    _pageController.animateToPage(
      7,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isReviewMode ? '온보딩 다시 보기' : '온보딩'),
        elevation: 0,
        leading: _currentStep == 0
            ? (widget.isReviewMode
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                : null)
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (_currentStep > 0) {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
      ),
      body: Column(
        children: [
          // 여정 진행 표시기
          JourneyProgressIndicator(
            currentStep: _currentStep,
            totalSteps: _totalSteps,
          ),
          // 페이지 뷰
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onStepChanged,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // ===== PART 1: 공감과 희망 (1-3) =====
                // [1] 환영
                WelcomeScreen(
                  onNext: _nextStep,
                  onSkip: _canSkipEducation ? _skipToSetup : null,
                ),
                // [2] 당신 탓 아니에요
                NotYourFaultScreen(
                  onNext: _nextStep,
                  onSkip: _canSkipEducation ? _skipToSetup : null,
                ),
                // [3] 변화의 증거들
                EvidenceScreen(
                  onNext: _nextStep,
                  onSkip: _canSkipEducation ? _skipToSetup : null,
                ),

                // ===== PART 2: 이해와 확신 (4-7) =====
                // [4] Food Noise
                FoodNoiseScreen(
                  onNext: _nextStep,
                  onSkip: _canSkipEducation ? _skipToSetup : null,
                  onFoodNoiseLevelChanged: (level) =>
                      _initialFoodNoiseLevel = level,
                ),
                // [5] 작동 원리
                HowItWorksScreen(
                  onNext: _nextStep,
                  onSkip: _canSkipEducation ? _skipToSetup : null,
                ),
                // [6] 여정 로드맵
                JourneyRoadmapScreen(
                  onNext: _nextStep,
                  onSkip: _canSkipEducation ? _skipToSetup : null,
                ),
                // [7] 적응과 대처
                SideEffectsScreen(
                  onNext: _nextStep,
                  onSkip: _canSkipEducation ? _skipToSetup : null,
                ),

                // ===== PART 3: 설정 (8-11) =====
                // [8] 기본 프로필
                BasicProfileForm(
                  onNameChanged: (name) => _name = name,
                  onNext: _nextStep,
                  isReviewMode: widget.isReviewMode,
                  initialName: widget.isReviewMode ? _name : null,
                ),
                // [9] 체중 목표
                WeightGoalForm(
                  onDataChanged: (current, target, period) {
                    _currentWeight = current;
                    _targetWeight = target;
                    _targetPeriodWeeks = period;
                  },
                  onNext: _nextStep,
                  isReviewMode: widget.isReviewMode,
                  initialCurrentWeight: widget.isReviewMode ? _currentWeight : null,
                  initialTargetWeight: widget.isReviewMode ? _targetWeight : null,
                  initialTargetPeriod: widget.isReviewMode ? _targetPeriodWeeks : null,
                ),
                // [10] 투여 계획
                DosagePlanForm(
                  onDataChanged: (medication, date, cycle, dose) {
                    _medicationName = medication;
                    _startDate = date;
                    _cycleDays = cycle;
                    _initialDose = dose;
                  },
                  onNext: _nextStep,
                  isReviewMode: widget.isReviewMode,
                  initialMedicationName: widget.isReviewMode ? _medicationName : null,
                  initialStartDate: widget.isReviewMode ? _startDate : null,
                  initialDose: widget.isReviewMode ? _initialDose : null,
                ),
                // [11] 요약 확인
                SummaryScreen(
                  userId: widget.userId ?? '',
                  name: _name,
                  currentWeight: _currentWeight,
                  targetWeight: _targetWeight,
                  targetPeriodWeeks: _targetPeriodWeeks,
                  medicationName: _medicationName,
                  startDate: _startDate,
                  cycleDays: _cycleDays,
                  initialDose: _initialDose,
                  onComplete: _nextStep,
                  isReviewMode: widget.isReviewMode,
                ),

                // ===== PART 4: 준비와 시작 (12-14) =====
                // [12] 주사 가이드
                InjectionGuideScreen(
                  onNext: _nextStep,
                ),
                // [13] 앱 사용법
                AppFeaturesScreen(
                  onNext: _nextStep,
                ),
                // [14] 약속과 시작
                CommitmentScreen(
                  name: _name,
                  currentWeight: _currentWeight,
                  targetWeight: _targetWeight,
                  startDate: _startDate,
                  medicationName: _medicationName,
                  initialDose: _initialDose,
                  onComplete: widget.isReviewMode
                      ? _completeReview
                      : _completeOnboarding,
                  isReviewMode: widget.isReviewMode,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 온보딩 완료 처리 (신규 사용자)
  Future<void> _completeOnboarding() async {
    // education_completed 플래그 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('education_completed', true);

    // initial_food_noise_level 저장 (선택)
    if (_initialFoodNoiseLevel != null) {
      await prefs.setInt('initial_food_noise_level', _initialFoodNoiseLevel!);
    }

    // 완료 콜백 또는 홈으로 이동
    if (mounted) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    }
  }

  /// 리뷰 모드 완료 처리 (DB 저장 없이 종료)
  void _completeReview() {
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
