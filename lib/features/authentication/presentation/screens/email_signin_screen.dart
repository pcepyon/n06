import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/core/utils/validators.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/onboarding/application/providers.dart';

/// Email sign in screen
/// Allows users to sign in with email and password
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in successful!')),
        );

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
        // Show friendly signup prompt bottom sheet
        await _showSigninFailedBottomSheet();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in error: $e')),
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
    return null;
  }

  /// Show friendly bottom sheet when sign-in fails
  /// Guides user to sign up if they don't have an account
  Future<void> _showSigninFailedBottomSheet() async {
    // FIX BUG-2025-1120-008: Await bottom sheet result and navigate with parent context
    final email = _emailController.text.trim();

    final shouldNavigateToSignup = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true, // Required for GoRouter navigation after dismiss
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
            // Icon
            const Icon(
              Icons.lock_outline,
              size: 48,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              '로그인에 실패했습니다',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            const Text(
              '입력하신 이메일 또는 비밀번호가\n일치하지 않습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Divider
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 16),

            // Sign up prompt
            const Text(
              '💡 혹시 계정이 없으신가요?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // Sign up button
            ElevatedButton(
              key: const Key('goto_signup_button'),
              onPressed: () {
                // Close sheet and signal to navigate
                Navigator.pop(sheetContext, true);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('이메일로 회원가입 하러가기'),
            ),
            const SizedBox(height: 8),

            // Close button
            TextButton(
              key: const Key('close_bottomsheet_button'),
              onPressed: () => Navigator.pop(sheetContext, false),
              child: const Text('닫기'),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
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
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'user@example.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 8),

                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.go('/password-reset'),
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: 24),

                // Sign in button
                ElevatedButton(
                  onPressed: _handleSignin,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Sign In'),
                  ),
                ),
                const SizedBox(height: 16),

                // Sign up link
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/email-signup'),
                    child: const Text('Don\'t have an account? Sign up'),
                  ),
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
