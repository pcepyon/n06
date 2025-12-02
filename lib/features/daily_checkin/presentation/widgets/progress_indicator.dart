import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/daily_checkin/presentation/constants/checkin_strings.dart';

/// 체크인 진행률 표시 위젯
///
/// 6개 질문의 진행 상태를 표시합니다.
/// - 현재 위치 강조
/// - 완료된 단계 표시
class CheckinProgressIndicator extends StatelessWidget {
  final int currentStep; // 1-6
  final int totalSteps; // 6

  const CheckinProgressIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 진행 바
        Row(
          children: List.generate(
            totalSteps,
            (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index < totalSteps - 1 ? 4 : 0,
                ),
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: index < currentStep
                        ? AppColors.primary
                        : AppColors.neutral200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // 텍스트 표시
        Text(
          ProgressStrings.currentStep(currentStep, totalSteps),
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.neutral600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
