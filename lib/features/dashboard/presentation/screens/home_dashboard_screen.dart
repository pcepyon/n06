import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/dashboard/application/notifiers/dashboard_notifier.dart';
import 'package:n06/features/dashboard/presentation/widgets/greeting_widget.dart';
import 'package:n06/features/dashboard/presentation/widgets/weekly_progress_widget.dart';
import 'package:n06/features/dashboard/presentation/widgets/quick_action_widget.dart';
import 'package:n06/features/dashboard/presentation/widgets/next_schedule_widget.dart';
import 'package:n06/features/dashboard/presentation/widgets/weekly_report_widget.dart';
import 'package:n06/features/dashboard/presentation/widgets/timeline_widget.dart';
import 'package:n06/features/dashboard/presentation/widgets/badge_widget.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('홈 대시보드'),
        elevation: 0,
      ),
      body: dashboardState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text('데이터를 불러올 수 없습니다'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.refresh(dashboardNotifierProvider);
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (dashboardData) => RefreshIndicator(
          onRefresh: () async {
            await ref.read(dashboardNotifierProvider.notifier).refresh();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 개인화 인사
                  GreetingWidget(dashboardData: dashboardData),
                  const SizedBox(height: 24),

                  // 주간 목표 진행도
                  WeeklyProgressWidget(weeklyProgress: dashboardData.weeklyProgress),
                  const SizedBox(height: 24),

                  // 퀵 액션 버튼
                  QuickActionWidget(),
                  const SizedBox(height: 24),

                  // 다음 일정
                  NextScheduleWidget(nextSchedule: dashboardData.nextSchedule),
                  const SizedBox(height: 24),

                  // 주간 리포트
                  WeeklyReportWidget(weeklySummary: dashboardData.weeklySummary),
                  const SizedBox(height: 24),

                  // 치료 여정 타임라인
                  TimelineWidget(timeline: dashboardData.timeline),
                  const SizedBox(height: 24),

                  // 성취 뱃지
                  BadgeWidget(badges: dashboardData.badges),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
