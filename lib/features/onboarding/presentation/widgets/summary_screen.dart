import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';
import 'package:n06/features/onboarding/application/notifiers/onboarding_notifier.dart';

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
  final List<EscalationStep>? escalationPlan;
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
    required this.escalationPlan,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingNotifierProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('정보 확인', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            _SummarySection(
              title: '기본 정보',
              items: [
                ('이름', name),
                ('현재 체중', '$currentWeight kg'),
                ('목표 체중', '$targetWeight kg'),
                ('감량 목표', '${(currentWeight - targetWeight).toStringAsFixed(1)} kg'),
              ],
            ),
            const SizedBox(height: 24),
            _SummarySection(
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
            if (escalationPlan != null && escalationPlan!.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text('증량 계획', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: escalationPlan!.length,
                itemBuilder: (context, index) {
                  final step = escalationPlan![index];
                  return ListTile(title: Text('${step.weeksFromStart}주차: ${step.doseMg} mg'));
                },
              ),
            ],
            const SizedBox(height: 32),
            if (onboardingState.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (onboardingState.hasError)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '저장 실패: ${onboardingState.error}',
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ref
                            .read(onboardingNotifierProvider.notifier)
                            .retrySave(
                              userId: userId,
                              name: name,
                              currentWeight: currentWeight,
                              targetWeight: targetWeight,
                              targetPeriodWeeks: targetPeriodWeeks,
                              medicationName: medicationName,
                              startDate: startDate,
                              cycleDays: cycleDays,
                              initialDose: initialDose,
                              escalationPlan: escalationPlan,
                            );
                      },
                      child: const Text('재시도'),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await ref
                        .read(onboardingNotifierProvider.notifier)
                        .saveOnboardingData(
                          userId: userId,
                          name: name,
                          currentWeight: currentWeight,
                          targetWeight: targetWeight,
                          targetPeriodWeeks: targetPeriodWeeks,
                          medicationName: medicationName,
                          startDate: startDate,
                          cycleDays: cycleDays,
                          initialDose: initialDose,
                          escalationPlan: escalationPlan,
                        );

                    if (context.mounted) {
                      if (onComplete != null) {
                        onComplete!();
                      } else {
                        context.go('/home');
                      }
                    }
                  },
                  child: const Text('확인'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 요약 섹션 위젯
class _SummarySection extends StatelessWidget {
  final String title;
  final List<(String, String)> items;

  const _SummarySection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final (label, value) = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
                    Text(value),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
