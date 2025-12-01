# Dashboard Emotional UX - 오케스트레이션 에이전트 프롬프트

이 문서는 오케스트레이션 에이전트가 Task tool을 사용하여 범용 에이전트를 호출할 때 사용할 정밀 설계된 프롬프트입니다.

**중요**: 모든 에이전트는 `model: opus`로 실행합니다.

---

## 공통 디자인 철학 (모든 에이전트가 숙지해야 함)

이 섹션은 모든 에이전트 프롬프트의 서두에 포함됩니다.

```markdown
## 🎯 프로젝트 핵심 목적

이 프로젝트는 GLP-1 치료 관리 앱의 대시보드를 **감정적으로 지지하고 동기를 부여하는 따뜻한 UX**로 전환하는 것입니다.

### 왜 이렇게 해야 하는가?

GLP-1 주사제 사용자들은:
- 주사에 대한 **거부감과 두려움**을 느낌
- 부작용(메스꺼움, 변비 등)으로 **불안**해함
- 체중 감량 실패 경험으로 **자존감이 낮음**
- 장기 치료에 대한 **의욕 유지**가 어려움

우리의 앱은 이들에게:
- "당신은 잘하고 있어요"라는 **감정적 지지**
- 부작용은 "문제"가 아니라 "몸이 적응하는 신호"라는 **안심감**
- 작은 성공을 축하하는 **성취감**
- 혼자가 아니라는 **연결감**

을 전달해야 합니다.

---

## 📚 참조해야 할 UX 베스트 프랙티스

### 1. Noom (체중 감량 앱) - 심리 기반 접근
- **CBT(인지행동치료) 원리**: 부정적 사고 → 긍정적 재해석
- **레벨업 시스템**: "Novice → Apprentice → Advanced → Master"
- **사회적 증거**: "다른 Noomer들도 비슷한 경험을 해요"
- **가상 보상**: 일일 퀴즈 정답 시 "NoomCoin" + 가상 하이파이브

### 2. Headspace (멘탈 웰니스) - 따뜻한 UX
- **둥근 캐릭터**: 날카로운 모서리 없이, 다양한 크기/모양으로 포용성
- **암묵적 응원**: "You deserve some Headspace today!"
- **동료 비교 회피**: 친구에게 보내는 메시지가 모두 격려 중심
- **Progress Stats**: 연속 사용일로 성취감 제공

### 3. Duolingo (언어 학습) - 게이미피케이션
- **스트릭 효과**: 7일 스트릭 유지 시 장기 참여율 3.6배 증가
- **Streak Freeze**: 이탈 위험 사용자 이탈률 21% 감소
- **컨페티 폭발**: 레슨 완료 시 축하 애니메이션 → 완료율 30% 증가
- **변동 보상**: 예측 불가능한 보상으로 슬롯머신 심리 활용

### 4. Fitbit (건강 트래킹) - 마일스톤 축하
- **100개 이상 배지**: 모든 작은 성공 축하
- **단계별 목표**: "Boat Shoes(5,000보) → Olympian Sandals(100,000보)"
- **가상 챌린지**: 도시를 걷는 느낌의 재미 요소

### 5. Forest (습관 앱) - 감정적 연결
- **성장 은유**: 집중하면 나무가 자라고, 포기하면 시들어 죽음
- **실제 연결**: Trees for the Future 파트너십으로 실제 나무 심기
- **책임감**: 자신의 나무에 대한 감정적 유대

### 6. Flo/Clue (여성 건강) - 민감한 주제의 따뜻함
- **정상화**: "당신의 분비물을 사랑해야 하는 7가지 이유"
- **완곡어법 거부**: "Aunt Flo" 대신 "생리" 직접 사용 (숨기지 않음)
- **공감적 관계**: 전 직원이 사용자와 공감 훈련

---

## 🎨 디자인 원칙

### 색상 심리
| 컬러 | 심리적 효과 | 사용처 |
|------|------------|--------|
| **옐로/오렌지** | 따뜻함, 기쁨, 활력 | 축하, 격려 (Headspace 스타일) |
| **그린** | 성장, 건강, 안정 | 진행률, 목표 달성 |
| **소프트 블루** | 신뢰, 안정, 전문성 | 배경, 정보 영역 |
| **피치/코랄** | 친근함, 공감 | 부작용 관련 (Error 대신!) |

### 시각적 따뜻함
- **둥근 모서리**: 날카로운 모서리 금지 (Headspace)
- **부드러운 그라데이션**: 시각적 흥미 + 따뜻함
- **여백**: 숨 쉴 공간, 불안 감소

---

## 🎯 디자인 시스템 토큰 참조 (필수!)

**⚠️ 중요**: 아래 토큰을 정확히 사용해야 합니다. 임의의 이름 금지!

### Typography (AppTypography 클래스)
| 토큰 | 크기/Weight | 용도 |
|-----|------------|------|
| `AppTypography.display` | 28px Bold | 페이지 주 제목, 환영 메시지 |
| `AppTypography.heading1` | 24px Bold | 섹션 제목, 모달 제목 |
| `AppTypography.heading2` | 20px Semibold | 하위 섹션 제목, 카드 제목 |
| `AppTypography.heading3` | 18px Semibold | 강조 텍스트, 리스트 헤더 |
| `AppTypography.bodyLarge` | 16px Regular (Primary) | 주요 본문 |
| `AppTypography.bodySmall` | 14px Regular | 보조 텍스트, 라벨 |
| `AppTypography.caption` | 12px Regular | 캡션, 메타데이터 |
| `AppTypography.labelMedium` | 14px Medium | 탭 라벨, 보조 버튼 |

### Colors (AppColors 클래스)
| 토큰 | 값 | 용도 |
|-----|---|------|
| `AppColors.primary` | #4ADE80 | 주요 강조, 성장, 건강 |
| `AppColors.success` | #10B981 | 성공, 목표 달성, 완료 |
| `AppColors.warning` | #F59E0B | 주의 (부작용 관련에 사용!) |
| `AppColors.error` | #EF4444 | 에러만 (부작용에 사용 금지!) |
| `AppColors.neutral50` | #F8FAFC | 앱 배경 |
| `AppColors.neutral100` | #F1F5F9 | 카드/섹션 배경 |
| `AppColors.neutral200` | #E2E8F0 | 구분선, 테두리 |
| `AppColors.neutral500` | #64748B | 보조 텍스트, 아이콘 |
| `AppColors.neutral800` | #1E293B | 제목, 헤더 |
| `AppColors.textPrimary` | neutral800 | 제목 텍스트 |
| `AppColors.textSecondary` | neutral600 | 본문 텍스트 |
| `AppColors.textTertiary` | neutral500 | 캡션 텍스트 |
| `AppColors.gold` | #F59E0B | 골드 뱃지, 마일스톤 |

### 배경색 패턴 (밝은 배경)
```dart
// Success 밝은 배경 (격려 메시지 컨테이너)
AppColors.success.withOpacity(0.1)  // 또는 Color(0xFFECFDF5)

// Primary 밝은 배경 (Next-Up 뱃지)
AppColors.primary.withOpacity(0.1)

// Warning 밝은 배경 (부작용/적응기)
AppColors.warning.withOpacity(0.1)  // 또는 Color(0xFFFFFBEB)
```

### Spacing & Sizing
| 토큰 | 값 | 용도 |
|-----|---|------|
| xs | 4px | 텍스트-아이콘 간격 |
| sm | 8px | 컴포넌트 내부 패딩 |
| md | 16px | 기본 요소 간격 |
| lg | 24px | 섹션 간 간격 |
| xl | 32px | 주요 섹션 구분 |

### Border Radius
| 토큰 | 값 | 용도 |
|-----|---|------|
| sm | 8px | 버튼, 입력 필드 |
| md | 12px | 카드, 작은 모달 |
| lg | 16px | 큰 카드, 바텀시트 |
| full | 999px | 원형 아바타, 뱃지 |

### Shadows
```dart
// Card 기본 그림자 (sm)
BoxShadow(
  color: Color(0x0F0F172A).withOpacity(0.06),
  blurRadius: 4,
  offset: Offset(0, 2),
)
```

### 카피라이팅 원칙
| Before (차가운) | After (따뜻한) | 원리 |
|----------------|---------------|------|
| "부작용 3회 발생" | "3일을 잘 견뎌냈어요" | 인내를 성취로 |
| "순응도 72%" | "목표의 70% 이상 달성!" | 임계값 축하 |
| "다음 투여까지 4일" | "4일 후면 다음 단계로!" | 미래 지향적 |
| "Error" | "잠시 문제가 생겼어요" | 공감적 오류 |

---

## 🧠 구현 시 반드시 지켜야 할 심리학적 원칙

1. **정상화 (Normalization)**
   - 부작용은 "문제"가 아니라 "몸이 GLP-1에 적응하는 자연스러운 과정"
   - "많은 사용자들이 처음 2-3주간 비슷한 경험을 해요"

2. **성장 마인드셋 (Growth Mindset)**
   - 실패 → "배움의 기회"
   - 스트릭 끊김 → "새로운 시작을 응원해요" (죄책감 X)

3. **작은 승리 축적 (Small Wins)**
   - 매일 기록하는 것 자체가 성취
   - "오늘 기록을 완료했어요! 한 걸음 더 나아갔어요"

4. **손실 회피 → 성장 동기 전환**
   - "스트릭을 잃지 마세요" (X)
   - "연속 기록이 당신의 성장을 보여줘요!" (O)

5. **사회적 증거 (Social Proof)**
   - "대부분의 사용자들이 4주차에 적응을 느껴요"
   - "당신만 힘든 게 아니에요"
```

---

## 실행 순서

```
┌────────────────────────────────────────────────────────────┐
│  Step 1: 구현 에이전트 (6개 위젯 + 스크린 업데이트)           │
│  - 각 위젯별로 별도 opus 에이전트 호출                       │
│  - UX 철학이 코드에 녹아들도록 상세 지시                     │
└────────────────────────────────────────────────────────────┘
                              ↓
┌────────────────────────────────────────────────────────────┐
│  Step 2: 검증 에이전트 (opus)                               │
│  - 기술적 검증 + UX 의도 검증                               │
│  - "따뜻함"이 코드에 반영되었는지 확인                       │
└────────────────────────────────────────────────────────────┘
                              ↓
┌────────────────────────────────────────────────────────────┐
│  Step 3: 에셋 재활용 에이전트 (opus)                         │
│  - Component Registry 업데이트                              │
│  - UX 의도 문서화                                           │
└────────────────────────────────────────────────────────────┘
```

---

## Step 1: 구현 에이전트 프롬프트

### 1.1 EmotionalGreetingWidget 구현

```
당신은 Flutter UI 구현 전문가이자 UX 심리학 전문가입니다.

## 🎯 프로젝트 핵심 목적

이 프로젝트는 GLP-1 치료 관리 앱의 대시보드를 **감정적으로 지지하고 동기를 부여하는 따뜻한 UX**로 전환하는 것입니다.

### 왜 이렇게 해야 하는가?

GLP-1 주사제 사용자들은:
- 주사에 대한 **거부감과 두려움**을 느낌
- 부작용으로 **불안**해함
- 장기 치료에 대한 **의욕 유지**가 어려움

이 위젯은 사용자가 앱을 열 때 **가장 먼저 보는 것**입니다.
Headspace처럼 "You deserve some Headspace today!"라고 말해주는 것처럼,
우리도 "오늘도 건강한 선택을 하고 계시네요"라고 **따뜻하게 환영**해야 합니다.

---

## 📚 참조할 UX 베스트 프랙티스

### Headspace 스타일
- **시간대별 맞춤 인사**: "Good morning", "Good afternoon", "Good evening"
- **암묵적 응원**: "You're doing great", "Keep it up"
- **연속 기록을 성장의 증거로**: "You've meditated 7 days in a row!"

### Noom 스타일
- **사용자를 특별하게**: "Noomer"라고 부르며 커뮤니티 소속감
- **레벨 표시**: 현재 치료 주차를 "여정의 단계"로 표현

### 심리학적 원칙
- **긍정적 재해석**: 연속 기록일을 "꾸준함의 증거"로
- **작은 승리 인정**: 오늘 앱을 연 것 자체가 성취

---

## 작업 목표

GreetingWidget을 EmotionalGreetingWidget으로 개선합니다.

### 필수 사전 읽기 (반드시 순서대로)
1. Read: /Users/pro16/Desktop/project/n06/CLAUDE.md (아키텍처 규칙)
2. Read: /Users/pro16/Desktop/project/n06/.claude/skills/ui-renewal/projects/dashboard-emotional-ux/20251201-implementation-v1.md (구현 명세 - "Component 1: EmotionalGreetingWidget" 섹션)
3. Read: /Users/pro16/Desktop/project/n06/lib/features/dashboard/presentation/widgets/greeting_widget.dart (기존 구현 참조)
4. Read: /Users/pro16/Desktop/project/n06/lib/core/presentation/theme/app_colors.dart (색상 토큰)
5. Read: /Users/pro16/Desktop/project/n06/lib/core/presentation/theme/app_typography.dart (타이포그래피 토큰)
6. Read: /Users/pro16/Desktop/project/n06/lib/features/dashboard/domain/entities/dashboard_data.dart (데이터 구조)

---

## 구현 핵심 의도

### 1. 시간대별 따뜻한 인사 (Headspace 스타일)
```dart
// 단순한 "안녕하세요" 대신
// 시간대에 따른 공감적 인사
String getTimeBasedGreeting(String userName) {
  final hour = DateTime.now().hour;
  if (hour < 12) {
    return '좋은 아침이에요, $userName님!';
  } else if (hour < 18) {
    return '좋은 오후예요, $userName님!';
  } else {
    return '오늘 하루도 수고하셨어요, $userName님!';
  }
}
```

### 2. 연속 기록일을 "성장의 증거"로 (Duolingo 스트릭)
- 숫자만 보여주지 말고 의미를 부여
- "5일째 연속으로 건강한 습관을 만들어가고 있어요!"
- 7일, 14일, 30일 마일스톤에서 특별 메시지

### 3. Insight 메시지를 격려 컨테이너로 (Noom 스타일)
- Success 색상 배경의 둥근 컨테이너
- 스파클 아이콘으로 특별함 강조
- 메시지 자체가 "당신을 응원하고 있어요" 느낌

---

## 디자인 토큰 (하드코딩 금지 - 정확한 클래스명 사용!)
- Card: `AppColors.surface` + `AppColors.neutral200` border + 12px radius + sm shadow
- 인사: `AppTypography.display` (28px Bold), `AppColors.textPrimary`
- 통계값: `AppTypography.heading2` (20px Semibold), `AppColors.primary` (성장/건강)
- 통계라벨: `AppTypography.caption` (12px), `AppColors.textTertiary`
- 격려메시지 컨테이너: `AppColors.success.withOpacity(0.1)` 배경 + `AppColors.success` 텍스트

---

## 출력 파일
/Users/pro16/Desktop/project/n06/lib/features/dashboard/presentation/widgets/emotional_greeting_widget.dart

## 제약 조건
- Presentation Layer만 수정 (application/, domain/, infrastructure/ 금지)
- 기존 DashboardData 구조 그대로 사용
- const 생성자 사용
- 하드코딩된 메시지 금지 (함수로 동적 생성)

## 완료 조건
1. 파일 생성 완료
2. flutter analyze 에러 없음
3. 시간대별 인사 함수 구현 확인
4. 연속 기록일에 의미 부여 텍스트 확인
5. 격려 메시지 컨테이너가 따뜻한 색상인지 확인

작업을 시작하세요.
```

---

### 1.2 EncouragingProgressWidget 구현

```
당신은 Flutter UI 구현 전문가이자 UX 심리학 전문가입니다.

## 🎯 프로젝트 핵심 목적

이 프로젝트는 GLP-1 치료 관리 앱의 대시보드를 **감정적으로 지지하고 동기를 부여하는 따뜻한 UX**로 전환하는 것입니다.

### 왜 이 위젯이 중요한가?

현재 "부작용 기록"이라는 라벨은 사용자에게:
- **부정적 연상**을 유발 ("부작용 = 나쁜 것")
- **기록 부담**을 증가 ("또 부작용을 기록해야 해...")
- **치료에 대한 거부감**을 강화

우리는 이것을 **정상화(Normalization)**해야 합니다.
Flo 앱이 "당신의 분비물을 사랑해야 하는 7가지 이유"로 taboo를 깨듯,
우리도 "부작용"을 "몸이 적응하는 신호"로 재해석해야 합니다.

---

## 📚 참조할 UX 베스트 프랙티스

### Flo/Clue 스타일 - 정상화
- **숨기지 않음**: 완곡어법 대신 직접적이지만 따뜻하게
- **교육적 프레이밍**: "이것은 자연스러운 과정이에요"
- **공감**: "힘드시죠, 하지만 대부분 2-3주면 나아져요"

### Duolingo 스타일 - 진행률 축하
- **80%+ 달성 시 축하**: 스파클 효과, 컨페티
- **완료 시 특별 메시지**: "완벽해요!", "대단해요!"
- **시각적 보상**: 그라데이션, 애니메이션

### Fitbit 스타일 - 마일스톤
- **단계별 목표**: 달성률에 따른 시각적 변화
- **즉각적 피드백**: 진행 시 색상 변화

---

## 작업 목표

WeeklyProgressWidget을 EncouragingProgressWidget으로 개선합니다.

### 필수 사전 읽기
1. Read: /Users/pro16/Desktop/project/n06/CLAUDE.md
2. Read: /Users/pro16/Desktop/project/n06/.claude/skills/ui-renewal/projects/dashboard-emotional-ux/20251201-implementation-v1.md ("Component 2" 섹션)
3. Read: /Users/pro16/Desktop/project/n06/lib/features/dashboard/presentation/widgets/weekly_progress_widget.dart
4. Read: /Users/pro16/Desktop/project/n06/lib/features/dashboard/domain/entities/weekly_progress.dart
5. Read: /Users/pro16/Desktop/project/n06/lib/core/presentation/theme/app_colors.dart
6. Read: /Users/pro16/Desktop/project/n06/lib/core/presentation/theme/app_typography.dart

---

## 구현 핵심 의도

### 1. 라벨 리프레이밍 - 정상화 (가장 중요!)

```dart
/// 부정적 라벨을 긍정적/정상화된 라벨로 변환
///
/// 심리학적 근거:
/// - "부작용" → "몸의 신호" : 부작용을 문제가 아닌 피드백으로 재해석
/// - "기록" → "체크" : 부담을 줄이고 간단한 행동으로 인식
String getEncouragingLabel(String originalLabel) {
  switch (originalLabel.toLowerCase()) {
    case '투여':
      return '투여 완료';  // 완료 = 성취
    case '체중 기록':
      return '변화 추적';  // 기록 → 추적 (능동적)
    case '부작용 기록':
      return '몸의 신호 체크';  // 핵심 리프레이밍!
    default:
      return originalLabel;
  }
}
```

### 2. 80%+ 달성 시 축하 (Duolingo 스타일)
- **스파클 아이콘**: Icons.auto_awesome (반짝이는 별)
- **스케일 애니메이션**: 0.0 → 1.0, elasticOut 커브
- **Success 컬러**: 달성감 시각화

### 3. 그라데이션 진행률 바 (시각적 따뜻함)
- **시작**: Primary 60% opacity (시작은 부드럽게)
- **끝**: Primary 100% (완료에 가까울수록 강해짐)
- **100%**: Success 컬러 단색 (완료는 특별하게)

---

## 라벨 매핑 함수 (반드시 구현)
```dart
getEncouragingLabel(String originalLabel)
// '투여' → '투여 완료'
// '체중 기록' → '변화 추적'
// '부작용 기록' → '몸의 신호 체크'
```

## 출력 파일
/Users/pro16/Desktop/project/n06/lib/features/dashboard/presentation/widgets/encouraging_progress_widget.dart

## 제약 조건
- WeeklyProgress entity 구조 변경 금지
- 하드코딩된 라벨 금지 (매핑 함수 사용)
- Presentation Layer만 수정

## 완료 조건
1. 파일 생성 완료
2. getEncouragingLabel 함수 구현 확인
3. "부작용 기록"이 화면에 절대 나오지 않음 ("몸의 신호 체크"만)
4. 80%+ sparkle 효과 구현 확인
5. 그라데이션 진행률 바 구현 확인

작업을 시작하세요.
```

---

### 1.3 HopefulScheduleWidget 구현

```
당신은 Flutter UI 구현 전문가이자 UX 심리학 전문가입니다.

## 🎯 프로젝트 핵심 목적

이 프로젝트는 GLP-1 치료 관리 앱의 대시보드를 **감정적으로 지지하고 동기를 부여하는 따뜻한 UX**로 전환하는 것입니다.

### 왜 이 위젯이 중요한가?

현재 "다음 투여", "다음 증량" 같은 의료 용어는:
- **임상적이고 차가운** 느낌
- **의무감**을 유발 ("또 주사를 맞아야 해...")
- **거부감**을 강화

우리는 이것을 **여정의 다음 단계**로 프레이밍해야 합니다.
Forest 앱에서 나무가 자라는 것처럼,
치료도 "성장의 과정"으로 느껴져야 합니다.

---

## 📚 참조할 UX 베스트 프랙티스

### Forest 스타일 - 성장 은유
- **나무 성장**: 시간이 지나면 작은 씨앗 → 큰 나무
- **단계적 발전**: 각 단계가 성장의 증거
- **감정적 연결**: 내 나무를 돌보는 느낌

### Noom 스타일 - 레벨업
- **단계별 여정**: "Novice → Apprentice → Master"
- **다음 단계 기대감**: "곧 다음 레벨로!"
- **격려 메시지**: 각 단계에 응원 문구

### Headspace 스타일 - 부드러운 안내
- **압박 없는 리마인더**: "다음 세션이 기다리고 있어요"
- **선택의 여지**: "준비되면 언제든지"

---

## 작업 목표

NextScheduleWidget을 HopefulScheduleWidget으로 개선합니다.

### 필수 사전 읽기
1. Read: /Users/pro16/Desktop/project/n06/CLAUDE.md
2. Read: /Users/pro16/Desktop/project/n06/.claude/skills/ui-renewal/projects/dashboard-emotional-ux/20251201-implementation-v1.md ("Component 3" 섹션)
3. Read: /Users/pro16/Desktop/project/n06/lib/features/dashboard/presentation/widgets/next_schedule_widget.dart
4. Read: /Users/pro16/Desktop/project/n06/lib/features/dashboard/domain/entities/next_schedule.dart
5. Read: /Users/pro16/Desktop/project/n06/lib/core/presentation/theme/app_colors.dart
6. Read: /Users/pro16/Desktop/project/n06/lib/core/presentation/theme/app_typography.dart

---

## 구현 핵심 의도

### 1. 의료 용어 → 여정 언어 (Forest 스타일)

```dart
/// 의료 용어를 여정/성장 언어로 변환
///
/// 심리학적 근거:
/// - "투여" → "단계" : 치료를 여정의 일부로 인식
/// - "증량" → "성장" : 용량 증가를 부담이 아닌 발전으로
String getHopefulTitle(String scheduleType) {
  switch (scheduleType) {
    case 'dose':
      return '다음 단계';  // 투여 → 단계
    case 'escalation':
      return '성장의 순간';  // 증량 → 성장
    default:
      return scheduleType;
  }
}
```

### 2. 격려 메시지 추가 (Headspace 스타일)

```dart
/// 각 일정에 따뜻한 격려 메시지 제공
///
/// 심리학적 근거:
/// - 불안 감소: 미리 준비하면 덜 두렵다
/// - 정상화: "많은 분들이 이 단계를 거쳐요"
String getSupportMessage(String scheduleType) {
  switch (scheduleType) {
    case 'dose':
      return '투여 전 물 한 잔, 오늘도 건강한 선택!';
    case 'escalation':
      return '몸이 잘 적응하고 있어요. 다음 단계로 나아갈 준비가 되었어요.';
    default:
      return '';
  }
}
```

### 3. 아이콘 원형 배경 (시각적 따뜻함)
- **`AppColors.primary.withOpacity(0.1)` 배경**: 부드럽고 포근한 느낌
- **둥근 모서리**: Headspace 스타일
- **적절한 크기**: 40x40px로 눈에 띄지만 압박적이지 않게

---

## 출력 파일
/Users/pro16/Desktop/project/n06/lib/features/dashboard/presentation/widgets/hopeful_schedule_widget.dart

## 제약 조건
- NextSchedule entity 구조 변경 금지
- Presentation Layer만 수정

## 완료 조건
1. 파일 생성 완료
2. getHopefulTitle, getSupportMessage 함수 구현 확인
3. "다음 투여"가 화면에 나오지 않음 ("다음 단계"만)
4. 격려 메시지 컨테이너 (`AppColors.neutral50` 배경, `AppColors.primary` 텍스트)
5. 아이콘 원형 배경 스타일 확인

작업을 시작하세요.
```

---

### 1.4 CelebratoryReportWidget 구현

```
당신은 Flutter UI 구현 전문가이자 UX 심리학 전문가입니다.

## 🎯 프로젝트 핵심 목적

이 프로젝트는 GLP-1 치료 관리 앱의 대시보드를 **감정적으로 지지하고 동기를 부여하는 따뜻한 UX**로 전환하는 것입니다.

### 왜 이 위젯이 중요한가?

현재 "부작용 3회, 순응도 72%" 같은 표현은:
- **평가받는 느낌** ("72%... 부족하네...")
- **숫자의 압박** ("3회나 부작용이...")
- **자책감 유발** ("왜 나는 100%를 못 하지?")

우리는 이것을 **축하의 언어**로 바꿔야 합니다.
Duolingo가 "You're on fire! 🔥"라고 외치듯,
우리도 "목표의 70% 이상을 달성했어요! 잘하고 있어요!"라고 말해야 합니다.

---

## 📚 참조할 UX 베스트 프랙티스

### Duolingo 스타일 - 축하 문화
- **임계값 축하**: 50%만 해도 "Great start!"
- **점진적 격려**: 70% "You're doing great!", 90% "Almost there!", 100% "Perfect!"
- **절대 비난 없음**: 낮은 점수도 "Keep trying!"

### Noom 스타일 - 긍정적 재해석
- **모든 데이터를 성취로**: "이번 주에 5번 식사를 기록했어요!"
- **비교 대신 개인 성장**: "지난주보다 2번 더 기록했어요"

### Fitbit 스타일 - 작은 승리
- **모든 활동 인정**: 500보만 걸어도 "Good start!"
- **트렌드 강조**: "올바른 방향으로 가고 있어요"

---

## 작업 목표

WeeklyReportWidget을 CelebratoryReportWidget으로 개선합니다.

### 필수 사전 읽기
1. Read: /Users/pro16/Desktop/project/n06/CLAUDE.md
2. Read: /Users/pro16/Desktop/project/n06/.claude/skills/ui-renewal/projects/dashboard-emotional-ux/20251201-implementation-v1.md ("Component 4" 섹션)
3. Read: /Users/pro16/Desktop/project/n06/lib/features/dashboard/presentation/widgets/weekly_report_widget.dart
4. Read: /Users/pro16/Desktop/project/n06/lib/features/dashboard/domain/entities/weekly_summary.dart
5. Read: /Users/pro16/Desktop/project/n06/lib/core/presentation/theme/app_colors.dart
6. Read: /Users/pro16/Desktop/project/n06/lib/core/presentation/theme/app_typography.dart

---

## 구현 핵심 의도

### 1. 숫자를 축하로 변환 (Duolingo 스타일)

```dart
/// 냉정한 숫자를 축하의 언어로 변환
///
/// 심리학적 근거:
/// - "3회 발생" → "3일을 견뎌냈어요" : 피해자 → 극복자
/// - "72%" → "70% 이상 달성!" : 부족함 → 임계값 초과
String getCelebratoryValue(String type, dynamic value) {
  switch (type) {
    case 'dose':
      return '${value}회 투여 완료';  // 완료 = 성취
    case 'weight':
      final direction = value < 0 ? '줄었어요!' : '늘었어요';
      return '${value.abs().toStringAsFixed(1)}kg $direction';
    case 'symptom':
      return '${value}일을 잘 견뎌냈어요';  // 핵심! 피해 → 극복
    case 'adherence':
      return '목표의 ${value.toStringAsFixed(0)}% 달성!';  // 달성 강조
    default:
      return value.toString();
  }
}
```

### 2. 임계값별 축하 메시지 (Duolingo 스타일)

```dart
/// 순응도에 따른 격려 메시지
///
/// 심리학적 근거:
/// - 70%도 칭찬: "잘하고 있어요" (Duolingo는 50%도 칭찬)
/// - 100%는 특별: "완벽해요!" + 시각적 효과
String getAdherenceMessage(double percentage) {
  if (percentage >= 100) return '완벽해요!';
  if (percentage >= 90) return '거의 다 왔어요!';
  if (percentage >= 70) return '잘하고 있어요!';
  return '';  // 70% 미만도 비난 없음
}
```

### 3. 부작용 색상 변경 (중요!)
- **Error (#EF4444) → Warning (#F59E0B)**
- **심리학적 이유**: Error = 잘못됨, Warning = 주의 필요 (덜 위협적)
- **라벨도 변경**: "부작용" → "적응기"

---

## CRITICAL 변경 사항
- 부작용 아이콘: `AppColors.error` → `AppColors.warning` (#F59E0B)
- 부작용 라벨: "부작용" → "적응기"
- 순응도 70%+: `AppColors.primary` → `AppColors.success`

## 출력 파일
/Users/pro16/Desktop/project/n06/lib/features/dashboard/presentation/widgets/celebratory_report_widget.dart

## 제약 조건
- WeeklySummary entity 구조 변경 금지
- 기존 탭 네비게이션 로직 (context.push('/trend-dashboard')) 유지
- Presentation Layer만 수정

## 완료 조건
1. 파일 생성 완료
2. 부작용 아이콘 색상이 Warning인지 확인 (Error 금지!)
3. "부작용"이 화면에 나오지 않음 ("적응기"만)
4. 70%+ 순응도에 Success 컬러 + 격려 메시지
5. getCelebratoryValue, getAdherenceMessage 함수 구현 확인

작업을 시작하세요.
```

---

### 1.5 JourneyTimelineWidget 구현

```
당신은 Flutter UI 구현 전문가이자 UX 심리학 전문가입니다.

## 🎯 프로젝트 핵심 목적

이 프로젝트는 GLP-1 치료 관리 앱의 대시보드를 **감정적으로 지지하고 동기를 부여하는 따뜻한 UX**로 전환하는 것입니다.

### 왜 이 위젯이 중요한가?

타임라인은 **사용자의 여정을 보여주는** 위젯입니다.
하지만 현재는 단순 이벤트 나열에 그쳐:
- **성취감 부족**: "그래서 뭐?" 느낌
- **거리감**: 자신의 이야기로 느껴지지 않음
- **스토리 부재**: 연결된 여정이 아닌 파편화된 사건들

우리는 이것을 **"당신이 얼마나 멀리 왔는지"** 보여주는
**감동적인 여정 스토리**로 만들어야 합니다.

---

## 📚 참조할 UX 베스트 프랙티스

### Forest 스타일 - 성장 시각화
- **시작부터 현재까지**: 씨앗 → 새싹 → 나무 → 숲
- **누적된 성취**: "지금까지 100그루를 심었어요"
- **마일스톤 축하**: 특별한 순간은 더 크게

### Fitbit 스타일 - 마일스톤 강조
- **배지 시스템**: 중요한 성취는 금색으로
- **최근 성취 강조**: "NEW" 뱃지
- **요약 통계**: "이번 달 X개의 배지를 획득했어요"

### Headspace 스타일 - 연속성
- **여정 감각**: "Day 7 of your journey"
- **과거와 현재 연결**: "처음 시작했을 때를 기억하세요"

---

## 작업 목표

TimelineWidget을 JourneyTimelineWidget으로 개선합니다.

### 필수 사전 읽기
1. Read: /Users/pro16/Desktop/project/n06/CLAUDE.md
2. Read: /Users/pro16/Desktop/project/n06/.claude/skills/ui-renewal/projects/dashboard-emotional-ux/20251201-implementation-v1.md ("Component 5" 섹션)
3. Read: /Users/pro16/Desktop/project/n06/lib/features/dashboard/presentation/widgets/timeline_widget.dart
4. Read: /Users/pro16/Desktop/project/n06/lib/features/dashboard/domain/entities/timeline_event.dart
5. Read: /Users/pro16/Desktop/project/n06/lib/core/presentation/theme/app_colors.dart
6. Read: /Users/pro16/Desktop/project/n06/lib/core/presentation/theme/app_typography.dart

---

## 구현 핵심 의도

### 1. 여정 요약 헤더 (Forest 스타일)
- **상단에 요약**: "4주간 3개의 성취를 달성했어요!"
- **`AppColors.success.withOpacity(0.1)` 배경**: 따뜻하고 축하하는 느낌
- **트로피 아이콘**: 성취감 시각화

```dart
/// 여정 요약 통계 계산
int getMilestoneCount(List<TimelineEvent> events) {
  return events.where((e) =>
    e.eventType == TimelineEventType.weightMilestone ||
    e.eventType == TimelineEventType.badgeAchievement
  ).length;
}
```

### 2. 마일스톤 강조 (Fitbit 스타일)
- **일반 이벤트**: 16px dot, 3px border
- **마일스톤**: 20px dot, 4px border, **gold glow** 효과
- **심리학적 이유**: 중요한 순간은 시각적으로 특별해야

### 3. NEW 뱃지 (Fitbit 스타일)
- **24시간 내 이벤트**: "NEW" 뱃지 표시
- **`AppColors.primary.withOpacity(0.1)` 배경**: 눈에 띄지만 과하지 않게
- **심리학적 이유**: 최근 성취에 대한 즉각적 인정

```dart
/// 24시간 이내 이벤트인지 확인
bool isNew(DateTime eventDate) {
  return DateTime.now().difference(eventDate).inHours < 24;
}
```

---

## 출력 파일
/Users/pro16/Desktop/project/n06/lib/features/dashboard/presentation/widgets/journey_timeline_widget.dart

## 제약 조건
- TimelineEvent entity 구조 변경 금지
- Presentation Layer만 수정

## 완료 조건
1. 파일 생성 완료
2. 여정 요약 컨테이너 ("X주간 X개의 성취") 구현 확인
3. 마일스톤 dot에 gold glow 효과 확인
4. NEW 뱃지 로직 (24시간 이내) 구현 확인
5. getMilestoneCount, isNew 함수 구현 확인

작업을 시작하세요.
```

---

### 1.6 CelebratoryBadgeWidget 구현

```
당신은 Flutter UI 구현 전문가이자 UX 심리학 전문가입니다.

## 🎯 프로젝트 핵심 목적

이 프로젝트는 GLP-1 치료 관리 앱의 대시보드를 **감정적으로 지지하고 동기를 부여하는 따뜻한 UX**로 전환하는 것입니다.

### 왜 이 위젯이 중요한가?

뱃지 시스템은 **게이미피케이션의 핵심**입니다.
Duolingo가 성공한 이유 중 하나는 **즉각적인 보상감**입니다.
하지만 현재 뱃지 위젯은:
- **축하 애니메이션 부재**: 뱃지를 받아도 "그냥 생겼네" 느낌
- **다음 목표 불명확**: "뭘 해야 다음 뱃지를 받지?"
- **빈 상태 우울함**: "뱃지가 없네..." 느낌

---

## 📚 참조할 UX 베스트 프랙티스

### Duolingo 스타일 - 즉각적 보상
- **컨페티 폭발**: 레슨 완료 시 애니메이션 → 완료율 30% 증가
- **스케일 애니메이션**: 뱃지 획득 시 0.5 → 1.2 → 1.0
- **사운드 효과**: (앱에서는 시각적으로 대체)

### Fitbit 스타일 - 100개 이상 배지
- **모든 작은 성공 축하**: 첫 걸음도 뱃지
- **희귀도 표시**: Bronze/Silver/Gold
- **다음 배지 프리뷰**: "다음 목표: 10km 걷기"

### 변동 보상 (슬롯머신 심리)
- **예상치 못한 뱃지**: "깜짝 뱃지를 받았어요!"
- **진행률 표시**: "다음 뱃지까지 20%!"

---

## 작업 목표

BadgeWidget을 CelebratoryBadgeWidget으로 개선합니다.

### 필수 사전 읽기
1. Read: /Users/pro16/Desktop/project/n06/CLAUDE.md
2. Read: /Users/pro16/Desktop/project/n06/.claude/skills/ui-renewal/projects/dashboard-emotional-ux/20251201-implementation-v1.md ("Component 6" 섹션)
3. Read: /Users/pro16/Desktop/project/n06/lib/features/dashboard/presentation/widgets/badge_widget.dart
4. Read: /Users/pro16/Desktop/project/n06/lib/features/dashboard/domain/entities/user_badge.dart
5. Read: /Users/pro16/Desktop/project/n06/lib/core/presentation/theme/app_colors.dart
6. Read: /Users/pro16/Desktop/project/n06/lib/core/presentation/theme/app_typography.dart

---

## 구현 핵심 의도

### 1. 다음 획득 가능 뱃지 하이라이트 (Fitbit 스타일)
- **가장 진행률 높은 뱃지**: dashed Primary border
- **Primary 5% 배경**: "이 뱃지가 가장 가까워요!"
- **심리학적 이유**: 명확한 목표는 동기를 높임

```dart
/// 다음 획득 가능 뱃지 찾기 (가장 진행률 높은)
UserBadge? getNextUpBadge(List<UserBadge> badges) {
  final inProgress = badges.where((b) => b.status == BadgeStatus.inProgress);
  if (inProgress.isEmpty) return null;
  return inProgress.reduce((a, b) =>
    a.progressPercentage > b.progressPercentage ? a : b
  );
}
```

### 2. 빈 상태 개선 (Headspace 스타일)
- **아이콘 변경**: emoji_events → **celebration** (더 따뜻함)
- **격려 메시지**: "첫 뱃지를 향해 나아가고 있어요!"
- **심리학적 이유**: 빈 상태도 긍정적으로

### 3. 탭 피드백 (미세한 인터랙션)
- **AnimatedScale**: 0.95 → 1.0 (100ms)
- **심리학적 이유**: 반응하는 UI는 살아있는 느낌

---

## 출력 파일
/Users/pro16/Desktop/project/n06/lib/features/dashboard/presentation/widgets/celebratory_badge_widget.dart

## 제약 조건
- UserBadge entity 구조 변경 금지
- 기존 BottomSheet 상세보기 로직 유지
- Presentation Layer만 수정

## 완료 조건
1. 파일 생성 완료
2. getNextUpBadge 함수 구현 확인
3. Next-Up 뱃지에 dashed Primary border
4. Empty state 아이콘: Icons.celebration (NOT emoji_events)
5. Empty state 메시지: "첫 뱃지를 향해 나아가고 있어요!"

작업을 시작하세요.
```

---

### 1.7 홈 대시보드 스크린 업데이트

```
당신은 Flutter UI 구현 전문가입니다.

## 작업 목표

home_dashboard_screen.dart의 import와 위젯 참조를 새 위젯으로 교체합니다.

## 필수 사전 읽기
1. Read: /Users/pro16/Desktop/project/n06/CLAUDE.md
2. Read: /Users/pro16/Desktop/project/n06/lib/features/dashboard/presentation/screens/home_dashboard_screen.dart

## 변경 내용

### Import 변경
OLD → NEW:
- greeting_widget.dart → emotional_greeting_widget.dart
- weekly_progress_widget.dart → encouraging_progress_widget.dart
- next_schedule_widget.dart → hopeful_schedule_widget.dart
- weekly_report_widget.dart → celebratory_report_widget.dart
- timeline_widget.dart → journey_timeline_widget.dart
- badge_widget.dart → celebratory_badge_widget.dart

### 위젯 교체
- GreetingWidget → EmotionalGreetingWidget
- WeeklyProgressWidget → EncouragingProgressWidget
- NextScheduleWidget → HopefulScheduleWidget
- WeeklyReportWidget → CelebratoryReportWidget
- TimelineWidget → JourneyTimelineWidget
- BadgeWidget → CelebratoryBadgeWidget

## 수정 파일
/Users/pro16/Desktop/project/n06/lib/features/dashboard/presentation/screens/home_dashboard_screen.dart

## 제약 조건
- 비즈니스 로직 (dashboardNotifierProvider 호출) 유지
- RefreshIndicator 로직 유지
- AppBar 스타일 유지
- 위젯 간 spacing (SizedBox height: 24) 유지

## 완료 조건
1. 모든 import 교체 완료
2. 모든 위젯 참조 교체 완료
3. flutter analyze 에러 없음

작업을 시작하세요.
```

---

## Step 2: 검증 에이전트 프롬프트

```
당신은 Flutter 코드 품질 검증 전문가이자 UX 심리학 전문가입니다.

## 🎯 검증 목표

Dashboard Emotional UX 구현이 **기술적으로 정확**하고 **UX 의도대로** 완료되었는지 검증합니다.

---

## 검증 항목

### 1. 아키텍처 준수 검증
```bash
bash /Users/pro16/Desktop/project/n06/.claude/skills/ui-renewal/scripts/validate_presentation_layer.sh check
```
기대 결과: "✅ VALIDATION PASSED"

### 2. Lint 검증
```bash
cd /Users/pro16/Desktop/project/n06 && flutter analyze lib/features/dashboard/presentation/
```
기대 결과: "No issues found!"

---

### 3. UX 의도 검증 (가장 중요!)

각 파일을 읽고 다음 **심리학적 원칙**이 코드에 반영되었는지 확인하세요:

#### 3.1 EmotionalGreetingWidget - "따뜻한 환영"
- [ ] getTimeBasedGreeting 함수: 아침/오후/저녁별 다른 인사
- [ ] 연속 기록일에 "성장" 관련 표현 포함
- [ ] insightMessage 컨테이너: `AppColors.success.withOpacity(0.1)` 배경
- [ ] **금지어 확인**: "단순히", "그냥" 같은 무의미한 표현 없음

#### 3.2 EncouragingProgressWidget - "정상화"
- [ ] getEncouragingLabel 함수 존재
- [ ] **핵심 확인**: "부작용 기록" → "몸의 신호 체크"로 매핑됨
- [ ] 80%+ 달성 시 Icons.auto_awesome (sparkle) 존재
- [ ] 그라데이션 LinearProgressIndicator 사용
- [ ] **금지어 확인**: 화면 어디에도 "부작용 기록" 문자열 없음

#### 3.3 HopefulScheduleWidget - "여정 언어"
- [ ] getHopefulTitle 함수: "다음 투여" → "다음 단계"
- [ ] getSupportMessage 함수: 격려 메시지 반환
- [ ] 격려 메시지 컨테이너: `AppColors.neutral50` 배경, `AppColors.primary` 텍스트
- [ ] **금지어 확인**: "다음 투여", "다음 증량" 문자열 없음

#### 3.4 CelebratoryReportWidget - "축하 언어"
- [ ] getCelebratoryValue 함수: 숫자 → 축하 언어
- [ ] getAdherenceMessage 함수: 70%+ "잘하고 있어요!"
- [ ] **색상 확인**: 부작용 아이콘 = `AppColors.warning` (NOT error!)
- [ ] **라벨 확인**: "부작용" → "적응기"
- [ ] **금지어 확인**: "부작용", "순응도 X%" (숫자만) 없음

#### 3.5 JourneyTimelineWidget - "스토리텔링"
- [ ] 여정 요약 헤더: "X주간 X개의 성취"
- [ ] getMilestoneCount 함수 존재
- [ ] isNew 함수: 24시간 이내 체크
- [ ] 마일스톤 dot: `AppColors.gold` 색상 + glow 효과
- [ ] NEW 뱃지: `AppColors.primary.withOpacity(0.1)` 배경

#### 3.6 CelebratoryBadgeWidget - "게이미피케이션"
- [ ] getNextUpBadge 함수 존재
- [ ] Next-Up 뱃지: dashed `AppColors.primary` border
- [ ] Empty state 아이콘: Icons.celebration (NOT emoji_events)
- [ ] Empty state 메시지: "첫 뱃지를 향해" 포함

---

### 4. 하드코딩 검사

각 파일에서 다음 **금지 패턴**이 없는지 확인:

#### 금지 문자열 (화면에 직접 노출되면 안 됨)
- "부작용 기록" → "몸의 신호 체크" 사용
- "다음 투여" → "다음 단계" 사용
- "다음 증량" → "성장의 순간" 사용
- "부작용" (단독) → "적응기" 사용
- "순응도 72%" (숫자만) → "목표의 70% 이상 달성!" 사용

#### 금지 색상 사용
- 부작용/적응기 관련: AppColors.error 사용 금지 → AppColors.warning 사용

---

## 출력 형식

```markdown
# 검증 결과 보고서

## 1. 아키텍처 준수: ✅/❌
{결과 상세}

## 2. Lint 검증: ✅/❌
{결과 상세}

## 3. UX 의도 검증

### 3.1 EmotionalGreetingWidget
| 항목 | 상태 | 비고 |
|------|------|------|
| 시간대별 인사 | ✅/❌ | |
| 성장 표현 | ✅/❌ | |
| Success 배경 | ✅/❌ | |

### 3.2 EncouragingProgressWidget
| 항목 | 상태 | 비고 |
|------|------|------|
| 라벨 리프레이밍 | ✅/❌ | |
| "부작용 기록" 금지 | ✅/❌ | |
| 80% sparkle | ✅/❌ | |

[... 나머지 위젯 ...]

## 4. 금지어/금지색상 검사
- "부작용 기록" 발견: ✅ 없음 / ❌ {위치}
- "다음 투여" 발견: ✅ 없음 / ❌ {위치}
- AppColors.error 부적절 사용: ✅ 없음 / ❌ {위치}

## 5. 종합 결과: ✅ PASS / ❌ FAIL

### 수정 필요 항목:
1. {문제점} - {해결 방법}
2. ...
```

작업을 시작하세요.
```

---

## Step 3: 에셋 재활용 에이전트 프롬프트

```
당신은 UI Renewal 에셋 정리 전문 에이전트입니다.

## 작업 목표

Dashboard Emotional UX 구현 완료 후 에셋을 정리하고 재사용 가능하도록 등록합니다.

## 필수 사전 읽기
1. Read: /Users/pro16/Desktop/project/n06/.claude/skills/ui-renewal/references/phase3-asset-organization.md
2. Read: /Users/pro16/Desktop/project/n06/.claude/skills/ui-renewal/component-library/registry.json

---

## 작업 순서

### Step 1: Component Registry 업데이트

registry.json에 6개 컴포넌트 추가:

각 컴포넌트에 **designIntent** 필드 추가 (UX 의도 문서화):

```json
{
  "name": "EmotionalGreetingWidget",
  "createdDate": "2024-12-01",
  "framework": "flutter",
  "file": "flutter/EmotionalGreetingWidget.dart",
  "projectFile": "lib/features/dashboard/presentation/widgets/emotional_greeting_widget.dart",
  "usedIn": ["dashboard-emotional-ux"],
  "category": "display",
  "description": "시간대별 인사 + 격려 메시지 위젯",
  "designIntent": {
    "uxPrinciple": "Headspace 스타일 따뜻한 환영",
    "psychologicalBasis": "첫인상이 전체 경험을 좌우함",
    "keyFeatures": ["시간대별 인사", "연속 기록 성장 표현", "격려 메시지 컨테이너"]
  },
  "designTokens": {
    "colors": ["AppColors.primary", "AppColors.success", "AppColors.textPrimary", "AppColors.textTertiary"],
    "typography": ["AppTypography.display", "AppTypography.heading2", "AppTypography.caption", "AppTypography.labelMedium"],
    "spacing": ["lg (24px)", "md (16px)", "sm (8px)"],
    "borderRadius": ["md (12px)"],
    "shadows": ["sm"]
  },
  "props": [
    {
      "name": "dashboardData",
      "type": "DashboardData",
      "required": true,
      "description": "Dashboard data entity"
    }
  ]
}
```

나머지 5개 컴포넌트도 동일하게 **designIntent** 포함하여 추가.

---

### Step 2: metadata.json 업데이트

status를 "completed"로 변경:

```json
{
  "project_name": "dashboard-emotional-ux",
  "status": "completed",
  "current_phase": "completed",
  ...
}
```

---

### Step 3: INDEX.md 업데이트

Pending → Completed 섹션으로 이동, 상태 업데이트.

---

### Step 4: 완료 요약 생성 (한글)

```markdown
# ✅ Dashboard Emotional UX 작업 완료

## 완료된 작업
✅ Phase 2A: 개선 방향 분석 및 제안
✅ Phase 2B: 구현 명세 작성
✅ Phase 2C: 코드 자동 구현
✅ Phase 3: 에셋 정리 및 문서화

## 적용된 UX 원칙
- **Noom 스타일**: CBT 기반 긍정적 재해석
- **Headspace 스타일**: 따뜻한 환영, 둥근 디자인
- **Duolingo 스타일**: 게이미피케이션, 축하 애니메이션
- **정상화**: "부작용" → "몸의 신호"

## 핵심 리프레이밍
| Before | After |
|--------|-------|
| 부작용 기록 | 몸의 신호 체크 |
| 다음 투여 | 다음 단계 |
| 순응도 72% | 목표의 70% 이상 달성! |
| 부작용 3회 | 3일을 잘 견뎌냈어요 |

## 생성된 컴포넌트
| 컴포넌트 | UX 의도 |
|---------|---------|
| EmotionalGreetingWidget | Headspace 스타일 따뜻한 환영 |
| EncouragingProgressWidget | 정상화 + Duolingo 축하 |
| HopefulScheduleWidget | Forest 스타일 성장 은유 |
| CelebratoryReportWidget | Duolingo 스타일 축하 언어 |
| JourneyTimelineWidget | 스토리텔링 + 마일스톤 강조 |
| CelebratoryBadgeWidget | 게이미피케이션 강화 |

**이 프로젝트의 모든 작업이 완료되었습니다.** ✅
```

작업을 시작하세요.
```

---

## 오케스트레이션 실행 예시

```javascript
// Step 1: 순차적 구현 (모두 opus)
Task(prompt: "[1.1 프롬프트]", subagent_type: "general-purpose", model: "opus")
Task(prompt: "[1.2 프롬프트]", subagent_type: "general-purpose", model: "opus")
Task(prompt: "[1.3 프롬프트]", subagent_type: "general-purpose", model: "opus")
Task(prompt: "[1.4 프롬프트]", subagent_type: "general-purpose", model: "opus")
Task(prompt: "[1.5 프롬프트]", subagent_type: "general-purpose", model: "opus")
Task(prompt: "[1.6 프롬프트]", subagent_type: "general-purpose", model: "opus")
Task(prompt: "[1.7 프롬프트]", subagent_type: "general-purpose", model: "opus")

// Step 2: 검증 (opus)
Task(prompt: "[검증 프롬프트]", subagent_type: "general-purpose", model: "opus")

// Step 3: 에셋 재활용 (opus)
Task(prompt: "[에셋 프롬프트]", subagent_type: "general-purpose", model: "opus")
```

---

## 컨텍스트 엔지니어링 핵심 원칙

1. **UX 철학 서두 배치**: 모든 에이전트가 "왜 이렇게 해야 하는가"를 먼저 이해
2. **베스트 프랙티스 참조**: Noom, Headspace, Duolingo 등 구체적 사례
3. **심리학적 근거**: 각 디자인 결정에 "왜?"에 대한 답
4. **금지어/금지색상 명시**: 기존 냉정한 표현 차단
5. **코드 예시 포함**: 함수명과 로직 힌트 제공
6. **검증 항목에 UX 의도 포함**: 기술적 검증 + 감정적 검증
