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

## 2025-12-10

- [fix] F021 암호화 서비스 initialize() 누락 버그 수정 (10개 메서드)
  - **문제**: 일부 Repository 메서드에서 `_encryptionService.initialize(userId)` 호출 누락으로 EncryptionException 발생 가능
  - **수정된 메서드**:
    - `MedicationRepository`: getRecentDoseRecords, updateDoseRecord, getActiveDosagePlan, saveDosagePlan, updateDosagePlan, getDosagePlan, watchDoseRecords, watchActiveDosagePlan
    - `DailyCheckinRepository`: getByDateRange
    - `ProfileRepository`: watchUserProfile
  - `lib/features/tracking/infrastructure/repositories/supabase_medication_repository.dart`
  - `lib/features/daily_checkin/infrastructure/repositories/supabase_daily_checkin_repository.dart`
  - `lib/features/onboarding/infrastructure/repositories/supabase_profile_repository.dart`

- [feat] F021 Option A: 암호화 키 서버 저장 방식으로 변경 (다중 기기 지원)
  - **목적**: 암호화 키를 Supabase에 저장하여 다른 기기에서 로그인 시에도 암호화된 데이터 접근 가능
  - **변경사항**:
    - `user_encryption_keys` 테이블 생성 (RLS 정책: 본인 키만 접근)
    - `EncryptionService.initialize()` 시그니처 변경: `initialize(String userId)` (사용자별 키 관리)
    - `AesEncryptionService`: flutter_secure_storage → Supabase 테이블로 키 저장 위치 변경
    - Repository 메서드들에 `await _encryptionService.initialize(userId)` 호출 추가
    - main.dart: 전역 초기화 제거 (사용자 로그인 후 Repository에서 초기화)
  - **보안**: 통신은 HTTPS 암호화, RLS로 타 사용자 키 접근 차단
  - **마이그레이션**: `supabase/migrations/11_user_encryption_keys.sql`
  - `lib/core/encryption/domain/encryption_service.dart`
  - `lib/core/encryption/infrastructure/aes_encryption_service.dart`
  - `lib/core/encryption/application/providers.dart`
  - `lib/main.dart`
  - `lib/features/tracking/infrastructure/repositories/supabase_tracking_repository.dart`
  - `lib/features/tracking/infrastructure/repositories/supabase_medication_repository.dart`
  - `lib/features/daily_checkin/infrastructure/repositories/supabase_daily_checkin_repository.dart`
  - `lib/features/onboarding/infrastructure/repositories/supabase_profile_repository.dart`

- [feat] 데일리 체크인 페이지 전환 애니메이션 추가
  - **페이드 인 애니메이션**: 모든 페이지 전환 시 300ms easeInOut 애니메이션 적용
  - **적용 범위**: 체중 입력, 메인 질문(Q1-Q6), 파생 질문, 완료 화면 모든 전환
  - **상태 변화 감지**: 스텝/파생경로/완료상태 변경 시 자동 트리거
  - `lib/features/daily_checkin/presentation/screens/daily_checkin_screen.dart`

- [refactor] 온보딩 다시보기 기능 제거
  - **설정 화면**: "온보딩 다시보기" 메뉴 항목 삭제 (앱 소개 다시보기는 유지)
  - **라우터**: `/onboarding/review` 경로 삭제
  - **온보딩 위젯**: `isReviewMode` 파라미터 및 관련 로직 제거 (OnboardingScreen, BasicProfileForm, WeightGoalForm, DosagePlanForm, SummaryScreen)
  - **l10n**: `settings_menu_onboardingReview`, `settings_menu_onboardingReviewSubtitle` 키 삭제
  - `lib/features/settings/presentation/screens/settings_screen.dart`
  - `lib/core/routing/app_router.dart`
  - `lib/features/onboarding/presentation/screens/onboarding_screen.dart`
  - `lib/features/onboarding/presentation/widgets/*.dart`

## 2025-12-09

- [fix] CTA 체크리스트 섹션 인덱스 및 네비게이션 버그 수정
  - **섹션 인덱스 수정**: evidence(0→2), journey(1→5), sideEffects(3→6) 올바른 페이지 매핑
  - **"확인하러 가기" 버튼 추가**: 기존 비활성 "스크롤하여 확인" → 클릭 시 해당 섹션으로 이동
  - `lib/features/guest_home/presentation/widgets/cta_checklist.dart`
  - `lib/features/guest_home/presentation/widgets/cta_section.dart`
  - `lib/features/guest_home/presentation/screens/guest_home_screen.dart`

- [fix] 게스트홈 데모 UX 개선 및 버그 수정
  - **DailyCheckinDemo 크래시 수정**: SingleChildScrollView 내 Spacer() 사용으로 인한 unbounded height 에러 해결
  - **전환 애니메이션 추가**: 질문 간 FadeTransition으로 부드러운 전환, 진행률 표시, 완료 화면 추가
  - **의료진 공유하기 데모 분리**: "진료실에서 말문이 막혀도" 기능에 ShareReportDemo 연결 (기존 TrendReportDemo에서 분리)
  - `lib/features/guest_home/presentation/widgets/demo/daily_checkin_demo.dart`
  - `lib/features/guest_home/presentation/widgets/demo/share_report_demo.dart` (신규)
  - `lib/features/guest_home/presentation/widgets/app_features_section.dart`

- [feat] 게스트 체험 통합 시스템 구현
  - **게스트홈 확장 (6→10섹션)**: 당신탓아니에요, Food Noise, 작동원리, 주사가이드 추가
  - **체험 기능**: 6개 데모 위젯으로 비로그인 앱 체험 제공 (데이터 저장 없음)
  - **온보딩 축소 (14→5스크린)**: 교육 콘텐츠를 게스트홈으로 이동, 개인화 설정만 유지
  - **스타일 통일**: 온보딩에 게스트홈 스타일 적용 (도트 네비게이션, Scale+Fade 전환, Confetti)
  - `lib/features/guest_home/presentation/widgets/demo/` (7개 파일)
  - `lib/features/guest_home/presentation/widgets/*_section.dart` (4개 신규)
  - `lib/features/onboarding/presentation/screens/onboarding_screen.dart`

- [fix] 파생 질문 피드백 표시 중 화면 전환 타이밍 버그 수정
  - **중간 파생 질문**: 피드백이 현재 질문이 아닌 다음 질문 화면에서 표시되던 문제 해결
  - **마지막 파생 질문**: 피드백 표시 중 즉시 다음 메인 질문으로 전환되고, 피드백 닫히면 선택 없이 건너뛰던 문제 해결
  - `pendingMainStep` 필드 추가하여 마지막 파생 질문 피드백 후 이동할 메인 스텝 저장
  - `lib/features/daily_checkin/application/notifiers/daily_checkin_notifier.dart`

## 2025-12-08

- [fix] streak 뱃지 설명을 '투여'에서 '기록'으로 수정
  - GLP-1 주사는 주 1회 투여이므로 "연속 투여" 표현 부적절
  - "7일/30일 연속" → "7일/30일 연속 기록", "투여 완료" → "기록했어요"
  - `lib/l10n/app_ko.arb`, `lib/l10n/app_en.arb`

- [fix] 대시보드 위젯 레이아웃 및 격려 메시지 버그 수정
  - **주간 요약 위젯 오버플로우**: Row에 Expanded 적용, 텍스트 overflow 처리
  - **아이콘 정렬**: crossAxisAlignment.start로 상단 정렬 통일
  - **격려 메시지 SSOT**: extension 호출 수정으로 실제 연속 기록일 표시
  - `lib/features/dashboard/presentation/widgets/celebratory_report_widget.dart`
  - `lib/features/dashboard/presentation/widgets/emotional_greeting_widget.dart`

- [fix] 주간 요약 증상 표시 수정 - 날짜 기준에서 개수 기준으로 변경
  - **라벨 변경**: "적응기" → "증상" (Adaptation → Symptoms)
  - **메시지 수정**: 모든 메시지에 실제 증상 개수(count) 표시
  - `lib/features/dashboard/presentation/widgets/celebratory_report_widget.dart`
  - `lib/l10n/app_ko.arb`, `lib/l10n/app_en.arb`

- [fix] 성취 뱃지 위젯 '목표 확인하기' 버튼 기능 구현
  - **빈 상태 버튼**: 클릭 시 달성 가능한 7개 뱃지 목표를 바텀시트로 표시
  - **주간 요약 수정**: 증상 개수 계산 시 체크인 데이터 연결
  - `lib/features/dashboard/presentation/widgets/celebratory_badge_widget.dart`
  - `lib/features/dashboard/application/notifiers/dashboard_notifier.dart`

- [fix] 대시보드 위젯 로직 검증 및 SSOT 통합 수정
  - **뱃지 시스템**: badge_definitions 시드 데이터 추가, first_dose 상수 SSOT 이동
  - **체중 마일스톤**: 절대 감량률(5%,10%) → 목표 진행률(25%,50%,75%,100%)로 단순화
  - **순응도 계산**: 하드코딩 85% → 실제 계산 (실제투여/예상투여*100)
  - **날짜 계산**: 6개 파일에서 시간 제외, 날짜만 비교하도록 수정
  - `supabase/migrations/09_seed_badge_definitions.sql` (신규)
  - `lib/core/constants/badge_constants.dart`
  - `lib/core/constants/weight_constants.dart`
  - `lib/features/dashboard/application/notifiers/dashboard_notifier.dart`
  - `lib/features/tracking/domain/entities/dose_record.dart`

- [feat] 치료 여정 위젯 높이 제한 및 상세 화면 추가
  - **대시보드**: 최근 4개 이벤트만 표시, "N개 더보기" 버튼 추가
  - **상세 화면**: `/journey-detail` 경로로 전체 타임라인 확인 가능
  - **정렬 순서 수정**: 오름차순 → 내림차순 (최신 이벤트 상단 표시)
  - `lib/features/dashboard/presentation/widgets/journey_timeline_widget.dart`
  - `lib/features/dashboard/presentation/screens/journey_detail_screen.dart`
  - `lib/features/dashboard/application/notifiers/dashboard_notifier.dart`

- [feat] AI 메시지 상황별 프롬프트 분기 추가
  - **6가지 특수 상황 감지**: 첫 시작, 증량 직후, 오랜만에 복귀, 체중 정체기, 장기 사용자, 기록률 저조
  - **동적 User Prompt**: 상황별 맞춤 지침 자동 추가
  - `supabase/functions/generate-ai-message/index.ts`

- [fix] 다음 투여일 계산 로직 수정
  - **기존**: 무조건 내일로 하드코딩
  - **수정**: 마지막 투여일 + cycleDays로 실제 계산
  - **추가**: nextDoseMg도 현재 용량으로 계산
  - `lib/features/dashboard/application/notifiers/dashboard_notifier.dart`

- [refactor] AI 메시지 프롬프트 전면 개선
  - **모델 변경**: google/gemma-3n → openai/gpt-4o-mini
  - **핵심 변경**: 일반적 격려 → 구체적 상황에 반응
  - **우선순위 기반 컨텍스트**: 체크인 > 투여일정 > 여정정보
  - **메시지 구조**: [상황 인식] + [공감/조언] + [격려로 마무리]
  - **Few-shot 예시 추가**: 좋은 예시 / 나쁜 예시 명시
  - **체크인 반응 유도**: 속 불편, 피곤, 우울 등에 공감
  - `supabase/functions/generate-ai-message/index.ts`

- [feat] 치료 여정 타임라인 이벤트 확장 - 5개 신규 이벤트 타입 추가
  - **연속 체크인 마일스톤**: 3, 7, 14, 21, 30, 60, 90일 달성 표시 (Gold)
  - **뱃지 달성**: UserBadge.achievedAt 기반 이벤트 (Gold)
  - **첫 기록 이벤트**: 첫 체크인, 첫 체중 기록, 첫 투여 (Purple/Green)
  - **용량 변경**: 새로운 용량 첫 투여 시 표시 (Blue)
  - 디자인 시스템 Feature Color 적용 (Achievement, History, Primary, Info)
  - `lib/features/dashboard/domain/entities/timeline_event.dart`
  - `lib/features/dashboard/application/notifiers/dashboard_notifier.dart`
  - `lib/features/dashboard/presentation/widgets/journey_timeline_widget.dart`

- [refactor] 대시보드 위젯 구조 개편 및 미사용 위젯 삭제
  - **위젯 순서 재배치**: EmotionalGreeting → CelebratoryReport → HopefulSchedule → JourneyTimeline → AIMessage → CelebratoryBadge
  - **삭제된 위젯** (3개):
    - `GreetingSection` - 간소화된 인사 위젯
    - `StatusSummarySection` - 상태 요약 위젯
    - `EncouragingProgressWidget` - 진행률 위젯
  - `lib/features/dashboard/presentation/screens/home_dashboard_screen.dart`

## 2025-12-07

- [fix] AI 메시지 체크인 후 재생성 및 네비게이션 복귀 시 미표시 버그 수정
  - **문제 1**: 데일리 체크인 완료 후 AI 메시지가 재생성되지 않음
    - **원인**: autoDispose provider가 화면 전환 시 dispose되어 regenerateForCheckin 호출 실패
    - **해결**: `@Riverpod(keepAlive: true)` 적용하여 provider 유지
  - **문제 2**: 다른 페이지 갔다가 홈 버튼으로 복귀 시 메시지 영역 비어있음
    - **원인**: AIMessageSection의 `_showMessage`가 initState에서 초기화되지 않음
    - **해결**: initState에서 로딩 상태가 아니면 `_showMessage = true` 설정
  - `lib/features/dashboard/application/notifiers/ai_message_notifier.dart`
  - `lib/features/dashboard/presentation/widgets/ai_message_section.dart`

- [fix] StatusSummarySection 컨디션 요약 위젯 미표시 버그 수정
  - **원인**: `authNotifierProvider`를 별도 watch하여 타이밍 이슈 발생, userId가 null이면 위젯 미렌더링
  - **해결**: `DashboardData`에 `userId` 필드 추가, 이미 검증된 userId 사용
  - `lib/features/dashboard/domain/entities/dashboard_data.dart`
  - `lib/features/dashboard/application/notifiers/dashboard_notifier.dart`
  - `lib/features/dashboard/presentation/widgets/status_summary_section.dart`

- [feat] 대시보드 Emotion-Driven 개선 - 3섹션 구조 + LLM 공감 메시지 생성
  - **목표**: "정보 나열"에서 "맥락 인식 감정 지지"로 전환
  - **3섹션 UI 구조**:
    - GreetingSection: 시간대별 인사 + 이름 + 연속기록일
    - StatusSummarySection: 주차/진행률/다음투여/체중/컨디션
    - AIMessageSection: LLM 생성 공감 메시지 + 스켈레톤 UI + fade-in 애니메이션
  - **AI 메시지 저장소**: ai_generated_messages 테이블, Repository 패턴
  - **LLM 컨텍스트**: UserContext, HealthData, 최근 7개 메시지 (톤 일관성)
  - **Edge Function**: OpenRouter API 연동 (gpt-oss-20b:free), Fallback 로직
  - **생성 타이밍**: 하루 첫 접속 + 데일리 체크인 완료 시 재생성
  - **DBT 검증 원칙**: 판단하지 않음, 감정 먼저, 정상화, 해결책 강요 금지
  - `lib/features/dashboard/domain/entities/ai_generated_message.dart`
  - `lib/features/dashboard/domain/entities/llm_context.dart`
  - `lib/features/dashboard/application/notifiers/ai_message_notifier.dart`
  - `lib/features/dashboard/application/services/llm_context_builder.dart`
  - `lib/features/dashboard/presentation/widgets/greeting_section.dart`
  - `lib/features/dashboard/presentation/widgets/status_summary_section.dart`
  - `lib/features/dashboard/presentation/widgets/ai_message_section.dart`
  - `supabase/functions/generate-ai-message/index.ts`
  - `supabase/migrations/08_create_ai_generated_messages.sql`

## 2025-12-05

- [feat] 로그인 사용자 대상 '앱 소개 다시보기' 기능 추가
  - 설정 화면에서 게스트 홈 콘텐츠를 다시 볼 수 있도록 preview 모드 구현
  - 쿼리 파라미터 방식으로 기존 라우팅 로직에 영향 없이 구현
  - `lib/core/routing/app_router.dart`
  - `lib/features/settings/presentation/screens/settings_screen.dart`

- [fix] 게스트 홈 텍스트 펼침/닫힘 시 RenderFlex overflow 수정
  - **원인**: IntrinsicHeight + AnimatedCrossFade 조합에서 높이 계산 충돌
  - **수정**: IntrinsicHeight 제거, AnimatedCrossFade → AnimatedSize 교체
  - `lib/features/guest_home/presentation/widgets/journey_preview_section.dart`
  - `lib/features/guest_home/presentation/widgets/side_effects_guide_section.dart`

- [feat] 게스트 홈 인터랙티브 UX 개선 - Progress Bar, 스크롤 기반 애니메이션, CTA 체크박스
  - **Progress Bar + 섹션 네비게이션**: 상단 고정, 스크롤 진행률 표시, 탭하여 섹션 이동
  - **스크롤 기반 애니메이션**: 섹션 진입 시 fade-in + slide-up, 숫자 카운팅 트리거
  - **CTA 체크박스 커밋먼트**: 섹션 방문 시 체크 가능, 완료 시 버튼 강조
  - **방문 섹션 추적**: Progress Bar에 체크 아이콘 표시
  - `lib/features/guest_home/presentation/screens/guest_home_screen.dart`
  - `lib/features/guest_home/presentation/widgets/section_progress_indicator.dart` (신규)
  - `lib/features/guest_home/presentation/widgets/cta_checklist.dart` (신규)
  - `lib/features/guest_home/presentation/widgets/cta_section.dart`
  - `lib/features/guest_home/presentation/widgets/scientific_evidence_section.dart`
  - `lib/features/guest_home/presentation/widgets/journey_preview_section.dart`
  - `lib/features/guest_home/presentation/widgets/app_features_section.dart`
  - `lib/features/guest_home/presentation/widgets/side_effects_guide_section.dart`

- [refactor] 전체 Notifier에 Riverpod AsyncNotifier 안전 패턴 적용
  - **범위**: 11개 Notifier 파일
  - **수정**: getter → late final 필드로 의존성 캡처, AsyncValue.guard 내부 ref.read 제거
  - **핵심 수정**: `daily_checkin_notifier.dart`의 getter 패턴 제거
  - 파일 목록: `notification_notifier`, `profile_notifier`, `onboarding_notifier`, `tracking_notifier`, `trend_insight_notifier`, `daily_checkin_notifier`, `dose_record_edit_notifier`, `weight_record_edit_notifier`, `coping_guide_notifier`, `auth_notifier`

- [fix] MedicationProvider "Cannot use Ref after disposed" 에러 수정
  - **원인**: getter로 ref.read() 호출 시 async 작업 중 disposed ref 접근
  - **수정**: build()에서 late final 필드로 의존성 캡처 패턴 적용
  - **문서**: CLAUDE.md에 5단계 AsyncNotifier 안전 패턴 추가
  - `lib/features/tracking/application/notifiers/medication_notifier.dart`
  - `claude.md`

- [fix] EvidenceCard Column overflow 수정 및 CLAUDE.md 레이아웃 규칙 통합
  - **문제**: SizedBox(height: 480) 내 Column이 39픽셀 overflow
  - **수정**: SingleChildScrollView로 감싸서 스크롤 가능하게 변경
  - **문서 개선**: 4개 개별 레이아웃 버그 규칙을 "Flutter 레이아웃 제약 조건" 섹션으로 통합
  - `lib/features/guest_home/presentation/widgets/evidence_card.dart`
  - `claude.md`

- [refactor] Medication 엔티티 개선 및 SQL 뷰 호환성 수정
  - **Medication.startDose**: 빈 availableDoses 배열 방어 코드 추가 (0.0 반환)
  - **Medication.findByDisplayName**: static 헬퍼 메서드 추가로 fallback 로직 통일
  - **v_weekly_weight_summary**: PostgreSQL GROUP BY 호환성 수정 (윈도우 함수 사용)
  - `lib/features/tracking/domain/entities/medication.dart`
  - `supabase/migrations/07_add_master_tables.sql`

- [feat] Guest Home 비로그인 홈 화면 구현 (앱 스토어 심사 대응)
  - **목적**: 로그인 없이 GLP-1 치료 정보와 앱 가치를 전달하여 회원가입 유도
  - **6개 섹션**: 환영, 과학적 근거(5개 카드), 12주 치료 여정, 앱 기능(5개), 부작용 가이드(4개 증상), CTA
  - **P0 인터랙션**: Sequential Text Reveal, Number Counting, Progressive Disclosure Timeline, Expandable Cards, Staggered Entry, Pulsing CTA, Press State with Depth, Milestone Celebration
  - **P1 인터랙션**: Card Stack Effect, Scroll-Triggered CTA Reveal, Symptom Severity Progress Bar
  - **라우팅 변경**: 초기 경로 `/login` → `/guest`, 비인증 시 `/guest`로 리다이렉트
  - `docs/018-guest-home/spec.md`
  - `lib/features/guest_home/` (13개 파일)

- [feat] DB 확장성 준비: medications, symptom_types 마스터 테이블 및 분석 뷰 추가
  - **목적**: 앱 배포 없이 새 약물/증상 추가 가능하도록 마스터 테이블 도입
  - **DB 변경**:
    - `medications` 테이블: GLP-1 약물 5종 (위고비, 오젬픽, 마운자로, 젭바운드, 삭센다)
    - `symptom_types` 테이블: 기본 증상 13종 + Red Flag 6종
    - 분석 뷰 3개: v_weekly_weight_summary, v_weekly_checkin_summary, v_monthly_dose_adherence
  - **Flutter 변경**:
    - `MedicationTemplate` (하드코딩) → `Medication` 엔티티 + DB 조회로 전환
    - MedicationMasterRepository, DTO, Provider 추가
    - 온보딩/투여계획 수정 화면에서 DB 약물 목록 사용
  - `supabase/migrations/07_add_master_tables.sql`
  - `lib/features/tracking/domain/entities/medication.dart`
  - `lib/features/tracking/domain/repositories/medication_master_repository.dart`
  - `lib/features/tracking/infrastructure/repositories/supabase_medication_master_repository.dart`

- [feat] GoRouter에 FirebaseAnalyticsObserver 추가하여 화면 추적 활성화
  - `lib/core/routing/app_router.dart`

- [fix] BUG-20251205: 세션 만료 시 무한 로딩 및 오프라인 에러 수정
  - **문제**: 만료된 세션으로 앱 재시작 시 무한 로딩, 오프라인에서 Uncaught error
  - **원인**: GoRouter와 AuthNotifier 인증 상태 불일치, SDK의 자동 세션 복구 에러
  - **수정 내용**:
    - `_isSessionExpired()` 헬퍼 함수 추가 (expiresAt null 시 유효로 간주)
    - GoRouter redirect에서 정확한 세션 만료 체크
    - AuthNotifier에서 signOut() 호출 제거 (오프라인 에러 방지)
    - main.dart에서 Supabase 네트워크 에러 무시 처리
  - `lib/core/routing/app_router.dart`
  - `lib/features/authentication/application/notifiers/auth_notifier.dart`
  - `lib/features/authentication/infrastructure/repositories/supabase_auth_repository.dart`
  - `lib/main.dart`

## 2025-12-04

- [feat] Firebase Analytics 및 Crashlytics 모니터링 활성화
  - firebase_core, firebase_analytics, firebase_crashlytics 패키지 활성화
  - FlutterFire CLI로 Firebase 프로젝트 연동
  - AnalyticsService 클래스 생성 (화면 조회, 이벤트 로깅, 에러 리포팅)
  - `lib/main.dart`, `lib/core/services/analytics_service.dart`

- [feat] 다국어 지원 (i18n) 인프라 구축 및 전체 기능 적용
  - **인프라 (Phase 0-4)**
    - flutter_localizations, intl 패키지 추가
    - l10n.yaml 설정 및 ARB 파일 구조 생성 (한국어/영어)
    - L10n extension (context.l10n) 헬퍼 구현
    - 언어 설정 Provider 및 설정 화면 UI 구현
  - **Application Layer 리팩토링**
    - 하드코딩 문자열 → enum 기반 타입 시스템 전환
    - 31개 Domain enum 타입 정의 (FeedbackType, RedFlagType, GreetingMessageType 등)
    - 15개 Presentation 매핑 헬퍼 생성
    - 레이어 분리 원칙 준수 (Application에서 l10n 완전 제거)
  - **Feature별 i18n 적용**
    - daily_checkin: 220+ 키 (질문, 피드백, 리포트)
    - tracking: 116 키 (투약, 달력, 트렌드)
    - onboarding: 177 키 (14개 화면)
    - coping_guide: 83 키 (부작용 대처법)
    - notification: 12 키 (알림 설정)
    - records: 46 키 (기록 관리)
  - **의료 콘텐츠 관리**
    - MEDICAL REVIEW REQUIRED 태그 506개 적용
    - 증상명, 부작용, 주사 가이드 등 전문가 검토 필요 항목 표시
  - **통계**: ARB 키 1,317개, context.l10n 855회 사용
  - `l10n.yaml`, `lib/l10n/app_ko.arb`, `lib/l10n/app_en.arb`
  - `lib/core/extensions/l10n_extension.dart`
  - `lib/features/*/domain/entities/*_type.dart` (31개)
  - `lib/features/*/presentation/utils/*_l10n.dart` (15개)
  - `docs/i18n/` (가이드 문서)

## 2025-12-03

- [docs] 앱스토어 제출용 법적 문서 추가 및 앱 내 연동
  - 개인정보 처리방침, 이용약관, 건강정보 면책조항 문서 작성
  - 설정 화면에 "약관 및 정책" 섹션 추가 (외부 URL 연결)
  - 회원가입 화면 동의 체크박스에 "보기" 버튼 추가
  - `docs/legal/privacy-policy.md`, `terms-of-service.md`, `medical-disclaimer.md`
  - `lib/core/constants/legal_urls.dart`
  - `lib/features/settings/presentation/screens/settings_screen.dart`
  - `lib/features/authentication/presentation/widgets/consent_checkbox.dart`

- [fix] 과거 날짜 기록 로직 개선
  - 과거 날짜 선택 시 연체 제한 해제 (항상 기록 가능)
  - "과거 기록" 배지 + 안내 메시지 표시
  - 스케줄 연결 시 같은 거리면 과거 스케줄 우선

- [fix] 과거 기록 입력 모드 버그 수정
  - 5일 이상 경과 스케줄에서도 기록 가능하도록 수정
  - 주사 부위 이력을 선택 날짜 기준으로 계산
  - 장기 부재 판단 로직: 마지막 투여 기준 → 가장 오래된 미완료 스케줄 기준
  - `lib/features/tracking/presentation/widgets/injection_site_selector_v2.dart`

- [feat] 장기 부재 시 과거 기록 입력 모드 추가
  - 장기 부재 카드에 "과거 기록 입력하기" 버튼 추가
  - 과거 기록 입력 모드에서 장기 부재 체크 스킵
  - 상단 배너 UI로 모드 표시 및 종료 버튼
  - `lib/features/tracking/presentation/screens/dose_calendar_screen.dart`
  - `lib/features/tracking/presentation/widgets/selected_date_detail_card.dart`

- [feat] 계정 삭제 기능 구현 (Apple/Google 정책 준수)
  - Supabase Edge Function으로 auth.admin.deleteUser 호출
  - Flutter: AuthRepository, AuthNotifier에 deleteAccount() 추가
  - 2단계 확인 다이얼로그: 삭제 데이터 목록 + 동의 체크박스
  - 설정 화면에 계정 삭제 버튼 추가
  - `supabase/functions/delete-account/index.ts`
  - `lib/features/authentication/domain/repositories/auth_repository.dart`
  - `lib/features/authentication/infrastructure/repositories/supabase_auth_repository.dart`
  - `lib/features/authentication/application/notifiers/auth_notifier.dart`
  - `lib/features/authentication/presentation/widgets/delete_account_confirm_dialog.dart`
  - `lib/features/settings/presentation/screens/settings_screen.dart`

- [fix] 체중 기록 수정/삭제 후 목록 UI 갱신 누락 수정
  - updateWeight, deleteWeight에서 trackingProvider invalidate 추가
  - `lib/features/tracking/application/notifiers/weight_record_edit_notifier.dart`

- [fix] AuditLogDto 컬럼명을 DB 스키마에 맞게 수정
  - record_id→entity_id, record_type→entity_type, change_type→action, old_value→old_data, new_value→new_data
  - `lib/features/tracking/infrastructure/dtos/audit_log_dto.dart`

- [fix] 투여 기록 삭제 후 목록 UI가 즉시 갱신되지 않는 버그 수정
  - 삭제/수정 후 medicationNotifierProvider invalidate 추가
  - `lib/features/tracking/application/notifiers/dose_record_edit_notifier.dart`

- [fix] 데일리 체크인 중복 다이얼로그 "나가기" 버튼 GoError 수정
  - "오늘 이미 기록했어요" 팝업에서 나가기 시 "There is nothing to pop" 에러 해결
  - ShellRoute 내부이므로 context.pop() 대신 context.go('/home') 사용
  - `lib/features/daily_checkin/presentation/screens/daily_checkin_screen.dart:312`

- [feat] 설정 화면에 부작용 대처 가이드 메뉴 추가
  - 설정 페이지에서 부작용 증상별 대처법과 피드백 기능 접근 가능
  - `lib/features/settings/presentation/screens/settings_screen.dart:143-147`

- [fix] DosagePlan 엔티티에서 미래 시작일 검증 로직 완화
  - 미래 시작일 설정 시 "Start date cannot be in the future" 에러 수정
  - 1년 이내 미래 시작일 허용 (케이스 2: 미래 계획 변경 지원)
  - `lib/features/tracking/domain/entities/dosage_plan.dart:45-49`
  - `test/features/tracking/domain/entities/dosage_plan_test.dart:25-51`

- [fix] 재시작 모드에서 과거 예정 스케줄이 삭제되지 않는 버그 수정
  - 재시작 모드 시 새 시작일 이전의 과거 예정 스케줄도 모두 삭제되도록 수정
  - deleteFromDate를 2020-01-01부터 설정하여 모든 과거 스케줄 삭제
  - `lib/features/tracking/application/usecases/update_dosage_plan_usecase.dart:100-102`

- [feat] 투여 계획 수정/재시작 모드 분리로 유저 플로우 개선
  - 일반 모드: 과거 기록 보존, 현재/미래 스케줄만 재생성 (설정 메뉴 진입)
  - 재시작 모드: 과거 예정 스케줄 삭제, 새 시작일부터 전체 재생성 (RestartScheduleDialog 진입)
  - URL 쿼리 파라미터로 모드 구분 (/dose-plan/edit?restart=true)
  - 케이스 1: 과거 시작일 설정 시 수동 기록 필요 (자동 생성 안 함)
  - 케이스 2: 미래 계획 변경 시 과거 기록 보존 (일반 모드)
  - 케이스 3: 장기 중단 후 재시작 시 과거 예정 스케줄 삭제 (재시작 모드)
  - `lib/features/tracking/application/usecases/update_dosage_plan_usecase.dart`
  - `lib/features/tracking/presentation/screens/edit_dosage_plan_screen.dart`
  - `lib/features/tracking/presentation/dialogs/restart_schedule_dialog.dart`
  - `lib/core/routing/app_router.dart`

- [feat] 투여 계획 시작일을 미래로 설정 가능하도록 개선
  - 시작일 선택 범위를 현재부터 1년 후까지 확장 (기존: 과거만 가능)
  - 다음 주부터 용량 증량 등 미래 계획을 미리 등록 가능
  - 시작일 변경 시 새 시작일부터 스케줄 생성 (과거/미래 모두 지원)
  - 시작일 미변경 시 현재부터 미래 스케줄만 재생성 (과거 기록 보존)
  - `lib/features/tracking/presentation/screens/edit_dosage_plan_screen.dart:461`
  - `lib/features/tracking/application/usecases/update_dosage_plan_usecase.dart:91`

- [fix] 투여 계획 시작일을 과거로 변경 시 과거 스케줄이 생성되지 않는 버그 수정
  - 시작일을 과거(예: 한 달 전)로 설정해도 과거 스케줄이 생성되지 않던 문제 해결
  - 앱 설치 전부터 GLP-1 약물을 사용하던 사용자의 과거 기록 추가 가능
  - UpdateDosagePlanUseCase에서 시작일 변경 감지 후 과거 스케줄 생성 로직 추가
  - deleteDoseSchedulesFrom()을 .gt()에서 .gte()로 변경하여 중복 방지
  - `lib/features/tracking/application/usecases/update_dosage_plan_usecase.dart`
  - `lib/features/tracking/infrastructure/repositories/supabase_medication_repository.dart`

- [feat] 투여 기록 로직 개선 - 날짜 기반 기록 및 2주 공백 재시작 모드
  - 날짜 클릭 시 해당 날짜로 administeredAt 기록 (기존: 항상 현재 시간)
  - 미래 날짜 기록 불가 - 조기 투여 안내 제공
  - 2주 이상 투여 공백 시 스케줄 재시작 모드 자동 진입
  - 과거 예정일 기록 시 "이 날짜에 실제로 투여하셨나요?" 확인 안내
  - `lib/features/tracking/presentation/dialogs/dose_record_dialog_v2.dart`
  - `lib/features/tracking/presentation/dialogs/restart_schedule_dialog.dart` (신규)
  - `lib/features/tracking/presentation/widgets/selected_date_detail_card.dart`
  - `lib/features/tracking/application/notifiers/medication_notifier.dart`

- [fix] 투여 계획 시작일 변경 시 스케줄이 시작일과 정렬되지 않는 버그 수정
  - 시작일을 화요일로 변경해도 스케줄이 변경 당일(목요일)부터 생성되던 문제 해결
  - _findFirstAlignedDate() 메서드 추가로 plan.startDate 기준 정렬 보장
  - `lib/features/tracking/domain/usecases/recalculate_dose_schedule_usecase.dart`

- [feat] 투여 스케줄 개별 삭제 기능 추가
  - 연체/미래 예정 스케줄을 사용자가 직접 삭제 가능
  - 투여 기록이 연결된 스케줄은 삭제 불가 (데이터 무결성 보호)
  - 삭제 확인 다이얼로그로 실수 방지
  - `lib/features/tracking/presentation/widgets/selected_date_detail_card.dart`
  - `lib/features/tracking/application/notifiers/medication_notifier.dart`

- [feat] GoRouter 인증 guard 추가로 라우팅 보안 강화
  - 로그아웃 상태에서 보호 라우트 접근 시 자동으로 /login redirect
  - 로그인 상태에서 앱 시작 시 자동으로 /home redirect (로그인 화면 스킵)
  - refreshListenable로 인증 상태 변화 실시간 감지
  - 이메일 로그인/회원가입 뒤로가기 경로 수정 (/로 이동하던 버그 → /login)
  - `lib/core/routing/app_router.dart`
  - `lib/features/authentication/presentation/screens/email_signin_screen.dart`
  - `lib/features/authentication/presentation/screens/email_signup_screen.dart`

- [fix] 이메일 로그인 화면에 뒤로 가기 버튼 추가
  - 이메일 회원가입 화면과 동일한 패턴 적용
  - `lib/features/authentication/presentation/screens/email_signin_screen.dart`

- [docs] 커밋 규칙을 Critical Rules로 이동
  - Commit Process 섹션 제거, changelog 필수 규칙 강화
  - `claude.md`

- [feat] 하단 네비 바에 트렌드 대시보드 추가
  - 가이드 탭을 트렌드 탭으로 교체 (아이콘: insights)
  - trend-dashboard 라우트를 ShellRoute 내로 이동하여 하단 네비 표시
  - 트렌드 점수 체계 통일 (goodRate → averageScore, 0-100 스케일)
  - `lib/core/presentation/widgets/scaffold_with_bottom_nav.dart`
  - `lib/core/routing/app_router.dart`
  - `lib/features/tracking/domain/entities/trend_insight.dart`

- [fix] 데일리 체크인 파생 질문 분기 로직 일관성 개선
  - Q3(속 편안함), Q4(화장실)에서 보통 선택 시에도 파생 질문이 나오던 문제 수정
  - 다른 질문들과 동일하게 나쁨 선택 시에만 파생 질문 표시
  - Q3: uncomfortable → 피드백만 표시, veryUncomfortable만 파생 질문
  - Q4: irregular → 피드백만 표시, difficult만 파생 질문
  - `lib/features/daily_checkin/presentation/constants/questions.dart`
  - `lib/features/daily_checkin/application/notifiers/daily_checkin_notifier.dart`
  - `lib/features/daily_checkin/presentation/constants/checkin_strings.dart`

## 2025-12-02

- [fix] 체크인 완료 페이지 네비게이션 오류 및 중앙 정렬 수정
  - GoError 수정: ShellRoute 내부이므로 pop() 대신 go('/home') 사용
  - 중앙 정렬: Center + SingleChildScrollView로 화면 중앙 배치
  - `lib/features/daily_checkin/presentation/screens/daily_checkin_screen.dart`

- [feat] 트렌드 대시보드 데일리 체크인 기반으로 전체 재구성 (B. 상세화)
  - TrendInsight 엔티티: 6개 질문별 트렌드, 일별 컨디션 요약, 패턴 인사이트 구조로 재설계
  - TrendInsightAnalyzer: 데일리 체크인 데이터 분석, 이전 기간 대비 비교 로직 추가
  - ConditionCalendar: 날짜별 컨디션 점수 캘린더 (주간/월간 뷰, Red Flag 표시)
  - WeeklyConditionChart: 6개 질문별 good 비율 막대그래프 + 트렌드 방향 표시
  - QuestionDetailChart: 질문별 일간 변화 라인 차트 (탭으로 질문 선택)
  - WeeklyPatternInsightCard: 주사 후 패턴, 개선/주의 영역, 추천 사항 표시
  - TrendInsightCard: 전반적 컨디션, 기록률, 연속일수, Red Flag 등 요약 카드
  - `lib/features/tracking/domain/entities/trend_insight.dart`
  - `lib/features/tracking/domain/services/trend_insight_analyzer.dart`
  - `lib/features/tracking/application/notifiers/trend_insight_notifier.dart`
  - `lib/features/tracking/presentation/screens/trend_dashboard_screen.dart`
  - `lib/features/tracking/presentation/widgets/` (5개 위젯)

- [feat] debug-pipeline 근본 원인 분석에 확신도 기반 분기 로직 추가
  - Step 2.5: 초기 확신도 평가 (4가지 기준, 100점 만점)
  - Step 2.6: 다중 가설 병렬 검증 (확신도 < 85% 시)
  - Step 2.7: 사용자 선택 요청 (보정 확신도 < 85% 시)
  - `.claude/agents/root-cause-analyzer.md`

- [fix] 데일리 체크인 Q6 완료 처리, 체중 저장, 타이머 누수, enum 방어 로직 수정
  - Q6 답변 후 finishCheckin 자동 호출 추가 (BUG-20251202-Q6FINISH)
  - 체중 입력 시 weight_logs 테이블에 저장 연동 (BUG-20251202-WEIGHT)
  - 피드백 타이머 Future.delayed → Timer 교체 및 dispose cancel (BUG-20251202-TIMER)
  - DTO enum 파싱 시 ArgumentError 대신 기본값 반환 (BUG-20251202-ENUMDEFENSE)
  - `lib/features/daily_checkin/application/notifiers/daily_checkin_notifier.dart`
  - `lib/features/daily_checkin/presentation/screens/daily_checkin_screen.dart`
  - `lib/features/daily_checkin/infrastructure/dtos/daily_checkin_dto.dart`

- [fix] 데일리 체크인 AppBar.actions 진행률 표시기 레이아웃 예외 수정 (BUG-20251202-173205)
  - 원인: AppBar.actions의 unbounded width constraint에서 Row+Expanded 사용
  - 수정: SizedBox(width: 120)로 고정 너비 제공
  - `lib/features/daily_checkin/presentation/screens/daily_checkin_screen.dart`

- [docs] CLAUDE.md에 AppBar.actions 레이아웃 규칙 추가 (BUG-20251202-173205)
  - AppBar.actions 내 Expanded/Flexible 포함 Row 직접 배치 금지
  - SizedBox로 고정 너비 제공 필수

- [fix] 데일리 체크인 화면 진입 시 Riverpod Provider 수정 에러 수정 (BUG-20251202-153023)
  - 원인: `didChangeDependencies`에서 `Future.microtask()` 없이 Provider 직접 수정
  - 수정: `Future.microtask()` 패턴 적용하여 위젯 트리 빌드 후 실행되도록 변경
  - `lib/features/daily_checkin/presentation/screens/daily_checkin_screen.dart`

- [docs] CLAUDE.md에 Widget Lifecycle 내 Provider 수정 규칙 추가
  - `initState/didChangeDependencies/build` 내 Provider 직접 수정 금지
  - `Future.microtask()` 또는 `addPostFrameCallback()` 사용 필수

- [refactor] 레거시 data_sharing 모듈 제거 및 주간 리포트로 교체
  - 설정 화면의 "의료진 데이터 공유" 메뉴를 `/share-report`로 연결
  - 기존 `/data-sharing` 라우트 및 data_sharing 폴더 전체 삭제 (12개 파일)
  - `lib/features/settings/presentation/screens/settings_screen.dart`
  - `lib/core/routing/app_router.dart`

- [fix] flutter analyze 경고 및 미사용 코드 정리 (38개 → 4개 info)
  - dead code 제거, 미사용 함수/변수/import 제거
  - super parameter 적용, BuildContext async gap 수정
  - `lib/features/authentication/`, `lib/features/tracking/`, `test/` (14개 파일)

- [feat] 데일리 체크인 기능 Phase 0-4 전체 구현 완료
  - **Phase 0: 레거시 정리**
    - DB 마이그레이션: daily_checkins 테이블 생성 (`supabase/migrations/06.daily_checkins.sql`)
    - 삭제된 파일 (18개): symptom_log, emergency_symptom_check 관련 entities/dtos/repositories/notifiers/widgets
    - weight_logs에서 appetite_score 제거 → daily_checkins로 이동
    - tracking_repository, dashboard, data_sharing에서 symptom 참조 제거
  - **Phase 1: 핵심 플로우** (기존 구현)
    - 6개 일상 질문 (식사, 수분, 속 편안함, 화장실, 에너지, 기분)
    - 파생 질문 분기 로직, 피드백 시스템, daily_checkins 저장
  - **Phase 2: 감정적 UX**
    - GreetingService: 시간대별/복귀 사용자/주사 다음날 컨텍스트 인사
    - ConsecutiveDaysService: 연속 체크인 마일스톤 축하 (3,7,14,21,30,60,90일)
    - WeeklyComparisonService: 주간 비교 피드백 (메스꺼움↓, 식욕↑, 에너지↑)
  - **Phase 3: 안전 시스템**
    - RedFlagDetector: 6가지 Red Flag 조건 감지 (췌장염, 담낭염, 탈수, 장폐색, 저혈당, 신부전)
    - RedFlagGuidanceSheet: 부드러운 안내 바텀시트 UI (두려움 최소화 톤)
  - **Phase 4: 의료진 공유**
    - WeeklyReport 엔티티 + WeeklyReportGenerator 서비스
    - ShareReportScreen: 주간 리포트 조회/복사 화면
    - 라우팅 추가: `/share-report`
  - **빌드 에러 수정**
    - daily_tracking_screen: 식욕 점수 섹션 제거 (daily_checkins로 이동됨)
    - record_list_screen: 죽은 코드 _SymptomRecordTile 제거
  - `lib/features/daily_checkin/` (32개 파일 신규)
  - `lib/features/tracking/` (18개 파일 삭제, 13개 수정)
  - `lib/features/dashboard/`, `lib/features/data_sharing/` (4개 수정)

- [docs] 데일리 체크인 명세서 구현 준비 보완
  - SymptomType → CopingGuide symptomName 매핑 함수 추가 (12.6절)
  - 연속 기록 판정 정책 명확화: 체크인 기준, 체중은 선택 (7.2절)
  - 주사 다음날 감지 로직 상세화: dose_records 활용 (6.2절)
  - 위젯 재사용/신규 생성 결정 테이블 추가 (1.2절)
  - Q0 체중 입력 섹션 신규 추가: UI 구조, 입력 사양, 피드백
  - database.md: daily_checkins 테이블 스키마 반영, symptom_logs/emergency_symptom_checks 제거

- [docs] database.md 마이그레이션/코드와 일치하도록 동기화
  - users 테이블: id TEXT 타입, 불필요 컬럼 제거 (auth_type, password_hash 등)
  - weight_logs: appetite_score 컬럼 추가
  - 신규 테이블 추가: notification_settings, audit_logs, guide_feedback
  - password_reset_tokens 제거, RLS 정책 업데이트, Trigger 섹션 추가

- [chore] 미사용 코드 18개 파일 정리
  - authentication: datasources(kakao/naver), dtos(user/consent_record), email_auth_exceptions
  - onboarding: user_dto
  - tracking: validate_weight_create_usecase, symptom_context_tag_dto, record_detail_sheet, coping_guide_widget, dose_schedule_card
  - dashboard: calculate_adherence_usecase
  - data_sharing: data_sharing_aggregator
  - coping_guide: guide_feedback_dto
  - barrel exports: 4개 index.dart 파일

## 2025-12-01

- [fix] 지난 주 요약 위젯 체중 변화 계산 버그 수정
  - 체중 감소 시 "증가"로 잘못 표시되던 문제 해결 (계산 순서 반전: first-last → last-first)
  - `lib/features/dashboard/application/notifiers/dashboard_notifier.dart`

- [fix] 지난 주 요약 위젯 적응기 표시 개선
  - 기존: "N일을 잘 견뎌냈어요" (증상 건수를 일수로 잘못 표시, 0건 시 부정적)
  - 변경: 증상 건수별 긍정적 프레이밍 (0건: "증상 없이 잘 지냈어요!", 1-2건: "가벼운 적응기", 3-5건: "N건의 증상을 잘 견뎌냈어요", 6건+: "적응 중이에요, 잘하고 있어요!")
  - `lib/features/dashboard/presentation/widgets/celebratory_report_widget.dart`

- [feat] PRD 감정적 UX 원칙에 맞춘 전체 앱 색상 개선
  - 성취/자부심 → Gold (#F59E0B): 연속 기록, 뱃지, 마일스톤
  - 따뜻함/환영 → Orange (#F97316): 복귀 메시지, 환영, 격려
  - 안심/신뢰 → Blue (#3B82F6): 대처 가이드, 교육 콘텐츠, 팁
  - 연결/회고 → Purple (#8B5CF6): 타임라인, 기록 히스토리
  - Dashboard, Tracking, Coping Guide, Onboarding, Data Sharing 19개 파일 수정
  - `.claude/skills/ui-renewal/references/feature-color-guide.md`

- [docs] PRD 감정적 UX 원칙 및 사용자 감정 프로파일 추가
  - 핵심 가치 5개 재정의 (감정적 지지, 안심감, 성취감, 연결감, 안전성)
  - Target User 감정적 프로파일 섹션 추가 (거부감, 불안, 자존감, 의욕 저하, 고립감)
  - 사용자 여정에 감정적 목표 컬럼 추가 + SC5(기록 공백 후 복귀) 신규
  - Section VI 감정적 UX 원칙 (언어/시각/메시지 톤/터치포인트)
  - Section VII 핵심 지표 (리텐션, 복귀율, NPS)
  - `docs/prd.md`

- [feat] 대시보드 감정적 UX 개선 위젯 6개 구현
  - 핵심 리프레이밍: "부작용 기록" → "몸의 신호 체크", "다음 투여" → "다음 단계"
  - EmotionalGreetingWidget: 시간대별 인사 + 마일스톤 격려 메시지
  - EncouragingProgressWidget: 정상화 + 80% sparkle 축하 애니메이션
  - HopefulScheduleWidget: Forest 스타일 성장 은유 + 격려 컨테이너
  - CelebratoryReportWidget: Duolingo 스타일 축하 언어 + warning 색상
  - JourneyTimelineWidget: 스토리텔링 + gold glow 마일스톤
  - CelebratoryBadgeWidget: Next-Up dashed border 하이라이트
  - 기존 6개 위젯 삭제 (greeting, weekly_progress, next_schedule, weekly_report, timeline, badge)
  - `lib/features/dashboard/presentation/widgets/*.dart`

- [feat] 트렌드 대시보드 유저플로우 접근 경로 추가
  - WeeklyReportWidget 탭 시 트렌드 대시보드로 이동 (기존: data-sharing)
  - 설정 화면에 '의료진 데이터 공유' 메뉴 추가
  - `lib/features/dashboard/presentation/widgets/weekly_report_widget.dart`
  - `lib/features/settings/presentation/screens/settings_screen.dart`

- [fix] 부작용 가이드 콘텐츠를 content-guide.md 기준으로 정확히 반영
  - 두통 안심 메시지에 "혈당 변화" 추가
  - 변비/복통 통계적 안심 메시지 보완 (섬유질, 휴식)
  - detailedSections를 2-3개 섹션으로 간결화 (기존 4개)
  - 섹션 제목을 케어 기반 대화체로 변경
  - `lib/features/coping_guide/infrastructure/repositories/static_coping_guide_repository.dart`

## 2025-11-30

- [feat] 부작용 UX 개선 Phase 1-4 전체 구현 완료
  - Phase 1: 안심 퍼스트 가이드 (InlineSymptomGuideCard, SeverityFeedbackChip, ExpandableGuideSection)
  - Phase 2: 컨텍스트 인식 가이드 (PatternInsightCard, ContextualGuideCard, SymptomPatternAnalyzer)
  - Phase 3: 트렌드 대시보드 (SymptomHeatmapCalendar, SymptomTrendChart, TrendInsightCard, TrendDashboardScreen)
  - Phase 4: 통합 테스트 94개 작성 및 문서화
  - `lib/features/tracking/domain/entities/pattern_insight.dart`
  - `lib/features/tracking/domain/entities/trend_insight.dart`
  - `lib/features/tracking/domain/services/symptom_pattern_analyzer.dart`
  - `lib/features/tracking/domain/services/trend_insight_analyzer.dart`
  - `lib/features/tracking/presentation/widgets/` (8개 위젯)
  - `lib/features/tracking/presentation/screens/trend_dashboard_screen.dart`

- [fix] EmergencyCheckScreen Container color/decoration 동시 사용 버그 수정
  - color를 BoxDecoration 내부로 이동하여 assertion 에러 해결
  - CLAUDE.md에 Container 스타일링 규칙 추가
  - `lib/features/tracking/presentation/screens/emergency_check_screen.dart`

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

