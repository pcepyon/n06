# Phase 5: Daily Checkin

> 출처: docs/i18n-plan.md §5 Phase 5

## 개요

- **목적**: 데일리 체크인 화면 i18n + checkin_strings.dart 마이그레이션
- **선행 조건**: Phase 0, Phase 1 완료
- **문자열 수**: ~220개
- **난이도**: 높음 (마이그레이션 필요)

---

## 작업 목록

| 작업 | 파일 | 문자열 수 |
|-----|------|---------:|
| 기존 strings 마이그레이션 | `checkin_strings.dart` → ARB | ~150 |
| 체크인 화면 | `daily_checkin_screen.dart` | ~15 |
| 질문 카드 | `question_card.dart`, `answer_button.dart` | ~10 |
| 체중 입력 | `weight_input_section.dart` | ~10 |
| Red Flag 안내 | `red_flag_guidance_dialog.dart`, `red_flag_guidance_sheet.dart` | ~20 |
| 완료 화면 | `share_report_screen.dart` | ~15 |

---

## 핵심 작업: checkin_strings.dart 마이그레이션

### 마이그레이션 순서

```
1. checkin_strings.dart 내용 분석
2. ARB에 모든 키 추가
3. 사용처를 context.l10n으로 변경
4. 모든 참조 제거 확인 (grep으로 검증)
5. checkin_strings.dart 삭제
```

### 주의사항

- `checkin_strings.dart`에 150+ 상수가 있음
- 모든 참조가 제거되기 전까지 파일 삭제 금지
- 시간대별 인사말 (morning, afternoon, evening) plural 처리

---

## ARB 키 목록 (예상)

### 인사말 (시간대별)

```json
{
  "checkin_greeting_morning": "좋은 아침이에요",
  "checkin_greeting_afternoon": "오늘 하루 어떠세요?",
  "checkin_greeting_evening": "오늘도 수고하셨어요",
  "checkin_greeting_night": "오늘 하루 마무리 잘 하세요"
}
```

### 체중 입력

```json
{
  "checkin_weightInput_title": "오늘 체중을 입력해주세요",
  "checkin_weightInput_hint": "체중 (kg)",
  "checkin_weightInput_feedbackDecreased": "조금 줄었네요! 💚",
  "checkin_weightInput_feedbackIncreased": "조금 늘었지만 괜찮아요",
  "checkin_weightInput_feedbackMaintained": "잘 유지하고 계시네요"
}
```

### 증상 질문

```json
{
  "checkin_symptom_question": "오늘 불편한 증상이 있었나요?",
  "checkin_symptom_nausea": "메스꺼움",
  "checkin_symptom_vomiting": "구토",
  "checkin_symptom_constipation": "변비",
  "checkin_symptom_diarrhea": "설사",
  "checkin_symptom_stomachPain": "복통",
  "checkin_symptom_headache": "두통",
  "checkin_symptom_fatigue": "피로",
  "checkin_symptom_heartburn": "속쓰림",
  "checkin_symptom_bloating": "배가 빵빵함",
  "checkin_symptom_dizziness": "어지러움",
  "checkin_symptom_none": "없었어요"
}
```

### Red Flag 안내 (의료 콘텐츠 - 검수 필요)

> **주의**: 이 메시지들은 의료진 검수 필수

```json
{
  "checkin_redFlag_pancreatitis": "윗배 통증이 등 쪽으로도 느껴지고,\n몇 시간 이상 지속되셨군요.\n\n이런 경우 드물지만 확인이 필요할 때가 있어요.\n오늘 중으로 가까운 병원에 들러서\n한 번 확인받아 보시는 게 안심이 될 것 같아요.\n\n💡 응급실이 아니어도 괜찮아요.\n   가까운 내과에서 확인받으시면 돼요.",
  "@checkin_redFlag_pancreatitis": {
    "description": "Pancreatitis warning - MEDICAL REVIEW REQUIRED"
  },

  "checkin_redFlag_cholecystitis": "오른쪽 윗배 통증이...",
  "@checkin_redFlag_cholecystitis": {
    "description": "Cholecystitis warning - MEDICAL REVIEW REQUIRED"
  },

  "checkin_redFlag_bowelObstruction": "구토와 함께 배가...",
  "@checkin_redFlag_bowelObstruction": {
    "description": "Bowel obstruction warning - MEDICAL REVIEW REQUIRED"
  }
}
```

### 연속 일수 메시지 (복수형)

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

---

## 대상 파일 (경로 확인 필요)

```
lib/features/daily_checkin/
├── presentation/
│   ├── screens/
│   │   ├── daily_checkin_screen.dart
│   │   └── share_report_screen.dart
│   ├── widgets/
│   │   ├── question_card.dart
│   │   ├── answer_button.dart
│   │   ├── weight_input_section.dart
│   │   ├── red_flag_guidance_dialog.dart
│   │   └── red_flag_guidance_sheet.dart
│   └── constants/
│       └── checkin_strings.dart  ← 마이그레이션 후 삭제
```

---

## 마이그레이션 검증

```bash
# checkin_strings.dart 참조 검색
grep -r "checkin_strings" lib/
grep -r "GreetingStrings" lib/
grep -r "SymptomStrings" lib/
# ... 기타 클래스명

# 결과가 없어야 삭제 가능
```

---

## 완료 기준

```
[ ] checkin_strings.dart 전체 분석
[ ] ARB에 모든 키 추가 (ko, en)
[ ] 체크인 화면 문자열 변환
[ ] 질문 카드 문자열 변환
[ ] 체중 입력 문자열 변환
[ ] Red Flag 안내 문자열 변환 (의료 검수 태그 포함)
[ ] 완료 화면 문자열 변환
[ ] 복수형 처리 검증
[ ] checkin_strings.dart 참조 0개 확인
[ ] checkin_strings.dart 삭제
[ ] 빌드 성공
```
