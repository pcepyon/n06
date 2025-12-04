# Phase 10: Record Management

> 출처: docs/i18n-plan.md §5 Phase 10

## 개요

- **목적**: 기록 목록 화면 i18n
- **선행 조건**: Phase 0, Phase 1 완료
- **문자열 수**: ~20개
- **난이도**: 낮음

---

## 작업 목록

| 작업 | 파일 | 문자열 수 |
|-----|------|---------:|
| 기록 목록 | `record_list_screen.dart`, `record_list_card.dart` | ~20 |

---

## ARB 키 목록 (예상)

### 기록 목록 화면

```json
{
  "records_screen_title": "기록 목록",
  "records_filter_all": "전체",
  "records_filter_checkin": "체크인",
  "records_filter_dose": "투약",
  "records_filter_weight": "체중",
  "records_empty_message": "아직 기록이 없어요",
  "records_empty_startButton": "첫 기록 시작하기"
}
```

### 기록 카드

```json
{
  "records_card_checkin": "데일리 체크인",
  "records_card_dose": "투약 기록",
  "records_card_weight": "체중 기록",
  "records_card_symptoms": "증상: {symptoms}",
  "@records_card_symptoms": {
    "placeholders": {
      "symptoms": {
        "type": "String"
      }
    }
  },
  "records_card_doseAmount": "{dose}mg 투약",
  "records_card_weightValue": "{weight}kg"
}
```

### 날짜 표시

```json
{
  "records_date_today": "오늘",
  "records_date_yesterday": "어제"
}
```

---

## 대상 파일 (경로 확인 필요)

```
lib/features/records/presentation/
├── screens/
│   └── record_list_screen.dart
└── widgets/
    └── record_list_card.dart
```

---

## 완료 기준

```
[ ] 기록 목록 화면 문자열 ARB 추가 (ko, en)
[ ] 기록 카드 문자열 ARB 추가 (ko, en)
[ ] 날짜 표시 문자열 ARB 추가 (ko, en)
[ ] 플레이스홀더 처리 검증
[ ] 모든 사용처 context.l10n으로 변경
[ ] 빌드 성공
```

---

## Phase 10 완료 = 전체 i18n 완료

Phase 10 완료 후 최종 검증:

```
[ ] 전체 ARB 키 수 확인 (~1,383개)
[ ] 한국어/영어 키 일치 확인
[ ] 전체 빌드 성공
[ ] 언어 전환 테스트 (전체 화면)
[ ] 의료 콘텐츠 검수 완료 확인
```
