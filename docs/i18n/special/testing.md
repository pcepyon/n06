# i18n 테스트 전략

> 출처: docs/i18n-plan.md §14

## 테스트 헬퍼

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

---

## 다국어 UI 테스트 예시

### 한국어 테스트

```dart
testWidgets('displays Korean text', (tester) async {
  await tester.pumpWidget(
    L10nTestHelper.wrapWithL10n(
      const LogoutConfirmDialog(),
      locale: const Locale('ko'),
    ),
  );
  expect(find.text('로그아웃'), findsOneWidget);
});
```

### 영어 테스트

```dart
testWidgets('displays English text', (tester) async {
  await tester.pumpWidget(
    L10nTestHelper.wrapWithL10n(
      const LogoutConfirmDialog(),
      locale: const Locale('en'),
    ),
  );
  expect(find.text('Logout'), findsOneWidget);
});
```

---

## Overflow 테스트

```dart
testWidgets('long English text does not overflow', (tester) async {
  // 작은 화면 시뮬레이션
  tester.binding.window.physicalSizeTestValue = const Size(300, 600);

  await tester.pumpWidget(
    L10nTestHelper.wrapWithL10n(
      const RedFlagGuidanceDialog(...),
      locale: const Locale('en'),
    ),
  );

  // overflow 없어야 함
  expect(tester.takeException(), isNull);
});
```

---

## 테스트 체크리스트

### 모든 화면에 적용

```
[ ] 한국어 텍스트 표시 확인
[ ] 영어 텍스트 표시 확인
[ ] 플레이스홀더 값 정상 표시
[ ] 복수형 처리 정상 동작
[ ] Overflow 없음 확인
```

### 언어 전환 테스트

```dart
testWidgets('language switch updates UI', (tester) async {
  // 초기 한국어
  await tester.pumpWidget(
    ProviderScope(
      child: L10nTestHelper.wrapWithL10n(
        const SettingsScreen(),
        locale: const Locale('ko'),
      ),
    ),
  );
  expect(find.text('설정'), findsOneWidget);

  // 영어로 전환
  // ... locale 변경 로직
  await tester.pumpAndSettle();
  expect(find.text('Settings'), findsOneWidget);
});
```

---

## CI/CD 통합

### ARB 검증 스크립트

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

### GitHub Actions 설정

```yaml
# .github/workflows/i18n-check.yml
name: i18n Check
on: [push, pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter gen-l10n
      - run: chmod +x scripts/validate_arb.sh && ./scripts/validate_arb.sh
```

---

## 품질 보증

### 컴파일 타임 검증

```yaml
# l10n.yaml
nullable-getter: false  # null 반환 방지 → 컴파일 에러로 누락 감지
```

### 텍스트 Overflow 검증

```dart
// 1. 영어는 한국어보다 평균 30% 길어짐을 감안
// 2. 테스트 시 pseudo-localization 활용

// 개발 중 긴 텍스트 시뮬레이션
Text(
  kDebugMode ? '${text} [extended for testing]' : text,
  overflow: TextOverflow.ellipsis,
)
```

### 누락 키 검증 스크립트

```bash
# scripts/check_l10n.sh
flutter gen-l10n
grep -r "context.l10n\." lib/ | grep -v "generated" | \
  while read line; do
    key=$(echo $line | grep -oP 'l10n\.\K[a-zA-Z_]+')
    if ! grep -q "\"$key\"" lib/l10n/app_ko.arb; then
      echo "Missing key: $key"
    fi
  done
```

---

## Fallback 전략

```dart
// gen_l10n은 지원하지 않는 locale에 대해 기본 locale(ko)로 fallback
// 추가 fallback은 불필요
```
