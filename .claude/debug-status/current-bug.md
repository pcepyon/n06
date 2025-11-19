---
status: VERIFIED
timestamp: 2025-11-19T10:30:00+09:00
bug_id: BUG-2025-1119-001
verified_by: error-verifier
severity: High
---

# 버그 검증 완료 보고서

## 버그 요약

**현상**: 이메일 회원가입/로그인 기능 추가 후 로그인 시 화면 전환이 발생하지 않음

**근본 원인**: `EmailSigninScreen`에서 로그인 성공 후 명시적 화면 전환 로직 누락

**영향도**: High - 이메일 로그인 사용자가 로그인 후 대시보드로 이동할 수 없음

---

## 재현 결과

### 재현 성공 여부: 예 (코드 분석을 통한 검증)

### 재현 단계:
1. 앱 실행 (로그인 화면 표시)
2. "Email로 로그인" 버튼 클릭
3. `EmailSigninScreen`으로 이동
4. 유효한 이메일/비밀번호 입력
5. "Sign In" 버튼 클릭
6. 로그인 성공 후 "Sign in successful!" 스낵바만 표시됨
7. **화면 전환 없음** - 여전히 로그인 화면에 머물러 있음

### 예상 동작 vs 실제 동작:

**예상 동작**:
1. 로그인 성공 시 `authNotifier.signInWithEmail()` 호출
2. `AuthNotifier.state`가 `AsyncValue.data(user)`로 업데이트
3. 자동으로 `/home` 대시보드로 리다이렉트

**실제 동작**:
1. 로그인 성공 시 `authNotifier.signInWithEmail()` 호출 ✅
2. `AuthNotifier.state`가 `AsyncValue.data(user)`로 업데이트 ✅
3. **화면 전환 로직이 없음** ❌ - TODO 주석만 존재

---

## 영향도 평가

### 심각도: High
- **기능 완전 차단**: 이메일 로그인 사용자는 로그인 후 앱을 사용할 수 없음
- **사용자 경험 심각 손상**: 로그인 버튼을 눌러도 아무 반응이 없음

### 영향 범위:
- **직접 영향**: 
  - `lib/features/authentication/presentation/screens/email_signin_screen.dart` (Line 53-59)
  - 이메일 로그인을 시도하는 모든 사용자

- **간접 영향**:
  - 소셜 로그인 (Kakao/Naver)은 영향 받지 않음 (별도 화면 전환 로직 보유)
  - 회원가입 기능도 동일한 문제 가능성 있음

### 사용자 영향:
- 이메일 인증 방식으로 가입한 모든 신규/기존 사용자
- Phase 1 Supabase 전환 시 이메일 인증이 주요 방식이므로 **Critical**

### 발생 빈도: 항상 (100% 재현)

---

## 수집된 증거

### 버그 발생 코드:

**파일**: `lib/features/authentication/presentation/screens/email_signin_screen.dart`

```dart
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
        // Navigate to dashboard
        // TODO: Navigate to dashboard  ⬅️ ❌ 구현 누락!
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in failed')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in error: $e')),
      );
    }
  }
```

**라인 58**: `// TODO: Navigate to dashboard` 주석만 있고 실제 네비게이션 코드 없음

---

### 정상 동작하는 참조 코드 (LoginScreen - Kakao/Naver 로그인):

**파일**: `lib/features/authentication/presentation/screens/login_screen.dart`

```dart
  Future<void> _handleKakaoLogin() async {
    // ... (로그인 로직 생략)

    try {
      final notifier = ref.read(authNotifierProvider.notifier);
      final isFirstLogin = await notifier.loginWithKakao(
        agreedToTerms: _agreedToTerms,
        agreedToPrivacy: _agreedToPrivacy,
      );

      // ... (에러 체크 생략)

      if (mounted) {
        if (isFirstLogin) {
          if (kDebugMode) {
            developer.log('🚀 Navigating to onboarding...', name: 'LoginScreen');
          }
          context.go('/onboarding', extra: user.id);  ✅ 명시적 화면 전환
        } else {
          if (kDebugMode) {
            developer.log('🏠 Navigating to home dashboard...', name: 'LoginScreen');
          }
          context.go('/home');  ✅ 명시적 화면 전환
        }
      }
    } catch (e) {
      // 에러 처리
    }
  }
```

**차이점**: 소셜 로그인은 `context.go('/onboarding')` 또는 `context.go('/home')`을 명시적으로 호출하여 화면 전환

---

### AuthNotifier 로직 확인:

**파일**: `lib/features/authentication/application/notifiers/auth_notifier.dart`

```dart
  /// Sign in with email and password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (kDebugMode) {
      developer.log(
        'signInWithEmail called (email: $email)',
        name: 'AuthNotifier',
      );
    }

    state = const AsyncValue.loading();

    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.signInWithEmail(
        email: email,
        password: password,
      );

      state = AsyncValue.data(user);  ✅ 상태 업데이트 정상

      if (kDebugMode) {
        developer.log(
          'Sign in successful: ${user.id}',
          name: 'AuthNotifier',
        );
      }

      return true;  ✅ 성공 반환
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);

      if (kDebugMode) {
        developer.log(
          'Sign in failed',
          name: 'AuthNotifier',
          error: error,
          stackTrace: stackTrace,
          level: 1000,
        );
      }

      return false;  ❌ 실패 반환
    }
  }
```

**분석**: `AuthNotifier.signInWithEmail()`은 정상 동작하며 성공 시 `true`, 실패 시 `false` 반환

---

### GoRouter 라우팅 설정 확인:

**파일**: `lib/core/routing/app_router.dart`

```dart
final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeDashboardScreen(),
    ),
    GoRoute(
      path: '/email-signin',
      name: 'email_signin',
      builder: (context, state) => const EmailSigninScreen(),
    ),
    // ... 기타 라우트
  ],
);
```

**분석**: `/home` 라우트는 정상 등록되어 있음 - 라우팅 설정 문제 없음

---

## 추가 발견사항

### EmailSignupScreen도 동일 문제 보유:

**파일**: `lib/features/authentication/presentation/screens/email_signup_screen.dart` (추정)

회원가입 화면도 동일한 패턴으로 TODO 주석만 있을 가능성이 높음 (추가 검증 필요)

---

## 버그 원인 분석

### 직접 원인:
1. `EmailSigninScreen._handleSignin()` 메서드에서 로그인 성공 시 화면 전환 코드 누락
2. TODO 주석만 남아 있고 실제 구현이 완료되지 않음

### 근본 원인:
1. **구현 불완전**: F-016 이메일 인증 기능 개발 시 네비게이션 로직 미완성
2. **테스트 부재**: 통합 테스트가 없어 로그인 → 대시보드 플로우 검증 안 됨
3. **코드 리뷰 누락**: TODO 주석이 PR에서 그대로 머지됨

### 설계 결함 가능성:
- 소셜 로그인과 이메일 로그인의 플로우 차이:
  - **소셜 로그인**: `isFirstLogin` 체크 후 `/onboarding` 또는 `/home`으로 분기
  - **이메일 로그인**: `isFirstLogin` 체크 없이 무조건 `/home`으로 이동해야 함 (회원가입 직후는 별도 처리)

---

## 재현 환경

### 환경 확인 결과:
- **Flutter 버전**: 3.38.1 (Stable, 2025-11-12)
- **Dart 버전**: 3.10.0
- **플랫폼**: macOS Darwin 24.6.0
- **GoRouter**: 설치됨 (app_router.dart 확인)
- **Riverpod**: 설치됨 (ConsumerState 사용 확인)

### 최근 변경사항:
```
f720db2 docs: BUG-2025-1116-001 수정 및 검증 완료 보고서
63dd860 fix(BUG-2025-1116-001): UserProfileDto 스키마 불일치 해결
e486c86 test: add failing tests for BUG-2025-1116-001 (UserProfileDto schema mismatch)
f1859b4 fix: Supabase 신규 사용자 등록 RLS 오류 해결
9fb64ef test: 테스트 유지보수 및 정리 작업 완료
```

**분석**: 최근 커밋은 다른 버그(UserProfileDto 스키마) 수정이며, 이메일 로그인 버그와는 무관

---

## Quality Gate 1 체크리스트

- [x] 버그 재현 성공 (코드 분석을 통한 논리적 재현)
- [x] 에러 메시지 완전 수집 (에러는 없고 기능 누락)
- [x] 영향 범위 명확히 식별 (EmailSigninScreen, 추가로 EmailSignupScreen 가능성)
- [x] 증거 충분히 수집 (코드 스니펫, 비교 분석 완료)
- [x] 한글 문서 완성

---

## 다음 단계

### Root Cause Analyzer에게 전달할 정보:

1. **버그 위치**: `lib/features/authentication/presentation/screens/email_signin_screen.dart:58`
2. **문제 유형**: 기능 구현 누락 (TODO 미완성)
3. **수정 방향**: 
   - 소셜 로그인 패턴 참조하여 `context.go('/home')` 추가
   - `isFirstLogin` 체크 필요 여부 검토 (회원가입 직후 vs 재로그인 구분)
4. **추가 검증 필요**: `EmailSignupScreen`도 동일 문제 보유 여부 확인

---

## 권장 수정 방안 (Root Cause Analyzer가 검토할 사항)

### Option 1: 간단 수정 (이메일 로그인은 항상 /home으로)

```dart
if (success) {
  if (!mounted) return;
  
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Sign in successful!')),
  );
  
  // Navigate to dashboard
  context.go('/home');
}
```

### Option 2: 소셜 로그인과 동일한 플로우 (isFirstLogin 체크)

```dart
if (success) {
  if (!mounted) return;
  
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Sign in successful!')),
  );
  
  // Check if first login (onboarding needed)
  final authState = ref.read(authProvider);
  final user = authState.asData?.value;
  
  if (user != null) {
    final repository = ref.read(authRepositoryProvider);
    final isFirstLogin = await repository.isFirstLogin();
    
    if (isFirstLogin) {
      context.go('/onboarding', extra: user.id);
    } else {
      context.go('/home');
    }
  }
}
```

**권장**: Option 1 (이메일 로그인은 재로그인 케이스만 존재, 회원가입 직후는 EmailSignupScreen에서 처리)

---

## 참조 문서

- **아키텍처 가이드**: `/Users/pro16/Desktop/project/n06/CLAUDE.md`
- **소셜 로그인 구현 가이드**: `/Users/pro16/Desktop/project/n06/docs/external/flutter_kakao_gorouter_guide.md`
- **GoRouter 설정**: `/Users/pro16/Desktop/project/n06/lib/core/routing/app_router.dart`

---

**검증자**: error-verifier (Claude Code Agent)
**검증 일시**: 2025-11-19 10:30 KST
**다음 에이전트**: root-cause-analyzer
