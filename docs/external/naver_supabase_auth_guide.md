# 네이버 로그인 Supabase Auth 통합 가이드

## 개요

네이버는 OIDC(OpenID Connect)를 지원하지 않아 Supabase의 `signInWithIdToken()`을 사용할 수 없습니다. 이 문서는 Edge Function을 통한 **Admin Magic Link 패턴**으로 네이버 로그인을 Supabase Auth와 완전히 통합하는 방법을 설명합니다.

### 왜 이 방식이 필요한가?

| 인증 방식 | Kakao | Naver |
|----------|-------|-------|
| OIDC 지원 | ✅ 지원 | ❌ 미지원 |
| `signInWithIdToken()` | ✅ 사용 가능 | ❌ 사용 불가 |
| Supabase Auth 세션 | ✅ 자동 생성 | ❌ 별도 처리 필요 |
| RLS 정책 (`auth.uid()`) | ✅ 작동 | ❌ 작동 안함 (기존 방식) |

**기존 네이버 구현의 문제점:**
```dart
// 기존 방식: public.users에 직접 INSERT
final userId = 'naver_${naverAccount.id}';  // 커스텀 ID
await _supabase.from('users').insert({'id': userId, ...});

// 문제: auth.uid()가 null이므로 RLS 정책 미작동
// USING (auth.uid() = user_id) → 항상 false
```

---

## 아키텍처

### 인증 플로우

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Flutter   │────▶│  Naver SDK  │────▶│    Naver    │────▶│ Access Token│
│     App     │     │             │     │   Server    │     │   반환      │
└─────────────┘     └─────────────┘     └─────────────┘     └──────┬──────┘
                                                                    │
                                                                    ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Flutter   │◀────│   세션 설정   │◀────│ Edge Func  │◀────│ 토큰 검증   │
│  setSession │     │refresh_token│     │ naver-auth │     │ Naver API  │
└─────────────┘     └─────────────┘     └──────┬──────┘     └─────────────┘
                                               │
                          ┌────────────────────┼────────────────────┐
                          ▼                    ▼                    ▼
                   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
                   │ createUser  │     │generateLink │     │  verifyOtp  │
                   │ (Admin API) │     │ (magiclink) │     │ (세션 생성) │
                   └─────────────┘     └─────────────┘     └─────────────┘
```

### 핵심 패턴: Admin Magic Link

1. **Edge Function**에서 Admin API로 사용자 생성
2. **generateLink(magiclink)** 로 일회용 링크 생성
3. **verifyOtp(token_hash)** 로 즉시 세션 획득
4. **refresh_token**을 Flutter에 반환
5. Flutter에서 **setSession()** 으로 세션 설정

---

## 구현 상세

### 1. Edge Function (서버 측)

**파일 위치:** `supabase/functions/naver-auth/index.ts`

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  const { access_token, agreed_to_terms, agreed_to_privacy } = await req.json();

  // ============================================
  // STEP 1: Naver API로 토큰 검증 (보안 필수!)
  // ============================================
  const naverResponse = await fetch("https://openapi.naver.com/v1/nid/me", {
    headers: { Authorization: `Bearer ${access_token}` },
  });

  const naverData = await naverResponse.json();
  if (naverData.resultcode !== "00") {
    throw new Error(`Naver API error: ${naverData.message}`);
  }

  const naverProfile = naverData.response;
  const naverId = naverProfile.id;

  // 이메일 미제공 시 가상 이메일 생성
  const userEmail = naverProfile.email || `naver_${naverId}@naver.placeholder.local`;

  // ============================================
  // STEP 2: Supabase 클라이언트 생성
  // ============================================
  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;

  // Admin Client (사용자 생성, Magic Link 생성용)
  const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  // Public Client (verifyOtp용 - Admin API에는 verifyOtp가 없음!)
  const supabasePublic = createClient(supabaseUrl, anonKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  // ============================================
  // STEP 3: 사용자 Get or Create
  // ============================================
  const { data: newUserData, error: createError } =
    await supabaseAdmin.auth.admin.createUser({
      email: userEmail,
      email_confirm: true,  // ⚠️ 필수: 이메일 인증 자동 완료
      user_metadata: {
        provider: "naver",
        naver_id: naverId,
        naver_nickname: naverProfile.nickname,
      },
    });

  // 이미 존재하는 사용자인 경우 에러 무시
  if (createError && !createError.message.includes("already")) {
    throw createError;
  }

  // ============================================
  // STEP 4: Magic Link 생성 (Admin API)
  // ============================================
  const { data: linkData, error: linkError } =
    await supabaseAdmin.auth.admin.generateLink({
      type: "magiclink",
      email: userEmail,
    });

  if (linkError || !linkData?.properties?.hashed_token) {
    throw new Error("Failed to generate magic link");
  }

  // ============================================
  // STEP 5: OTP 검증으로 세션 획득
  // ⚠️ 중요: verifyOtp는 Admin API가 아닌 일반 Auth API
  // ============================================
  const { data: otpData, error: otpError } =
    await supabasePublic.auth.verifyOtp({
      token_hash: linkData.properties.hashed_token,
      type: "magiclink",
    });

  if (otpError || !otpData.session) {
    throw new Error("Failed to verify OTP");
  }

  const userId = otpData.user?.id;

  // ============================================
  // STEP 6: public.users 테이블 UPSERT
  // ============================================
  await supabaseAdmin.from("users").upsert(
    {
      id: userId,
      oauth_provider: "naver",
      oauth_user_id: naverId,
      name: naverProfile.nickname || "User",
      email: naverProfile.email || "",
      profile_image_url: naverProfile.profile_image,
      last_login_at: new Date().toISOString(),
    },
    { onConflict: "id" }
  );

  // ============================================
  // STEP 7: 세션 정보 반환
  // ============================================
  return new Response(
    JSON.stringify({
      success: true,
      refresh_token: otpData.session.refresh_token,
      access_token: otpData.session.access_token,
    }),
    { status: 200, headers: { "Content-Type": "application/json" } }
  );
});
```

### 2. Flutter Repository (클라이언트 측)

**파일 위치:** `lib/features/authentication/infrastructure/repositories/supabase_auth_repository.dart`

```dart
@override
Future<domain.User> loginWithNaver({
  required bool agreedToTerms,
  required bool agreedToPrivacy,
}) async {
  try {
    // 1. Naver Native SDK로 로그인
    final NaverLoginResult result = await FlutterNaverLogin.logIn();
    if (result.status != NaverLoginStatus.loggedIn) {
      throw Exception('Naver login was cancelled or failed');
    }

    // 2. Naver Access Token 획득
    final naverToken = await FlutterNaverLogin.getCurrentAccessToken();
    final accessToken = naverToken.accessToken;

    // 3. Edge Function 호출 (서버 측에서 토큰 검증 + 세션 생성)
    final response = await _supabase.functions.invoke(
      'naver-auth',
      body: {
        'access_token': accessToken,
        'agreed_to_terms': agreedToTerms,
        'agreed_to_privacy': agreedToPrivacy,
      },
    );

    // 4. Edge Function 응답 처리
    if (response.status != 200 || response.data?['success'] != true) {
      throw Exception('Authentication failed: ${response.data?['error']}');
    }

    final String refreshToken = response.data['refresh_token'];

    // 5. Supabase 세션 설정
    final authResponse = await _supabase.auth.setSession(refreshToken);
    await _supabase.auth.refreshSession();

    // 6. public.users에서 사용자 프로필 조회
    final userProfile = await _supabase
        .from('users')
        .select()
        .eq('id', authResponse.user!.id)  // auth.uid()와 동일
        .single();

    // 7. domain.User 반환
    return domain.User(
      id: authResponse.user!.id,
      oauthProvider: userProfile['oauth_provider'],
      oauthUserId: userProfile['oauth_user_id'],
      name: userProfile['name'],
      email: userProfile['email'] ?? '',
      profileImageUrl: userProfile['profile_image_url'],
      lastLoginAt: DateTime.parse(userProfile['last_login_at']).toLocal(),
    );
  } on AuthException catch (e) {
    throw Exception('Naver login failed: ${e.message}');
  }
}
```

---

## RLS 정책 호환성

### Before (기존 방식)

```
public.users.id = 'naver_123456789'  (커스텀 문자열)
auth.uid() = null                    (Supabase Auth 미사용)

RLS 정책: USING (auth.uid() = user_id)
결과: 항상 false → 데이터 접근 불가
```

### After (새 방식)

```
public.users.id = 'a1b2c3d4-...'     (Supabase Auth UUID)
auth.uid() = 'a1b2c3d4-...'          (동일한 UUID)

RLS 정책: USING (auth.uid() = user_id)
결과: true → 정상 작동
```

---

## 배포 가이드

### 1. Edge Function 배포

```bash
# Supabase CLI 설치 (미설치 시)
npm install -g supabase

# 프로젝트 연결
supabase link --project-ref YOUR_PROJECT_REF

# Edge Function 배포
supabase functions deploy naver-auth

# 배포 확인
supabase functions list
```

### 2. 환경 변수 (자동 설정됨)

Edge Function에서 사용하는 환경 변수는 Supabase에서 자동으로 설정됩니다:
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `SUPABASE_ANON_KEY`

### 3. Naver Developers Console 설정

1. [Naver Developers](https://developers.naver.com) 접속
2. 애플리케이션 등록
3. 사용 API: `네이버 로그인` 선택
4. 필수 권한: 이메일 주소, 별명, 프로필 사진
5. iOS: Bundle ID 등록
6. Android: 패키지명 + 서명 키 해시 등록

### 4. Flutter 앱 설정

**Android:** `android/app/src/main/res/values/strings.xml`
```xml
<string name="naver_client_id">YOUR_CLIENT_ID</string>
<string name="naver_client_secret">YOUR_CLIENT_SECRET</string>
<string name="naver_client_name">YOUR_APP_NAME</string>
```

**iOS:** `Info.plist`에 URL Scheme 등록

---

## 트러블슈팅

### "Edge Function error" 메시지

```bash
# Edge Function 로그 확인
supabase functions logs naver-auth
```

### "Invalid Naver access token" 에러

- Naver 앱에서 로그아웃 후 다시 로그인
- Naver Developers Console에서 앱 상태 확인
- 네이버 API 권한 설정 확인

### "Failed to generate magic link" 에러

- Supabase Service Role Key 환경 변수 확인
- Supabase Dashboard → Functions → naver-auth → Secrets 확인

### RLS 정책 미적용

- `auth.users` 테이블에 사용자가 생성되었는지 확인
- `public.users.id`가 `auth.users.id`와 동일한지 확인

```sql
-- 사용자 ID 확인
SELECT au.id as auth_id, pu.id as public_id, pu.oauth_provider
FROM auth.users au
JOIN public.users pu ON au.id::text = pu.id
WHERE pu.oauth_provider = 'naver';
```

---

## 기존 사용자 마이그레이션

기존에 `naver_xxx` ID로 생성된 사용자가 있다면 마이그레이션이 필요합니다.

### 기존 사용자 확인

```sql
SELECT * FROM public.users WHERE id LIKE 'naver_%';
```

### 마이그레이션 전략

1. **신규 사용자**: Edge Function을 통해 UUID 기반으로 생성
2. **기존 사용자**: 동일 네이버 계정으로 재로그인 시 새 UUID 발급 (데이터 마이그레이션 필요)

---

## 참고 자료

- [Supabase Admin API - createUser](https://supabase.com/docs/reference/javascript/auth-admin-createuser)
- [Supabase Admin API - generateLink](https://supabase.com/docs/reference/javascript/auth-admin-generatelink)
- [Flutter setSession](https://supabase.com/docs/reference/dart/auth-setsession)
- [Naver Login API](https://developers.naver.com/docs/login/api/api.md)
- [GitHub Discussion - Custom OAuth Provider](https://github.com/supabase/supabase/discussions/18682)

---

## 변경 이력

| 날짜 | 버전 | 변경 내용 |
|------|------|----------|
| 2024-11-27 | 1.0 | 최초 작성 - Edge Function 기반 네이버 로그인 구현 |
