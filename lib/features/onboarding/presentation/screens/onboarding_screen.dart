import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
// Form Widgets
import 'package:n06/features/onboarding/presentation/widgets/basic_profile_form.dart';
import 'package:n06/features/onboarding/presentation/widgets/weight_goal_form.dart';
import 'package:n06/features/onboarding/presentation/widgets/dosage_plan_form.dart';
import 'package:n06/features/onboarding/presentation/widgets/summary_screen.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';

/// 온보딩 5단계 화면 네비게이션
class OnboardingScreen extends ConsumerStatefulWidget {
  final String? userId;
  final VoidCallback? onComplete;

  const OnboardingScreen({
    super.key,
    this.userId,
    this.onComplete,
  });

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> with TickerProviderStateMixin {
  int _currentStep = 0;
  static const int _totalSteps = 5;
  final Set<int> _visitedSteps = {0};

  // Form data
  String _name = '';
  double _currentWeight = 0;
  double _targetWeight = 0;
  int? _targetPeriodWeeks;
  String _medicationName = '';
  DateTime _startDate = DateTime.now();
  int _cycleDays = 7;
  double _initialDose = 0.25;

  // Page transition animation
  late final AnimationController _pageTransitionController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  bool _isTransitioning = false;
  bool _transitionForward = true;

  // Confetti controller for completion screen
  late final ConfettiController _confettiController;

  /// 유효한 userId를 반환 (widget.userId 우선, 없으면 authProvider에서 조회)
  String get _effectiveUserId {
    if (widget.userId != null && widget.userId!.isNotEmpty) {
      return widget.userId!;
    }
    final authState = ref.read(authNotifierProvider);
    return authState.value?.id ?? '';
  }

  @override
  void initState() {
    super.initState();

    // Page transition animation
    _pageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeOut,
    );

    _pageTransitionController.value = 1.0;

    // Confetti controller
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _pageTransitionController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  /// 페이지 전환 (스케일 + 페이드 애니메이션)
  Future<void> _goToPage(int pageIndex) async {
    if (_isTransitioning || pageIndex == _currentStep) return;
    if (pageIndex < 0 || pageIndex >= _totalSteps) return;

    _isTransitioning = true;
    _transitionForward = pageIndex > _currentStep;

    // Fade out
    await _pageTransitionController.reverse();

    setState(() {
      _currentStep = pageIndex;
      _visitedSteps.add(pageIndex);
    });

    HapticFeedback.selectionClick();

    // Fade in
    await _pageTransitionController.forward();
    _isTransitioning = false;

    // Trigger confetti on completion screen
    if (pageIndex == 4) {
      _confettiController.play();
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _goToPage(_currentStep + 1);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _goToPage(_currentStep - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Dot Navigation Indicator (5 dots)
          _buildDotNavigator(),
          // Page Content with animation
          Expanded(
            child: AnimatedBuilder(
              animation: _pageTransitionController,
              builder: (context, child) {
                final scale = _transitionForward
                    ? _scaleAnimation.value
                    : 2.0 - _scaleAnimation.value;

                return Transform.scale(
                  scale: scale.clamp(0.92, 1.0),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: _buildCurrentPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotNavigator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.neutral200,
                borderRadius: BorderRadius.circular(1.5),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: constraints.maxWidth * (_currentStep / (_totalSteps - 1)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryHover],
                      ),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_totalSteps, (index) {
                return _buildDot(index);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == _currentStep;
    final isVisited = _visitedSteps.contains(index);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _goToPage(index);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 32 : 24,
              height: isActive ? 32 : 24,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : isVisited
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : AppColors.neutral200,
                shape: BoxShape.circle,
                border: isVisited && !isActive
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: AppTypography.labelSmall.copyWith(
                    color: isActive
                        ? Colors.white
                        : isVisited
                            ? AppColors.primary
                            : AppColors.textTertiary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentStep) {
      case 0:
        return _WelcomeScreen(onNext: _nextStep);
      case 1:
        return _PageWrapper(
          showBackButton: true,
          onBack: _previousStep,
          child: BasicProfileForm(
            onNameChanged: (name) => _name = name,
            onNext: _nextStep,
          ),
        );
      case 2:
        return _PageWrapper(
          showBackButton: true,
          onBack: _previousStep,
          child: WeightGoalForm(
            onDataChanged: (current, target, period) {
              _currentWeight = current;
              _targetWeight = target;
              _targetPeriodWeeks = period;
            },
            onNext: _nextStep,
          ),
        );
      case 3:
        return _PageWrapper(
          showBackButton: true,
          onBack: _previousStep,
          child: DosagePlanForm(
            onDataChanged: (medication, date, cycle, dose) {
              _medicationName = medication;
              _startDate = date;
              _cycleDays = cycle;
              _initialDose = dose;
            },
            onNext: _nextStep,
          ),
        );
      case 4:
        return _CompletionScreen(
          confettiController: _confettiController,
          userId: _effectiveUserId,
          name: _name,
          currentWeight: _currentWeight,
          targetWeight: _targetWeight,
          targetPeriodWeeks: _targetPeriodWeeks,
          medicationName: _medicationName,
          startDate: _startDate,
          cycleDays: _cycleDays,
          initialDose: _initialDose,
          onComplete: _completeOnboarding,
          onBack: _previousStep,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// 온보딩 완료 처리
  Future<void> _completeOnboarding() async {
    if (mounted && widget.onComplete != null) {
      widget.onComplete!();
    }
  }
}

/// Welcome Screen (Index 0)
class _WelcomeScreen extends StatelessWidget {
  final VoidCallback onNext;

  const _WelcomeScreen({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '이제 내 여정을\n시작해볼까요?',
                    style: AppTypography.heading1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '간단한 설정으로 맞춤형 여정을 시작하세요.',
                    style: AppTypography.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: GabiumButton(
              text: '시작하기',
              onPressed: onNext,
              variant: GabiumButtonVariant.primary,
              size: GabiumButtonSize.medium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Page Wrapper with optional back button
class _PageWrapper extends StatelessWidget {
  final Widget child;
  final bool showBackButton;
  final VoidCallback? onBack;

  const _PageWrapper({
    required this.child,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showBackButton)
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: onBack,
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: child,
          ),
        ),
      ],
    );
  }
}

/// Completion Screen with Confetti (Index 4)
class _CompletionScreen extends ConsumerWidget {
  final ConfettiController confettiController;
  final String userId;
  final String name;
  final double currentWeight;
  final double targetWeight;
  final int? targetPeriodWeeks;
  final String medicationName;
  final DateTime startDate;
  final int cycleDays;
  final double initialDose;
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const _CompletionScreen({
    required this.confettiController,
    required this.userId,
    required this.name,
    required this.currentWeight,
    required this.targetWeight,
    required this.targetPeriodWeeks,
    required this.medicationName,
    required this.startDate,
    required this.cycleDays,
    required this.initialDose,
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: onBack,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: SummaryScreen(
                  userId: userId,
                  name: name,
                  currentWeight: currentWeight,
                  targetWeight: targetWeight,
                  targetPeriodWeeks: targetPeriodWeeks,
                  medicationName: medicationName,
                  startDate: startDate,
                  cycleDays: cycleDays,
                  initialDose: initialDose,
                  onComplete: onComplete,
                ),
              ),
            ),
          ],
        ),
        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              AppColors.primary,
              AppColors.secondary,
              AppColors.success,
              AppColors.info,
            ],
          ),
        ),
      ],
    );
  }
}
