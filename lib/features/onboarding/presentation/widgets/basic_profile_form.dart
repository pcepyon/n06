import 'package:flutter/material.dart';
import 'package:n06/features/authentication/presentation/widgets/auth_hero_section.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_text_field.dart';

/// 기본 프로필(이름) 입력 폼
class BasicProfileForm extends StatefulWidget {
  final Function(String) onNameChanged;
  final VoidCallback onNext;

  const BasicProfileForm({super.key, required this.onNameChanged, required this.onNext});

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
            const AuthHeroSection(
              title: '가비움 온보딩을 시작하세요',
              subtitle: '당신의 건강 관리 여정을 함께합니다',
              icon: Icons.health_and_safety,
            ),
            const SizedBox(height: 24), // lg

            // Name Input
            GabiumTextField(
              controller: _nameController,
              label: '성명',
              hint: '성명',
              keyboardType: TextInputType.text,
              onChanged: (value) {
                widget.onNameChanged(value);
              },
            ),
            const SizedBox(height: 24), // lg

            // Next Button
            GabiumButton(
              text: '다음',
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
