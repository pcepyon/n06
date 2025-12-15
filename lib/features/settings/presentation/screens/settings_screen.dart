import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:n06/core/constants/legal_urls.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/authentication/presentation/widgets/logout_confirm_dialog.dart';
import 'package:n06/features/authentication/presentation/widgets/delete_account_confirm_dialog.dart';
import 'package:n06/features/profile/application/notifiers/profile_notifier.dart';
import 'package:n06/features/settings/presentation/widgets/user_info_card.dart';
import 'package:n06/features/settings/presentation/widgets/settings_menu_item_improved.dart';
import 'package:n06/features/settings/presentation/widgets/danger_button.dart';
import 'package:n06/features/settings/presentation/widgets/language_selector_dialog.dart';
import 'package:n06/core/extensions/l10n_extension.dart';

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
          title: Text(context.l10n.settings_screen_title),
          elevation: 0,
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shadowColor: AppColors.neutral900.withValues(alpha: 0.06),
        ),
        body: Builder(
          builder: (context) => Semantics(
            liveRegion: true,
            label: context.l10n.a11y_loading,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
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
            title: Text(context.l10n.settings_screen_title),
            elevation: 0,
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            shadowColor: AppColors.neutral900.withValues(alpha: 0.06),
            titleTextStyle: AppTypography.heading1,
          ),
          body: profileState.when(
            loading: () => Builder(
              builder: (context) => Semantics(
                liveRegion: true,
                label: context.l10n.a11y_profileLoading,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (error, stackTrace) => Semantics(
              liveRegion: true,
              child: _buildError(context, ref, error),
            ),
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
              context.l10n.settings_screen_title,
              style: AppTypography.heading2,
            ),
            const SizedBox(height: 16.0), // md spacing

            // Menu items
            SettingsMenuItemImproved(
              title: context.l10n.settings_menu_profileEdit,
              subtitle: context.l10n.settings_menu_profileEditSubtitle,
              onTap: () => context.push('/profile/edit'),
            ),
            SettingsMenuItemImproved(
              title: context.l10n.settings_menu_dosePlanEdit,
              subtitle: context.l10n.settings_menu_dosePlanEditSubtitle,
              onTap: () => context.push('/dose-plan/edit'),
            ),
            SettingsMenuItemImproved(
              title: context.l10n.settings_menu_weeklyGoal,
              subtitle: context.l10n.settings_menu_weeklyGoalSubtitle,
              onTap: () => context.push('/weekly-goal/edit'),
            ),
            SettingsMenuItemImproved(
              title: context.l10n.settings_menu_notifications,
              subtitle: context.l10n.settings_menu_notificationsSubtitle,
              onTap: () => context.push('/notification/settings'),
            ),
            SettingsMenuItemImproved(
              title: context.l10n.settings_language_title,
              subtitle: context.l10n.settings_language_subtitle,
              onTap: () => _showLanguageSelector(context),
            ),
            SettingsMenuItemImproved(
              title: context.l10n.settings_menu_recordManagement,
              subtitle: context.l10n.settings_menu_recordManagementSubtitle,
              onTap: () => context.push('/records'),
            ),
            SettingsMenuItemImproved(
              title: context.l10n.settings_menu_dataSharing,
              subtitle: context.l10n.settings_menu_dataSharingSubtitle,
              onTap: () => context.push('/share-report'),
            ),
            SettingsMenuItemImproved(
              title: context.l10n.settings_menu_copingGuide,
              subtitle: context.l10n.settings_menu_copingGuideSubtitle,
              onTap: () => context.push('/coping-guide'),
            ),
            SettingsMenuItemImproved(
              title: '앱 소개 다시 보기',
              subtitle: '과학적 근거, 치료 여정, 부작용 가이드 등 앱 소개 콘텐츠',
              onTap: () => context.push('/guest?preview=true'),
            ),
            const SizedBox(height: 24.0), // lg spacing

            // Legal section
            Text(
              context.l10n.common_legal_sectionTitle,
              style: AppTypography.heading2,
            ),
            const SizedBox(height: 16.0), // md spacing

            SettingsMenuItemImproved(
              title: context.l10n.common_legal_termsOfService,
              subtitle: context.l10n.common_legal_termsOfServiceSubtitle,
              onTap: () => _openUrl(LegalUrls.termsOfService),
            ),
            SettingsMenuItemImproved(
              title: context.l10n.common_legal_privacyPolicy,
              subtitle: context.l10n.common_legal_privacyPolicySubtitle,
              onTap: () => _openUrl(LegalUrls.privacyPolicy),
            ),
            SettingsMenuItemImproved(
              title: context.l10n.common_legal_medicalDisclaimer,
              subtitle: context.l10n.common_legal_medicalDisclaimerSubtitle,
              onTap: () => _openUrl(LegalUrls.medicalDisclaimer),
            ),
            SettingsMenuItemImproved(
              title: context.l10n.common_legal_sensitiveInfoConsent,
              subtitle: context.l10n.common_legal_sensitiveInfoConsentSubtitle,
              onTap: () => _openUrl(LegalUrls.sensitiveInfoConsent),
            ),
            const SizedBox(height: 24.0), // lg spacing after menu items

            // Logout section
            DangerButton(
              text: context.l10n.common_button_logout,
              onPressed: () => _handleLogout(context, ref),
            ),
            const SizedBox(height: 12.0),

            // Account deletion section
            DangerButton(
              text: context.l10n.common_dialog_deleteAccountTitle,
              onPressed: () => _handleDeleteAccount(context, ref),
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
            Text(context.l10n.common_error_profileLoadFailed),
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
              child: Text(context.l10n.common_button_retry),
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
            content: Text(context.l10n.common_error_logoutFailed(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handle account deletion with confirmation dialog
  Future<void> _handleDeleteAccount(BuildContext context, WidgetRef ref) async {
    // Show delete account confirmation dialog
    await showDialog<void>(
      context: context,
      builder: (context) => DeleteAccountConfirmDialog(
        onConfirm: () {
          // Proceed with account deletion
          _performDeleteAccount(context, ref);
        },
      ),
    );
  }

  /// Perform the actual account deletion operation
  Future<void> _performDeleteAccount(
      BuildContext context, WidgetRef ref) async {
    if (!context.mounted) return;

    // Show loading indicator during deletion
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(context.l10n.common_loading_deletingAccount),
            ],
          ),
        ),
      ),
    );

    try {
      // Call deleteAccount on the notifier
      await ref.read(authNotifierProvider.notifier).deleteAccount();

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
            content: Text(context.l10n.common_error_deleteAccountFailed(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show language selector dialog
  void _showLanguageSelector(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const LanguageSelectorDialog(),
    );
  }

  /// Open URL in external browser
  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
