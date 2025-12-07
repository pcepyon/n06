import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/features/dashboard/application/notifiers/dashboard_notifier.dart';
import 'package:n06/features/dashboard/application/notifiers/ai_message_notifier.dart';
import 'package:n06/features/dashboard/presentation/widgets/greeting_section.dart';
import 'package:n06/features/dashboard/presentation/widgets/status_summary_section.dart';
import 'package:n06/features/dashboard/presentation/widgets/ai_message_section.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardNotifierProvider);
    final aiMessageState = ref.watch(aIMessageProvider);

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

                // Section 1: 인사 (GreetingSection)
                GreetingSection(dashboardData: dashboardData),
                SizedBox(height: 24), // lg spacing between sections

                // Section 2: 상태 요약 (StatusSummarySection)
                StatusSummarySection(dashboardData: dashboardData),
                SizedBox(height: 24),

                // Section 3: AI 메시지 (AIMessageSection)
                // Phase 5: AI 메시지 상태를 watch하여 전달
                _buildAIMessageSection(aiMessageState),
                SizedBox(height: 24), // Bottom padding
              ],
            ),
          ),
        ),
      ),
      // Note: BottomNavigationBar is provided by ScaffoldWithBottomNav wrapper
    );
  }

  /// Builds AI message section based on notifier state.
  ///
  /// States:
  /// - loading: Shows skeleton with "메시지 준비 중..."
  /// - error: Shows last successful message (fallback from notifier) or default message
  /// - data: Shows generated message
  ///
  /// Error handling strategy (per spec.md):
  /// - AIMessageNotifier._generateNewMessage() catches errors and returns
  ///   _repository.getLatestMessage() as fallback
  /// - If that also fails (no previous messages), returns null
  /// - Screen displays null as default message: "오늘도 함께해요."
  Widget _buildAIMessageSection(AsyncValue<dynamic> aiMessageState) {
    return aiMessageState.when(
      loading: () => const AIMessageSection(isLoading: true),
      error: (error, stackTrace) {
        // On error, show default fallback message
        // Note: The notifier already tried to return last successful message,
        // but if that also failed, we show default message here
        return const AIMessageSection(
          isLoading: false,
          message: null, // Will use default message: "오늘도 함께해요."
        );
      },
      data: (aiMessage) {
        // Show generated message if available, otherwise default message
        final messageText = aiMessage?.message;
        return AIMessageSection(
          isLoading: false,
          message: messageText,
        );
      },
    );
  }
}
