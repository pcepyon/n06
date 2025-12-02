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

## 2025-12-03

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

