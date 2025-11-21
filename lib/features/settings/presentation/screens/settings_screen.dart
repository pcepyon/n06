import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/core/theme/app_colors.dart';
import 'package:n06/core/theme/app_text_styles.dart';
import 'package:n06/core/widgets/app_button.dart';
import 'package:n06/core/widgets/app_card.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/authentication/presentation/widgets/logout_confirm_dialog.dart';
import 'package:n06/features/profile/application/notifiers/profile_notifier.dart';
import 'package:n06/features/settings/presentation/widgets/settings_menu_item.dart';

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

    return ListView(
      children: [
        // User information section
        // User information section
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '사용자 정보',
                  style: AppTextStyles.h3,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('이름', style: AppTextStyles.body2),
                  subtitle: Text(userName, style: AppTextStyles.body1),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  title: const Text('목표 체중', style: AppTextStyles.body2),
                  subtitle: Text('${profile.targetWeight.value}kg', style: AppTextStyles.body1),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Settings menu items
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '설정',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 16),
              // Business Rule 3: Clear labels and descriptions
              SettingsMenuItem(
                title: '프로필 및 목표 수정',
                subtitle: '이름과 목표 체중을 변경할 수 있습니다',
                onTap: () => context.push('/profile/edit'),
              ),
              SettingsMenuItem(
                title: '투여 계획 수정',
                subtitle: '약물 투여 계획을 변경할 수 있습니다',
                onTap: () => context.push('/dose-plan/edit'),
              ),
              SettingsMenuItem(
                title: '주간 기록 목표 조정',
                subtitle: '주간 체중 및 증상 기록 목표를 설정합니다',
                onTap: () => context.push('/weekly-goal/edit'),
              ),
              SettingsMenuItem(
                title: '푸시 알림 설정',
                subtitle: '알림 시간과 방식을 설정합니다',
                onTap: () => context.push('/notification/settings'),
              ),
              SettingsMenuItem(
                title: '기록 관리',
                subtitle: '저장된 기록을 확인하거나 삭제할 수 있습니다',
                onTap: () => context.push('/records'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Divider
        Divider(
          height: 1,
          color: Colors.grey[300],
        ),
        const SizedBox(height: 24),

        // Business Rule 4: Logout at bottom
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SettingsMenuItem(
            title: '로그아웃',
            subtitle: '앱에서 로그아웃합니다',
            onTap: () => _handleLogout(context, ref),
          ),
        ),
        const SizedBox(height: 32),
      ],
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
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text('프로필 정보를 불러올 수 없습니다', style: AppTextStyles.body1),
            const SizedBox(height: 16),
            AppButton(
              text: '다시 시도',
              onPressed: () {
                final authState = ref.read(authNotifierProvider);
                if (authState.hasValue && authState.value != null) {
                  ref
                      .read(profileNotifierProvider.notifier)
                      .loadProfile(authState.value!.id);
                }
              },
              type: AppButtonType.secondary,
              isFullWidth: false,
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
