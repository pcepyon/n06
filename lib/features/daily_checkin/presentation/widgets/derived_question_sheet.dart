import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/features/daily_checkin/presentation/constants/questions.dart';
import 'package:n06/features/daily_checkin/presentation/widgets/answer_button.dart';
import 'package:n06/features/daily_checkin/presentation/widgets/question_card.dart';

/// 파생 질문 바텀시트
///
/// 메인 질문에서 특정 답변 선택 시 추가로 표시되는 상세 질문입니다.
/// 예: Q1-1 (식사 힘든 이유), Q3-2 (복통 위치) 등
class DerivedQuestionSheet extends StatelessWidget {
  final String path;
  final Function(String answer) onAnswerSelected;

  const DerivedQuestionSheet({
    super.key,
    required this.path,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    final derivedQuestion = _getDerivedQuestion(path);

    if (derivedQuestion == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: const Text('질문을 찾을 수 없습니다'),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // 질문 카드
          QuestionCard(
            emoji: derivedQuestion.emoji,
            question: derivedQuestion.question,
          ),
          const SizedBox(height: 32),
          // 답변 버튼들
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: derivedQuestion.options.map((option) {
              return AnswerButton(
                emoji: option.emoji,
                text: option.text,
                isSelected: false,
                isPositive: false,
                onTap: () {
                  onAnswerSelected(option.value);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// 경로에 해당하는 파생 질문 반환
  DerivedQuestion? _getDerivedQuestion(String path) {
    switch (path) {
      case 'Q1-1':
        return DerivedQuestions.mealDifficulty;
      case 'Q3-1':
        return DerivedQuestions.giDiscomfortType;
      case 'Q4-1':
        return DerivedQuestions.bowelIssueType;
      case 'Q5-1':
        return DerivedQuestions.energySymptoms;
      default:
        return null;
    }
  }
}

/// 파생 질문 바텀시트 표시 헬퍼 함수
Future<void> showDerivedQuestionSheet({
  required BuildContext context,
  required String path,
  required Function(String answer) onAnswerSelected,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DerivedQuestionSheet(
      path: path,
      onAnswerSelected: onAnswerSelected,
    ),
  );
}
