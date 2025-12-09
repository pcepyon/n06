# 게스트 체험 통합 시스템 구현 스펙

## 개요
게스트홈을 "교육 + 체험" 허브로 확장하고, 온보딩을 "개인화 설정"으로 축소하여 중복 제거 및 전환율 향상.

## 배경
- 현재 문제: 게스트홈(6섹션)과 온보딩(14스크린)에 교육 콘텐츠가 중복됨
- 기대 효과: 설명 직후 체험으로 전환율 향상, 온보딩 시간 단축(14→5스크린)

## 목표
- [ ] 게스트홈을 10섹션(교육 + 체험, 인덱스 0-9)으로 확장
- [ ] 온보딩을 5스크린(개인화 설정)으로 축소
- [ ] 각 교육 섹션에 실제 앱 UI 체험 기능 추가 (데이터 저장 없음, 순수 UI 체험)
- [ ] 온보딩을 게스트홈 스타일로 통일

## 사용자 시나리오

### 시나리오 1: 게스트 체험 플로우
1. 사용자가 게스트홈에서 "부작용 대처" 섹션 진입
2. 부작용 설명 카드 확인 후 "체험하기" 버튼 탭
3. 바텀시트에서 데일리 체크인 데모 UI 표시
4. "조금 불편했어요" 선택 → FeedbackCard로 안심 메시지 표시
5. 결과: 하단 배너의 "내 기록 시작하기" CTA로 전환 유도

### 시나리오 2: 체험 후 회원가입
1. 사용자가 여러 체험 완료 후 CTA 섹션 도달
2. 회원가입 → 로그인 → 온보딩 진입
3. 결과: 개인화 설정(5스크린)만 진행

### 시나리오 3: 체험 없이 바로 회원가입
1. 사용자가 게스트홈에서 바로 "시작하기" 탭
2. 결과: 동일하게 온보딩 5스크린 진행

## 구조 변경

### 게스트홈 섹션 (6 → 10섹션)
| 인덱스 | 섹션명 | 변경 | 체험 기능 |
|--------|--------|------|----------|
| 0 | 환영 | 유지 | - |
| 1 | 당신 탓 아니에요 | 신규 (온보딩에서 이동) | - |
| 2 | 과학적 근거 | 유지 | - |
| 3 | Food Noise | 신규 (온보딩에서 이동) | 슬라이더 인터랙션 |
| 4 | 작동 원리 | 신규 (온보딩에서 이동) | - |
| 5 | 치료 여정 | 유지 | 대시보드 미리보기 |
| 6 | 부작용 대처 | 강화 | 데일리 체크인 체험 |
| 7 | 앱 기능 | 유지 | 투여 캘린더, 트렌드 리포트 체험 |
| 8 | 주사 가이드 | 신규 (온보딩에서 이동) | 부위 선택 인터랙션 |
| 9 | CTA | 유지 | - |

### 온보딩 스크린 (14 → 5스크린)
| 인덱스 | 스크린명 | 변경 |
|--------|----------|------|
| 0 | 환영 | 신규 ("이제 내 여정을 시작해볼까요?") |
| 1 | 프로필 설정 | 유지 (기존 BasicProfileForm) |
| 2 | 체중 목표 | 유지 (기존 WeightGoalForm) |
| 3 | 투여 계획 | 유지 (기존 DosagePlanForm) |
| 4 | 요약 + 완료 | 통합 (SummaryScreen + Confetti + 완료 버튼) |

## 체험 위젯 구현 원칙

### 왜 데모 전용 위젯을 만드는가?

기존 화면(DailyCheckinScreen, DoseCalendarScreen 등)을 그대로 재사용할 수 없는 이유:

1. **Provider 의존성**: 기존 화면들은 build() 시점에 Provider를 통해 userId, repository 등을 주입받음
   - 게스트는 로그인하지 않았으므로 userId가 null → Exception 발생
   - 예: `DailyCheckinNotifier.startCheckin()`은 `authNotifierProvider.value?.id`가 null이면 throw

2. **데이터 저장 로직**: 기존 화면은 사용자 액션 시 실제 DB에 저장함
   - 체험에서는 어떤 데이터도 저장하면 안 됨
   - 예: `DailyCheckinNotifier.finishCheckin()`은 Supabase에 체크인 기록 저장

3. **복잡한 상태 관리**: 기존 Notifier는 파생 질문, Red Flag 감지 등 복잡한 로직 포함
   - 체험에서는 단순한 UI 인터랙션만 필요

### 위젯 분류 기준

```
[Screen/Notifier 레벨]     → 데모 전용 위젯 새로 생성 (Provider 의존성 있음)
[순수 UI 위젯 레벨]        → 그대로 재사용 (props만 받는 Stateless/Stateful)
```

#### 재사용 가능 (순수 UI 위젯)
Provider 의존성 없이 props만 받아서 렌더링하는 위젯:
- `QuestionCard` - 질문 텍스트와 이모지만 표시
- `AnswerButton` - 답변 옵션 버튼
- `FeedbackCard` - 피드백 메시지 표시
- `EmotionalGreetingWidget` - DashboardData props로 렌더링
- `CelebratoryReportWidget` - WeeklySummary props로 렌더링
- `TrendInsightCard` - TrendInsight props로 렌더링
- `WeeklyConditionChart` - questionTrends props로 렌더링

#### 새로 생성 필요 (Demo 전용)
Provider/Notifier를 사용하는 Screen 레벨 위젯:
- `DailyCheckinDemo` - DailyCheckinScreen 대체
- `DoseCalendarDemo` - DoseCalendarScreen 대체
- `DashboardPreviewDemo` - HomeDashboardScreen 대체 (래퍼)
- `TrendReportDemo` - TrendDashboardScreen 대체 (래퍼)
- `FoodNoiseDemo` - FoodNoiseScreen 대체

### 데모 위젯 구현 패턴

```dart
// ❌ 잘못된 방식: 기존 Screen 재사용 시도
DailyCheckinScreen() // → authNotifierProvider 접근 → userId null → 크래시

// ✅ 올바른 방식: 데모 전용 StatefulWidget
class DailyCheckinDemo extends StatefulWidget {
  final VoidCallback onComplete;

  @override
  State<DailyCheckinDemo> createState() => _DailyCheckinDemoState();
}

class _DailyCheckinDemoState extends State<DailyCheckinDemo> {
  int _currentStep = 0;           // 로컬 상태만 사용
  String? _selectedAnswer;
  String? _feedbackMessage;

  @override
  Widget build(BuildContext context) {
    // 기존 순수 UI 위젯 재사용
    return Column(
      children: [
        QuestionCard(...),        // ✅ 재사용
        AnswerButton(...),        // ✅ 재사용
        if (_feedbackMessage != null)
          FeedbackCard(...),      // ✅ 재사용
      ],
    );
  }
}
```

### 위젯별 구현 방식 요약

| 체험 기능 | 신규 생성 | 재사용 (순수 UI) | 재사용 이유 |
|----------|----------|-----------------|------------|
| 데일리 체크인 | `DailyCheckinDemo` | QuestionCard, AnswerButton, FeedbackCard | props만 받는 순수 UI |
| 대시보드 미리보기 | `DashboardPreviewDemo` | EmotionalGreetingWidget, CelebratoryReportWidget, HopefulScheduleWidget | DashboardData props로 동작 |
| 투여 캘린더 | `DoseCalendarDemo` | (TableCalendar 직접 사용) | 외부 패키지, Provider 무관 |
| 트렌드 리포트 | `TrendReportDemo` | TrendInsightCard, WeeklyConditionChart | TrendInsight props로 동작 |
| Food Noise | `FoodNoiseDemo` | (Slider 직접 사용) | Flutter 기본 위젯 |

### 더미 데이터 생성

데모 위젯은 하드코딩된 더미 데이터 사용:

```dart
// DashboardPreviewDemo 내부
final _demoData = DashboardData(
  weeklySummary: WeeklySummary(weekNumber: 4, totalCheckins: 7, ...),
  nextSchedule: NextSchedule(scheduledDate: DateTime.now().add(Duration(days: 2)), ...),
  ...
);

// DailyCheckinDemo 내부
final _demoQuestions = [
  (question: '오늘 식사는 어떠셨어요?', options: [...]),
  (question: '속은 편안하셨어요?', options: [...]),
];
```

### 체험 화면 진입/종료
- 진입: 섹션 내 "체험하기" 버튼 → 바텀시트(80% 높이)
- 종료: 드래그 다운 또는 X 버튼 → 원래 섹션 복귀
- 바텀시트 스타일: 기존 showModalBottomSheet 패턴 참조

### 전환 유도 배너
- 위치: 바텀시트 하단 고정
- 구성: 안내 문구 + "내 기록 시작하기" CTA 버튼
- 항상 표시 (닫기 불가)
- 기존 InfoBanner 컴포넌트 스타일 참조

## 신규 콘텐츠 출처

| 대상 | 콘텐츠 출처 | 처리 방식 |
|------|------------|----------|
| 당신 탓 아니에요 | `not_your_fault_screen.dart` | 텍스트 추출 → 게스트홈 섹션 패턴으로 재작성 |
| Food Noise | `food_noise_screen.dart` | 텍스트/슬라이더 → 게스트홈 섹션 + 체험 데모 |
| 작동 원리 | `how_it_works_screen.dart` | 텍스트 추출 → 게스트홈 섹션 패턴으로 재작성 |
| 주사 가이드 | `injection_guide_screen.dart` | 텍스트/이미지 → 게스트홈 섹션 + 부위 선택 데모 |

> UI는 게스트홈 섹션 패턴으로 새로 작성 (기존 온보딩 UI 그대로 복사 금지)
> 언어/톤: `docs/018-guest-home/spec.md`의 카피라이팅 원칙 참조

## 온보딩 변경사항

### 제거 대상
- 교육 스크린 7개 (PART 1-2 전체)
- `OnboardingPageTemplate` 사용 중단
- `JourneyProgressIndicator` 사용 중단
- `CommitmentScreen`의 Swipe to Confirm

### 유지 대상
- `BasicProfileForm`, `WeightGoalForm`, `DosagePlanForm`
- `SummaryScreen` (확장하여 완료 버튼 + Confetti 통합)

### 스타일 변경
- AppBar 제거
- `SectionProgressIndicator` 스타일 적용 (5개 도트)
- 페이지 전환: Scale + Fade 애니메이션 (기존 게스트홈 패턴 따름)

## 삭제 대상 파일

### education 폴더 (7개)
- `welcome_screen.dart`
- `not_your_fault_screen.dart`
- `evidence_screen.dart`
- `food_noise_screen.dart`
- `how_it_works_screen.dart`
- `journey_roadmap_screen.dart`
- `side_effects_screen.dart`

### preparation 폴더 (3개)
- `injection_guide_screen.dart`
- `app_features_screen.dart`
- `commitment_screen.dart`

### common 폴더 (2개)
- `onboarding_page_template.dart`
- `journey_progress_indicator.dart`

## 제약 조건
- 게스트홈 디자인 시스템(애니메이션, 인터랙션) 유지
- FeedbackCard 톤/색상 체계 준수 (positive/supportive/cautious)
- 바텀시트: 80% 높이, 둥근 모서리(16px)

## 참조 코드
> 에이전트는 아래 파일을 먼저 읽고 패턴을 따를 것

| 참조 대상 | 경로 | 참조 이유 |
|----------|------|----------|
| 게스트홈 스펙 | `docs/018-guest-home/spec.md` | 언어 프레이밍, 톤, 카피라이팅 |
| 게스트홈 화면 | `lib/features/guest_home/presentation/screens/guest_home_screen.dart` | 섹션 네비게이션, 페이지 전환 |
| 게스트홈 섹션 | `lib/features/guest_home/presentation/widgets/` | 섹션 레이아웃, 애니메이션 |
| 게스트홈 콘텐츠 | `lib/features/guest_home/data/guest_home_content.dart` | 정적 데이터 구조 |
| Progress Indicator | `lib/features/guest_home/presentation/widgets/section_progress_indicator.dart` | 도트 네비게이션 |
| 대시보드 위젯 | `lib/features/dashboard/presentation/widgets/` | 재사용 위젯 (데모용) |
| 체크인 UI 위젯 | `lib/features/daily_checkin/presentation/widgets/` | QuestionCard, FeedbackCard |
| 체크인 질문 | `lib/features/daily_checkin/presentation/constants/questions.dart` | 질문/답변/피드백 구조 |
| 트렌드 위젯 | `lib/features/tracking/presentation/widgets/` | 차트 위젯 (데모용) |
| 온보딩 폼 | `lib/features/onboarding/presentation/widgets/` | 재사용 폼 |
| 온보딩 화면 | `lib/features/onboarding/presentation/screens/onboarding_screen.dart` | 축소 대상 |

## 구현 순서

### Phase 1: 게스트홈 확장
1. 신규 섹션 4개 콘텐츠 작성 (기존 온보딩 텍스트 참조)
2. `GuestHomeSection` enum 확장 (5 → 9개, CTA 제외)
3. `guest_home_content.dart` 데이터 추가
4. 기존 섹션 인덱스 조정

### Phase 2: 체험 기능 추가
1. 데모 위젯 생성 (`lib/features/guest_home/presentation/widgets/demo/`)
2. 바텀시트 공통 컴포넌트 생성
3. 전환 유도 배너 생성
4. 각 섹션에 "체험하기" 버튼 연결

### Phase 3: 온보딩 축소
1. 교육 스크린 제거 (삭제 대상 파일 12개)
2. `OnboardingScreen` 5스크린으로 재구성
3. 게스트홈 스타일 적용 (Progress, 애니메이션)
4. `SummaryScreen`에 완료 버튼 + Confetti 통합

### Phase 4: 정리
1. 미사용 import 정리
2. i18n 키 정리 (불필요한 온보딩 키 제거)
3. 테스트 수정

## 엣지 케이스

| 케이스 | 처리 방식 |
|--------|----------|
| 체험 중 앱 종료 | 저장 데이터 없으므로 처리 불필요 |
| 기존 회원 로그아웃 후 게스트홈 | 게스트홈 정상 표시 |
| 온보딩 중간 앱 종료 | 기존 로직 유지 (currentStep 저장) |

## 구현 시 주의사항 (메인 오케스트레이션 → 범용 에이전트)

### 하드코딩된 값 수정 목록
Phase 1 완료 시 아래 값들을 **반드시 함께** 수정해야 함. 하나라도 누락 시 런타임 에러 발생:

| 파일 | 위치 | 현재 값 | 변경 값 | 설명 |
|------|------|--------|--------|------|
| `guest_home_screen.dart` | line 84 | `pageIndex > 5` | `pageIndex > 9` | 페이지 범위 체크 |
| `guest_home_screen.dart` | line 109 | `_currentPageIndex < 5` | `_currentPageIndex < 9` | 다음 버튼 조건 |
| `guest_home_screen.dart` | line 144 | `/ 5` | `/ 9` | 스크롤 진행률 계산 |
| `section_progress_indicator.dart` | enum 정의 | 5개 항목 | 9개 항목 | GuestHomeSection enum |
| `_buildCurrentPage()` 메서드 | switch 문 | case 0-5 | case 0-9 | 페이지별 위젯 매핑 |

### Phase 실행 순서 엄수
Phase 순서를 바꾸거나 건너뛰면 빌드 실패:

```
Phase 1 (확장) → Phase 2 (체험) → Phase 3 (축소) → Phase 4 (정리)
```

- Phase 1을 완료해야 새 섹션에 체험 버튼을 연결할 수 있음
- Phase 3에서 파일 삭제 전 반드시 import 정리 필요

### 파일 삭제 순서
삭제 대상 파일 12개를 제거할 때 **반드시 아래 순서** 준수:

1. **`OnboardingScreen` 수정**: 삭제 대상 파일 import 제거, 5스크린 구성으로 변경
2. **빌드 확인**: `flutter analyze && flutter build ios --no-codesign`
3. **삭제 대상 파일 제거**: education(7개), preparation(3개), common(2개)
4. **빌드 재확인**: `flutter analyze && flutter build ios --no-codesign`

> ⚠️ 순서 무시 시 "import not found" 에러로 빌드 실패

### Phase별 빌드 검증
각 Phase 완료 후 **반드시** 실행:

```bash
flutter analyze && flutter build ios --no-codesign
```

- Phase 1 후: 10섹션 네비게이션 동작 확인
- Phase 2 후: 체험 바텀시트 동작 확인
- Phase 3 후: 온보딩 5스크린 동작 확인, 삭제된 파일 import 에러 없음 확인
- Phase 4 후: 최종 빌드 성공 확인

### 범용 에이전트 호출 시 컨텍스트 전달
각 Phase를 담당하는 범용 에이전트에게 다음 정보 필수 전달:

1. **현재 Phase 번호**: 어느 단계를 구현하는지 명확히
2. **이전 Phase 완료 여부**: Phase 2 시작 전 Phase 1 완료 확인
3. **참조 파일 목록**: 해당 Phase에서 읽어야 할 파일
4. **수정 대상 파일 목록**: 해당 Phase에서 수정할 파일
5. **검증 명령어**: Phase 완료 후 실행할 테스트/빌드 명령

### 공통 실수 방지
| 실수 | 결과 | 방지책 |
|------|------|--------|
| enum 확장 후 switch 문 미수정 | 새 섹션 표시 안됨 | switch 문의 모든 case 확인 |
| 하드코딩된 5를 일부만 수정 | 마지막 섹션 접근 불가 | 위 표의 모든 위치 수정 |
| 파일 삭제 후 import 정리 | 빌드 실패 | 삭제 전 import 먼저 정리 |
| 데모 위젯에서 Provider 사용 | userId null 크래시 | StatefulWidget + 로컬 상태만 사용 |
| 기존 Screen 재사용 시도 | Provider 의존성 에러 | 데모 전용 위젯 새로 생성 |

## 성공 지표
- [ ] 게스트홈 10섹션(0-9) 정상 네비게이션
- [ ] 각 체험 화면이 바텀시트로 표시
- [ ] 체험에서 어떤 데이터도 저장되지 않음 확인
- [ ] 데일리 체크인 체험 시 FeedbackCard 정상 표시
- [ ] 온보딩 5스크린으로 축소 완료
- [ ] 온보딩이 게스트홈 스타일 적용 (Progress, 애니메이션)
- [ ] 삭제 대상 파일 12개 제거 완료
- [ ] 기존 테스트 통과
- [ ] 빌드 성공
