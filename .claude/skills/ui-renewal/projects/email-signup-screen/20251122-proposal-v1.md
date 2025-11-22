# Email Signup Screen Improvement Proposal

## Overview
Transform the email signup screen from a generic Material Design form into a welcoming, brand-aligned entry point that reflects Gabium's core values of safety, approachability, and motivation. This screen is the user's first impression and the gateway to their GLP-1 treatment journey.

## Current State Issues

### Brand Consistency Issues
- **No Brand Colors**: Uses default Material colors instead of Gabium Primary `#4ADE80` (bright green)
- **Generic Typography**: Standard Material typography without Pretendard font or Gabium type scale
- **Missing Visual Identity**: No design system spacing, border radius, or shadow levels applied
- **Neutral Palette**: No use of Gabium Neutral scale (`#F8FAFC` backgrounds, `#1E293B` headings)

### Visual Quality Issues
- **Weak Visual Hierarchy**: Title lacks prominence (should be 3xl/2xl, Bold, Neutral-800)
- **Insufficient Whitespace**: Cramped spacing doesn't follow 8px-based spacing scale
- **Harsh Corners**: 8px radius applied but inconsistently; should use Design System tokens (sm/md/lg)
- **Flat Appearance**: No shadow system applied to create depth and trust
- **Clinical Form**: Lacks warmth - feels like a generic signup rather than the start of a health journey

### UX Issues
- **No Motivational Context**: Missing welcoming message or journey context ("치료 여정을 시작해보세요")
- **Lacks Trust Elements**: No reassurance about data security or medical-grade app quality
- **Password Strength Indicator Weak**: Basic linear progress bar instead of visual feedback with Design System colors
- **Error States Generic**: Standard red errors instead of Gabium Error color `#EF4444` with proper messaging
- **No Success Feeling**: Signup completion lacks celebratory feedback (should feel like an achievement)
- **Checkbox Pattern Outdated**: Plain checkboxes instead of modern toggles or styled consent UI
- **Missing Progressive Disclosure**: All fields shown at once instead of friendly step-by-step approach

## Improvement Direction

### Change 1: Add Welcoming Hero Section
- **Current:** Title "Create Account" in AppBar only
- **Proposed:** Hero section with welcoming message and journey context
- **Rationale:** First impression matters - users should feel invited into their health journey, not just filling a form. Aligns with "Motivation" and "Approachability" brand values.
- **Design System Mapping:**
  - Component: Section 6 - Layout Patterns - Header (custom hero variant)
  - Background: Colors - Neutral-50 `#F8FAFC` (subtle, clean)
  - Greeting Title: Typography - 3xl (28px, Bold), Colors - Neutral-800 `#1E293B`
  - Subtitle: Typography - base (16px, Regular), Colors - Neutral-600 `#475569`
  - Spacing: xl padding (32px top), md padding (16px horizontal)
  - Visual Element: Optional health icon (xl size 48px, Primary color)

### Change 2: Rebrand Primary CTA Button
- **Current:** Generic ElevatedButton with default Material colors
- **Proposed:** Gabium Primary button with proper states
- **Rationale:** Primary action must reflect brand - bright green communicates health, progress, and safety
- **Design System Mapping:**
  - Component: Section 6 - Buttons - Primary, Large
  - Background: Colors - Primary `#4ADE80`
  - Text: `#FFFFFF`, Typography - lg (18px, Semibold 600)
  - Border Radius: sm (8px)
  - Shadow: sm
  - Height: 52px (Large size)
  - Horizontal Padding: 32px
  - Interactive States:
    - Hover: Primary `#22C55E`, Shadow md
    - Active: Primary `#16A34A`, Shadow xs
    - Disabled: Primary at 40% opacity
    - Loading: Primary background + 24px spinner (white)

### Change 3: Improve Input Field Styling
- **Current:** Standard Material OutlineInputBorder with default styling
- **Proposed:** Gabium-branded input fields with trust-building design
- **Rationale:** Input fields are where users provide sensitive data - they must feel secure and well-designed. 48px height improves mobile touch experience.
- **Design System Mapping:**
  - Component: Section 6 - Form Elements - Text Input
  - Height: 48px (instead of default ~56px Material)
  - Padding: 12px 16px (md vertical, md horizontal)
  - Border: 2px solid Neutral-300 `#CBD5E1` (default)
  - Border Radius: sm (8px)
  - Font: Typography - base (16px, Regular)
  - Background: `#FFFFFF`
  - Focus State:
    - Border: Primary `#4ADE80`
    - Background: Primary at 10% opacity `rgba(74, 222, 128, 0.1)`
    - Outline: none (avoid browser default)
  - Error State:
    - Border: Error `#EF4444`
    - Error Message: Typography - xs (12px, Medium 500), Color - Error `#EF4444`
    - Icon: Alert-circle 16px, Error color
  - Label: Typography - sm (14px, Semibold 600), Color - Neutral-700 `#334155`

### Change 4: Enhanced Password Strength Indicator
- **Current:** Simple LinearProgressIndicator with red/orange/green text
- **Proposed:** Visual strength feedback using Gabium semantic colors with clear messaging
- **Rationale:** Password security is critical for medical app trust - make it visually clear and encouraging
- **Design System Mapping:**
  - Component: Section 6 - Feedback Components - Progress Bar (adapted)
  - Height: 8px
  - Border Radius: full (999px)
  - Background: Neutral-200 `#E2E8F0`
  - Fill Colors (by strength):
    - Weak: Error `#EF4444`
    - Medium: Warning `#F59E0B`
    - Strong: Success `#10B981`
  - Label: Typography - xs (12px, Medium 500)
  - Label Colors: Same as fill (Error/Warning/Success)
  - Transition: 200ms ease (smooth fill animation)
  - Spacing: 8px (sm) below input

### Change 5: Modern Consent UI
- **Current:** Plain CheckboxListTile (Material default)
- **Proposed:** Card-based consent sections with visual grouping and clear hierarchy
- **Rationale:** Consent is legally critical and should be easy to understand - visual grouping improves comprehension. Required vs optional distinction must be crystal clear.
- **Design System Mapping:**
  - Component: Section 6 - Form Elements - Checkbox (redesigned pattern)
  - Container Background: Neutral-50 `#F8FAFC`
  - Container Border: 1px solid Neutral-200 `#E2E8F0`
  - Container Border Radius: md (12px)
  - Container Padding: md (16px)
  - Checkbox Size: 24x24px (visual), 44x44px (touch area)
  - Checkbox Border: 2px solid Neutral-400 `#94A3B8`
  - Checkbox Border Radius: 4px
  - Checked State:
    - Background: Primary `#4ADE80`
    - Border: Primary `#4ADE80`
    - Checkmark: White, 16px icon
  - Label: Typography - sm (14px, Regular), Color - Neutral-700 `#334155`
  - Required Badge: Typography - xs (12px, Medium), Color - Error `#EF4444`, Background - Error at 10%
  - Spacing: sm (8px) between checkbox and label, md (16px) between items

### Change 6: Sign In Link Styling
- **Current:** TextButton with default Material style
- **Proposed:** Gabium Ghost button with Primary color
- **Rationale:** Secondary navigation should be subtle but brand-aligned
- **Design System Mapping:**
  - Component: Section 6 - Buttons - Ghost
  - Text: Primary `#4ADE80`, Typography - base (16px, Medium 500)
  - Background: Transparent
  - Border: None
  - Shadow: None
  - Hover State:
    - Background: Primary at 8% `rgba(74, 222, 128, 0.08)`
  - Active State:
    - Background: Primary at 12% `rgba(74, 222, 128, 0.12)`

### Change 7: Consistent Spacing System
- **Current:** Inconsistent padding (16px) and spacing (8px, 16px, 24px mixed)
- **Proposed:** Systematic spacing using 8px-based scale
- **Rationale:** Visual rhythm improves scannability and professionalism
- **Design System Mapping:**
  - Section Spacing: Section 4 - Spacing Scale
  - Screen Edge Padding: md (16px) horizontal
  - Hero Section Padding: xl (32px) top, md (16px) bottom
  - Between Input Fields: md (16px)
  - Input to Helper Text: xs (4px)
  - Input to Strength Indicator: sm (8px)
  - Before Consent Section: lg (24px)
  - Between Consent Items: md (16px)
  - Before CTA Button: xl (32px)
  - CTA to Sign In Link: md (16px)

### Change 8: Loading State Improvement
- **Current:** Full-screen CircularProgressIndicator (Material default)
- **Proposed:** Inline button loading with Gabium spinner
- **Rationale:** Full-screen loading feels disruptive - inline loading keeps context
- **Design System Mapping:**
  - Component: Section 6 - Feedback Components - Loading Indicator
  - Spinner Size: 24px (Medium, for button)
  - Spinner Color: `#FFFFFF` (on Primary button background)
  - Animation: 1s linear infinite rotation
  - Button State: Primary background maintained, text replaced with spinner
  - Disabled State: Prevent additional clicks while loading

### Change 9: Error Feedback Enhancement
- **Current:** Generic SnackBar with plain text
- **Proposed:** Gabium Toast with semantic colors and icons
- **Rationale:** Error feedback should be informative and aligned with brand design
- **Design System Mapping:**
  - Component: Section 6 - Feedback Components - Toast/Snackbar
  - Width: 90% viewport (max 360px on mobile)
  - Padding: md (16px)
  - Border Radius: md (12px)
  - Shadow: lg
  - Position: Bottom-center (mobile)
  - Error Variant:
    - Left Border: 4px solid Error `#EF4444`
    - Background: `#FEF2F2` (Error background tint)
    - Text: Typography - sm (14px, Regular), Color `#991B1B` (Error dark)
    - Icon: 24px alert-circle, Error `#EF4444`, left-aligned, 12px spacing to text
  - Success Variant (on signup success):
    - Left Border: 4px solid Success `#10B981`
    - Background: `#ECFDF5` (Success background tint)
    - Text: Color `#065F46` (Success dark)
    - Icon: 24px check-circle, Success color

### Change 10: AppBar Redesign
- **Current:** Material AppBar with "Create Account" title
- **Proposed:** Simplified Gabium header with minimal branding
- **Rationale:** Let hero section do the welcoming - AppBar should be functional and clean
- **Design System Mapping:**
  - Component: Section 6 - Layout Patterns - Header (App Bar)
  - Height: 56px
  - Background: `#FFFFFF`
  - Border Bottom: 1px solid Neutral-200 `#E2E8F0`
  - Back Button: 44x44px icon button, Neutral-700 `#334155` color
  - Title: Typography - xl (20px, Semibold 600), Color - Neutral-800 `#1E293B`
  - Title: "가비움 시작하기" (instead of "Create Account")
  - Padding: 0 16px (md)

## Design System Token Reference

Complete list of all tokens to be used:

| Element | Token Path | Value | Usage |
|---------|-----------|-------|-------|
| Screen Background | Colors - Neutral - 50 | #F8FAFC | Full screen background |
| Hero Container BG | Colors - Neutral - 50 | #F8FAFC | Hero section (seamless) |
| Hero Title | Typography - 3xl | 28px, Bold (700) | "가비움과 함께 시작해요" |
| Hero Title Color | Colors - Neutral - 800 | #1E293B | Title text |
| Hero Subtitle | Typography - base | 16px, Regular (400) | "건강한 변화의 첫 걸음" |
| Hero Subtitle Color | Colors - Neutral - 600 | #475569 | Subtitle text |
| Hero Spacing Top | Spacing - xl | 32px | Hero padding top |
| Hero Spacing Horizontal | Spacing - md | 16px | Hero padding horizontal |
| Input Container BG | Colors - Base | #FFFFFF | Input field background |
| Input Border Default | Colors - Neutral - 300 | #CBD5E1 | Input border default |
| Input Border Focus | Colors - Primary | #4ADE80 | Input border focus |
| Input Border Error | Colors - Error | #EF4444 | Input border error |
| Input BG Focus | Colors - Primary at 10% | rgba(74, 222, 128, 0.1) | Input background focus |
| Input Height | Component Heights - Input | 48px | Input field height |
| Input Padding | Spacing - md vertical, md horizontal | 12px 16px | Input padding |
| Input Border Radius | Border Radius - sm | 8px | Input corners |
| Input Text | Typography - base | 16px, Regular (400) | Input text |
| Label Text | Typography - sm | 14px, Semibold (600) | Input label |
| Label Color | Colors - Neutral - 700 | #334155 | Label text |
| Error Message | Typography - xs | 12px, Medium (500) | Error text |
| Error Color | Colors - Error | #EF4444 | Error text color |
| Strength Bar BG | Colors - Neutral - 200 | #E2E8F0 | Progress background |
| Strength Weak | Colors - Error | #EF4444 | Weak password |
| Strength Medium | Colors - Warning | #F59E0B | Medium password |
| Strength Strong | Colors - Success | #10B981 | Strong password |
| Strength Bar Height | Custom | 8px | Progress bar height |
| Strength Bar Radius | Border Radius - full | 999px | Full rounded |
| Consent Container BG | Colors - Neutral - 50 | #F8FAFC | Consent section background |
| Consent Border | Colors - Neutral - 200 | #E2E8F0 | Consent section border |
| Consent Border Radius | Border Radius - md | 12px | Consent section corners |
| Consent Padding | Spacing - md | 16px | Consent section padding |
| Checkbox Size | Component - Checkbox | 24x24px visual, 44x44px touch | Checkbox |
| Checkbox Border | Colors - Neutral - 400 | #94A3B8 | Checkbox border |
| Checkbox Checked BG | Colors - Primary | #4ADE80 | Checkbox checked |
| Checkbox Border Radius | Custom | 4px | Checkbox corners |
| Checkbox Label | Typography - sm | 14px, Regular (400) | Checkbox label |
| Checkbox Label Color | Colors - Neutral - 700 | #334155 | Checkbox label text |
| CTA Button BG | Colors - Primary | #4ADE80 | Sign Up button |
| CTA Button Text | Colors - Base | #FFFFFF | Button text |
| CTA Button Text Size | Typography - lg | 18px, Semibold (600) | Button text |
| CTA Button Height | Component Heights - Large | 52px | Button height |
| CTA Button Padding | Spacing - 2xl horizontal | 32px | Button horizontal padding |
| CTA Button Radius | Border Radius - sm | 8px | Button corners |
| CTA Button Shadow | Shadow - sm | 0 2px 4px rgba(15, 23, 42, 0.06) | Button shadow |
| CTA Hover BG | Colors - Primary Hover | #22C55E | Button hover |
| CTA Hover Shadow | Shadow - md | 0 4px 8px rgba(15, 23, 42, 0.08) | Button hover shadow |
| CTA Active BG | Colors - Primary Active | #16A34A | Button active |
| CTA Disabled BG | Colors - Primary at 40% | rgba(74, 222, 128, 0.4) | Button disabled |
| Sign In Link Text | Colors - Primary | #4ADE80 | Sign in link |
| Sign In Link Size | Typography - base | 16px, Medium (500) | Sign in link |
| Sign In Link Hover BG | Colors - Primary at 8% | rgba(74, 222, 128, 0.08) | Sign in link hover |
| Toast BG Error | Custom | #FEF2F2 | Error toast background |
| Toast Border Error | Colors - Error | #EF4444 | Error toast border |
| Toast Text Error | Custom | #991B1B | Error toast text |
| Toast BG Success | Custom | #ECFDF5 | Success toast background |
| Toast Border Success | Colors - Success | #10B981 | Success toast border |
| Toast Text Success | Custom | #065F46 | Success toast text |
| Toast Padding | Spacing - md | 16px | Toast padding |
| Toast Radius | Border Radius - md | 12px | Toast corners |
| Toast Shadow | Shadow - lg | 0 8px 16px rgba(15, 23, 42, 0.10) | Toast shadow |
| AppBar BG | Colors - Base | #FFFFFF | AppBar background |
| AppBar Border | Colors - Neutral - 200 | #E2E8F0 | AppBar border bottom |
| AppBar Height | Component Heights - App Bar | 56px | AppBar height |
| AppBar Title | Typography - xl | 20px, Semibold (600) | AppBar title |
| AppBar Title Color | Colors - Neutral - 800 | #1E293B | AppBar title text |
| AppBar Back Icon | Colors - Neutral - 700 | #334155 | Back button color |
| Spacing Input to Input | Spacing - md | 16px | Between input fields |
| Spacing Input to Helper | Spacing - xs | 4px | Input to helper text |
| Spacing Input to Strength | Spacing - sm | 8px | Input to strength bar |
| Spacing Before Consent | Spacing - lg | 24px | Before consent section |
| Spacing Between Consent | Spacing - md | 16px | Between consent items |
| Spacing Before CTA | Spacing - xl | 32px | Before CTA button |
| Spacing CTA to Link | Spacing - md | 16px | CTA to sign in link |

## Preserved Elements

What should NOT change:
- **Email Pre-fill Logic**: `prefillEmail` parameter from sign-in screen must remain functional
- **Validation Logic**: Email/password validators (`isValidEmail`, `isValidPassword`) are solid
- **Password Strength Calculation**: `getPasswordStrength` logic works well, only visual presentation changes
- **Consent Validation**: `isValidConsent` business logic should remain unchanged
- **Navigation Flow**: After signup → `/onboarding` with `userId` extra parameter (critical for user journey)
- **Form State Management**: TextEditingControllers and GlobalKey<FormState> pattern is correct
- **Mounted Checks**: All `if (!mounted) return;` checks are essential and must be preserved
- **Error Handling**: Try-catch pattern and SnackBar error messages (just re-style them)

## Dependencies

### Prerequisites (must do first):
✅ None - Design System is complete and approved. All tokens are available.

### Impact (will need updating after):
- **Email Sign-In Screen** (`email_signin_screen.dart`): Must maintain visual consistency with signup screen
  - Same hero section pattern (welcoming message)
  - Same input field styling
  - Same button styling (Primary for Sign In, Ghost for Sign Up link)
  - Same error toast styling
  - Same AppBar styling
- **Password Reset Screen** (if exists): Should follow same form styling
- **Future Authentication Screens**: This becomes the template for all auth flows

## Component Reuse

### Existing Components to Reuse:
✅ None - This is the first authentication screen being redesigned. Components created here will seed the registry.

### New Components to Create:
These components will be extracted and added to Component Registry after implementation:

1. **AuthHeroSection**
   - Welcoming hero with title, subtitle, optional icon
   - Reusable for all auth screens (sign in, signup, password reset)
   - Props: title, subtitle, iconName (optional)

2. **GabiumTextField**
   - Branded text input following Design System
   - Handles default, focus, error states
   - Includes label, helper text, error message
   - Props: label, hint, errorText, helperText, obscureText, controller, validator

3. **GabiumButton**
   - Primary, Secondary, Tertiary, Ghost variants
   - Small, Medium, Large sizes
   - Loading state support
   - Props: text, variant, size, onPressed, isLoading

4. **PasswordStrengthIndicator**
   - Visual strength feedback with Gabium colors
   - Props: strength (weak/medium/strong)

5. **ConsentCheckbox**
   - Styled checkbox with required/optional badge
   - Card container background
   - Props: label, isRequired, value, onChanged

6. **GabiumToast**
   - Error, Success, Warning, Info variants
   - Custom show function replacing SnackBar
   - Props: message, variant

All components will be added to Section 7 - Component Registry after implementation.

## Success Criteria

1. **Brand Alignment**: 100% of visual elements use Design System tokens (colors, typography, spacing, shadows)
2. **User Perception**: Screen feels welcoming and trustworthy (vs. clinical), validated through user feedback or stakeholder approval
3. **Consistency**: Sign-in and signup screens share identical component styling (buttons, inputs, layout)
4. **Accessibility**: All touch targets ≥44x44px, color contrast ≥4.5:1 (WCAG AA), labels present
5. **Functionality Preserved**: All existing features work (email prefill, validation, consent, navigation, error handling)
6. **Reusable Components**: At least 5 components extracted to registry for reuse across auth screens

## Technical Context

### Platform/Framework:
Flutter (Dart)

### Special Constraints:
- **Riverpod State Management**: Preserve `ref.watch(authProvider)` and `ref.read(authProvider.notifier)` patterns
- **GoRouter Navigation**: Maintain `context.go('/onboarding', extra: userId)` navigation
- **Mounted Checks**: Critical for async operations - do not remove
- **Form Validation**: GlobalKey<FormState> and validator pattern must remain
- **Responsive Design**: Mobile-first (but should scale to tablet with max-width constraints)
- **iOS Safe Area**: Consider safe area insets for iPhone notch/home indicator

## Layout Structure (High-Level)

```
+----------------------------------+
| AppBar (56px)                    |
| "가비움 시작하기" + Back Button    |
+----------------------------------+
| ScrollView                       |
|                                  |
|  +----------------------------+  |
|  | Hero Section               |  |
|  | Title (3xl, Bold)          |  |
|  | Subtitle (base, Regular)   |  |
|  | 32px top padding           |  |
|  +----------------------------+  |
|                                  |
|  Email Input (48px)              |
|  Label (sm, Semibold)            |
|  Field (base, Regular)           |
|                                  |
|  16px spacing                    |
|                                  |
|  Password Input (48px)           |
|  + Password Strength Bar (8px)   |
|                                  |
|  16px spacing                    |
|                                  |
|  Confirm Password Input (48px)   |
|                                  |
|  24px spacing                    |
|                                  |
|  +----------------------------+  |
|  | Consent Section (Card)     |  |
|  | - Terms (required)         |  |
|  | - Privacy (required)       |  |
|  | - Marketing (optional)     |  |
|  +----------------------------+  |
|                                  |
|  32px spacing                    |
|                                  |
|  CTA Button (52px, Primary)      |
|  "회원가입"                       |
|                                  |
|  16px spacing                    |
|                                  |
|  Sign In Link (Ghost)            |
|  "이미 계정이 있으신가요?"         |
|                                  |
+----------------------------------+
```

## Approval Required

- [ ] User approves improvement direction
- [ ] All Design System tokens available (✅ Complete)
- [ ] Dependencies acknowledged (Sign-in screen will need update)
- [ ] Component extraction plan approved (6 new reusable components)

---

**Next Phase:** Upon approval, proceed to Phase 2B for detailed implementation specifications.
