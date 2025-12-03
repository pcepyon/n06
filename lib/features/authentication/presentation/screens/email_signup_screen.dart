import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:n06/core/constants/legal_urls.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/core/utils/validators.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/authentication/presentation/widgets/auth_hero_section.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_text_field.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';
import 'package:n06/features/authentication/presentation/widgets/password_strength_indicator.dart';
import 'package:n06/features/authentication/presentation/widgets/consent_checkbox.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_toast.dart';

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
  bool _isLoading = false;

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
      if (!mounted) return;
      GabiumToast.showError(
        context,
        '이용약관과 개인정보 처리방침에 동의해주세요',
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      if (!mounted) return;
      GabiumToast.showError(
        context,
        '비밀번호가 일치하지 않습니다',
      );
      return;
    }

    setState(() => _isLoading = true);

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

      GabiumToast.showSuccess(
        context,
        '회원가입이 완료되었습니다!',
      );

      // FIX BUG-2025-1119-003: 회원가입 성공 시 무조건 온보딩으로 이동
      // signUpWithEmail이 User 객체를 직접 반환하므로 authProvider 재조회 불필요
      if (!mounted) return;
      context.go('/onboarding', extra: user.id);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      GabiumToast.showError(
        context,
        '회원가입에 실패했습니다: $e',
      );
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요';
    }
    if (!isValidEmail(value)) {
      return '올바른 이메일 형식을 입력해주세요';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    if (value.length < 8) {
      return '비밀번호는 최소 8자 이상이어야 합니다';
    }
    if (!isValidPassword(value)) {
      return '비밀번호는 대문자, 소문자, 숫자, 특수문자를 포함해야 합니다';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호 확인을 입력해주세요';
    }
    if (value != _passwordController.text) {
      return '비밀번호가 일치하지 않습니다';
    }
    return null;
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          '가비움 시작하기',
          style: AppTypography.heading2,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.neutral700),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/login');
            }
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.border,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Section
              const AuthHeroSection(
                title: '가비움과 함께 시작해요',
                subtitle: '건강한 변화의 첫 걸음',
              ),
              const SizedBox(height: 16),

              // Email field
              GabiumTextField(
                key: const Key('email_field'),
                controller: _emailController,
                label: '이메일',
                hint: 'user@example.com',
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),

              // Password field
              GabiumTextField(
                controller: _passwordController,
                label: '비밀번호',
                obscureText: !_showPassword,
                onChanged: _updatePasswordStrength,
                validator: _validatePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.textTertiary,
                  ),
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                ),
              ),
              const SizedBox(height: 8),

              // Password strength indicator
              PasswordStrengthIndicator(strength: _passwordStrength),
              const SizedBox(height: 16),

              // Confirm password field
              GabiumTextField(
                controller: _confirmPasswordController,
                label: '비밀번호 확인',
                obscureText: !_showConfirmPassword,
                validator: _validateConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.textTertiary,
                  ),
                  onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                ),
              ),
              const SizedBox(height: 24),

              // Consent section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ConsentCheckbox(
                      value: _agreeToTerms,
                      onChanged: (value) => setState(() => _agreeToTerms = value),
                      label: '이용약관에 동의합니다',
                      isRequired: true,
                      onViewTap: () => _openUrl(LegalUrls.termsOfService),
                    ),
                    const SizedBox(height: 16),
                    ConsentCheckbox(
                      value: _agreeToPrivacy,
                      onChanged: (value) => setState(() => _agreeToPrivacy = value),
                      label: '개인정보 처리방침에 동의합니다',
                      isRequired: true,
                      onViewTap: () => _openUrl(LegalUrls.privacyPolicy),
                    ),
                    const SizedBox(height: 16),
                    ConsentCheckbox(
                      value: _agreeToMarketing,
                      onChanged: (value) => setState(() => _agreeToMarketing = value),
                      label: '마케팅 정보 수신에 동의합니다',
                      isRequired: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Sign up button
              GabiumButton(
                text: '회원가입',
                onPressed: _handleSignup,
                isLoading: _isLoading,
                variant: GabiumButtonVariant.primary,
                size: GabiumButtonSize.large,
              ),
              const SizedBox(height: 16),

              // Sign in link
              Center(
                child: GabiumButton(
                  text: '이미 계정이 있으신가요? 로그인',
                  onPressed: () => context.go('/email-signin'),
                  variant: GabiumButtonVariant.ghost,
                  size: GabiumButtonSize.medium,
                ),
              ),
              const SizedBox(height: 32), // Bottom padding for scroll
            ],
          ),
        ),
      ),
    );
  }
}
