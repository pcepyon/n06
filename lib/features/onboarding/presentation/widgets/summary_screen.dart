import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
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
              context.l10n.onboarding_summary_titleReady,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8), // sm
            Text(
              context.l10n.onboarding_summary_sectionTitle,
              style: AppTypography.heading2,
            ),
            const SizedBox(height: 24), // lg

            // Basic Info Summary Card
            SummaryCard(
              title: context.l10n.onboarding_summary_basicInfoTitle,
              items: [
                (context.l10n.onboarding_summary_basicInfo_name, name),
                (context.l10n.onboarding_summary_basicInfo_currentWeight, '$currentWeight kg'),
                (context.l10n.onboarding_summary_basicInfo_targetWeight, '$targetWeight kg'),
                (context.l10n.onboarding_summary_basicInfo_weightGoal, '${(currentWeight - targetWeight).toStringAsFixed(1)} kg'),
              ],
            ),
            const SizedBox(height: 24), // lg

            // Dosage Plan Summary Card
            SummaryCard(
              title: context.l10n.onboarding_summary_dosagePlanTitle,
              items: [
                (context.l10n.onboarding_summary_dosagePlan_medication, medicationName),
                (
                  context.l10n.onboarding_summary_dosagePlan_startDate,
                  '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
                ),
                (context.l10n.onboarding_summary_dosagePlan_cycle, '$cycleDays일'),
                (context.l10n.onboarding_summary_dosagePlan_initialDose, '$initialDose mg'),
              ],
            ),
            const SizedBox(height: 24), // lg

            // Loading/Error/Success States
            if (onboardingState.isLoading)
              const Center(
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 4,
                  ),
                ),
              )
            else if (onboardingState.hasError)
              Column(
                children: [
                  ValidationAlert(
                    type: ValidationAlertType.error,
                    message: context.l10n.onboarding_summary_errorSaving(onboardingState.error.toString()),
                  ),
                  const SizedBox(height: 16), // md
                  GabiumButton(
                    text: context.l10n.onboarding_summary_retryButton,
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
                text: context.l10n.onboarding_summary_confirmButton,
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
