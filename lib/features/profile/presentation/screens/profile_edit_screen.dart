import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_toast.dart';
import 'package:n06/features/onboarding/domain/entities/user_profile.dart';
import 'package:n06/features/profile/application/notifiers/profile_notifier.dart';
import 'package:n06/features/profile/presentation/widgets/profile_edit_form.dart';

/// Screen for editing user profile and goals
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  UserProfile? _editedProfile;

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('프로필 및 목표 수정'),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 56,
        titleTextStyle: AppTypography.heading2,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.border,
            height: 1,
          ),
        ),
      ),
      body: profileState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primary,
            ),
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error icon
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                // Error title
                Text(
                  '오류 발생',
                  style: AppTypography.heading3,
                ),
                const SizedBox(height: 8),
                // Error message
                Text(
                  '프로필을 불러오는 중에 오류가 발생했습니다. 다시 시도해주세요.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 24),
                // Retry button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      ref.invalidate(profileNotifierProvider);
                    },
                    child: const Text(
                      '다시 시도',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (profile) {
          if (profile == null) {
            return const Center(
              child: Text('프로필 정보를 찾을 수 없습니다.'),
            );
          }

          return ProfileEditForm(
            profile: profile,
            onProfileChanged: (newProfile) {
              setState(() {
                _editedProfile = newProfile;
              });
            },
            onSave: _editedProfile != null ? _handleSave : null,
          );
        },
      ),
    );
  }

  void _handleSave() async {
    if (_editedProfile == null) {
      GabiumToast.showInfo(context, '변경사항이 없습니다.');
      if (mounted) {
        Navigator.pop(context);
      }
      return;
    }

    // Validate
    if (_editedProfile!.targetWeight.value >= _editedProfile!.currentWeight.value) {
      GabiumToast.showError(context, '목표 체중은 현재 체중보다 작아야 합니다.');
      return;
    }

    try {
      // Update profile
      await ref.read(profileNotifierProvider.notifier).updateProfile(_editedProfile!);

      if (mounted) {
        GabiumToast.showSuccess(context, '프로필이 저장되었습니다.');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        GabiumToast.showError(context, '저장 실패: $e');
      }
    }
  }
}
