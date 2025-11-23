# Onboarding Screen Implementation Guide

## Implementation Summary

Based on the approved Improvement Proposal (v1), this guide provides exact specifications for implementing the onboarding flow redesign. The 4-step wizard will be updated to align with Gabium Design System while preserving all validation logic and navigation patterns.

**Changes to Implement:**
- Replace Material components with Gabium-branded widgets (GabiumTextField, GabiumButton)
- Implement Gabium typography scale (2xl, xl, base, sm)
- Add hero/welcome section to Step 1 for context and brand alignment
- Create semantic alert banners (ValidationAlert) for error/warning/info messages
- Restructure summary section using card-based layout (SummaryCard)
- Enhance progress indicator styling (8px height, semantic colors)
- Apply Gabium spacing scale consistently (xl, lg, md, sm)
- Add focus/disabled state styling using Gabium tokens

---

## Design Token Values

| Element | Token Path | Value | Usage |
|---------|-----------|-------|-------|
| Page Padding (H) | Spacing - xl | 32px | Horizontal container padding |
| Section Spacing | Spacing - lg | 24px | Between major sections |
| Field Spacing | Spacing - md | 16px | Between form fields |
| Step Title | Typography - xl | 20px, Semibold | Section headers |
| Welcome Title | Typography - 2xl | 24px, Bold | Hero section (Step 1) |
| Body Text | Typography - base | 16px, Regular | Input labels, body content |
| Helper Text | Typography - sm | 14px, Regular | Label text, helper text |
| Caption | Typography - xs | 12px, Regular | Error messages, small text |
| Input Height | Sizing - Medium | 48px | All form inputs |
| Input Border Radius | Border Radius - sm | 8px | Input fields, buttons |
| Button Height | Sizing - Medium | 44px | CTA buttons |
| Button Color | Colors - Primary | #4ADE80 | Button background, links |
| Error Color | Colors - Error | #EF4444 | Error messages, invalid state |
| Warning Color | Colors - Warning | #F59E0B | Warning messages |
| Success Color | Colors - Success | #10B981 | Success messages |
| Info Color | Colors - Info | #3B82F6 | Info messages |
| Input Background | Colors - Neutral | #FFFFFF | Input field background |
| Input Border | Colors - Neutral - 300 | #CBD5E1 | Default input border |
| Focus Background | Colors - Primary at 10% | #4ADE80 (10%) | Input focus background |
| Error Background | Colors - Error at 5% | #FEF2F2 | Error message background |
| Warning Background | Colors - Warning at 5% | #FFFBEB | Warning message background |
| Info Background | Colors - Info at 5% | #EFF6FF | Info message background |
| Card Background | Colors - White | #FFFFFF | Summary cards |
| Card Border | Colors - Neutral - 200 | #E2E8F0 | Card borders |
| Card Shadow | Shadow - sm | 0 2px 4px rgba(15,23,42,0.06) | Card elevation |
| Progress Fill | Colors - Primary | #4ADE80 | Progress bar fill |
| Progress Background | Colors - Neutral - 200 | #E2E8F0 | Progress bar background |
| Neutral Text | Colors - Neutral - 500 | #64748B | Secondary text, placeholder |
| Label Text | Colors - Neutral - 700 | #334155 | Input labels |

---

## Component Specifications

### Change 1: Hero/Welcome Section for Step 1

**Component Type:** AuthHeroSection (reusable)

**Visual Specifications:**
- Title: "가비움 온보딩을 시작하세요" or "당신의 건강 관리 시작"
  - Font Size: 24px (2xl), Bold (700)
  - Color: #1E293B (Neutral-800)
- Subtitle: (Optional context about onboarding)
  - Font Size: 16px (base), Regular (400)
  - Color: #475569 (Neutral-600)
- Background: #F8FAFC (Neutral-50)
- Padding: 32px top, 16px bottom/sides (xl/md)
- Icon: Optional (e.g., medical bag icon, 48px, #4ADE80)

**Sizing:**
- Width: 100% of container
- Height: Auto (content-driven)

**Interactive States:**
- N/A (informational component)

**Accessibility:**
- ARIA label: Not required (decorative)
- Text contrast: 4.5:1 (WCAG AA compliant)
- Keyboard navigation: No interaction

---

### Change 2: Redesigned Form Inputs Using GabiumTextField

**Component Type:** GabiumTextField (existing, reuse)

**Visual Specifications (All Text Inputs):**
- Height: 48px
- Padding: 12px vertical, 16px horizontal
- Border: 2px solid #CBD5E1 (Neutral-300)
- Border Radius: 8px (sm)
- Background: #FFFFFF
- Font: 16px (base), Regular (400)
- Label: 14px (sm), Semibold (600), #334155 (Neutral-700)
- Placeholder: #94A3B8 (Neutral-400)

**Interactive States:**

**Default:**
- Border: 2px solid #CBD5E1
- Background: #FFFFFF

**Focus:**
- Border: 2px solid #4ADE80 (Primary)
- Background: #4ADE80 at 10% opacity (#E7F9E9 approx)
- Outline: None

**Error:**
- Border: 2px solid #EF4444
- Error Message: Below input, 4px spacing
  - Font: 12px (xs), Medium (500), #EF4444
  - Icon: alert-circle 16px

**Disabled:**
- Background: #F1F5F9 (Neutral-100)
- Text Color: #94A3B8 (Neutral-400)
- Opacity: 0.6
- Cursor: not-allowed

---

### Change 3: Replace ElevatedButton with GabiumButton

**Component Type:** GabiumButton (existing, reuse)

**Visual Specifications:**
- Variant: Primary
- Size: Medium (44px height)
- Width: 100% (full width in forms)
- Background: #4ADE80 (Primary)
- Text: White (#FFFFFF), Semibold (600), 16px (base)
- Border Radius: 8px (sm)
- Shadow: sm (0 2px 4px rgba(15,23,42,0.06))

**Interactive States:**

**Default:**
- Background: #4ADE80
- Shadow: sm
- Cursor: pointer

**Hover:**
- Background: #22C55E (Green-500)
- Shadow: md
- Cursor: pointer

**Active/Pressed:**
- Background: #16A34A (Green-600)
- Shadow: xs

**Disabled:**
- Background: #4ADE80 at 40% opacity
- Text: White at 50% opacity
- Cursor: not-allowed

**Loading:**
- Background: #4ADE80
- Text: Hidden
- Spinner: 24px, white, centered
- Button size maintained (44px height)

---

### Change 4: Semantic Color System for Validation Feedback

**Component Type:** ValidationAlert (NEW - to create)

**Visual Specifications:**

**Error Alert:**
- Border: 4px solid #EF4444 (left border only)
- Background: #FEF2F2
- Text: #991B1B (Dark Error)
- Font: 14px (base), Regular (400)
- Icon: alert-circle 24px, left-aligned
- Padding: 16px (md)
- Border Radius: 8px (sm)

**Warning Alert:**
- Border: 4px solid #F59E0B (left border only)
- Background: #FFFBEB
- Text: #92400E (Dark Warning)
- Font: 14px (base), Regular (400)
- Icon: alert-triangle 24px
- Padding: 16px (md)
- Border Radius: 8px (sm)

**Info Alert:**
- Border: 4px solid #3B82F6 (left border only)
- Background: #EFF6FF
- Text: #1E40AF (Dark Info)
- Font: 14px (base), Regular (400)
- Icon: info 24px
- Padding: 16px (md)
- Border Radius: 8px (sm)

**Success Alert:**
- Border: 4px solid #10B981 (left border only)
- Background: #ECFDF5
- Text: #065F46 (Dark Success)
- Font: 14px (base), Regular (400)
- Icon: check-circle 24px
- Padding: 16px (md)
- Border Radius: 8px (sm)

**Spacing:**
- Margin: 24px (lg) above, 24px (lg) below (between sections)
- Multiple alerts: 8px (sm) spacing between

**Accessibility:**
- ARIA role: alert
- ARIA live: assertive
- Color not sole information method (icon + text)

---

### Change 5: Summary Card Component

**Component Type:** SummaryCard (NEW - to create)

**Visual Specifications:**

**Card Container:**
- Background: #FFFFFF
- Border: 1px solid #E2E8F0 (Neutral-200) OR no border with shadow
- Border Radius: 12px (md)
- Shadow: sm (0 2px 4px rgba(15,23,42,0.06))
- Padding: 16px (md)

**Card Title:**
- Font: 18px (lg), Semibold (600)
- Color: #1E293B (Neutral-800)
- Padding: 0 0 16px 0

**Card Items (Data pairs):**
- Layout: Flex column, gap 12px (sm spacing)
- Label: 14px (sm), Medium (500), #334155 (Neutral-700)
- Value: 16px (base), Regular (400), #475569 (Neutral-600)
- Separator: None between items (vertical spacing only)
- Last item: No extra spacing

**Sizing:**
- Width: 100% of container
- Height: Auto (content-driven)

**Spacing Between Cards:**
- 24px (lg) vertical gap

**Hover Effect (Optional):**
- Shadow: md
- Transform: translateY(-2px)

**Accessibility:**
- Semantic structure: Use article or section tag
- Tab order: Natural (top-to-bottom)

---

### Change 6: Progress Indicator Enhancement

**Component Type:** Enhanced LinearProgressIndicator + Text

**Visual Specifications:**

**Progress Bar:**
- Height: 8px (increased from 4px)
- Background: #E2E8F0 (Neutral-200)
- Fill: #4ADE80 (Primary)
- Border Radius: 999px (full/rounded)
- Width: 100% of container
- Padding: 0 (no padding, full width)

**Step Indicator Text:**
- Font: 14px (sm), Regular (400)
- Color: #64748B (Neutral-500)
- Format: "{currentStep + 1}/4단계"
- Padding: 16px top (below progress bar)

**Animation:**
- Duration: 300ms (smooth transition)
- Easing: Curves.easeInOut

**Spacing:**
- Progress bar to step text: 8px (sm)
- Step text to content: 16px (md)

---

### Change 7: Typography Scale Implementation

**Applied Across All Text:**

| Element | Token | Size | Weight | Usage |
|---------|-------|------|--------|-------|
| Page Title | 2xl | 24px | Bold (700) | Step 1 hero title |
| Section Headers | xl | 20px | Semibold (600) | Steps 2-4 titles |
| Input Labels | sm | 14px | Semibold (600) | GabiumTextField labels |
| Body/Body Text | base | 16px | Regular (400) | Input hints, body content |
| Helper/Error Text | xs/sm | 12-14px | Regular/Medium | Error messages, captions |
| Step Indicator | sm | 14px | Regular (400) | Progress text |

**Font Family:** Pretendard Variable (all text)

---

### Change 8: Spacing Scale Consistency

**Applied Throughout:**

| Element | Spacing Token | Value | Usage |
|---------|----------------|-------|-------|
| Page Padding | xl | 32px | Container sides |
| Section Gap | lg | 24px | Between sections |
| Field Gap | md | 16px | Between input fields |
| Label Spacing | md | 16px | Below section title to first field |
| Button Spacing | md | 16px | Above button from last field |
| Alert Spacing | lg | 24px | Above/below alerts |
| Card Spacing | lg | 24px | Between summary cards |
| Inner Padding | md/sm | 16px/8px | Card/field padding |

---

## Layout Specification

### Overall Onboarding Flow

```
┌─────────────────────────────────────────┐
│ App Bar                                 │
│ Title: "온보딩"                          │
│ Back: Conditional (disabled on step 1)  │
└─────────────────────────────────────────┘
┌─────────────────────────────────────────┐
│ LinearProgressIndicator (8px, Primary)  │
├─────────────────────────────────────────┤
│ "X/4단계" (sm text, Neutral-500)        │
├─────────────────────────────────────────┤
│                                         │
│ PageView[4 steps]                       │
│ (NeverScrollableScrollPhysics)          │
│                                         │
│ STEP 1: Profile Setup                  │
│ ┌───────────────────────────────────┐  │
│ │ [AuthHeroSection]                 │  │
│ │ Title: Hero context               │  │
│ │ Subtitle: Welcoming message       │  │
│ ├───────────────────────────────────┤  │
│ │ [GabiumTextField]                 │  │
│ │ Label: "성명"                      │  │
│ │ Placeholder: "성명"                │  │
│ ├───────────────────────────────────┤  │
│ │ [GabiumButton Primary]            │  │
│ │ "다음"                            │  │
│ └───────────────────────────────────┘  │
│                                         │
│ STEP 2: Weight & Goal                  │
│ ┌───────────────────────────────────┐  │
│ │ Title: "체중 및 목표 설정" (xl)    │  │
│ │ Spacing: md below                 │  │
│ ├───────────────────────────────────┤  │
│ │ [GabiumTextField]                 │  │
│ │ Label: "현재 체중 (kg)"             │  │
│ │ Input type: decimal               │  │
│ ├───────────────────────────────────┤  │
│ │ [Spacing md]                      │  │
│ ├───────────────────────────────────┤  │
│ │ [GabiumTextField]                 │  │
│ │ Label: "목표 체중 (kg)"             │  │
│ │ Input type: decimal               │  │
│ ├───────────────────────────────────┤  │
│ │ [Spacing md]                      │  │
│ ├───────────────────────────────────┤  │
│ │ [GabiumTextField]                 │  │
│ │ Label: "목표 기간 (주, 선택)"      │  │
│ │ Input type: number                │  │
│ ├───────────────────────────────────┤  │
│ │ [Spacing lg]                      │  │
│ ├───────────────────────────────────┤  │
│ │ [ValidationAlert - Error] (if)    │  │
│ │ "현재 체중은 20kg 이상..."         │  │
│ ├───────────────────────────────────┤  │
│ │ [ValidationAlert - Info]          │  │
│ │ "주간 목표: X.XXkg/주"             │  │
│ ├───────────────────────────────────┤  │
│ │ [ValidationAlert - Warning] (if)  │  │
│ │ "⚠ 주간 목표가 1kg을 초과합니다"  │  │
│ ├───────────────────────────────────┤  │
│ │ [Spacing md]                      │  │
│ ├───────────────────────────────────┤  │
│ │ [GabiumButton Primary]            │  │
│ │ "다음"                            │  │
│ └───────────────────────────────────┘  │
│                                         │
│ STEP 3: Dosage Plan                    │
│ ┌───────────────────────────────────┐  │
│ │ Title: "투여 계획 설정" (xl)      │  │
│ │ Spacing: md below                 │  │
│ ├───────────────────────────────────┤  │
│ │ [DropdownButtonFormField]         │  │
│ │ Label: "약물명"                    │  │
│ │ Height: 48px (consistent)         │  │
│ ├───────────────────────────────────┤  │
│ │ [Spacing md]                      │  │
│ ├───────────────────────────────────┤  │
│ │ [ListTile for Date Picker]        │  │
│ │ Label: "시작일"                    │  │
│ │ OnTap: showDatePicker              │  │
│ ├───────────────────────────────────┤  │
│ │ [Spacing md]                      │  │
│ ├───────────────────────────────────┤  │
│ │ [GabiumTextField - Disabled]      │  │
│ │ Label: "투여 주기 (일)" (read-only) │  │
│ │ Background: Neutral-100           │  │
│ ├───────────────────────────────────┤  │
│ │ [Spacing md]                      │  │
│ ├───────────────────────────────────┤  │
│ │ [DropdownButtonFormField]         │  │
│ │ Label: "초기 용량 (mg)"             │  │
│ │ Height: 48px                      │  │
│ ├───────────────────────────────────┤  │
│ │ [Spacing lg]                      │  │
│ ├───────────────────────────────────┤  │
│ │ [ValidationAlert - Error] (if)    │  │
│ │ (validation failure message)      │  │
│ ├───────────────────────────────────┤  │
│ │ [Spacing md]                      │  │
│ ├───────────────────────────────────┤  │
│ │ [GabiumButton Primary]            │  │
│ │ "다음"                            │  │
│ └───────────────────────────────────┘  │
│                                         │
│ STEP 4: Summary & Confirmation         │
│ ┌───────────────────────────────────┐  │
│ │ Title: "정보 확인" (xl)            │  │
│ │ Spacing: lg below                 │  │
│ ├───────────────────────────────────┤  │
│ │ [SummaryCard]                     │  │
│ │ Title: "기본 정보"                 │  │
│ │ Items:                            │  │
│ │  - 이름: {name}                    │  │
│ │  - 현재 체중: {weight} kg           │  │
│ │  - 목표 체중: {target} kg           │  │
│ │  - 감량 목표: {diff} kg             │  │
│ ├───────────────────────────────────┤  │
│ │ [Spacing lg]                      │  │
│ ├───────────────────────────────────┤  │
│ │ [SummaryCard]                     │  │
│ │ Title: "투여 계획"                 │  │
│ │ Items:                            │  │
│ │  - 약물명: {med}                   │  │
│ │  - 시작일: {date}                  │  │
│ │  - 주기: {cycle}일                 │  │
│ │  - 초기 용량: {dose} mg             │  │
│ ├───────────────────────────────────┤  │
│ │ [Spacing lg]                      │  │
│ ├───────────────────────────────────┤  │
│ │ [Loading Spinner / Error / OK]    │  │
│ │ - Spinner: 48px, Primary          │  │
│ │ - Error: ValidationAlert + Retry  │  │
│ │ - OK: Ready for confirmation      │  │
│ ├───────────────────────────────────┤  │
│ │ [GabiumButton Primary]            │  │
│ │ "확인" (saves + navigates)        │  │
│ └───────────────────────────────────┘  │
│                                         │
└─────────────────────────────────────────┘
```

### Responsive Behavior

**Mobile (< 768px):**
- Page padding: xl (32px) horizontal
- Single column layout
- Full-width buttons
- Standard spacing scale

**Tablet (768px - 1024px):**
- Same as mobile (single column optimization for forms)
- Page padding can increase to 48px if desired

**Desktop (> 1024px):**
- Same as mobile/tablet (form UX is best single-column)
- Consider max-width constraint (e.g., 600px max-width, centered)

---

## Interaction Specifications

### Step 1: Profile Input

**Name Input Field:**
- Click/Tap: Focus input, show cursor
- Type: Update validation state
- Visual feedback: Focus state (border color + background change)
- Keyboard: Standard text input

**Next Button:**
- Enabled only when name is not empty
- Click: Trigger navigation to Step 2 (PageView.nextPage)
- Duration: 300ms slide animation

---

### Step 2: Weight & Goal Input

**Weight/Period Input Fields:**
- Change trigger: Recalculate weekly goal
- Error display: Show ValidationAlert with red styling
- Warning display: Show ValidationAlert with amber styling when weekly goal > 1kg

**Dynamic Calculations:**
- Weekly Goal = (Current Weight - Target Weight) / Target Period
- Real-time update as user types

**Next Button:**
- Disabled while errors exist
- Enabled when: current weight valid AND target weight valid AND target < current AND errors == null

---

### Step 3: Dosage Plan Input

**Medication Dropdown:**
- Tap: Show list of medication templates
- Selection: Auto-fill recommended start dose
- Behavior: Update dose dropdown options

**Start Date Input:**
- Tap: Show Material DatePicker
- Selection: Update displayed date

**Cycle Field:**
- Auto-fill based on selected medication
- Disabled state (read-only)

**Dose Dropdown:**
- Tap: Show list of available doses for selected medication
- Selection: Enable Next button if valid

**Next Button:**
- Disabled while medication not selected OR dose not selected
- Click: Trigger navigation to Step 4

---

### Step 4: Summary & Confirmation

**Summary Display:**
- Load onboarding state (read from Riverpod provider)
- Display data in card-based layout

**Loading State:**
- Show spinner (48px, Primary color)
- Center-aligned on screen
- Disable all interactions

**Success State:**
- Display confirm button
- Click: Trigger saveOnboardingData()
- After save: Check context.mounted, then onComplete() callback or context.go('/home')

**Error State:**
- Show ValidationAlert with error message
- Display retry button
- Click retry: Call retrySave() to retry save operation

---

## Implementation by Framework

### Flutter

**File Structure:**
```
lib/features/onboarding/presentation/
├── screens/
│   └── onboarding_screen.dart (MODIFIED)
├── widgets/
│   ├── basic_profile_form.dart (MODIFIED)
│   ├── weight_goal_form.dart (MODIFIED)
│   ├── dosage_plan_form.dart (MODIFIED)
│   ├── summary_screen.dart (MODIFIED)
│   ├── validation_alert.dart (NEW)
│   └── summary_card.dart (NEW)
```

**Import Pattern:**
```dart
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_text_field.dart';
import 'package:n06/features/authentication/presentation/widgets/auth_hero_section.dart';
```

### Key Implementation Patterns

**GabiumTextField Usage:**
```dart
GabiumTextField(
  controller: _nameController,
  label: '성명',
  hint: '성명',
  helperText: 'Optional helper text',
  errorText: _errorMessage,
  keyboardType: TextInputType.text,
  onChanged: (value) {
    widget.onNameChanged(value);
  },
)
```

**GabiumButton Usage:**
```dart
GabiumButton(
  text: '다음',
  onPressed: _isNameValid ? widget.onNext : null,
  variant: GabiumButtonVariant.primary,
  size: GabiumButtonSize.medium,
  isLoading: _isLoading,
)
```

**AuthHeroSection Usage:**
```dart
AuthHeroSection(
  title: '가비움 온보딩을 시작하세요',
  subtitle: '당신의 건강 관리 여정을 함께합니다',
  icon: Icons.health_and_safety,
)
```

**ValidationAlert (to be created):**
```dart
ValidationAlert(
  type: ValidationAlertType.error,
  message: '현재 체중은 20kg 이상 300kg 이하여야 합니다.',
  icon: Icons.error_outline,
)
```

**SummaryCard (to be created):**
```dart
SummaryCard(
  title: '기본 정보',
  items: [
    ('이름', name),
    ('현재 체중', '$currentWeight kg'),
    ('목표 체중', '$targetWeight kg'),
  ],
)
```

### Design System Token Constants (Reference)

Create a constants file or use design system extension:
```dart
// lib/core/design/gabium_colors.dart
const Color primaryColor = Color(0xFF4ADE80);
const Color errorColor = Color(0xFFEF4444);
const Color warningColor = Color(0xFFF59E0B);
const Color infoColor = Color(0xFF3B82F6);
const Color successColor = Color(0xFF10B981);
const Color neutral50 = Color(0xFFF8FAFC);
const Color neutral100 = Color(0xFFF1F5F9);
const Color neutral200 = Color(0xFFE2E8F0);
const Color neutral300 = Color(0xFFCBD5E1);
const Color neutral400 = Color(0xFF94A3B8);
const Color neutral500 = Color(0xFF64748B);
const Color neutral600 = Color(0xFF475569);
const Color neutral700 = Color(0xFF334155);
const Color neutral800 = Color(0xFF1E293B);
const Color neutral900 = Color(0xFF0F172A);

// lib/core/design/gabium_spacing.dart
const double spacingXs = 4;
const double spacingSm = 8;
const double spacingMd = 16;
const double spacingLg = 24;
const double spacingXl = 32;
const double spacing2xl = 48;

// lib/core/design/gabium_typography.dart
const double fontSizeXs = 12;
const double fontSizeSm = 14;
const double fontSizeBase = 16;
const double fontSizeLg = 18;
const double fontSizeXl = 20;
const double fontSize2xl = 24;
const double fontSize3xl = 28;
```

---

## Accessibility Checklist

- [ ] **Color Contrast:**
  - [ ] Primary button text on background: 4.5:1 (WCAG AA)
  - [ ] Error alert text on background: 4.5:1 (WCAG AA)
  - [ ] Warning alert text on background: 4.5:1 (WCAG AA)
  - [ ] All labels readable

- [ ] **Keyboard Navigation:**
  - [ ] Tab order: Logical flow (top to bottom, left to right)
  - [ ] Focus indicators: Visible on all interactive elements (2px border)
  - [ ] Enter/Space: Buttons activate on press
  - [ ] Tab focuses next field

- [ ] **Focus States:**
  - [ ] Input fields: 2px solid #4ADE80 border, background tint
  - [ ] Buttons: 2px offset outline (or high-contrast change)
  - [ ] Indicators: Clear visual feedback

- [ ] **Touch Targets:**
  - [ ] Buttons: 44x44px minimum
  - [ ] Input fields: 48px height (comfortable)
  - [ ] Spacing between targets: 8px minimum

- [ ] **Screen Reader Support:**
  - [ ] Form labels associated with inputs
  - [ ] Error messages announced (ARIA alert role)
  - [ ] Alert banners marked with `role="alert"` + `aria-live="assertive"`
  - [ ] Form structure semantic

- [ ] **Motion:**
  - [ ] Transitions: Smooth 300ms (not jarring)
  - [ ] Respect prefers-reduced-motion (optional enhancement)

---

## Testing Checklist

- [ ] **Step 1: Profile Setup**
  - [ ] Name validation works (empty vs non-empty)
  - [ ] Next button enables/disables correctly
  - [ ] Hero section displays with correct styling
  - [ ] Focus state on input field shows Primary border

- [ ] **Step 2: Weight & Goal**
  - [ ] Weight range validation (20-300kg)
  - [ ] Target weight < current weight validation
  - [ ] Weekly goal calculation correct
  - [ ] Error alert displays when validation fails
  - [ ] Warning alert displays when weekly goal > 1kg
  - [ ] Info alert displays with calculated weekly goal
  - [ ] All alerts use correct colors and styling
  - [ ] Next button state follows validation

- [ ] **Step 3: Dosage Plan**
  - [ ] Medication dropdown populates correctly
  - [ ] Selected medication auto-fills dose
  - [ ] Date picker shows and updates correctly
  - [ ] Cycle field displays (read-only) with medication value
  - [ ] Dose dropdown populates based on medication
  - [ ] Error alert shows when validation fails
  - [ ] Next button enables only when selections complete

- [ ] **Step 4: Summary**
  - [ ] Summary cards display all data correctly
  - [ ] Card styling matches specifications (shadow, border, padding)
  - [ ] Loading spinner shows during save
  - [ ] Error alert displays if save fails
  - [ ] Retry button triggers retrySave()
  - [ ] Confirm button saves and navigates correctly
  - [ ] context.mounted check prevents errors

- [ ] **Navigation:**
  - [ ] Back button disabled on Step 1
  - [ ] Back button enabled on Steps 2-4
  - [ ] Back button navigates to previous step
  - [ ] Next button navigates to next step
  - [ ] PageView animation smooth (300ms)
  - [ ] Progress indicator updates with step

- [ ] **Visual Consistency:**
  - [ ] All inputs use GabiumTextField
  - [ ] All CTA buttons use GabiumButton (Primary)
  - [ ] All text uses Gabium typography scale
  - [ ] Spacing follows lg/md/sm scale (no hardcoded values)
  - [ ] Colors match token values (no custom colors)
  - [ ] No Material default styles visible

- [ ] **Responsive:**
  - [ ] Mobile (< 768px): Single column, full-width buttons
  - [ ] Tablet (768-1024px): Same as mobile
  - [ ] Padding and spacing scale appropriately

---

## Files to Create/Modify

**New Files:**
1. `lib/features/onboarding/presentation/widgets/validation_alert.dart`
   - ValidationAlert component
   - Supports: error, warning, info, success types
   - Reusable across app

2. `lib/features/onboarding/presentation/widgets/summary_card.dart`
   - SummaryCard component
   - Displays grouped data with title
   - Reusable for other summary screens

**Modified Files:**
1. `lib/features/onboarding/presentation/screens/onboarding_screen.dart`
   - Update progress indicator height (8px)
   - Adjust spacing (use design tokens)
   - Update text styling (typography scale)

2. `lib/features/onboarding/presentation/widgets/basic_profile_form.dart`
   - Replace TextField with GabiumTextField
   - Add AuthHeroSection to top
   - Replace ElevatedButton with GabiumButton
   - Update typography and spacing

3. `lib/features/onboarding/presentation/widgets/weight_goal_form.dart`
   - Replace all TextFields with GabiumTextField
   - Replace error/warning/info containers with ValidationAlert
   - Replace ElevatedButton with GabiumButton
   - Update typography and spacing

4. `lib/features/onboarding/presentation/widgets/dosage_plan_form.dart`
   - Update DropdownButtonFormField styling (height, border radius)
   - Replace TextFormField with GabiumTextField
   - Replace error container with ValidationAlert
   - Replace ElevatedButton with GabiumButton
   - Update typography and spacing

5. `lib/features/onboarding/presentation/widgets/summary_screen.dart`
   - Replace _SummarySection with SummaryCard
   - Replace error container with ValidationAlert
   - Update typography and spacing
   - Maintain Riverpod state management pattern

**Assets Needed:**
- None (all icons use Material Symbols/Icons)

---

## Implementation Order

1. **Create new components** (Phase 2C priority 1)
   - ValidationAlert widget
   - SummaryCard widget

2. **Update onboarding_screen.dart** (Phase 2C priority 2)
   - Progress indicator styling
   - Spacing updates
   - Typography updates

3. **Update basic_profile_form.dart** (Phase 2C priority 3)
   - Add AuthHeroSection
   - Replace TextField → GabiumTextField
   - Replace ElevatedButton → GabiumButton
   - Update styling and spacing

4. **Update weight_goal_form.dart** (Phase 2C priority 4)
   - Replace TextFields → GabiumTextField
   - Replace validation containers → ValidationAlert
   - Replace ElevatedButton → GabiumButton
   - Update styling and spacing

5. **Update dosage_plan_form.dart** (Phase 2C priority 5)
   - Update dropdown styling
   - Replace TextFormField → GabiumTextField
   - Replace error container → ValidationAlert
   - Replace ElevatedButton → GabiumButton
   - Update styling and spacing

6. **Update summary_screen.dart** (Phase 2C priority 6)
   - Replace _SummarySection → SummaryCard
   - Replace error container → ValidationAlert
   - Update styling and spacing
   - Test with onboardingNotifierProvider state

7. **Testing & Validation** (Phase 2C priority 7)
   - Run full onboarding flow
   - Verify all states (loading, error, success)
   - Test accessibility (keyboard navigation, screen reader)
   - Verify visual consistency

---

## Validation Steps

**Before considering implementation complete:**

1. ✅ All GabiumTextField fields visible with correct labels and states
2. ✅ All GabiumButton buttons styled with Primary variant
3. ✅ All validation alerts display with correct colors/icons
4. ✅ Step 1 hero section displays correctly
5. ✅ Step 4 summary cards display with proper grouping
6. ✅ Progress indicator is 8px tall with Primary fill color
7. ✅ All text uses Gabium typography scale (no inline font sizes)
8. ✅ Spacing follows scale (no hardcoded padding except token values)
9. ✅ Focus states show Primary border on inputs
10. ✅ Next button enables/disables based on validation
11. ✅ Navigation works (forward/backward with PageView)
12. ✅ Summary shows correct data from all steps
13. ✅ Save operation shows loading spinner
14. ✅ Error retry works correctly
15. ✅ No Material default styles visible (clean Gabium design)

---

## Rollback Plan

If issues arise during implementation:

1. **Git restore** modified widget files to last commit
2. **Keep** new ValidationAlert and SummaryCard files (safe additions)
3. **Revert** onboarding_screen.dart changes (spacing/styling)
4. **Return** to Phase 2A if component dependencies broken

**Recovery time:** < 30 minutes (straightforward widget replacement)

---

**Document Version:** v1
**Framework:** Flutter
**Date:** 2025-11-23
**Status:** Ready for Phase 2C Implementation
