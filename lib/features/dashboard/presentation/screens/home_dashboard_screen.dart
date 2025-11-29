import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/dashboard/application/notifiers/dashboard_notifier.dart';
import 'package:n06/features/dashboard/presentation/widgets/greeting_widget.dart';
import 'package:n06/features/dashboard/presentation/widgets/weekly_progress_widget.dart';
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
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 56,
        title: Text(
          '홈',
          style: AppTypography.heading2,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 24),
            color: AppColors.neutral700,
            onPressed: () {},
            constraints: const BoxConstraints.tightFor(width: 44, height: 44),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.border,
            height: 1,
          ),
        ),
      ),
      body: dashboardState.when(
        loading: () => Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 4.0,
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 60,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  '데이터를 불러올 수 없습니다',
                  style: AppTypography.heading3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '네트워크 연결을 확인하고 다시 시도해주세요.',
                  style: AppTypography.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(dashboardNotifierProvider);
                  },
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        ),
        data: (dashboardData) => RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          strokeWidth: 3.0,
          displacement: 40.0,
          onRefresh: () async {
            await ref.read(dashboardNotifierProvider.notifier).refresh();
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24), // lg spacing from top

                // Greeting Widget
                GreetingWidget(dashboardData: dashboardData),
                SizedBox(height: 24), // lg spacing between sections

                // Weekly Progress Widget
                WeeklyProgressWidget(weeklyProgress: dashboardData.weeklyProgress),
                SizedBox(height: 24),

                // Next Schedule Widget
                NextScheduleWidget(schedule: dashboardData.nextSchedule),
                SizedBox(height: 24),

                // Weekly Report Widget (tappable)
                WeeklyReportWidget(summary: dashboardData.weeklySummary),
                SizedBox(height: 24),

                // Timeline Widget
                TimelineWidget(events: dashboardData.timeline),
                SizedBox(height: 24),

                // Badge Widget
                BadgeWidget(badges: dashboardData.badges),
                SizedBox(height: 24), // Bottom padding
              ],
            ),
          ),
        ),
      ),
      // Note: BottomNavigationBar is provided by ScaffoldWithBottomNav wrapper
    );
  }
}
