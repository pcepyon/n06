import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:n06/core/constants/legal_urls.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
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
  bool _agreeToSensitiveInfo = false;
  bool _agreeToMedicalDisclaimer = false;
  bool _agreeToMarketing = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

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
      // 검증 실패 시 자동 재검증 활성화 (사용자가 수정하면 실시간 갱신)
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      return;
    }

    if (!isValidConsent(
      termsOfService: _agreeToTerms,
      privacyPolicy: _agreeToPrivacy,
      sensitiveInfo: _agreeToSensitiveInfo,
      medicalDisclaimer: _agreeToMedicalDisclaimer,
    )) {
      if (!mounted) return;
      GabiumToast.showError(
        context,
        context.l10n.auth_signup_error_consentRequired,
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      if (!mounted) return;
      GabiumToast.showError(
        context,
        context.l10n.auth_signup_error_passwordMismatch,
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
        context.l10n.auth_signup_success,
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
        context.l10n.auth_signup_error_failed(e.toString()),
      );
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n.auth_signup_validation_emailRequired;
    }
    if (!isValidEmail(value)) {
      return context.l10n.auth_signup_validation_emailInvalid;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n.auth_signup_validation_passwordRequired;
    }
    if (value.length < 8) {
      return context.l10n.auth_signup_validation_passwordTooShort;
    }
    if (!isValidPassword(value)) {
      return context.l10n.auth_signup_validation_passwordWeak;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n.auth_signup_validation_confirmPasswordRequired;
    }
    if (value != _passwordController.text) {
      return context.l10n.auth_signup_validation_confirmPasswordMismatch;
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
          context.l10n.auth_signup_title,
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
          autovalidateMode: _autovalidateMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Section
              AuthHeroSection(
                title: context.l10n.auth_signup_heroTitle,
                subtitle: context.l10n.auth_signup_heroSubtitle,
              ),
              const SizedBox(height: 16),

              // Email field
              GabiumTextField(
                key: const Key('email_field'),
                controller: _emailController,
                label: context.l10n.auth_signup_emailLabel,
                hint: context.l10n.auth_signup_emailHint,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),

              // Password field
              GabiumTextField(
                controller: _passwordController,
                label: context.l10n.auth_signup_passwordLabel,
                obscureText: !_showPassword,
                onChanged: _updatePasswordStrength,
                validator: _validatePassword,
                autovalidateMode: _autovalidateMode,
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
                label: context.l10n.auth_signup_passwordConfirmLabel,
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
                      label: context.l10n.auth_signup_consentTerms,
                      isRequired: true,
                      onViewTap: () => _openUrl(LegalUrls.termsOfService),
                    ),
                    const SizedBox(height: 16),
                    ConsentCheckbox(
                      value: _agreeToPrivacy,
                      onChanged: (value) => setState(() => _agreeToPrivacy = value),
                      label: context.l10n.auth_signup_consentPrivacy,
                      isRequired: true,
                      onViewTap: () => _openUrl(LegalUrls.privacyPolicy),
                    ),
                    const SizedBox(height: 16),
                    ConsentCheckbox(
                      value: _agreeToSensitiveInfo,
                      onChanged: (value) => setState(() => _agreeToSensitiveInfo = value),
                      label: context.l10n.auth_signup_consentSensitiveInfo,
                      isRequired: true,
                      onViewTap: () => _openUrl(LegalUrls.sensitiveInfoConsent),
                    ),
                    const SizedBox(height: 16),
                    ConsentCheckbox(
                      value: _agreeToMedicalDisclaimer,
                      onChanged: (value) => setState(() => _agreeToMedicalDisclaimer = value),
                      label: context.l10n.auth_signup_consentMedicalDisclaimer,
                      isRequired: true,
                      onViewTap: () => _openUrl(LegalUrls.medicalDisclaimer),
                    ),
                    const SizedBox(height: 16),
                    ConsentCheckbox(
                      value: _agreeToMarketing,
                      onChanged: (value) => setState(() => _agreeToMarketing = value),
                      label: context.l10n.auth_signup_consentMarketing,
                      isRequired: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Sign up button
              GabiumButton(
                text: context.l10n.auth_signup_button,
                onPressed: _handleSignup,
                isLoading: _isLoading,
                variant: GabiumButtonVariant.primary,
                size: GabiumButtonSize.large,
              ),
              const SizedBox(height: 16),

              // Sign in link
              Center(
                child: GabiumButton(
                  text: context.l10n.auth_signup_signinLink,
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
