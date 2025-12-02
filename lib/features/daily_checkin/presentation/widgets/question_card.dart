import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

/// 질문 카드 위젯
///
/// 질문 텍스트와 이모지를 표시합니다.
/// - 큰 이모지와 친근한 질문 텍스트
/// - 깔끔한 카드 레이아웃
class QuestionCard extends StatelessWidget {
  final String emoji;
  final String question;

  const QuestionCard({
    super.key,
    required this.emoji,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.neutral200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 이모지
          Text(
            emoji,
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          // 질문 텍스트
          Text(
            question,
            textAlign: TextAlign.center,
            style: AppTypography.heading2.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),
        ],
      ),
    );
  }
}
