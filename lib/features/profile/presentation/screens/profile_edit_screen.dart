import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  String? _validationError;

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 및 목표 수정'),
        elevation: 0,
      ),
      body: profileState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('오류가 발생했습니다: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(profileNotifierProvider);
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (profile) {
          if (profile == null) {
            return const Center(
              child: Text('프로필 정보를 찾을 수 없습니다.'),
            );
          }

          return Stack(
            children: [
              ProfileEditForm(
                profile: profile,
                onProfileChanged: (newProfile) {
                  setState(() {
                    _editedProfile = newProfile;
                    _validationError = null;
                  });
                },
              ),
              // Validation error message
              if (_validationError != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.red.withValues(alpha: 0.8),
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _validationError!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: _editedProfile != null
          ? FloatingActionButton(
              onPressed: _handleSave,
              child: const Icon(Icons.check),
            )
          : null,
    );
  }

  void _handleSave() async {
    if (_editedProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('변경사항이 없습니다.')),
      );
      Navigator.pop(context);
      return;
    }

    // Validate
    if (_editedProfile!.targetWeight.value >= _editedProfile!.currentWeight.value) {
      setState(() {
        _validationError = '목표 체중은 현재 체중보다 작아야 합니다.';
      });
      return;
    }

    try {
      // Update profile
      await ref.read(profileNotifierProvider.notifier).updateProfile(_editedProfile!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필이 저장되었습니다.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _validationError = '저장 실패: $e';
      });
    }
  }
}
