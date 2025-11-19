import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/core/utils/validators.dart';
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
        title: const Text('Reset Password'),
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
                    'Enter your email to receive a password reset link',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
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
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _handleResetEmailRequest,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Send Reset Email'),
                    ),
                  ),
                ] else ...[
                  // Step 2: Change password
                  Text(
                    'Enter your new password',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: !_showPassword,
                    onChanged: _updatePasswordStrength,
                    decoration: InputDecoration(
                      labelText: 'New Password',
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
                  ElevatedButton(
                    onPressed: _handlePasswordChange,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Change Password'),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back to Sign In'),
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
