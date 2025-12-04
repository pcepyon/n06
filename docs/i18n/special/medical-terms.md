# 의료 용어 번역 가이드라인

> 출처: docs/i18n-plan.md §4

## 원칙

| 원칙 | 설명 | 예시 |
|-----|------|-----|
| **환자 친화적 표현 우선** | 의학 용어 대신 일상어 사용 | "췌장염" → "윗배 통증" |
| **톤 유지** | 한국어의 따뜻한 톤을 영어에도 반영 | "힘드셨죠" → "That sounds tough" (not "You experienced discomfort") |
| **의료적 정확성** | Red Flag 메시지는 의료진 검수 필수 | `@` 메타데이터에 `MEDICAL REVIEW REQUIRED` 태그 |
| **이모지 공통** | 이모지는 양 언어에서 동일하게 사용 | 💚, 🎉, 💧 등 |

---

## 증상명 번역표

### 기본 증상 (10개)

| 한국어 | 영어 (환자용) | 의학 용어 | 비고 |
|-------|-------------|----------|------|
| 메스꺼움 | Nausea / Feeling queasy | Nausea | 증상 선택에서 사용 |
| 구토 | Vomiting / Throwing up | Emesis | - |
| 변비 | Constipation | Constipation | 일상어와 의학용어 동일 |
| 설사 | Diarrhea / Loose stools | Diarrhea | - |
| 복통 | Stomach pain / Belly ache | Abdominal pain | - |
| 두통 | Headache | Cephalgia | 일상어 사용 |
| 피로 | Tiredness / Fatigue | Fatigue | - |
| 속쓰림 | Heartburn | Pyrosis | - |
| 배가 빵빵함 | Bloating | Abdominal distension | - |
| 어지러움 | Dizziness | Vertigo/Dizziness | - |

### 추가 증상 - 데일리 체크인 (7개)

| 한국어 | 영어 (환자용) | 의학 용어 | 비고 |
|-------|-------------|----------|------|
| 입맛이 없었어요 | Loss of appetite / Not feeling hungry | Anorexia | 식욕 저하 |
| 조금만 먹어도 배불러요 | Feeling full quickly | Early satiety | 조기 포만감 |
| 손이 떨리거나 | Hand shaking / Trembling | Tremor | 저혈당 체크 |
| 심장이 빨리 뛰었어요 | Heart racing / Fast heartbeat | Palpitation | 저혈당 체크 |
| 식은땀이 났어요 | Cold sweat / Sweating | Diaphoresis | 저혈당 체크 |
| 숨이 찼어요 | Shortness of breath / Breathing difficulty | Dyspnea | 신부전 체크 |
| 붓기가 있었어요 | Swelling | Edema | 신부전 체크 |

### Red Flag 관련 용어 (4개)

| 한국어 | 영어 (환자용) | 의학 용어 | 비고 |
|-------|-------------|----------|------|
| 췌장염 의심 | Possible pancreas issue | Pancreatitis | **MEDICAL REVIEW** |
| 담낭염 의심 | Possible gallbladder issue | Cholecystitis | **MEDICAL REVIEW** |
| 장폐색 의심 | Possible bowel blockage | Bowel obstruction | **MEDICAL REVIEW** |
| 신부전 의심 | Possible kidney issue | Renal impairment | **MEDICAL REVIEW** |

---

## Red Flag 메시지 번역 원칙

### 1. 긴급성 전달

한국어의 부드러운 톤을 유지하면서 긴급성 전달:

```
KO: "오늘 중으로 병원에 들러보시는 게 좋겠어요"
EN: "It would be good to visit a clinic today"
    (NOT "Go to ER immediately")
```

### 2. 안심 제공

두려움 최소화 메시지 유지:

```
KO: "드문 경우지만 확인이 필요할 수 있어요"
EN: "This is rare, but it's worth getting checked"
```

### 3. 실행 가능한 조언

구체적 행동 안내:

```
KO: "가까운 내과에서 확인받으시면 돼요"
EN: "A nearby clinic can check this for you"
```

---

## 번역 검수 프로세스

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

---

## 의료 콘텐츠 검수 체크리스트

| 체크 항목 | 담당 | 기준 |
|----------|------|------|
| 의학적 정확성 | 약사/의료진 | 임상 가이드라인과 일치 |
| 긴급성 전달 | 의료진 | 응급 vs 당일진료 명확 구분 |
| 환자 이해도 | UX 리서처 | 비의료인 이해 가능 |
| 문화적 맥락 | 네이티브 | 영어권 의료 문화 반영 |
| 행동 지침 실현성 | 간호사 | 구체적이고 실행 가능 |

---

## 검수 완료 기준

```
✅ 의료 콘텐츠 검수 완료 조건:
- [ ] 약사 2인 이상 검토 서명
- [ ] Red Flag 메시지별 개별 승인
- [ ] 영어권 의료진 1인 검토 (영어 버전)
- [ ] 검수 완료일 기록 (@metadata에 review_date 추가)

❌ 자동 Fail 기준:
- 의학적 부정확성 발견
- 긴급성 수준 불명확
- 행동 지침 누락
```

---

## ARB 메타데이터 예시 (의료 콘텐츠)

```json
{
  "checkin_redFlag_pancreatitis": "윗배 통증이 등 쪽으로도...",
  "@checkin_redFlag_pancreatitis": {
    "description": "Pancreatitis warning - MEDICAL REVIEW REQUIRED",
    "context": "Red Flag guidance dialog",
    "reviewed_by": "pharmacist_name",
    "review_date": "2025-12-03",
    "review_status": "APPROVED"
  }
}
```

---

## 적용 Phase

이 가이드라인이 적용되는 Phase:

- **Phase 5**: Daily Checkin (Red Flag 메시지)
- **Phase 6**: Tracking (응급 체크)
- **Phase 8**: Coping Guide (전체 의료 콘텐츠)
