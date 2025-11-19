# F-016: 이메일 회원가입 및 로그인

> Feature ID: F-016
> Status: 개발 예정
> Priority: P0 (소셜 로그인과 병행하여 제공)
> Est. Effort: 80 시간

---

## 1. Overview

기존 소셜 로그인 (Kakao, Naver)을 보완하는 이메일 기반 인증 기능입니다.
사용자가 이메일과 비밀번호로 가입하고 로그인할 수 있도록 제공합니다.

---

## 2. Use Cases

### UC-016-01: 이메일로 회원가입

- 이메일 입력 → 유효성 검증
- 비밀번호 입력 → 강도 검증 (최소 8자, 대소문자 + 숫자 + 특수문자)
- 약관 동의
- Supabase Auth signUp 호출
- 대시보드 진입

### UC-016-02: 이메일로 로그인

- 이메일, 비밀번호 입력
- Supabase Auth signInWithPassword 호출
- 대시보드 진입

### UC-016-03: 비밀번호 재설정

- 이메일 입력 → resetPasswordForEmail 호출
- Deep Link: n06://reset-password?token=xxx
- 새 비밀번호 입력 → updateUser 호출

---

## 3. Validation Rules

### Email
```dart
bool isValidEmail(String email) {
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&\'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
  );
  return emailRegex.hasMatch(email) && email.length <= 254;
}
```

### Password
```dart
bool isValidPassword(String password) {
  if (password.length < 8) return false;
  if (!RegExp(r'[A-Z]').hasMatch(password)) return false;
  if (!RegExp(r'[a-z]').hasMatch(password)) return false;
  if (!RegExp(r'[0-9]').hasMatch(password)) return false;
  if (!RegExp(r'[!@#$%^&*()_+\-=\[\]{};:\'",.<>?/\\|`~]').hasMatch(password)) return false;
  return true;
}

enum PasswordStrength { weak, medium, strong }

PasswordStrength getPasswordStrength(String password) {
  if (password.length < 8) return PasswordStrength.weak;
  int score = 0;
  if (RegExp(r'[A-Z]').hasMatch(password)) score++;
  if (RegExp(r'[a-z]').hasMatch(password)) score++;
  if (RegExp(r'[0-9]').hasMatch(password)) score++;
  if (RegExp(r'[!@#$%^&*()_+\-=\[\]{};:\'",.<>?/\\|`~]').hasMatch(password)) score++;
  if (score < 3) return PasswordStrength.weak;
  if (score < 4) return PasswordStrength.medium;
  return PasswordStrength.strong;
}
```

---

## 4. Repository Interface (Domain)

```dart
abstract class AuthRepository {
  // 기존 메서드
  Future<User> loginWithKakao({...});
  Future<User> loginWithNaver({...});
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<bool> isFirstLogin();
  Future<bool> isAccessTokenValid();
  Future<String> refreshAccessToken(String refreshToken);

  // 신규 메서드 (F-016)
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
}
```

---

## 5. Acceptance Criteria

- [ ] Unit tests 통과 (validators)
- [ ] Integration tests 통과 (repository)
- [ ] Application tests 통과 (notifier)
- [ ] Widget tests 통과 (screens)
- [ ] Code coverage >= 85%
- [ ] flutter analyze 경고 없음
- [ ] 수동 QA 테스트 완료
