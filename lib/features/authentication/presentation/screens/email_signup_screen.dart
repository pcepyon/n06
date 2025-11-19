import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/core/utils/validators.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';

/// Email signup screen
/// Allows users to create an account with email and password
class EmailSignupScreen extends ConsumerStatefulWidget {
  const EmailSignupScreen({super.key});

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
    _emailController = TextEditingController();
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
      final isFirstLogin = await authNotifier.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        agreedToTerms: _agreeToTerms,
        agreedToPrivacy: _agreeToPrivacy,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign up successful!')),
      );

      // Navigate based on onboarding status
      if (isFirstLogin) {
        // Go to onboarding
        // TODO: Navigate to onboarding screen
      } else {
        // Go to dashboard
        // TODO: Navigate to dashboard
      }
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
        title: const Text('Create Account'),
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
                  onChanged: _updatePasswordStrength,
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

                // Password strength indicator
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: _passwordStrength.index / PasswordStrength.values.length,
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _passwordStrength.name,
                      style: TextStyle(
                        color: switch (_passwordStrength) {
                          PasswordStrength.weak => Colors.red,
                          PasswordStrength.medium => Colors.orange,
                          PasswordStrength.strong => Colors.green,
                        },
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Confirm password field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_showConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(_showConfirmPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                    ),
                  ),
                  validator: _validateConfirmPassword,
                ),
                const SizedBox(height: 24),

                // Consent checkboxes
                CheckboxListTile(
                  value: _agreeToTerms,
                  onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
                  title: const Text('I agree to Terms of Service (required)'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  value: _agreeToPrivacy,
                  onChanged: (value) => setState(() => _agreeToPrivacy = value ?? false),
                  title: const Text('I agree to Privacy Policy (required)'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  value: _agreeToMarketing,
                  onChanged: (value) => setState(() => _agreeToMarketing = value ?? false),
                  title: const Text('I agree to Marketing Email (optional)'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 24),

                // Sign up button
                ElevatedButton(
                  onPressed: _handleSignup,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Sign Up'),
                  ),
                ),
                const SizedBox(height: 16),

                // Sign in link
                Center(
                  child: TextButton(
                    onPressed: () {
                      // Navigate to sign in
                      // TODO: Navigate to EmailSignInScreen
                    },
                    child: const Text('Already have an account? Sign in'),
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
