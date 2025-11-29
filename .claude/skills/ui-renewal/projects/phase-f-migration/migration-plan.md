# Phase F Migration Plan: 하드코딩 스타일 → Theme 기반 전환

**생성일:** 2025-11-29
**상태:** 계획 수립 완료

---

## 개요

총 75개 파일에서 하드코딩된 Color/TextStyle을 `Theme.of(context)` 및 `AppColors`/`AppTypography` 기반으로 전환.

---

## 마이그레이션 배치 (기능별)

### Batch 1: Core & Shared Components (6개 파일)
**우선순위:** 높음 (다른 기능에서 재사용)

| 파일 | 하드코딩 수 (예상) |
|------|-------------------|
| `lib/core/presentation/widgets/gabium_bottom_navigation.dart` | ~15 |
| `lib/core/presentation/widgets/empty_state_widget.dart` | ~8 |
| `lib/core/presentation/widgets/status_badge.dart` | ~10 |
| `lib/core/presentation/widgets/impact_analysis_dialog.dart` | ~12 |
| `lib/core/presentation/widgets/scaffold_with_bottom_nav.dart` | ~5 |
| `lib/core/presentation/widgets/record_type_icon.dart` | ~6 |

---

### Batch 2: Authentication (10개 파일)
**우선순위:** 높음 (첫 인상)

| 파일 |
|------|
| `login_screen.dart` |
| `email_signin_screen.dart` |
| `email_signup_screen.dart` |
| `auth_hero_section.dart` |
| `gabium_button.dart` |
| `gabium_text_field.dart` |
| `gabium_toast.dart` |
| `password_strength_indicator.dart` |
| `consent_checkbox.dart` |
| `social_login_button.dart` |

---

### Batch 3: Dashboard (7개 파일)
**우선순위:** 높음 (메인 화면)

| 파일 |
|------|
| `home_dashboard_screen.dart` |
| `greeting_widget.dart` |
| `weekly_progress_widget.dart` |
| `next_schedule_widget.dart` |
| `weekly_report_widget.dart` |
| `timeline_widget.dart` |
| `badge_widget.dart` |

---

### Batch 4: Tracking (15개 파일)
**우선순위:** 중간 (핵심 기능)

| 파일 |
|------|
| `daily_tracking_screen.dart` |
| `dose_calendar_screen.dart` |
| `edit_dosage_plan_screen.dart` |
| `emergency_check_screen.dart` |
| `dose_record_dialog_v2.dart` |
| `injection_site_selector_v2.dart` |
| `date_picker_field.dart` |
| `date_selection_widget.dart` |
| `dose_schedule_card.dart` |
| `selected_date_detail_card.dart` |
| `severity_level_indicator.dart` |
| `appeal_score_chip.dart` |
| `conditional_section.dart` |
| `consultation_recommendation_dialog.dart` |
| `emergency_checklist_item.dart` |

---

### Batch 5: Onboarding (15개 파일)
**우선순위:** 중간 (첫 경험이지만 한 번만 봄)

| 파일 |
|------|
| `basic_profile_form.dart` |
| `dosage_plan_form.dart` |
| `weight_goal_form.dart` |
| `summary_screen.dart` |
| `summary_card.dart` |
| `validation_alert.dart` |
| `onboarding_page_template.dart` |
| `journey_progress_indicator.dart` |
| `welcome_screen.dart` |
| `evidence_screen.dart` |
| `food_noise_screen.dart` |
| `how_it_works_screen.dart` |
| `journey_roadmap_screen.dart` |
| `not_your_fault_screen.dart` |
| `side_effects_screen.dart` |
| `app_features_screen.dart` |
| `commitment_screen.dart` |
| `injection_guide_screen.dart` |

---

### Batch 6: Settings & Profile (8개 파일)
**우선순위:** 낮음

| 파일 |
|------|
| `settings_screen.dart` |
| `settings_menu_item_improved.dart` |
| `user_info_card.dart` |
| `danger_button.dart` |
| `profile_edit_screen.dart` |
| `profile_edit_form.dart` |
| `weekly_goal_settings_screen.dart` |
| `notification_settings_screen.dart` |
| `time_picker_button.dart` |

---

### Batch 7: Coping Guide (5개 파일)
**우선순위:** 낮음

| 파일 |
|------|
| `coping_guide_screen.dart` |
| `detailed_guide_screen.dart` |
| `coping_guide_card.dart` |
| `coping_guide_feedback_result.dart` |
| `feedback_widget.dart` |

---

### Batch 8: Data Sharing & Record Management (5개 파일)
**우선순위:** 낮음

| 파일 |
|------|
| `data_sharing_screen.dart` |
| `data_sharing_period_selector.dart` |
| `exit_confirmation_dialog.dart` |
| `record_list_screen.dart` |
| `record_list_card.dart` |

---

## 마이그레이션 규칙

### Color 변환
```dart
// Before
Color(0xFF4ADE80)  → AppColors.primary
Color(0xFF1E293B)  → AppColors.textPrimary (또는 neutral800)
Color(0xFFE2E8F0)  → AppColors.border (또는 neutral200)
Color(0xFFEF4444)  → AppColors.error
Color(0xFF10B981)  → AppColors.success
```

### TextStyle 변환
```dart
// Before
TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w700,
  color: Color(0xFF1E293B),
)

// After (Option 1: Theme 사용)
Theme.of(context).textTheme.headlineMedium

// After (Option 2: AppTypography 직접 사용)
AppTypography.heading1
```

### 권장 패턴
```dart
// 색상은 AppColors 상수 사용
color: AppColors.primary

// 텍스트 스타일은 Theme 또는 AppTypography
style: Theme.of(context).textTheme.bodyLarge
// 또는
style: AppTypography.bodyLarge

// 커스텀 조합 시
style: AppTypography.bodyLarge.copyWith(color: AppColors.primary)
```

---

## 예상 작업량

| Batch | 파일 수 | 예상 변경 라인 |
|-------|--------|--------------|
| 1 | 6 | ~150 |
| 2 | 10 | ~250 |
| 3 | 7 | ~180 |
| 4 | 15 | ~350 |
| 5 | 18 | ~400 |
| 6 | 9 | ~200 |
| 7 | 5 | ~120 |
| 8 | 5 | ~100 |
| **Total** | **75** | **~1,750** |

---

## 검증 방법

각 Batch 완료 후:
1. `flutter analyze` 통과
2. `flutter build ios --debug` 성공
3. 해당 화면 UI 시각적 확인

---

## 다음 단계

1. Batch 1 (Core) 먼저 완료 - 공유 컴포넌트이므로
2. Batch 2 (Authentication) - 첫 인상
3. Batch 3 (Dashboard) - 메인 화면
4. 나머지 Batch 순차 진행
