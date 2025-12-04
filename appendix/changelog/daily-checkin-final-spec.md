# 데일리 체크인 최종 설계 명세서

> 작성일: 2025-12-02
> 상태: **확정 (Confirmed)**
> 다음 단계: 구현

---

## I. 설계 배경 및 목적

### 1.1 문제 정의

기존 "데일리 기록" 화면의 문제점:

| 문제 | 현상 | PRD 원칙 위반 |
|------|------|--------------|
| **부작용 기록 역설** | 부작용 없으면 기록 안 함 → 0% 달성 → "실패" 느낌 | 무조건적 긍정, 성취 강조 |
| **목표 설정 역설** | "주간 부작용 기록 목표"라는 개념 자체가 부자연스러움 | 부담을 줄이고 간단한 행동으로 인식 |
| **심리적 프레이밍 오류** | "부작용이 있어야 기록할 게 있다" | "실패" → "쉬어가는 날"로 재해석 |

### 1.2 핵심 모순

```
사용자 기대: "부작용 없이 건강하게 지낸 것" = 성공
앱의 해석: "기록 없음" = 미달성 = 실패
```

**PRD 언어 프레이밍 원칙 명백히 위반:**
- "아직 ~못함" → "이미 ~했음" 전환 불가능
- "실패" → "쉬어가는 날" 전환 불가능

---

## II. 기획 철학 (설계 의도)

### 2.1 GLP-1 치료에서 "매일 기록해야 할 것"은 무엇인가?

**핵심 인사이트**: 기록의 목적은 "문제를 추적"하는 것이 아니라 **"여정을 함께하는 것"**

| 항목 | 목적 | 기록 빈도 | 비고 |
|------|------|----------|------|
| **체중** | 변화 추적의 핵심 지표 | 매일 또는 정기적 | 가장 직접적인 피드백 |
| **컨디션** | 오늘의 몸 상태 확인 | 매일 | 좋든 나쁘든 기록 가능 |
| **식욕** | 약물 효과 확인 | 매일 | 변화 추세가 중요 |
| **증상 상세** | 특이사항 기록 | 필요시에만 | 컨디션이 나쁠 때만 |

### 2.2 "부작용 기록"의 진정한 목적

| 목적 | 기존 달성 여부 | 재설계 방향 |
|------|--------------|------------|
| **추적** | ✅ 달성 | 유지 |
| **안심** | ❌ 부분 달성 | "좋은 날"도 기록하여 전체 그림 제공 |
| **의료진 공유** | ✅ 달성 | "컨디션 히스토리"로 확장 |

**재정의**: "부작용 기록" → **"오늘의 컨디션 체크"**
- 증상이 있든 없든 매일 체크
- 증상 없음 = "좋음"으로 기록 = 성취

### 2.3 사용자가 매일 앱에 들어오게 만드는 본질적 동기

```
1. 체중 변화 확인 (가장 직접적인 피드백)
2. "오늘도 기록했다"는 작은 승리 (성취감)
3. "몸 상태가 정상이다" 확인 (안심감)
4. 치료 여정을 함께하는 느낌 (연결감)
```

**핵심**: 모든 동기를 충족하려면 **"기록하지 않은 날 = 실패"가 아닌 구조** 필요

### 2.4 용어 선택의 의도

| 용어 | 뉘앙스 | 채택 여부 | 이유 |
|------|--------|----------|------|
| 건강 체크 | "건강한지 아닌지 확인" → 이분법적 | ❌ | 실패/성공 느낌 유발 |
| 컨디션 체크 | "오늘의 상태는?" → 스펙트럼 | ✅ | 좋든 나쁘든 기록 가능 |
| 몸의 신호 체크 | PRD 용어와 일치, 정상화 | ✅ (보조) | 부작용을 신호로 재해석 |
| 데일리 체크인 | 습관 형성 강조 | ✅ (상위 개념) | 가볍고 친근한 느낌 |

### 2.5 개념 변환 매핑

| 기존 용어 | 변경 용어 | 이유 |
|----------|----------|------|
| 데일리 기록 | **데일리 체크인** | "기록"의 부담 → "체크인"의 가벼움 |
| 부작용 기록 (선택) | **일상 질문 + 자연스러운 파생** | 매일 기록 가능한 구조 |
| 증상 선택 | **몸의 신호 상세** | PRD 언어 프레이밍 |
| 부작용 기록 목표 | **체크인 목표** | 증상 여부와 무관하게 달성 가능 |

---

## III. 해결 방향 및 원칙

### 3.1 해결 방향

```
"부작용 기록" 중심 → "일상적 안부 질문" 중심으로 전환

- 매일 답변할 수 있는 일상적 질문
- 자연스러운 파생으로 부작용 정보 수집
- 매 답변마다 감정적 지지 피드백
- Red Flag는 숨겨진 로직으로 감지, 부드럽게 안내
```

### 3.2 핵심 원칙

| 원칙 | 구현 방식 |
|------|----------|
| **일상적 대화** | 의료 용어 대신 친근한 안부 질문 |
| **자연스러운 파생** | "힘들었어요" 선택 시에만 상세 질문 |
| **즉각적 피드백** | 매 답변마다 격려/안심 메시지 |
| **숨겨진 임상 감지** | Red Flag 조건을 자연스럽게 수집 |
| **두려움 최소화** | 안내도 "확인 권유" 톤으로 |

### 3.3 PRD 원칙 정합성

| PRD 핵심 가치 | 재설계 반영 |
|--------------|------------|
| 감정적 지지 | 컨디션 "좋아요"도 성취로 인정 |
| 안심감 | 증상 없는 날 = 좋은 날로 기록 |
| 성취감 | 매일 체크인 = 작은 승리 |
| 연결감 | 좋든 나쁘든 여정 기록 |

---

## IV. 확정된 기능 목록

### 4.1 핵심 기능

| # | 기능 | 설명 | 상태 |
|---|------|------|------|
| 1 | 일상적 질문 6개 | 식사, 수분, 속 편안함, 화장실, 에너지, 기분 | ✅ 확정 |
| 2 | 자연스러운 파생 | "힘들었어요" → 부작용 상세 질문으로 분기 | ✅ 확정 |
| 3 | 매 답변 피드백 | 기존 CopingGuide 활용 + 긍정 피드백 | ✅ 확정 |
| 4 | Red Flag 감지 | 췌장염, 담낭염, 탈수, 저혈당 등 | ✅ 확정 |
| 5 | 의료진 공유 형식 | 구조화된 주간 리포트 | ✅ 확정 |

### 4.2 감정적 UX 기능

| # | 기능 | 설명 | 상태 |
|---|------|------|------|
| 6 | 시간대별 인사 톤 | 아침/점심/저녁 다른 인사 | ✅ 확정 |
| 7 | 연속 체크인 축하 | 3일, 7일, 14일 등 마일스톤 | ✅ 확정 |
| 8 | 주사 다음날 컨텍스트 | 투여 다음날 맞춤 질문 | ✅ 확정 |
| 9 | 복귀 사용자 환영 | 3일+ 공백 후 따뜻한 메시지 | ✅ 확정 |
| 10 | 변화 감지 피드백 | "지난주보다 나아졌어요" 등 | ✅ 확정 |

---

## V. 질문 플로우 상세

### 5.1 전체 구조

```
┌─────────────────────────────────────────────────────────────┐
│                     데일리 체크인                            │
│                                                             │
│  🌤️ 컨텍스트 인사 (시간대/복귀/주사 다음날)                 │
│                                                             │
│  📊 체중 입력                                               │
│                                                             │
│  Q1. 🍽️ 식사 ──→ 메스꺼움/구토 파생                        │
│       ↓ 피드백                                              │
│  Q2. 💧 수분 ──→ 탈수 위험 파생                             │
│       ↓ 피드백                                              │
│  Q3. 😌 속 편안함 ──→ 복통/속쓰림 파생 → 췌장염/담낭염      │
│       ↓ 피드백                                              │
│  Q4. 🚽 화장실 ──→ 변비/설사 파생 → 장폐색                  │
│       ↓ 피드백                                              │
│  Q5. ⚡ 에너지 ──→ 피로/어지러움 파생 → 저혈당              │
│       ↓ 피드백                                              │
│  Q6. 😊 기분                                                │
│       ↓ 피드백                                              │
│                                                             │
│  ✅ 완료 + 종합 피드백 + (연속 기록 축하)                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 5.2 질문별 상세

#### Q1. 식사 질문
```
🍽️ 오늘 식사는 어떠셨어요?

[😋 잘 먹었어요] [😐 적당히 먹었어요] [😣 좀 힘들었어요]
```

| 답변 | 피드백 | 파생 |
|------|--------|------|
| 잘 먹었어요 | "좋아요! 규칙적인 식사가 치료에 도움이 돼요 💚" | 없음 |
| 적당히 먹었어요 | "괜찮아요, 소량씩 드시는 것도 좋아요" | 없음 |
| 좀 힘들었어요 | "어떤 점이 힘드셨어요?" | Q1-1로 |

**Q1-1 파생**: 속이 메스꺼웠어요 / 입맛이 없었어요 / 조금만 먹어도 배불러요

#### Q2. 수분 질문
```
💧 물은 충분히 드셨나요?

[💧 충분히 마셨어요] [💧 좀 적게 마신 것 같아요] [😰 거의 못 마셨어요]
```

| 답변 | 피드백 | 파생 |
|------|--------|------|
| 충분히 마셨어요 | "잘하셨어요! 수분 섭취가 정말 중요해요 💧" | 없음 |
| 좀 적게 마신 것 같아요 | "내일은 조금 더 챙겨보세요" | 없음 |
| 거의 못 마셨어요 | "물 마시기가 힘드셨나요?" | Q2-1로 |

#### Q3. 속 편안함 질문
```
😌 속은 편하셨어요?

[😊 네, 괜찮았어요] [😐 좀 불편했어요] [😣 많이 불편했어요]
```

| 답변 | 피드백 | 파생 |
|------|--------|------|
| 네, 괜찮았어요 | "다행이에요! 💚" | 없음 |
| 좀/많이 불편했어요 | "어떤 불편함이 있으셨어요?" | Q3-1로 |

**Q3-1 파생**: 속이 쓰렸어요 / 배가 아팠어요 / 배가 빵빵했어요
**Q3-2 (배 아픔 시)**: 복통 위치 선택 → 심각도 → 등 방사 여부 (췌장염/담낭염 체크)

#### Q4. 화장실 질문
```
🚽 화장실은 잘 다녀오셨어요?

[😊 네, 잘 봤어요] [😐 좀 불규칙했어요] [😣 힘들었어요]
```

| 답변 | 피드백 | 파생 |
|------|--------|------|
| 네, 잘 봤어요 | "좋아요! 규칙적인 게 중요해요" | 없음 |
| 불규칙/힘들었어요 | "어떤 상황이었어요?" | Q4-1로 |

**Q4-1 파생**: 변비가 있었어요 / 설사를 했어요

#### Q5. 에너지 질문
```
⚡ 오늘 에너지는 어떠셨어요?

[😊 활기 있었어요] [😐 평소와 비슷했어요] [😴 많이 피곤했어요]
```

| 답변 | 피드백 | 파생 |
|------|--------|------|
| 활기 있었어요 | "좋은 하루였네요! ⚡" | 없음 |
| 평소와 비슷했어요 | "꾸준히 유지하고 계시네요" | 없음 |
| 많이 피곤했어요 | "다른 증상도 함께 있었나요?" | Q5-1로 |

**Q5-1 파생**: 어지러웠어요 / 식은땀이 났어요 / 붓기가 있었어요 (저혈당/신부전 체크)

#### Q6. 기분 질문
```
😊 마지막으로, 오늘 기분은 어떠셨어요?

[😊 좋았어요] [😐 그저 그랬어요] [😔 좀 우울했어요]
```

| 답변 | 피드백 |
|------|--------|
| 좋았어요 | "좋은 하루였네요! 😊" |
| 그저 그랬어요 | "그런 날도 있죠. 내일은 더 좋을 거예요" |
| 좀 우울했어요 | "힘든 날도 있어요. 당신은 잘하고 있어요 💚" |

---

## VI. 컨텍스트 인사 시스템

### 6.1 시간대별 인사

| 시간대 | 인사 예시 |
|--------|----------|
| 아침 (5-11시) | "좋은 아침이에요 ☀️" |
| 점심 (11-17시) | "오늘 하루 어떠세요?" |
| 저녁 (17-21시) | "오늘 하루 수고하셨어요 🌙" |
| 밤 (21-5시) | "늦은 시간까지 수고 많으셨어요" |

### 6.2 주사 다음날 컨텍스트

**기존 데이터 활용**: `dose_records` 테이블의 `administered_at` 필드 확인

```dart
/// 주사 다음날 여부 확인
/// dose_records 테이블에서 가장 최근 투여일 확인
Future<bool> isPostInjectionDay(String userId) async {
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  final yesterday = todayDate.subtract(const Duration(days: 1));

  // 최근 투여 기록 조회
  final latestDose = await doseRecordRepository.getLatestRecord(userId);

  if (latestDose == null) return false;

  final doseDate = DateTime(
    latestDose.administeredAt.year,
    latestDose.administeredAt.month,
    latestDose.administeredAt.day,
  );

  return doseDate == yesterday;
}

// 인사말 적용
if (await isPostInjectionDay(userId)) {
  greeting = "어제 주사 맞으셨죠? 오늘 컨디션은 어떠세요?";
  context.isPostInjection = true;
  // Q1, Q3, Q5에서 "힘들었어요" 선택 시 더 세심한 파생 질문
}
```

### 6.3 복귀 사용자 환영

```dart
if (daysSinceLastCheckin >= 3) {
  greeting = """
    다시 만나서 반가워요 😊
    쉬어가는 것도 여정의 일부예요.
    오늘부터 다시 함께해요!
  """;
}
```

---

## VII. 연속 체크인 축하 시스템

### 7.1 마일스톤 정의

| 연속 일수 | 축하 메시지 | 시각적 효과 |
|----------|------------|------------|
| 3일 | "벌써 3일째 함께하고 있어요!" | 작은 별 이모지 |
| 7일 | "일주일 완주! 대단해요 🎉" | 축하 애니메이션 |
| 14일 | "2주 동안 꾸준히 기록하셨네요!" | 뱃지 부여 |
| 21일 | "3주! 이제 습관이 되셨을 거예요" | 뱃지 부여 |
| 30일 | "한 달 완주! 정말 대단해요 🏆" | 특별 뱃지 |

### 7.2 연속 기록 판정 정책

**정책 결정**: 체크인 완료 기준 (체중은 선택)

| 시나리오 | 연속 기록 인정 |
|----------|--------------|
| 체중 ✅ + 체크인 ✅ | ✅ 인정 |
| 체중 ❌ + 체크인 ✅ | ✅ 인정 |
| 체중 ✅ + 체크인 ❌ | ❌ 불인정 |
| 체중 ❌ + 체크인 ❌ | ❌ 불인정 |

**이유**:
- 체중 입력은 저울이 없는 등의 이유로 건너뛸 수 있음
- 6개 질문 체크인이 핵심 목표이므로 이를 기준으로 연속성 판정

### 7.3 구현 로직

```dart
/// 연속 체크인 일수 계산
/// daily_checkins 테이블 기준 (weight_logs는 포함하지 않음)
int calculateConsecutiveDays(String userId, List<DailyCheckin> checkins) {
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);

  // 체크인 날짜들을 정렬
  final checkinDates = checkins
      .map((c) => DateTime(c.checkinDate.year, c.checkinDate.month, c.checkinDate.day))
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a)); // 내림차순

  int consecutiveDays = 0;
  for (var i = 0; i < checkinDates.length; i++) {
    final expectedDate = todayDate.subtract(Duration(days: i));
    if (checkinDates.contains(expectedDate)) {
      consecutiveDays++;
    } else {
      break;
    }
  }
  return consecutiveDays;
}

// 마일스톤 체크
if (consecutiveDays in [3, 7, 14, 21, 30, 60, 90]) {
  showMilestoneAnimation();
  showCelebrationMessage(consecutiveDays);
}
```

---

## VIII. 변화 감지 피드백

### 8.1 감지 항목

| 항목 | 감지 조건 | 피드백 예시 |
|------|----------|------------|
| 메스꺼움 감소 | 이번 주 빈도 < 지난주 | "지난주보다 메스꺼움이 줄었어요! 몸이 적응하고 있네요 💚" |
| 식욕 안정화 | 식욕 점수 평균 상승 | "식욕 조절이 잘 되고 있어요" |
| 에너지 회복 | 에너지 "좋음" 비율 증가 | "에너지가 돌아오고 있네요! ⚡" |
| 체중 변화 | 목표 방향으로 변화 | "꾸준히 변화하고 있어요" |

### 8.2 구현 로직

```dart
WeeklyComparison comparison = compareWithLastWeek(userId);

if (comparison.nauseaDecreased) {
  feedbacks.add("지난주보다 메스꺼움이 줄었어요! 몸이 적응하고 있네요 💚");
}

if (comparison.appetiteImproved) {
  feedbacks.add("식욕 조절이 잘 되고 있어요. 약이 잘 작용하는 신호예요");
}
```

---

## IX. 피드백 시스템 상세

### 9.1 피드백 구조

```dart
class CheckinFeedback {
  final String message;           // 메인 메시지
  final String? stat;             // 통계 (선택)
  final String? action;           // 즉각 행동 제안 (선택)
  final FeedbackTone tone;        // positive, supportive, cautious
}

enum FeedbackTone {
  positive,    // 💚 긍정 (잘한 경우)
  supportive,  // 💛 지지 (힘든 경우)
  cautious,    // 🧡 주의 (Red Flag 감지)
}
```

### 9.2 기존 CopingGuide 활용

부작용 관련 답변 시 기존 데이터 활용:

```dart
// 메스꺼움 선택 시
CopingGuide guide = copingGuideRepository.getGuide('메스꺼움');

showFeedback(
  message: guide.reassuranceMessage,  // "몸이 약에 적응하는 자연스러운 반응이에요"
  stat: guide.reassuranceStat,        // "85%가 2주 내 개선을 경험해요"
  action: guide.immediateAction,      // "시원한 물 한 모금 마시기"
);
```

### 9.3 긍정 답변용 피드백 (신규)

| 질문 | 긍정 답변 | 피드백 |
|------|----------|--------|
| 식사 | 잘 먹었어요 | "좋아요! 규칙적인 식사가 치료에 도움이 돼요 💚" |
| 수분 | 충분히 마셨어요 | "잘하셨어요! 수분 섭취가 정말 중요해요 💧" |
| 속 편안함 | 괜찮았어요 | "다행이에요! 💚" |
| 화장실 | 잘 봤어요 | "좋아요! 규칙적인 게 중요해요" |
| 에너지 | 활기 있었어요 | "좋은 하루였네요! ⚡" |
| 기분 | 좋았어요 | "좋은 하루였네요! 😊" |

---

## X. Red Flag 감지 시스템

### 10.1 감지 매트릭스

| Red Flag | 트리거 경로 | 감지 조건 |
|----------|------------|----------|
| 급성 췌장염 | Q3 → 배 아픔 → 상복부 | 심한 통증 + 등 방사 + 수시간 지속 |
| 담낭염 | Q3 → 배 아픔 → 우상복부 | 심한 통증 + 발열/오한 |
| 심한 탈수 | Q1 → 구토 + Q2 → 못 마심 | 구토 3회+ AND 물 못 마심 |
| 장폐색 | Q4 → 변비 | 5일+ 변비 + 심한 빵빵함 + 가스 없음 |
| 저혈당 | Q5 → 어지러움 + 식은땀 | 증상 + 당뇨약 병용 |
| 신부전 | Q5 → 피로 + 붓기 | 심한 피로 + 부종 + 소변 감소 |

### 10.2 안내 톤 (확정)

```
💛 오늘 기록해주신 증상이 조금 확인이 필요해 보여요.

[구체적 증상 요약]

이런 경우 드물지만 확인이 필요할 때가 있어요.
오늘 중으로 가까운 병원에 들러서
한 번 확인받아 보시는 게 안심이 될 것 같아요.

💡 응급실이 아니어도 괜찮아요.
   가까운 내과에서 확인받으시면 돼요.

[병원 찾기] [나중에 확인할게요]
```

---

## XI. 의료진 공유 형식

### 11.1 주간 리포트 구조

```
╔══════════════════════════════════════════════════════════════╗
║                   GLP-1 치료 주간 리포트                      ║
║  환자: OOO | 약제: 위고비 0.5mg | 기간: 11.25-12.01         ║
╠══════════════════════════════════════════════════════════════╣
║  ▶ 주요 지표                                                ║
║    체중: 85.2 → 84.5kg (▼0.7kg)                            ║
║    식욕: 평균 3.2/5, 안정적                                 ║
║    체크인: 5/7일 (71%)                                      ║
╠══════════════════════════════════════════════════════════════╣
║  ▶ 증상 발생 현황                                           ║
║    메스꺼움 3일 (경미2, 중등도1)                            ║
║    변비 2일 (경미)                                          ║
╠══════════════════════════════════════════════════════════════╣
║  ▶ 주의 필요 기록                                           ║
║    11/28: 상복부 통증, 중등도, 4시간                        ║
║    → 등 방사 없음, 다음날 소실, Red Flag 해당 없음          ║
╠══════════════════════════════════════════════════════════════╣
║  ▶ 컨디션 추이                                              ║
║    😊😔😐😊😐😊--                                            ║
║    월 화 수 목 금 토 일                                      ║
╚══════════════════════════════════════════════════════════════╝
```

---

## XII. 데이터 모델

### 12.1 설계 결정

#### 12.1.1 분석 배경

기존 코드베이스와의 정합성을 검토한 결과, 다음과 같은 구조적 변경이 필요합니다:

| 기존 구조 | 문제점 | 결정 |
|----------|--------|------|
| `symptom_logs` 테이블 | 단일 증상 + 심각도(1-10) 구조가 새 6개 질문 모델과 완전히 다름 | **삭제** |
| `symptom_context_tags` 테이블 | `symptom_logs`에 FK 의존 | **삭제** |
| `emergency_symptom_checks` 테이블 | Red Flag 체크 이력 (사용자 직접 선택 방식) | **삭제** (daily_checkins로 통합) |
| `weight_logs` 테이블 | 체중 + 식욕 점수, 독립적 기능 | **유지** |

#### 12.1.2 설계 옵션 분석

| 옵션 | 설명 | 장점 | 단점 | 채택 |
|------|------|------|------|------|
| A. weight_logs 확장 | condition_data JSONB 추가 | 기존 코드 활용 | 체중 없이 체크인 불가, WeightLog 대폭 수정 | ❌ |
| **B. daily_checkins 신규** | 독립 테이블 생성 | 명확한 책임 분리, 기존 코드 최소 수정 | 신규 코드 필요 | ✅ |
| C. symptom_logs 재활용 | 스키마 변경 | 테이블 유지 | 의미론적 혼란, 구조 완전히 다름 | ❌ |

**채택: 옵션 B** - 앱 미출시이므로 깔끔한 신규 설계 가능

#### 12.1.3 체중 기록과 체크인의 관계

```
[체중 기록 (선택)] → [데일리 체크인 (필수)]
       ↓                    ↓
  weight_logs          daily_checkins
  (순수 체중만)        (컨디션 + 식욕점수)
```

**핵심 원칙:**
- **체중 입력은 선택적**: 체크인 플로우 시작 시 체중 입력 UI 표시, "건너뛰기" 버튼으로 스킵 가능
- **식욕 점수는 daily_checkins 소유**: `appetite_score`는 체크인의 `meal_condition`과 함께 저장
- **weight_logs는 순수 체중만**: `appetite_score` 컬럼 제거, 체중(kg) 수치만 저장
- **날짜 기준 연결**: 같은 날짜(log_date = checkin_date)로 조인 가능

**UI 플로우:**
```
1. 체중 입력 화면
   - [체중 입력 필드]
   - [다음] 버튼
   - [건너뛰기] 링크 (하단, 덜 강조)

2. 건너뛰기 선택 시
   - 체중 저장 없이 바로 6개 질문으로 이동
   - "나중에 기록해도 괜찮아요" 메시지
```

### 12.2 신규 테이블: daily_checkins

```sql
-- 데일리 체크인 테이블
CREATE TABLE public.daily_checkins (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id TEXT NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  checkin_date DATE NOT NULL,

  -- 6개 일상 질문 응답
  meal_condition VARCHAR(20) NOT NULL,        -- good / moderate / difficult
  hydration_level VARCHAR(20) NOT NULL,       -- good / moderate / poor
  gi_comfort VARCHAR(20) NOT NULL,            -- good / uncomfortable / very_uncomfortable
  bowel_condition VARCHAR(20) NOT NULL,       -- normal / irregular / difficult
  energy_level VARCHAR(20) NOT NULL,          -- good / normal / tired
  mood VARCHAR(20) NOT NULL,                  -- good / neutral / low

  -- 식욕 점수 (weight_logs에서 이동)
  appetite_score INTEGER CHECK (appetite_score >= 1 AND appetite_score <= 5),
  -- 1: 아예 없음, 2: 매우 감소, 3: 약간 감소, 4: 보통, 5: 폭발
  -- meal_condition이 'difficult'면 파생 질문에서 정확한 점수 결정
  -- meal_condition이 'good'면 4-5, 'moderate'면 3-4

  -- 파생 증상 상세 (JSONB) - "힘들었어요" 선택 시 추가 정보
  symptom_details JSONB,
  -- 스키마: [{"type": string, "severity": 1-3, "details": {...}}]
  -- 상세 타입 정의는 12.4절 참조

  -- 컨텍스트 정보 (JSONB)
  context JSONB,
  -- 예: {
  --   "is_post_injection": true,
  --   "days_since_last_checkin": 1,
  --   "consecutive_days": 5,
  --   "greeting_type": "morning"
  -- }

  -- Red Flag 감지 결과 (JSONB) - 시스템 자동 감지
  red_flag_detected JSONB,
  -- 예: {
  --   "type": "pancreatitis",
  --   "severity": "warning",
  --   "symptoms": ["severe_abdominal_pain", "radiates_to_back"],
  --   "notified_at": "2025-12-02T10:30:00Z"
  -- }

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(user_id, checkin_date)
);

-- 인덱스
CREATE INDEX idx_daily_checkins_user_date ON public.daily_checkins(user_id, checkin_date DESC);
CREATE INDEX idx_daily_checkins_red_flag ON public.daily_checkins(user_id)
  WHERE red_flag_detected IS NOT NULL;
CREATE INDEX idx_daily_checkins_symptom_gin ON public.daily_checkins
  USING GIN (symptom_details jsonb_path_ops);

-- RLS 정책
ALTER TABLE public.daily_checkins ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their own checkins"
ON public.daily_checkins FOR ALL
USING (auth.uid()::TEXT = user_id);
```

### 12.3 삭제할 테이블

```sql
-- 마이그레이션 순서 (FK 의존성 고려)
-- 1. 자식 테이블 먼저 삭제
DROP TABLE IF EXISTS public.symptom_context_tags CASCADE;

-- 2. 부모 테이블 삭제
DROP TABLE IF EXISTS public.symptom_logs CASCADE;

-- 3. emergency_symptom_checks 삭제 (daily_checkins로 통합)
DROP TABLE IF EXISTS public.emergency_symptom_checks CASCADE;
```

### 12.4 엔티티 구조 (Dart)

```dart
// lib/features/daily_checkin/domain/entities/daily_checkin.dart

/// 6개 일상 질문 응답 값
enum ConditionLevel {
  good,       // 좋음
  moderate,   // 보통
  difficult;  // 힘듦/어려움
}

/// 수분 섭취 수준
enum HydrationLevel {
  good,       // 충분히
  moderate,   // 적당히
  poor;       // 부족
}

/// GI 편안함 수준
enum GiComfortLevel {
  good,             // 편안함
  uncomfortable,    // 불편함
  veryUncomfortable; // 매우 불편함
}

/// 배변 상태
enum BowelCondition {
  normal,     // 정상
  irregular,  // 불규칙
  difficult;  // 힘듦
}

/// 에너지 수준
enum EnergyLevel {
  good,    // 활기참
  normal,  // 보통
  tired;   // 피곤함
}

/// 기분 상태
enum MoodLevel {
  good,    // 좋음
  neutral, // 그저 그럼
  low;     // 우울함
}

/// 데일리 체크인 엔티티
class DailyCheckin extends Equatable {
  final String id;
  final String userId;
  final DateTime checkinDate;

  // 6개 일상 질문 응답
  final ConditionLevel mealCondition;
  final HydrationLevel hydrationLevel;
  final GiComfortLevel giComfort;
  final BowelCondition bowelCondition;
  final EnergyLevel energyLevel;
  final MoodLevel mood;

  // 식욕 점수 (1-5, weight_logs에서 이동)
  // - meal_condition이 'good'이면 4-5
  // - meal_condition이 'moderate'이면 3-4
  // - meal_condition이 'difficult'이면 파생 질문에서 결정 (1-3)
  final int? appetiteScore;

  // 파생 정보
  final List<SymptomDetail>? symptomDetails;
  final CheckinContext? context;
  final RedFlagDetection? redFlagDetected;

  final DateTime createdAt;

  // ... 생성자, copyWith, props
}
```

### 12.5 JSONB 스키마 정의

#### 12.5.1 symptom_details 스키마

```dart
/// 증상 타입 (정규화된 값)
enum SymptomType {
  nausea,           // 메스꺼움
  vomiting,         // 구토
  lowAppetite,      // 입맛 없음
  earlySatiety,     // 조기 포만감
  heartburn,        // 속쓰림
  abdominalPain,    // 복통
  bloating,         // 복부 팽만
  constipation,     // 변비
  diarrhea,         // 설사
  fatigue,          // 피로
  dizziness,        // 어지러움
  coldSweat,        // 식은땀
  swelling,         // 부종
}

/// 파생 증상 상세
///
/// JSONB 구조:
/// ```json
/// [
///   {
///     "type": "nausea",        // SymptomType enum 값
///     "severity": 2,           // 1(mild), 2(moderate), 3(severe) - 숫자 필수
///     "details": {             // 증상별 추가 필드 (nullable)
///       "vomit_count": 2,
///       "duration_hours": 4
///     }
///   }
/// ]
/// ```
class SymptomDetail {
  final SymptomType type;
  final int severity;  // 1-3 (mild/moderate/severe)
  final Map<String, dynamic>? details;

  /// 복통 전용 details 필드
  /// - location: "upper" | "right_upper" | "lower" | "around_navel"
  /// - radiates_to_back: bool (췌장염 지표)
  /// - duration_hours: int

  /// 구토 전용 details 필드
  /// - vomit_count: int (횟수)
  /// - can_keep_water: bool (물 마실 수 있는지)

  /// 변비 전용 details 필드
  /// - days_without: int (변비 일수)
  /// - has_gas: bool (가스 배출 여부)

  /// JSON 검증
  static bool isValid(Map<String, dynamic> json) {
    return json.containsKey('type') &&
           json.containsKey('severity') &&
           json['severity'] is int &&
           json['severity'] >= 1 &&
           json['severity'] <= 3;
  }
}
```

#### 12.5.2 context 스키마

```dart
/// 체크인 컨텍스트 정보
///
/// JSONB 구조:
/// ```json
/// {
///   "is_post_injection": true,
///   "days_since_last_checkin": 1,
///   "consecutive_days": 5,
///   "greeting_type": "morning",
///   "weight_skipped": true
/// }
/// ```
class CheckinContext {
  final bool isPostInjection;      // 주사 다음날 여부
  final int daysSinceLastCheckin;  // 마지막 체크인 이후 일수
  final int consecutiveDays;       // 연속 체크인 일수
  final String? greetingType;      // morning/afternoon/evening/night
  final bool weightSkipped;        // 체중 입력 건너뛰기 여부
}
```

#### 12.5.3 red_flag_detected 스키마

```dart
/// Red Flag 타입
enum RedFlagType {
  pancreatitis,       // 급성 췌장염
  cholecystitis,      // 담낭염
  severeDehydration,  // 심한 탈수
  bowelObstruction,   // 장폐색
  hypoglycemia,       // 저혈당
  renalImpairment,    // 신부전
}

/// Red Flag 감지 결과
///
/// JSONB 구조:
/// ```json
/// {
///   "type": "pancreatitis",
///   "severity": "warning",
///   "symptoms": ["severe_abdominal_pain", "radiates_to_back"],
///   "notified_at": "2025-12-02T10:30:00Z",
///   "user_action": "dismissed"
/// }
/// ```
class RedFlagDetection {
  final RedFlagType type;
  final String severity;       // "warning" | "urgent"
  final List<String> symptoms; // 감지된 증상 목록
  final DateTime? notifiedAt;  // 사용자에게 안내한 시간
  final String? userAction;    // "dismissed" | "hospital_search" | null
}
```

### 12.6 CopingGuide 활용

기존 `CopingGuide` 엔티티를 피드백 시스템에 직접 활용:

```dart
// SymptomType → CopingGuide symptomName 매핑
String _mapSymptomTypeToName(SymptomType type) {
  switch (type) {
    case SymptomType.nausea: return '메스꺼움';
    case SymptomType.vomiting: return '구토';
    case SymptomType.lowAppetite: return '식욕 감소';
    case SymptomType.earlySatiety: return '조기 포만감';
    case SymptomType.heartburn: return '속쓰림';
    case SymptomType.abdominalPain: return '복통';
    case SymptomType.bloating: return '복부 팽만';
    case SymptomType.constipation: return '변비';
    case SymptomType.diarrhea: return '설사';
    case SymptomType.fatigue: return '피로';
    case SymptomType.dizziness: return '어지러움';
    case SymptomType.coldSweat: return '식은땀';
    case SymptomType.swelling: return '부종';
  }
}

// 피드백 생성 로직 예시
class CheckinFeedbackService {
  final CopingGuideRepository _copingGuideRepository;

  /// 증상 선택 시 피드백 생성
  Future<CheckinFeedback> getFeedbackForSymptom(SymptomType symptomType) async {
    final guide = await _copingGuideRepository.getGuideBySymptom(
      _mapSymptomTypeToName(symptomType),
    );

    if (guide != null) {
      return CheckinFeedback(
        message: guide.reassuranceMessage,
        stat: guide.reassuranceStat,
        action: guide.immediateAction,
        tone: FeedbackTone.supportive,
      );
    }

    return CheckinFeedback.defaultSupportive();
  }

  /// 긍정 응답 시 피드백 (신규)
  CheckinFeedback getPositiveFeedback(String questionType) {
    return _positiveFeedbacks[questionType] ??
           CheckinFeedback(message: "좋아요! 💚", tone: FeedbackTone.positive);
  }
}
```

### 12.7 주간 통계 집계 쿼리

```sql
-- 주간 체크인 통계 (대시보드용)
SELECT
  user_id,
  COUNT(*) as checkin_count,
  COUNT(*) FILTER (WHERE meal_condition = 'good') as good_meal_days,
  COUNT(*) FILTER (WHERE hydration_level = 'good') as good_hydration_days,
  COUNT(*) FILTER (WHERE symptom_details IS NOT NULL) as symptom_days,
  COUNT(*) FILTER (WHERE red_flag_detected IS NOT NULL) as red_flag_days
FROM daily_checkins
WHERE checkin_date >= CURRENT_DATE - INTERVAL '7 days'
  AND user_id = :userId
GROUP BY user_id;
```

---

## XIII. 구현 우선순위

### Phase 0: 레거시 정리 (P0) ⚠️ 선행 필수

#### 0.1 데이터베이스 마이그레이션
```
- [ ] daily_checkins 테이블 생성 마이그레이션 작성 (appetite_score 포함)
- [ ] weight_logs에서 appetite_score 컬럼 제거
- [ ] symptom_context_tags 테이블 삭제
- [ ] symptom_logs 테이블 삭제
- [ ] emergency_symptom_checks 테이블 삭제
- [ ] docs/database.md 동기화 ✅ 완료
```

#### 0.2 레거시 코드 삭제
```
삭제할 파일:
- [ ] lib/features/tracking/domain/entities/symptom_log.dart
- [ ] lib/features/tracking/infrastructure/dtos/symptom_log_dto.dart
- [ ] lib/features/tracking/domain/entities/emergency_symptom_check.dart
- [ ] lib/features/tracking/infrastructure/dtos/emergency_symptom_check_dto.dart
- [ ] lib/features/tracking/domain/repositories/emergency_check_repository.dart
- [ ] lib/features/tracking/infrastructure/repositories/supabase_emergency_check_repository.dart
- [ ] lib/features/tracking/application/notifiers/emergency_check_notifier.dart
- [ ] lib/features/tracking/application/notifiers/emergency_check_notifier.g.dart
- [ ] lib/features/tracking/application/notifiers/symptom_record_edit_notifier.dart
- [ ] lib/features/tracking/application/notifiers/symptom_guide_notifier.dart
- [ ] lib/features/tracking/application/notifiers/symptom_guide_notifier.g.dart
- [ ] lib/features/tracking/application/notifiers/symptom_pattern_notifier.dart
- [ ] lib/features/tracking/application/notifiers/symptom_pattern_notifier.g.dart
```

#### 0.3 기존 코드 수정
```
수정할 파일:
- [ ] lib/features/tracking/domain/entities/weight_log.dart
      → appetiteScore 필드 제거
- [ ] lib/features/tracking/infrastructure/dtos/weight_log_dto.dart
      → appetite_score 컬럼 매핑 제거
- [ ] lib/features/tracking/domain/repositories/tracking_repository.dart
      → symptom 관련 메서드 제거 (saveSymptomLog, getSymptomLogs 등)
- [ ] lib/features/tracking/infrastructure/repositories/supabase_tracking_repository.dart
      → symptom 관련 메서드 구현 제거
- [ ] lib/features/tracking/application/providers.dart
      → symptom/emergency 관련 provider 제거
- [ ] lib/features/dashboard/** (대시보드)
      → symptom_logs 참조 제거, daily_checkins로 교체
      → 식욕 점수 조회 로직 daily_checkins로 변경
- [ ] lib/features/dashboard/domain/usecases/calculate_continuous_record_days_usecase.dart
      → symptom_logs 기반 → daily_checkins 기반으로 변경
      → weight_logs만으로는 연속 기록 인정 안 함 (7.2절 정책 참조)
```

### Phase 1: 핵심 플로우 (P0)

#### 1.1 신규 기능 생성
```
신규 생성할 파일:
- [ ] lib/features/daily_checkin/domain/entities/daily_checkin.dart
- [ ] lib/features/daily_checkin/domain/entities/symptom_detail.dart
- [ ] lib/features/daily_checkin/domain/entities/checkin_context.dart
- [ ] lib/features/daily_checkin/domain/entities/red_flag_detection.dart
- [ ] lib/features/daily_checkin/domain/entities/checkin_feedback.dart
- [ ] lib/features/daily_checkin/infrastructure/dtos/daily_checkin_dto.dart
- [ ] lib/features/daily_checkin/domain/repositories/daily_checkin_repository.dart
- [ ] lib/features/daily_checkin/infrastructure/repositories/supabase_daily_checkin_repository.dart
- [ ] lib/features/daily_checkin/application/notifiers/daily_checkin_notifier.dart
- [ ] lib/features/daily_checkin/application/notifiers/checkin_feedback_notifier.dart
- [ ] lib/features/daily_checkin/application/providers.dart
```

#### 1.2 UI 구현

**기존 위젯 재사용/신규 생성 결정**:

| 위젯 | 기존 코드 | 결정 | 이유 |
|------|----------|------|------|
| **답변 버튼** | `appeal_score_chip.dart` | ✅ 확장 재사용 | 선택/미선택 상태, 터치 44px 보장 로직 이미 있음. 이모지+텍스트 지원으로 확장 |
| **피드백 카드** | `contextual_guide_card.dart` | 🆕 신규 생성 | CopingGuide용 구조와 다름. 더 심플한 구조 필요 |
| **질문 카드** | 없음 | 🆕 신규 생성 | 질문+설명+선택지 레이아웃 필요 |
| **진행률 표시** | 없음 | 🆕 신규 생성 | 6개 질문 진행 상태 표시 |
| **심각도 선택** | `severity_level_indicator.dart` | ⚠️ 수정 재사용 | 1-10 → 1-3 범위로 변경 필요 |

```
신규 생성:
- [ ] lib/features/daily_checkin/presentation/screens/daily_checkin_screen.dart
- [ ] lib/features/daily_checkin/presentation/widgets/question_card.dart
- [ ] lib/features/daily_checkin/presentation/widgets/feedback_card.dart
- [ ] lib/features/daily_checkin/presentation/widgets/checkin_progress_indicator.dart

기존 코드 수정/확장:
- [ ] lib/features/tracking/presentation/widgets/appeal_score_chip.dart
      → 이모지+텍스트 지원하도록 확장 (answer_button으로 활용)
- [ ] lib/features/tracking/presentation/widgets/severity_level_indicator.dart
      → 1-3 범위 지원 추가 (심각도 선택용)
```

#### 1.3 핵심 로직
```
- [ ] 질문 6개 순차 플로우
- [ ] 파생 질문 분기 로직 (힘들었어요 → 상세 질문)
- [ ] 기본 피드백 시스템 (CopingGuide 연동)
- [ ] 데이터 저장 (daily_checkins 테이블)
```

### Phase 2: 감정적 UX (P1)
```
- [ ] 시간대별 인사 (GreetingService)
- [ ] 연속 체크인 축하 (ConsecutiveDaysCalculator)
- [ ] 복귀 사용자 환영 (3일+ 공백 감지)
- [ ] 변화 감지 피드백 (WeeklyComparisonService)
```

### Phase 3: 안전 시스템 (P1)
```
- [ ] Red Flag 감지 로직 (RedFlagDetector)
- [ ] 안내 메시지 UI (RedFlagAlertDialog)
- [ ] 주사 다음날 컨텍스트 (PostInjectionDetector)
- [ ] red_flag_detected JSONB 저장
```

### Phase 4: 의료진 공유 (P2)
```
- [ ] 주간 리포트 생성 (WeeklyReportGenerator)
- [ ] 공유 모드 UI
- [ ] 텍스트 복사/공유 기능
```

### 파일 구조 최종 형태

```
lib/features/
├── daily_checkin/                    # [신규]
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── daily_checkin.dart
│   │   │   ├── symptom_detail.dart
│   │   │   ├── checkin_context.dart
│   │   │   ├── red_flag_detection.dart
│   │   │   └── checkin_feedback.dart
│   │   └── repositories/
│   │       └── daily_checkin_repository.dart
│   ├── infrastructure/
│   │   ├── dtos/
│   │   │   └── daily_checkin_dto.dart
│   │   └── repositories/
│   │       └── supabase_daily_checkin_repository.dart
│   ├── application/
│   │   ├── notifiers/
│   │   │   ├── daily_checkin_notifier.dart
│   │   │   └── checkin_feedback_notifier.dart
│   │   ├── services/
│   │   │   ├── greeting_service.dart
│   │   │   ├── red_flag_detector.dart
│   │   │   └── weekly_comparison_service.dart
│   │   └── providers.dart
│   └── presentation/
│       ├── screens/
│       │   └── daily_checkin_screen.dart
│       └── widgets/
│           ├── question_card.dart
│           ├── answer_button.dart
│           └── feedback_card.dart
├── tracking/                          # [수정]
│   ├── domain/
│   │   ├── entities/
│   │   │   └── weight_log.dart        # 유지
│   │   └── repositories/
│   │       └── tracking_repository.dart  # symptom 메서드 제거
│   └── infrastructure/
│       ├── dtos/
│       │   └── weight_log_dto.dart    # 유지
│       └── repositories/
│           └── supabase_tracking_repository.dart  # symptom 메서드 제거
└── coping_guide/                      # [유지] - 피드백에 활용
    └── ...
```

---

## XIV. 관련 문서

| 문서 | 경로 | 설명 |
|------|------|------|
| 초기 재설계안 | `docs/daily-checkin-redesign.md` | 철학적 배경 |
| 임상 기반 명세 | `docs/clinical-daily-checkin-spec.md` | 임상 지표 상세 |
| 질문 트리 상세 | `docs/daily-checkin-question-tree.md` | 분기 로직 상세 |
| PRD | `docs/prd.md` | 감정적 UX 원칙 |
| 기존 CopingGuide | `lib/features/coping_guide/` | 부작용 안심 메시지 |

---

## XV. 다음 세션 가이드

### 이 문서의 목적
GLP-1 앱의 "데일리 체크인" 기능을 근본적으로 재설계한 최종 명세서입니다.
기존의 "부작용 기록" 중심에서 "일상적 안부 질문" 중심으로 전환하여,
사용자가 매일 부담 없이 체크인하면서 자연스럽게 임상 데이터를 수집하고,
감정적 지지를 받을 수 있도록 설계되었습니다.

### 확정된 핵심 기능
1. **일상적 질문 6개**: 식사, 수분, 속 편안함, 화장실, 에너지, 기분
2. **자연스러운 파생**: "힘들었어요" 선택 시에만 부작용 상세 질문
3. **매 답변 피드백**: 긍정/지지 메시지 + 기존 CopingGuide 활용
4. **컨텍스트 인사**: 시간대별, 주사 다음날, 복귀 사용자
5. **연속 체크인 축하**: 3일, 7일, 14일 등 마일스톤
6. **변화 감지 피드백**: "지난주보다 나아졌어요" 등
7. **Red Flag 감지**: 췌장염, 담낭염, 탈수 등 숨겨진 감지 + 부드러운 안내
8. **의료진 공유**: 구조화된 주간 리포트

### 다음 단계
1. Phase 1 구현 시작 (핵심 질문 플로우)
2. UI 프로토타입 검토
3. 기존 코드 리팩토링 계획 수립
