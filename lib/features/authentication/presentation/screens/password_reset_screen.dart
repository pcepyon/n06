import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/core/utils/validators.dart';
import 'package:n06/core/theme/app_colors.dart';
import 'package:n06/core/theme/app_text_styles.dart';
import 'package:n06/core/widgets/app_button.dart';
import 'package:n06/core/widgets/app_text_field.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';

/// Password reset screen
/// Step 1: Request password reset email
/// Step 2: Change password using token from email
class PasswordResetScreen extends ConsumerStatefulWidget {
  final String? token;

  const PasswordResetScreen({super.key, this.token});

  @override
  ConsumerState<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends ConsumerState<PasswordResetScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;
  late final GlobalKey<FormState> _formKey;

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  PasswordStrength _passwordStrength = PasswordStrength.weak;

  bool get _hasToken => widget.token != null && widget.token!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength(String password) {
    setState(() {
      _passwordStrength = getPasswordStrength(password);
    });
  }

  Future<void> _handleResetEmailRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;

    try {
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.resetPasswordForEmail(_emailController.text.trim());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent. Check your inbox.')),
      );

      // Clear form
      _emailController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _handlePasswordChange() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (!mounted) return;

    try {
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.updatePassword(
        currentPassword: '', // Token-based reset, no current password needed
        newPassword: _newPasswordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );

      // Navigate back to signin
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!isValidPassword(value)) {
      return 'Password must contain uppercase, lowercase, number, and special character';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('비밀번호 재설정'),
      ),
      body: authState.maybeWhen(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
        data: (_) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!_hasToken) ...[
                  // Step 1: Request reset email
                  Text(
                    '가입하신 이메일 주소를 입력하시면\n비밀번호 재설정 링크를 보내드립니다.',
                    style: AppTextStyles.body1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  AppTextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    label: '이메일',
                    hintText: 'example@email.com',
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 32),
                  AppButton(
                    text: '재설정 메일 보내기',
                    onPressed: _handleResetEmailRequest,
                    type: AppButtonType.primary,
                  ),
                ] else ...[
                  // Step 2: Change password
                  Text(
                    '새로운 비밀번호를 입력해주세요',
                    style: AppTextStyles.h2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  AppTextField(
                    controller: _newPasswordController,
                    obscureText: !_showPassword,
                    label: '새 비밀번호',
                    hintText: '영문, 숫자, 특수문자 포함 8자 이상',
                    onChanged: _updatePasswordStrength,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.gray,
                      ),
                      onPressed: () => setState(() => _showPassword = !_showPassword),
                    ),
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: _passwordStrength.index / PasswordStrength.values.length,
                            minHeight: 4,
                            backgroundColor: AppColors.extraLightGray,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              switch (_passwordStrength) {
                                PasswordStrength.weak => AppColors.error,
                                PasswordStrength.medium => AppColors.warning,
                                PasswordStrength.strong => AppColors.success,
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        switch (_passwordStrength) {
                          PasswordStrength.weak => '약함',
                          PasswordStrength.medium => '보통',
                          PasswordStrength.strong => '안전',
                        },
                        style: AppTextStyles.caption.copyWith(
                          color: switch (_passwordStrength) {
                            PasswordStrength.weak => AppColors.error,
                            PasswordStrength.medium => AppColors.warning,
                            PasswordStrength.strong => AppColors.success,
                          },
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    controller: _confirmPasswordController,
                    obscureText: !_showConfirmPassword,
                    label: '새 비밀번호 확인',
                    hintText: '비밀번호를 다시 입력해주세요',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.gray,
                      ),
                      onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                    ),
                    validator: _validateConfirmPassword,
                  ),
                  const SizedBox(height: 32),
                  AppButton(
                    text: '비밀번호 변경하기',
                    onPressed: _handlePasswordChange,
                    type: AppButtonType.primary,
                  ),
                ],
                const SizedBox(height: 16),
                AppButton(
                  text: '로그인 화면으로 돌아가기',
                  onPressed: () => Navigator.of(context).pop(),
                  type: AppButtonType.ghost,
                ),
              ],
            ),
          ),
        ),
        orElse: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
