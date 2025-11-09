import 'package:flutter/material.dart';
import 'package:n06/features/onboarding/domain/entities/escalation_step.dart';
import 'package:n06/features/onboarding/presentation/widgets/basic_profile_form.dart';
import 'package:n06/features/onboarding/presentation/widgets/weight_goal_form.dart';
import 'package:n06/features/onboarding/presentation/widgets/dosage_plan_form.dart';
import 'package:n06/features/onboarding/presentation/widgets/summary_screen.dart';

/// 온보딩 4단계 화면 네비게이션
class OnboardingScreen extends StatefulWidget {
  final String? userId;
  final VoidCallback? onComplete;

  const OnboardingScreen({
    Key? key,
    this.userId,
    this.onComplete,
  }) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentStep = 0;

  // Step 1 데이터
  String _name = '';

  // Step 2 데이터
  double _currentWeight = 0;
  double _targetWeight = 0;
  int? _targetPeriodWeeks;

  // Step 3 데이터
  String _medicationName = '';
  DateTime _startDate = DateTime.now();
  int _cycleDays = 7;
  double _initialDose = 0.25;
  List<EscalationStep>? _escalationPlan;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('온보딩'),
        elevation: 0,
        leading: _currentStep == 0
            ? null
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
          // 진행 표시기
          LinearProgressIndicator(
            value: (_currentStep + 1) / 4,
            minHeight: 4,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '${_currentStep + 1}/4단계',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          // 페이지 뷰
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onStepChanged,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Step 1: 기본 프로필
                BasicProfileForm(
                  onNameChanged: (name) => _name = name,
                  onNext: _nextStep,
                ),
                // Step 2: 체중 및 목표
                WeightGoalForm(
                  onDataChanged: (current, target, period) {
                    _currentWeight = current;
                    _targetWeight = target;
                    _targetPeriodWeeks = period;
                  },
                  onNext: _nextStep,
                ),
                // Step 3: 투여 계획
                DosagePlanForm(
                  onDataChanged: (medication, date, cycle, dose, escalation) {
                    _medicationName = medication;
                    _startDate = date;
                    _cycleDays = cycle;
                    _initialDose = dose;
                    _escalationPlan = escalation;
                  },
                  onNext: _nextStep,
                ),
                // Step 4: 요약 및 확인
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
                  escalationPlan: _escalationPlan,
                  onComplete: widget.onComplete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
