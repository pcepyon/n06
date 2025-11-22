<!-- 
  ⚠️ AUTO-GENERATED FILE - DO NOT EDIT MANUALLY
  
  This file is generated from component-library/registry.json
  To update: Edit registry.json, then run:
  
  python scripts/generate_components_docs.py --output-components-md
-->

# Gabium UI Component Library

This library contains reusable UI components extracted from the email signup screen redesign, following the Gabium Design System.

## Component Registry

| Component | Created Date | Used In | Framework | File Location | Notes |
|-----------|--------------|---------|-----------|---------------|-------|
| GabiumBottomNavigation | 2025-11-22 | Home Dashboard Screen, Weight Tracking Screen + 4 more | Flutter | `flutter/gabium_bottom_navigation.dart` | Bottom navigation bar with 5 tabs following Gabium Design System. Features scale animation on tap an |
| AuthHeroSection | 2025-11-22 | Email Signup Screen, Email Signin Screen | Flutter | `flutter/AuthHeroSection.dart` | Welcoming hero section with title, subtitle, and optional icon. Reusable for all authentication scre |
| GabiumTextField | 2025-11-22 | Email Signup Screen, Email Signin Screen | Flutter | `flutter/GabiumTextField.dart` | Branded text input field with label, validation, focus and error states. Height 48px. |
| GabiumButton | 2025-11-22 | Email Signup Screen, Email Signin Screen | Flutter | `flutter/GabiumButton.dart` | Branded button with Primary and Ghost variants. Supports Small, Medium, and Large sizes. Includes lo |
| PasswordStrengthIndicator | 2025-11-22 | Email Signup Screen | Flutter | `flutter/PasswordStrengthIndicator.dart` | Visual password strength indicator with semantic colors showing Weak, Medium, or Strong states. |
| ConsentCheckbox | 2025-11-22 | Email Signup Screen | Flutter | `flutter/ConsentCheckbox.dart` | Styled checkbox with required/optional badge. Touch area 44x44px for accessibility. |
| GabiumToast | 2025-11-22 | Email Signup Screen, Email Signin Screen | Flutter | `flutter/GabiumToast.dart` | Toast notification with Error, Success, Warning, and Info variants. Replaces SnackBar with branded s |

---

## Component Specifications

### GabiumBottomNavigation

**Purpose:** Bottom navigation bar with 5 tabs following Gabium Design System. Features scale animation on tap and semantic color states (Primary for active, Neutral-500 for inactive).

**Design Tokens:**
- Background: #FFFFFF (White)
- Bordertop: Neutral-200 (#E2E8F0), 1px
- Shadow: Reverse md (0 -4px 8px rgba(15, 23, 42, 0.08))
- Height: 56px + SafeArea bottom inset
- Activecolor: Primary (#4ADE80)
- Inactivecolor: Neutral-500 (#64748B)
- Iconsize: 24px
- Labelfont: xs (12px Medium)

**Props:**
```dart
GabiumBottomNavigation({
  List<GabiumBottomNavItem> (required) items,
  int (required, 0-4) currentIndex,
  ValueChanged<int> (required) onTap,
})
```

**Usage Example:**
```dart
GabiumBottomNavigation(
  // Set required properties
)
```

---

### AuthHeroSection

**Purpose:** Welcoming hero section with title, subtitle, and optional icon. Reusable for all authentication screens.

**Design Tokens:**
- Background: Neutral-50 (#F8FAFC)
- Titlecolor: Neutral-800 (#1E293B)
- Subtitlecolor: Neutral-600 (#475569)
- Titlesize: 3xl (28px Bold)
- Subtitlesize: base (16px Regular)

**Props:**
```dart
AuthHeroSection({
  String (required) title,
  String (required) subtitle,
  IconData (optional) icon,
})
```

**Usage Example:**
```dart
AuthHeroSection(
  // Set required properties
)
```

---

### GabiumTextField

**Purpose:** Branded text input field with label, validation, focus and error states. Height 48px.

**Design Tokens:**
- Height: 48px
- Borderradius: sm (8px)
- Borderdefault: 2px solid Neutral-300
- Borderfocus: 2px solid Primary (#4ADE80)
- Bordererror: 2px solid Error (#EF4444)
- Backgroundcolor: #FFFFFF
- Backgroundfocus: Primary 10%

**Props:**
```dart
GabiumTextField({
  TextEditingController (optional) controller,
  String (required) label,
  String (optional) hint,
  String (optional) helperText,
  String (optional) errorText,
  bool (default: false) obscureText,
  TextInputType (optional) keyboardType,
  Widget (optional) suffixIcon,
  String? Function(String?) (optional) validator,
  void Function(String) (optional) onChanged,
})
```

**Usage Example:**
```dart
GabiumTextField(
  // Set required properties
)
```

---

### GabiumButton

**Purpose:** Branded button with Primary and Ghost variants. Supports Small, Medium, and Large sizes. Includes loading state with spinner.

**Design Tokens:**
- Primarybackground: Primary (#4ADE80)
- Primarytext: #FFFFFF
- Ghostbackground: transparent
- Ghosttext: Primary (#4ADE80)
- Heightlarge: 52px
- Heightmedium: 44px
- Heightsmall: 36px
- Borderradius: sm (8px)

**Props:**
```dart
GabiumButton({
  VoidCallback (required) onPressed,
  String (required) label,
  ButtonVariant (Primary or Ghost) variant,
  ButtonSize (Small, Medium, or Large) size,
  bool (default: false) isLoading,
  bool (default: false) fullWidth,
})
```

**Usage Example:**
```dart
GabiumButton(
  // Set required properties
)
```

---

### PasswordStrengthIndicator

**Purpose:** Visual password strength indicator with semantic colors showing Weak, Medium, or Strong states.

**Design Tokens:**
- Weakcolor: Error (#EF4444)
- Mediumcolor: Warning (#F59E0B)
- Strongcolor: Success (#10B981)
- Height: 4px
- Borderradius: full (999px)
- Animationduration: 200ms

**Props:**
```dart
PasswordStrengthIndicator({
  PasswordStrength (enum: weak, medium, strong) strength,
})
```

**Usage Example:**
```dart
PasswordStrengthIndicator(
  // Set required properties
)
```

---

### ConsentCheckbox

**Purpose:** Styled checkbox with required/optional badge. Touch area 44x44px for accessibility.

**Design Tokens:**
- Toucharea: 44x44px
- Checkboxsize: 24x24px
- Badgerequired: Error (#EF4444)
- Badgeoptional: Neutral-500
- Labelsize: sm (14px Regular)
- Containerbackground: Neutral-50 (#F8FAFC)
- Containerradius: md (12px)

**Props:**
```dart
ConsentCheckbox({
  bool (required) value,
  void Function(bool?) (required) onChanged,
  String (required) label,
  bool (default: false) isRequired,
})
```

**Usage Example:**
```dart
ConsentCheckbox(
  // Set required properties
)
```

---

### GabiumToast

**Purpose:** Toast notification with Error, Success, Warning, and Info variants. Replaces SnackBar with branded styling.

**Design Tokens:**
- Errorbackground: Error-50
- Errorborder: Error (#EF4444)
- Successbackground: Success-50
- Successborder: Success (#10B981)
- Warningbackground: Warning-50
- Warningborder: Warning (#F59E0B)
- Infobackground: Info-50
- Infoborder: Info (#3B82F6)
- Borderradius: sm (8px)
- Borderwidth: 4px (left only)
- Padding: md (16px)
- Iconsize: 24px

**Props:**
```dart
GabiumToast({
  BuildContext (required) context,
  String (required) message,
  ToastVariant (error, success, warning, info) variant,
})
```

**Usage Example:**
```dart
GabiumToast(
  // Set required properties
)
```

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
import 'package:n06/lib/core/presentation/widgets/gabium_bottom_navigation.dart';
import 'package:n06/lib/features/authentication/presentation/widgets/auth_hero_section.dart';
import 'package:n06/lib/features/authentication/presentation/widgets/gabium_text_field.dart';
import 'package:n06/lib/features/authentication/presentation/widgets/gabium_button.dart';
import 'package:n06/lib/features/authentication/presentation/widgets/password_strength_indicator.dart';
import 'package:n06/lib/features/authentication/presentation/widgets/consent_checkbox.dart';
import 'package:n06/lib/features/authentication/presentation/widgets/gabium_toast.dart';
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
**Component Count:** 8 Flutter components
**Design System Version:** Gabium Design System v1.0

For questions or updates, refer to:
- Implementation Guide: `.claude/skills/ui-renewal/implementation-guides/email-signup-screen-implementation-guide.md`
- Design System: `.claude/skills/ui-renewal/design-system/gabium-design-system.md`
- Improvement Proposal: `.claude/skills/ui-renewal/proposals/email-signup-screen-improvement-proposal.md`
