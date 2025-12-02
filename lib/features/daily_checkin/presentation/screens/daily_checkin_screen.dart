import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/daily_checkin/application/notifiers/daily_checkin_notifier.dart';
import 'package:n06/features/daily_checkin/application/notifiers/checkin_feedback_notifier.dart';
import 'package:n06/features/daily_checkin/presentation/constants/checkin_strings.dart';
import 'package:n06/features/daily_checkin/presentation/constants/questions.dart';
import 'package:n06/features/daily_checkin/presentation/widgets/answer_button.dart';
import 'package:n06/features/daily_checkin/presentation/widgets/feedback_card.dart';
import 'package:n06/features/daily_checkin/presentation/widgets/progress_indicator.dart';
import 'package:n06/features/daily_checkin/presentation/widgets/question_card.dart';
import 'package:n06/features/daily_checkin/presentation/widgets/weight_input_section.dart';
import 'package:n06/features/daily_checkin/presentation/widgets/derived_question_sheet.dart';
import 'package:n06/features/daily_checkin/presentation/widgets/red_flag_guidance_dialog.dart';

/// 데일리 체크인 화면
///
/// 전체 플로우:
/// 1. 인사 메시지 (컨텍스트별)
/// 2. 체중 입력 (선택)
/// 3. 6개 질문 순차 진행
/// 4. 완료 화면
class DailyCheckinScreen extends ConsumerStatefulWidget {
  const DailyCheckinScreen({super.key});

  @override
  ConsumerState<DailyCheckinScreen> createState() => _DailyCheckinScreenState();
}

class _DailyCheckinScreenState extends ConsumerState<DailyCheckinScreen> {
  final PageController _pageController = PageController();

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // 체크인 시작은 didChangeDependencies에서
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      // 체크인 시작 - 위젯 트리 빌드 후 실행 (BUG-20251202-153023)
      Future.microtask(() {
        ref.read(dailyCheckinProvider.notifier).startCheckin();
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleWeightSubmit(double weight) {
    ref.read(dailyCheckinProvider.notifier).submitWeight(weight);
  }

  void _skipWeight() {
    ref.read(dailyCheckinProvider.notifier).submitWeight(null);
  }

  void _handleAnswerSelected(int questionIndex, AnswerOption option) async {
    // Notifier에 답변 제출
    await ref.read(dailyCheckinProvider.notifier).submitAnswer(
          questionIndex,
          option.value,
        );
  }

  void _handleDerivedAnswer(String path, String answer) async {
    await ref
        .read(dailyCheckinProvider.notifier)
        .submitDerivedAnswer(path, answer);
  }

  void _handleGoBack() {
    ref.read(dailyCheckinProvider.notifier).goBack();
  }

  String _getGreeting(String? greetingType) {
    if (greetingType == null) {
      final hour = DateTime.now().hour;
      if (hour >= 5 && hour < 11) {
        return GreetingStrings.morning;
      } else if (hour >= 11 && hour < 17) {
        return GreetingStrings.afternoon;
      } else if (hour >= 17 && hour < 21) {
        return GreetingStrings.evening;
      } else {
        return GreetingStrings.night;
      }
    }

    switch (greetingType) {
      case 'morning':
        return GreetingStrings.morning;
      case 'afternoon':
        return GreetingStrings.afternoon;
      case 'evening':
        return GreetingStrings.evening;
      case 'night':
        return GreetingStrings.night;
      default:
        return GreetingStrings.morning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkinState = ref.watch(dailyCheckinProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            checkinState.when(
              data: (state) {
                if (state.currentStep == 0 && state.currentDerivedPath == null) {
                  context.pop();
                } else {
                  _handleGoBack();
                }
              },
              loading: () => context.pop(),
              error: (_, _) => context.pop(),
            );
          },
        ),
        actions: [
          checkinState.when(
            data: (state) {
              if (state.currentStep >= 1 &&
                  state.currentStep <= 6 &&
                  state.currentDerivedPath == null &&
                  !state.isComplete) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: CheckinProgressIndicator(
                      currentStep: state.currentStep,
                      totalSteps: 6,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: checkinState.when(
        data: (state) => _buildContent(context, state),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DailyCheckinState state) {
    // 파생 질문이 활성화된 경우
    if (state.currentDerivedPath != null) {
      return _buildDerivedQuestionPage(state.currentDerivedPath!);
    }

    // 완료 화면
    if (state.isComplete) {
      return _buildCompletionPage(state);
    }

    // 체중 입력 (Step 0)
    if (state.currentStep == 0) {
      return _buildWeightInputPage(state);
    }

    // 메인 질문 (Step 1-6)
    if (state.currentStep >= 1 && state.currentStep <= 6) {
      final questionIndex = state.currentStep - 1;
      return _buildQuestionPage(questionIndex, state);
    }

    // 기본 인사 화면
    return _buildGreetingPage(state);
  }

  Widget _buildGreetingPage(DailyCheckinState state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '👋',
            style: TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 24),
          Text(
            _getGreeting(state.context?.greetingType),
            textAlign: TextAlign.center,
            style: AppTypography.heading1.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 48),
          FilledButton(
            onPressed: () => _skipWeight(),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(200, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              '시작하기',
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightInputPage(DailyCheckinState state) {
    return WeightInputSection(
      previousWeight: null, // TODO: 이전 체중 데이터 연결
      onWeightSubmit: _handleWeightSubmit,
      onSkip: _skipWeight,
    );
  }

  Widget _buildQuestionPage(int questionIndex, DailyCheckinState state) {
    final question = Questions.all[questionIndex];
    final selectedAnswer = state.answers[questionIndex + 1];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          // 질문 카드
          QuestionCard(
            emoji: question.emoji,
            question: question.question,
          ),
          const SizedBox(height: 32),
          // 답변 버튼들
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: question.options.map((option) {
              final isSelected = selectedAnswer == option.value;
              final isPositive = option.value == 'good' || option.value == 'normal';

              return AnswerButton(
                emoji: option.emoji,
                text: option.text,
                isSelected: isSelected,
                isPositive: isPositive,
                onTap: () => _handleAnswerSelected(questionIndex + 1, option),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          // 피드백 카드 (선택된 답변에 피드백이 있으면 표시)
          if (selectedAnswer != null)
            Builder(
              builder: (context) {
                final selectedOption = question.options.firstWhere(
                  (opt) => opt.value == selectedAnswer,
                  orElse: () => question.options.first,
                );
                if (selectedOption.feedback != null) {
                  return FeedbackCard(
                    message: selectedOption.feedback!,
                    tone: FeedbackTone.positive,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildDerivedQuestionPage(String path) {
    // 파생 질문을 바텀시트로 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDerivedQuestionSheet(
        context: context,
        path: path,
        onAnswerSelected: (answer) {
          _handleDerivedAnswer(path, answer);
        },
      );
    });

    // 이전 질문 화면 유지 (백그라운드)
    final currentQuestion = _getQuestionIndexFromPath(path);
    if (currentQuestion >= 1 && currentQuestion <= 6) {
      final state = ref.read(dailyCheckinProvider).value;
      if (state != null) {
        return _buildQuestionPage(currentQuestion - 1, state);
      }
    }

    return const Center(child: CircularProgressIndicator());
  }

  int _getQuestionIndexFromPath(String path) {
    final match = RegExp(r'Q(\d+)').firstMatch(path);
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    return 1;
  }

  Widget _buildCompletionPage(DailyCheckinState state) {
    final consecutiveDays = state.context?.consecutiveDays ?? 0;
    final savedCheckin = state.savedCheckin;

    // 피드백 생성
    String feedbackMessage = CompletionStrings.goodDay;
    if (savedCheckin != null) {
      final feedbackNotifier = ref.read(checkinFeedbackProvider.notifier);
      final feedback = feedbackNotifier.getCompletionFeedback(savedCheckin);
      feedbackMessage = feedback.message;

      // Red Flag 안내 표시
      if (savedCheckin.redFlagDetected != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final redFlagFeedback = feedbackNotifier.getRedFlagGuidance(
            savedCheckin.redFlagDetected!.type,
          );

          showRedFlagGuidanceDialog(
            context: context,
            redFlag: savedCheckin.redFlagDetected!,
            message: redFlagFeedback.message,
          );
        });
      }
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            CompletionStrings.emoji,
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 24),
          Text(
            CompletionStrings.title,
            textAlign: TextAlign.center,
            style: AppTypography.heading1.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 24),
          // 연속 일수 표시
          if (consecutiveDays > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$consecutiveDays일째 연속 기록 중!',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 24),
          // 피드백 메시지
          Text(
            feedbackMessage,
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.neutral700,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 48),
          FilledButton(
            onPressed: () {
              context.pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(200, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              CompletionStrings.doneButton,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
