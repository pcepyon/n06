import 'package:flutter/material.dart';
import 'package:n06/features/authentication/presentation/widgets/auth_hero_section.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_text_field.dart';

/// 기본 프로필(이름) 입력 폼
class BasicProfileForm extends StatefulWidget {
  final Function(String) onNameChanged;
  final VoidCallback onNext;
  final bool isReviewMode;
  final String? initialName;

  const BasicProfileForm({
    super.key,
    required this.onNameChanged,
    required this.onNext,
    this.isReviewMode = false,
    this.initialName,
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
    _nameController = TextEditingController(
      text: widget.initialName ?? '',
    );
    _nameController.addListener(_validateName);
    // 리뷰 모드에서 초기값이 있으면 부모에게 알림
    if (widget.isReviewMode && widget.initialName != null) {
      widget.onNameChanged(widget.initialName!);
      _validateName();
    }
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
              title: widget.isReviewMode
                  ? '🌟 프로필 확인'
                  : '🌟 여정의 주인공을 알려주세요',
              subtitle: widget.isReviewMode
                  ? '현재 등록된 이름입니다'
                  : '앞으로 이 이름으로 응원해 드릴게요',
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
            const SizedBox(height: 16), // md

            // Privacy Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9), // Neutral-100
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: Color(0xFF64748B), // Neutral-500
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '입력하신 건강 데이터는 암호화되어 안전하게 보관됩니다.',
                      style: TextStyle(
                        fontSize: 12, // xs
                        color: Color(0xFF64748B), // Neutral-500
                      ),
                    ),
                  ),
                ],
              ),
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
