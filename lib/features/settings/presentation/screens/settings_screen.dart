import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/authentication/presentation/widgets/logout_confirm_dialog.dart';
import 'package:n06/features/profile/application/notifiers/profile_notifier.dart';
import 'package:n06/features/settings/presentation/widgets/user_info_card.dart';
import 'package:n06/features/settings/presentation/widgets/settings_menu_item_improved.dart';
import 'package:n06/features/settings/presentation/widgets/danger_button.dart';

/// Settings screen for user to manage profile, dose plan, and notifications
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    // Business Rule 1: Check if user is authenticated
    return authState.when(
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('설정'),
          elevation: 0,
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shadowColor: AppColors.neutral900.withValues(alpha: 0.06),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) {
        debugPrint('SettingsScreen: Auth error: $error');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.go('/login');
          }
        });
        return const SizedBox.shrink();
      },
      data: (user) {
        if (user == null) {
          debugPrint('SettingsScreen: User is null');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go('/login');
            }
          });
          return const SizedBox.shrink();
        }

        final profileState = ref.watch(profileNotifierProvider);

        return Scaffold(
          appBar: AppBar(
            title: const Text('설정'),
            elevation: 0,
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            shadowColor: AppColors.neutral900.withValues(alpha: 0.06),
            titleTextStyle: AppTypography.heading1,
          ),
          body: profileState.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stackTrace) => _buildError(context, ref, error),
            data: (profile) {
              if (profile == null) {
                return _buildError(context, ref, Exception('Profile not found'));
              }
              return _buildSettings(context, ref, profile);
            },
          ),
        );
      },
    );
  }

  /// Build settings menu UI
  Widget _buildSettings(
    BuildContext context,
    WidgetRef ref,
    dynamic profile,
  ) {
    final userName = profile.userName ?? profile.userId.split('@').first;

    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0), // md
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User information section
            UserInfoCard(
              userName: userName,
              targetWeight: profile.targetWeight.value,
            ),
            const SizedBox(height: 24.0), // lg spacing

            // Settings menu section
            Text(
              '설정',
              style: AppTypography.heading2,
            ),
            const SizedBox(height: 16.0), // md spacing

            // Menu items
            SettingsMenuItemImproved(
              title: '프로필 및 목표 수정',
              subtitle: '이름과 목표 체중을 변경할 수 있습니다',
              onTap: () => context.push('/profile/edit'),
            ),
            SettingsMenuItemImproved(
              title: '투여 계획 수정',
              subtitle: '약물 투여 계획을 변경할 수 있습니다',
              onTap: () => context.push('/dose-plan/edit'),
            ),
            SettingsMenuItemImproved(
              title: '주간 기록 목표 조정',
              subtitle: '주간 체중 및 증상 기록 목표를 설정합니다',
              onTap: () => context.push('/weekly-goal/edit'),
            ),
            SettingsMenuItemImproved(
              title: '푸시 알림 설정',
              subtitle: '알림 시간과 방식을 설정합니다',
              onTap: () => context.push('/notification/settings'),
            ),
            SettingsMenuItemImproved(
              title: '기록 관리',
              subtitle: '저장된 기록을 확인하거나 삭제할 수 있습니다',
              onTap: () => context.push('/records'),
            ),
            SettingsMenuItemImproved(
              title: '의료진 데이터 공유',
              subtitle: '담당 의료진에게 기록 데이터를 공유합니다',
              onTap: () => context.push('/data-sharing'),
            ),
            SettingsMenuItemImproved(
              title: '온보딩 다시 보기',
              subtitle: 'GLP-1 약물 정보, 부작용 안내 등 교육 콘텐츠를 다시 볼 수 있습니다',
              onTap: () => context.push('/onboarding/review'),
            ),
            const SizedBox(height: 24.0), // lg spacing after menu items

            // Logout section
            DangerButton(
              text: '로그아웃',
              onPressed: () => _handleLogout(context, ref),
            ),
            const SizedBox(height: 16.0), // md spacing at bottom
          ],
        ),
      ),
    );
  }

  /// Build error UI with retry option
  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    // Edge Case 1: Check for session expired
    final isSessionExpired = error.toString().contains('Unauthorized') ||
        error.toString().contains('401') ||
        error.toString().contains('session');

    if (isSessionExpired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const SizedBox.shrink();
    }

    // Edge Case 2: Network error with retry option
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            const Text('프로필 정보를 불러올 수 없습니다'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final authState = ref.read(authNotifierProvider);
                if (authState.hasValue && authState.value != null) {
                  ref
                      .read(profileNotifierProvider.notifier)
                      .loadProfile(authState.value!.id);
                }
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle logout with confirmation dialog
  /// Business Rule 5: Confirmation step needed
  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    // Show logout confirmation dialog
    await showDialog<void>(
      context: context,
      builder: (context) => LogoutConfirmDialog(
        onConfirm: () {
          // Proceed with logout
          _performLogout(context, ref);
        },
      ),
    );
  }

  /// Perform the actual logout operation
  Future<void> _performLogout(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) return;

    // Show loading indicator during logout
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Call logout on the notifier
      await ref.read(authNotifierProvider.notifier).logout();

      if (context.mounted) {
        // Close loading dialog
        Navigator.pop(context);
        // Navigate to login screen
        context.go('/login');
      }
    } catch (e) {
      if (context.mounted) {
        // Close loading dialog
        Navigator.pop(context);
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그아웃 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
