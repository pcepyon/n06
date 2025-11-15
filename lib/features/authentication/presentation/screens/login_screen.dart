import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/authentication/domain/exceptions/auth_exceptions.dart';

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
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'GLP-1 치료 관리',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '안전하고 효과적인 치료를 위해',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 48),

              // Terms checkboxes
              CheckboxListTile(
                key: const Key('terms_checkbox'),
                title: const Text('이용약관 동의 (필수)'),
                value: _agreedToTerms,
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() => _agreedToTerms = value ?? false);
                      },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                key: const Key('privacy_checkbox'),
                title: const Text('개인정보처리방침 동의 (필수)'),
                value: _agreedToPrivacy,
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() => _agreedToPrivacy = value ?? false);
                      },
                controlAffinity: ListTileControlAffinity.leading,
              ),

              const SizedBox(height: 32),

              // Kakao Login Button
              ElevatedButton.icon(
                key: const Key('kakao_login_button'),
                onPressed: _canLogin ? _handleKakaoLogin : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEE500),
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black87,
                        ),
                      )
                    : const Icon(Icons.chat_bubble),
                label: const Text(
                  '카카오 로그인',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Naver Login Button
              ElevatedButton.icon(
                key: const Key('naver_login_button'),
                onPressed: _canLogin ? _handleNaverLogin : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF03C75A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.language),
                label: const Text(
                  '네이버 로그인',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Helper text
              if (!_canLogin && !_isLoading)
                const Text(
                  '로그인하려면 약관에 동의해주세요',
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
