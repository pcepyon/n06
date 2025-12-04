import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
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
        SnackBar(content: Text(context.l10n.auth_passwordReset_emailSent)),
      );

      // Clear form
      _emailController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.auth_passwordReset_error(e.toString()))),
      );
    }
  }

  Future<void> _handlePasswordChange() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.auth_passwordReset_validation_passwordMismatch)),
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
        SnackBar(content: Text(context.l10n.auth_passwordReset_success)),
      );

      // Navigate back to signin
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.auth_passwordReset_error(e.toString()))),
      );
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n.auth_passwordReset_validation_emailRequired;
    }
    if (!isValidEmail(value)) {
      return context.l10n.auth_passwordReset_validation_emailInvalid;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n.auth_passwordReset_validation_passwordRequired;
    }
    if (value.length < 8) {
      return context.l10n.auth_passwordReset_validation_passwordTooShort;
    }
    if (!isValidPassword(value)) {
      return context.l10n.auth_passwordReset_validation_passwordWeak;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n.auth_passwordReset_validation_confirmPasswordRequired;
    }
    if (value != _newPasswordController.text) {
      return context.l10n.auth_passwordReset_validation_passwordMismatch;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.auth_passwordReset_title),
      ),
      body: authState.maybeWhen(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(context.l10n.auth_passwordReset_error(error.toString())),
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
                    context.l10n.auth_passwordReset_requestEmail_description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: context.l10n.auth_passwordReset_emailLabel,
                      hintText: context.l10n.auth_passwordReset_emailHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _handleResetEmailRequest,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(context.l10n.auth_passwordReset_sendEmailButton),
                    ),
                  ),
                ] else ...[
                  // Step 2: Change password
                  Text(
                    context.l10n.auth_passwordReset_changePassword_description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: !_showPassword,
                    onChanged: _updatePasswordStrength,
                    decoration: InputDecoration(
                      labelText: context.l10n.auth_passwordReset_newPasswordLabel,
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
                      labelText: context.l10n.auth_passwordReset_confirmPasswordLabel,
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
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(context.l10n.auth_passwordReset_changePasswordButton),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(context.l10n.auth_passwordReset_backToSignin),
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
