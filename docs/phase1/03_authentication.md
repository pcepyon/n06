# Phase 1.3: 인증 시스템 전환 (LTS 가이드 반영)

**목표**: 자체 OAuth에서 Supabase Auth로 전환, Naver Edge Function 구현
**소요 기간**: 1주
**담당**: Backend 엔지니어
**기준 문서**: `docs/external/flutter_kakao_gorouter_guide.md`

> **중요**: 이 문서는 `flutter_kakao_gorouter_guide.md`의 최신 가이드를 반영하여 수정되었습니다. 기존 웹 기반 OAuth 흐름 대신 네이티브 앱에 최적화된 토큰 기반 인증 방식을 사용합니다.

---

## 1. Supabase Auth 개요

### 1.1 변경 사항

**Before (Phase 0)**:
- 자체 OAuth 구현
- `flutter_secure_storage`로 토큰 관리
- 수동 토큰 갱신

**After (Phase 1)**:
- Supabase Auth 사용
- **네이티브 SDK(카카오)와 Supabase `signInWithIdToken` 연동**
- 토큰 자동 관리 (Supabase)
- RLS와 통합

### 1.2 지원하는 인증 방식

| 인증 방식 | Supabase 네이티브 지원 | 구현 방법 |
|----------|---------------------|----------|
| **Kakao OAuth** | ✅ `id_token` 방식 지원 | `kakao_flutter_sdk` + `signInWithIdToken()` |
| **Naver OAuth** | ❌ 미지원 | Edge Function |
| **Email/Password**| ✅ 지원 | `signInWithPassword()` |

---

## 2. 네이티브 플랫폼 설정 (필수)

**가장 중요한 단계입니다.** 소셜 로그인이 네이티브 앱에서 정상적으로 동작하려면, 반드시 플랫폼별 설정을 완료해야 합니다.

**상세 설정은 반드시 `docs/external/flutter_kakao_gorouter_guide.md` 문서를 따르세요.**

### 2.1 Android 설정 (`AndroidManifest.xml`)
- `AuthCodeCustomTabsActivity`를 선언해야 합니다.
- 카카오 SDK용 `intent-filter`를 `kakao{NATIVE_APP_KEY}` 스킴으로 설정해야 합니다.
- `android:exported="true"` 속성을 올바르게 사용해야 합니다.

### 2.2 iOS 설정 (`Info.plist`)
- `CFBundleURLTypes`에 `kakao{NATIVE_APP_KEY}` 스킴을 추가해야 합니다.
- `LSApplicationQueriesSchemes`에 `kakaokompassauth`를 추가하여 카카오톡 앱을 호출할 수 있도록 해야 합니다.

> **경고**: 이 설정을 누락하면 카카오 로그인이 동작하지 않거나, 웹뷰로만 동작하여 사용자 경험이 크게 저하됩니다.

---

## 3. SupabaseAuthRepository 구현

### 3.1 파일 생성

**파일 위치**: `/Users/pro16/Desktop/project/n06/lib/features/authentication/infrastructure/repositories/supabase_auth_repository.dart`

**새 파일 생성**:
```dart
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_auth;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao_sdk;
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart' as app_user;

class SupabaseAuthRepository implements AuthRepository {
  final supabase_auth.SupabaseClient _supabase;

  SupabaseAuthRepository(this._supabase);

  // ============================================
  // Kakao OAuth (LTS 가이드 방식)
  // ============================================

  @override
  Future<app_user.User?> loginWithKakao({
    required bool agreedToTerms,
    required bool agreedToPrivacy,
  }) async {
    try {
      // 1. Kakao SDK로 토큰 받기 (카카오톡 앱 우선)
      kakao_sdk.OAuthToken kakaoToken;
      if (await kakao_sdk.isKakaoTalkInstalled()) {
        try {
          kakaoToken = await kakao_sdk.UserApi.instance.loginWithKakaoTalk();
        } catch (error) {
          // 카카오톡 로그인 실패 시 웹으로 폴백
          kakaoToken = await kakao_sdk.UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        kakaoToken = await kakao_sdk.UserApi.instance.loginWithKakaoAccount();
      }

      if (kakaoToken.idToken == null) {
        throw Exception('Kakao login failed: ID token is missing.');
      }

      // 2. Supabase에 ID 토큰으로 로그인
      final response = await _supabase.auth.signInWithIdToken(
        provider: supabase_auth.OAuthProvider.kakao,
        idToken: kakaoToken.idToken!,
        accessToken: kakaoToken.accessToken,
      );

      final authUser = response.user;
      if (authUser == null) return null;

      // 3. public.users 테이블에 프로필 생성/업데이트
      await _createOrUpdateUserProfile(authUser);

      // 4. 동의 기록 저장
      await _saveConsentRecord(authUser.id, agreedToTerms, agreedToPrivacy);

      // 5. app_user.User로 변환
      return await _mapToAppUser(authUser);
    } catch (e) {
      throw Exception('Kakao login failed: $e');
    }
  }

  // ============================================
  // Naver OAuth (Edge Function)
  // ============================================

  // Naver 로그인은 Presentation Layer에서 인증 URL을 열고,
  // GoRouter로 딥링크 콜백을 받아 아래 메서드를 호출합니다.
  
  @override
  Future<app_user.User?> loginWithNaverCallback({
    required String code,
    required bool agreedToTerms,
    required bool agreedToPrivacy,
  }) async {
    try {
      // 1. Edge Function으로 code 전달하여 사용자 정보 받기
      final response = await _supabase.functions.invoke(
        'naver-auth',
        body: {
          'action': 'callback',
          'code': code,
        },
      );

      final sessionData = response.data;

      // 2. Supabase Session 설정
      await _supabase.auth.setSession(sessionData['access_token']);

      final authUser = _supabase.auth.currentUser;
      if (authUser == null) return null;

      // 3. public.users 테이블에 프로필 생성
      await _createOrUpdateUserProfile(authUser);

      // 4. 동의 기록 저장
      await _saveConsentRecord(authUser.id, agreedToTerms, agreedToPrivacy);

      // 5. app_user.User로 변환
      return await _mapToAppUser(authUser);
    } catch (e) {
      throw Exception('Naver callback failed: $e');
    }
  }

  // ... (Email/Password, Logout, GetCurrentUser 등 나머지 코드는 기존과 거의 동일) ...
  // ... (Helper Methods _createOrUpdateUserProfile, _saveConsentRecord, _mapToAppUser 등도 동일) ...
}
```

### 3.2 AuthNotifier 수정
`AuthNotifier`의 `loginWithKakao`는 그대로 유지하되, `loginWithNaver`는 삭제하고 `loginWithNaverCallback`을 사용하도록 명확히 합니다.

---

## 4. Naver OAuth Edge Function

Naver OAuth를 위한 Edge Function 구현은 기존 계획을 유지합니다. 클라이언트에서 인증 URL을 받아 브라우저를 열고, 앱 딥링크로 콜백을 받는 흐름은 유효합니다.

**파일 위치**: `/Users/pro16/Desktop/project/n06/supabase/functions/naver-auth/index.ts`
(기존 코드 유지)

---

## 5. 딥링크 설정 및 처리

### 5.1 딥링크 스킴
- **Kakao**: `kakao{NATIVE_APP_KEY}://oauth` (SDK가 처리)
- **Naver**: `n06://naver-callback` (앱이 직접 처리)

### 5.2 딥링크 처리 (GoRouter)
**`uni_links` 패키지는 사용하지 않습니다.** `GoRouter`는 자체적으로 딥링크를 처리할 수 있습니다.

**라우터 설정 예시**:
```dart
// lib/core/routing/app_router.dart
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      // ... 다른 라우트들
      GoRoute(
        path: '/naver-callback', // `n06://naver-callback`에 매칭
        name: 'naver-callback',
        builder: (context, state) {
          final code = state.uri.queryParameters['code'];
          if (code != null) {
            // AuthNotifier를 통해 로그인 처리
            ref.read(authNotifierProvider.notifier).loginWithNaverCallback(
              code: code,
              agreedToTerms: true, // 이전 화면에서 받은 값
              agreedToPrivacy: true,
            );
            return const ProcessingLoginScreen(); // 로그인 처리 중 화면
          }
          return const LoginErrorScreen(); // 에러 화면
        },
      ),
    ],
    // ...
  );
});
```
> **참고**: `path`를 `/naver-callback`으로 설정하면 `n06://naver-callback` 형태의 딥링크를 처리할 수 있습니다. `GoRouter`가 스킴(`n06://`) 이후의 경로를 분석하기 때문입니다.

---

## 6. 로그인 화면 수정

### 6.1 Naver 로그인 버튼
`url_launcher`를 사용하여 Edge Function에서 받은 인증 URL을 여는 방식은 그대로 유지합니다. 콜백 처리는 위에서 설명한 GoRouter가 담당합니다.

---

## 7. 테스트

### 7.1 Kakao 로그인 테스트
- **시나리오**:
  1. "카카오 로그인" 버튼 클릭
  2. **카카오톡 앱이 열리거나 웹뷰가 뜨는지 확인**
  3. 로그인 후 앱으로 정상적으로 돌아오는지 확인
  4. Supabase `auth.users` 테이블에 사용자 생성 확인

### 7.2 Naver 로그인 테스트
- **시나리오**:
  1. "네이버 로그인" 버튼 클릭
  2. 브라우저로 네이버 로그인 페이지 열림
  3. 로그인 후 **`n06://naver-callback?code=...` 딥링크로 앱이 다시 열리는지 확인**
  4. GoRouter가 콜백을 처리하여 로그인 완료되는지 확인

---

## 8. 다음 단계

✅ Phase 1.3 수정 완료 후:
- **[Phase 1.4: 데이터 마이그레이션](./04_migration.md)** 문서로 이동하세요.
