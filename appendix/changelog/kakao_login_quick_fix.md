₩# 카카오 로그인 빠른 수정 가이드

**문제:** 카카오 OAuth 콜백이 잘못된 Activity로 라우팅되어 토큰 교환 미완료
**해결 난이도:** ⭐ (매우 쉬움 - 1줄 추가, 4줄 삭제)
**예상 소요 시간:** 5분

---

## 단계별 수정

### Step 1: AndroidManifest.xml 열기

```
파일: android/app/src/main/AndroidManifest.xml
```

### Step 2: MainActivity의 kakao 스킴 intent-filter 제거

**현재 (제거할 부분):**
```xml
<activity android:name=".MainActivity" ... >
  <intent-filter>
    <action android:name="android.intent.action.MAIN"/>
    <category android:name="android.intent.category.LAUNCHER"/>
  </intent-filter>
  
  <!-- 이 블록 전체를 삭제하기 -->
  <intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:host="oauth"
        android:scheme="kakao32dfc3999b53af153dbcefa7014093bc" />
  </intent-filter>
</activity>
```

**수정 후:**
```xml
<activity android:name=".MainActivity" ... >
  <intent-filter>
    <action android:name="android.intent.action.MAIN"/>
    <category android:name="android.intent.category.LAUNCHER"/>
  </intent-filter>
</activity>
```

### Step 3: AuthCodeCustomTabsActivity 추가

**추가할 위치:** `</application>` 태그 바로 전에

**추가할 코드:**
```xml
<!-- Kakao OAuth 전용 Activity -->
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

### Step 4: 변경 확인

```bash
# 프로젝트 클린
flutter clean

# 의존성 받기
flutter pub get

# 빌드
flutter build apk --debug

# 설치 (기존 버전이 있으면)
adb install -r build/app/outputs/apk/debug/app-debug.apk
```

---

## 완료 체크리스트

- [ ] MainActivity에서 kakao 스킴 intent-filter 삭제됨
- [ ] AuthCodeCustomTabsActivity 추가됨
- [ ] `android:exported="true"` 있음
- [ ] `android:launchMode="singleTop"` 있음
- [ ] AndroidManifest.xml 문법 에러 없음
- [ ] `flutter clean` 실행됨
- [ ] 앱 빌드 성공
- [ ] 카카오 로그인 재시도 완료

---

## 예상 결과

**수정 전:**
```
❌ 타임아웃: loginWithKakaoAccount() Future가 해결되지 않음
❌ 콜백: MainActivity가 Intent를 받지만 SDK로 전달 안 됨
```

**수정 후:**
```
✓ 토큰 교환 성공
✓ 사용자 프로필 조회 완료
✓ 온보딩 화면으로 네비게이션
```

---

## 트러블슈팅

### 여전히 타임아웃이 발생하면

**확인 사항:**
1. `android:exported="true"` 있는가?
2. `android:scheme="kakao32dfc3999b53af153dbcefa7014093bc"` 정확한가?
3. MainActivity에 kakao 스킴이 남아있지 않은가?
4. 앱을 완전히 제거했는가? (`adb uninstall com.glp1.n06`)

**로그 확인:**
```bash
adb logcat | grep -E "AuthCode|Kakao|onNewIntent"
```

정상 로그:
```
D/MainActivity: 🔍 onNewIntent called with URI: kakao32dfc...://oauth?code=...
D/KakaoAuthDataSource: ✅ Account login successful
```

---

**완료되면 git에 커밋하세요:**
```bash
git add android/app/src/main/AndroidManifest.xml
git commit -m "fix: 카카오 OAuth 콜백을 AuthCodeCustomTabsActivity로 라우팅"
```

