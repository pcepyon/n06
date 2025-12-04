# Phase 3: Authentication

> 출처: docs/i18n-plan.md §5 Phase 3

## 개요

- **목적**: 로그인, 회원가입, 비밀번호 재설정 등 인증 화면 i18n
- **선행 조건**: Phase 0, Phase 1 완료
- **문자열 수**: ~118개

---

## 작업 목록

| 작업 | 파일 | 문자열 수 |
|-----|------|---------:|
| 로그인 화면 | `login_screen.dart` | ~25 |
| 이메일 가입 | `email_signup_screen.dart` | ~30 |
| 이메일 로그인 | `email_signin_screen.dart` | ~20 |
| 비밀번호 재설정 | `password_reset_screen.dart` | ~15 |
| 계정 삭제 | `delete_account_confirm_dialog.dart` | ~10 |
| 로그아웃 | `logout_confirm_dialog.dart` | ~8 |
| 동의 체크박스 | `consent_checkbox.dart` | ~10 |

---

## ARB 키 목록 (예상)

### 로그인 화면

```json
{
  "auth_login_title": "로그인",
  "auth_login_subtitle": "계정에 로그인하세요",
  "auth_login_emailButton": "이메일로 로그인",
  "auth_login_appleButton": "Apple로 로그인",
  "auth_login_googleButton": "Google로 로그인",
  "auth_login_signupPrompt": "계정이 없으신가요?",
  "auth_login_signupLink": "회원가입"
}
```

### 이메일 가입

```json
{
  "auth_signup_title": "회원가입",
  "auth_signup_email": "이메일",
  "auth_signup_emailHint": "이메일을 입력해주세요",
  "auth_signup_emailError_invalid": "올바른 이메일 형식이 아닙니다",
  "auth_signup_emailError_exists": "이미 사용 중인 이메일입니다",
  "auth_signup_password": "비밀번호",
  "auth_signup_passwordHint": "비밀번호를 입력해주세요",
  "auth_signup_passwordError_short": "비밀번호는 8자 이상이어야 합니다",
  "auth_signup_passwordConfirm": "비밀번호 확인",
  "auth_signup_passwordConfirmHint": "비밀번호를 다시 입력해주세요",
  "auth_signup_passwordConfirmError_mismatch": "비밀번호가 일치하지 않습니다",
  "auth_signup_submitButton": "가입하기",
  "auth_signup_success": "가입이 완료되었습니다"
}
```

### 이메일 로그인

```json
{
  "auth_signin_title": "이메일 로그인",
  "auth_signin_email": "이메일",
  "auth_signin_password": "비밀번호",
  "auth_signin_submitButton": "로그인",
  "auth_signin_forgotPassword": "비밀번호를 잊으셨나요?",
  "auth_signin_error_invalidCredentials": "이메일 또는 비밀번호가 올바르지 않습니다"
}
```

### 비밀번호 재설정

```json
{
  "auth_passwordReset_title": "비밀번호 재설정",
  "auth_passwordReset_description": "가입한 이메일 주소를 입력하시면 비밀번호 재설정 링크를 보내드립니다.",
  "auth_passwordReset_email": "이메일",
  "auth_passwordReset_submitButton": "재설정 링크 보내기",
  "auth_passwordReset_success": "재설정 링크가 이메일로 전송되었습니다"
}
```

### 계정 삭제

```json
{
  "auth_deleteAccount_title": "계정 삭제",
  "auth_deleteAccount_confirmTitle": "계정 삭제 확인",
  "auth_deleteAccount_confirmMessage": "정말로 계정을 삭제하시겠습니까?\n모든 데이터가 삭제되며 복구할 수 없습니다.",
  "auth_deleteAccount_inputLabel": "확인을 위해 '삭제'를 입력해주세요",
  "auth_deleteAccount_confirmWord": "삭제",
  "auth_deleteAccount_button": "계정 삭제"
}
```

### 로그아웃

```json
{
  "auth_logout_title": "로그아웃",
  "auth_logout_confirmMessage": "정말로 로그아웃하시겠습니까?",
  "auth_logout_button": "로그아웃"
}
```

### 동의 체크박스

```json
{
  "auth_consent_termsPrefix": "",
  "auth_consent_termsLink": "이용약관",
  "auth_consent_termsSuffix": "에 동의합니다",
  "auth_consent_privacyPrefix": "",
  "auth_consent_privacyLink": "개인정보처리방침",
  "auth_consent_privacySuffix": "에 동의합니다",
  "auth_consent_all": "전체 동의"
}
```

---

## 대상 파일 (경로 확인 필요)

```
lib/features/auth/presentation/
├── screens/
│   ├── login_screen.dart
│   ├── email_signup_screen.dart
│   ├── email_signin_screen.dart
│   └── password_reset_screen.dart
├── widgets/
│   ├── delete_account_confirm_dialog.dart
│   ├── logout_confirm_dialog.dart
│   └── consent_checkbox.dart
```

---

## 완료 기준

```
[ ] 로그인 화면 문자열 ARB 추가 (ko, en)
[ ] 이메일 가입 문자열 ARB 추가 (ko, en)
[ ] 이메일 로그인 문자열 ARB 추가 (ko, en)
[ ] 비밀번호 재설정 문자열 ARB 추가 (ko, en)
[ ] 계정 삭제 문자열 ARB 추가 (ko, en)
[ ] 로그아웃 문자열 ARB 추가 (ko, en)
[ ] 동의 체크박스 문자열 ARB 추가 (ko, en)
[ ] 모든 사용처 context.l10n으로 변경
[ ] 빌드 성공
```
