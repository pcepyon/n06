# i18n 키 네이밍 컨벤션

> 출처: docs/i18n-plan.md §3

## 규칙

```
{feature}_{screen/widget}_{element}_{variant}
```

| 세그먼트 | 설명 | 예시 |
|---------|------|------|
| feature | 기능 모듈 | `checkin`, `tracking`, `dashboard` |
| screen/widget | 화면 또는 위젯 | `greeting`, `weightInput`, `redFlag` |
| element | UI 요소 유형 | `title`, `button`, `label`, `message`, `hint` |
| variant | 상태/변형 (선택) | `morning`, `error`, `success` |

---

## 예시

```json
{
  "checkin_greeting_morning": "좋은 아침이에요",
  "@checkin_greeting_morning": {
    "description": "Morning greeting (5-11 AM)"
  },

  "checkin_weightInput_title": "오늘 체중을 입력해주세요",
  "@checkin_weightInput_title": {
    "description": "Weight input screen title"
  },

  "checkin_weightInput_feedbackDecreased": "조금 줄었네요! 💚",
  "@checkin_weightInput_feedbackDecreased": {
    "description": "Feedback when weight decreased"
  },

  "checkin_redFlag_pancreatitis": "윗배 통증이 등 쪽으로도 느껴지고,\n몇 시간 이상 지속되셨군요.\n\n이런 경우 드물지만 확인이 필요할 때가 있어요.\n오늘 중으로 가까운 병원에 들러서\n한 번 확인받아 보시는 게 안심이 될 것 같아요.\n\n💡 응급실이 아니어도 괜찮아요.\n   가까운 내과에서 확인받으시면 돼요.",
  "@checkin_redFlag_pancreatitis": {
    "description": "Pancreatitis warning message - MEDICAL REVIEW REQUIRED"
  },

  "tracking_calendar_title": "투약 달력",
  "@tracking_calendar_title": {
    "description": "Dose calendar screen title"
  },

  "tracking_symptom_nausea": "메스꺼움",
  "@tracking_symptom_nausea": {
    "description": "Symptom: Nausea - MEDICAL TERM"
  },

  "dashboard_badge_streak7_name": "7일 연속",
  "@dashboard_badge_streak7_name": {
    "description": "Badge name for 7-day streak"
  },

  "settings_menu_termsOfService": "이용약관",
  "@settings_menu_termsOfService": {
    "description": "Terms of service menu item"
  },

  "common_button_confirm": "확인",
  "@common_button_confirm": {
    "description": "Generic confirm button"
  },

  "common_error_networkFailed": "네트워크 연결을 확인해주세요",
  "@common_error_networkFailed": {
    "description": "Network error message"
  }
}
```

---

## 플레이스홀더 처리

```json
{
  "checkin_completion_consecutiveDays": "벌써 {days}일째 함께하고 있어요.",
  "@checkin_completion_consecutiveDays": {
    "description": "Consecutive days message",
    "placeholders": {
      "days": {
        "type": "int",
        "example": "5"
      }
    }
  },

  "tracking_dose_scheduledMessage": "{dose}mg 투여 시간입니다.",
  "@tracking_dose_scheduledMessage": {
    "placeholders": {
      "dose": {
        "type": "double",
        "format": "decimalPattern"
      }
    }
  },

  "tracking_weight_changeMessage": "꾸준히 변화하고 있어요! ({change}kg)",
  "@tracking_weight_changeMessage": {
    "placeholders": {
      "change": {
        "type": "double",
        "format": "decimalPattern"
      }
    }
  }
}
```

---

## 복수형 처리

```json
{
  "checkin_completion_daysMessage": "{count, plural, =1{첫 날이에요!} =3{벌써 3일째 함께하고 있어요!} =7{일주일 완주! 대단해요 🎉} =14{2주 동안 꾸준히 기록하셨네요!} =21{3주! 이제 습관이 되셨을 거예요} =30{한 달 완주! 정말 대단해요 🏆} other{벌써 {count}일째 함께하고 있어요.}}",
  "@checkin_completion_daysMessage": {
    "placeholders": {
      "count": {
        "type": "int"
      }
    }
  }
}
```
