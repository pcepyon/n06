# Section 7: Component Library

## 7.1 Overview

Total Components: 8
Frameworks: Flutter
Categories: Authentication, Form, Button, Feedback, Navigation

## 7.2 Component Registry

### Authentication

**AuthHeroSection**
- Description: Welcoming hero section with title, subtitle, and optional icon. Reusable for all authentication screens.
- File: `flutter/AuthHeroSection.dart`
- Used in: Email Signup Screen, Email Signin Screen

### Button

**GabiumButton**
- Description: Branded button with Primary and Ghost variants. Supports Small, Medium, and Large sizes. Includes loading state with spinner.
- File: `flutter/GabiumButton.dart`
- Used in: Email Signup Screen, Email Signin Screen

### Feedback

**GabiumToast**
- Description: Toast notification with Error, Success, Warning, and Info variants. Replaces SnackBar with branded styling.
- File: `flutter/GabiumToast.dart`
- Used in: Email Signup Screen, Email Signin Screen

### Form

**GabiumTextField**
- Description: Branded text input field with label, validation, focus and error states. Height 48px.
- File: `flutter/GabiumTextField.dart`
- Used in: Email Signup Screen, Email Signin Screen

**PasswordStrengthIndicator**
- Description: Visual password strength indicator with semantic colors showing Weak, Medium, or Strong states.
- File: `flutter/PasswordStrengthIndicator.dart`
- Used in: Email Signup Screen

**ConsentCheckbox**
- Description: Styled checkbox with required/optional badge. Touch area 44x44px for accessibility.
- File: `flutter/ConsentCheckbox.dart`
- Used in: Email Signup Screen

### Navigation

**GabiumBottomNavigation**
- Description: Bottom navigation bar with 5 tabs following Gabium Design System. Features scale animation on tap and semantic color states (Primary for active, Neutral-500 for inactive).
- File: `flutter/gabium_bottom_navigation.dart`
- Used in: Home Dashboard Screen, Weight Tracking Screen, Symptom Tracking Screen

---

## 7.3 Usage Notes

- All components follow Gabium Design System tokens
- Accessibility standards: WCAG 2.1 AA compliance
- Touch targets: Minimum 44x44px
- Color contrast: Minimum 4.5:1 for normal text, 3:1 for large text

For detailed component specifications, see:
`component-library/COMPONENTS.md`
