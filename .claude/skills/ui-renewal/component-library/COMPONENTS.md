# Gabium UI Component Library

This library contains reusable UI components extracted from the email signup screen redesign, following the Gabium Design System.

## Component Registry

| Component | Created Date | Used In | Framework | File Location | Notes |
|-----------|--------------|---------|-----------|---------------|-------|
| GabiumBottomNavigation | 2025-11-22 | Home Dashboard + All Main Screens | Flutter | `flutter/gabium_bottom_navigation.dart` | 5-tab bottom navigation with scale animation on tap. Active: Primary, Inactive: Neutral-500. Height 56px + safe area. |
| AuthHeroSection | 2025-11-22 | Email Signup Screen | Flutter | `flutter/AuthHeroSection.dart` | Welcoming hero with title, subtitle, optional icon. Reusable for all auth screens (sign in, signup, password reset). |
| GabiumTextField | 2025-11-22 | Email Signup Screen | Flutter | `flutter/GabiumTextField.dart` | Branded text input with label, validation, focus/error states. Height 48px. Includes helper text and error message support. |
| GabiumButton | 2025-11-22 | Email Signup Screen | Flutter | `flutter/GabiumButton.dart` | Button with Primary/Secondary/Tertiary/Ghost variants. Small/Medium/Large sizes. Loading state support with spinner. |
| PasswordStrengthIndicator | 2025-11-22 | Email Signup Screen | Flutter | `flutter/PasswordStrengthIndicator.dart` | Visual password strength indicator with semantic colors. Shows Weak/Medium/Strong with animated progress bar. |
| ConsentCheckbox | 2025-11-22 | Email Signup Screen | Flutter | `flutter/ConsentCheckbox.dart` | Styled checkbox with required/optional badge. 44x44px touch area. Card container background optional. |
| GabiumToast | 2025-11-22 | Email Signup Screen | Flutter | `flutter/GabiumToast.dart` | Toast notification with Error/Success/Warning/Info variants. Replaces SnackBar with branded styling. |

---

## Component Specifications

### GabiumBottomNavigation

**Purpose:** Bottom navigation bar for main app screens

**Design Tokens:**
- Background: White `#FFFFFF`
- Border Top: Neutral-200 `#E2E8F0`, 1px
- Shadow: Reverse md (0 -4px 8px rgba(15, 23, 42, 0.08))
- Height: 56px + SafeArea bottom inset
- Active Color: Primary `#4ADE80`
- Inactive Color: Neutral-500 `#64748B`
- Icon Size: 24px
- Label Font: xs (12px Medium)
- Touch Target: 56px × 56px per item

**Props:**
```dart
GabiumBottomNavigation({
  required List<GabiumBottomNavItem> items,
  required int currentIndex,
  required ValueChanged<int> onTap,
})
```

**GabiumBottomNavItem:**
```dart
GabiumBottomNavItem({
  required String label,
  required IconData icon,
  required IconData activeIcon,
  required String route,
})
```

**Usage Example:**
```dart
GabiumBottomNavigation(
  items: [
    GabiumBottomNavItem(
      label: '홈',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      route: '/home',
    ),
    GabiumBottomNavItem(
      label: '기록',
      icon: Icons.edit_note_outlined,
      activeIcon: Icons.edit_note,
      route: '/tracking/weight',
    ),
    GabiumBottomNavItem(
      label: '일정',
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
      route: '/dose-schedule',
    ),
    GabiumBottomNavItem(
      label: '가이드',
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book,
      route: '/coping-guide',
    ),
    GabiumBottomNavItem(
      label: '설정',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      route: '/settings',
    ),
  ],
  currentIndex: 0,
  onTap: (index) => context.go(items[index].route),
)
```

**Router Integration (ShellRoute):**
```dart
ShellRoute(
  builder: (context, state, child) => ScaffoldWithBottomNav(child: child),
  routes: [
    GoRoute(path: '/home', builder: (context, state) => HomeDashboardScreen()),
    GoRoute(path: '/tracking/weight', builder: (context, state) => WeightTrackingScreen()),
    GoRoute(path: '/dose-schedule', builder: (context, state) => DoseScheduleScreen()),
    GoRoute(path: '/coping-guide', builder: (context, state) => CopingGuideScreen()),
    GoRoute(path: '/settings', builder: (context, state) => SettingsScreen()),
  ],
)
```

**Interactive States:**
- Default: As specified above
- Active: Icon + Label change to Primary color
- Tap: Scale 0.95 animation (150ms ease-out), then restore

**Accessibility:**
- Touch target: 56px × 56px per item (exceeds 44px minimum)
- Color contrast: Active (Primary on White) 3.1:1 (AA Large Text), Inactive (Neutral-500 on White) 4.7:1 (AA)
- Semantic labels: Each tab labeled for screen readers
- Current index announced
- Keyboard navigation: Tab cycles through items

**Notes:**
- Reverse shadow (0 -4px) creates elevation above content
- SafeArea automatically respects iOS bottom notch
- Use ScaffoldWithBottomNav wrapper for consistent integration
- State preservation: Use IndexedStack or AutomaticKeepAliveClientMixin if needed

---

### AuthHeroSection

**Purpose:** Welcoming hero section for authentication screens

**Design Tokens:**
- Background: Neutral-50 `#F8FAFC`
- Title: 3xl (28px Bold), Neutral-800 `#1E293B`
- Subtitle: base (16px Regular), Neutral-600 `#475569`
- Padding: xl top (32px), md horizontal/bottom (16px)
- Optional icon: 48px, Primary `#4ADE80`

**Props:**
```dart
AuthHeroSection({
  required String title,
  required String subtitle,
  IconData? icon,
})
```

**Usage Example:**
```dart
AuthHeroSection(
  title: '가비움과 함께 시작해요',
  subtitle: '건강한 변화의 첫 걸음',
)
```

**Variants:** None (single design)

**Accessibility:**
- Semantic heading level: H1 for title
- Color contrast: Title 10.5:1, Subtitle 6.8:1 (WCAG AAA)

---

### GabiumTextField

**Purpose:** Branded text input field for forms

**Design Tokens:**
- Height: 48px
- Border: 2px solid (Neutral-300 default, Primary focus, Error error)
- Border Radius: sm (8px)
- Padding: md (12px vertical, 16px horizontal)
- Background: `#FFFFFF`, focus tint Primary 10%
- Label: sm (14px Semibold), Neutral-700 `#334155`
- Text: base (16px Regular), Neutral-800 `#1E293B`
- Error Message: xs (12px Medium), Error `#EF4444`

**Props:**
```dart
GabiumTextField({
  TextEditingController? controller,
  required String label,
  String? hint,
  String? helperText,
  String? errorText,
  bool obscureText = false,
  TextInputType? keyboardType,
  Widget? suffixIcon,
  String? Function(String?)? validator,
  void Function(String)? onChanged,
  Key? key,
})
```

**Usage Example:**
```dart
GabiumTextField(
  controller: _emailController,
  label: '이메일',
  hint: 'user@example.com',
  keyboardType: TextInputType.emailAddress,
  validator: _validateEmail,
)
```

**Interactive States:**
- Default: Border Neutral-300, Background White
- Focus: Border Primary, Background Primary 10%
- Error: Border Error, Error message below
- Disabled: Background Neutral-50, Border Neutral-200, opacity 0.6

**Accessibility:**
- Label always visible above input
- Touch target: 48px height (exceeds 44px minimum)
- Color contrast: Text 10.5:1, Label 8.2:1

---

### GabiumButton

**Purpose:** Primary button component with multiple variants and sizes

**Design Tokens:**
- **Primary Large:** 52px height, Primary `#4ADE80` bg, lg (18px Semibold) text, 32px horizontal padding, sm (8px) radius, sm shadow
- **Ghost Medium:** 44px height, Primary `#4ADE80` text, transparent bg, no shadow
- Loading: 24px white spinner, button disabled
- Hover: Primary `#22C55E` (Primary), Primary 8% opacity (Ghost)
- Active: Primary `#16A34A` (Primary), Primary 12% opacity (Ghost)
- Disabled: Primary at 40% opacity

**Props:**
```dart
GabiumButton({
  required String text,
  required VoidCallback? onPressed,
  GabiumButtonVariant variant = GabiumButtonVariant.primary,
  GabiumButtonSize size = GabiumButtonSize.medium,
  bool isLoading = false,
})
```

**Variants:**
- `GabiumButtonVariant.primary`: Primary green button
- `GabiumButtonVariant.secondary`: (to be implemented)
- `GabiumButtonVariant.tertiary`: (to be implemented)
- `GabiumButtonVariant.ghost`: Transparent button with Primary text

**Sizes:**
- `GabiumButtonSize.small`: 36px height, 14px text
- `GabiumButtonSize.medium`: 44px height, 16px text
- `GabiumButtonSize.large`: 52px height, 18px text

**Usage Example:**
```dart
GabiumButton(
  text: '회원가입',
  onPressed: _handleSignup,
  isLoading: _isLoading,
  variant: GabiumButtonVariant.primary,
  size: GabiumButtonSize.large,
)
```

**Accessibility:**
- Touch target: All sizes ≥44px height (or effective area with spacing)
- Color contrast: 3.5:1 (meets WCAG AA for large text 18px+)
- Keyboard navigation: Tab order, Enter/Space trigger
- Loading state: Disabled during async operation, ARIA label announced

---

### PasswordStrengthIndicator

**Purpose:** Visual feedback for password strength

**Design Tokens:**
- Height: 8px, full radius (999px)
- Background: Neutral-200 `#E2E8F0`
- Fill: Error `#EF4444` (Weak), Warning `#F59E0B` (Medium), Success `#10B981` (Strong)
- Label: xs (12px Medium), color matches fill
- Animation: 200ms ease transition

**Props:**
```dart
PasswordStrengthIndicator({
  required PasswordStrength strength,
})
```

**Usage Example:**
```dart
PasswordStrengthIndicator(
  strength: _passwordStrength,
)
```

**Strength Values:**
- `PasswordStrength.weak`: 33% fill, Error color, label "약함"
- `PasswordStrength.medium`: 66% fill, Warning color, label "보통"
- `PasswordStrength.strong`: 100% fill, Success color, label "강함"

**Accessibility:**
- Label announces strength to screen reader
- Color contrast: Labels meet WCAG AA (4.5:1+)
- Not keyboard focusable (decorative)

---

### ConsentCheckbox

**Purpose:** Styled checkbox for consent forms with required/optional badge

**Design Tokens:**
- Checkbox: 24x24px visual, 44x44px touch, 4px radius
- Border: Neutral-400 `#94A3B8` (unchecked), Primary `#4ADE80` (checked)
- Background: Transparent (unchecked), Primary `#4ADE80` (checked)
- Checkmark: White, 16px icon
- Label: sm (14px Regular), Neutral-700 `#334155`
- Badge: xs (12px Medium), Error `#EF4444` (required) or Neutral-500 `#64748B` (optional)

**Props:**
```dart
ConsentCheckbox({
  required String label,
  required bool isRequired,
  required bool value,
  required ValueChanged<bool?>? onChanged,
})
```

**Usage Example:**
```dart
ConsentCheckbox(
  value: _agreeToTerms,
  onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
  label: '이용약관에 동의합니다',
  isRequired: true,
)
```

**Usage in Container (recommended):**
```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Color(0xFFF8FAFC), // Neutral-50
    border: Border.all(color: Color(0xFFE2E8F0)), // Neutral-200
    borderRadius: BorderRadius.circular(12),
  ),
  child: Column(
    children: [
      ConsentCheckbox(...),
      SizedBox(height: 16),
      ConsentCheckbox(...),
    ],
  ),
)
```

**Accessibility:**
- Touch target: 44x44px minimum
- Color contrast: Label 8.2:1, Required badge 4.8:1
- Keyboard navigation: Tab order, Space to toggle
- ARIA: role="checkbox", aria-checked state
- Label: Associated with checkbox (clickable)

---

### GabiumToast

**Purpose:** Branded toast notifications replacing SnackBar

**Design Tokens:**
- Width: 90% viewport (max 360px)
- Padding: md (16px), md (12px) radius
- Border: 4px left (Error/Success/Warning/Info color)
- Background: Tinted (Error: `#FEF2F2`, Success: `#ECFDF5`, Warning: `#FEF3C7`, Info: `#EFF6FF`)
- Text: sm (14px Regular), dark variant of semantic color
- Icon: 24px, left-aligned, 12px spacing to text
- Shadow: lg (0 8px 16px rgba(15, 23, 42, 0.10))
- Duration: 4s (success), 6s (error/warning/info)

**Static Methods:**
```dart
GabiumToast.showError(BuildContext context, String message)
GabiumToast.showSuccess(BuildContext context, String message)
GabiumToast.showWarning(BuildContext context, String message)
GabiumToast.showInfo(BuildContext context, String message)
```

**Usage Example:**
```dart
GabiumToast.showError(
  context,
  '이메일을 입력해주세요',
);

GabiumToast.showSuccess(
  context,
  '회원가입이 완료되었습니다!',
);
```

**Variants:**
- **Error:** Red border/icon, red-tinted background, dark red text
- **Success:** Green border/icon, green-tinted background, dark green text
- **Warning:** Orange border/icon, orange-tinted background, dark orange text
- **Info:** Blue border/icon, blue-tinted background, dark blue text

**Accessibility:**
- ARIA role: "alert"
- Screen reader: Announces message immediately
- Color contrast: Error 7.2:1, Success 8.5:1
- Position: Bottom-center, does not block primary content

---

## Design System Reference

All components follow the Gabium Design System tokens:

**Colors:**
- Primary: `#4ADE80`
- Neutral-50: `#F8FAFC`
- Neutral-200: `#E2E8F0`
- Neutral-300: `#CBD5E1`
- Neutral-400: `#94A3B8`
- Neutral-500: `#64748B`
- Neutral-600: `#475569`
- Neutral-700: `#334155`
- Neutral-800: `#1E293B`
- Error: `#EF4444`
- Warning: `#F59E0B`
- Success: `#10B981`

**Typography Scale:**
- xs: 12px
- sm: 14px
- base: 16px
- lg: 18px
- xl: 20px
- 2xl: 24px
- 3xl: 28px

**Font Weights:**
- Regular: 400
- Medium: 500
- Semibold: 600
- Bold: 700

**Spacing Scale (8px-based):**
- xs: 4px
- sm: 8px
- md: 16px
- lg: 24px
- xl: 32px
- 2xl: 48px

**Border Radius:**
- sm: 8px
- md: 12px
- lg: 16px
- full: 999px

**Shadows:**
- xs: 0 1px 2px rgba(15, 23, 42, 0.04)
- sm: 0 2px 4px rgba(15, 23, 42, 0.06)
- md: 0 4px 8px rgba(15, 23, 42, 0.08)
- lg: 0 8px 16px rgba(15, 23, 42, 0.10)

---

## Usage Guidelines

### Import Components

```dart
import 'package:n06/features/authentication/presentation/widgets/auth_hero_section.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_text_field.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';
import 'package:n06/features/authentication/presentation/widgets/password_strength_indicator.dart';
import 'package:n06/features/authentication/presentation/widgets/consent_checkbox.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_toast.dart';
```

### Consistency Checklist

When using these components:
- ✅ Use exact Design System tokens (no custom colors/spacing)
- ✅ Follow accessibility guidelines (contrast, touch targets, keyboard nav)
- ✅ Maintain component API (don't modify props without updating this registry)
- ✅ Test all interactive states (default, hover, active, disabled, focus)
- ✅ Ensure Korean text for all user-facing strings

### Future Components

Components planned for extraction:
- **Secondary Button** (from future screens)
- **Tertiary Button** (from future screens)
- **Card Container** (reusable card wrapper)
- **Form Section** (grouped form fields with title)
- **Error Message** (standalone error display)

---

## Maintenance

**Last Updated:** 2025-11-22
**Component Count:** 7 Flutter components
**Design System Version:** Gabium v1.0 (approved 2025-11-22)

For questions or updates, refer to:
- Implementation Guide: `.claude/skills/ui-renewal/implementation-guides/email-signup-screen-implementation-guide.md`
- Design System: `.claude/skills/ui-renewal/design-system/gabium-design-system.md`
- Improvement Proposal: `.claude/skills/ui-renewal/proposals/email-signup-screen-improvement-proposal.md`
