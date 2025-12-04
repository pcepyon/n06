import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
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
        GabiumToast.showSuccess(context, context.l10n.auth_signin_success);

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
      GabiumToast.showError(context, context.l10n.auth_signin_error_failed(e.toString()));
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n.auth_signin_validation_emailRequired;
    }
    if (!isValidEmail(value)) {
      return context.l10n.auth_signin_validation_emailInvalid;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n.auth_signin_validation_passwordRequired;
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
                  color: AppColors.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),

              // Icon
              Icon(
                Icons.lock_outline,
                size: 48,
                color: AppColors.warning,
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                context.l10n.auth_signin_failedBottomSheet_title,
                style: AppTypography.heading1,
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                context.l10n.auth_signin_failedBottomSheet_message,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 24),

              // Divider
              Divider(
                color: AppColors.border,
                thickness: 1,
              ),
              const SizedBox(height: 24),

              // Prompt
              Text(
                context.l10n.auth_signin_failedBottomSheet_prompt,
                style: AppTypography.heading3.copyWith(
                  color: AppColors.neutral700,
                ),
              ),
              const SizedBox(height: 16),

              // Primary Button
              GabiumButton(
                key: const Key('goto_signup_button'),
                text: context.l10n.auth_signin_failedBottomSheet_signupButton,
                onPressed: () => Navigator.pop(sheetContext, true),
                variant: GabiumButtonVariant.primary,
                size: GabiumButtonSize.large,
              ),
              const SizedBox(height: 8),

              // Secondary Button
              GabiumButton(
                key: const Key('close_bottomsheet_button'),
                text: context.l10n.auth_signin_failedBottomSheet_closeButton,
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          context.l10n.auth_signin_title,
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
            color: AppColors.border,
            height: 1,
          ),
        ),
      ),
      body: authState.maybeWhen(
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                context.l10n.auth_signin_error_title(error.toString()),
                style: TextStyle(color: AppColors.error),
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
                AuthHeroSection(
                  title: context.l10n.auth_signin_heroTitle,
                  subtitle: context.l10n.auth_signin_heroSubtitle,
                ),
                const SizedBox(height: 24), // lg

                // Email field
                GabiumTextField(
                  controller: _emailController,
                  label: context.l10n.auth_signin_emailLabel,
                  hint: context.l10n.auth_signin_emailHint,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16), // md

                // Password field
                GabiumTextField(
                  controller: _passwordController,
                  label: context.l10n.auth_signin_passwordLabel,
                  obscureText: !_showPassword,
                  validator: _validatePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                ),
                const SizedBox(height: 8), // sm

                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: GabiumButton(
                    text: context.l10n.auth_signin_forgotPasswordLink,
                    onPressed: () => context.go('/password-reset'),
                    variant: GabiumButtonVariant.ghost,
                    size: GabiumButtonSize.medium,
                  ),
                ),
                const SizedBox(height: 24), // lg

                // Sign in button
                GabiumButton(
                  text: context.l10n.auth_signin_button,
                  onPressed: _handleSignin,
                  variant: GabiumButtonVariant.primary,
                  size: GabiumButtonSize.large,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 16), // md

                // Sign up link
                Center(
                  child: GabiumButton(
                    text: context.l10n.auth_signin_signupLink,
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
