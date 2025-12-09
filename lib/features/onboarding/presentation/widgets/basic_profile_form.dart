import 'package:flutter/material.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/authentication/presentation/widgets/auth_hero_section.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_text_field.dart';

/// 기본 프로필(이름) 입력 폼
class BasicProfileForm extends StatefulWidget {
  final Function(String) onNameChanged;
  final VoidCallback onNext;

  const BasicProfileForm({
    super.key,
    required this.onNameChanged,
    required this.onNext,
  });

  @override
  State<BasicProfileForm> createState() => _BasicProfileFormState();
}

class _BasicProfileFormState extends State<BasicProfileForm> {
  late TextEditingController _nameController;
  bool _isNameValid = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _nameController.addListener(_validateName);
  }

  void _validateName() {
    final isValid = _nameController.text.trim().isNotEmpty;
    setState(() {
      _isNameValid = isValid;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0), // xl
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            AuthHeroSection(
              title: context.l10n.onboarding_profile_title,
              subtitle: context.l10n.onboarding_profile_subtitle,
            ),
            const SizedBox(height: 24), // lg

            // Name Input
            GabiumTextField(
              controller: _nameController,
              label: context.l10n.onboarding_profile_nameLabel,
              hint: context.l10n.onboarding_profile_nameHint,
              keyboardType: TextInputType.text,
              onChanged: (value) {
                widget.onNameChanged(value);
              },
            ),
            const SizedBox(height: 16), // md

            // Privacy Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.onboarding_profile_privacyNotice,
                      style: AppTypography.caption,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24), // lg

            // Next Button
            GabiumButton(
              text: context.l10n.onboarding_common_nextButton,
              onPressed: _isNameValid ? widget.onNext : null,
              variant: GabiumButtonVariant.primary,
              size: GabiumButtonSize.medium,
            ),
          ],
        ),
      ),
    );
  }
}
