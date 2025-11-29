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

- [refactor] Phase F 마이그레이션 - 하드코딩 스타일을 Theme 시스템으로 전환
  - 75개 파일에서 Color/TextStyle 하드코딩 제거
  - AppColors, AppTypography, AppTheme 신규 추가
  - withOpacity() → withValues(alpha:) deprecated 해결
  - Batch 1-2: Core 위젯 및 Authentication (16개)
  - Batch 3: Dashboard (7개)
  - Batch 4: Tracking (15개)
  - Batch 5: Onboarding (18개)
  - Batch 6: Settings & Profile (9개)
  - Batch 7: Coping Guide (5개)
  - Batch 8: Data Sharing & Record (5개)
  - `lib/core/presentation/theme/app_colors.dart`
  - `lib/core/presentation/theme/app_typography.dart`
  - `lib/core/presentation/theme/app_theme.dart`

- [fix] 온보딩 첫 사용자 정보 입력 안정성 개선
  - DosagePlanForm: 선택 시점에 즉시 부모에게 데이터 전달
  - userId 빈 문자열 방지 (authProvider 폴백)
  - 체중 0 이하 값 입력 방지
  - Layer 위반 수정: Repository 직접 접근 → Application 계층 통해 접근
  - `features/onboarding/application/notifiers/onboarding_notifier.dart`
  - `features/onboarding/presentation/screens/onboarding_screen.dart`
  - `features/onboarding/presentation/widgets/dosage_plan_form.dart`
  - `features/onboarding/presentation/widgets/weight_goal_form.dart`

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

