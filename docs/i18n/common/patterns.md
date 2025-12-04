# i18n 코드 변환 패턴

> 출처: docs/i18n-plan.md §6

## 6.1 기본 Text 위젯

**Before:**
```dart
Text('설정')
```

**After:**
```dart
Text(context.l10n.settings_screen_title)
```

---

## 6.2 플레이스홀더 포함

**Before:**
```dart
Text('${schedule.scheduledDoseMg}mg 투여 시간입니다.')
```

**After:**
```dart
Text(context.l10n.tracking_dose_scheduledMessage(schedule.scheduledDoseMg))
```

---

## 6.3 조건부 문자열

**Before:**
```dart
static String consecutiveDays(int days) {
  if (days == 3) return '벌써 3일째 함께하고 있어요!';
  if (days == 7) return '일주일 완주! 대단해요 🎉';
  if (days > 1) return '벌써 $days일째 함께하고 있어요.';
  return '';
}
```

**After:**
```dart
// ARB에서 plural 처리
Text(context.l10n.checkin_completion_daysMessage(days))

// app_ko.arb
{
  "checkin_completion_daysMessage": "{count, plural, =3{벌써 3일째 함께하고 있어요!} =7{일주일 완주! 대단해요 🎉} other{벌써 {count}일째 함께하고 있어요.}}"
}
```

---

## 6.4 기존 strings 클래스 마이그레이션

**Before (checkin_strings.dart):**
```dart
class GreetingStrings {
  static const morning = '좋은 아침이에요';
  static const afternoon = '오늘 하루 어떠세요?';
}

// 사용처
Text(GreetingStrings.morning)
```

**After:**
```dart
// checkin_strings.dart 제거 또는 래퍼로 변경

// 사용처
Text(context.l10n.checkin_greeting_morning)
```

---

## 6.5 Dialog/AlertDialog

**Before:**
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('계정 삭제 확인'),
    content: const Text('정말로 계정을 삭제하시겠습니까?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('취소'),
      ),
      TextButton(
        onPressed: _deleteAccount,
        child: const Text('삭제'),
      ),
    ],
  ),
);
```

**After:**
```dart
showDialog(
  context: context,
  builder: (dialogContext) => AlertDialog(
    title: Text(context.l10n.auth_deleteAccount_confirmTitle),
    content: Text(context.l10n.auth_deleteAccount_confirmMessage),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(dialogContext),
        child: Text(context.l10n.common_button_cancel),
      ),
      TextButton(
        onPressed: _deleteAccount,
        child: Text(context.l10n.common_button_delete),
      ),
    ],
  ),
);
```

---

## 6.6 DateFormat locale 연동

**Before:**
```dart
DateFormat('M월 d일 (E)', 'ko_KR').format(date)
```

**After:**
```dart
// lib/core/extensions/date_format_extension.dart
extension DateFormatL10n on DateTime {
  String formatMedium(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'ko') {
      return DateFormat('M월 d일 (E)', 'ko_KR').format(this);
    } else {
      return DateFormat('MMM d (E)', 'en_US').format(this);
    }
  }
}

// 사용처
Text(date.formatMedium(context))
```

---

## 6.7 L10n Extension 정의

```dart
// lib/core/extensions/l10n_extension.dart
import 'package:flutter/widgets.dart';
import '../../l10n/generated/app_localizations.dart';

extension L10nExtension on BuildContext {
  L10n get l10n => L10n.of(this);
}
```
