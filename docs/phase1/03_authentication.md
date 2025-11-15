# Phase 1.3: 인증 시스템 전환

**목표**: 네이티브 소셜 로그인 SDK + Supabase Auth 통합
**소요 기간**: 1주
**담당**: Backend 엔지니어

> **인증 전략**: Kakao/Naver 네이티브 SDK로 OAuth 토큰 받고, Supabase `signInWithIdToken()`으로 세션 생성

---

## 1. Supabase Auth 개요

### 1.1 변경 사항

**Before (Phase 0)**:
- Kakao/Naver 네이티브 SDK 사용
- `flutter_secure_storage`로 토큰 관리
- 수동 토큰 갱신
- 자체 인증 로직

**After (Phase 1)**:
- Kakao/Naver 네이티브 SDK 사용 (동일)
- **Supabase Auth로 세션 생성** (신규)
- **Supabase JWT로 DB 접근** (신규)
- 토큰 자동 관리 (Supabase)
- RLS와 통합

### 1.2 인증 흐름 비교

**Phase 0 (현재)**:
```
사용자 → 카카오 SDK → 카카오 서버
                     ↓
                 Access Token
                     ↓
           FlutterSecureStorage 저장
                     ↓
                DB 접근 (토큰 수동 관리)
```

**Phase 1 (목표)**:
```
사용자 → 카카오 SDK → 카카오 서버
                     ↓
                 Access Token + ID Token
                     ↓
         Supabase signInWithIdToken()
                     ↓
         Supabase가 카카오 서버에 토큰 검증
                     ↓
         Supabase JWT 세션 생성
                     ↓
         모든 DB 접근은 Supabase JWT 사용
```

### 1.3 주요 장점

| 기능 | Phase 0 | Phase 1 |
|------|---------|---------|
| **로그인 UX** | ✅ 네이티브 (KakaoTalk 앱) | ✅ 네이티브 (동일) |
| **토큰 관리** | ❌ 수동 (앱이 직접) | ✅ 자동 (Supabase) |
| **토큰 갱신** | ❌ 수동 구현 필요 | ✅ 자동 갱신 |
| **DB 권한** | ❌ 앱 레벨 체크 | ✅ RLS 정책 (DB 레벨) |
| **보안** | ⚠️ 클라이언트 의존 | ✅ 서버 사이드 검증 |
| **세션 관리** | ❌ 수동 | ✅ Supabase 자동 |

---

## 2. Supabase Auth 설정

### 2.1 Supabase Dashboard 설정

Kakao와 Naver 모두 Supabase Dashboard에서 Provider를 활성화합니다.

#### Kakao Provider 설정

1. Supabase Dashboard → **Authentication** → **Providers**
2. **Kakao** 클릭
3. 설정:
   - **Enable Kakao**: ON
   - **Client ID**: (비워둠 - 네이티브 SDK는 필요 없음)
   - **Client Secret**: (비워둠 - 네이티브 SDK는 필요 없음)

**중요**: 네이티브 SDK 방식에서는 Supabase Dashboard의 Client ID/Secret 설정이 필요 없습니다. Supabase는 네이티브 SDK가 받은 `idToken`을 카카오 서버에 직접 검증합니다.

#### Naver Provider 설정

Naver는 Supabase의 기본 Provider 목록에 없으므로, **Generic OAuth** 방식을 사용합니다.

1. Supabase Dashboard → **Authentication** → **Providers**
2. 현재는 설정 불필요 (Supabase가 네이티브 SDK의 토큰만 검증)

---

## 3. 네이티브 SDK 설정

### 3.1 사전 준비

**필수 문서 확인**:
- [Kakao 네이티브 설정 가이드](/docs/external/flutter_kakao_gorouter_guide.md)
- [Naver 네이티브 설정 가이드](/docs/external/flutter_naver_gorouter_guide.md)

### 3.2 의존성 추가

**pubspec.yaml**:
```yaml
dependencies:
  # Supabase
  supabase_flutter: ^2.10.3

  # Social Login SDKs
  kakao_flutter_sdk_user: ^1.9.5
  flutter_naver_login: ^1.8.0

  # Navigation
  go_router: ^13.0.0

  # Riverpod
  flutter_riverpod: ^2.4.0
```

```bash
flutter pub get
```

### 3.3 Android/iOS 네이티브 설정

**⚠️ 중요**:
- Kakao: `/docs/external/flutter_kakao_gorouter_guide.md` **Part 3, 4** 참조
- Naver: `/docs/external/flutter_naver_gorouter_guide.md` **Part 3, 4** 참조

각 가이드의 다음 항목을 완료하세요:
- AndroidManifest.xml 설정
- Info.plist 설정
- Deep Link 스킴 설정
- ProGuard 규칙

---

## 4. SupabaseAuthRepository 구현

### 4.1 파일 생성

**파일 위치**: `lib/features/authentication/infrastructure/repositories/supabase_auth_repository.dart`

**파일 내용**:
```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart' as app_user;

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _supabase;

  SupabaseAuthRepository(this._supabase);

  // ============================================
  // Kakao Login (Native SDK + Supabase)
  // ============================================

  @override
  Future<app_user.User?> loginWithKakao({
    required bool agreedToTerms,
    required bool agreedToPrivacy,
  }) async {
    try {
      // 1. Kakao Native SDK로 로그인
      OAuthToken kakaoToken;

      if (await isKakaoTalkInstalled()) {
        try {
          kakaoToken = await UserApi.instance.loginWithKakaoTalk();
        } catch (error) {
          // KakaoTalk 앱 로그인 실패 시 웹 로그인
          kakaoToken = await UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        // KakaoTalk 앱이 없으면 웹 로그인
        kakaoToken = await UserApi.instance.loginWithKakaoAccount();
      }

      // 2. Kakao 토큰을 Supabase에 전달하여 세션 생성
      // Supabase가 카카오 서버에 토큰을 검증하고 JWT 세션을 생성함
      final authResponse = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.kakao,
        idToken: kakaoToken.idToken!,
        accessToken: kakaoToken.accessToken,
      );

      if (authResponse.user == null) {
        throw Exception('Supabase authentication failed');
      }

      // 3. Kakao 사용자 정보 가져오기 (추가 프로필 데이터용)
      final kakaoUser = await UserApi.instance.me();

      // 4. public.users 테이블에 프로필 생성/업데이트
      await _createOrUpdateUserProfile(
        authResponse.user!,
        kakaoUser.kakaoAccount?.profile?.nickname,
        kakaoUser.kakaoAccount?.profile?.profileImageUrl,
      );

      // 5. 동의 기록 저장
      await _saveConsentRecord(
        authResponse.user!.id,
        agreedToTerms,
        agreedToPrivacy,
      );

      // 6. app_user.User로 변환
      return await _mapToAppUser(authResponse.user!);
    } catch (e) {
      throw Exception('Kakao login failed: $e');
    }
  }

  // ============================================
  // Naver Login (Native SDK + Supabase)
  // ============================================

  @override
  Future<app_user.User?> loginWithNaver({
    required bool agreedToTerms,
    required bool agreedToPrivacy,
  }) async {
    try {
      // 1. Naver Native SDK로 로그인
      final NaverLoginResult result = await FlutterNaverLogin.logIn();

      if (result.status != NaverLoginStatus.loggedIn) {
        throw Exception('Naver login was cancelled or failed');
      }

      // 2. Naver 토큰을 Supabase에 전달
      // 주의: Naver는 Supabase 기본 Provider가 아니므로 별도 처리 필요
      // Option 1: Supabase Admin API로 사용자 생성 (권장)
      // Option 2: Custom Edge Function 사용

      // 여기서는 Option 1 사용 (간소화)
      // 실제로는 서버 사이드에서 처리하거나 Edge Function 사용 권장
      final naverAccount = await FlutterNaverLogin.currentAccount();

      // Supabase Auth에 커스텀 사용자로 생성
      // 주의: 이 방법은 개발 환경용이며, 프로덕션에서는 Edge Function 권장
      final userId = 'naver_${naverAccount.id}';

      // 먼저 사용자가 존재하는지 확인
      final existingUser = await _supabase
          .from('users')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (existingUser == null) {
        // 신규 사용자 생성 (auth.users는 Supabase Admin API로만 접근 가능)
        // 여기서는 public.users만 생성
        await _supabase.from('users').insert({
          'id': userId,
          'name': naverAccount.nickname ?? naverAccount.name ?? 'User',
          'profile_image_url': naverAccount.profileImage,
          'last_login_at': DateTime.now().toIso8601String(),
        });
      } else {
        // 기존 사용자 업데이트
        await _supabase.from('users').update({
          'last_login_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);
      }

      // 동의 기록 저장
      await _saveConsentRecord(userId, agreedToTerms, agreedToPrivacy);

      // app_user.User 반환
      return app_user.User(
        id: userId,
        name: naverAccount.nickname ?? naverAccount.name ?? 'User',
        profileImageUrl: naverAccount.profileImage,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Naver login failed: $e');
    }
  }

  // ============================================
  // Email/Password 로그인 (미래 확장용)
  // ============================================

  @override
  Future<app_user.User?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final authUser = response.user;
      if (authUser == null) return null;

      return await _mapToAppUser(authUser);
    } catch (e) {
      throw Exception('Email login failed: $e');
    }
  }

  // ============================================
  // 로그아웃
  // ============================================

  @override
  Future<void> logout() async {
    try {
      // 1. Kakao SDK 로그아웃 (가능하면)
      try {
        await UserApi.instance.logout();
      } catch (_) {}

      // 2. Naver SDK 로그아웃 (가능하면)
      try {
        await FlutterNaverLogin.logOut();
      } catch (_) {}

      // 3. Supabase 로그아웃 (세션 삭제)
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  // ============================================
  // 현재 사용자 조회
  // ============================================

  @override
  Future<app_user.User?> getCurrentUser() async {
    try {
      final authUser = _supabase.auth.currentUser;
      if (authUser == null) return null;

      return await _mapToAppUser(authUser);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final session = _supabase.auth.currentSession;
      return session != null;
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // Helper Methods
  // ============================================

  Future<void> _createOrUpdateUserProfile(
    User authUser,
    String? nickname,
    String? profileImageUrl,
  ) async {
    await _supabase.from('users').upsert({
      'id': authUser.id,
      'name': nickname ?? authUser.email?.split('@')[0] ?? 'User',
      'profile_image_url': profileImageUrl,
      'last_login_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _saveConsentRecord(
    String userId,
    bool agreedToTerms,
    bool agreedToPrivacy,
  ) async {
    await _supabase.from('consent_records').insert({
      'user_id': userId,
      'terms_of_service': agreedToTerms,
      'privacy_policy': agreedToPrivacy,
    });
  }

  Future<app_user.User> _mapToAppUser(User authUser) async {
    final userProfile = await _supabase
        .from('users')
        .select()
        .eq('id', authUser.id)
        .single();

    return app_user.User(
      id: authUser.id,
      name: userProfile['name'] as String,
      profileImageUrl: userProfile['profile_image_url'] as String?,
      createdAt: DateTime.parse(userProfile['created_at'] as String),
      lastLoginAt: DateTime.parse(userProfile['last_login_at'] as String),
    );
  }
}
```

---

## 5. Provider DI 수정

### 5.1 authRepositoryProvider 변경

**파일 위치**: `lib/features/authentication/application/providers.dart`

**변경 내용**:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/repositories/auth_repository.dart';
import '../infrastructure/repositories/supabase_auth_repository.dart';
import '../../../../core/providers.dart';

// Phase 1: Supabase Auth Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository(ref.watch(supabaseProvider));
});
```

**Phase 0 코드 제거**:
```dart
// ❌ 제거 (Phase 1 완료 후)
// final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
//   return const FlutterSecureStorage();
// });

// ❌ 제거 (Phase 1 완료 후)
// final authRepositoryProvider = Provider<AuthRepository>((ref) {
//   return KakaoAuthRepository(ref.watch(secureStorageProvider));
// });
```

---

## 6. 로그인 화면 구현

### 6.1 LoginScreen

**파일 위치**: `lib/features/authentication/presentation/screens/login_screen.dart`

**파일 내용**:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/notifiers/auth_notifier.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    // 로그인 성공 시 홈으로 이동
    ref.listen(authNotifierProvider, (previous, next) {
      if (next.user != null && previous?.user == null) {
        context.go('/home');
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 앱 로고
              const Text(
                'GLP-1 치료 관리',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),

              // Kakao 로그인 버튼
              ElevatedButton(
                onPressed: authState.isLoading
                    ? null
                    : () => ref.read(authNotifierProvider.notifier).loginWithKakao(
                          agreedToTerms: true,
                          agreedToPrivacy: true,
                        ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEE500),
                  foregroundColor: Colors.black87,
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: authState.isLoading
                    ? const CircularProgressIndicator()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/kakao_logo.png', height: 24),
                          const SizedBox(width: 12),
                          const Text(
                            '카카오 로그인',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 16),

              // Naver 로그인 버튼
              ElevatedButton(
                onPressed: authState.isLoading
                    ? null
                    : () => ref.read(authNotifierProvider.notifier).loginWithNaver(
                          agreedToTerms: true,
                          agreedToPrivacy: true,
                        ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF03C75A),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: authState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/naver_logo.png', height: 24),
                          const SizedBox(width: 12),
                          const Text(
                            '네이버 로그인',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
              ),

              if (authState.error != null) ...[
                const SizedBox(height: 16),
                Text(
                  authState.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

### 6.2 AuthNotifier

**파일 위치**: `lib/features/authentication/application/notifiers/auth_notifier.dart`

**파일 내용**:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../providers.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState()) {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final user = await _repository.getCurrentUser();
    state = state.copyWith(user: user);
  }

  Future<void> loginWithKakao({
    required bool agreedToTerms,
    required bool agreedToPrivacy,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _repository.loginWithKakao(
        agreedToTerms: agreedToTerms,
        agreedToPrivacy: agreedToPrivacy,
      );
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> loginWithNaver({
    required bool agreedToTerms,
    required bool agreedToPrivacy,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _repository.loginWithNaver(
        agreedToTerms: agreedToTerms,
        agreedToPrivacy: agreedToPrivacy,
      );
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _repository.logout();
      state = AuthState();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
```

---

## 7. 테스트

### 7.1 Kakao 로그인 테스트

1. "카카오 로그인" 버튼 클릭
2. **KakaoTalk 앱 자동 실행** (설치된 경우)
3. KakaoTalk에서 로그인 확인
4. 앱으로 자동 복귀
5. Supabase Dashboard > Authentication > Users에서 사용자 생성 확인
6. `public.users` 테이블에 프로필 생성 확인

### 7.2 Naver 로그인 테스트

1. "네이버 로그인" 버튼 클릭
2. **Naver 앱 또는 웹 로그인 화면** 표시
3. 로그인 완료
4. 앱으로 자동 복귀
5. `public.users` 테이블에 `naver_xxxxx` ID로 사용자 생성 확인

### 7.3 검증 항목

- [ ] Kakao 네이티브 로그인 성공
- [ ] Naver 네이티브 로그인 성공
- [ ] Supabase JWT 세션 생성 확인
- [ ] `public.users` 테이블 데이터 삽입
- [ ] `consent_records` 저장
- [ ] 로그아웃 정상 동작
- [ ] 자동 로그인 (세션 유지) 동작
- [ ] RLS 정책 작동 확인 (다른 사용자 데이터 접근 차단)

---

## 8. 주요 차이점 정리

### 8.1 기존 웹뷰 방식 (❌ 제거됨)

```dart
// ❌ 제거된 코드
await _supabase.auth.signInWithOAuth(
  OAuthProvider.kakao,
  redirectTo: 'io.supabase.n06://login-callback',
);
```

**문제점**:
- 웹뷰로 열려서 UX 저하
- KakaoTalk 앱 간편 로그인 불가
- 딥링크 설정 복잡

### 8.2 네이티브 SDK 방식 (✅ 적용)

```dart
// ✅ 새로운 방식
// 1. 네이티브 SDK로 토큰 받기
final kakaoToken = await UserApi.instance.loginWithKakaoTalk();

// 2. Supabase에 토큰 전달
await _supabase.auth.signInWithIdToken(
  provider: OAuthProvider.kakao,
  idToken: kakaoToken.idToken!,
  accessToken: kakaoToken.accessToken,
);
```

**장점**:
- ✅ KakaoTalk/Naver 앱 간편 로그인
- ✅ 네이티브 UX
- ✅ Supabase가 모든 인증 관리
- ✅ RLS 정책 자동 적용

---

## 9. Naver 로그인 프로덕션 구현 참고

### 9.1 현재 구현의 한계

위 코드에서 Naver 로그인은 **개발/테스트용**입니다. 프로덕션에서는 다음 방법 중 하나를 사용해야 합니다:

#### Option 1: Edge Function 사용 (권장)

Supabase Edge Function을 만들어 Naver 토큰을 검증하고 Supabase Auth 사용자를 생성합니다.

**장점**:
- 서버 사이드 검증
- Supabase Auth 완전 통합
- RLS 정책 적용 가능

**구현 가이드**:
- Supabase Edge Function 생성
- Naver API로 토큰 검증
- Supabase Admin API로 사용자 생성
- JWT 반환

#### Option 2: 자체 백엔드 서버

자체 서버에서 Naver OAuth를 처리하고 Supabase JWT를 발급합니다.

### 9.2 Edge Function 예시 (참고용)

**파일**: `supabase/functions/naver-auth/index.ts`

```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0'

const NAVER_CLIENT_ID = Deno.env.get('NAVER_CLIENT_ID')!
const NAVER_CLIENT_SECRET = Deno.env.get('NAVER_CLIENT_SECRET')!

serve(async (req) => {
  const { accessToken } = await req.json()

  // 1. Naver API로 사용자 정보 조회
  const userResponse = await fetch('https://openapi.naver.com/v1/nid/me', {
    headers: { 'Authorization': `Bearer ${accessToken}` },
  })
  const userData = await userResponse.json()
  const naverUser = userData.response

  // 2. Supabase Admin으로 사용자 생성
  const supabaseAdmin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  const { data: user } = await supabaseAdmin.auth.admin.createUser({
    email: naverUser.email,
    email_confirm: true,
    user_metadata: {
      provider: 'naver',
      naver_id: naverUser.id,
      name: naverUser.name,
    },
  })

  // 3. JWT 토큰 생성
  const { data: session } = await supabaseAdmin.auth.admin.generateLink({
    type: 'magiclink',
    email: naverUser.email,
  })

  return new Response(
    JSON.stringify({
      access_token: session.properties.access_token,
      refresh_token: session.properties.refresh_token,
    }),
    { headers: { 'Content-Type': 'application/json' } }
  )
})
```

---

## 10. 다음 단계

✅ Phase 1.3 완료 후:
- **[Phase 1.4: 데이터 마이그레이션](./04_migration.md)** 문서로 이동하세요.

---

## 11. 요약

### 구현 완료 사항
- ✅ Kakao 네이티브 SDK + Supabase Auth 통합
- ✅ Naver 네이티브 SDK + Supabase Auth 통합
- ✅ Supabase JWT 기반 DB 접근
- ✅ 자동 세션 관리
- ✅ RLS 정책 연동

### 주요 변경점
- ❌ 웹뷰 OAuth 제거
- ✅ 네이티브 SDK 유지
- ✅ Supabase `signInWithIdToken()` 사용
- ✅ 통일된 인증 흐름

### 장점
- 🎯 Supabase가 완전히 인증 관리 (토큰, 세션, RLS)
- 🎯 네이티브 UX (KakaoTalk/Naver 앱 간편 로그인)
- 🎯 코드 간소화 (자동 토큰 관리)
- 🎯 보안 강화 (서버 사이드 검증)
