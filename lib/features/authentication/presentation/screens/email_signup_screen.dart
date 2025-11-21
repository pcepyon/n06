import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/core/utils/validators.dart';
import 'package:n06/core/theme/app_colors.dart';
import 'package:n06/core/theme/app_text_styles.dart';
import 'package:n06/core/widgets/app_button.dart';
import 'package:n06/core/widgets/app_text_field.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';

/// Email signup screen
/// Allows users to create an account with email and password
class EmailSignupScreen extends ConsumerStatefulWidget {
  /// Optional pre-filled email (from sign-in screen)
  final String? prefillEmail;

  const EmailSignupScreen({
    super.key,
    this.prefillEmail,
  });

  @override
  ConsumerState<EmailSignupScreen> createState() => _EmailSignupScreenState();
}

class _EmailSignupScreenState extends ConsumerState<EmailSignupScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final GlobalKey<FormState> _formKey;

  bool _agreeToTerms = false;
  bool _agreeToPrivacy = false;
  bool _agreeToMarketing = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  PasswordStrength _passwordStrength = PasswordStrength.weak;

  @override
  void initState() {
    super.initState();
    // Pre-fill email if provided from sign-in screen
    _emailController = TextEditingController(
      text: widget.prefillEmail ?? '',
    );
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength(String password) {
    setState(() {
      _passwordStrength = getPasswordStrength(password);
    });
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!isValidConsent(
      termsOfService: _agreeToTerms,
      privacyPolicy: _agreeToPrivacy,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to terms and privacy policy')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (!mounted) return;

    try {
      final authNotifier = ref.read(authProvider.notifier);
      final user = await authNotifier.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        agreedToTerms: _agreeToTerms,
        agreedToPrivacy: _agreeToPrivacy,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign up successful!')),
      );

      // FIX BUG-2025-1119-003: 회원가입 성공 시 무조건 온보딩으로 이동
      // signUpWithEmail이 User 객체를 직접 반환하므로 authProvider 재조회 불필요
      if (!mounted) return;
      context.go('/onboarding', extra: user.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up failed: $e')),
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
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
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
                // Email field
                AppTextField(
                  key: const Key('email_field'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  label: '이메일',
                  hintText: 'example@email.com',
                  validator: _validateEmail,
                ),
                const SizedBox(height: 24),

                // Password field
                AppTextField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  label: '비밀번호',
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

                // Password strength indicator
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

                // Confirm password field
                AppTextField(
                  controller: _confirmPasswordController,
                  obscureText: !_showConfirmPassword,
                  label: '비밀번호 확인',
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

                // Consent checkboxes
                CheckboxListTile(
                  value: _agreeToTerms,
                  onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
                  title: const Text('이용약관 동의 (필수)', style: AppTextStyles.body2),
                  activeColor: AppColors.primary,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  value: _agreeToPrivacy,
                  onChanged: (value) => setState(() => _agreeToPrivacy = value ?? false),
                  title: const Text('개인정보처리방침 동의 (필수)', style: AppTextStyles.body2),
                  activeColor: AppColors.primary,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  value: _agreeToMarketing,
                  onChanged: (value) => setState(() => _agreeToMarketing = value ?? false),
                  title: const Text('마케팅 정보 수신 동의 (선택)', style: AppTextStyles.body2),
                  activeColor: AppColors.primary,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 32),

                // Sign up button
                AppButton(
                  text: '회원가입',
                  onPressed: _handleSignup,
                  type: AppButtonType.primary,
                ),
                const SizedBox(height: 16),

                // Sign in link
                AppButton(
                  text: '이미 계정이 있으신가요? 로그인',
                  onPressed: () => context.go('/email-signin'),
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
