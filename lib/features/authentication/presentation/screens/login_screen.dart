import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
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
            const SnackBar(
              content: Text('로그인에 실패했습니다. 다시 시도해주세요.'),
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
            const SnackBar(
              content: Text('로그인 정보를 가져올 수 없습니다.'),
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
          const SnackBar(
            content: Text('로그인이 취소되었습니다. 다시 시도해주세요.'),
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
            content: const Text('네트워크 연결을 확인해주세요.'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: '재시도',
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
            content: Text('로그인 중 오류가 발생했습니다: $e'),
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
            const SnackBar(
              content: Text('로그인에 실패했습니다. 다시 시도해주세요.'),
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
            const SnackBar(
              content: Text('로그인 정보를 가져올 수 없습니다.'),
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
          const SnackBar(
            content: Text('로그인이 취소되었습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } on MaxRetriesExceededException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('네트워크 연결을 확인해주세요.'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: '재시도',
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
            content: Text('로그인 중 오류가 발생했습니다: $e'),
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
                const AuthHeroSection(
                  title: '가비움',
                  subtitle: 'GLP-1 치료를 체계적으로 관리하세요',
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
                      ConsentCheckbox(
                        key: const Key('terms_checkbox'),
                        label: '이용약관에 동의합니다',
                        isRequired: true,
                        value: _agreedToTerms,
                        onChanged: _isLoading
                            ? (val) {}
                            : (val) {
                                setState(() => _agreedToTerms = val);
                              },
                      ),
                      const SizedBox(height: 16),
                      ConsentCheckbox(
                        key: const Key('privacy_checkbox'),
                        label: '개인정보처리방침에 동의합니다',
                        isRequired: true,
                        value: _agreedToPrivacy,
                        onChanged: _isLoading
                            ? (val) {}
                            : (val) {
                                setState(() => _agreedToPrivacy = val);
                              },
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
                          child: Text(
                            '소셜 로그인하려면 약관에 모두 동의해주세요',
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // 4. Social Login Buttons
                SocialLoginButton(
                  key: const Key('kakao_login_button'),
                  label: '카카오 로그인',
                  icon: Icons.chat_bubble,
                  backgroundColor: const Color(0xFFFEE500),
                  foregroundColor: Colors.black87,
                  isLoading: _isLoading,
                  onPressed: _canLogin ? _handleKakaoLogin : null,
                ),
                const SizedBox(height: 8),
                SocialLoginButton(
                  key: const Key('naver_login_button'),
                  label: '네이버 로그인',
                  icon: Icons.language,
                  backgroundColor: const Color(0xFF03C75A),
                  foregroundColor: Colors.white,
                  isLoading: _isLoading,
                  onPressed: _canLogin ? _handleNaverLogin : null,
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
                      child: Text(
                        '또는',
                        style: AppTypography.bodySmall,
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
                Text(
                  '다른 계정으로 계속하기',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.neutral700,
                  ),
                ),
                const SizedBox(height: 12),

                // Email Login Button
                OutlinedButton.icon(
                  key: const Key('email_login_button'),
                  onPressed: () => context.go('/email-signin'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.email_outlined),
                  label: Text(
                    '이메일로 로그인',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Email Signup Button (consistent with login)
                OutlinedButton.icon(
                  key: const Key('email_signup_link'),
                  onPressed: () => context.go('/email-signup'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.person_add_outlined),
                  label: Text(
                    '이메일로 회원가입',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.primary,
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
