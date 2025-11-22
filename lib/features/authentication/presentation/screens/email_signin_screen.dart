import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/core/utils/validators.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/authentication/presentation/widgets/auth_hero_section.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_text_field.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_toast.dart';
import 'package:n06/features/onboarding/application/providers.dart';

/// Email sign in screen
/// Allows users to sign in with email and password
/// REDESIGNED: Gabium-branded UI with Design System compliance
class EmailSigninScreen extends ConsumerStatefulWidget {
  const EmailSigninScreen({super.key});

  @override
  ConsumerState<EmailSigninScreen> createState() => _EmailSigninScreenState();
}

class _EmailSigninScreenState extends ConsumerState<EmailSigninScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final GlobalKey<FormState> _formKey;

  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;

    try {
      final authNotifier = ref.read(authProvider.notifier);
      final success = await authNotifier.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        // SUCCESS: Show toast
        GabiumToast.showSuccess(context, '로그인 성공!');

        if (!mounted) return;

        // FIX BUG-2025-1119-004: Check if user has completed onboarding
        // Same pattern as OAuth login (login_screen.dart)
        final user = ref.read(authProvider).value;
        if (user != null) {
          final profileRepo = ref.read(profileRepositoryProvider);
          final profile = await profileRepo.getUserProfile(user.id);

          if (!mounted) return;

          if (profile == null) {
            // User hasn't completed onboarding, redirect to onboarding
            context.go('/onboarding', extra: user.id);
          } else {
            // User has profile, go to dashboard
            context.go('/home');
          }
        } else {
          // Fallback: user is null (unlikely after successful signin)
          context.go('/home');
        }
      } else {
        // FAILURE: Show friendly signup prompt bottom sheet
        await _showSigninFailedBottomSheet();
      }
    } catch (e) {
      if (!mounted) return;
      GabiumToast.showError(context, '로그인 실패: $e');
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
    return null;
  }

  /// Show friendly bottom sheet when sign-in fails
  /// Guides user to sign up if they don't have an account
  Future<void> _showSigninFailedBottomSheet() async {
    final email = _emailController.text.trim();

    final shouldNavigateToSignup = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true, // Required for GoRouter navigation after dismiss
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)), // lg
      ),
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1), // Neutral-300
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),

              // Icon
              const Icon(
                Icons.lock_outline,
                size: 48,
                color: Color(0xFFF59E0B), // Warning
              ),
              const SizedBox(height: 16),

              // Title
              const Text(
                '로그인에 실패했습니다',
                style: TextStyle(
                  fontSize: 24, // 2xl
                  fontWeight: FontWeight.w700, // Bold
                  color: Color(0xFF1E293B), // Neutral-800
                ),
              ),
              const SizedBox(height: 8),

              // Description
              const Text(
                '입력하신 이메일 또는 비밀번호가\n일치하지 않습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16, // base
                  fontWeight: FontWeight.w400, // Regular
                  color: Color(0xFF475569), // Neutral-600
                ),
              ),
              const SizedBox(height: 24),

              // Divider
              const Divider(
                color: Color(0xFFE2E8F0), // Neutral-200
                thickness: 1,
              ),
              const SizedBox(height: 24),

              // Prompt
              const Text(
                '💡 혹시 계정이 없으신가요?',
                style: TextStyle(
                  fontSize: 18, // lg
                  fontWeight: FontWeight.w600, // Semibold
                  color: Color(0xFF334155), // Neutral-700
                ),
              ),
              const SizedBox(height: 16),

              // Primary Button
              GabiumButton(
                key: const Key('goto_signup_button'),
                text: '이메일로 회원가입 하러가기',
                onPressed: () => Navigator.pop(sheetContext, true),
                variant: GabiumButtonVariant.primary,
                size: GabiumButtonSize.large,
              ),
              const SizedBox(height: 8),

              // Secondary Button
              GabiumButton(
                key: const Key('close_bottomsheet_button'),
                text: '닫기',
                onPressed: () => Navigator.pop(sheetContext, false),
                variant: GabiumButtonVariant.ghost,
                size: GabiumButtonSize.medium,
              ),
            ],
          ),
        ),
      ),
    );

    // Navigate after sheet is closed
    if (mounted && shouldNavigateToSignup == true) {
      context.go('/email-signup', extra: email);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Neutral-50
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF), // White
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF334155)), // Neutral-700
        title: const Text(
          '이메일로 로그인',
          style: TextStyle(
            fontSize: 20, // xl
            fontWeight: FontWeight.w600, // Semibold
            color: Color(0xFF1E293B), // Neutral-800
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE2E8F0), // Neutral-200
            height: 1,
          ),
        ),
      ),
      body: authState.maybeWhen(
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
              const SizedBox(height: 16),
              Text(
                '오류 발생: $error',
                style: const TextStyle(color: Color(0xFFEF4444)),
              ),
            ],
          ),
        ),
        orElse: () => SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 16, // md
            right: 16, // md
            bottom: 32, // xl
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Section
                const AuthHeroSection(
                  title: '이메일로 로그인',
                  subtitle: '가비움 계정으로 로그인해주세요',
                  icon: Icons.lock_outline,
                ),
                const SizedBox(height: 24), // lg

                // Email field
                GabiumTextField(
                  controller: _emailController,
                  label: '이메일',
                  hint: 'user@example.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16), // md

                // Password field
                GabiumTextField(
                  controller: _passwordController,
                  label: '비밀번호',
                  obscureText: !_showPassword,
                  validator: _validatePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                      color: const Color(0xFF64748B), // Neutral-500
                    ),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                ),
                const SizedBox(height: 8), // sm

                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: GabiumButton(
                    text: '비밀번호를 잊으셨나요?',
                    onPressed: () => context.go('/password-reset'),
                    variant: GabiumButtonVariant.ghost,
                    size: GabiumButtonSize.medium,
                  ),
                ),
                const SizedBox(height: 24), // lg

                // Sign in button
                GabiumButton(
                  text: '로그인',
                  onPressed: _handleSignin,
                  variant: GabiumButtonVariant.primary,
                  size: GabiumButtonSize.large,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 16), // md

                // Sign up link
                Center(
                  child: GabiumButton(
                    text: '계정이 없으신가요? 회원가입',
                    onPressed: () => context.go('/email-signup'),
                    variant: GabiumButtonVariant.ghost,
                    size: GabiumButtonSize.medium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
