import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/onboarding/presentation/widgets/common/onboarding_page_template.dart';

class JourneyRoadmapScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback? onSkip;

  const JourneyRoadmapScreen({
    super.key,
    required this.onNext,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingPageTemplate(
      title: '앞으로의 여정이에요',
      subtitle: '조급해하지 않아도 괜찮아요\n몸이 천천히 변화할 거예요',
      showSkip: true,
      onSkip: onSkip,
      onNext: onNext,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Phase 1
          _buildTimelineItem(
            icon: '🌱',
            phase: '1-4주: 적응기',
            description: '몸이 약과 친해지는 시간\n큰 변화 없어도 정상이에요',
            color: AppColors.history.withValues(alpha: 0.7), // Purple lighter
            isLast: false,
          ),

          const SizedBox(height: 24),

          // Timeline Phase 2
          _buildTimelineItem(
            icon: '🌿',
            phase: '5-12주: 변화기',
            description: '본격적인 효과가 나타나요\n체중 감소가 눈에 보여요',
            color: AppColors.history, // Purple
            isLast: false,
          ),

          const SizedBox(height: 24),

          // Timeline Phase 3
          _buildTimelineItem(
            icon: '🌳',
            phase: '13주+: 성장기',
            description: '새로운 습관이 자리잡아요\n건강한 일상이 되어가요',
            color: const Color(0xFF6B21A8), // Purple-800 (darker)
            isLast: true,
          ),

          const SizedBox(height: 32),

          // 팁 카드
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.historyBackground, // Purple-50
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.history.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💡',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.history,
                            height: 1.43,
                          ),
                          children: const [
                            TextSpan(
                              text: '평균 4-5주 후부터\n',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: '확실한 변화를 느껴요',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(
                  color: AppColors.history.withValues(alpha: 0.5),
                  height: 1,
                  thickness: 0.5,
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💡',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.history,
                            height: 1.43,
                          ),
                          children: const [
                            TextSpan(
                              text: '체중이 잠시 멈추는 건\n',
                            ),
                            TextSpan(
                              text: '몸이 적응하는 건강한 신호예요',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String icon,
    required String phase,
    required String description,
    required Color color,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: color,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color,
                      color.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(width: 16),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                phase,
                style: AppTypography.heading2.copyWith(
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
