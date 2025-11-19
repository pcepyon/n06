# F-016: 이메일 회원가입/로그인 구현 계획 (TDD)

> Feature: F-016 (이메일 인증)
> Strategy: Test-Driven Development (TDD)
> Timeline: 10 Modules, 80 hours

---

## 구현 순서 및 Module 분류

### Module 0: 선행 작업 (Preparation)

**목표:** 프로젝트 기초 설정

- [ ] Supabase Auth API Key 확인
- [ ] Deep Link 설정 계획 검토
- [ ] 기존 AuthRepository 분석
- [ ] 테스트 환경 구성

**관련 파일:** 기존 인증 기능

**산출물:** 설정 완료

---

### Module 1: Domain Layer - Validators (Unit Tests First)

**목표:** 검증 로직 구현 (TDD)

**위치:** `lib/core/utils/validators.dart`

**기능:**
- `isValidEmail(String email) -> bool`
- `isValidPassword(String password) -> bool`
- `getPasswordStrength(String password) -> PasswordStrength`
- `enum PasswordStrength { weak, medium, strong }`

**TDD 사이클:**
1. **RED:** 테스트 작성
   - `test_validators.dart` 생성
   - 모든 validator 함수에 대한 test case 작성
   - 테스트 실행 → 모두 실패 확인

2. **GREEN:** 최소 구현
   - `validators.dart` 구현
   - 모든 테스트 통과 확인

3. **REFACTOR:** 코드 정리
   - 정규표현식 상수화
   - 함수 이름 개선
   - 문서화 추가

**테스트 케이스:**
```
isValidEmail():
  - 유효한 이메일
  - 잘못된 형식 (@ 없음)
  - 빈 문자열
  - 254자 초과
  
isValidPassword():
  - 유효한 비밀번호 (모든 조건 만족)
  - 8자 미만
  - 대문자 없음
  - 소문자 없음
  - 숫자 없음
  - 특수문자 없음

getPasswordStrength():
  - weak (2개 이상 조건 미만족)
  - medium (3개 조건 만족)
  - strong (4개 이상 조건 만족)
```

**산출물:**
- `lib/core/utils/validators.dart`
- `test/core/utils/validators_test.dart`
- Test Coverage: 100%

---

### Module 2: Domain Layer - AuthRepository 인터페이스 확장

**목표:** 이메일 인증 메서드 정의

**위치:** `lib/features/authentication/domain/repositories/auth_repository.dart`

**메서드 추가:**
```dart
Future<User> signUpWithEmail({
  required String email,
  required String password,
});

Future<User> signInWithEmail({
  required String email,
  required String password,
});

Future<void> resetPasswordForEmail(String email);

Future<void> updatePassword({
  required String currentPassword,
  required String newPassword,
});
```

**TDD 방식:** 
- 인터페이스이므로 구현 테스트 작성 (Mock 사용)
- 각 메서드의 계약(contract) 정의

**산출물:**
- `lib/features/authentication/domain/repositories/auth_repository.dart` (수정)
- Domain layer 테스트는 Interface test (Mock AuthRepository 사용)

---

### Module 3: Domain Layer - Custom Exceptions

**목표:** 이메일 인증 관련 예외 정의

**위치:** `lib/features/authentication/domain/exceptions/email_auth_exceptions.dart` (신규)

**예외 클래스:**
```dart
class EmailAlreadyExists implements Exception {
  final String email;
  EmailAlreadyExists(this.email);
}

class InvalidPassword implements Exception {
  final String reason;
  InvalidPassword(this.reason);
}

class InvalidEmail implements Exception {
  final String email;
  InvalidEmail(this.email);
}

class PasswordResetTokenExpired implements Exception {}

class ConsentNotProvided implements Exception {
  final List<String> missingConsents;
  ConsentNotProvided(this.missingConsents);
}
```

**TDD:** 단순 Data class 테스트

**산출물:**
- `lib/features/authentication/domain/exceptions/email_auth_exceptions.dart`

---

### Module 4: Infrastructure Layer - SupabaseAuthRepository 구현

**목표:** Supabase Auth와 통합

**위치:** `lib/features/authentication/infrastructure/repositories/supabase_auth_repository.dart` (확장)

**메서드 구현:**
```dart
@override
Future<User> signUpWithEmail({...}) async {
  try {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) throw Exception('User creation failed');
    
    // ConsentRecord 저장
    await _saveConsentRecord(user.id, true, true, false);
    
    return User(...);
  } on AuthException catch (e) {
    // 에러 처리
  }
}
```

**TDD 사이클:**
1. **RED:** Mock Supabase 클라이언트와 테스트 작성
2. **GREEN:** Supabase 호출 구현
3. **REFACTOR:** 에러 처리 개선

**테스트 케이스:**
```
signUpWithEmail():
  - 정상 가입
  - 중복 이메일
  - 약한 비밀번호
  - 네트워크 오류

signInWithEmail():
  - 정상 로그인
  - 잘못된 자격증명
  - 계정 잠금
  - 네트워크 오류

resetPasswordForEmail():
  - 정상 요청
  - 존재하지 않는 이메일
  - 요청 제한

updatePassword():
  - 정상 변경
  - 토큰 만료
```

**산출물:**
- `lib/features/authentication/infrastructure/repositories/supabase_auth_repository.dart` (확장)
- `test/features/authentication/infrastructure/repositories/supabase_auth_repository_test.dart` (신규)

---

### Module 5: Application Layer - AuthNotifier 확장

**목표:** 이메일 인증 상태 관리

**위치:** `lib/features/authentication/application/notifiers/auth_notifier.dart` (확장)

**메서드 추가:**
```dart
Future<bool> signUpWithEmail({
  required String email,
  required String password,
  required bool agreedToTerms,
  required bool agreedToPrivacy,
}) async {
  state = const AsyncValue.loading();
  state = await AsyncValue.guard(() async {
    final user = await repository.signUpWithEmail(
      email: email,
      password: password,
    );
    return user;
  });
  return state.hasValue;
}

Future<bool> signInWithEmail({
  required String email,
  required String password,
}) async { ... }

Future<void> resetPasswordForEmail(String email) async { ... }

Future<void> updatePassword({
  required String currentPassword,
  required String newPassword,
}) async { ... }
```

**TDD:** Mock Repository와 Provider test

**테스트 케이스:**
```
signUpWithEmail():
  - state: loading → data
  - state: loading → error (중복 이메일)
  - Consent 기록 검증

signInWithEmail():
  - state: loading → data
  - state: loading → error

resetPasswordForEmail():
  - async 작업 완료
  - 에러 처리
```

**산출물:**
- `lib/features/authentication/application/notifiers/auth_notifier.dart` (확장)
- `test/features/authentication/application/notifiers/auth_notifier_test.dart` (확장)

---

### Module 6: Presentation - EmailSignUpScreen

**목표:** 이메일 회원가입 UI

**위치:** `lib/features/authentication/presentation/screens/email_signup_screen.dart` (신규)

**위젯:**
- TextField (이메일)
- TextField (비밀번호) + 강도 표시
- TextField (비밀번호 확인)
- Checkbox (약관 동의)
- ElevatedButton (가입)

**TDD:** Widget test

**테스트 케이스:**
```
- 이메일 입력 후 유효성 에러 메시지 표시
- 비밀번호 강도 지시자 업데이트
- 약관 미동의 시 가입 버튼 비활성
- 가입 성공 시 대시보드로 이동
- 가입 실패 시 SnackBar 표시
```

**산출물:**
- `lib/features/authentication/presentation/screens/email_signup_screen.dart`
- `test/features/authentication/presentation/screens/email_signup_screen_test.dart`

---

### Module 7: Presentation - EmailSignInScreen

**목표:** 이메일 로그인 UI

**위치:** `lib/features/authentication/presentation/screens/email_signin_screen.dart` (신규)

**위젯:**
- TextFormField (이메일)
- TextFormField (비밀번호)
- "비밀번호 재설정" 텍스트 링크
- ElevatedButton (로그인)

**TDD:** Widget test

**테스트 케이스:**
```
- 로그인 성공 시 대시보드로 이동
- 로그인 실패 시 에러 메시지 표시
- "비밀번호 재설정" 링크 탭 시 해당 화면으로 이동
- "회원가입" 링크 탭 시 회원가입 화면으로 이동
```

**산출물:**
- `lib/features/authentication/presentation/screens/email_signin_screen.dart`
- `test/features/authentication/presentation/screens/email_signin_screen_test.dart`

---

### Module 8: Presentation - PasswordResetScreen

**목표:** 비밀번호 재설정 UI

**위치:** `lib/features/authentication/presentation/screens/password_reset_screen.dart` (신규)

**두 단계:**
1. 이메일 입력 화면
2. 비밀번호 변경 화면 (Deep Link: token 파라미터)

**위젯:**
- TextField (이메일)
- TextField (새 비밀번호)
- TextField (비밀번호 확인)
- ElevatedButton (재설정 링크 발송 / 비밀번호 변경)

**TDD:** Widget test

**산출물:**
- `lib/features/authentication/presentation/screens/password_reset_screen.dart`
- `test/features/authentication/presentation/screens/password_reset_screen_test.dart`

---

### Module 9: Deep Link 설정

**목표:** 비밀번호 재설정 메일 링크 처리

**iOS:** `ios/Runner/Info.plist`
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLName</key>
    <string>n06</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>n06</string>
    </array>
  </dict>
</array>
```

**Android:** `android/app/src/main/AndroidManifest.xml`
```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data
    android:scheme="n06"
    android:host="reset-password" />
</intent-filter>
```

**Router:** `lib/core/routing/app_router.dart`
```dart
GoRoute(
  path: 'reset-password',
  builder: (context, state) {
    final token = state.uri.queryParameters['token'];
    return PasswordResetScreen(token: token);
  },
),
```

**산출물:**
- iOS/Android 설정 파일 수정
- Router 설정 추가
- Deep Link 테스트 (수동)

---

### Module 10: 통합 테스트 및 정리

**목표:** 모든 모듈 통합 검증

**작업:**
1. 모든 테스트 실행: `flutter test`
2. Code coverage 확인: >= 85%
3. 정적 분석: `flutter analyze`
4. 통합 테스트 (수동):
   - 이메일로 회원가입
   - 이메일로 로그인
   - 비밀번호 재설정 (Deep Link)
   - 로그아웃

**산출물:**
- 구현 완료 보고서
- QA Sheet (수동 테스트)
- Release notes

---

## 예상 Timeline

| Module | 예상 시간 | 상태 |
|--------|----------|------|
| 0: Preparation | 2h | - |
| 1: Validators | 4h | - |
| 2: Repository Interface | 2h | - |
| 3: Exceptions | 1h | - |
| 4: Implementation | 12h | - |
| 5: Notifier | 10h | - |
| 6: SignUp Screen | 12h | - |
| 7: SignIn Screen | 8h | - |
| 8: Password Reset | 12h | - |
| 9: Deep Link | 3h | - |
| 10: Integration | 12h | - |
| **Total** | **78h** | - |

---

## TDD 체크리스트

- [ ] Module 1-10 모두 Test First 작성
- [ ] 모든 테스트 통과 확인
- [ ] Code coverage >= 85%
- [ ] 정적 분석 경고 없음
- [ ] Linting 통과
- [ ] 수동 QA 완료
- [ ] 문서 업데이트

---

## 산출물 정리

### 코드 파일 (신규 + 수정)
- `lib/core/utils/validators.dart` (신규)
- `lib/features/authentication/domain/repositories/auth_repository.dart` (수정)
- `lib/features/authentication/domain/exceptions/email_auth_exceptions.dart` (신규)
- `lib/features/authentication/infrastructure/repositories/supabase_auth_repository.dart` (수정)
- `lib/features/authentication/application/notifiers/auth_notifier.dart` (수정)
- `lib/features/authentication/presentation/screens/email_signup_screen.dart` (신규)
- `lib/features/authentication/presentation/screens/email_signin_screen.dart` (신규)
- `lib/features/authentication/presentation/screens/password_reset_screen.dart` (신규)
- `lib/core/routing/app_router.dart` (수정)

### 테스트 파일 (신규 + 수정)
- `test/core/utils/validators_test.dart` (신규)
- `test/features/authentication/infrastructure/repositories/supabase_auth_repository_test.dart` (신규)
- `test/features/authentication/application/notifiers/auth_notifier_test.dart` (수정)
- `test/features/authentication/presentation/screens/email_signup_screen_test.dart` (신규)
- `test/features/authentication/presentation/screens/email_signin_screen_test.dart` (신규)
- `test/features/authentication/presentation/screens/password_reset_screen_test.dart` (신규)

### 설정 파일 (수정)
- `ios/Runner/Info.plist`
- `android/app/src/main/AndroidManifest.xml`

### 문서 파일 (신규 + 수정)
- `docs/016/spec.md` (신규)
- `docs/016/plan.md` (신규)
- `docs/016/qa_sheet.md` (신규)
- `docs/016/report.md` (신규)

---

## 참고 사항

### TDD 프로세스
1. **RED:** 실패하는 테스트 작성
2. **GREEN:** 최소 구현으로 통과
3. **REFACTOR:** 코드 정리 (테스트 통과 유지)

### Code Coverage 목표
- Domain: 100% (validators, exceptions)
- Infrastructure: 90% (repository)
- Application: 85% (notifier)
- Presentation: 70% (screens)

### Build & Test
```bash
# 테스트 실행
flutter test

# 정적 분석
flutter analyze

# Build
flutter build apk
```
