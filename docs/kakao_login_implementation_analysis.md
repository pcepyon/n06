# n06 프로젝트 카카오 로그인 구현 점검 보고서

**작성일:** 2025년 11월 9일
**분석 대상:** flutter_kakao_gorouter_guide.md와 현재 n06 프로젝트 구현 비교
**주요 문제:** 카카오 OAuth 인가 코드는 받지만 토큰 교환 미완료

---

## 1. 핵심 문제 분석

### 1.1 현재 증상
```
✓ 카카오 OAuth 인가 코드 수신: MainActivity.onNewIntent()에서 콜백 감지
✗ loginWithKakaoAccount() Future 미해결: 120초 타임아웃 발생
✗ 토큰 교환 미완료: SDK로 콜백이 전달되지 않음
```

### 1.2 근본 원인 추론
카카오 SDK가 **OAuth 콜백(kakao{KEY}://oauth?code=...)**을 받지 못하고 있다.
- MainActivity.onNewIntent()에서 Intent를 받음 (로그 확인 가능)
- 하지만 이 Intent가 Kakao SDK의 내부 리스너(`WebAuthService`)에 전달되지 않음
- Kakao SDK는 내부적으로 `AuthCodeCustomTabsActivity`를 기대함

---

## 2. 가이드 vs 현재 구현 비교 (상세)

### 2.1 AndroidManifest.xml 점검

#### 가이드에서 권장하는 구조
```xml
<!-- MainActivity: 앱 시작 + GoRouter 깊은 링크 -->
<activity android:name=".MainActivity" ... >
  <intent-filter>
    <action android:name="android.intent.action.MAIN"/>
    <category android:name="android.intent.category.LAUNCHER"/>
  </intent-filter>
  
  <!-- 앱의 커스텀 스킴 (GoRouter 깊은 링크용) -->
  <intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="glp1tracker" />
  </intent-filter>
</activity>

<!-- AuthCodeCustomTabsActivity: 카카오 OAuth 콜백만 처리 -->
<activity android:name="com.kakao.sdk.flutter.AuthCodeCustomTabsActivity"
    android:exported="true"
    android:launchMode="singleTop">
  <intent-filter android:label="flutter_web_auth">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="kakao32dfc3999b53af153dbcefa7014093bc"
        android:host="oauth" />
  </intent-filter>
</activity>
```

#### 현재 n06 구현 상태
```xml
<activity android:name=".MainActivity" ... >
  <intent-filter>
    <action android:name="android.intent.action.MAIN"/>
    <category android:name="android.intent.category.LAUNCHER"/>
  </intent-filter>
  
  <!-- ⚠️ 문제: 카카오 스킴을 MainActivity에 등록 -->
  <intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:host="oauth"
        android:scheme="kakao32dfc3999b53af153dbcefa7014093bc" />
  </intent-filter>
</activity>

<!-- ⚠️ 누락: AuthCodeCustomTabsActivity 선언 없음 -->
```

**문제점:**
- ✗ `AuthCodeCustomTabsActivity` 미선언
- ✗ 카카오 OAuth 스킴이 MainActivity에 잘못 등록됨
- ✗ 카카오 SDK가 기대하는 전용 activity 부재

#### 왜 이게 문제인가?

카카오 Flutter SDK의 `UserApi.loginWithKakaoAccount()`를 호출하면:

1. SDK가 내부에서 `AuthCodeCustomTabsActivity`를 통해 Chrome Custom Tabs 열기
2. 카카오 로그인 페이지에서 사용자 인증 후 OAuth 콜백 수신
3. **Kakao SDK가 자체 AuthCodeCustomTabsActivity를 기대함** ← 핵심!
4. 콜백이 MainActivity 대신 AuthCodeCustomTabsActivity로 전달되어야 함
5. AuthCodeCustomTabsActivity가 콜백을 처리하고 SDK의 내부 리스너에 전달

**현재 상황:**
- MainActivity가 kakao:/oauth 스킴을 가로채기 (OS 레벨)
- 하지만 MainActivity는 Kakao SDK의 내부 콜백 핸들러와 무관함
- Kakao SDK는 여전히 AuthCodeCustomTabsActivity 대기 중 → 타임아웃!

---

### 2.2 MainActivity 코드 분석

#### 현재 n06 구현
```kotlin
override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)
    Log.d(TAG, "🔍 [HEALTH CHECK] onNewIntent called with URI: ${intent.data}")
    setIntent(intent)
}
```

**문제점:**
- ✗ Intent를 받긴 하지만, 이것이 Kakao SDK에 전달되지 않음
- ✗ `setIntent(intent)`는 Flutter 엔진용인데, Kakao SDK의 콜백 핸들러를 트리거하지 않음
- ✓ 로그는 정상이므로 Android OS는 Intent를 올바르게 라우팅함

**실제 문제는 Android Manifest 구성입니다.**

---

### 2.3 GoRouter 설정 점검

#### 현재 n06 구현
```dart
final appRouter = GoRouter(
  initialLocation: '/login',
  onException: (context, state, router) {
    final uri = state.uri;
    if (uri.scheme.startsWith('kakao')) {
      // Kakao 콜백 에러 무시
      return;
    }
    router.go('/login');
  },
  routes: [
    // 일반 라우트들...
  ],
);
```

**분석:**
- ✓ `onException`에서 Kakao 콜백 에러 처리 시도 (방어적)
- ✓ GoRouter 설정 자체는 문제 없음
- **하지만 근본 문제는 AndroidManifest 설정이므로 이 로직도 실행되지 않음**

---

### 2.4 lib/main.dart 점검

#### 현재 n06 구현
```dart
void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    _setupErrorHandlers();
    await _initializeAndRunApp();
  }, ...);
}

// _initializeAndRunApp 내부:
KakaoSdk.init(
  nativeAppKey: '32dfc3999b53af153dbcefa7014093bc',
  loggingEnabled: true,
);
```

**분석:**
- ✓ Kakao SDK 초기화 정상
- ✓ 디버그 로깅 활성화 (좋음)
- ✓ 에러 핸들러 설정 (과도하지만 문제는 아님)

---

### 2.5 kakao_auth_datasource.dart 점검

#### 코드 구조
```dart
Future<OAuthToken> login() async {
  // 1. 기존 토큰 확인
  if (await AuthApi.instance.hasToken()) {
    // 토큰 유효성 검사
  }
  
  // 2. KakaoTalk 설치 확인
  if (await isKakaoTalkInstalled()) {
    try {
      final token = await UserApi.instance.loginWithKakaoTalk()
        .timeout(Duration(seconds: 120));
      return token;
    } catch (error) {
      // KakaoTalk 실패 시 Account 로그인으로 폴백
    }
  }
  
  // 3. Account 로그인
  final token = await UserApi.instance.loginWithKakaoAccount()
    .timeout(Duration(seconds: 120));
  return token;
}
```

**분석:**
- ✓ 로직 자체는 Kakao SDK 모범 사례를 따름
- ✓ 타임아웃 설정 (120초) 적절
- ✓ 풍부한 디버그 로깅
- **✗ 하지만 이 코드가 작동하지 않는 이유는 AndroidManifest 설정 때문**

---

## 3. Android 13+ (API 33+) Intent Filter 매칭 규칙

### 3.1 핵심 변경사항
Android 13부터 Intent Filter 매칭이 더 **엄격**해졌습니다.

**문제 상황:**
```
OS가 Intent를 받을 때:
  scheme: kakao32dfc3999b53af153dbcefa7014093bc
  host: oauth
  action: android.intent.action.VIEW
  categories: [DEFAULT, BROWSABLE]

OS가 Intent Filter를 매칭할 때:
1. MainActivity의 kakao 스킴과 매칭되는지 확인 → 될 수 있음
2. AuthCodeCustomTabsActivity의 kakao 스킴과 매칭되는지 확인 → 선언 없음!

결과: 첫 번째 매칭 위치(MainActivity)로 이동
        하지만 MainActivity는 Kakao SDK의 콜백 핸들러가 없음
```

---

## 4. 현재 구현의 문제점 정리

| 문제 | 심각도 | 영향 |
|------|--------|------|
| ✗ AuthCodeCustomTabsActivity 미선언 | 🔴 **CRITICAL** | 로그인 작동 불가 |
| ✗ MainActivity에 kakao 스킴 등록 | 🔴 **CRITICAL** | 콜백 라우팅 오류 |
| ✗ 카카오 전용 Activity 부재 | 🔴 **CRITICAL** | SDK 콜백 처리 불가 |
| ✓ GoRouter 에러 처리 | 🟢 OK | 증상 완화만 함 |
| ✓ main.dart 초기화 | 🟢 OK | 문제 없음 |
| ✓ kakao_auth_datasource.dart | 🟢 OK | 로직 정상 |

---

## 5. 개선사항 (Action Items)

### 5.1 AndroidManifest.xml 수정 필요

**변경 전:**
```xml
<activity android:name=".MainActivity" ... >
  <intent-filter>
    <action android:name="android.intent.action.MAIN"/>
    <category android:name="android.intent.category.LAUNCHER"/>
  </intent-filter>
  <intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:host="oauth" android:scheme="kakao32dfc3999b53af153dbcefa7014093bc" />
  </intent-filter>
</activity>
```

**변경 후:**
```xml
<activity android:name=".MainActivity" ... >
  <intent-filter>
    <action android:name="android.intent.action.MAIN"/>
    <category android:name="android.intent.category.LAUNCHER"/>
  </intent-filter>
</activity>

<!-- 추가: 카카오 OAuth 전용 Activity -->
<activity
    android:name="com.kakao.sdk.flutter.AuthCodeCustomTabsActivity"
    android:exported="true"
    android:launchMode="singleTop">
    <intent-filter android:label="flutter_web_auth">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data
            android:scheme="kakao32dfc3999b53af153dbcefa7014093bc"
            android:host="oauth" />
    </intent-filter>
</activity>
```

**주요 변경:**
- ✓ MainActivity에서 kakao 스킴 제거
- ✓ `com.kakao.sdk.flutter.AuthCodeCustomTabsActivity` 추가
- ✓ `android:exported="true"` (Android 12+ 필수)
- ✓ `android:launchMode="singleTop"` (중복 인스턴스 방지)

---

## 6. 예상 동작 흐름 (수정 후)

```
1. LoginScreen에서 "카카오 로그인" 버튼 클릭
   ↓
2. KakaoAuthDataSource.login() 호출
   ↓
3. UserApi.instance.loginWithKakaoAccount() 호출
   ↓
4. Kakao SDK가 내부적으로 AuthCodeCustomTabsActivity 시작
   ↓
5. Chrome Custom Tabs에서 카카오 로그인 페이지 표시
   ↓
6. 사용자 로그인 → 인가 코드 수신
   ↓
7. AuthCodeCustomTabsActivity가 kakao{KEY}://oauth?code=... 받음 ← 이제 가능!
   ↓
8. Kakao SDK의 내부 리스너가 코드 처리
   ↓
9. Kakao 서버에 토큰 교환 요청
   ↓
10. OAuthToken 반환
    ↓
11. loginWithKakaoAccount() Future 해결 ← 타임아웃 문제 해결!
    ↓
12. KakaoAuthDataSource.login() 성공
    ↓
13. AuthNotifier 상태 업데이트
    ↓
14. GoRouter가 /onboarding으로 네비게이션
```

---

## 7. 테스트 절차

### 7.1 수정 후 검증

```bash
# 1. 프로젝트 클린
flutter clean

# 2. 의존성 다시 받기
flutter pub get

# 3. 빌드
flutter build apk --debug

# 4. 설치
adb install -r build/app/outputs/apk/debug/app-debug.apk

# 5. 로그 모니터링
adb logcat -c
adb logcat | grep -E "MainActivity|AuthCode|Kakao|oauth|KakaoAuthDataSource"

# 6. 앱 시작 후 카카오 로그인 버튼 클릭
```

### 7.2 예상 정상 로그

```
[정상] D/KakaoAuthDataSource: 🚀 Starting Kakao login...
[정상] D/KakaoAuthDataSource: 🔍 Creating Future for loginWithKakaoAccount()...
[정상] D/MainActivity: 🔍 onNewIntent called with URI: kakao{KEY}://oauth?code=...
[정상] (토큰 교환)
[정상] D/KakaoAuthDataSource: ✅ Account login successful
[정상] D/KakaoAuthDataSource: Token received: ...
```

---

## 8. 가이드와 현재 구현 비교 요약

| 항목 | 가이드 | 현재 n06 | 상태 |
|------|--------|---------|------|
| **AuthCodeCustomTabsActivity** | 필수 | 없음 | 🔴 FAIL |
| **MainActivity 카카오 스킴** | 제거 | 있음 | 🔴 FAIL |
| **android:exported** | true | true | 🟢 PASS |
| **launchMode="singleTop"** | 권장 | 있음 | 🟢 PASS |
| **Kakao SDK 초기화** | main.dart | main.dart | 🟢 PASS |
| **GoRouter 에러 처리** | 권장 | 있음 | 🟢 PASS |
| **WidgetsBindingObserver** | 선택사항 | 있음 | 🟢 PASS |

---

## 9. 결론

### 핵심 문제
```
카카오 OAuth 콜백(kakao{KEY}://oauth)이 잘못된 Activity(MainActivity)로 
라우팅되고 있어서, Kakao SDK의 내부 콜백 핸들러가 실행될 수 없습니다.
```

### 해결책
```
1. AndroidManifest.xml에서 MainActivity의 kakao 스킴 제거
2. com.kakao.sdk.flutter.AuthCodeCustomTabsActivity 추가 선언
3. 나머지 코드는 수정할 필요 없음 (이미 모두 정상)
```

### 예상 효과
- ✓ loginWithKakaoAccount() Future가 정상 해결
- ✓ 토큰 교환 성공
- ✓ 사용자 프로필 조회 성공
- ✓ 카카오 로그인 완료 후 온보딩으로 네비게이션

---

**다음 단계:**
1. AndroidManifest.xml 수정 (심각도: 🔴 CRITICAL)
2. flutter clean && flutter pub get
3. 테스트 빌드 및 실행
4. 로그 확인
5. 카카오 로그인 재시도
