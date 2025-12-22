import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/dashboard/application/notifiers/dashboard_notifier.dart';
import 'package:n06/features/dashboard/application/notifiers/ai_message_notifier.dart';
import 'package:n06/features/dashboard/domain/entities/dashboard_message_type.dart';
import 'package:n06/features/dashboard/presentation/widgets/ai_message_section.dart';
import 'package:n06/features/dashboard/presentation/widgets/emotional_greeting_widget.dart';
import 'package:n06/features/dashboard/presentation/widgets/hopeful_schedule_widget.dart';
import 'package:n06/features/dashboard/presentation/widgets/celebratory_report_widget.dart';
import 'package:n06/features/dashboard/presentation/widgets/journey_timeline_widget.dart';
import 'package:n06/features/dashboard/presentation/widgets/celebratory_badge_widget.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardNotifierProvider);
    final aiMessageState = ref.watch(aIMessageProvider);

    final aiMsgPreview = aiMessageState.value?.message;
    final aiMsgShort = aiMsgPreview != null
        ? (aiMsgPreview.length > 20 ? '${aiMsgPreview.substring(0, 20)}...' : aiMsgPreview)
        : 'null';
    developer.log(
      '📱 HomeDashboard build: dashboard=${dashboardState.isLoading ? "loading" : dashboardState.hasError ? "error" : "data"}, '
      'aiMessage=${aiMessageState.isLoading ? "loading" : aiMessageState.hasError ? "error" : "data($aiMsgShort)"}',
      name: 'Dashboard',
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 56,
        title: Text(
          context.l10n.dashboard_screen_title,
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
        loading: () => Semantics(
          liveRegion: true,
          label: context.l10n.dashboard_screen_title,
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 4.0,
            ),
          ),
        ),
        error: (error, stackTrace) {
          // BUG-20251222: 프로필이 없는 인증된 사용자를 온보딩으로 리디렉션
          // 회원가입 후 온보딩을 완료하지 않고 앱을 재시작한 경우 발생
          final errorString = error.toString();
          if (errorString.contains(DashboardMessageType.errorProfileNotFound.name)) {
            developer.log(
              '🔄 Profile not found, redirecting to onboarding...',
              name: 'Dashboard',
            );
            // 빌드 중 네비게이션 방지를 위해 addPostFrameCallback 사용
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                final userId = ref.read(authNotifierProvider).value?.id;
                context.go('/onboarding', extra: userId);
              }
            });
            // 리디렉션 중 로딩 표시
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 4.0,
              ),
            );
          }

          // 기존 에러 UI (다른 에러의 경우)
          return Semantics(
            liveRegion: true,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ExcludeSemantics(
                      child: Icon(
                        Icons.error_outline,
                        size: 60,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.dashboard_error_loadFailed,
                      style: AppTypography.heading3,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.dashboard_error_retryMessage,
                      style: AppTypography.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(dashboardNotifierProvider);
                      },
                      child: Text(context.l10n.dashboard_error_retryButton),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
                SizedBox(height: 24),

                // 1. EmotionalGreetingWidget - 감정적 인사
                EmotionalGreetingWidget(dashboardData: dashboardData),
                SizedBox(height: 24),

                // 2. CelebratoryReportWidget - 주간 요약 (축하 관점)
                CelebratoryReportWidget(summary: dashboardData.weeklySummary),
                SizedBox(height: 24),

                // 3. HopefulScheduleWidget - 일정 (희망적 프레이밍)
                HopefulScheduleWidget(schedule: dashboardData.nextSchedule),
                SizedBox(height: 24),

                // 4. JourneyTimelineWidget - 여정 타임라인
                JourneyTimelineWidget(events: dashboardData.timeline),
                SizedBox(height: 24),

                // 5. AIMessageSection - AI 메시지
                _buildAIMessageSection(aiMessageState),
                SizedBox(height: 24),

                // 6. CelebratoryBadgeWidget - 뱃지 그리드
                CelebratoryBadgeWidget(badges: dashboardData.badges),
                SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds AI message section based on notifier state.
  Widget _buildAIMessageSection(AsyncValue<dynamic> aiMessageState) {
    return aiMessageState.when(
      loading: () => const AIMessageSection(isLoading: true),
      error: (error, stackTrace) {
        return const AIMessageSection(
          isLoading: false,
          message: null,
        );
      },
      data: (aiMessage) {
        final messageText = aiMessage?.message;
        return AIMessageSection(
          isLoading: false,
          message: messageText,
        );
      },
    );
  }
}
