import 'dart:async';

import 'package:flutter/material.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/features/daily_checkin/presentation/widgets/answer_button.dart';
import 'package:n06/features/daily_checkin/presentation/widgets/feedback_card.dart';
import 'package:n06/features/daily_checkin/presentation/widgets/question_card.dart';
import 'package:n06/features/daily_checkin/domain/entities/checkin_feedback.dart';

/// 데일리 체크인 체험용 데모 위젯
///
/// Provider 의존성 없이 로컬 상태로 동작하는 순수 UI 데모입니다.
/// 기존 QuestionCard, AnswerButton, FeedbackCard 위젯을 재사용하여
/// 데일리 체크인 플로우를 시뮬레이션합니다.
///
/// 특징:
/// - 하드코딩된 3개 질문 (식사, 속 편안함, 에너지)
/// - 각 질문당 3-4개 답변 옵션
/// - 답변 선택 시 피드백 표시 (2초 후 자동 전환)
/// - 완료 시 onComplete 콜백 호출
class DailyCheckinDemo extends StatefulWidget {
  final VoidCallback? onComplete;

  const DailyCheckinDemo({super.key, this.onComplete});

  @override
  State<DailyCheckinDemo> createState() => _DailyCheckinDemoState();
}

class _DailyCheckinDemoState extends State<DailyCheckinDemo>
    with SingleTickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  String? _feedbackMessage;
  Timer? _feedbackTimer;
  bool _isTransitioning = false;
  bool _isComplete = false;

  // 애니메이션 컨트롤러 (질문 전환용)
  late final AnimationController _transitionController;
  late final Animation<double> _fadeAnimation;

  // 더미 질문 데이터 (간소화된 3개 질문)
  late final List<_DemoQuestion> _demoQuestions;

  @override
  void initState() {
    super.initState();

    // 전환 애니메이션 설정
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    );
    _transitionController.value = 1.0; // 초기 상태는 보이는 상태

    _demoQuestions = [
      // Q1. 식사 질문
      _DemoQuestion(
        emoji: '🍽️',
        getQuestion: (l10n) => l10n.checkin_meal_question,
        options: [
          _DemoAnswerOption(
            emoji: '😊',
            getText: (l10n) => l10n.checkin_meal_answerGood,
            value: 'good',
            getFeedback: (l10n) => l10n.checkin_meal_feedbackGood,
            isPositive: true,
          ),
          _DemoAnswerOption(
            emoji: '😐',
            getText: (l10n) => l10n.checkin_meal_answerModerate,
            value: 'moderate',
            getFeedback: (l10n) => l10n.checkin_meal_feedbackModerate,
            isPositive: false,
          ),
          _DemoAnswerOption(
            emoji: '😔',
            getText: (l10n) => l10n.checkin_meal_answerDifficult,
            value: 'difficult',
            getFeedback: (l10n) => '어려움이 있으셨군요. 천천히 적응해 나가면 괜찮아질 거예요.',
            isPositive: false,
          ),
        ],
      ),
      // Q2. 속 편안함 질문
      _DemoQuestion(
        emoji: '🫄',
        getQuestion: (l10n) => l10n.checkin_giComfort_question,
        options: [
          _DemoAnswerOption(
            emoji: '😌',
            getText: (l10n) => l10n.checkin_giComfort_answerGood,
            value: 'good',
            getFeedback: (l10n) => l10n.checkin_giComfort_feedbackGood,
            isPositive: true,
          ),
          _DemoAnswerOption(
            emoji: '😕',
            getText: (l10n) => l10n.checkin_giComfort_answerUncomfortable,
            value: 'uncomfortable',
            getFeedback: (l10n) => l10n.checkin_giComfort_feedbackUncomfortable,
            isPositive: false,
          ),
          _DemoAnswerOption(
            emoji: '😣',
            getText: (l10n) => l10n.checkin_giComfort_answerVeryUncomfortable,
            value: 'veryUncomfortable',
            getFeedback: (l10n) => '많이 불편하시군요. 증상이 지속되면 의료진과 상담해 주세요.',
            isPositive: false,
          ),
        ],
      ),
      // Q3. 에너지 질문
      _DemoQuestion(
        emoji: '⚡',
        getQuestion: (l10n) => l10n.checkin_energy_question,
        options: [
          _DemoAnswerOption(
            emoji: '🤩',
            getText: (l10n) => l10n.checkin_energy_answerGood,
            value: 'good',
            getFeedback: (l10n) => l10n.checkin_energy_feedbackGood,
            isPositive: true,
          ),
          _DemoAnswerOption(
            emoji: '😐',
            getText: (l10n) => l10n.checkin_energy_answerNormal,
            value: 'normal',
            getFeedback: (l10n) => l10n.checkin_energy_feedbackNormal,
            isPositive: true,
          ),
          _DemoAnswerOption(
            emoji: '😴',
            getText: (l10n) => l10n.checkin_energy_answerTired,
            value: 'tired',
            getFeedback: (l10n) => '피곤하시군요. 충분한 휴식을 취해 주세요.',
            isPositive: false,
          ),
        ],
      ),
    ];
  }

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    _transitionController.dispose();
    super.dispose();
  }

  void _handleAnswerSelected(_DemoAnswerOption option) {
    // 이미 전환 중이면 무시
    if (_isTransitioning) return;

    setState(() {
      _selectedAnswer = option.value;
      _feedbackMessage = option.getFeedback(context.l10n);
    });

    // 1.5초 후 자동 전환 (피드백 읽을 시간)
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      _transitionToNext();
    });
  }

  Future<void> _transitionToNext() async {
    if (_isTransitioning) return;
    _isTransitioning = true;

    // 페이드 아웃
    await _transitionController.reverse();

    if (!mounted) return;

    if (_currentQuestionIndex < _demoQuestions.length - 1) {
      // 다음 질문으로
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _feedbackMessage = null;
      });

      // 페이드 인
      await _transitionController.forward();
    } else {
      // 완료 상태로 전환
      setState(() {
        _selectedAnswer = null;
        _feedbackMessage = null;
        _isComplete = true;
      });

      // 페이드 인 (완료 화면 표시)
      await _transitionController.forward();

      widget.onComplete?.call();
    }

    _isTransitioning = false;
  }

  @override
  Widget build(BuildContext context) {
    // 완료 상태면 완료 화면 표시
    if (_isComplete) {
      return _buildCompletionView();
    }

    final currentQuestion = _demoQuestions[_currentQuestionIndex];

    // Note: SingleChildScrollView 내부에서 사용되므로 Spacer 대신 SizedBox 사용
    return Padding(
      padding: const EdgeInsets.all(24),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // 진행률 표시
            _buildProgressIndicator(),
            const SizedBox(height: 24),
            // 질문 카드
            QuestionCard(
              emoji: currentQuestion.emoji,
              question: currentQuestion.getQuestion(context.l10n),
            ),
            const SizedBox(height: 32),
            // 답변 버튼들
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: currentQuestion.options.map((option) {
                final isSelected = _selectedAnswer == option.value;

                return AnswerButton(
                  emoji: option.emoji,
                  text: option.getText(context.l10n),
                  isSelected: isSelected,
                  isPositive: option.isPositive,
                  onTap: () => _handleAnswerSelected(option),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // 피드백 카드 (애니메이션 적용)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: _feedbackMessage != null
                  ? FeedbackCard.direct(
                      message: _feedbackMessage!,
                      tone: FeedbackTone.positive,
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 완료 화면
  Widget _buildCompletionView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            const SizedBox(height: 32),
            // 완료 이모지
            const Text(
              '🎉',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 24),
            // 완료 메시지
            Text(
              '체험 완료!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              '매일 이렇게 간단한 체크인으로\n나의 컨디션을 기록할 수 있어요',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 32),
            // 완료된 진행률 표시
            _buildCompletedProgressIndicator(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 완료된 진행률 표시 위젯
  Widget _buildCompletedProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_demoQuestions.length, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981), // Green (모두 완료)
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  /// 진행률 표시 위젯
  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_demoQuestions.length, (index) {
        final isCompleted = index < _currentQuestionIndex;
        final isCurrent = index == _currentQuestionIndex;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isCurrent ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isCompleted || isCurrent
                ? const Color(0xFF10B981) // Green
                : const Color(0xFFE5E7EB), // Gray
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

/// 데모용 질문 데이터 구조
class _DemoQuestion {
  final String emoji;
  final String Function(dynamic) getQuestion;
  final List<_DemoAnswerOption> options;

  const _DemoQuestion({
    required this.emoji,
    required this.getQuestion,
    required this.options,
  });
}

/// 데모용 답변 옵션 데이터 구조
class _DemoAnswerOption {
  final String emoji;
  final String Function(dynamic) getText;
  final String value;
  final String Function(dynamic) getFeedback;
  final bool isPositive;

  const _DemoAnswerOption({
    required this.emoji,
    required this.getText,
    required this.value,
    required this.getFeedback,
    this.isPositive = false,
  });
}
