# Dashboard Emotional UX Implementation Guide

## Implementation Summary

Based on the approved Improvement Proposal, this guide provides exact specifications for implementing emotional UX improvements to the GLP-1 dashboard. All changes focus on reframing language, adding micro-interactions, and enhancing visual feedback while preserving existing business logic.

**Changes to Implement:**
1. GreetingWidget → EmotionalGreetingWidget (따뜻한 인사 + 격려)
2. WeeklyProgressWidget → EncouragingProgressWidget (긍정적 라벨링)
3. NextScheduleWidget → HopefulScheduleWidget (희망적 프레이밍)
4. WeeklyReportWidget → CelebratoryReportWidget (성취 중심)
5. TimelineWidget → JourneyTimelineWidget (여정 스토리텔링)
6. BadgeWidget → CelebratoryBadgeWidget (축하 애니메이션)

---

## Design Token Values

| Element | Token Path | Value | Usage |
|---------|-----------|-------|-------|
| Card BG | Surface | #FFFFFF | Widget containers |
| Card Border | Neutral-200 | #E2E8F0 | Card borders |
| Card Radius | md | 12px | Card corners |
| Card Shadow sm | sm | 0 2px 4px rgba(15,23,42,0.06) | Default elevation |
| Primary | Primary | #4ADE80 | CTA, positive |
| Success | Success | #10B981 | Achievement |
| Warning | Warning | #F59E0B | Attention |
| Gold | Gold | #F59E0B | Badges |
| Text Primary | Neutral-800 | #1E293B | Headings |
| Text Secondary | Neutral-700 | #334155 | Subheadings |
| Text Body | Neutral-600 | #475569 | Body |
| Text Caption | Neutral-500 | #64748B | Captions |
| Border Light | Neutral-200 | #E2E8F0 | Borders |
| BG Subtle | Neutral-50 | #F8FAFC | Backgrounds |
| display | 3xl | 28px Bold | Main greeting (AppTypography.display) |
| heading2 | xl | 20px Semibold | Sections (AppTypography.heading2) |
| labelLarge | lg | 16px Semibold | Emphasis |
| labelMedium | sm | 14px Medium | Labels |
| bodySmall | sm | 14px Regular | Body |
| caption | xs | 12px Regular | Metadata |
| Spacing lg | lg | 24px | Sections |
| Spacing md | md | 16px | Elements |
| Spacing sm | sm | 8px | Tight |

---

## Component Specifications

### Component 1: EmotionalGreetingWidget

**Purpose:** 시간대별 공감 인사와 격려 메시지로 사용자를 따뜻하게 환영

**Design Intent:**
- 앱을 열 때 "환영받는 느낌" 전달
- 연속 기록일을 "성장의 증거"로 프레이밍
- 시간대별 맞춤 인사로 개인화된 경험

**Visual Specifications:**

```
Container:
├── Background: #FFFFFF (Surface)
├── Border: 1px solid #E2E8F0 (Neutral-200)
├── Border Radius: 12px (md)
├── Shadow: 0 2px 4px rgba(15,23,42,0.06) (sm)
├── Padding: 24px (lg)
│
├── Time-based Greeting Row
│   ├── Text: "좋은 아침이에요, {userName}님!" (or 오후/저녁)
│   ├── Typography: 28px Bold (AppTypography.display)
│   ├── Color: #1E293B (AppColors.textPrimary)
│
├── Stats Row (2 columns)
│   ├── Column 1: 연속 기록일
│   │   ├── Label: "연속으로 기록 중"
│   │   ├── Label Style: 12px Regular, #64748B
│   │   ├── Value: "{continuousRecordDays}일째"
│   │   ├── Value Style: 20px Semibold, #4ADE80 (Primary)
│   │
│   ├── Column 2: 현재 주차
│   │   ├── Label: "치료 여정"
│   │   ├── Label Style: 12px Regular, #64748B
│   │   ├── Value: "{currentWeek}주차"
│   │   ├── Value Style: 20px Semibold, #1E293B
│
├── Encouragement Message (if insightMessage exists)
│   ├── Icon: Icons.auto_awesome (sparkle), 20px, #10B981
│   ├── Text: "{insightMessage}"
│   ├── Typography: 14px Medium, #10B981 (Success)
│   ├── Container: Background #ECFDF5 (AppColors.success.withOpacity(0.1)), Padding 12px, Radius 8px
```

**Time-based Greeting Logic:**
```dart
String getTimeBasedGreeting(String userName) {
  final hour = DateTime.now().hour;
  if (hour < 12) {
    return '좋은 아침이에요, $userName님!';
  } else if (hour < 18) {
    return '좋은 오후예요, $userName님!';
  } else {
    return '좋은 저녁이에요, $userName님!';
  }
}
```

**Encouragement Message Examples (content-driven, not hardcoded):**
- 연속 7일: "일주일 연속으로 기록 중이에요! 멋져요!"
- 연속 30일: "한 달간 꾸준히 기록하고 있어요. 대단해요!"
- Default: insightMessage 그대로 사용

**Interactive States:**
- Default: As specified above
- Hover: Card shadow upgrade to md (desktop only)
- Transition: 200ms ease

---

### Component 2: EncouragingProgressWidget

**Purpose:** 진행률을 긍정적 언어로 표현하고, 높은 달성률에 시각적 축하 제공

**Design Intent:**
- "부작용 기록" → "몸의 신호 체크" (정상화)
- 80%+ 달성 시 sparkle 효과로 성취감
- 그라데이션 진행률 바로 시각적 만족감

**Label Mapping (CRITICAL - 하드코딩 금지):**
```dart
String getEncouragingLabel(String originalLabel) {
  switch (originalLabel.toLowerCase()) {
    case '투여':
      return '투여 완료';
    case '체중 기록':
      return '변화 추적';
    case '부작용 기록':
      return '몸의 신호 체크';
    default:
      return originalLabel;
  }
}
```

**Visual Specifications:**

```
Section Container:
├── Title: "주간 목표 진행도"
├── Title Style: 20px Semibold, #1E293B
├── Spacing below title: 16px (md)
│
├── Progress Items (Column, gap: 16px)
│   │
│   └── Progress Item Container
│       ├── Background: #F8FAFC (Neutral-50)
│       ├── Border: 1px solid #E2E8F0 (Neutral-200)
│       ├── Border Radius: 8px (sm)
│       ├── Padding: 16px (md)
│       │
│       ├── Header Row
│       │   ├── Left: Encouraging Label
│       │   │   ├── Typography: 14px Medium, #334155 (Neutral-700)
│       │   ├── Right: Fraction "{current}/{total}"
│       │   │   ├── Typography: 14px Regular, #475569 (Neutral-600)
│       │
│       ├── Progress Bar (height: 8px, radius: 999px)
│       │   ├── Background: #E2E8F0 (Neutral-200)
│       │   ├── Fill: LinearGradient(
│       │   │     begin: Alignment.centerLeft,
│       │   │     end: Alignment.centerRight,
│       │   │     colors: [Primary.withOpacity(0.6), Primary]
│       │   │   )
│       │   ├── Fill (100%): #10B981 (Success) solid
│       │
│       ├── Footer Row
│       │   ├── Right: Percentage + Celebration
│       │   │   ├── Text: "{percentage}%"
│       │   │   ├── Color: Primary (default), Success (100%)
│       │   │   ├── If 80%+: Add sparkle icon (Icons.auto_awesome, 16px)
│       │   │   ├── If 100%: Add "완료!" text
```

**Animation Spec (80%+ achievement):**
```dart
// Sparkle icon animation
AnimatedScale(
  scale: _showCelebration ? 1.0 : 0.0,
  duration: Duration(milliseconds: 300),
  curve: Curves.elasticOut,
  child: Icon(Icons.auto_awesome, size: 16, color: AppColors.success),
)
```

**Celebration Messages (threshold-based):**
- 80-99%: sparkle icon only
- 100%: sparkle icon + "완료!" text + Success color

---

### Component 3: HopefulScheduleWidget

**Purpose:** 다음 일정을 희망적이고 지지적인 언어로 표현

**Design Intent:**
- "다음 투여" → "다음 단계" (여정의 일부로 프레이밍)
- "다음 증량" → "성장의 순간" (긍정적 의미 부여)
- 각 일정에 격려 메시지 추가

**Copy Mapping:**
```dart
String getHopefulTitle(String scheduleType) {
  switch (scheduleType) {
    case 'dose':
      return '다음 단계';
    case 'escalation':
      return '성장의 순간';
    default:
      return scheduleType;
  }
}

String getSupportMessage(String scheduleType) {
  switch (scheduleType) {
    case 'dose':
      return '투여 전 물 한 잔, 오늘도 건강한 선택!';
    case 'escalation':
      return '몸이 잘 적응하고 있어요. 다음 단계로 나아갈 준비가 되었어요.';
    default:
      return '';
  }
}
```

**Visual Specifications:**

```
Card Container:
├── Background: #FFFFFF (Surface)
├── Border: 1px solid #E2E8F0
├── Border Radius: 12px (md)
├── Shadow: sm
├── Padding: 24px (lg)
│
├── Section Title: "다음 예정"
├── Title Style: 20px Semibold, #1E293B
├── Spacing: 16px below title
│
├── Schedule Items (Column)
│   │
│   └── Schedule Item
│       ├── Row (crossAxisAlignment: start)
│       │   ├── Icon Container (40x40px, centered)
│       │   │   ├── Background: Primary at 10% (#4ADE80 0.1)
│       │   │   ├── Border Radius: full (20px)
│       │   │   ├── Icon: Icons.medication_outlined (dose) / Icons.trending_up (escalation)
│       │   │   ├── Icon Size: 20px
│       │   │   ├── Icon Color: #4ADE80 (dose) / #64748B (escalation)
│       │   │
│       │   ├── Text Column (Expanded)
│       │   │   ├── Title: getHopefulTitle(type)
│       │   │   │   ├── Typography: 12px Regular, #64748B
│       │   │   ├── Date: formatted date
│       │   │   │   ├── Typography: 14px Medium, #1E293B
│       │   │   ├── Subtitle (if exists): "{mg}mg 투여 예정"
│       │   │   │   ├── Typography: 14px Regular, #475569
│       │   │   ├── Support Message
│       │   │   │   ├── Spacing: 8px top
│       │   │   │   ├── Container: Background #F8FAFC, Padding 8px 12px, Radius 6px
│       │   │   │   ├── Text: getSupportMessage(type)
│       │   │   │   ├── Typography: 14px Regular, #4ADE80 (Primary)
│       │
│       ├── Spacing between items: 24px (lg)
```

---

### Component 4: CelebratoryReportWidget

**Purpose:** 주간 요약을 평가가 아닌 축하의 관점으로 전환

**Design Intent:**
- "부작용 X회" → "X일을 잘 견뎌냈어요" (극복 프레이밍)
- "순응도 X%" → "목표의 X% 달성!" (성취 프레이밍)
- 70%+ 임계값에서 Success 색상 + 격려 메시지

**Copy Mapping:**
```dart
String getCelebratoryValue(String type, dynamic value) {
  switch (type) {
    case 'dose':
      return '${value}회 투여 완료';
    case 'weight':
      final direction = value < 0 ? '줄었어요' : '늘었어요';
      return '${value.abs().toStringAsFixed(1)}kg $direction';
    case 'symptom':
      return '${value}일을 잘 견뎌냈어요';
    case 'adherence':
      return '목표의 ${value.toStringAsFixed(0)}% 달성!';
    default:
      return value.toString();
  }
}

String getAdherenceMessage(double percentage) {
  if (percentage >= 100) return '완벽해요!';
  if (percentage >= 90) return '거의 다 왔어요!';
  if (percentage >= 70) return '잘하고 있어요!';
  return '';
}
```

**Visual Specifications:**

```
Card Container (with tap animation):
├── GestureDetector with scale animation on tap
├── Background: #FFFFFF
├── Border: 1px solid #E2E8F0
├── Border Radius: 12px
├── Shadow: sm (default), md (pressed)
├── Transform: translateY(-2px) on press
├── Padding: 24px
│
├── Section Title: "지난주 요약"
├── Title Style: 20px Semibold, #1E293B
├── Spacing: 16px
│
├── Report Items Row (MainAxisAlignment.spaceAround)
│   │
│   └── Report Item (Column)
│       ├── Icon: 24px
│       │   ├── dose: Icons.medication, #4ADE80
│       │   ├── weight: Icons.monitor_weight, #10B981
│       │   ├── symptom: Icons.favorite_border, #F59E0B (Warning, not Error!)
│       ├── Label: 12px Regular, #64748B
│       │   ├── dose: "투여"
│       │   ├── weight: "체중"
│       │   ├── symptom: "적응기" (NOT "부작용")
│       ├── Value: getCelebratoryValue(type, value)
│       │   ├── Typography: 14px Semibold, #1E293B
│
├── Spacing: 16px
│
├── Adherence Container
│   ├── Background: #F8FAFC (Neutral-50)
│   ├── Border: 1px solid #E2E8F0
│   ├── Border Radius: 8px
│   ├── Padding: 16px
│   │
│   ├── Row (MainAxisAlignment.spaceBetween)
│   │   ├── Left Column
│   │   │   ├── Label: "투여 순응도"
│   │   │   ├── Style: 14px Regular, #475569
│   │   │   ├── Message (if 70%+): getAdherenceMessage()
│   │   │   ├── Message Style: 14px Medium, #10B981
│   │   │
│   │   ├── Right: Percentage
│   │   │   ├── Text: "{percentage}%"
│   │   │   ├── Style: 20px Semibold
│   │   │   ├── Color: #4ADE80 (default), #10B981 (70%+)
```

**CRITICAL Change:**
- 부작용 아이콘 색상: `AppColors.error` → `AppColors.warning` (#F59E0B)
- 부작용 라벨: "부작용" → "적응기"

---

### Component 5: JourneyTimelineWidget

**Purpose:** 이벤트 나열을 "여정 스토리"로 전환하여 성취감 강화

**Design Intent:**
- 상단에 여정 요약 추가 ("X주간 X개의 성취!")
- 마일스톤 이벤트 강조 (더 큰 dot, glow)
- 최근 24시간 내 이벤트에 "NEW" 뱃지

**Visual Specifications:**

```
Section Container:
├── Title Row
│   ├── Text: "치료 여정"
│   ├── Style: 20px Semibold, #1E293B
│
├── Journey Summary (NEW)
│   ├── Container: Background #ECFDF5, Padding 12px 16px, Radius 8px
│   ├── Icon: Icons.emoji_events, 20px, #4ADE80
│   ├── Text: "{weeks}주간 {milestoneCount}개의 성취를 달성했어요!"
│   ├── Style: 14px Medium, #4ADE80
│   ├── Spacing: 16px below
│
├── Timeline Events (Column)
│   │
│   └── Timeline Event Item
│       ├── IntrinsicHeight Row
│       │
│       ├── Dot Column (width: 20px)
│       │   ├── Dot (regular)
│       │   │   ├── Size: 16px
│       │   │   ├── Border: 3px solid {eventColor}
│       │   │   ├── Background: #FFFFFF
│       │   │
│       │   ├── Dot (milestone) - weightMilestone, badgeAchievement
│       │   │   ├── Size: 20px
│       │   │   ├── Border: 4px solid #F59E0B (Gold)
│       │   │   ├── Background: #FEF3C7 (Gold-100)
│       │   │   ├── Shadow: 0 0 8px rgba(245,158,11,0.4) (gold glow)
│       │   │
│       │   ├── Connector Line (if not last)
│       │   │   ├── Width: 3px
│       │   │   ├── Color: #CBD5E1 (Neutral-300)
│       │
│       ├── Spacing: 16px
│       │
│       ├── Content Column
│       │   ├── Title Row
│       │   │   ├── Text: event.title
│       │   │   ├── Style: 16px Semibold, #1E293B
│       │   │   ├── NEW Badge (if within 24h)
│       │   │   │   ├── Background: #4ADE80 at 10%
│       │   │   │   ├── Text: "NEW"
│       │   │   │   ├── Style: 12px Medium, #4ADE80
│       │   │   │   ├── Padding: 2px 8px
│       │   │   │   ├── Radius: full
│       │   │   │   ├── Margin left: 8px
│       │   │
│       │   ├── Description
│       │   │   ├── Text: event.description
│       │   │   ├── Style: 14px Regular, #64748B
│       │
│       ├── Padding bottom (if not last): 24px
```

**Journey Summary Calculation:**
```dart
int getMilestoneCount(List<TimelineEvent> events) {
  return events.where((e) =>
    e.eventType == TimelineEventType.weightMilestone ||
    e.eventType == TimelineEventType.badgeAchievement
  ).length;
}

int getWeeksCount(List<TimelineEvent> events) {
  if (events.isEmpty) return 0;
  final earliest = events.last.date; // Assuming sorted desc
  return DateTime.now().difference(earliest).inDays ~/ 7 + 1;
}
```

**NEW Badge Logic:**
```dart
bool isNew(DateTime eventDate) {
  return DateTime.now().difference(eventDate).inHours < 24;
}
```

---

### Component 6: CelebratoryBadgeWidget

**Purpose:** 뱃지 획득을 즉각적이고 즐거운 경험으로 만들기

**Design Intent:**
- 새 뱃지 획득 시 scale-up 애니메이션
- 다음 획득 가능 뱃지 하이라이트
- 빈 상태 메시지 더 격려적으로

**Visual Specifications:**

```
Section Container:
├── Title: "성취 뱃지"
├── Style: 20px Semibold, #1E293B
├── Spacing: 16px
│
├── Badge Grid (4 columns)
│   ├── crossAxisCount: 4
│   ├── crossAxisSpacing: 16px
│   ├── mainAxisSpacing: 16px
│   ├── childAspectRatio: 0.8
│   │
│   └── Badge Item
│       ├── GestureDetector (tap to show detail)
│       ├── AnimatedScale (scale: _isPressed ? 0.95 : 1.0, 100ms)
│       │
│       ├── Column
│       │   ├── Badge Circle
│       │   │   ├── Size: 80x80px
│       │   │   │
│       │   │   ├── Achieved State:
│       │   │   │   ├── Background: LinearGradient(#F59E0B, #FCD34D)
│       │   │   │   ├── Border: 3px solid #F59E0B
│       │   │   │   ├── Shadow: 0 4px 8px rgba(245,158,11,0.2)
│       │   │   │   ├── Icon Color: #FFFFFF
│       │   │   │
│       │   │   ├── Locked State:
│       │   │   │   ├── Background: #E2E8F0 (Neutral-200)
│       │   │   │   ├── No border
│       │   │   │   ├── Icon Color: #CBD5E1 (Neutral-300)
│       │   │   │
│       │   │   ├── In-Progress State:
│       │   │   │   ├── Background: #F8FAFC (Neutral-50)
│       │   │   │   ├── Border: 2px solid #CBD5E1
│       │   │   │   ├── Icon Color: #94A3B8 (Neutral-400)
│       │   │   │
│       │   │   ├── Next-Up State (closest to achievement):
│       │   │   │   ├── Border: 2px dashed #4ADE80 (Primary)
│       │   │   │   ├── Background: #4ADE80 at 5%
│       │   │   │   ├── Icon Color: #4ADE80
│       │   │
│       │   ├── Spacing: 8px
│       │   │
│       │   ├── Badge Label
│       │   │   ├── Text: metadata.name
│       │   │   ├── Style: 12px Regular, #334155
│       │   │
│       │   ├── Progress Text (In-Progress only)
│       │   │   ├── Text: "{progress}%"
│       │   │   ├── Style: 12px Regular, #64748B

Empty State:
├── Container: Background #F8FAFC, Border #E2E8F0, Radius 12px, Padding 32px
│
├── Icon: Icons.celebration, 48px, #4ADE80 (NOT emoji_events)
├── Title: "첫 뱃지를 향해 나아가고 있어요!"
├── Title Style: 20px Semibold, #334155
├── Description: "목표를 달성하면 멋진 뱃지를 받을 수 있어요."
├── Description Style: 16px Regular, #64748B
├── Button: "목표 확인하기" (GabiumButton, Primary)
```

**Next-Up Badge Detection:**
```dart
UserBadge? getNextUpBadge(List<UserBadge> badges) {
  final inProgress = badges.where((b) => b.status == BadgeStatus.inProgress);
  if (inProgress.isEmpty) return null;
  return inProgress.reduce((a, b) =>
    a.progressPercentage > b.progressPercentage ? a : b
  );
}
```

**Achievement Animation (when badge.isNewlyAchieved):**
```dart
// Add to badge_widget.dart
class _CelebrationAnimation extends StatefulWidget {
  // Scale animation: 0.5 → 1.2 → 1.0 over 400ms with elasticOut curve
}

AnimatedScale(
  scale: widget.badge.isNewlyAchieved ? _celebrationScale : 1.0,
  duration: Duration(milliseconds: 400),
  curve: Curves.elasticOut,
  child: badgeCircle,
)
```

---

## Implementation by Framework

### Flutter

**File Structure:**
```
lib/features/dashboard/presentation/
├── screens/
│   └── home_dashboard_screen.dart (modify imports)
├── widgets/
│   ├── emotional_greeting_widget.dart (NEW)
│   ├── encouraging_progress_widget.dart (NEW)
│   ├── hopeful_schedule_widget.dart (NEW)
│   ├── celebratory_report_widget.dart (NEW)
│   ├── journey_timeline_widget.dart (NEW)
│   ├── celebratory_badge_widget.dart (NEW)
│   ├── greeting_widget.dart (DEPRECATED - keep for reference)
│   ├── weekly_progress_widget.dart (DEPRECATED)
│   ├── next_schedule_widget.dart (DEPRECATED)
│   ├── weekly_report_widget.dart (DEPRECATED)
│   ├── timeline_widget.dart (DEPRECATED)
│   └── badge_widget.dart (DEPRECATED)
└── index.dart (update exports)
```

**Import Pattern:**
```dart
import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/dashboard/domain/entities/dashboard_data.dart';
// DO NOT import from application/ or domain/ (except entities)
```

**home_dashboard_screen.dart Changes:**
```dart
// OLD:
import 'package:n06/features/dashboard/presentation/widgets/greeting_widget.dart';
// NEW:
import 'package:n06/features/dashboard/presentation/widgets/emotional_greeting_widget.dart';

// OLD:
GreetingWidget(dashboardData: dashboardData),
// NEW:
EmotionalGreetingWidget(dashboardData: dashboardData),

// Apply same pattern to all 6 widgets
```

---

## Accessibility Checklist

- [ ] Color contrast meets WCAG AA (4.5:1 minimum)
- [ ] All icons have semantic labels (semanticLabel property)
- [ ] Touch targets minimum 44×44px
- [ ] Progress indicators have textual alternatives
- [ ] Animations respect reduced motion preferences
- [ ] Badge states distinguishable without color alone

---

## Testing Checklist

- [ ] Time-based greeting shows correct message (morning/afternoon/evening)
- [ ] Progress labels show encouraging versions (not original labels)
- [ ] 80%+ achievement shows sparkle animation
- [ ] 70%+ adherence shows Success color and message
- [ ] Symptom icon uses Warning color (not Error)
- [ ] Milestones in timeline have gold glow effect
- [ ] NEW badge appears for events within 24h
- [ ] Next-up badge has dashed border
- [ ] Empty badge state shows celebration icon
- [ ] All tap interactions have press feedback
- [ ] Pull-to-refresh still works

---

## Files to Create/Modify

**New Files:**
- `lib/features/dashboard/presentation/widgets/emotional_greeting_widget.dart`
- `lib/features/dashboard/presentation/widgets/encouraging_progress_widget.dart`
- `lib/features/dashboard/presentation/widgets/hopeful_schedule_widget.dart`
- `lib/features/dashboard/presentation/widgets/celebratory_report_widget.dart`
- `lib/features/dashboard/presentation/widgets/journey_timeline_widget.dart`
- `lib/features/dashboard/presentation/widgets/celebratory_badge_widget.dart`

**Modified Files:**
- `lib/features/dashboard/presentation/screens/home_dashboard_screen.dart` (import changes + widget swaps)
- `lib/features/dashboard/presentation/widgets/index.dart` (export updates)

**Deprecated (DO NOT DELETE, mark as deprecated):**
- `greeting_widget.dart`
- `weekly_progress_widget.dart`
- `next_schedule_widget.dart`
- `weekly_report_widget.dart`
- `timeline_widget.dart`
- `badge_widget.dart`

**Assets Needed:**
- None (using existing Material Icons)
- Optional: Lottie animation for confetti (future enhancement)

---

## Critical Implementation Notes

### DO:
- Use AppColors and AppTypography from design system
- Preserve all existing data flow (dashboardNotifierProvider)
- Keep original widgets as deprecated reference
- Add null safety checks for optional data
- Use const constructors where possible

### DO NOT:
- Modify DashboardData entity
- Create new providers or notifiers
- Change any Application/Domain/Infrastructure files
- Hardcode strings (use functions for dynamic content)
- Remove original business logic calls

### Message Generation Pattern:
```dart
// CORRECT: Content-driven, not hardcoded
String getMessage(int value, String type) {
  // Logic based on data
}

// WRONG: Hardcoded strings scattered in UI
Text('7일을 잘 견뎌냈어요') // Never do this
```

---

**Note:** Component Registry will be updated in Phase 3 after implementation is complete.
