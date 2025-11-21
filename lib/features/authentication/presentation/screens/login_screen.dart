import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/authentication/domain/exceptions/auth_exceptions.dart';
import 'package:n06/core/theme/app_colors.dart';
import 'package:n06/core/theme/app_text_styles.dart';
import 'package:n06/core/widgets/app_button.dart';

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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo or Title
              const Icon(
                Icons.medication,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              const Text(
                'GLP-1 치료 관리',
                textAlign: TextAlign.center,
                style: AppTextStyles.h1,
              ),
              const SizedBox(height: 8),
              Text(
                '안전하고 효과적인 치료를 위해',
                textAlign: TextAlign.center,
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.gray,
                ),
              ),
              const SizedBox(height: 48),

              // Terms checkboxes
              CheckboxListTile(
                key: const Key('terms_checkbox'),
                title: const Text('이용약관 동의 (필수)', style: AppTextStyles.body2),
                value: _agreedToTerms,
                activeColor: AppColors.primary,
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() => _agreedToTerms = value ?? false);
                      },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                key: const Key('privacy_checkbox'),
                title: const Text('개인정보처리방침 동의 (필수)', style: AppTextStyles.body2),
                value: _agreedToPrivacy,
                activeColor: AppColors.primary,
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() => _agreedToPrivacy = value ?? false);
                      },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 32),

              // Kakao Login Button
              AppButton(
                text: '카카오 로그인',
                onPressed: _canLogin ? _handleKakaoLogin : null,
                type: AppButtonType.primary,
                backgroundColor: const Color(0xFFFEE500),
                textColor: Colors.black87,
                icon: Icons.chat_bubble,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 12),

              // Naver Login Button
              AppButton(
                text: '네이버 로그인',
                onPressed: _canLogin ? _handleNaverLogin : null,
                type: AppButtonType.primary,
                backgroundColor: const Color(0xFF03C75A),
                textColor: Colors.white,
                icon: Icons.language,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 24),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '또는',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),

              const SizedBox(height: 24),

              // Email Login Button
              AppButton(
                text: '이메일로 로그인',
                onPressed: () => context.go('/email-signin'),
                type: AppButtonType.outline,
                icon: Icons.email_outlined,
              ),

              const SizedBox(height: 12),

              // Email Signup Link
              AppButton(
                text: '이메일로 회원가입',
                onPressed: () => context.go('/email-signup'),
                type: AppButtonType.ghost,
              ),

              const SizedBox(height: 24),

              // Helper text
              if (!_canLogin && !_isLoading)
                const Text(
                  '소셜 로그인하려면 약관에 동의해주세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
