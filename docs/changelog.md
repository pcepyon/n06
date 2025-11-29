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

## 2025-11-30

- [feat] 부작용 기록에서 긴급 증상 체크 화면 자동 진입 기능 추가
  - 심각도 7-10점 + "24시간 이상 지속" = 예 선택 시 EmergencyCheckScreen으로 자동 이동
  - UF-F005 유저플로우 진입점 구현 완료
  - `lib/features/tracking/presentation/screens/daily_tracking_screen.dart`

- [refactor] 긴급 증상 체크 UI를 Design System 기준에 맞게 개선
  - Colors.white → AppColors.surface 토큰 사용
  - 커스텀 ElevatedButton → GabiumButton danger variant로 통일
  - `lib/features/tracking/presentation/widgets/emergency_checklist_item.dart`
  - `lib/features/tracking/presentation/widgets/consultation_recommendation_dialog.dart`

- [fix] 부작용 기록 저장 후 로그인이 풀리는 문제 수정
  - 존재하지 않는 `/dashboard` 경로 대신 `goNamed('home')` 사용
  - `lib/features/tracking/presentation/screens/daily_tracking_screen.dart`

- [fix] 기록 관리 삭제 다이얼로그가 자동으로 닫히지 않는 문제 수정
  - 삭제 버튼이 외부 context 대신 dialogContext를 전달하도록 수정
  - 체중/증상/투여 기록 삭제 버튼 3개 위치 모두 수정
  - `lib/features/record_management/presentation/screens/record_list_screen.dart`

- [fix] GabiumButton secondary/ghost variant 텍스트 색상 수정
  - secondary, tertiary, ghost 버튼의 텍스트가 흰색으로 표시되어 보이지 않던 문제 해결
  - variant별 텍스트 색상 분기 로직 추가 (primary/danger → 흰색, 나머지 → primary 색상)
  - `lib/features/authentication/presentation/widgets/gabium_button.dart`
  - `.claude/skills/ui-renewal/component-library/flutter/GabiumButton.dart`

- [fix] 투여 기록 다이얼로그 ParentDataWidget 오류 수정
  - AlertDialog.actions에서 Expanded 사용 시 OverflowBar와 타입 충돌 발생
  - AlertDialog → Dialog + Row + Expanded 패턴으로 전환
  - `lib/features/tracking/presentation/dialogs/dose_record_dialog_v2.dart`
  - `lib/features/tracking/presentation/dialogs/off_schedule_dose_dialog.dart`

- [feat] 일정 외 투여 기록 기능 추가
  - 예정 없는 날짜에도 투여 기록 가능 (가장 가까운 미완료 스케줄에 연결)
  - 조기/지연 투여 안내 메시지 및 48시간 간격 검증
  - `lib/features/tracking/presentation/dialogs/off_schedule_dose_dialog.dart`
  - `lib/features/tracking/presentation/widgets/selected_date_detail_card.dart`

- [feat] 캘린더 마커를 실제 투여일 기준으로 표시
  - 스케줄 예정일이 아닌 실제 투여일(administeredAt)에 완료 마커 표시
  - 원래 예정일 선택 시 "X월X일에 조기/지연 투여됨" 안내 표시
  - `lib/features/tracking/presentation/screens/dose_calendar_screen.dart`

## 2025-11-29

- [fix] 스낵바가 Dialog/BottomSheet에 가려지는 z-index 문제 해결
  - 전역 ScaffoldMessengerKey를 MaterialApp 레벨에 등록
  - GabiumToast에서 전역 키 우선 사용 (fallback 포함)
  - `lib/main.dart`
  - `lib/features/authentication/presentation/widgets/gabium_toast.dart`

- [test] GabiumToast 전역 ScaffoldMessengerKey 테스트 추가
  - `test/features/authentication/presentation/widgets/gabium_toast_test.dart`

- [fix] 온보딩 투여 계획 설정 - 약물 선택 시 에러 메시지 미초기화 버그 수정
  - 약물 선택 후 초기 용량이 자동 설정되어도 "약물을 선택해주세요" 에러 메시지가 남아있던 문제 해결
  - `features/onboarding/presentation/widgets/dosage_plan_form.dart`

- [fix] 위고비 용량 데이터 수정 - 7.2mg 제거
  - 한국 식약처 승인 기준 2.4mg이 최고 용량
  - 7.2mg은 STEP UP Trial 연구용량으로 실제 제품에 없음
  - `features/tracking/domain/entities/medication_template.dart`

- [fix] HowItWorksScreen ExpansionTile 빌드 중 setState 에러 해결
  - 근본 원인: PageStorageKey(Uncontrolled)와 onExpansionChanged+setState(Controlled) 혼합 사용
  - 수정: PageStorageKey 제거로 완전한 Controlled 패턴으로 전환
  - `features/onboarding/presentation/widgets/education/how_it_works_screen.dart`

- [test] HowItWorksScreen 위젯 테스트 추가
  - 초기 렌더링, ExpansionTile 확장/축소, 다음 버튼 활성화, 화면 재빌드 시나리오 검증
  - `test/features/onboarding/presentation/widgets/education/how_it_works_screen_test.dart`

- [feat] 온보딩 다시보기에서 목표 달성 시 진행 허용
  - 리뷰 모드에서 현재 체중 ≤ 목표 체중인 경우 축하 메시지 표시
  - 에러 대신 "🎉 목표를 달성하셨네요!" 안내 후 다음 단계 진행 가능
  - `features/onboarding/presentation/widgets/weight_goal_form.dart`

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

