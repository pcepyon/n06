# Phase 7: Onboarding

> 출처: docs/i18n-plan.md §5 Phase 7

## 개요

- **목적**: 온보딩 플로우 전체 i18n
- **선행 조건**: Phase 0, Phase 1 완료
- **문자열 수**: ~255개

---

## 작업 목록

| 작업 | 파일 | 문자열 수 |
|-----|------|---------:|
| 온보딩 메인 | `onboarding_screen.dart` | ~15 |
| 교육 화면들 | `welcome_screen.dart`, `not_your_fault_screen.dart`, `food_noise_screen.dart`, `how_it_works_screen.dart`, `side_effects_screen.dart`, `journey_roadmap_screen.dart` | ~120 |
| 준비 화면들 | `injection_guide_screen.dart`, `app_features_screen.dart`, `commitment_screen.dart` | ~60 |
| 입력 폼들 | `basic_profile_form.dart`, `weight_goal_form.dart`, `dosage_plan_form.dart` | ~40 |
| 요약 화면 | `summary_screen.dart`, `summary_card.dart` | ~20 |

---

## ARB 키 목록 (예상)

### 온보딩 메인

```json
{
  "onboarding_title": "시작하기",
  "onboarding_skipButton": "건너뛰기",
  "onboarding_nextButton": "다음",
  "onboarding_startButton": "시작하기"
}
```

### 환영 화면

```json
{
  "onboarding_welcome_title": "환영합니다",
  "onboarding_welcome_subtitle": "GLP-1 여정을 함께해요",
  "onboarding_welcome_description": "이 앱은 당신의 건강한 변화를 응원합니다"
}
```

### 교육: 당신 잘못이 아니에요

```json
{
  "onboarding_notYourFault_title": "당신 잘못이 아니에요",
  "onboarding_notYourFault_message1": "체중 관리가 어려웠던 건",
  "onboarding_notYourFault_message2": "의지력의 문제가 아닙니다",
  "onboarding_notYourFault_message3": "우리 몸의 호르몬과 신호 체계가 관여하기 때문이에요"
}
```

### 교육: Food Noise

```json
{
  "onboarding_foodNoise_title": "음식에 대한 생각이 줄어들어요",
  "onboarding_foodNoise_description": "GLP-1 약물은 뇌의 음식 보상 체계에 작용해서\n음식에 대한 집착을 줄여줍니다"
}
```

### 교육: 작동 원리

```json
{
  "onboarding_howItWorks_title": "어떻게 작동하나요?",
  "onboarding_howItWorks_point1": "포만감을 오래 유지시켜요",
  "onboarding_howItWorks_point2": "식욕을 자연스럽게 줄여요",
  "onboarding_howItWorks_point3": "혈당 조절을 도와요"
}
```

### 교육: 부작용

```json
{
  "onboarding_sideEffects_title": "알아두면 좋은 것들",
  "onboarding_sideEffects_common": "흔한 증상들",
  "onboarding_sideEffects_nausea": "메스꺼움 - 보통 시간이 지나면 나아져요",
  "onboarding_sideEffects_constipation": "변비 - 물을 충분히 드세요",
  "onboarding_sideEffects_fatigue": "피로감 - 몸이 적응하는 중이에요"
}
```

### 준비: 주사 가이드

```json
{
  "onboarding_injectionGuide_title": "주사 방법",
  "onboarding_injectionGuide_step1": "주사 부위를 알코올 솜으로 닦아주세요",
  "onboarding_injectionGuide_step2": "펜을 피부에 90도로 대주세요",
  "onboarding_injectionGuide_step3": "버튼을 누르고 10초간 유지해주세요"
}
```

### 입력 폼: 기본 프로필

```json
{
  "onboarding_profile_title": "프로필 설정",
  "onboarding_profile_nickname": "닉네임",
  "onboarding_profile_birthYear": "출생연도",
  "onboarding_profile_gender": "성별",
  "onboarding_profile_height": "키",
  "onboarding_profile_currentWeight": "현재 체중"
}
```

### 입력 폼: 체중 목표

```json
{
  "onboarding_weightGoal_title": "목표 설정",
  "onboarding_weightGoal_targetWeight": "목표 체중",
  "onboarding_weightGoal_suggestion": "건강한 감량 속도는 주당 0.5-1kg이에요"
}
```

### 입력 폼: 투약 계획

```json
{
  "onboarding_dosagePlan_title": "투약 계획",
  "onboarding_dosagePlan_startDate": "시작일",
  "onboarding_dosagePlan_initialDose": "시작 용량",
  "onboarding_dosagePlan_targetDose": "목표 용량",
  "onboarding_dosagePlan_frequency": "투약 주기",
  "onboarding_dosagePlan_frequency_weekly": "주 1회"
}
```

### 요약 화면

```json
{
  "onboarding_summary_title": "설정 완료!",
  "onboarding_summary_profile": "프로필",
  "onboarding_summary_goal": "목표",
  "onboarding_summary_plan": "투약 계획",
  "onboarding_summary_startButton": "여정 시작하기"
}
```

---

## 대상 파일 (경로 확인 필요)

```
lib/features/onboarding/presentation/
├── screens/
│   ├── onboarding_screen.dart
│   ├── welcome_screen.dart
│   ├── not_your_fault_screen.dart
│   ├── food_noise_screen.dart
│   ├── how_it_works_screen.dart
│   ├── side_effects_screen.dart
│   ├── journey_roadmap_screen.dart
│   ├── injection_guide_screen.dart
│   ├── app_features_screen.dart
│   ├── commitment_screen.dart
│   └── summary_screen.dart
├── widgets/
│   ├── basic_profile_form.dart
│   ├── weight_goal_form.dart
│   ├── dosage_plan_form.dart
│   └── summary_card.dart
```

---

## 완료 기준

```
[ ] 온보딩 메인 문자열 ARB 추가 (ko, en)
[ ] 교육 화면 6개 문자열 ARB 추가 (ko, en)
[ ] 준비 화면 3개 문자열 ARB 추가 (ko, en)
[ ] 입력 폼 3개 문자열 ARB 추가 (ko, en)
[ ] 요약 화면 문자열 ARB 추가 (ko, en)
[ ] 모든 사용처 context.l10n으로 변경
[ ] 빌드 성공
```
