# 데모 모드 (Demo Mode) 스펙

## 개요

비로그인 사용자가 **실제 앱 UI를 더미 데이터로 체험**할 수 있는 모드.
기존 게스트홈의 "정보 전달" 역할을 "체험 유도"로 전환하여, 자연스러운 회원가입 전환을 유도한다.

**핵심 원칙**:
- 실제 앱과 **동일한 UI** 사용 (별도 UI 개발 X)
- **데모 표시 배너**로 체험 모드임을 명확히 인지
- 체험 중 자연스러운 **로그인 유도 시점** 설계
- 게스트홈과 온보딩의 **역할 분리** (게스트홈=체험, 온보딩=설정)

---

## 아키텍처 변경

### 기존 흐름
```
[비로그인] 게스트홈(정보) → 로그인 → 온보딩(교육 7단계 + 설정 4단계 + 준비 3단계)
```

### 새로운 흐름
```
[비로그인] 게스트홈(체험 + 간결한 정보) → 로그인 → 온보딩(설정 4단계 + 준비 2단계)
```

---

## 게스트홈 리디자인

### 새로운 섹션 구조

```
[게스트홈 - 체험 중심]
│
├── 1. Welcome (유지, 간결화)
│   └── 공감 + 희망 메시지
│   └── "12주 후 달라진 나를 만나보세요"
│
├── 2. 🆕 Demo Dashboard (핵심 - 실제 앱 체험)
│   ├── 홈 대시보드 체험 (F006)
│   ├── 체중 기록 체험 (F002)
│   ├── 데일리 체크인 체험 (불편 증상 → 대처 가이드)
│   └── 투여 스케줄 확인 (F001)
│
├── 3. Quick Evidence (간결화)
│   └── 핵심 숫자 3개만 (확장 가능)
│   └── 20% 체중 감량, 20% 심혈관 보호, 혈당 안정
│
├── 4. Journey Timeline (유지)
│   └── 12주 여정 미리보기
│
└── 5. 🆕 Natural CTA
    └── "내 데이터로 시작하기"
    └── 체험 중 자연스러운 로그인 유도
```

### 삭제/이동되는 섹션

| 기존 섹션 | 조치 | 이유 |
|----------|------|------|
| Scientific Evidence (상세) | 간결화 → Quick Evidence | 체험으로 가치 전달 |
| App Features Section | 삭제 | 데모에서 직접 체험 |
| Side Effects Guide | 삭제 | 데일리 체크인에서 체험 |
| 상세 CTA Section | 간결화 | 체험 후 자연스러운 전환 |

---

## 데모 모드 상세 설계

### 1. 데모 표시 배너

```
┌─────────────────────────────────────────┐
│ 🎮 체험 모드                        [X] │
│ 실제 기록은 로그인 후 저장돼요           │
└─────────────────────────────────────────┘
```

**동작**:
- 최초 표시: 데모 진입 시 상단에 고정
- 닫기 가능: [X] 탭 시 축소 (완전 삭제 X, 작은 아이콘으로 유지)
- 재표시: 데모 내 다른 화면 이동 시 다시 노출

**스타일**:
- 배경: `AppColors.infoBackground` (파란색 계열)
- 아이콘: 🎮 또는 Material icon `sports_esports`
- 텍스트: `AppTypography.labelMedium`
- 높이: 48px (SafeArea 포함)

### 2. 더미 데이터 설계

```dart
/// 데모용 더미 사용자 프로필
class DemoUserProfile {
  static const String name = '체험자';
  static const double currentWeight = 75.0;
  static const double targetWeight = 65.0;
  static const int treatmentWeek = 3;
  static const DateTime startDate = /* 3주 전 */;
}

/// 데모용 더미 체중 기록 (최근 3주)
class DemoWeightLogs {
  static final List<WeightLog> logs = [
    WeightLog(date: day(-21), weight: 78.0),
    WeightLog(date: day(-14), weight: 76.5),
    WeightLog(date: day(-7), weight: 75.2),
    WeightLog(date: day(0), weight: 75.0),
  ];
}

/// 데모용 더미 투여 스케줄
class DemoDoseSchedule {
  static const String medicationName = '위고비';
  static const double currentDose = 0.5; // mg
  static const DateTime nextDoseDate = /* 다음 주 월요일 */;
  static const DateTime nextEscalationDate = /* 1주 후 */;
}

/// 데모용 더미 데일리 체크인
class DemoDailyCheckin {
  static const int energyLevel = 3; // 1-5
  static const int appetiteLevel = 2; // 1-5
  static const List<String> symptoms = ['메스꺼움', '피로감'];
}
```

### 3. 데모 대시보드 체험

#### 3-1. 홈 대시보드 (F006 재사용)

```
┌─────────────────────────────────────────┐
│ 🎮 체험 모드                        [X] │
├─────────────────────────────────────────┤
│                                         │
│  체험자님, 3주차 진행 중                  │
│  목표까지 10kg 남았어요                  │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ 주간 목표 진행도                  │   │
│  │ ████████░░░░ 67%                 │   │
│  │                                  │   │
│  │ ✓ 투여 완료 1/1                   │   │
│  │ ◐ 체중 기록 5/7                   │   │
│  │ ○ 컨디션 체크 3/7                 │   │
│  └─────────────────────────────────┘   │
│                                         │
│  [체중 기록하기] [오늘 컨디션 체크]       │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ 📊 체중 변화                      │   │
│  │  78 ─┐                          │   │
│  │  77  │    ╲                     │   │
│  │  76  │      ╲                   │   │
│  │  75  └────────╲───── 목표 65    │   │
│  │      1주  2주  3주               │   │
│  │                                  │   │
│  │  지난 3주간 -3kg 감소 🎉          │   │
│  └─────────────────────────────────┘   │
│                                         │
│  다음 투여: 12월 9일 (월) · 0.5mg        │
│                                         │
└─────────────────────────────────────────┘
```

**구현 방식**:
```dart
// 기존 HomeDashboard 위젯 재사용
// isDemoMode 플래그로 데이터 소스 분기

class HomeDashboard extends ConsumerWidget {
  final bool isDemoMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 데모 모드면 demoUserProvider 사용
    final profile = isDemoMode
        ? ref.watch(demoUserProfileProvider)
        : ref.watch(userProfileProvider);

    final weightLogs = isDemoMode
        ? ref.watch(demoWeightLogsProvider)
        : ref.watch(weightLogsProvider);

    // ... 동일한 UI 렌더링
  }
}
```

#### 3-2. 체중 기록 체험 (F002 재사용)

```
┌─────────────────────────────────────────┐
│ 🎮 체험 모드                        [X] │
├─────────────────────────────────────────┤
│                                         │
│  오늘 체중을 기록해볼까요?               │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │                                  │   │
│  │          74.8 kg                 │   │
│  │      ▲ 숫자 입력 휠 ▼            │   │
│  │                                  │   │
│  └─────────────────────────────────┘   │
│                                         │
│  지난 기록: 75.0kg (3일 전)              │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │      [기록 완료하기]              │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  💡 로그인하면 이 기록이 저장되고,        │
│     변화 추이를 계속 확인할 수 있어요.    │
│                                         │
│         [내 데이터로 시작하기 →]         │
│                                         │
└─────────────────────────────────────────┘
```

**체험 동작**:
1. 실제 체중 입력 UI 조작 가능
2. "기록 완료하기" 탭 → 로컬 세션에 임시 저장 (앱 종료 시 삭제)
3. 저장 성공 피드백 + 로그인 유도 메시지
4. 3회 이상 기록 시 더 강한 로그인 유도

#### 3-3. 데일리 체크인 체험 (불편 증상 → 즉각 대처 가이드)

```
[1단계: 컨디션 체크]
┌─────────────────────────────────────────┐
│ 🎮 체험 모드                        [X] │
├─────────────────────────────────────────┤
│                                         │
│  오늘 컨디션은 어떠세요?                 │
│                                         │
│  에너지 레벨                             │
│  😫  😕  😐  🙂  😊                      │
│        ◉                                │
│                                         │
│  식욕                                    │
│  거의 없음 ─────●───── 왕성함            │
│                                         │
│  불편한 증상이 있나요?                   │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐      │
│  │메스꺼움│ │변비  │ │피로감│ │없음  │      │
│  │  ✓   │ │     │ │  ✓  │ │     │      │
│  └─────┘ └─────┘ └─────┘ └─────┘      │
│                                         │
│         [체크인 완료]                    │
│                                         │
└─────────────────────────────────────────┘

[2단계: 즉각 대처 가이드 - 자동 표시]
┌─────────────────────────────────────────┐
│                                         │
│  😣 메스꺼움이 있으시군요                 │
│                                         │
│  걱정 마세요, 가장 흔한 적응 반응이에요.   │
│  보통 1~2주면 나아져요.                  │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  💡 지금 바로 해볼 수 있어요             │
│                                         │
│  ✓ 소량씩 천천히 식사하기                │
│  ✓ 기름진 음식 피하기                    │
│  ✓ 식후 바로 눕지 않기                   │
│  ✓ 생강차나 페퍼민트차 마시기            │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  😴 피로감도 느끼고 계시네요              │
│                                         │
│  칼로리 섭취가 줄면서 처음엔 피곤할 수    │
│  있어요. 몸이 적응하면 괜찮아져요.        │
│                                         │
│  💡 이렇게 해보세요                      │
│  ✓ 충분히 주무세요 (7-8시간)             │
│  ✓ 단백질은 꼭 챙기세요                  │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  💚 로그인하면 컨디션 패턴을 분석해서      │
│     맞춤 인사이트를 알려드려요.           │
│                                         │
│         [내 데이터로 시작하기 →]         │
│                                         │
└─────────────────────────────────────────┘
```

**핵심 차별점**:
- 기존: 별도 "부작용 가이드" 섹션에서 정보 전달
- 새로운: 데일리 체크인에서 **불편 증상 선택 시 즉각적으로 대처 가이드 표시**

#### 3-4. 투여 스케줄 확인 (F001 재사용)

```
┌─────────────────────────────────────────┐
│ 🎮 체험 모드                        [X] │
├─────────────────────────────────────────┤
│                                         │
│  다음 투여 예정                          │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │                                  │   │
│  │   12월 9일 (월)                  │   │
│  │   0.5mg · 위고비                 │   │
│  │                                  │   │
│  │   D-3                            │   │
│  │                                  │   │
│  └─────────────────────────────────┘   │
│                                         │
│  용량 증량 예정: 12월 23일 → 1.0mg       │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  📅 이번 달 스케줄                       │
│                                         │
│  일 월 화 수 목 금 토                    │
│           1  2  3  4  5                 │
│   ●                     ← 투여 완료      │
│   6  7  8  ◉ 10 11 12                   │
│            ↑ 다음 투여                   │
│  13 14 15 16 17 18 19                   │
│            ○             ← 예정          │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  💡 로그인하면 내 실제 스케줄로           │
│     알림을 받을 수 있어요.               │
│                                         │
│         [내 스케줄로 시작하기 →]         │
│                                         │
└─────────────────────────────────────────┘
```

---

## 자연스러운 로그인 유도 전략

### 유도 시점 및 메시지

| 시점 | 조건 | 메시지 | 강도 |
|------|------|--------|------|
| 체중 기록 1회 | 첫 기록 완료 | "기록이 저장됐어요! 로그인하면 계속 추적돼요" | 약함 |
| 체중 기록 3회 | 누적 3회 | "기록이 쌓이고 있어요! 로그인해서 저장하세요" | 중간 |
| 데일리 체크인 | 증상 선택 후 | "컨디션 패턴을 분석해드릴게요. 로그인하면 계속 추적돼요" | 중간 |
| 스케줄 확인 | 캘린더 탭 | "내 실제 스케줄로 알림 받기" | 약함 |
| 체험 5분 경과 | 시간 기반 | 하단 스낵바: "체험이 마음에 드셨나요?" | 약함 |
| 앱 종료 시도 | 백 버튼 | "체험 기록은 로그인하면 저장돼요" | 중간 |

### 유도 UI 패턴

#### 패턴 1: 인라인 유도 (약함)
```
💡 로그인하면 이 기록이 저장되고,
   변화 추이를 계속 확인할 수 있어요.

      [내 데이터로 시작하기 →]
```

#### 패턴 2: 하단 스낵바 (중간)
```
┌─────────────────────────────────────────┐
│ 🎮 체험 기록을 저장하시겠어요?           │
│                          [로그인] [나중에]│
└─────────────────────────────────────────┘
```

#### 패턴 3: 바텀시트 (강함 - 종료 시)
```
┌─────────────────────────────────────────┐
│                                         │
│         잠깐, 체험 기록이 있어요!         │
│                                         │
│  체중 기록 3건, 컨디션 체크 2건이         │
│  저장되지 않았어요.                      │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │    로그인하고 기록 저장하기        │   │
│  └─────────────────────────────────┘   │
│                                         │
│           [나중에 할게요]                │
│                                         │
└─────────────────────────────────────────┘
```

---

## 온보딩 간소화

### 기존 14단계 → 새로운 6단계

#### 기존 구조 (14단계)
```
PART 1: 공감과 희망 (1-3)
  [1] Welcome
  [2] Not Your Fault
  [3] Evidence

PART 2: 이해와 확신 (4-7)
  [4] Food Noise
  [5] How It Works
  [6] Journey Roadmap
  [7] Side Effects

PART 3: 설정 (8-11)
  [8] Basic Profile
  [9] Weight Goal
  [10] Dosage Plan
  [11] Summary

PART 4: 준비와 시작 (12-14)
  [12] Injection Guide
  [13] App Features
  [14] Commitment
```

#### 새로운 구조 (6단계)
```
PART 1: 빠른 환영 (1)
  [1] Welcome Back
      - 간단한 환영 메시지
      - "체험에서 봤던 것, 이제 진짜로"
      - 체험 데이터 이관 안내 (있을 경우)

PART 2: 설정 (2-4)
  [2] Basic Profile (이름)
  [3] Weight Goal (현재/목표 체중)
  [4] Dosage Plan (약물, 투여 계획)

PART 3: 확인 및 시작 (5-6)
  [5] Summary + Commitment (요약 + 약속)
  [6] Ready to Go
      - 주사 가이드 링크
      - 앱 사용 팁 요약
      - "시작하기" 버튼
```

### 삭제되는 교육 콘텐츠

| 기존 화면 | 삭제 이유 | 대체 |
|----------|----------|------|
| Not Your Fault | 게스트홈 Welcome에서 공감 전달 | - |
| Evidence | 게스트홈 Quick Evidence | - |
| Food Noise | 데모 체험으로 대체 | - |
| How It Works | 데모 체험으로 대체 | - |
| Journey Roadmap | 게스트홈 Journey Timeline | - |
| Side Effects | 데일리 체크인 체험으로 대체 | - |
| Injection Guide | Ready to Go에서 링크 제공 | 링크 |
| App Features | 데모 체험으로 대체 | - |

### 체험 데이터 이관

데모 모드에서 기록한 데이터를 실제 계정으로 이관:

```dart
// 온보딩 시작 시 체험 데이터 확인
final demoData = ref.read(demoSessionProvider);

if (demoData.hasRecords) {
  // Welcome Back 화면에서 안내
  """
  체험에서 기록한 데이터가 있어요!

  • 체중 기록 3건
  • 컨디션 체크 2건

  온보딩을 완료하면 이 기록들이
  당신의 계정에 저장돼요.
  """
}

// Summary 단계에서 이관 실행
await onboardingNotifier.migrateFromDemo(
  demoWeightLogs: demoData.weightLogs,
  demoCheckins: demoData.checkins,
);
```

---

## 게스트홈 콘텐츠 업데이트

### Quick Evidence 섹션 (간결화)

기존 5개 카드 캐러셀 → 3개 핵심 수치 + 확장 옵션

```
┌─────────────────────────────────────────┐
│                                         │
│  이미 증명된 효과                         │
│                                         │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐   │
│  │  ⚖️    │ │  ❤️    │ │  🩸    │   │
│  │         │ │         │ │         │   │
│  │ 20-22% │ │   20%   │ │ 97%    │   │
│  │체중 감소│ │심혈관   │ │혈당 목표│   │
│  │         │ │위험 감소│ │   달성  │   │
│  └─────────┘ └─────────┘ └─────────┘   │
│                                         │
│  2023 Science지 "올해의 과학적 돌파구"    │
│                                         │
│          [더 자세히 보기 ▼]              │
│                                         │
└─────────────────────────────────────────┘

[확장 시 - 기존 상세 카드 표시]
```

### Journey Timeline 섹션 (유지)

기존 `JourneyPreviewSection` 그대로 유지.
인터랙션(Progressive Disclosure) 동일.

### Natural CTA (새로운)

```
┌─────────────────────────────────────────┐
│                                         │
│  12주 후, 달라진 나를 만나보세요           │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │                                  │   │
│  │       내 데이터로 시작하기         │   │
│  │                                  │   │
│  └─────────────────────────────────┘   │
│                                         │
│           [데모 계속 체험하기]           │
│                                         │
│  💚 여기까지 읽은 당신,                   │
│     이미 한 걸음 내딛었어요.              │
│                                         │
└─────────────────────────────────────────┘
```

---

## 화면 흐름

### 게스트 → 로그인 → 홈 전체 흐름

```
[앱 실행 - 비로그인]
        │
        ▼
┌─────────────────┐
│   게스트홈       │
│  (체험 중심)     │
└────────┬────────┘
         │
         ├───────────────┐
         │               │
         ▼               ▼
┌─────────────┐  ┌─────────────┐
│ 데모 진입    │  │ 로그인 버튼  │
│ (체험하기)   │  │ (바로 시작)  │
└──────┬──────┘  └──────┬──────┘
       │                │
       ▼                │
┌─────────────────┐     │
│   데모 모드      │     │
│                 │     │
│ • 홈 대시보드    │     │
│ • 체중 기록     │     │
│ • 데일리 체크인  │     │
│ • 투여 스케줄   │     │
│                 │     │
│ [로그인 유도]   │     │
└────────┬────────┘     │
         │              │
         └──────┬───────┘
                │
                ▼
        ┌─────────────┐
        │   로그인     │
        │ (소셜/이메일) │
        └──────┬──────┘
               │
               ▼
        ┌─────────────┐
        │  온보딩 6단계 │
        │             │
        │ [1] Welcome  │
        │ [2] Profile  │
        │ [3] Weight   │
        │ [4] Dosage   │
        │ [5] Summary  │
        │ [6] Ready    │
        └──────┬──────┘
               │
               ▼
        ┌─────────────┐
        │  홈 대시보드  │
        │  (실제 데이터)│
        └─────────────┘
```

---

## 데이터 요구사항

### Provider 구조

```dart
// 데모 모드 상태 관리
@riverpod
class DemoSession extends _$DemoSession {
  @override
  DemoSessionState build() => DemoSessionState.initial();

  // 체중 기록 추가 (로컬 임시 저장)
  void addWeightLog(double weight) { ... }

  // 데일리 체크인 추가 (로컬 임시 저장)
  void addCheckin(DailyCheckin checkin) { ... }

  // 세션 초기화
  void reset() { ... }
}

// 데모 프로필 (정적 더미 데이터)
@riverpod
DemoUserProfile demoUserProfile(Ref ref) {
  return DemoUserProfile.sample();
}

// 데모 체중 기록 (정적 + 사용자 입력)
@riverpod
List<WeightLog> demoWeightLogs(Ref ref) {
  final session = ref.watch(demoSessionProvider);
  return [
    ...DemoWeightLogs.sample,
    ...session.userWeightLogs,
  ];
}
```

### 데모 세션 상태

```dart
@freezed
class DemoSessionState with _$DemoSessionState {
  const factory DemoSessionState({
    required List<WeightLog> userWeightLogs,
    required List<DailyCheckin> userCheckins,
    required int interactionCount,
    required DateTime? sessionStartTime,
    required bool hasDismissedBanner,
  }) = _DemoSessionState;

  factory DemoSessionState.initial() => DemoSessionState(
    userWeightLogs: [],
    userCheckins: [],
    interactionCount: 0,
    sessionStartTime: null,
    hasDismissedBanner: false,
  );
}
```

---

## 파일 구조

```
lib/features/
├── guest_home/
│   ├── presentation/
│   │   ├── screens/
│   │   │   └── guest_home_screen.dart  # 리디자인
│   │   └── widgets/
│   │       ├── welcome_section.dart     # 간결화
│   │       ├── demo_entry_section.dart  # 🆕 데모 진입점
│   │       ├── quick_evidence_section.dart  # 🆕 간결화된 증거
│   │       ├── journey_preview_section.dart  # 유지
│   │       └── natural_cta_section.dart  # 🆕 자연스러운 CTA
│   └── data/
│       └── guest_home_content.dart  # 콘텐츠 업데이트
│
├── demo/  # 🆕 새 feature
│   ├── presentation/
│   │   ├── screens/
│   │   │   └── demo_dashboard_screen.dart
│   │   └── widgets/
│   │       ├── demo_mode_banner.dart
│   │       ├── demo_weight_record.dart
│   │       ├── demo_daily_checkin.dart
│   │       ├── demo_schedule_view.dart
│   │       └── login_prompt_widgets.dart
│   ├── application/
│   │   └── notifiers/
│   │       └── demo_session_notifier.dart
│   ├── domain/
│   │   └── entities/
│   │       ├── demo_session_state.dart
│   │       └── demo_user_profile.dart
│   └── data/
│       └── demo_sample_data.dart  # 더미 데이터
│
└── onboarding/
    └── presentation/
        └── screens/
            └── onboarding_screen.dart  # 14단계 → 6단계
```

---

## 라우팅

```dart
// app_router.dart 업데이트

GoRoute(
  path: '/guest',
  builder: (context, state) => const GuestHomeScreen(),
  routes: [
    // 데모 모드 라우트
    GoRoute(
      path: 'demo',
      builder: (context, state) => const DemoDashboardScreen(),
      routes: [
        GoRoute(
          path: 'weight',
          builder: (context, state) => const DemoWeightRecordScreen(),
        ),
        GoRoute(
          path: 'checkin',
          builder: (context, state) => const DemoDailyCheckinScreen(),
        ),
        GoRoute(
          path: 'schedule',
          builder: (context, state) => const DemoScheduleScreen(),
        ),
      ],
    ),
  ],
),
```

---

## 톤 & 인터랙션 통일

### 카피라이팅 원칙 (게스트홈에서 온보딩으로)

| 원칙 | 게스트홈 예시 | 온보딩 적용 |
|------|-------------|------------|
| 사용자 중심 | "당신이 ~할 수 있어요" | "이제 당신의 정보를 입력해볼까요?" |
| 혜택 중심 | "12주 후 달라진 나를" | "입력하면 맞춤 스케줄을 만들어드려요" |
| 공감 → 희망 | "다이어트, 이번엔 다를 수 있어요" | "여기까지 온 당신, 이미 시작했어요" |

### 인터랙션 원칙

| 요소 | 게스트홈 | 온보딩 적용 |
|------|---------|------------|
| Progress Bar | 섹션 네비게이션 | 단계 진행 표시 |
| 확장 카드 | Journey Timeline | (필요시 적용) |
| 순차 애니메이션 | Welcome 텍스트 | Welcome Back에 적용 |
| Haptic | 주요 액션 시 | 단계 완료 시 |

---

## 구현 우선순위

### Phase 1: 데모 모드 기반 구축
1. `demo` feature 폴더 구조 생성
2. `DemoSessionNotifier` 구현
3. `DemoSampleData` 정의
4. `DemoModeBanner` 위젯

### Phase 2: 데모 화면 구현
5. `DemoDashboardScreen` (F006 재사용)
6. `DemoWeightRecordScreen` (F002 재사용)
7. `DemoDailyCheckinScreen` (즉각 대처 가이드 포함)
8. `DemoScheduleScreen` (F001 재사용)

### Phase 3: 게스트홈 리디자인
9. `DemoEntrySection` 추가
10. `QuickEvidenceSection` (간결화)
11. `NaturalCtaSection` 추가
12. 기존 섹션 정리 (삭제/수정)

### Phase 4: 온보딩 간소화
13. 14단계 → 6단계 구조 변경
14. `WelcomeBackScreen` (체험 데이터 이관 안내)
15. `ReadyToGoScreen` 추가
16. 기존 교육 화면 삭제

### Phase 5: 연결 및 테스트
17. 라우팅 업데이트
18. 로그인 유도 로직 구현
19. 체험 데이터 → 실제 계정 이관 구현
20. E2E 테스트

---

## 테스트 케이스

### Unit Tests
- 데모 세션 상태 관리
- 더미 데이터 생성
- 로그인 유도 조건 판단

### Widget Tests
- 데모 모드 배너 표시/숨김
- 체중 기록 UI 동작
- 데일리 체크인 → 대처 가이드 연결
- 로그인 유도 UI 표시

### Integration Tests
- 게스트홈 → 데모 → 로그인 → 온보딩 전체 플로우
- 체험 데이터 이관
- 온보딩 6단계 완료

---

## 성공 지표

| 지표 | 현재 (예상) | 목표 |
|------|------------|------|
| 게스트홈 → 로그인 전환율 | 15% | 30%+ |
| 온보딩 완료율 | 60% | 85%+ |
| 온보딩 소요 시간 | 8분 | 3분 |
| 데모 체험 참여율 | 0% | 50%+ |
| 체험 후 로그인 전환율 | - | 40%+ |
