# Feature Color 개선 계획서

## 개요

**목표:** PRD의 감정적 UX 원칙에 맞게 전체 앱의 색상 다양성 개선
**방법:** 기존 디자인 시스템의 색상을 전략적으로 활용 (디자인 시스템 전면 수정 X)
**작성일:** 2024-12-01

---

## 현황 분석

### 문제점
- Primary(녹색) + Neutral(회색)만 압도적으로 사용
- PRD에서 요구하는 "성취감", "따뜻함", "안심" 등의 감정을 색상으로 표현하지 못함
- 디자인 시스템에 다양한 색상이 정의되어 있으나 활용 안 됨

### 해결 방안
- 기능별/감정별 색상 매핑 정의
- 각 화면에서 해당 색상 전략적 활용
- 신규 기능에도 동일 규칙 적용

---

## 완료된 기반 작업 (Phase 0)

- [x] `app_colors.dart`에 Feature Color 상수 추가
- [x] 디자인 시스템에 Feature Color Mapping 섹션 추가 (Section 13)
- [x] `references/feature-color-guide.md` 가이드 문서 작성
- [x] `SKILL.md`에 Feature Color Guide 참조 추가

---

## 개선 대상 화면 목록

### Phase 1: Dashboard (최우선)
**이유:** 사용자가 가장 많이 보는 화면, 동기부여가 핵심

| 화면 | 파일 | 개선 포인트 |
|-----|------|-----------|
| 홈 대시보드 | `home_dashboard_screen.dart` | 연속 기록→Gold, 인사→Orange, 팁→Blue |

**예상 변경 컴포넌트:**
- 연속 기록 뱃지/카운터 → `AppColors.achievement`
- 주간 진행률 100% → `AppColors.achievement`
- 오늘의 인사 (특히 복귀) → `AppColors.warmWelcome`
- 팁/가이드 카드 → `AppColors.education`
- 타임라인 → `AppColors.history`

---

### Phase 2: Tracking (핵심 기능)
**이유:** 앱의 핵심 기능, 성취감 강화 필요

| 화면 | 파일 | 개선 포인트 |
|-----|------|-----------|
| 일일 트래킹 | `daily_tracking_screen.dart` | 연속 투여→Gold |
| 투여 캘린더 | `dose_calendar_screen.dart` | 완료일→Primary, 연속→Gold |
| 트렌드 대시보드 | `trend_dashboard_screen.dart` | 차트 다중색상 |
| 응급 체크 | `emergency_check_screen.dart` | 위험→Error |
| 투여 계획 수정 | `edit_dosage_plan_screen.dart` | 기존 유지 |

**예상 변경 컴포넌트:**
- 연속 투여 표시 → `AppColors.achievement`
- 트렌드 차트 → `AppColors.chartColors` 활용
- 투여 스케줄 안내 → `AppColors.education`

---

### Phase 3: Coping Guide (안심감)
**이유:** 안심감이 핵심인 영역, Blue 계열로 통일

| 화면 | 파일 | 개선 포인트 |
|-----|------|-----------|
| 대처 가이드 | `coping_guide_screen.dart` | 전체→Blue |
| 상세 가이드 | `detailed_guide_screen.dart` | 전체→Blue |

**예상 변경 컴포넌트:**
- 가이드 카드 배경 → `AppColors.educationBackground`
- 아이콘/강조 → `AppColors.education`
- 안심 메시지 → `AppColors.education`

---

### Phase 4: Onboarding (첫인상)
**이유:** 첫인상 결정, 환영/교육 색상 적용

| 화면 | 파일 | 개선 포인트 |
|-----|------|-----------|
| 온보딩 메인 | `onboarding_screen.dart` | 진행→Primary |
| 환영 | `welcome_screen.dart` | 환영→Orange |
| 푸드노이즈 | `food_noise_screen.dart` | 교육→Blue |
| 작동원리 | `how_it_works_screen.dart` | 교육→Blue |
| 근거 | `evidence_screen.dart` | 교육→Blue |
| 여정 로드맵 | `journey_roadmap_screen.dart` | 여정→Purple |
| 부작용 | `side_effects_screen.dart` | 안심→Blue |
| 서약 | `commitment_screen.dart` | 시작→Primary |

**예상 변경 컴포넌트:**
- 환영 메시지 → `AppColors.warmWelcome`
- 교육 콘텐츠 카드 → `AppColors.educationBackground`
- 여정 타임라인 → `AppColors.history`

---

### Phase 5: 나머지 화면
**이유:** 대부분 기존 유지, 포인트만 개선

| 영역 | 화면 | 개선 포인트 |
|-----|------|-----------|
| Authentication | login, signup, signin, reset | 기존 유지 |
| Settings | settings_screen | 위험 액션→Error |
| Profile | profile_edit, weekly_goal | 기존 유지 |
| Notification | notification_settings | 기존 유지 |
| Data Sharing | data_sharing_screen | 공유→Blue, 데이터→Purple |
| Record | record_list_screen | 기록→Purple |

---

## 작업 순서

```
Phase 0 (완료)
    │
    ├── app_colors.dart 수정 ✅
    ├── 디자인 시스템 문서 수정 ✅
    ├── feature-color-guide.md 작성 ✅
    └── SKILL.md 수정 ✅
    │
    ▼
Phase 1: Dashboard
    │
    └── home_dashboard_screen.dart
    │
    ▼
Phase 2: Tracking
    │
    ├── daily_tracking_screen.dart
    ├── dose_calendar_screen.dart
    ├── trend_dashboard_screen.dart
    └── emergency_check_screen.dart
    │
    ▼
Phase 3: Coping Guide
    │
    ├── coping_guide_screen.dart
    └── detailed_guide_screen.dart
    │
    ▼
Phase 4: Onboarding
    │
    ├── welcome_screen.dart
    ├── education/* screens
    └── preparation/* screens
    │
    ▼
Phase 5: 나머지
    │
    ├── data_sharing_screen.dart
    ├── record_list_screen.dart
    └── settings_screen.dart
```

---

## 작업 가이드라인

### 각 화면 작업 시 체크리스트

1. [ ] PRD의 해당 터치포인트 감정 목표 확인
2. [ ] `feature-color-guide.md`에서 적용할 색상 확인
3. [ ] 현재 색상 사용 현황 파악 (grep `AppColors`)
4. [ ] 변경할 컴포넌트 식별
5. [ ] `AppColors.xxx` 상수 사용하여 변경
6. [ ] 빌드 및 시각적 확인

### 금지 사항

- `Color(0xFF...)` 하드코딩 금지
- 한 화면에 4개 이상 포인트 색상 사용 금지
- Primary를 모든 강조에 남용 금지

---

## 예상 결과

### Before
- 모든 화면이 녹색+회색 톤으로 단조로움
- 성취/환영/안심 등의 감정 구분이 안 됨

### After
- 기능별로 색상 톤이 구분됨
- Dashboard: 성취의 Gold 톤 강조
- Coping Guide: 안심의 Blue 톤
- Onboarding: 환영의 Orange + 교육의 Blue
- 전체적으로 PRD의 감정적 UX 원칙 구현

---

## 참고 문서

- PRD: `docs/prd.md` (감정적 UX 원칙)
- Feature Color Guide: `.claude/skills/ui-renewal/references/feature-color-guide.md`
- Design System: `.claude/skills/ui-renewal/design-systems/gabium-design-system-v1.0.md` (Section 13)
- App Colors: `lib/core/presentation/theme/app_colors.dart`

---

**Version:** 1.0
**Last Updated:** 2024-12-01
