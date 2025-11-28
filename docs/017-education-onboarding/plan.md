# 교육 온보딩 구현 계획

## 구현 범위

14스크린 인터랙티브 교육 온보딩 플로우 구현

---

## 의존성 설치

```bash
flutter pub add lottie confetti animated_flip_counter slide_to_confirm smooth_page_indicator url_launcher shared_preferences
```

---

## 공통 Import 및 커스텀 위젯 정의

### 필수 Import
```dart
// 기본
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // HapticFeedback

// 외부 패키지
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:slide_to_confirm/slide_to_confirm.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 프로젝트 내부
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';
import 'package:n06/features/onboarding/presentation/widgets/common/onboarding_page_template.dart';
```

### 커스텀 위젯 매핑

문서에서 사용하는 의사(pseudo) 위젯과 실제 구현 매핑:

| 문서 위젯 | 실제 구현 |
|----------|----------|
| `Title(text)` | `Text(text, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)))` |
| `Subtitle(text)` | `Text(text, style: TextStyle(fontSize: 16, color: Color(0xFF64748B)))` |
| `BodyText(text)` | `Text(text, style: TextStyle(fontSize: 16, color: Color(0xFF334155)))` |
| `NextButton()` | `GabiumButton(text: '다음', onPressed: onNext, variant: GabiumButtonVariant.primary, size: GabiumButtonSize.medium)` |
| `NextButton(enabled: bool)` | `GabiumButton(..., onPressed: enabled ? onNext : null)` |
| `InfoCard(text)` | 아래 InfoCard 구현 참조 |
| `BenefitChip(text)` | 아래 BenefitChip 구현 참조 |

### InfoCard 구현
```dart
Widget InfoCard(String text) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Color(0xFFEFF6FF), // Info 배경 (Blue-50)
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Color(0xFF3B82F6).withOpacity(0.3)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('💡', style: TextStyle(fontSize: 16)),
        SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 14, color: Color(0xFF1E40AF))),
        ),
      ],
    ),
  );
}
```

### BenefitChip 구현
```dart
Widget BenefitChip(String text) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Color(0xFFF1F5F9), // Neutral-100
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(text, style: TextStyle(fontSize: 12, color: Color(0xFF334155))),
  );
}
```

### QuoteCard 구현
```dart
Widget QuoteCard(String text) {
  return Container(
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Color(0xFFF0FDF4), // Green-50
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Color(0xFF4ADE80).withOpacity(0.3)),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontStyle: FontStyle.italic,
        color: Color(0xFF166534), // Green-800
        height: 1.6,
      ),
      textAlign: TextAlign.center,
    ),
  );
}
```

---

## Task 1: 기반 구조

### 1.1 OnboardingScreen 확장

**파일**: `lib/features/onboarding/presentation/screens/onboarding_screen.dart`

**변경**:
```dart
// 기존: 4스크린
// 변경: 14스크린

const totalSteps = 14;

// Part 구분
enum OnboardingPart {
  empathy,      // 1-3
  understanding, // 4-7
  setup,        // 8-11
  preparation   // 12-14
}
```

### 1.2 JourneyProgressIndicator 생성

**파일**: `lib/features/onboarding/presentation/widgets/common/journey_progress_indicator.dart`

**Props**:
```dart
class JourneyProgressIndicator extends StatelessWidget {
  final int currentStep; // 0-13
  final int totalSteps;  // 14
}
```

**UI**:
```
공감    이해    설정    준비
 ●━━━━━━●━━━━━━○━━━━━━○
```

### 1.3 OnboardingPageTemplate 생성

**파일**: `lib/features/onboarding/presentation/widgets/common/onboarding_page_template.dart`

**Props**:
```dart
class OnboardingPageTemplate extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget content;
  final Widget? bottomWidget;
  final VoidCallback onNext;
  final bool showSkip;
  final VoidCallback? onSkip;
}
```

---

## Task 2: PART 1 - 공감과 희망 (3스크린)

### 2.1 WelcomeScreen [1]

**파일**: `lib/features/onboarding/presentation/widgets/education/welcome_screen.dart`

**구조**:
```dart
Column(
  children: [
    Lottie.asset('assets/animations/welcome.json'), // 문 여는 사람
    Title('새로운 여정을 시작해요'),
    Subtitle('당신이 여기까지 오기까지\n얼마나 많은 노력을 했는지 알아요'),
    QuoteCard('"이번엔 혼자가 아니에요\n과학이, 그리고 이 앱이\n당신과 함께할 거예요"'),
    NextButton(),
  ],
)
```

### 2.2 NotYourFaultScreen [2]

**파일**: `lib/features/onboarding/presentation/widgets/education/not_your_fault_screen.dart`

**구조**:
```dart
Column(
  children: [
    Lottie.asset('assets/animations/hormone_balance.json'),
    Title('의지력의 문제가 아니었어요'),
    BodyText('체중 관리가 어려웠던 건...'),
    Divider(),
    BodyText('우리 몸에는 식욕을 조절하는...'),
    InfoCard('💡 GLP-1은 이 균형을 다시 맞춰주는 역할을 해요'),
    NextButton(),
  ],
)
```

### 2.3 EvidenceScreen [3]

**파일**: `lib/features/onboarding/presentation/widgets/education/evidence_screen.dart`

**데이터**:
```dart
// SURMOUNT-1 임상시험 결과 (72주, 15mg)
const evidenceData = {
  'weightLoss': 21,       // %
  'achieved5percent': 91,  // %
  'achieved20percent': 57, // %
};
```

**구조**:
```dart
Column(
  children: [
    Title('실제로 일어난 변화들'),
    Subtitle('전 세계 수백만 명이 경험한 검증된 결과예요'),
    // 숫자 카운터 애니메이션
    AnimatedFlipCounter(
      value: 21,
      suffix: '%',
      textStyle: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
    ),
    Text('평균 체중 감량'),
    Text('평균 체중 감량'),
    GestureDetector(
      onTap: () => launchUrl(Uri.parse('https://www.nejm.org/doi/full/10.1056/NEJMoa2206038')),
      child: Text('72주 임상시험 결과 (NEJM) 🔗', style: TextStyle(fontSize: 12, decoration: TextDecoration.underline)),
    ),
    SizedBox(height: 16),
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        BenefitChip('🫀 심장 건강 개선'),
        SizedBox(width: 8),
        BenefitChip('😴 수면 질 향상'),
      ],
    ),
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        BenefitChip('🩸 혈당 조절 개선'),
        SizedBox(width: 8),
        BenefitChip('⚡ 에너지 레벨 상승'),
      ],
    ),
    BodyText('체중 감량 그 이상의 변화가 당신을 기다리고 있어요'),
    NextButton(),
  ],
)
```

---

## Task 3: PART 2 - 이해와 확신 (4스크린)

### 3.1 FoodNoiseScreen [4]

**파일**: `lib/features/onboarding/presentation/widgets/education/food_noise_screen.dart`

**Lottie + Slider 연동**:
```dart
class _FoodNoiseScreenState extends State<FoodNoiseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _lottieController;
  double _userLevel = 5.0; // 1-10
  bool _isSimulating = false;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
  }

  void _startSimulation() {
    setState(() => _isSimulating = true);
    // 1.5초 동안 현재 레벨에서 1.0(평화)으로 줄어드는 애니메이션
    _lottieController.animateTo(0.1, duration: Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Title('머릿속 음식 생각, 줄어들 거예요'),
        Subtitle('현재 음식 생각이 얼마나 자주 나나요?'),
        
        // Lottie 애니메이션
        Lottie.asset(
          'assets/animations/food_noise.json',
          controller: _lottieController,
          onLoaded: (composition) {
            _lottieController.duration = composition.duration;
            // 초기값 설정 (사용자 입력에 따라)
            _lottieController.value = _userLevel / 10.0; 
          },
        ),

        if (!_isSimulating) ...[
          Text('나의 상태: ${_userLevel.toInt()}'),
          Slider(
            value: _userLevel,
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (value) {
              setState(() {
                _userLevel = value;
                _lottieController.value = value / 10.0;
              });
              HapticFeedback.selectionClick();
            },
          ),
          ElevatedButton(
            onPressed: _startSimulation,
            child: Text('치료 후 변화 보기'),
          ),
        ] else ...[
          Text('치료 후에는 이렇게 편안해질 거예요 ✨'),
          NextButton(onPressed: () {
             // 데이터 저장: initial_food_noise_level = _userLevel
             widget.onNext();
          }),
        ],
      ],
    );
  }
}
```

### 3.2 HowItWorksScreen [5]

**파일**: `lib/features/onboarding/presentation/widgets/education/how_it_works_screen.dart`

**구조**:
```dart
class _HowItWorksScreenState extends State<HowItWorksScreen> {
  bool _brainExpanded = false;
  bool _stomachExpanded = false;

  bool get _allExpanded => _brainExpanded && _stomachExpanded;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Title('이렇게 도와드려요'),
        Text('[탭해서 자세히 알아보기]'),
        // 뇌 설명
        ExpansionTile(
          leading: Text('🧠', style: TextStyle(fontSize: 32)),
          title: Text('뇌'),
          onExpansionChanged: (expanded) {
            setState(() => _brainExpanded = expanded);
            if (expanded) HapticFeedback.lightImpact();
          },
          children: [
            ListTile(title: Text('• 포만감 신호 강화')),
            ListTile(title: Text('• 음식 보상 반응 조절')),
          ],
        ),
        // 위 설명
        ExpansionTile(
          leading: Text('🫃', style: TextStyle(fontSize: 32)),
          title: Text('위'),
          onExpansionChanged: (expanded) {
            setState(() => _stomachExpanded = expanded);
            if (expanded) HapticFeedback.lightImpact();
          },
          children: [
            ListTile(title: Text('• 음식 소화 속도 조절')),
            ListTile(title: Text('• 포만감 오래 유지')),
          ],
        ),
        Divider(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✓ 억지로 참는 게 아니에요', style: TextStyle(fontSize: 14, color: Color(0xFF334155))),
            SizedBox(height: 4),
            Text('✓ 자연스럽게 덜 먹게 돼요', style: TextStyle(fontSize: 14, color: Color(0xFF334155))),
            SizedBox(height: 4),
            Text('✓ 선택의 여유가 생겨요', style: TextStyle(fontSize: 14, color: Color(0xFF334155))),
          ],
        ),
        // 모든 항목 탭해야 활성화
        NextButton(enabled: _allExpanded),
      ],
    );
  }
}
```

### 3.3 JourneyRoadmapScreen [6]

**파일**: `lib/features/onboarding/presentation/widgets/education/journey_roadmap_screen.dart`

**구조**:
```dart
Column(
  children: [
    Title('앞으로의 여정이에요'),
    Subtitle('조급해하지 않아도 괜찮아요\n몸이 천천히 변화할 거예요'),
    Expanded(
      child: ListView(
        children: [
          TimelineItem(
            icon: '🌱',
            title: '1-4주: 적응기',
            description: '몸이 약과 친해지는 시간\n큰 변화 없어도 정상이에요',
            isActive: true,
          ),
          TimelineItem(
            icon: '🌿',
            title: '5-12주: 변화기',
            description: '본격적인 효과가 나타나요\n체중 감소가 눈에 보여요',
          ),
          TimelineItem(
            icon: '🌳',
            title: '13주+: 성장기',
            description: '새로운 습관이 자리잡아요\n건강한 일상이 되어가요',
          ),
        ],
      ),
    ),
    InfoCard('💡 평균 4-5주 후부터 확실한 변화를 느껴요\n체중이 잠시 멈추는 건 몸이 적응하는 건강한 신호예요'),
    NextButton(),
  ],
)
```

### 3.4 SideEffectsScreen [7]

**파일**: `lib/features/onboarding/presentation/widgets/education/side_effects_screen.dart`

**구조**:
```dart
Column(
  children: [
    Title('처음엔 이런 느낌이 있을 수 있어요'),
    Subtitle('걱정 마세요, 몸이 적응하는 자연스러운 과정이에요'),
    ExpansionTile(
      leading: Text('😮‍💨'),
      title: Text('속이 불편해요'),
      trailing: Chip(label: Text('90%+ ✓')),
      onExpansionChanged: (_) => HapticFeedback.lightImpact(),
      children: [
        ListTile(title: Text('• 작은 양으로 천천히 드세요')),
        ListTile(title: Text('• 기름진 음식은 잠시 피해요')),
        ListTile(title: Text('• 대부분 2주 내 나아져요')),
      ],
    ),
    ExpansionTile(
      leading: Text('🍽️'),
      title: Text('입맛이 변했어요'),
      children: [
        ListTile(title: Text('• 좋은 신호예요!')),
        ListTile(title: Text('• 몸이 필요한 만큼만 먹으려는 거예요')),
      ],
    ),
    ExpansionTile(
      leading: Text('😴'),
      title: Text('좀 피곤해요'),
      children: [
        ListTile(title: Text('• 수분을 충분히 드세요')),
        ListTile(title: Text('• 단백질 섭취를 늘려보세요')),
        ListTile(title: Text('• 몸이 적응하면 나아져요')),
      ],
    ),
    WarningCard('⚠️ 심한 증상은 앱에서 바로 확인하고 대처할 수 있어요'),
    Text('이 정보는 일반적인 가이드이며, 담당 의사의 처방을 최우선으로 따라주세요.', style: TextStyle(fontSize: 10, color: Colors.grey)),
    NextButton(),
  ],
)
```

---

## Task 4: PART 3 - 설정 (기존 수정)

### 4.1 BasicProfileForm [8] 수정

**파일**: `lib/features/onboarding/presentation/widgets/basic_profile_form.dart`

**변경**:
```dart
// 타이틀 변경
'기본 프로필' → '🌟 여정의 주인공을 알려주세요'

// 서브텍스트 추가
'앞으로 이 이름으로 응원해 드릴게요'

// 데이터 프라이버시 문구 추가
'입력하신 건강 데이터는 암호화되어 안전하게 보관됩니다.'
```

### 4.2 WeightGoalForm [9] 수정

**파일**: `lib/features/onboarding/presentation/widgets/weight_goal_form.dart`

**변경**:
```dart
// 타이틀 변경
'체중 및 목표' → '📊 목표를 함께 세워볼까요?'

// 개인화 예측 계산기 추가
Widget _buildPredictionCard() {
  if (_currentWeight == 0) return SizedBox.shrink();

  final predicted12Week = _currentWeight * 0.10; // 10%
  final predicted72Week = _currentWeight * 0.21; // 21%

  return Card(
    child: Column(
      children: [
        Text('예상 변화'),
        Text('12주 후: -${predicted12Week.toStringAsFixed(1)}kg'),
        Text('72주 후: -${predicted72Week.toStringAsFixed(1)}kg'),
        Text('* 임상시험 평균 기준', style: TextStyle(fontSize: 12)),
      ],
    ),
  );
}

// 하단에 동기부여 메시지 추가
InfoCard(
  '💡 임상시험에서 72주 동안 평균 21% 감량을 달성했어요\n'
  '무리하지 않는 목표가 오히려 더 좋은 결과를 만들어요'
)
```

### 4.3 SummaryScreen [11] 수정

**파일**: `lib/features/onboarding/presentation/widgets/summary_screen.dart`

**변경**:
```dart
// 상단에 격려 메시지 추가
'준비가 잘 되었어요! ✨'
```

---

## Task 5: PART 4 - 준비와 시작 (3스크린)

### 5.1 InjectionGuideScreen [12]

**파일**: `lib/features/onboarding/presentation/widgets/preparation/injection_guide_screen.dart`

**구조 (간단한 버튼 방식)**:
```dart
Column(
  children: [
    Title('주사, 생각보다 간단해요'),
    Subtitle('처음엔 누구나 긴장돼요\n하지만 한 번 해보면 "이게 끝?" 할 거예요'),
    SizedBox(height: 24),
    // 주사 부위 선택 버튼 (3개)
    Text('주사 부위를 탭해서 알아보세요'),
    SizedBox(height: 16),
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _InjectionSiteButton(
          icon: '🫃',
          label: '복부',
          onTap: () => _showSiteGuide(context, InjectionSite.abdomen),
        ),
        _InjectionSiteButton(
          icon: '🦵',
          label: '허벅지',
          onTap: () => _showSiteGuide(context, InjectionSite.thigh),
        ),
        _InjectionSiteButton(
          icon: '💪',
          label: '팔',
          onTap: () => _showSiteGuide(context, InjectionSite.arm),
        ),
      ],
    ),
    SizedBox(height: 24),
    // 안심 포인트
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('✓ 바늘이 머리카락보다 가늘어요', style: TextStyle(fontSize: 14, color: Color(0xFF334155))),
        SizedBox(height: 4),
        Text('✓ 대부분 거의 못 느껴요', style: TextStyle(fontSize: 14, color: Color(0xFF334155))),
        SizedBox(height: 4),
        Text('✓ 버튼 누르면 10초 안에 끝', style: TextStyle(fontSize: 14, color: Color(0xFF334155))),
      ],
    ),
    SizedBox(height: 16),
    // 꿀팁 카드
    Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('💡 꿀팁', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text('• 매주 부위를 돌아가며', style: TextStyle(fontSize: 14)),
          Text('• 주사 전 심호흡 한 번', style: TextStyle(fontSize: 14)),
          Text('• 펜의 바늘 가림막으로 안심', style: TextStyle(fontSize: 14)),
        ],
      ),
    ),
    Text('담당 의사의 주사 지도를 최우선으로 따라주세요.', style: TextStyle(fontSize: 10, color: Colors.grey)),
    NextButton(),
  ],
)

// BottomSheet로 부위별 상세 안내
void _showSiteGuide(BuildContext context, InjectionSite site) {
  HapticFeedback.lightImpact();
  showModalBottomSheet(
    context: context,
    builder: (context) => _SiteGuideSheet(site: site),
  );
}
```

**부위별 BottomSheet 콘텐츠**:
```dart
class _SiteGuideSheet extends StatelessWidget {
  final InjectionSite site;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_getTitle(site), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Image.asset(_getImagePath(site), height: 150),
          SizedBox(height: 16),
          Text(_getDescription(site)),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  String _getTitle(InjectionSite site) {
    switch (site) {
      case InjectionSite.abdomen: return '🫃 복부';
      case InjectionSite.thigh: return '🦵 허벅지';
      case InjectionSite.arm: return '💪 팔';
    }
  }

  String _getDescription(InjectionSite site) {
    switch (site) {
      case InjectionSite.abdomen:
        return '배꼽 주변 5cm 이상 떨어진 곳\n가장 일반적인 부위예요';
      case InjectionSite.thigh:
        return '허벅지 앞쪽 또는 바깥쪽\n앉아서 편하게 주사할 수 있어요';
      case InjectionSite.arm:
        return '윗팔 뒤쪽\n다른 사람 도움이 필요할 수 있어요';
    }
  }
}

enum InjectionSite { abdomen, thigh, arm }
```

### 5.2 AppFeaturesScreen [13]

**파일**: `lib/features/onboarding/presentation/widgets/preparation/app_features_screen.dart`

**구조**:
```dart
class _AppFeaturesScreenState extends State<AppFeaturesScreen> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Title('이렇게 함께할 거예요'),
        Expanded(
          child: PageView(
            controller: _pageController,
            children: [
              FeatureSlide(icon: '📅', title: '투여 알림', description: '잊지 않도록 챙겨드려요'),
              FeatureSlide(icon: '📊', title: '변화 기록', description: '체중, 증상을 한눈에'),
              FeatureSlide(icon: '🆘', title: '부작용 가이드', description: '불편할 땐 바로 확인'),
              FeatureSlide(icon: '📋', title: '의료진 공유', description: '진료 시 보여드리기 편해요'),
            ],
          ),
        ),
        SmoothPageIndicator(
          controller: _pageController,
          count: 4,
          effect: WormEffect(
            dotHeight: 8,
            dotWidth: 8,
            activeDotColor: Color(0xFF4ADE80), // Primary
            dotColor: Color(0xFFE2E8F0), // Neutral-200
          ),
        ),
        SizedBox(height: 16),
        Text('스와이프해서 더 보기 →'),
        NextButton(),
      ],
    );
  }
}
```

### 5.3 CommitmentScreen [14]

**파일**: `lib/features/onboarding/presentation/widgets/preparation/commitment_screen.dart`

**구조**:
```dart
class _CommitmentScreenState extends State<CommitmentScreen> {
  final ConfettiController _confettiController = ConfettiController(
    duration: Duration(seconds: 3),
  );

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _onConfirmed() {
    HapticFeedback.heavyImpact();
    _confettiController.play();

    // 1.5초 후 완료 처리
    Future.delayed(Duration(milliseconds: 1500), () {
      _showNextStepDialog(); // 완료 후 다이얼로그 표시
    });
  }

  void _showNextStepDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('여정 시작을 축하해요! 🎉'),
        content: Text('첫 번째 미션: 현재 체중을 기록해보세요'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onComplete(); // 실제 완료 처리
            },
            child: Text('기록하러 가기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Lottie.asset('assets/animations/journey_together.json', height: 150),
            Title('준비가 되셨나요?'),
            SummaryCard(
              name: widget.name,
              currentWeight: widget.currentWeight,
              targetWeight: widget.targetWeight,
              startDate: widget.startDate,
              medication: widget.medicationName,
              dose: widget.initialDose,
            ),
            Divider(),
            Text('더 건강한 내일을 향해\n함께 걸어가요', textAlign: TextAlign.center),
            Spacer(),
            // Swipe to Confirm
            ConfirmationSlider(
              height: 64,
              width: 300,
              backgroundColor: Colors.grey[200]!,
              foregroundColor: Color(0xFF4ADE80),
              text: '밀어서 여정 시작하기',
              onConfirmation: _onConfirmed,
            ),
            SizedBox(height: 32),
          ],
        ),
        // Confetti 효과
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: [
              Color(0xFF4ADE80),
              Color(0xFF22C55E),
              Color(0xFF86EFAC),
              Colors.white,
            ],
            emissionFrequency: 0.05,
            numberOfParticles: 30,
          ),
        ),
      ],
    );
  }
}
```

---

## Task 6: 마무리

### 6.1 스킵 로직

**조건**: `SharedPreferences.getBool('education_completed') == true`

**동작**: Part 1-2 (스크린 1-7) 스킵 → Part 3 (스크린 8)부터 시작

**UI**: 재방문 시 "이미 알고 계시다면 [건너뛰기]" 표시

### 6.2 상태 저장

```dart
// 온보딩 완료 시
await prefs.setBool('education_completed', true);
if (initialFoodNoiseLevel != null) {
  await prefs.setInt('initial_food_noise_level', initialFoodNoiseLevel);
}
```

### 6.3 Haptic Feedback 적용 위치

| 액션 | 피드백 타입 |
|-----|-----------|
| 버튼 탭 | `lightImpact()` |
| ExpansionTile 확장 | `lightImpact()` |
| 슬라이더 조작 | `selectionClick()` |
| 스와이프 완료 | `heavyImpact()` |
| 에러 발생 | `heavyImpact()` |

---

## 필요한 에셋

### Lottie 애니메이션 (assets/animations/)
- `welcome.json` - 환영 (문 여는 사람)
- `hormone_balance.json` - 호르몬 균형 (뇌)
- `food_noise.json` - Food Noise Before/After
- `journey_together.json` - 함께 걷는 모습

### 이미지 (assets/images/)
- `injection_abdomen.png` - 복부 주사 부위
- `injection_thigh.png` - 허벅지 주사 부위
- `injection_arm.png` - 팔 주사 부위

---

## 테스트 범위

1. 14스크린 네비게이션 정상 동작
2. 각 스크린 렌더링 (위젯 테스트)
3. 인터랙티브 요소 동작
   - Lottie + Slider 연동
   - ExpansionTile 게이미피케이션
   - Swipe to Confirm
   - Confetti 효과
4. 스킵 로직 동작
5. 온보딩 완료 시 데이터 저장
6. 완료 후 홈 화면 이동
