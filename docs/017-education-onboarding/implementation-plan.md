# 교육 온보딩 구현 계획

## 개요

14스크린 인터랙티브 교육 온보딩 플로우 신규 구현

**접근 방식**: ui-renewal 디자인 시스템 + 기존 컴포넌트 활용, Phase 3 에셋 등록만 수행

---

## 구현 전략

```
Phase 1: 기반 구조 (직접 구현) ← Task 호출 전 필수 완료
   │
   ├── 1.1 의존성 설치
   ├── 1.2 OnboardingScreen 14스크린 확장 + 상태 추가
   ├── 1.3 JourneyProgressIndicator 생성
   ├── 1.4 OnboardingPageTemplate 생성
   └── 1.5 Lottie placeholder 에셋 준비
   │
   ▼ [Phase 1 완료 확인 후]
   │
Phase 2-4: Task로 스크린 그룹별 병렬 구현
   │  ├── Phase 1에서 생성한 위젯 코드 포함
   │  ├── 기존 컴포넌트 실제 인터페이스 포함
   │  └── 라이브러리 사용법 (웹 검색)
   │
Phase 5: 통합 + 에셋 등록 (직접 구현)
   └── registry.json에 새 컴포넌트 추가
```

---

## Phase 1: 기반 구조 (직접) - Task 호출 전 필수

### 1.1 의존성 설치

```bash
flutter pub add lottie confetti animated_flip_counter slide_to_confirm smooth_page_indicator url_launcher shared_preferences
```

---

## 라이브러리 버전 및 문서 참조 규칙

### ⚠️ 최신 버전 사용 필수

> **절대 규칙**: 모든 라이브러리는 **pub.dev 최신 stable 버전** 사용
>
> - `flutter pub add {패키지명}` 실행 시 자동으로 최신 버전 설치됨
> - 예제 코드 작성 시 **반드시 해당 버전의 pub.dev 문서** 참조
> - 블로그, StackOverflow 등 외부 소스의 오래된 코드 복사 금지

### Task Agent 필수 지침

```
🚨 라이브러리 구현 시 반드시 다음 순서를 따를 것:

1. pub.dev에서 해당 패키지의 **최신 버전** 페이지 열기
2. **"Example"** 탭에서 공식 예제 코드 확인
3. **"Readme"** 탭에서 API 사용법 확인
4. **"Changelog"** 탭에서 최근 breaking changes 확인
5. 위 문서 기준으로만 코드 작성

❌ 금지 사항:
- 2023년 이전 블로그/튜토리얼 코드 복사
- StackOverflow 답변 그대로 사용
- deprecated API 사용 (컴파일 경고 발생 시 즉시 수정)
```

### 버전 확인 방법
```bash
# 설치 후 pubspec.lock에서 실제 버전 확인
grep -A1 "lottie:\|confetti:\|animated_flip_counter:\|slide_to_confirm:\|smooth_page_indicator:" pubspec.lock
```

### Task 프롬프트에 포함할 라이브러리 정보

```markdown
## 라이브러리 (최신 버전 사용)

| 패키지 | pub.dev | 용도 |
|--------|---------|------|
| lottie | https://pub.dev/packages/lottie | 애니메이션 |
| confetti | https://pub.dev/packages/confetti | 축하 효과 |
| animated_flip_counter | https://pub.dev/packages/animated_flip_counter | 숫자 카운터 |
| slide_to_confirm | https://pub.dev/packages/slide_to_confirm | 스와이프 확인 |
| smooth_page_indicator | https://pub.dev/packages/smooth_page_indicator | 페이지 인디케이터 |
| url_launcher | https://pub.dev/packages/url_launcher | 외부 링크 |

🚨 **필수**: 각 링크의 Example 탭에서 최신 사용법 확인 후 구현
🚨 **금지**: 오래된 블로그/튜토리얼 코드 복사
```

### 문서 참조 우선순위
1. **pub.dev Example 탭** ← 최우선 (공식, 최신)
2. **pub.dev Readme 탭** ← 상세 문서
3. **pub.dev Changelog 탭** ← breaking changes 확인
4. **GitHub Repository** ← pub.dev에 없는 경우만

---

## Task 실행 전 필수 참조 문서

> **중요**: 각 Task 프롬프트 작성 시 아래 문서를 **직접 Read하여 내용 포함**

### 프로젝트 문서 (docs/017-education-onboarding/)

| 문서 | 용도 | Task에 포함할 내용 |
|------|------|-------------------|
| **spec.md** | 전체 스펙 | 해당 스크린의 인터랙션, 데이터 저장, UI 요구사항 |
| **content.md** | 텍스트 콘텐츠 | 해당 스크린의 **정확한 텍스트** (타이틀, 본문, 버튼 등) |
| **plan.md** | 구현 계획 | 해당 스크린의 구조, 위젯 트리, 상태 관리 |

### Task별 참조 섹션

```
Task A (PART 1: 스크린 1-3)
├── spec.md: "PART 1: 공감과 희망" 섹션
├── content.md: [1] 환영, [2] 당신 탓 아니에요, [3] 변화의 증거들
└── plan.md: Task 2 섹션

Task B (PART 2: 스크린 4-7)
├── spec.md: "PART 2: 이해와 확신" 섹션
├── content.md: [4] Food Noise, [5] 작동 원리, [6] 여정 로드맵, [7] 적응과 대처
└── plan.md: Task 3 섹션

Task C (PART 4: 스크린 12-14)
├── spec.md: "PART 4: 준비와 시작" 섹션
├── content.md: [12] 주사 가이드, [13] 앱 사용법, [14] 약속과 시작
└── plan.md: Task 5 섹션

Task D (PART 3 수정: 스크린 8-11)
├── spec.md: "PART 3: 설정" 섹션
├── content.md: [8] 프로필, [9] 체중 목표, [11] 요약 확인
└── 기존 코드: basic_profile_form.dart, weight_goal_form.dart, summary_screen.dart
```

### Task 프롬프트 작성 시 필수 포함

```markdown
## 참조 문서 내용

### spec.md에서 발췌 (해당 스크린)
{spec.md의 해당 PART 섹션 전체 복사}

### content.md에서 발췌 (해당 스크린)
{content.md의 해당 스크린 텍스트 전체 복사}
```

---

### 1.2 OnboardingScreen 확장

**파일**: `lib/features/onboarding/presentation/screens/onboarding_screen.dart`

**변경 사항**:
1. 4스크린 → 14스크린 PageView 확장
2. Part 구분 enum 추가
3. **새 상태 변수 추가**: `_initialFoodNoiseLevel`

```dart
// 추가할 상태
int? _initialFoodNoiseLevel; // [4] Food Noise에서 입력

// Part 구분
enum OnboardingPart {
  empathy,      // 1-3
  understanding, // 4-7
  setup,        // 8-11
  preparation   // 12-14
}

// 스킵 로직
bool _canSkipEducation = false; // SharedPreferences에서 로드
```

**기존 구조 유지**:
- `_name`, `_currentWeight`, `_targetWeight` 등 기존 상태 유지
- `OnboardingNotifier.saveOnboardingData()` 호출 방식 유지
- 마지막 스크린(14)에서 기존 SummaryScreen 로직 재사용

### 1.3 JourneyProgressIndicator 생성

**파일**: `lib/features/onboarding/presentation/widgets/common/journey_progress_indicator.dart`

```dart
import 'package:flutter/material.dart';

class JourneyProgressIndicator extends StatelessWidget {
  final int currentStep; // 0-13
  final int totalSteps;  // 14

  const JourneyProgressIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 14,
  });

  // Part 계산: 0-2 → empathy, 3-6 → understanding, 7-10 → setup, 11-13 → preparation
  int get _currentPart {
    if (currentStep <= 2) return 0;
    if (currentStep <= 6) return 1;
    if (currentStep <= 10) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    final parts = ['공감', '이해', '설정', '준비'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        children: [
          // Part 라벨
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) {
              final isActive = index <= _currentPart;
              final isCurrent = index == _currentPart;
              return Text(
                parts[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                    ? const Color(0xFF4ADE80)  // Primary
                    : const Color(0xFF94A3B8), // Neutral-400
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          // Progress dots with lines
          Row(
            children: List.generate(7, (index) {
              if (index.isOdd) {
                // Line
                final partIndex = index ~/ 2;
                final isCompleted = partIndex < _currentPart;
                return Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted
                      ? const Color(0xFF4ADE80)
                      : const Color(0xFFE2E8F0),
                  ),
                );
              } else {
                // Dot
                final partIndex = index ~/ 2;
                final isActive = partIndex <= _currentPart;
                return Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                      ? const Color(0xFF4ADE80)
                      : const Color(0xFFE2E8F0),
                  ),
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}
```

### 1.4 OnboardingPageTemplate 생성

**파일**: `lib/features/onboarding/presentation/widgets/common/onboarding_page_template.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';

class OnboardingPageTemplate extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget content;
  final Widget? bottomWidget;
  final VoidCallback? onNext;
  final String nextButtonText;
  final bool isNextEnabled;
  final bool showSkip;
  final VoidCallback? onSkip;

  const OnboardingPageTemplate({
    super.key,
    this.title,
    this.subtitle,
    required this.content,
    this.bottomWidget,
    this.onNext,
    this.nextButtonText = '다음',
    this.isNextEnabled = true,
    this.showSkip = false,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32), // xl
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Skip button (우상단)
            if (showSkip)
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onSkip?.call();
                  },
                  child: const Text(
                    '건너뛰기',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B), // Neutral-500
                    ),
                  ),
                ),
              ),

            // Title
            if (title != null) ...[
              const SizedBox(height: 16),
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 28, // 3xl
                  fontWeight: FontWeight.w700, // Bold
                  color: Color(0xFF1E293B), // Neutral-800
                  height: 1.29, // 36/28
                ),
              ),
            ],

            // Subtitle
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 16, // base
                  fontWeight: FontWeight.w400, // Regular
                  color: Color(0xFF64748B), // Neutral-500
                  height: 1.5,
                ),
              ),
            ],

            const SizedBox(height: 24), // lg

            // Content (scrollable)
            Expanded(
              child: SingleChildScrollView(
                child: content,
              ),
            ),

            // Bottom section
            if (bottomWidget != null) ...[
              bottomWidget!,
              const SizedBox(height: 16),
            ],

            // Next button
            if (onNext != null) ...[
              GabiumButton(
                text: nextButtonText,
                onPressed: isNextEnabled
                  ? () {
                      HapticFeedback.lightImpact();
                      onNext!();
                    }
                  : null,
                variant: GabiumButtonVariant.primary,
                size: GabiumButtonSize.medium, // 기존 온보딩 폼과 일관성 유지
              ),
              const SizedBox(height: 32), // xl (하단 여백)
            ],
          ],
        ),
      ),
    );
  }
}
```

### 1.5 Lottie Placeholder 준비

Lottie 에셋이 없으면 Task에서 에러 발생. **placeholder 전략**:

```dart
// Lottie 에셋 로드 (에러 시 placeholder 표시)
// 주의: Lottie.asset()에는 errorBuilder가 없으므로 FutureBuilder 패턴 사용
Widget _buildLottieOrPlaceholder(String assetPath, {double? height}) {
  final effectiveHeight = height ?? 200.0;

  return SizedBox(
    height: effectiveHeight,
    child: Lottie.asset(
      assetPath,
      height: effectiveHeight,
      fit: BoxFit.contain,
      // 에러 발생 시 빈 Container 반환 (파일 없을 때)
      onWarning: (warning) {
        debugPrint('Lottie warning: $warning');
      },
    ),
  );
}

// 대안: 에셋 존재 여부 확인 후 조건부 렌더링
Widget _buildLottieWithFallback(String assetPath, {double? height}) {
  final effectiveHeight = height ?? 200.0;

  // FutureBuilder로 에셋 로드 시도
  return FutureBuilder(
    future: Future.delayed(Duration.zero, () async {
      try {
        // 에셋 존재 확인 (rootBundle 사용)
        await rootBundle.load(assetPath);
        return true;
      } catch (e) {
        return false;
      }
    }),
    builder: (context, snapshot) {
      if (snapshot.data == true) {
        return Lottie.asset(assetPath, height: effectiveHeight);
      }
      // Placeholder
      return Container(
        height: effectiveHeight,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9), // Neutral-100
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(
            Icons.animation,
            size: 48,
            color: Color(0xFF94A3B8), // Neutral-400
          ),
        ),
      );
    },
  );
}
```

**assets/animations/ 에 빈 placeholder 파일 생성** (선택):
```bash
mkdir -p assets/animations
# 또는 실제 Lottie 파일 다운로드
```

---

## Phase 2-4: 스크린 그룹별 병렬 구현 (Task)

> **중요**: Phase 1 완료 후에만 Task 호출

### Task 호출 전 체크리스트

```
[ ] 의존성 설치 완료 (flutter pub get 성공)
[ ] OnboardingScreen 14스크린 구조 완료
[ ] JourneyProgressIndicator 생성 완료
[ ] OnboardingPageTemplate 생성 완료
[ ] 빌드 에러 없음 확인
```

---

### Task A: PART 1 - 공감과 희망 (3스크린)

**스크린**: [1] WelcomeScreen, [2] NotYourFaultScreen, [3] EvidenceScreen

**생성 파일**:
```
lib/features/onboarding/presentation/widgets/education/
├── welcome_screen.dart
├── not_your_fault_screen.dart
└── evidence_screen.dart
```

**Task 프롬프트 필수 컨텍스트**:

```markdown
## 목표
교육 온보딩 PART 1 (공감과 희망) 3개 스크린 구현

## 생성할 파일
1. `lib/features/onboarding/presentation/widgets/education/welcome_screen.dart`
2. `lib/features/onboarding/presentation/widgets/education/not_your_fault_screen.dart`
3. `lib/features/onboarding/presentation/widgets/education/evidence_screen.dart`

## 디자인 시스템 토큰
### 컬러
- Primary: #4ADE80 (Green-400)
- Primary Hover: #22C55E (Green-500)
- Neutral-50: #F8FAFC (배경)
- Neutral-100: #F1F5F9 (카드 배경)
- Neutral-200: #E2E8F0 (구분선)
- Neutral-400: #94A3B8 (placeholder)
- Neutral-500: #64748B (보조 텍스트)
- Neutral-700: #334155 (강조 텍스트)
- Neutral-800: #1E293B (제목)
- Info: #3B82F6 (파란색 정보)

### 타이포그래피
- 3xl: 28px Bold, line-height 36px (페이지 타이틀)
- 2xl: 24px Bold, line-height 32px (섹션 타이틀)
- xl: 20px Semibold, line-height 28px (카드 타이틀)
- base: 16px Regular, line-height 24px (본문)
- sm: 14px Regular, line-height 20px (보조 텍스트)
- xs: 12px Regular, line-height 16px (캡션)

### 스페이싱
- xs: 4px, sm: 8px, md: 16px, lg: 24px, xl: 32px

### Border Radius
- sm: 8px (버튼, 입력), md: 12px (카드), lg: 16px (시트)

## OnboardingPageTemplate 인터페이스 (이미 생성됨)
```dart
OnboardingPageTemplate(
  title: String?,           // 3xl Bold 타이틀
  subtitle: String?,        // base Regular 서브타이틀
  content: Widget,          // 메인 콘텐츠
  bottomWidget: Widget?,    // 버튼 위 추가 위젯
  onNext: VoidCallback?,    // 다음 버튼 콜백
  nextButtonText: String,   // 기본값 '다음'
  isNextEnabled: bool,      // 기본값 true
  showSkip: bool,           // 스킵 버튼 표시
  onSkip: VoidCallback?,    // 스킵 콜백
)
```

## 기존 컴포넌트 import
```dart
import 'package:n06/features/onboarding/presentation/widgets/common/onboarding_page_template.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/services.dart'; // HapticFeedback
```

## 필수 참조 문서 (Task 프롬프트 작성 시 Read하여 포함)

⚠️ **아래 문서를 직접 Read하고 해당 섹션을 Task 프롬프트에 복사할 것**

1. **spec.md** → "PART 1: 공감과 희망" 섹션 전체
2. **content.md** → [1] 환영, [2] 당신 탓 아니에요, [3] 변화의 증거들 섹션 전체

### 포함해야 할 spec.md 핵심 정보
- 각 스크린의 인터랙션 요구사항
- Lottie 애니메이션 파일명
- 출처 링크 (NEJM URL)
- showSkip 설정

### 포함해야 할 content.md 핵심 정보
- 정확한 타이틀, 서브타이틀 텍스트
- 본문 텍스트 (줄바꿈 포함)
- 정보카드, 인용문 텍스트
- 버튼 텍스트

## 라이브러리 사용법
⚠️ **반드시 pub.dev에서 최신 API 확인 후 구현**

### lottie (https://pub.dev/packages/lottie)
- pub.dev Example 탭에서 `Lottie.asset()` 또는 `LottieBuilder.asset()` 사용법 확인
- errorBuilder 파라미터로 fallback 처리
- 버전별 API 차이 주의 (v2.x vs v3.x)

### animated_flip_counter (https://pub.dev/packages/animated_flip_counter)
- pub.dev Example 탭에서 정확한 위젯명과 파라미터 확인
- `AnimatedFlipCounter` 또는 `AnimatedFlipWidget` 등 버전별 차이 확인

### url_launcher (https://pub.dev/packages/url_launcher)
- `launchUrl()` 또는 `launch()` - 버전에 따라 다름
- pub.dev에서 현재 권장 방식 확인

## 구현 규칙
1. Clean Architecture: Presentation Layer만 수정
2. 디자인 토큰 정확히 사용 (커스텀 색상/값 금지)
3. HapticFeedback: 버튼 탭 시 HapticFeedback.lightImpact()
4. Lottie 에러 시 Container placeholder 표시
5. 모든 텍스트 하드코딩 (i18n 미적용)

## 각 스크린 인터페이스
```dart
class WelcomeScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback? onSkip;

  const WelcomeScreen({super.key, required this.onNext, this.onSkip});
}
```
```

---

### Task B: PART 2 - 이해와 확신 (4스크린)

**스크린**: [4] FoodNoiseScreen, [5] HowItWorksScreen, [6] JourneyRoadmapScreen, [7] SideEffectsScreen

**생성 파일**:
```
lib/features/onboarding/presentation/widgets/education/
├── food_noise_screen.dart
├── how_it_works_screen.dart
├── journey_roadmap_screen.dart
└── side_effects_screen.dart
```

**Task 프롬프트 필수 컨텍스트**:

```markdown
## 목표
교육 온보딩 PART 2 (이해와 확신) 4개 스크린 구현

## 특수 요구사항

### [4] FoodNoiseScreen
- Slider(1-10)와 Lottie 애니메이션 연동
- Slider 값 변경 → Lottie controller.value 업데이트
- "변화 보기" 버튼 탭 → 애니메이션으로 값 감소 시뮬레이션
- 완료 후 onFoodNoiseLevelChanged(int level) 콜백 호출
- showSkip: true

### [5] HowItWorksScreen
- ExpansionTile 2개 (뇌, 위)
- **모든 타일 한 번씩 탭해야 다음 버튼 활성화** (게이미피케이션)
- 상태: Set<String> _expandedItems = {}
- isNextEnabled: _expandedItems.containsAll({'brain', 'stomach'})
- showSkip: true

### [6] JourneyRoadmapScreen
- 타임라인 ListView (3단계: 적응기, 변화기, 성장기)
- 각 단계 탭 시 ExpansionTile로 상세 정보
- showSkip: true

### [7] SideEffectsScreen
- ExpansionTile 3개 (속 불편함, 입맛 변화, 피로감)
- HapticFeedback.lightImpact() on expansion
- 의료적 면책 조항 텍스트 (xs, Neutral-400)
- showSkip: true

## [4] FoodNoiseScreen 인터페이스
```dart
class FoodNoiseScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onSkip;
  final Function(int) onFoodNoiseLevelChanged; // 상태 저장용

  const FoodNoiseScreen({
    super.key,
    required this.onNext,
    this.onSkip,
    required this.onFoodNoiseLevelChanged,
  });
}
```

## 라이브러리 사용법
⚠️ **반드시 pub.dev에서 최신 API 확인 후 구현**

### lottie + AnimationController 연동 (https://pub.dev/packages/lottie)
- pub.dev Example 탭에서 controller 연동 방식 확인
- `Lottie.asset()` 의 `controller` 파라미터 사용법 확인
- `onLoaded` 콜백에서 duration 설정 패턴 확인

**참고 패턴** (pub.dev 확인 후 수정 필요):
```dart
class _FoodNoiseScreenState extends State<FoodNoiseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _lottieController;
  double _userLevel = 5.0;
  bool _hasSimulated = false;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  // ⚠️ 아래 코드는 pub.dev에서 최신 API 확인 후 수정
  void _onSliderChanged(double value) {
    setState(() {
      _userLevel = value;
      _lottieController.value = value / 10.0;
    });
    HapticFeedback.selectionClick();
  }

  void _simulateChange() {
    setState(() => _hasSimulated = true);
    _lottieController.animateTo(
      0.16,
      duration: const Duration(seconds: 2),
      curve: Curves.easeOut,
    );
    widget.onFoodNoiseLevelChanged(_userLevel.toInt());
  }
}
```

## 필수 참조 문서 (Task 프롬프트 작성 시 Read하여 포함)

⚠️ **아래 문서를 직접 Read하고 해당 섹션을 Task 프롬프트에 복사할 것**

1. **spec.md** → "PART 2: 이해와 확신" 섹션 전체
2. **content.md** → [4] Food Noise, [5] 작동 원리, [6] 여정 로드맵, [7] 적응과 대처 섹션 전체

### 포함해야 할 spec.md 핵심 정보
- [4] Slider + Lottie 연동 상세 요구사항
- [5] ExpansionTile 게이미피케이션 (모든 항목 탭해야 다음 버튼 활성화)
- [6] 타임라인 데이터 (1-4주, 5-12주, 13주+)
- [7] 증상별 대처법 테이블, 의료적 면책 조항

### 포함해야 할 content.md 핵심 정보
- 모든 텍스트 (공감 문구, 설명, 팁 등)
- 이모지 포함 정확한 문구

(디자인 토큰, OnboardingPageTemplate 등은 Task A와 동일)
```

---

### Task C: PART 4 - 준비와 시작 (3스크린)

**스크린**: [12] InjectionGuideScreen, [13] AppFeaturesScreen, [14] CommitmentScreen

**생성 파일**:
```
lib/features/onboarding/presentation/widgets/preparation/
├── injection_guide_screen.dart
├── app_features_screen.dart
└── commitment_screen.dart
```

**Task 프롬프트 필수 컨텍스트**:

```markdown
## 목표
교육 온보딩 PART 4 (준비와 시작) 3개 스크린 구현

## 특수 요구사항

### [12] InjectionGuideScreen
- 3개 버튼 (복부, 허벅지, 팔) → 탭 시 BottomSheet
- BottomSheet: 부위별 설명 + 이미지 (없으면 Icon placeholder)
- showSkip: false (Part 4는 스킵 불가)

### [13] AppFeaturesScreen
- PageView + SmoothPageIndicator (4페이지)
- 자동 스와이프 안내: "스와이프해서 더 보기 →"
- showSkip: false

### [14] CommitmentScreen ⚠️ 가장 복잡
- 요약 카드 표시 (props로 받음)
- slide_to_confirm 위젯으로 스와이프 확인
- 스와이프 완료 시:
  1. HapticFeedback.heavyImpact()
  2. Confetti 애니메이션
  3. 1.5초 후 다이얼로그: "첫 번째 미션: 현재 체중을 기록해보세요"
  4. 다이얼로그 확인 → onComplete() 호출

## [14] CommitmentScreen 인터페이스
```dart
class CommitmentScreen extends StatefulWidget {
  // 요약 표시용 데이터
  final String name;
  final double currentWeight;
  final double targetWeight;
  final DateTime startDate;
  final String medicationName;
  final double initialDose;

  // 완료 콜백 (OnboardingScreen에서 saveOnboardingData 호출)
  final VoidCallback onComplete;

  const CommitmentScreen({
    super.key,
    required this.name,
    required this.currentWeight,
    required this.targetWeight,
    required this.startDate,
    required this.medicationName,
    required this.initialDose,
    required this.onComplete,
  });
}
```

## 라이브러리 사용법
⚠️ **반드시 pub.dev에서 최신 API 확인 후 구현**

### slide_to_confirm (https://pub.dev/packages/slide_to_confirm)
- pub.dev Example 탭에서 정확한 위젯명 확인 (ConfirmationSlider? SlideToConfirm?)
- 필수 파라미터와 콜백 이름 확인
- 스타일링 파라미터 (색상, 크기) 확인

### confetti (https://pub.dev/packages/confetti)
- pub.dev Example 탭에서 ConfettiController, ConfettiWidget 사용법 확인
- blastDirectionality 옵션 확인
- dispose 패턴 확인

### smooth_page_indicator (https://pub.dev/packages/smooth_page_indicator)
- pub.dev Example 탭에서 SmoothPageIndicator 사용법 확인
- effect 종류 (WormEffect, ExpandingDotsEffect 등) 확인
- 디자인 토큰 매핑:
  - activeDotColor: Primary (#4ADE80)
  - dotColor: Neutral-200 (#E2E8F0)

## 필수 참조 문서 (Task 프롬프트 작성 시 Read하여 포함)

⚠️ **아래 문서를 직접 Read하고 해당 섹션을 Task 프롬프트에 복사할 것**

1. **spec.md** → "PART 4: 준비와 시작" 섹션 전체
2. **content.md** → [12] 주사 가이드, [13] 앱 사용법, [14] 약속과 시작 섹션 전체

### 포함해야 할 spec.md 핵심 정보
- [12] 주사 부위 3개 (복부, 허벅지, 팔) + BottomSheet 내용
- [13] 캐러셀 4개 콘텐츠 (투여 알림, 변화 기록, 부작용 가이드, 의료진 공유)
- [14] 요약 카드 표시 형식, Swipe to Confirm, Confetti, 다음 미션 다이얼로그

### 포함해야 할 content.md 핵심 정보
- 안심 포인트 체크리스트 텍스트
- 캐러셀 각 페이지 텍스트
- 약속 체크박스 텍스트
- 마무리 메시지

(디자인 토큰, OnboardingPageTemplate 등은 Task A와 동일)
```

---

### Task D: PART 3 - 설정 수정 (기존 화면 개선)

**수정 파일**:
```
lib/features/onboarding/presentation/widgets/
├── basic_profile_form.dart
├── weight_goal_form.dart
└── summary_screen.dart
```

**Task 프롬프트 필수 컨텍스트**:

```markdown
## 목표
기존 온보딩 설정 화면 3개 톤 개선 (기존 코드 수정)

## 변경 사항

### [8] BasicProfileForm
**기존 코드 위치**: lib/features/onboarding/presentation/widgets/basic_profile_form.dart

변경 전:
- AuthHeroSection title: '가비움 온보딩을 시작하세요'
- AuthHeroSection subtitle: '당신의 건강 관리 여정을 함께합니다'

변경 후:
- title: '🌟 여정의 주인공을 알려주세요'
- subtitle: '앞으로 이 이름으로 응원해 드릴게요'
- 하단에 프라이버시 안내 추가: "입력하신 건강 데이터는 암호화되어 안전하게 보관됩니다."

### [9] WeightGoalForm
**기존 코드 위치**: lib/features/onboarding/presentation/widgets/weight_goal_form.dart

변경 전:
- 타이틀: '체중 및 목표 설정'

변경 후:
- 타이틀: '📊 목표를 함께 세워볼까요?'
- 예측 계산기 추가 (현재 체중 입력 시):
  ```
  예상 변화
  12주 후: -{currentWeight * 0.10}kg
  72주 후: -{currentWeight * 0.21}kg
  * 임상시험 평균 기준
  ```
- 하단 동기부여 메시지 추가:
  "💡 임상시험에서 72주 동안 평균 21% 감량을 달성했어요\n무리하지 않는 목표가 오히려 더 좋은 결과를 만들어요"

### [11] SummaryScreen
**기존 코드 위치**: lib/features/onboarding/presentation/widgets/summary_screen.dart

변경 전:
- 타이틀: '정보 확인'

변경 후:
- 상단에 격려 메시지 추가: "준비가 잘 되었어요! ✨"
- 타이틀 유지: '정보 확인'

## 필수 참조 문서 및 코드

⚠️ **아래 문서와 코드를 직접 Read하고 Task 프롬프트에 포함할 것**

### 1. spec.md → "PART 3: 설정" 섹션
- 각 스크린의 변경 요구사항

### 2. content.md → [8] 프로필, [9] 체중 목표, [11] 요약 확인 섹션
- 정확한 변경 텍스트

### 3. 기존 코드 (Read 필수) ⚠️
Task 실행 전 반드시 아래 3개 파일을 **Read하여 전체 코드를 Task 프롬프트에 포함**:
- `lib/features/onboarding/presentation/widgets/basic_profile_form.dart`
- `lib/features/onboarding/presentation/widgets/weight_goal_form.dart`
- `lib/features/onboarding/presentation/widgets/summary_screen.dart`

기존 구조(import, 위젯 트리, 상태 관리) 유지하며 텍스트만 수정

## 구현 규칙
1. 기존 import, 위젯 구조 최대한 유지
2. 기존 기능(validation, state) 변경 금지
3. 텍스트/메시지만 추가/수정

## 이모지 사용 정책
⚠️ **주의**: 이 프로젝트에서는 텍스트에 이모지를 사용합니다.
- Task D에서 수정하는 텍스트에는 의도적으로 이모지가 포함됨 (🌟, 📊, ✨, 💡)
- 이는 사용자 친화적인 톤을 위한 디자인 결정임
- content.md에 명시된 이모지를 그대로 사용할 것
```

---

## Phase 5: 통합 + 에셋 등록 (직접)

### 5.1 OnboardingScreen에 스크린 통합

```dart
// PageView children에 14개 스크린 연결
PageView(
  children: [
    // PART 1: 공감 (1-3)
    WelcomeScreen(onNext: _nextStep, onSkip: _skipToSetup),
    NotYourFaultScreen(onNext: _nextStep, onSkip: _skipToSetup),
    EvidenceScreen(onNext: _nextStep, onSkip: _skipToSetup),

    // PART 2: 이해 (4-7)
    FoodNoiseScreen(
      onNext: _nextStep,
      onSkip: _skipToSetup,
      onFoodNoiseLevelChanged: (level) => _initialFoodNoiseLevel = level,
    ),
    HowItWorksScreen(onNext: _nextStep, onSkip: _skipToSetup),
    JourneyRoadmapScreen(onNext: _nextStep, onSkip: _skipToSetup),
    SideEffectsScreen(onNext: _nextStep, onSkip: _skipToSetup),

    // PART 3: 설정 (8-11) - 기존 위젯
    BasicProfileForm(onNameChanged: (name) => _name = name, onNext: _nextStep),
    WeightGoalForm(onDataChanged: _onWeightDataChanged, onNext: _nextStep),
    DosagePlanForm(onDataChanged: _onDosageDataChanged, onNext: _nextStep),
    SummaryScreen(...), // 기존 요약 (10번째 → 11번째로 이동)

    // PART 4: 준비 (12-14)
    InjectionGuideScreen(onNext: _nextStep),
    AppFeaturesScreen(onNext: _nextStep),
    CommitmentScreen(
      name: _name,
      currentWeight: _currentWeight,
      targetWeight: _targetWeight,
      startDate: _startDate,
      medicationName: _medicationName,
      initialDose: _initialDose,
      onComplete: _completeOnboarding,
    ),
  ],
)
```

### 5.2 스킵 로직 구현

```dart
void _skipToSetup() {
  // Part 3 설정 시작 (8번째 스크린, index 7)
  _pageController.animateToPage(
    7,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );
}
```

### 5.3 완료 처리

```dart
Future<void> _completeOnboarding() async {
  // 기존 saveOnboardingData 호출
  await ref.read(onboardingNotifierProvider.notifier).saveOnboardingData(
    userId: widget.userId ?? '',
    name: _name,
    currentWeight: _currentWeight,
    targetWeight: _targetWeight,
    targetPeriodWeeks: _targetPeriodWeeks,
    medicationName: _medicationName,
    startDate: _startDate,
    cycleDays: _cycleDays,
    initialDose: _initialDose,
  );

  // education_completed 플래그 저장
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('education_completed', true);
  if (_initialFoodNoiseLevel != null) {
    await prefs.setInt('initial_food_noise_level', _initialFoodNoiseLevel!);
  }

  // 홈으로 이동
  if (context.mounted) {
    context.go('/home');
  }
}
```

### 5.4 에셋 등록 (registry.json)

**파일**: `.claude/skills/ui-renewal/component-library/registry.json`

신규 컴포넌트 추가:

| 컴포넌트 | 카테고리 | 재사용처 |
|---------|---------|---------|
| JourneyProgressIndicator | navigation | 멀티스텝 폼, 튜토리얼 |
| OnboardingPageTemplate | layout | 온보딩 전체 |
| TimelineItem | display | 투여 기록, 여정 표시 |

### 5.5 COMPONENTS.md 갱신

```bash
python .claude/skills/ui-renewal/scripts/generate_components_docs.py \
  --output-components-md
```

---

## 실행 순서 체크리스트

```
Phase 1 (직접)
[ ] 1.1: flutter pub add 의존성 설치
[ ] 1.2: OnboardingScreen 14스크린 구조 + 상태 추가
[ ] 1.3: JourneyProgressIndicator 생성
[ ] 1.4: OnboardingPageTemplate 생성
[ ] 1.5: 빌드 확인 (flutter build 에러 없음)

Phase 2-4 (Task 병렬) ← Phase 1 완료 후에만
[ ] Task A: PART 1 (WelcomeScreen 외 2개)
[ ] Task B: PART 2 (FoodNoiseScreen 외 3개)
[ ] Task C: PART 4 (InjectionGuideScreen 외 2개)
[ ] Task D: PART 3 수정 (BasicProfileForm 외 2개)

Phase 5 (직접)
[ ] 5.1: OnboardingScreen에 스크린 통합
[ ] 5.2: 스킵 로직 구현
[ ] 5.3: 완료 처리 + SharedPreferences
[ ] 5.4: registry.json 업데이트
[ ] 5.5: COMPONENTS.md 갱신
[ ] 5.6: 전체 테스트
```

---

## 참고 문서

- spec.md: 전체 스펙
- plan.md: 상세 구현 계획
- content.md: 텍스트 콘텐츠
- gabium-design-system-v1.0.md: 디자인 시스템
- COMPONENTS.md: 기존 컴포넌트 목록
