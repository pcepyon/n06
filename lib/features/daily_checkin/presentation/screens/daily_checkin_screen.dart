import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/daily_checkin/application/notifiers/daily_checkin_notifier.dart';
import 'package:n06/features/daily_checkin/application/notifiers/checkin_feedback_notifier.dart';
import 'package:n06/features/daily_checkin/domain/entities/checkin_feedback.dart';
import 'package:n06/features/daily_checkin/presentation/constants/questions.dart';
import 'package:n06/features/daily_checkin/presentation/widgets/answer_button.dart';
import 'package:n06/features/daily_checkin/presentation/widgets/feedback_card.dart';
import 'package:n06/features/daily_checkin/presentation/widgets/progress_indicator.dart';
import 'package:n06/features/daily_checkin/presentation/widgets/question_card.dart';
import 'package:n06/features/daily_checkin/presentation/widgets/weight_input_section.dart';
import 'package:n06/features/daily_checkin/presentation/widgets/derived_question_sheet.dart';
import 'package:n06/features/daily_checkin/presentation/widgets/red_flag_guidance_dialog.dart';
import 'package:n06/features/daily_checkin/presentation/utils/red_flag_localizations.dart';
import 'package:n06/features/daily_checkin/presentation/utils/feedback_l10n_mapper.dart';
import 'package:n06/l10n/generated/app_localizations.dart';

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
  bool _isInitialized = false;
  bool _isDerivedSheetOpen = false;
  Timer? _feedbackTimer; // 피드백 타이머 (BUG-20251202-TIMER)
  String? _lastPendingFeedback;
  bool _isRedFlagDialogShown = false; // Red Flag 다이얼로그 중복 표시 방지
  bool _isDuplicateDialogShown = false; // 중복 체크인 다이얼로그 중복 표시 방지

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
    _feedbackTimer?.cancel(); // 타이머 정리 (BUG-20251202-TIMER)
    super.dispose();
  }

  void _handleWeightSubmit(double weight) {
    ref.read(dailyCheckinProvider.notifier).submitWeight(weight);
  }

  void _skipWeight() {
    ref.read(dailyCheckinProvider.notifier).submitWeight(null);
  }

  Future<void> _handleAnswerSelected(int questionIndex, AnswerOption option) async {
    // Notifier에 답변 제출 (피드백 포함, BUG-20251202-175417)
    await ref.read(dailyCheckinProvider.notifier).submitAnswer(
          questionIndex,
          option.value,
          feedback: option.getFeedback != null ? option.getFeedback!(context.l10n) : null,
        );
  }

  Future<void> _handleDerivedAnswer(String path, String answer) async {
    await ref
        .read(dailyCheckinProvider.notifier)
        .submitDerivedAnswer(path, answer);
  }

  void _handleGoBack() {
    // 바텀시트가 열려있으면 먼저 닫기 (BUG-20251202-175417)
    if (_isDerivedSheetOpen) {
      Navigator.of(context).pop();
      _isDerivedSheetOpen = false;
    }
    ref.read(dailyCheckinProvider.notifier).goBack();
  }

  String _getGreeting(BuildContext context, String? greetingType) {
    final l10n = L10n.of(context)!;

    if (greetingType == null) {
      final hour = DateTime.now().hour;
      if (hour >= 5 && hour < 11) {
        return l10n.checkin_greeting_morning;
      } else if (hour >= 11 && hour < 17) {
        return l10n.checkin_greeting_afternoon;
      } else if (hour >= 17 && hour < 21) {
        return l10n.checkin_greeting_evening;
      } else {
        return l10n.checkin_greeting_night;
      }
    }

    switch (greetingType) {
      case 'morning':
        return l10n.checkin_greeting_morning;
      case 'afternoon':
        return l10n.checkin_greeting_afternoon;
      case 'evening':
        return l10n.checkin_greeting_evening;
      case 'night':
        return l10n.checkin_greeting_night;
      default:
        return l10n.checkin_greeting_morning;
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
                  child: SizedBox(
                    width: 120,
                    child: Center(
                      child: CheckinProgressIndicator(
                        currentStep: state.currentStep,
                        totalSteps: 6,
                      ),
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
    // 중복 체크인 확인 다이얼로그
    if (state.hasExistingCheckinToday &&
        !state.duplicateCheckConfirmed &&
        !_isDuplicateDialogShown) {
      _isDuplicateDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showDuplicateCheckinDialog();
      });
    }

    // 파생 질문이 활성화된 경우
    if (state.currentDerivedPath != null) {
      return _buildDerivedQuestionPage(context, state.currentDerivedPath!);
    }

    // 완료 화면
    if (state.isComplete) {
      return _buildCompletionPage(context, state);
    }

    // 체중 입력 (Step 0)
    if (state.currentStep == 0) {
      return _buildWeightInputPage(state);
    }

    // 메인 질문 (Step 1-6)
    if (state.currentStep >= 1 && state.currentStep <= 6) {
      final questionIndex = state.currentStep - 1;
      return _buildQuestionPage(context, questionIndex, state);
    }

    // 기본 인사 화면
    return _buildGreetingPage(context, state);
  }

  void _showDuplicateCheckinDialog() {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '📝',
                style: TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.checkin_dialog_alreadyRecorded_title,
                style: AppTypography.heading2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.checkin_dialog_alreadyRecorded_message,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false);
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        context.l10n.checkin_dialog_alreadyRecorded_exitButton,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(true);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        context.l10n.checkin_dialog_alreadyRecorded_editButton,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).then((confirmed) {
      if (!mounted) return;
      if (confirmed == true) {
        ref.read(dailyCheckinProvider.notifier).confirmDuplicateCheckin();
      } else {
        // ShellRoute 내부이므로 pop() 대신 go() 사용 (GoError 방지)
        context.go('/home');
      }
    });
  }

  Widget _buildGreetingPage(BuildContext context, DailyCheckinState state) {
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
            _getGreeting(context, state.context?.greetingType),
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
              context.l10n.checkin_greeting_startButton,
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

  Widget _buildQuestionPage(BuildContext context, int questionIndex, DailyCheckinState state) {
    final l10n = L10n.of(context)!;
    final question = Questions.all[questionIndex];
    final selectedAnswer = state.answers[questionIndex + 1];

    // 피드백이 표시 대기 중이면 자동 전환 (BUG-20251202-175417, BUG-20251202-TIMER)
    // 매 빌드마다 타이머가 생성되지 않도록 플래그로 제어
    if (state.pendingFeedback != null &&
        _feedbackTimer == null &&
        _lastPendingFeedback != state.pendingFeedback) {
      _lastPendingFeedback = state.pendingFeedback;
      _feedbackTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          _feedbackTimer = null;
          ref.read(dailyCheckinProvider.notifier).dismissFeedbackAndProceed();
        }
      });
    } else if (state.pendingFeedback == null) {
      _feedbackTimer?.cancel();
      _feedbackTimer = null;
      _lastPendingFeedback = null;
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          // 질문 카드
          QuestionCard(
            emoji: question.getEmoji(l10n),
            question: question.getQuestion(l10n),
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
                emoji: option.getEmoji(l10n),
                text: option.getText(l10n),
                isSelected: isSelected,
                isPositive: isPositive,
                onTap: () async => await _handleAnswerSelected(questionIndex + 1, option),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          // 피드백 카드 (pendingFeedback 우선, BUG-20251202-175417)
          if (state.pendingFeedback != null)
            FeedbackCard.direct(
              message: state.pendingFeedback!,
              tone: FeedbackTone.positive,
            )
          else if (selectedAnswer != null)
            Builder(
              builder: (context) {
                final selectedOption = question.options.firstWhere(
                  (opt) => opt.value == selectedAnswer,
                  orElse: () => question.options.first,
                );
                final feedback = selectedOption.getFeedback;
                if (feedback != null) {
                  return FeedbackCard.direct(
                    message: feedback(l10n),
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

  Widget _buildDerivedQuestionPage(BuildContext context, String path) {
    // 파생 질문을 바텀시트로 표시 (중복 열기 방지, BUG-20251202-175417)
    if (!_isDerivedSheetOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        _isDerivedSheetOpen = true;
        final openedPath = path; // 바텀시트 열 때의 경로 저장

        // 바텀시트가 완전히 닫힌 후 답변을 반환받음 (BUG-20251202-224803)
        final selectedAnswer = await showDerivedQuestionSheet(
          context: context,
          path: path,
          onAnswerSelected: (answer) {
            Navigator.of(context).pop(answer);
          },
        );

        // 바텀시트가 닫힌 후
        if (mounted) {
          _isDerivedSheetOpen = false;

          if (selectedAnswer != null) {
            // 답변이 선택된 경우: 바텀시트가 완전히 닫힌 후에만 상태 업데이트
            await _handleDerivedAnswer(openedPath, selectedAnswer);
          } else {
            // 답변 없이 닫힌 경우 (스와이프 다운 등): 동기화
            final currentPath = ref.read(dailyCheckinProvider).value?.currentDerivedPath;
            if (currentPath == openedPath) {
              ref.read(dailyCheckinProvider.notifier).goBack();
            }
          }
        }
      });
    }

    // 이전 질문 화면 유지 (백그라운드)
    final currentQuestion = _getQuestionIndexFromPath(path);
    if (currentQuestion >= 1 && currentQuestion <= 6) {
      final state = ref.read(dailyCheckinProvider).value;
      if (state != null) {
        return _buildQuestionPage(context, currentQuestion - 1, state);
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

  Widget _buildCompletionPage(BuildContext context, DailyCheckinState state) {
    final l10n = L10n.of(context)!;
    final consecutiveDays = state.context?.consecutiveDays ?? 0;
    final savedCheckin = state.savedCheckin;

    // 피드백 생성
    String feedbackMessage = l10n.checkin_completion_goodDay;
    if (savedCheckin != null) {
      final feedbackNotifier = ref.read(checkinFeedbackProvider.notifier);
      final feedback = feedbackNotifier.getCompletionFeedback(savedCheckin);
      feedbackMessage = FeedbackL10nMapper.getFeedbackMessage(context, feedback);

      // Red Flag 안내 표시 (중복 방지, BUG-20251202-REDFLAG)
      if (savedCheckin.redFlagDetected != null && !_isRedFlagDialogShown) {
        _isRedFlagDialogShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          // Presentation Layer에서 l10n으로 메시지 해결
          final message = savedCheckin.redFlagDetected!.type.getMessage(context);

          showRedFlagGuidanceDialog(
            context: context,
            redFlag: savedCheckin.redFlagDetected!,
            message: message,
          );
        });
      }
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.checkin_completion_emoji,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.checkin_completion_title,
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
                  l10n.checkin_completion_daysMessage(consecutiveDays),
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
                // ShellRoute 내부이므로 pop() 대신 go() 사용 (GoError 방지)
                context.go('/home');
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(200, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.checkin_completion_doneButton,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
