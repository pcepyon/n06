# Phase 1: 공통 컴포넌트

> 출처: docs/i18n-plan.md §5 Phase 1

## 개요

- **목적**: 공통 버튼, 다이얼로그, 에러 메시지 등 재사용 컴포넌트 i18n
- **선행 조건**: Phase 0 완료
- **문자열 수**: ~55개

---

## 작업 목록

| 작업 | 파일 | 문자열 수 |
|-----|------|---------:|
| 공통 버튼 | `lib/core/presentation/widgets/` | ~20 |
| 공통 다이얼로그 | `lib/core/presentation/widgets/` | ~15 |
| 에러 메시지 | `lib/core/errors/domain_exception.dart` | ~10 |
| 법적 문서 메뉴 | `lib/core/constants/legal_urls.dart` + settings | ~10 |

---

## ARB 키 목록 (예상)

### 공통 버튼

```json
{
  "common_button_confirm": "확인",
  "common_button_cancel": "취소",
  "common_button_delete": "삭제",
  "common_button_save": "저장",
  "common_button_close": "닫기",
  "common_button_next": "다음",
  "common_button_back": "이전",
  "common_button_done": "완료",
  "common_button_skip": "건너뛰기",
  "common_button_retry": "다시 시도"
}
```

### 공통 다이얼로그

```json
{
  "common_dialog_confirmTitle": "확인",
  "common_dialog_warningTitle": "주의",
  "common_dialog_errorTitle": "오류"
}
```

### 에러 메시지

```json
{
  "common_error_networkFailed": "네트워크 연결을 확인해주세요",
  "common_error_unknown": "알 수 없는 오류가 발생했습니다",
  "common_error_timeout": "요청 시간이 초과되었습니다",
  "common_error_serverError": "서버 오류가 발생했습니다"
}
```

### 법적 문서

```json
{
  "common_legal_termsOfService": "이용약관",
  "common_legal_privacyPolicy": "개인정보처리방침",
  "common_legal_openSourceLicenses": "오픈소스 라이선스"
}
```

---

## 대상 파일 (실제 파일 확인 필요)

```
lib/core/presentation/widgets/
├── common_button.dart (있다면)
├── confirm_dialog.dart (있다면)
└── ...

lib/core/errors/
└── domain_exception.dart

lib/core/constants/
└── legal_urls.dart
```

---

## 변환 예시

### 에러 메시지 변환

**Before:**
```dart
class DomainException {
  String get message => switch (this) {
    NetworkException() => '네트워크 연결을 확인해주세요',
    UnknownException() => '알 수 없는 오류가 발생했습니다',
  };
}
```

**After:**
```dart
// DomainException은 context 없으므로 키만 제공
class DomainException {
  String get messageKey => switch (this) {
    NetworkException() => 'common_error_networkFailed',
    UnknownException() => 'common_error_unknown',
  };
}

// Presentation에서 변환
extension DomainExceptionL10n on DomainException {
  String getMessage(BuildContext context) {
    return switch (messageKey) {
      'common_error_networkFailed' => context.l10n.common_error_networkFailed,
      'common_error_unknown' => context.l10n.common_error_unknown,
      _ => messageKey,
    };
  }
}
```

---

## 완료 기준

```
[ ] 공통 버튼 문자열 ARB 추가 (ko, en)
[ ] 공통 다이얼로그 문자열 ARB 추가 (ko, en)
[ ] 에러 메시지 문자열 ARB 추가 (ko, en)
[ ] 법적 문서 메뉴 문자열 ARB 추가 (ko, en)
[ ] 모든 사용처 context.l10n으로 변경
[ ] 빌드 성공
[ ] 기존 테스트 통과
```
