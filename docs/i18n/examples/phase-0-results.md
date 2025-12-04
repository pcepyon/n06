# Phase 0 실제 구현 결과물

> 이 문서는 Phase 0 인프라 설정의 **실제 동작하는 결과물**입니다.
> 빌드 검증 완료됨 (iOS build 성공)

---

## 생성된 파일 목록

```
l10n.yaml                                              # L10n 설정
lib/l10n/app_ko.arb                                    # 한국어 ARB
lib/l10n/app_en.arb                                    # 영어 ARB
lib/l10n/generated/app_localizations.dart              # 자동 생성
lib/l10n/generated/app_localizations_ko.dart           # 자동 생성
lib/l10n/generated/app_localizations_en.dart           # 자동 생성
lib/core/extensions/l10n_extension.dart                # context.l10n
lib/core/extensions/date_format_extension.dart         # locale 연동 날짜
lib/core/providers/shared_preferences_provider.dart    # SharedPreferences
lib/features/settings/application/notifiers/locale_notifier.dart
lib/features/settings/application/notifiers/locale_notifier.g.dart
test/helpers/l10n_test_helper.dart                     # 테스트 헬퍼
scripts/validate_arb.sh                                # ARB 검증
```

---

## 실제 l10n.yaml

```yaml
# Flutter Localization Configuration
arb-dir: lib/l10n
template-arb-file: app_ko.arb
output-localization-file: app_localizations.dart
output-class: L10n
output-dir: lib/l10n/generated
nullable-getter: false
use-deferred-loading: false
```

---

## 실제 app_ko.arb

```json
{
  "@@locale": "ko",

  "common_button_confirm": "확인",
  "@common_button_confirm": {
    "description": "Generic confirm button"
  },

  "common_button_cancel": "취소",
  "@common_button_cancel": {
    "description": "Generic cancel button"
  },

  "common_button_close": "닫기",
  "@common_button_close": {
    "description": "Generic close button"
  },

  "common_button_save": "저장",
  "@common_button_save": {
    "description": "Generic save button"
  },

  "common_button_delete": "삭제",
  "@common_button_delete": {
    "description": "Generic delete button"
  }
}
```

---

## 실제 app_en.arb

```json
{
  "@@locale": "en",

  "common_button_confirm": "OK",
  "@common_button_confirm": {
    "description": "Generic confirm button"
  },

  "common_button_cancel": "Cancel",
  "@common_button_cancel": {
    "description": "Generic cancel button"
  },

  "common_button_close": "Close",
  "@common_button_close": {
    "description": "Generic close button"
  },

  "common_button_save": "Save",
  "@common_button_save": {
    "description": "Generic save button"
  },

  "common_button_delete": "Delete",
  "@common_button_delete": {
    "description": "Generic delete button"
  }
}
```

---

## 사용 예시

### Widget에서 L10n 사용

```dart
import 'package:n06/core/extensions/l10n_extension.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      child: Text(context.l10n.common_button_confirm),  // "확인" 또는 "OK"
    );
  }
}
```

### DateFormat locale 연동

```dart
import 'package:n06/core/extensions/date_format_extension.dart';

Text(DateTime.now().formatMedium(context))  // "12월 4일 (수)" 또는 "Dec 4 (Wed)"
```

### 언어 설정 변경

```dart
import 'package:n06/features/settings/application/notifiers/locale_notifier.dart';

// 영어로 변경
ref.read(localeProvider.notifier).setLocale(const Locale('en'));

// 한국어로 변경
ref.read(localeProvider.notifier).setLocale(const Locale('ko'));

// 시스템 기본값으로 복원
ref.read(localeProvider.notifier).setLocale(null);
```

---

## 검증 명령어

```bash
# L10n 파일 생성
flutter gen-l10n

# ARB 파일 검증
./scripts/validate_arb.sh

# 빌드 테스트
flutter build ios --no-codesign

# build_runner (LocaleNotifier 변경 시)
dart run build_runner build --delete-conflicting-outputs
```

---

## 주의사항

1. **provider 이름**: riverpod_generator가 `localeProvider`로 생성 (`localeNotifierProvider` 아님)
2. **l10n.yaml format 옵션**: `format: icu`는 지원되지 않음 (제거)
3. **nullable-getter: false**: 컴파일 타임에 누락 키 감지 가능
