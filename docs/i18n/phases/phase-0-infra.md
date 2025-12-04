# Phase 0: 인프라 설정

> 출처: docs/i18n-plan.md §2, §5 Phase 0

## 개요

- **목적**: i18n 기반 인프라 구축
- **선행 조건**: 없음
- **후속 Phase**: 모든 Phase의 전제조건

---

## 작업 목록

| # | 작업 | 파일 | 상세 |
|---|-----|------|-----|
| 1 | l10n.yaml 생성 | `l10n.yaml` | gen_l10n 설정 (nullable-getter: false) |
| 2 | .gitignore 업데이트 | `.gitignore` | lib/l10n/generated/ 추가 |
| 3 | pubspec.yaml 수정 | `pubspec.yaml` | flutter_localizations, generate: true |
| 4 | ARB 파일 초기화 | `lib/l10n/app_ko.arb`, `app_en.arb` | 빈 템플릿 생성 |
| 5 | L10n Extension 생성 | `lib/core/extensions/l10n_extension.dart` | `context.l10n` 헬퍼 |
| 6 | DateFormat Extension | `lib/core/extensions/date_format_extension.dart` | locale 연동 날짜 포맷 |
| 7 | MaterialApp 설정 | `lib/main.dart` | localizationsDelegates 추가 |
| 8 | LocaleNotifier 생성 | `lib/features/settings/application/notifiers/locale_notifier.dart` | 언어 설정 상태 관리 |
| 9 | 테스트 헬퍼 생성 | `test/helpers/l10n_test_helper.dart` | L10n 모킹 유틸 |
| 10 | ARB 검증 스크립트 | `scripts/validate_arb.sh` | CI/CD 통합용 |
| 11 | 첫 번역 테스트 | - | common_button_confirm 키로 빌드 검증 |

---

## 상세 구현

### 1. l10n.yaml 생성

```yaml
# l10n.yaml (프로젝트 루트)
arb-dir: lib/l10n
template-arb-file: app_ko.arb
output-localization-file: app_localizations.dart
output-class: L10n
output-dir: lib/l10n/generated
nullable-getter: false
use-deferred-loading: false
format: icu
```

### 2. .gitignore 업데이트

```gitignore
# L10n generated files
lib/l10n/generated/
lib/l10n/*.g.dart
```

### 3. pubspec.yaml 수정

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.2  # 기존 유지

flutter:
  generate: true  # 추가
```

### 4. ARB 파일 초기화

**lib/l10n/app_ko.arb:**
```json
{
  "@@locale": "ko",
  "common_button_confirm": "확인",
  "@common_button_confirm": {
    "description": "Generic confirm button"
  }
}
```

**lib/l10n/app_en.arb:**
```json
{
  "@@locale": "en",
  "common_button_confirm": "OK",
  "@common_button_confirm": {
    "description": "Generic confirm button"
  }
}
```

### 5. L10n Extension 생성

```dart
// lib/core/extensions/l10n_extension.dart
import 'package:flutter/widgets.dart';
import '../../l10n/generated/app_localizations.dart';

extension L10nExtension on BuildContext {
  L10n get l10n => L10n.of(this);
}
```

### 6. DateFormat Extension

```dart
// lib/core/extensions/date_format_extension.dart
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

extension DateFormatL10n on DateTime {
  String formatMedium(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'ko') {
      return DateFormat('M월 d일 (E)', 'ko_KR').format(this);
    } else {
      return DateFormat('MMM d (E)', 'en_US').format(this);
    }
  }

  String formatFull(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'ko') {
      return DateFormat('yyyy년 M월 d일', 'ko_KR').format(this);
    } else {
      return DateFormat('MMMM d, yyyy', 'en_US').format(this);
    }
  }

  String formatTime(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'ko') {
      return DateFormat('HH:mm', 'ko_KR').format(this);
    } else {
      return DateFormat('h:mm a', 'en_US').format(this);
    }
  }
}
```

### 7. MaterialApp 설정

```dart
// lib/main.dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/generated/app_localizations.dart';
import 'features/settings/application/notifiers/locale_notifier.dart';

MaterialApp.router(
  localizationsDelegates: const [
    L10n.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: L10n.supportedLocales,
  locale: ref.watch(localeProvider),  // null이면 시스템 언어
  localeResolutionCallback: (locale, supportedLocales) {
    // 지원하지 않는 언어면 한국어로 fallback
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale?.languageCode) {
        return supportedLocale;
      }
    }
    return const Locale('ko');
  },
);
```

> **Note**: provider 이름은 riverpod_generator가 `localeProvider`로 생성함 (`localeNotifierProvider` 아님)

### 8. LocaleNotifier 생성

```dart
// lib/features/settings/application/notifiers/locale_notifier.dart
import 'dart:ui';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'locale_notifier.g.dart';

@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  static const _key = 'app_locale';

  @override
  Locale? build() {
    // SharedPreferences에서 저장된 값 로드
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedLocale = prefs.getString(_key);
    if (savedLocale != null) {
      return Locale(savedLocale);
    }
    return null;  // null = 시스템 기본값 (디바이스 감지)
  }

  Future<void> setLocale(Locale? locale) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (locale == null) {
      await prefs.remove(_key);  // 시스템 기본값으로 복귀
    } else {
      await prefs.setString(_key, locale.languageCode);
    }
    state = locale;
  }
}
```

### 9. 테스트 헬퍼 생성

```dart
// test/helpers/l10n_test_helper.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:n06/l10n/generated/app_localizations.dart';

class L10nTestHelper {
  /// 특정 locale로 Widget을 래핑
  static Widget wrapWithL10n(
    Widget child, {
    Locale locale = const Locale('ko'),
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        L10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: L10n.supportedLocales,
      locale: locale,
      home: Scaffold(body: child),
    );
  }
}
```

### 10. ARB 검증 스크립트

```bash
#!/bin/bash
# scripts/validate_arb.sh
set -e

echo "🔍 Validating ARB files..."

# JSON 구조 검증
for file in lib/l10n/app_*.arb; do
  if ! jq empty "$file" 2>/dev/null; then
    echo "❌ Invalid JSON: $file"
    exit 1
  fi
done

# 키 일관성 검증
ko_keys=$(jq -r 'keys[] | select(startswith("@") | not)' lib/l10n/app_ko.arb | sort)
en_keys=$(jq -r 'keys[] | select(startswith("@") | not)' lib/l10n/app_en.arb | sort)

missing=$(comm -23 <(echo "$ko_keys") <(echo "$en_keys"))
if [ -n "$missing" ]; then
  echo "⚠️ Missing English keys:"
  echo "$missing"
fi

echo "✅ ARB validation passed"
```

---

## 검증 명령어

```bash
# 1. 의존성 설치
flutter pub get

# 2. L10n 코드 생성
flutter gen-l10n

# 3. 빌드 검증
flutter build ios --no-codesign
# 또는
flutter build apk --debug

# 4. 테스트 실행
flutter test
```

---

## 완료 기준

```
[ ] l10n.yaml 생성 완료
[ ] .gitignore 업데이트 완료
[ ] pubspec.yaml 수정 완료
[ ] lib/l10n/app_ko.arb 생성 완료
[ ] lib/l10n/app_en.arb 생성 완료
[ ] flutter gen-l10n 성공
[ ] lib/l10n/generated/app_localizations.dart 생성 확인
[ ] L10n Extension 생성 완료
[ ] DateFormat Extension 생성 완료
[ ] MaterialApp 설정 완료
[ ] LocaleNotifier 생성 완료
[ ] 테스트 헬퍼 생성 완료
[ ] ARB 검증 스크립트 생성 완료
[ ] flutter pub get 성공
[ ] 빌드 성공 확인
[ ] context.l10n.common_button_confirm 컴파일 성공
```
