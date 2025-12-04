# i18n 에지 케이스 처리

> 출처: docs/i18n-plan.md §15

## 언어 전환 시나리오

| 시나리오 | 처리 방법 |
|---------|---------|
| 시스템 언어 변경 중 다이얼로그 열림 | MaterialApp의 locale 변경으로 자동 리빌드 |
| 지원하지 않는 언어 (일본어 등) | localeResolutionCallback에서 ko로 fallback |
| 앱 재시작 시 언어 유지 | SharedPreferences에서 locale 복원 |

---

## 백그라운드 알림 처리

> **문제**: context 없이 locale 접근 필요

### 해결 방법

```dart
// context 없이 locale 접근
Future<void> scheduleNotification(DoseSchedule schedule) async {
  // SharedPreferences에서 직접 locale 읽기
  final prefs = await SharedPreferences.getInstance();
  final localeCode = prefs.getString('app_locale') ?? 'ko';

  final message = _getLocalizedMessage(schedule, localeCode);
  await _notificationPlugin.show(message: message);
}

String _getLocalizedMessage(DoseSchedule schedule, String localeCode) {
  return switch (localeCode) {
    'en' => '${schedule.doseMg}mg dose time',
    _ => '${schedule.doseMg}mg 투여 시간입니다',
  };
}
```

### 주의사항

- 백그라운드 알림 문자열은 ARB와 별도로 하드코딩 필요
- ARB 변경 시 백그라운드 코드도 수동 동기화 필수

---

## 부분 마이그레이션 관리

마이그레이션 진행 중 상태 추적:

```markdown
<!-- docs/i18n-migration-status.md -->
| 파일 | 상태 | 남은 문자열 |
|------|------|-----------:|
| daily_checkin_screen | ✅ 완료 | 0 |
| question_card | ⏳ 진행 중 | 15 |
| red_flag_guidance | ❌ 미시작 | 20 |
```

---

## 텍스트 Overflow 방지

### 모든 Dialog에 적용

```dart
Dialog(
  child: SingleChildScrollView(  // 스크롤 가능
    child: Column(
      children: [
        Text(
          message,
          maxLines: 10,  // 최대 줄 수 제한
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  ),
)
```

### 영어 텍스트 길이 고려

- 영어는 한국어보다 평균 **30% 길어짐**
- UI 설계 시 여유 공간 확보
- 긴 텍스트는 `TextOverflow.ellipsis` 적용

---

## 특수 콘텐츠 처리

### 서버 콘텐츠 (Badge)

> **결정**: 클라이언트 매핑 방식 사용

```dart
// lib/features/dashboard/presentation/utils/badge_l10n.dart
extension BadgeL10n on BuildContext {
  String getBadgeName(String badgeId) {
    return switch (badgeId) {
      'streak_7' => l10n.dashboard_badge_streak7_name,
      'streak_14' => l10n.dashboard_badge_streak14_name,
      'streak_30' => l10n.dashboard_badge_streak30_name,
      'first_checkin' => l10n.dashboard_badge_firstCheckin_name,
      'weight_goal' => l10n.dashboard_badge_weightGoal_name,
      _ => badgeId,  // fallback
    };
  }
}
```

### Push Notification

```dart
// 로컬 알림: ARB에서 관리
// lib/features/notification/application/dose_notification_usecase.dart

final message = l10n.tracking_dose_scheduledMessage(schedule.scheduledDoseMg);

// 주의: 백그라운드 알림은 context 없이 처리해야 함
// → lookupL10n() 사용 또는 SharedPreferences에서 locale 로드
```

### 법적 문서

```dart
// URL은 언어별로 동일 (서버에서 Accept-Language 헤더로 분기)
// 또는 URL에 locale 파라미터 추가
class LegalUrls {
  static String privacyPolicy(Locale locale) =>
    'https://your-domain.com/privacy?lang=${locale.languageCode}';
}
```

---

## 단위/포맷

| 항목 | 한국어 | 영어 |
|-----|-------|-----|
| 체중 | kg | kg (동일) |
| 용량 | mg | mg (동일) |
| 날짜 | 2024년 1월 15일 | Jan 15, 2024 |
| 시간 | 14:30 | 2:30 PM |

### DateFormat locale 연동

```dart
// DateFormat은 locale에 따라 자동 변환
DateFormat.yMMMd(locale).format(date)
```

---

## 특수 문자 처리

### 줄바꿈 (\n)

ARB에서 줄바꿈은 `\n`으로 표현:

```json
{
  "checkin_redFlag_pancreatitis": "윗배 통증이 등 쪽으로도 느껴지고,\n몇 시간 이상 지속되셨군요."
}
```

### 이모지

이모지는 양 언어에서 동일하게 사용:

```json
{
  "checkin_completion_streak7": "일주일 완주! 대단해요 🎉"
}
```

### 특수 문자 이스케이프

```json
{
  "example_quote": "\"따옴표\" 사용 예시",
  "example_backslash": "역슬래시 \\\\ 사용"
}
```

---

## 플레이스홀더 타입별 처리

### int

```json
{
  "message": "{count}개",
  "@message": {
    "placeholders": {
      "count": { "type": "int" }
    }
  }
}
```

### double (소수점)

```json
{
  "message": "{weight}kg",
  "@message": {
    "placeholders": {
      "weight": {
        "type": "double",
        "format": "decimalPattern"
      }
    }
  }
}
```

### String

```json
{
  "message": "안녕하세요, {name}님",
  "@message": {
    "placeholders": {
      "name": { "type": "String" }
    }
  }
}
```

### DateTime

```json
{
  "message": "{date}에 예정",
  "@message": {
    "placeholders": {
      "date": {
        "type": "DateTime",
        "format": "yMd"
      }
    }
  }
}
```
