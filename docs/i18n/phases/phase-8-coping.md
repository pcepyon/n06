# Phase 8: Coping Guide

> 출처: docs/i18n-plan.md §5 Phase 8

## 개요

- **목적**: 부작용 대처법 가이드 i18n (의료 콘텐츠)
- **선행 조건**: Phase 0, Phase 1 완료, **의료 콘텐츠 검수**
- **문자열 수**: ~245개
- **난이도**: 높음 (의료 콘텐츠)

---

## 작업 목록

| 작업 | 파일 | 문자열 수 |
|-----|------|---------:|
| 가이드 화면 | `coping_guide_screen.dart`, `detailed_guide_screen.dart` | ~30 |
| 정적 데이터 | `static_coping_guide_repository.dart` | ~200 |
| 피드백 위젯 | `feedback_widget.dart`, `coping_guide_feedback_result.dart` | ~15 |

---

## 의료 콘텐츠 주의사항

> **중요**: 이 Phase의 모든 콘텐츠는 의료 검수 필수

### 검수 프로세스

```
1단계: 초벌 번역 (AI 또는 번역가)
   ↓
2단계: 의료 용어 검수 (의료진/약사)
   - Red Flag 메시지 정확성
   - 증상 설명의 적절성
   - 행동 지침의 안전성
   ↓
3단계: UX 라이팅 검토
   - 톤 & 보이스 일관성
   - 길이 적절성 (UI overflow 방지)
   ↓
4단계: 네이티브 스피커 검토 (영어)
```

### ARB 메타데이터

```json
{
  "coping_nausea_title": "메스꺼움 대처법",
  "@coping_nausea_title": {
    "description": "Nausea coping guide title - MEDICAL REVIEW REQUIRED",
    "context": "Coping guide screen",
    "reviewed_by": "",
    "review_date": "",
    "review_status": "PENDING"
  }
}
```

---

## ARB 키 목록 (예상)

### 가이드 화면

```json
{
  "coping_screen_title": "대처법 가이드",
  "coping_screen_subtitle": "증상별 대처법을 알려드릴게요",
  "coping_screen_selectSymptom": "증상을 선택하세요"
}
```

### 메스꺼움 대처법

```json
{
  "coping_nausea_title": "메스꺼움",
  "coping_nausea_description": "GLP-1 약물의 가장 흔한 부작용이에요",
  "coping_nausea_tip1_title": "소량씩 자주 드세요",
  "coping_nausea_tip1_detail": "한 번에 많이 먹지 않고, 조금씩 여러 번 나눠서 드세요",
  "coping_nausea_tip2_title": "기름진 음식을 피하세요",
  "coping_nausea_tip2_detail": "지방이 많은 음식은 소화를 느리게 해서 메스꺼움을 악화시킬 수 있어요",
  "coping_nausea_tip3_title": "생강을 활용해보세요",
  "coping_nausea_tip3_detail": "생강차나 생강 캔디가 메스꺼움을 줄이는 데 도움이 될 수 있어요",
  "coping_nausea_whenToSeekHelp": "구토가 지속되거나 수분 섭취가 어려우면 의사와 상담하세요"
}
```

### 변비 대처법

```json
{
  "coping_constipation_title": "변비",
  "coping_constipation_description": "장 운동이 느려지면서 생길 수 있어요",
  "coping_constipation_tip1_title": "물을 충분히 드세요",
  "coping_constipation_tip1_detail": "하루 8잔 이상의 물을 마시는 것이 좋아요",
  "coping_constipation_tip2_title": "식이섬유를 늘리세요",
  "coping_constipation_tip2_detail": "채소, 과일, 통곡물을 충분히 드세요",
  "coping_constipation_tip3_title": "가벼운 운동을 해보세요",
  "coping_constipation_tip3_detail": "걷기 같은 가벼운 운동이 장 운동에 도움이 돼요"
}
```

### 피로 대처법

```json
{
  "coping_fatigue_title": "피로",
  "coping_fatigue_description": "몸이 약물에 적응하는 과정에서 느낄 수 있어요",
  "coping_fatigue_tip1_title": "충분히 쉬세요",
  "coping_fatigue_tip1_detail": "몸이 적응하는 동안 충분한 수면이 중요해요",
  "coping_fatigue_tip2_title": "단백질 섭취를 확인하세요",
  "coping_fatigue_tip2_detail": "식사량이 줄면 단백질도 부족해질 수 있어요"
}
```

### 피드백 위젯

```json
{
  "coping_feedback_question": "이 정보가 도움이 되었나요?",
  "coping_feedback_helpful": "도움이 됐어요",
  "coping_feedback_notHelpful": "도움이 안 됐어요",
  "coping_feedback_thanks": "피드백 감사합니다"
}
```

---

## 대상 파일 (경로 확인 필요)

```
lib/features/coping_guide/
├── presentation/
│   ├── screens/
│   │   ├── coping_guide_screen.dart
│   │   └── detailed_guide_screen.dart
│   └── widgets/
│       ├── feedback_widget.dart
│       └── coping_guide_feedback_result.dart
└── infrastructure/
    └── repositories/
        └── static_coping_guide_repository.dart
```

---

## 완료 기준

```
[ ] 가이드 화면 문자열 ARB 추가 (ko, en)
[ ] 정적 데이터 문자열 ARB 추가 (ko, en)
[ ] 피드백 위젯 문자열 ARB 추가 (ko, en)
[ ] 모든 의료 콘텐츠에 MEDICAL REVIEW 태그 추가
[ ] 모든 사용처 context.l10n으로 변경
[ ] 의료진 검수 완료 (별도 프로세스)
[ ] 빌드 성공
```
