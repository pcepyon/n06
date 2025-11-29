# Changelog

## Writing Rules

1. **Newest entries at top** (reverse chronological order)
2. **Date format**: `## YYYY-MM-DD`
3. **Type tags**: `[feat]`, `[fix]`, `[refactor]`, `[docs]`, `[test]`, `[chore]`
4. **One-line summary**: What changed and why, keep it concise
5. **Related files**: Key file paths (optional)

### Example
```
## 2025-01-15

- [feat] Add user profile edit feature
  - `features/profile/presentation/screens/profile_edit_screen.dart`
- [fix] Handle auto-logout on token expiration
```

---

## 2025-11-29

- [feat] 설정에서 온보딩 다시 보기 기능 추가
  - 기존 사용자가 교육 콘텐츠를 언제든 다시 볼 수 있음
  - 리뷰 모드: 기존 데이터 표시, 수정 가능하나 DB 저장 안 함
  - `features/settings/presentation/screens/settings_screen.dart`
  - `features/onboarding/presentation/screens/onboarding_screen.dart`
  - `core/routing/app_router.dart`

- [feat] 14스크린 인터랙티브 교육 온보딩 플로우 신규 구현
  - PART 1 (공감과 희망): WelcomeScreen, NotYourFaultScreen, EvidenceScreen
  - PART 2 (이해와 확신): FoodNoiseScreen, HowItWorksScreen, JourneyRoadmapScreen, SideEffectsScreen
  - PART 3 (설정): BasicProfileForm/WeightGoalForm/SummaryScreen 톤 개선
  - PART 4 (준비와 시작): InjectionGuideScreen, AppFeaturesScreen, CommitmentScreen
  - `features/onboarding/presentation/widgets/education/*.dart`
  - `features/onboarding/presentation/widgets/preparation/*.dart`
  - `features/onboarding/presentation/widgets/common/*.dart`
  - `features/onboarding/presentation/screens/onboarding_screen.dart`
- [feat] JourneyProgressIndicator 위젯 추가 (4단계 여정 맵 스타일)
- [feat] OnboardingPageTemplate 공통 레이아웃 추가
- [feat] 의존성 추가: lottie, confetti, animated_flip_counter, slide_to_confirm, smooth_page_indicator

- [docs] 교육 온보딩 구현 문서 라이브러리 구문 검증 및 수정
  - `docs/017-education-onboarding/plan.md` - Flutter 구문 오류 수정, 커스텀 위젯 정의 추가
  - `docs/017-education-onboarding/implementation-plan.md` - Task 기반 병렬 구현 전략 신규 추가
- [docs] CLAUDE.md 간소화 및 문서 메타데이터 시스템 추가
  - 407줄 → 125줄 (70% 감소)
  - `docs/INDEX.md` 생성, 핵심 문서 8개에 Frontmatter 추가
- [docs] 커밋 프로세스에 changelog 단계 통합
  - `claude.md`

