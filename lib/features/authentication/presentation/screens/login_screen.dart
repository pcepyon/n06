import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/authentication/domain/exceptions/auth_exceptions.dart';
import 'package:n06/features/authentication/presentation/widgets/auth_hero_section.dart';
import 'package:n06/features/authentication/presentation/widgets/consent_checkbox.dart';
import 'package:n06/features/authentication/presentation/widgets/social_login_button.dart';

/// Login screen with social authentication options
///
/// Features:
/// - Kakao login button
/// - Naver login button
/// - Terms of service and privacy policy checkboxes
/// - Login buttons disabled until agreements are checked
/// - Navigation to onboarding (first login) or home dashboard (returning user)
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _agreedToTerms = false;
  bool _agreedToPrivacy = false;
  bool _isLoading = false;

  bool get _canLogin => _agreedToTerms && _agreedToPrivacy && !_isLoading;

  Future<void> _handleKakaoLogin() async {
    if (kDebugMode) {
      developer.log(
        '🔐 Kakao login button clicked',
        name: 'LoginScreen',
      );
      developer.log(
        'Can login: $_canLogin (terms: $_agreedToTerms, privacy: $_agreedToPrivacy, loading: $_isLoading)',
        name: 'LoginScreen',
      );
    }

    if (!_canLogin) {
      if (kDebugMode) {
        developer.log(
          '⚠️ Login blocked - conditions not met',
          name: 'LoginScreen',
          level: 900,
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    if (kDebugMode) {
      developer.log('📱 Starting Kakao login...', name: 'LoginScreen');
    }

    try {
      final notifier = ref.read(authNotifierProvider.notifier);

      if (kDebugMode) {
        developer.log('🔄 Calling notifier.loginWithKakao()...', name: 'LoginScreen');
      }

      final isFirstLogin = await notifier.loginWithKakao(
        agreedToTerms: _agreedToTerms,
        agreedToPrivacy: _agreedToPrivacy,
      );

      if (kDebugMode) {
        developer.log(
          '✅ Login completed. First login: $isFirstLogin',
          name: 'LoginScreen',
        );
      }

      if (!mounted) {
        if (kDebugMode) {
          developer.log('⚠️ Widget unmounted', name: 'LoginScreen', level: 900);
        }
        return;
      }

      // Verify auth state before navigation
      final authState = ref.read(authNotifierProvider);

      // Check for errors first (before accessing value)
      if (authState.hasError) {
        if (kDebugMode) {
          authState.whenOrNull(
            error: (error, stack) {
              developer.log(
                '❌ Auth state has error after login',
                name: 'LoginScreen',
                error: error,
                stackTrace: stack,
                level: 1000,
              );
            },
          );
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.auth_login_error_failed),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Safe to access value now (no error)
      final user = authState.asData?.value;

      if (user == null) {
        if (kDebugMode) {
          developer.log(
            '❌ User is null after login',
            name: 'LoginScreen',
            level: 1000,
          );
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.auth_login_error_userInfoFailed),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (kDebugMode) {
        developer.log(
          '✅ Auth state verified. User: ${user.id}',
          name: 'LoginScreen',
        );
      }

      if (mounted) {
        if (isFirstLogin) {
          if (kDebugMode) {
            developer.log('🚀 Navigating to onboarding...', name: 'LoginScreen');
          }
          context.go('/onboarding', extra: user.id);
        } else {
          if (kDebugMode) {
            developer.log('🏠 Navigating to home dashboard...', name: 'LoginScreen');
          }
          context.go('/home');
        }
      }
    } on OAuthCancelledException catch (e, stack) {
      if (kDebugMode) {
        developer.log(
          '🚫 OAuth cancelled by user',
          name: 'LoginScreen',
          error: e,
          stackTrace: stack,
          level: 900,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.auth_login_error_cancelled),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } on MaxRetriesExceededException catch (e, stack) {
      if (kDebugMode) {
        developer.log(
          '🌐 Network error - max retries exceeded',
          name: 'LoginScreen',
          error: e,
          stackTrace: stack,
          level: 1000,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.auth_login_error_networkWithRetry),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: context.l10n.auth_login_error_retryButton,
              textColor: Colors.white,
              onPressed: () => _handleKakaoLogin(),
            ),
          ),
        );
      }
    } catch (e, stack) {
      if (kDebugMode) {
        developer.log(
          '❌ Unexpected error during login',
          name: 'LoginScreen',
          error: e,
          stackTrace: stack,
          level: 1000,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.auth_login_error_unknown(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        if (kDebugMode) {
          developer.log('🏁 Login process completed', name: 'LoginScreen');
        }
      }
    }
  }

  Future<void> _handleNaverLogin() async {
    if (!_canLogin) return;

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(authNotifierProvider.notifier);
      final isFirstLogin = await notifier.loginWithNaver(
        agreedToTerms: _agreedToTerms,
        agreedToPrivacy: _agreedToPrivacy,
      );

      if (kDebugMode) {
        developer.log(
          '✅ Login completed. First login: $isFirstLogin',
          name: 'LoginScreen',
        );
      }

      if (!mounted) {
        if (kDebugMode) {
          developer.log('⚠️ Widget unmounted', name: 'LoginScreen', level: 900);
        }
        return;
      }

      // Verify auth state before navigation
      final authState = ref.read(authNotifierProvider);

      // Check for errors first (before accessing value)
      if (authState.hasError) {
        if (kDebugMode) {
          authState.whenOrNull(
            error: (error, stack) {
              developer.log(
                '❌ Auth state has error after login',
                name: 'LoginScreen',
                error: error,
                stackTrace: stack,
                level: 1000,
              );
            },
          );
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.auth_login_error_failed),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Safe to access value now (no error)
      final user = authState.asData?.value;

      if (user == null) {
        if (kDebugMode) {
          developer.log(
            '❌ User is null after login',
            name: 'LoginScreen',
            level: 1000,
          );
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.auth_login_error_userInfoFailed),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (kDebugMode) {
        developer.log(
          '✅ Auth state verified. User: ${user.id}',
          name: 'LoginScreen',
        );
      }

      if (mounted) {
        if (isFirstLogin) {
          if (kDebugMode) {
            developer.log('🚀 Navigating to onboarding...', name: 'LoginScreen');
          }
          context.go('/onboarding', extra: user.id);
        } else {
          if (kDebugMode) {
            developer.log('🏠 Navigating to home dashboard...', name: 'LoginScreen');
          }
          context.go('/home');
        }
      }
    } on OAuthCancelledException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.auth_login_error_cancelled),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } on MaxRetriesExceededException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.auth_login_error_networkWithRetry),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: context.l10n.auth_login_error_retryButton,
              textColor: Colors.white,
              onPressed: () => _handleNaverLogin(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.auth_login_error_unknown(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleAppleLogin() async {
    if (kDebugMode) {
      developer.log(
        '🍎 Apple login button clicked',
        name: 'LoginScreen',
      );
    }

    if (!_canLogin) {
      if (kDebugMode) {
        developer.log(
          '⚠️ Login blocked - conditions not met',
          name: 'LoginScreen',
          level: 900,
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    if (kDebugMode) {
      developer.log('🍎 Starting Apple login...', name: 'LoginScreen');
    }

    try {
      final notifier = ref.read(authNotifierProvider.notifier);

      if (kDebugMode) {
        developer.log('🔄 Calling notifier.loginWithApple()...', name: 'LoginScreen');
      }

      final isFirstLogin = await notifier.loginWithApple(
        agreedToTerms: _agreedToTerms,
        agreedToPrivacy: _agreedToPrivacy,
      );

      if (kDebugMode) {
        developer.log(
          '✅ Login completed. First login: $isFirstLogin',
          name: 'LoginScreen',
        );
      }

      if (!mounted) {
        if (kDebugMode) {
          developer.log('⚠️ Widget unmounted', name: 'LoginScreen', level: 900);
        }
        return;
      }

      // Verify auth state before navigation
      final authState = ref.read(authNotifierProvider);

      // Check for errors first (before accessing value)
      if (authState.hasError) {
        if (kDebugMode) {
          authState.whenOrNull(
            error: (error, stack) {
              developer.log(
                '❌ Auth state has error after login',
                name: 'LoginScreen',
                error: error,
                stackTrace: stack,
                level: 1000,
              );
            },
          );
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.auth_login_error_failed),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Safe to access value now (no error)
      final user = authState.asData?.value;

      if (user == null) {
        if (kDebugMode) {
          developer.log(
            '❌ User is null after login',
            name: 'LoginScreen',
            level: 1000,
          );
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.auth_login_error_userInfoFailed),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (kDebugMode) {
        developer.log(
          '✅ Auth state verified. User: ${user.id}',
          name: 'LoginScreen',
        );
      }

      if (mounted) {
        if (isFirstLogin) {
          if (kDebugMode) {
            developer.log('🚀 Navigating to onboarding...', name: 'LoginScreen');
          }
          context.go('/onboarding', extra: user.id);
        } else {
          if (kDebugMode) {
            developer.log('🏠 Navigating to home dashboard...', name: 'LoginScreen');
          }
          context.go('/home');
        }
      }
    } on OAuthCancelledException catch (e, stack) {
      if (kDebugMode) {
        developer.log(
          '🚫 OAuth cancelled by user',
          name: 'LoginScreen',
          error: e,
          stackTrace: stack,
          level: 900,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.auth_login_error_cancelled),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } on MaxRetriesExceededException catch (e, stack) {
      if (kDebugMode) {
        developer.log(
          '🌐 Network error - max retries exceeded',
          name: 'LoginScreen',
          error: e,
          stackTrace: stack,
          level: 1000,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.auth_login_error_networkWithRetry),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: context.l10n.auth_login_error_retryButton,
              textColor: Colors.white,
              onPressed: () => _handleAppleLogin(),
            ),
          ),
        );
      }
    } catch (e, stack) {
      if (kDebugMode) {
        developer.log(
          '❌ Unexpected error during Apple login',
          name: 'LoginScreen',
          error: e,
          stackTrace: stack,
          level: 1000,
        );
      }
      // Apple 로그인 취소 시 에러 메시지 표시 안 함
      if (e.toString().contains('cancelled')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.auth_login_error_cancelled),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.auth_login_error_unknown(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        if (kDebugMode) {
          developer.log('🏁 Apple login process completed', name: 'LoginScreen');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Hero Section with Gabium branding
                Builder(
                  builder: (context) => AuthHeroSection(
                    title: context.l10n.auth_login_heroTitle,
                    subtitle: context.l10n.auth_login_heroSubtitle,
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Consent Section (Card-like background)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    border: Border.all(
                      color: AppColors.border,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neutral900.withValues(alpha: 0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Builder(
                        builder: (context) => ConsentCheckbox(
                          key: const Key('terms_checkbox'),
                          label: context.l10n.auth_login_consentTerms,
                          isRequired: true,
                          value: _agreedToTerms,
                          onChanged: _isLoading
                              ? (val) {}
                              : (val) {
                                  setState(() => _agreedToTerms = val);
                                },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Builder(
                        builder: (context) => ConsentCheckbox(
                          key: const Key('privacy_checkbox'),
                          label: context.l10n.auth_login_consentPrivacy,
                          isRequired: true,
                          value: _agreedToPrivacy,
                          onChanged: _isLoading
                              ? (val) {}
                              : (val) {
                                  setState(() => _agreedToPrivacy = val);
                                },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Helper Text Alert (if agreements not complete)
                if (!_canLogin && !_isLoading)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.08),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.warning,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Builder(
                            builder: (context) => Text(
                              context.l10n.auth_login_consentRequired,
                              style: AppTypography.bodyLarge.copyWith(
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // 4. Social Login Buttons
                // Apple 로그인 버튼 (iOS/macOS only, 상단에 배치)
                if (Platform.isIOS || Platform.isMacOS) ...[
                  Builder(
                    builder: (context) => SocialLoginButton(
                      key: const Key('apple_login_button'),
                      label: context.l10n.auth_login_appleButton,
                      icon: Icons.apple,
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      isLoading: _isLoading,
                      onPressed: _canLogin ? _handleAppleLogin : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Builder(
                  builder: (context) => SocialLoginButton(
                    key: const Key('kakao_login_button'),
                    label: context.l10n.auth_login_kakaoButton,
                    icon: Icons.chat_bubble,
                    backgroundColor: const Color(0xFFFEE500),
                    foregroundColor: Colors.black87,
                    isLoading: _isLoading,
                    onPressed: _canLogin ? _handleKakaoLogin : null,
                  ),
                ),
                const SizedBox(height: 8),
                Builder(
                  builder: (context) => SocialLoginButton(
                    key: const Key('naver_login_button'),
                    label: context.l10n.auth_login_naverButton,
                    icon: Icons.language,
                    backgroundColor: const Color(0xFF03C75A),
                    foregroundColor: Colors.white,
                    isLoading: _isLoading,
                    onPressed: _canLogin ? _handleNaverLogin : null,
                  ),
                ),

                const SizedBox(height: 24),

                // 5. Email Section Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        height: 1,
                        color: AppColors.border,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Builder(
                        builder: (context) => Text(
                          context.l10n.auth_login_divider,
                          style: AppTypography.bodySmall,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        height: 1,
                        color: AppColors.border,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 6. Email Section Label
                Builder(
                  builder: (context) => Text(
                    context.l10n.auth_login_otherOptions,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.neutral700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Email Login Button
                Builder(
                  builder: (context) => OutlinedButton.icon(
                    key: const Key('email_login_button'),
                    onPressed: () => context.go('/email-signin'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.email_outlined),
                    label: Text(
                      context.l10n.auth_login_emailButton,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Email Signup Button (consistent with login)
                Builder(
                  builder: (context) => OutlinedButton.icon(
                    key: const Key('email_signup_link'),
                    onPressed: () => context.go('/email-signup'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.person_add_outlined),
                    label: Text(
                      context.l10n.auth_login_emailSignupButton,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
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
