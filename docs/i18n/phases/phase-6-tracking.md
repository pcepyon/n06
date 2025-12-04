# Phase 6: Tracking

> 출처: docs/i18n-plan.md §5 Phase 6

## 개요

- **목적**: 투약 기록, 달력, 트렌드 대시보드 i18n
- **선행 조건**: Phase 0, Phase 1 완료
- **문자열 수**: ~190개

---

## 작업 목록

| 작업 | 파일 | 문자열 수 |
|-----|------|---------:|
| 일일 기록 | `daily_tracking_screen.dart` | ~50 |
| 투약 달력 | `dose_calendar_screen.dart` | ~25 |
| 투약 기록 다이얼로그 | `dose_record_dialog_v2.dart`, `off_schedule_dose_dialog.dart` | ~30 |
| 트렌드 대시보드 | `trend_dashboard_screen.dart` | ~30 |
| 투약 계획 편집 | `edit_dosage_plan_screen.dart` | ~35 |
| 응급 체크 | `emergency_check_screen.dart` | ~20 |

---

## ARB 키 목록 (예상)

### 투약 달력

```json
{
  "tracking_calendar_title": "투약 달력",
  "tracking_calendar_today": "오늘",
  "tracking_calendar_doseRecorded": "투약 완료",
  "tracking_calendar_doseMissed": "미투약",
  "tracking_calendar_noRecord": "기록 없음"
}
```

### 투약 기록

```json
{
  "tracking_dose_title": "투약 기록",
  "tracking_dose_recordButton": "투약 기록하기",
  "tracking_dose_scheduledMessage": "{dose}mg 투여 시간입니다.",
  "@tracking_dose_scheduledMessage": {
    "placeholders": {
      "dose": {
        "type": "double",
        "format": "decimalPattern"
      }
    }
  },
  "tracking_dose_recordedAt": "{time}에 투약 완료",
  "tracking_dose_siteLabel": "주사 부위",
  "tracking_dose_site_abdomen": "복부",
  "tracking_dose_site_thigh": "허벅지",
  "tracking_dose_site_arm": "팔"
}
```

### 트렌드 대시보드

```json
{
  "tracking_trend_title": "트렌드",
  "tracking_trend_weight": "체중 변화",
  "tracking_trend_symptom": "증상 추이",
  "tracking_trend_period_week": "1주",
  "tracking_trend_period_month": "1개월",
  "tracking_trend_period_3months": "3개월",
  "tracking_trend_noData": "데이터가 없습니다"
}
```

### 투약 계획 편집

```json
{
  "tracking_dosagePlan_title": "투약 계획",
  "tracking_dosagePlan_currentDose": "현재 용량",
  "tracking_dosagePlan_nextIncrease": "다음 증량 예정",
  "tracking_dosagePlan_targetDose": "목표 용량",
  "tracking_dosagePlan_schedule": "투약 요일",
  "tracking_dosagePlan_time": "투약 시간",
  "tracking_dosagePlan_editButton": "계획 수정"
}
```

### 응급 체크 (의료 콘텐츠)

```json
{
  "tracking_emergency_title": "응급 확인",
  "tracking_emergency_question": "지금 심각한 증상이 있으신가요?",
  "tracking_emergency_callButton": "응급실 연락하기",
  "tracking_emergency_dismiss": "괜찮아요"
}
```

### 체중 변화 메시지

```json
{
  "tracking_weight_changeMessage": "꾸준히 변화하고 있어요! ({change}kg)",
  "@tracking_weight_changeMessage": {
    "placeholders": {
      "change": {
        "type": "double",
        "format": "decimalPattern"
      }
    }
  },
  "tracking_weight_noChange": "체중이 유지되고 있어요",
  "tracking_weight_increased": "{amount}kg 늘었어요",
  "tracking_weight_decreased": "{amount}kg 줄었어요"
}
```

---

## 대상 파일 (경로 확인 필요)

```
lib/features/tracking/presentation/
├── screens/
│   ├── daily_tracking_screen.dart
│   ├── dose_calendar_screen.dart
│   ├── trend_dashboard_screen.dart
│   ├── edit_dosage_plan_screen.dart
│   └── emergency_check_screen.dart
├── widgets/
│   ├── dose_record_dialog_v2.dart
│   └── off_schedule_dose_dialog.dart
```

---

## 완료 기준

```
[ ] 일일 기록 화면 문자열 ARB 추가 (ko, en)
[ ] 투약 달력 문자열 ARB 추가 (ko, en)
[ ] 투약 기록 다이얼로그 문자열 ARB 추가 (ko, en)
[ ] 트렌드 대시보드 문자열 ARB 추가 (ko, en)
[ ] 투약 계획 편집 문자열 ARB 추가 (ko, en)
[ ] 응급 체크 문자열 ARB 추가 (ko, en)
[ ] 플레이스홀더 처리 검증 (dose, change 등)
[ ] 모든 사용처 context.l10n으로 변경
[ ] 빌드 성공
```
