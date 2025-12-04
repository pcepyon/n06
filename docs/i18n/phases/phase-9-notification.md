# Phase 9: Notification

> 출처: docs/i18n-plan.md §5 Phase 9

## 개요

- **목적**: 알림 설정 및 알림 메시지 i18n
- **선행 조건**: Phase 0, Phase 1 완료
- **문자열 수**: ~40개
- **특수 처리**: 백그라운드 알림 (context 없음)

---

## 작업 목록

| 작업 | 파일 | 문자열 수 |
|-----|------|---------:|
| 알림 설정 | `notification_settings_screen.dart` | ~30 |
| 알림 메시지 | `dose_notification_usecase.dart` | ~10 |

---

## 특수 처리: 백그라운드 알림

> **중요**: 백그라운드에서는 BuildContext가 없음

### 문제

```dart
// ❌ 백그라운드에서 context 접근 불가
Future<void> showDoseNotification() async {
  final message = context.l10n.tracking_dose_scheduledMessage(dose);  // 에러!
}
```

### 해결 방법

```dart
// ✅ SharedPreferences에서 직접 locale 읽기
Future<void> scheduleNotification(DoseSchedule schedule) async {
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

- 백그라운드 알림 문자열은 **하드코딩 불가피**
- ARB와 **수동 동기화** 필요
- 문자열 변경 시 양쪽 모두 업데이트 필수

---

## ARB 키 목록 (예상)

### 알림 설정 화면

```json
{
  "notification_settings_title": "알림 설정",
  "notification_settings_doseReminder": "투약 알림",
  "notification_settings_doseReminderDescription": "투약 시간에 알림을 받습니다",
  "notification_settings_checkinReminder": "체크인 알림",
  "notification_settings_checkinReminderDescription": "매일 체크인 시간에 알림을 받습니다",
  "notification_settings_time": "알림 시간",
  "notification_settings_enabled": "켜짐",
  "notification_settings_disabled": "꺼짐"
}
```

### 알림 메시지 (ARB + 백그라운드 하드코딩)

```json
{
  "notification_dose_title": "투약 시간",
  "notification_dose_body": "{dose}mg 투여 시간입니다.",
  "@notification_dose_body": {
    "placeholders": {
      "dose": {
        "type": "double",
        "format": "decimalPattern"
      }
    }
  },
  "notification_checkin_title": "체크인 시간",
  "notification_checkin_body": "오늘의 상태를 기록해주세요"
}
```

---

## 백그라운드 메시지 동기화 체크리스트

| ARB 키 | 백그라운드 함수 | 한국어 | 영어 |
|--------|---------------|--------|------|
| `notification_dose_body` | `_getLocalizedMessage` | ✅ | ✅ |
| `notification_checkin_body` | `_getCheckinMessage` | ✅ | ✅ |

---

## 대상 파일 (경로 확인 필요)

```
lib/features/notification/
├── presentation/
│   └── screens/
│       └── notification_settings_screen.dart
└── application/
    └── usecases/
        └── dose_notification_usecase.dart
```

---

## 완료 기준

```
[ ] 알림 설정 화면 문자열 ARB 추가 (ko, en)
[ ] 알림 메시지 ARB 추가 (ko, en)
[ ] 백그라운드 알림 하드코딩 추가 (ko, en)
[ ] ARB ↔ 백그라운드 메시지 동기화 검증
[ ] 모든 사용처 context.l10n으로 변경
[ ] 백그라운드 알림 테스트
[ ] 빌드 성공
```
