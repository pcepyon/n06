import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';
import 'package:n06/features/onboarding/application/notifiers/onboarding_notifier.dart';
import 'package:n06/features/onboarding/presentation/widgets/summary_card.dart';
import 'package:n06/features/onboarding/presentation/widgets/validation_alert.dart';

/// 온보딩 정보 요약 및 최종 확인 화면
class SummaryScreen extends ConsumerWidget {
  final String userId;
  final String name;
  final double currentWeight;
  final double targetWeight;
  final int? targetPeriodWeeks;
  final String medicationName;
  final DateTime startDate;
  final int cycleDays;
  final double initialDose;
  final VoidCallback? onComplete;
  final bool isReviewMode;

  const SummaryScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.currentWeight,
    required this.targetWeight,
    required this.targetPeriodWeeks,
    required this.medicationName,
    required this.startDate,
    required this.cycleDays,
    required this.initialDose,
    this.onComplete,
    this.isReviewMode = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingNotifierProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0), // xl
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16), // md
            // Encouragement Message
            Text(
              isReviewMode ? '입력하신 정보입니다' : '준비가 잘 되었어요! ✨',
              style: TextStyle(
                fontSize: 16, // base
                fontWeight: FontWeight.w500,
                color: isReviewMode
                    ? const Color(0xFF64748B) // Neutral-500
                    : const Color(0xFF4ADE80), // Primary
              ),
            ),
            const SizedBox(height: 8), // sm
            Text(
              isReviewMode ? '정보 확인 (저장되지 않음)' : '정보 확인',
              style: const TextStyle(
                fontSize: 20, // xl
                fontWeight: FontWeight.w600, // Semibold
                color: Color(0xFF1E293B), // Neutral-800
              ),
            ),
            const SizedBox(height: 24), // lg

            // Basic Info Summary Card
            SummaryCard(
              title: '기본 정보',
              items: [
                ('이름', name),
                ('현재 체중', '$currentWeight kg'),
                ('목표 체중', '$targetWeight kg'),
                ('감량 목표', '${(currentWeight - targetWeight).toStringAsFixed(1)} kg'),
              ],
            ),
            const SizedBox(height: 24), // lg

            // Dosage Plan Summary Card
            SummaryCard(
              title: '투여 계획',
              items: [
                ('약물명', medicationName),
                (
                  '시작일',
                  '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
                ),
                ('주기', '$cycleDays일'),
                ('초기 용량', '$initialDose mg'),
              ],
            ),
            const SizedBox(height: 24), // lg

            // Loading/Error/Success States
            // 리뷰 모드: 저장 없이 다음 단계로 이동
            if (isReviewMode)
              GabiumButton(
                text: '다음',
                onPressed: () {
                  if (onComplete != null) {
                    onComplete!();
                  }
                },
                variant: GabiumButtonVariant.primary,
                size: GabiumButtonSize.medium,
              )
            else if (onboardingState.isLoading)
              const Center(
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    color: Color(0xFF4ADE80), // Primary
                    strokeWidth: 4,
                  ),
                ),
              )
            else if (onboardingState.hasError)
              Column(
                children: [
                  ValidationAlert(
                    type: ValidationAlertType.error,
                    message: '저장 실패: ${onboardingState.error}',
                  ),
                  const SizedBox(height: 16), // md
                  GabiumButton(
                    text: '재시도',
                    onPressed: () {
                      ref.read(onboardingNotifierProvider.notifier).retrySave(
                            userId: userId,
                            name: name,
                            currentWeight: currentWeight,
                            targetWeight: targetWeight,
                            targetPeriodWeeks: targetPeriodWeeks,
                            medicationName: medicationName,
                            startDate: startDate,
                            cycleDays: cycleDays,
                            initialDose: initialDose,
                          );
                    },
                    variant: GabiumButtonVariant.primary,
                    size: GabiumButtonSize.medium,
                  ),
                ],
              )
            else
              GabiumButton(
                text: '확인',
                onPressed: () async {
                  await ref.read(onboardingNotifierProvider.notifier).saveOnboardingData(
                        userId: userId,
                        name: name,
                        currentWeight: currentWeight,
                        targetWeight: targetWeight,
                        targetPeriodWeeks: targetPeriodWeeks,
                        medicationName: medicationName,
                        startDate: startDate,
                        cycleDays: cycleDays,
                        initialDose: initialDose,
                      );

                  if (context.mounted) {
                    if (onComplete != null) {
                      onComplete!();
                    } else {
                      context.go('/home');
                    }
                  }
                },
                variant: GabiumButtonVariant.primary,
                size: GabiumButtonSize.medium,
              ),
          ],
        ),
      ),
    );
  }
}
