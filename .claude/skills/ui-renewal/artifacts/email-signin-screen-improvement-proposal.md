# Email Sign-In Screen Improvement Proposal

## Overview
Transform the Email Sign-In screen from basic Material Design to Gabium-branded experience, ensuring visual consistency with the Email Signup screen and establishing trust while maintaining approachable, Toss-like friendliness.

## Current State Issues

### Brand Consistency Issues
- **Generic Material Design**: Screen uses default Material components without Gabium brand identity (no Primary green #4ADE80, default blue theme)
- **Inconsistent with Signup Screen**: Email Signup uses AuthHeroSection, GabiumTextField, GabiumButton, GabiumToast but Sign-In uses standard Flutter widgets
- **Missing Hero Section**: No welcoming hero section with title/subtitle, unlike Signup screen's "가비움과 함께 시작해요" branding
- **Default AppBar**: AppBar title "Sign In" (English) lacks brand personality, doesn't match "가비움 시작하기" style from Signup
- **Background Color**: Default white background (#FFFFFF) instead of brand's Neutral-50 (#F8FAFC) used in Signup
- **No Design System Tokens**: Text sizes, colors, spacing don't follow Design System (e.g., fontSize directly in code vs Typography tokens)

### Visual Quality Issues
- **Flat Visual Hierarchy**: All elements same visual weight, no clear focus on primary action
- **Inconsistent Spacing**: Arbitrary spacing (16px between fields) doesn't follow systematic scale from Design System
- **Standard TextFormField**: Default outlined style lacks polish, doesn't match GabiumTextField's refined borders and states
- **Standard ElevatedButton**: Default button styling without hover/active states, no shadow elevation
- **BottomSheet Styling**: SignIn failed BottomSheet uses basic rounded corners (20px) but misses Design System's 16px radius, no proper shadow, inconsistent padding
- **BottomSheet Icon Color**: Uses `Colors.orange` directly instead of Warning semantic color (#F59E0B)
- **Inconsistent Typography**: Direct font sizes (20, 14, 16) instead of Design System tokens (3xl, base, sm)
- **No Visual Feedback**: SnackBar for success uses default Material style, not GabiumToast

### UX Issues
- **Language Inconsistency**: UI mixes English ("Sign In", "Email", "Password", "Forgot password?") with Korean in BottomSheet ("로그인에 실패했습니다")
- **No Loading State Visual**: Button shows no loading indicator during async sign-in operation
- **BottomSheet Accessibility**: Icon size 48px, text sizes not optimized for readability hierarchy
- **Forgot Password Link Placement**: TextButton with "Forgot password?" feels disconnected, not visually grouped with password field
- **Missing Helper Text**: No guidance text for email/password fields (e.g., "가입 시 사용한 이메일을 입력해주세요")
- **BottomSheet Action Confusion**: Two actions (회원가입 하러가기, 닫기) but no clear primary vs secondary distinction
- **No Error Prevention**: Password field doesn't show/hide toggle icon consistency with Signup screen

## Improvement Direction

### Change 1: Add Gabium Hero Section
- **Current:** Standard AppBar with "Sign In" title only, white background
- **Proposed:** AuthHeroSection component with Korean title + subtitle, brand background
- **Rationale:** Establishes brand identity immediately, consistent with Signup screen, creates welcoming entry point
- **Design System Mapping:**
  - Component: AuthHeroSection (existing, reuse)
  - Background: Neutral-50 (#F8FAFC)
  - Title Typography: 3xl (28px, Bold)
  - Title Color: Neutral-800 (#1E293B)
  - Subtitle Typography: base (16px, Regular)
  - Subtitle Color: Neutral-600 (#475569)
  - Padding: top 32px (xl), bottom 16px (md), horizontal 16px (md)
  - Icon (optional): lock_outline, 48px, Primary (#4ADE80)

### Change 2: Replace TextFormFields with GabiumTextField
- **Current:** Standard TextFormField with OutlineInputBorder, no design system alignment
- **Proposed:** GabiumTextField component for email and password inputs
- **Rationale:** Visual consistency with Signup, proper focus states (#4ADE80 border), error states (#EF4444), refined styling
- **Design System Mapping:**
  - Component: GabiumTextField (existing, reuse)
  - Label Typography: sm (14px, Semibold)
  - Label Color: Neutral-700 (#334155)
  - Input Typography: base (16px, Regular)
  - Input Color: Neutral-800 (#1E293B)
  - Border Default: 2px solid Neutral-300 (#CBD5E1)
  - Border Focus: 2px solid Primary (#4ADE80)
  - Border Error: 2px solid Error (#EF4444)
  - Border Radius: sm (8px)
  - Height: 48px
  - Padding: 12px vertical (md), 16px horizontal (md)
  - Background: White (#FFFFFF)

### Change 3: Replace ElevatedButton with GabiumButton
- **Current:** Standard ElevatedButton with default Material styling, no loading state
- **Proposed:** GabiumButton with Primary variant, Large size, loading support
- **Rationale:** Brand-consistent CTA, proper interactive states, loading UX, visual prominence
- **Design System Mapping:**
  - Component: GabiumButton (existing, reuse)
  - Variant: Primary
  - Size: Large
  - Background: Primary (#4ADE80)
  - Text: White (#FFFFFF), lg (18px, Semibold)
  - Border Radius: sm (8px)
  - Height: 52px
  - Padding: 32px horizontal
  - Shadow: sm (0 2px 4px rgba(15,23,42,0.06))
  - Hover: Background #22C55E (Green-500)
  - Active: Background #16A34A (Green-600)
  - Disabled: Background #4ADE80 at 40% opacity
  - Loading: CircularProgressIndicator 24px (white)

### Change 4: Update AppBar to Gabium Style
- **Current:** Default AppBar with "Sign In" title
- **Proposed:** White AppBar with Korean title, Neutral-200 bottom border, consistent with Signup
- **Rationale:** Language consistency (Korean), brand alignment, professional separation from body
- **Design System Mapping:**
  - Background: White (#FFFFFF)
  - Elevation: 0 (flat)
  - Title Typography: xl (20px, Semibold)
  - Title Color: Neutral-800 (#1E293B)
  - Border Bottom: 1px solid Neutral-200 (#E2E8F0)
  - Back Icon Color: Neutral-700 (#334155)
  - Height: 56px (default)

### Change 5: Update Screen Background Color
- **Current:** Default white background
- **Proposed:** Neutral-50 background (#F8FAFC)
- **Rationale:** Matches Signup screen, softer visual, reduces eye strain, allows white cards to stand out
- **Design System Mapping:**
  - Background Color: Neutral-50 (#F8FAFC)

### Change 6: Replace SnackBar with GabiumToast
- **Current:** Standard SnackBar with "Sign in successful!" and error messages
- **Proposed:** GabiumToast.showSuccess() and GabiumToast.showError() with Korean messages
- **Rationale:** Brand consistency, better visual feedback, proper semantic colors, Korean language
- **Design System Mapping:**
  - Component: GabiumToast (existing, reuse)
  - Success Variant:
    - Background: #ECFDF5 (light green)
    - Border: 4px left, Success (#10B981)
    - Text: #065F46 (dark green), sm (14px, Regular)
    - Icon: check_circle_outline, 24px
    - Duration: 4 seconds
  - Error Variant:
    - Background: #FEF2F2 (light red)
    - Border: 4px left, Error (#EF4444)
    - Text: #991B1B (dark red), sm (14px, Regular)
    - Icon: error_outline, 24px
    - Duration: 6 seconds
  - Shadow: lg (0 8px 16px rgba(15,23,42,0.10))
  - Border Radius: md (12px)
  - Padding: 16px (md)

### Change 7: Redesign Sign-In Failed BottomSheet (Gabium Style)
- **Current:** Basic BottomSheet with 20px radius, Colors.orange icon, inconsistent spacing/typography
- **Proposed:** Gabium-styled BottomSheet matching Design System patterns
- **Rationale:** Professional error handling, clear signup funnel, brand consistency, proper visual hierarchy
- **Design System Mapping:**
  - Component: Bottom Sheet (Design System Section 6 - Feedback Components)
  - Width: 100% viewport
  - Padding: 24px (top/sides), 32px (bottom for safe area)
  - Border Radius: lg (16px, top corners only)
  - Shadow: 2xl (0 24px 48px rgba(15,23,42,0.16))
  - Backdrop: Neutral-900 (#0F172A) at 50% opacity
  - Handle: 32x4px bar, Neutral-300 (#CBD5E1), centered, 12px from top
  - Animation: Slide-up (300ms)
  - Icon: lock_outline, 48px, Warning (#F59E0B)
  - Title Typography: 2xl (24px, Bold), Neutral-800 (#1E293B)
  - Description Typography: base (16px, Regular), Neutral-600 (#475569)
  - Divider: 1px solid Neutral-200 (#E2E8F0), 24px spacing
  - Prompt Typography: lg (18px, Semibold), Neutral-700 (#334155)
  - Primary Button: GabiumButton Primary Large
  - Secondary Button: GabiumButton Ghost Medium

### Change 8: Add Password Visibility Toggle Consistency
- **Current:** Password field has visibility toggle but styling is default Material
- **Proposed:** IconButton with Neutral-500 color, matching Signup screen implementation
- **Rationale:** Visual consistency, clear affordance, matches Signup pattern
- **Design System Mapping:**
  - Icon: visibility / visibility_off (Material Icons)
  - Icon Size: 24px (base)
  - Icon Color: Neutral-500 (#64748B)
  - Touch Area: 44x44px
  - Position: suffixIcon in GabiumTextField

### Change 9: Update "Forgot password?" Link Styling
- **Current:** TextButton with default styling, right-aligned
- **Proposed:** GabiumButton Ghost variant with Primary color text
- **Rationale:** Consistent with Signup's ghost button style, clear interactive affordance
- **Design System Mapping:**
  - Component: GabiumButton Ghost (existing, reuse)
  - Text: Primary (#4ADE80), Medium (500)
  - Hover: Background Primary at 8% opacity
  - Active: Background Primary at 12% opacity
  - Typography: base (16px, Medium)
  - Alignment: right

### Change 10: Update "Don't have an account? Sign up" Link
- **Current:** TextButton with default styling
- **Proposed:** GabiumButton Ghost variant, centered, Korean text
- **Rationale:** Language consistency, brand style, clear secondary action
- **Design System Mapping:**
  - Component: GabiumButton Ghost (existing, reuse)
  - Text: "이미 계정이 있으신가요? 회원가입"
  - Same styling as Signup screen's reverse link
  - Size: Medium
  - Alignment: center

### Change 11: Systematic Spacing Following Design System
- **Current:** Arbitrary spacing (16px, 8px, 24px without system)
- **Proposed:** Design System spacing scale throughout
- **Rationale:** Visual rhythm, consistency, professional polish
- **Design System Mapping:**
  - Section spacing (Hero to Form): lg (24px)
  - Field spacing (Email to Password): md (16px)
  - Helper text to field: sm (8px)
  - Forgot password to next element: md (16px)
  - Button to link: md (16px)
  - Bottom padding: xl (32px)

## Design System Token Reference

Complete list of all tokens to be used:

| Element | Token Path | Value | Usage |
|---------|-----------|-------|-------|
| **Screen Background** | Colors - Neutral - 50 | #F8FAFC | Body background |
| **AppBar Background** | Colors - Base - White | #FFFFFF | AppBar surface |
| **AppBar Title** | Typography - xl | 20px, Semibold | "이메일로 로그인" |
| **AppBar Title Color** | Colors - Neutral - 800 | #1E293B | Title text |
| **AppBar Border** | Colors - Neutral - 200 | #E2E8F0 | Bottom border 1px |
| **AppBar Icon** | Colors - Neutral - 700 | #334155 | Back button |
| **Hero Background** | Colors - Neutral - 50 | #F8FAFC | Seamless with body |
| **Hero Title** | Typography - 3xl | 28px, Bold | Main heading |
| **Hero Title Color** | Colors - Neutral - 800 | #1E293B | Hero text |
| **Hero Subtitle** | Typography - base | 16px, Regular | Subtitle |
| **Hero Subtitle Color** | Colors - Neutral - 600 | #475569 | Subtitle text |
| **Hero Icon** | Icon - base | 48px | lock_outline |
| **Hero Icon Color** | Colors - Primary | #4ADE80 | Brand icon |
| **Hero Padding Top** | Spacing - xl | 32px | Top margin |
| **Hero Padding Bottom** | Spacing - md | 16px | Bottom margin |
| **Field Label** | Typography - sm | 14px, Semibold | Input labels |
| **Field Label Color** | Colors - Neutral - 700 | #334155 | Label text |
| **Field Input Text** | Typography - base | 16px, Regular | User input |
| **Field Input Color** | Colors - Neutral - 800 | #1E293B | Input text |
| **Field Border Default** | Colors - Neutral - 300 | #CBD5E1 | 2px border |
| **Field Border Focus** | Colors - Primary | #4ADE80 | 2px border |
| **Field Border Error** | Colors - Error | #EF4444 | 2px border |
| **Field Radius** | Border Radius - sm | 8px | Input corners |
| **Field Height** | Component Heights - Input | 48px | Touch-friendly |
| **Field Padding V** | Spacing - md | 12px | Vertical |
| **Field Padding H** | Spacing - md | 16px | Horizontal |
| **Field Icon Color** | Colors - Neutral - 500 | #64748B | Visibility icon |
| **Button Primary BG** | Colors - Primary | #4ADE80 | CTA background |
| **Button Primary Text** | Colors - Base - White | #FFFFFF | Button label |
| **Button Primary Text Size** | Typography - lg | 18px, Semibold | Large button |
| **Button Primary Height** | Component Heights - Button Large | 52px | Touch target |
| **Button Primary Padding** | Spacing - xl | 32px | Horizontal |
| **Button Primary Radius** | Border Radius - sm | 8px | Corners |
| **Button Primary Shadow** | Shadow - sm | 0 2px 4px rgba(15,23,42,0.06) | Elevation |
| **Button Hover** | Colors - Primary Hover | #22C55E | Hover state |
| **Button Active** | Colors - Primary Active | #16A34A | Pressed state |
| **Button Disabled** | Opacity - Disabled | 0.4 | Disabled opacity |
| **Button Loading Spinner** | Icon - base | 24px, white | Progress indicator |
| **Link Button Text** | Colors - Primary | #4ADE80 | Ghost button |
| **Link Button Hover BG** | Colors - Primary | #4ADE80 at 8% | Ghost hover |
| **Link Button Active BG** | Colors - Primary | #4ADE80 at 12% | Ghost active |
| **Toast Success BG** | Semantic - Success - Light | #ECFDF5 | Success feedback |
| **Toast Success Border** | Colors - Success | #10B981 | 4px left |
| **Toast Success Text** | Semantic - Success - Dark | #065F46 | Message text |
| **Toast Error BG** | Semantic - Error - Light | #FEF2F2 | Error feedback |
| **Toast Error Border** | Colors - Error | #EF4444 | 4px left |
| **Toast Error Text** | Semantic - Error - Dark | #991B1B | Message text |
| **Toast Icon** | Icon - base | 24px | Feedback icon |
| **Toast Shadow** | Shadow - lg | 0 8px 16px rgba(15,23,42,0.10) | Floating elevation |
| **Toast Radius** | Border Radius - md | 12px | Rounded corners |
| **Toast Padding** | Spacing - md | 16px | Internal padding |
| **BottomSheet Radius** | Border Radius - lg | 16px | Top corners |
| **BottomSheet Shadow** | Shadow - 2xl | 0 24px 48px rgba(15,23,42,0.16) | High elevation |
| **BottomSheet Backdrop** | Colors - Neutral - 900 | #0F172A at 50% | Modal overlay |
| **BottomSheet Padding Top** | Spacing - lg | 24px | Top spacing |
| **BottomSheet Padding Bottom** | Spacing - xl | 32px | Safe area |
| **BottomSheet Handle** | Colors - Neutral - 300 | #CBD5E1 | Drag indicator |
| **BottomSheet Icon** | Colors - Warning | #F59E0B | Alert icon |
| **BottomSheet Title** | Typography - 2xl | 24px, Bold | Modal title |
| **BottomSheet Title Color** | Colors - Neutral - 800 | #1E293B | Title text |
| **BottomSheet Body** | Typography - base | 16px, Regular | Description |
| **BottomSheet Body Color** | Colors - Neutral - 600 | #475569 | Body text |
| **BottomSheet Divider** | Colors - Neutral - 200 | #E2E8F0 | 1px line |
| **Section Spacing** | Spacing - lg | 24px | Between sections |
| **Field Spacing** | Spacing - md | 16px | Between inputs |
| **Helper Spacing** | Spacing - sm | 8px | Text to field |
| **Bottom Padding** | Spacing - xl | 32px | Scroll padding |

## Preserved Elements

What should NOT change:
- **Form Validation Logic**: Current validators for email and password work correctly (isValidEmail, isValidPassword)
- **Authentication Flow**: Sign-in logic with authProvider.notifier.signInWithEmail is solid
- **Onboarding Routing**: Profile check logic (redirect to /onboarding if no profile, /home if profile exists) is correct
- **BottomSheet UX Flow**: Showing signup prompt on sign-in failure with email prefill is excellent UX
- **Password Visibility Toggle**: Functionality is good (just needs visual polish)
- **Mounted Checks**: Proper `if (!mounted) return` checks prevent memory leaks

## Dependencies

### Prerequisites (must do first):
- ✅ None - All components already exist from Email Signup screen

### Impact (will need updating after):
- ✅ Isolated change - No other screens depend on Email Sign-In styling

## Component Reuse

### Existing Components to Reuse:
1. **AuthHeroSection** (Component Library): Add welcoming title "이메일로 로그인" + subtitle "가비움 계정으로 로그인해주세요" with lock icon
2. **GabiumTextField** (Component Library): Replace both TextFormField widgets (email, password) with proper validation props
3. **GabiumButton** (Component Library):
   - Primary Large for "로그인" CTA (with loading state)
   - Ghost Medium for "비밀번호를 잊으셨나요?" link
   - Ghost Medium for "계정이 없으신가요? 회원가입" link
   - Primary Large for BottomSheet "이메일로 회원가입 하러가기"
   - Ghost Medium for BottomSheet "닫기"
4. **GabiumToast** (Component Library): Replace SnackBar calls with showSuccess("로그인 성공!") and showError("로그인 실패: {message}")

### New Components to Create:
- ✅ None - All required components already exist

## Success Criteria

1. **Visual Consistency**: Sign-In screen matches Signup screen's visual language (same components, same spacing, same colors)
2. **Brand Identity**: Primary green (#4ADE80) visible in hero icon, focused inputs, CTA button
3. **Language Consistency**: All user-facing text in Korean (matching Signup screen)
4. **Component Reuse**: 100% usage of existing Gabium components (no custom widgets)
5. **Design System Compliance**: All spacing, typography, colors directly from Design System tokens
6. **Interactive States**: Hover, active, disabled, loading states visible and functional
7. **Accessibility**: WCAG AA contrast ratios maintained, 44x44px touch targets, clear error messages
8. **UX Polish**: Loading state during sign-in, proper toast feedback, refined BottomSheet design

## Technical Context

### Platform/Framework:
Flutter

### Special Constraints:
- Must maintain existing authentication logic (no changes to authProvider, profile check, routing)
- Must preserve form validation logic (validators work correctly)
- BottomSheet must support keyboard insets (MediaQuery.viewInsets.bottom)
- Must use `useRootNavigator: true` for BottomSheet (GoRouter compatibility, already implemented)
- Loading state must disable button during async operation (prevent double-tap)

## Layout Structure (High-Level)

```
+----------------------------------+
| AppBar (White)                   |
|  ← 이메일로 로그인               |
|  ━━━━━━━━━━━━━━━━━━━━━━━━ (border)|
+----------------------------------+
| Body (Neutral-50 background)     |
|                                  |
|  +------------------------------+|
|  | AuthHeroSection              ||
|  |  🔒 (Primary green icon)      ||
|  |  이메일로 로그인 (3xl, Bold)  ||
|  |  가비움 계정으로 로그인해주세요||
|  |  (base, Regular)             ||
|  +------------------------------+|
|                                  |
|  [24px spacing]                  |
|                                  |
|  +------------------------------+|
|  | GabiumTextField              ||
|  |  이메일 (label)               ||
|  |  [input field]               ||
|  +------------------------------+|
|                                  |
|  [16px spacing]                  |
|                                  |
|  +------------------------------+|
|  | GabiumTextField              ||
|  |  비밀번호 (label)             ||
|  |  [input field] 👁 (toggle)    ||
|  +------------------------------+|
|                                  |
|  [8px spacing]                   |
|                                  |
|  비밀번호를 잊으셨나요? (Ghost)   |
|                                  |
|  [24px spacing]                  |
|                                  |
|  +------------------------------+|
|  | GabiumButton Primary Large   ||
|  |  로그인                       ||
|  +------------------------------+|
|                                  |
|  [16px spacing]                  |
|                                  |
|  계정이 없으신가요? 회원가입       |
|  (Ghost button, centered)        |
|                                  |
|  [32px bottom padding]           |
+----------------------------------+

BOTTOM SHEET (on sign-in failure):
+----------------------------------+
| Handle (32x4px bar, centered)    |
|                                  |
|  ⚠️ (Warning #F59E0B, 48px)       |
|                                  |
|  로그인에 실패했습니다 (2xl, Bold)|
|                                  |
|  입력하신 이메일 또는 비밀번호가  |
|  일치하지 않습니다. (base)        |
|                                  |
|  ━━━━━━━━━━━━━━━━━━━━━━━━ (divider)|
|                                  |
|  💡 혹시 계정이 없으신가요?       |
|  (lg, Semibold)                  |
|                                  |
|  +------------------------------+|
|  | GabiumButton Primary Large   ||
|  |  이메일로 회원가입 하러가기   ||
|  +------------------------------+|
|                                  |
|  닫기 (Ghost button)              |
|                                  |
+----------------------------------+
```

## Approval Required

- [ ] User approves improvement direction
- [ ] All Design System tokens available (✅ confirmed)
- [ ] Dependencies acknowledged (✅ none)
- [ ] Component reuse plan confirmed (✅ 4 components)
