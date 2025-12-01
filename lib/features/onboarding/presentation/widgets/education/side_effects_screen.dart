import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/features/onboarding/presentation/widgets/common/onboarding_page_template.dart';

class SideEffectsScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback? onSkip;

  const SideEffectsScreen({
    super.key,
    required this.onNext,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingPageTemplate(
      title: '처음엔 이런 느낌이 있을 수 있어요',
      subtitle: '걱정 마세요, 몸이 적응하는\n자연스러운 과정이에요',
      showSkip: true,
      onSkip: onSkip,
      onNext: onNext,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 증상 1: 속 불편함
          _buildSymptomCard(
            icon: '😮‍💨',
            title: '속이 불편해요',
            tips: [
              '작은 양으로 천천히 드세요',
              '기름진 음식은 잠시 피해요',
              '대부분 2주 내 나아져요',
            ],
            badge: '90%+',
            badgeColor: const Color(0xFF4ADE80), // Primary
          ),

          const SizedBox(height: 16),

          // 증상 2: 입맛 변화
          _buildSymptomCard(
            icon: '🍽️',
            title: '입맛이 변했어요',
            tips: [
              '좋은 신호예요!',
              '몸이 필요한 만큼만 먹으려는 거예요',
            ],
            badge: null,
            badgeColor: null,
          ),

          const SizedBox(height: 16),

          // 증상 3: 피로감
          _buildSymptomCard(
            icon: '😴',
            title: '좀 피곤해요',
            tips: [
              '수분을 충분히 드세요',
              '단백질 섭취를 늘려보세요',
              '몸이 적응하면 나아져요',
            ],
            badge: null,
            badgeColor: null,
          ),

          const SizedBox(height: 24),

          // 경고 카드
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB), // Warning Yellow-50
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0x4DD97706), // Yellow-600 with 30% opacity
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 20,
                      color: Color(0xFFD97706), // Warning Yellow-600
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '심한 증상은 앱에서\n바로 확인하고 대처할 수 있어요',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD97706), // Warning Yellow-600
                          height: 1.43,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 의료적 면책 조항
          const Text(
            '*이 정보는 일반적인 가이드이며, 담당 의사의 처방을 최우선으로 따라주세요.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF94A3B8), // Neutral-400
              height: 1.33,
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSymptomCard({
    required String icon,
    required String title,
    required List<String> tips,
    String? badge,
    Color? badgeColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.educationBackground, // Blue-50 for education
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.education.withValues(alpha: 0.2),
        ),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          leading: Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
              if (badge != null && badgeColor != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: badgeColor,
                    ),
                  ),
                ),
            ],
          ),
          trailing: Icon(
            Icons.expand_more,
            color: AppColors.education,
          ),
          onExpansionChanged: (isExpanded) {
            if (isExpanded) {
              HapticFeedback.lightImpact();
            }
          },
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: tips.map((tip) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '•',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.education,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tip,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
