# Coping Guide Screen Implementation Guide

## Implementation Summary

Based on the approved Improvement Proposal (v1.0), this guide provides exact specifications for implementing 7 design system improvements to the Coping Guide Screen. All specifications use Gabium Design System v1.0 tokens without deviation.

**Changes to Implement:**
1. Align Severity Warning Banner to Design System (ValidationAlert component)
2. Replace ElevatedButtons with Gabium Design System Buttons (Primary/Secondary variants)
3. Upgrade Card Structure with Design System Styling (top border accent, shadows, radius)
4. Implement Feedback Widget with Clear State Feedback (success animation, toast integration)
5. Add Dividers and Improve List Visual Separation (consistent spacing and dividers)
6. Enhance Typography Hierarchy with Explicit Design System Mapping (xl/lg/base scales)
7. Improve AppBar Styling and Consistency (design system header styling)

---

## Design Token Values

Exact mapping of all tokens used in this implementation:

| Element | Token Path | Value | Usage |
|---------|-----------|-------|-------|
| Primary Color | Colors - Primary | #4ADE80 | CTA buttons, accents, top border |
| Primary Hover | Colors - Primary Hover | #22C55E | Button hover state |
| Primary Active | Colors - Primary Active | #16A34A | Button active/pressed state |
| Error Color | Colors - Semantic - Error | #EF4444 | Warning banner border |
| Error Background | Colors - Semantic - Error-50 | #FEF2F2 | Warning banner background |
| Error Text Dark | Colors - Error Dark | #991B1B | Warning banner text |
| Success Color | Colors - Semantic - Success | #10B981 | Feedback confirmation |
| Success Background | Colors - Semantic - Success-50 | #ECFDF5 | Success toast background |
| Success Text Dark | Colors - Success Dark | #065F46 | Success message text |
| White | Colors - Neutral - White | #FFFFFF | Card/Button backgrounds |
| Neutral-50 | Colors - Neutral - 50 | #F8FAFC | Light backgrounds |
| Neutral-200 | Colors - Neutral - 200 | #E2E8F0 | Dividers, borders |
| Neutral-500 | Colors - Neutral - 500 | #64748B | Secondary text |
| Neutral-600 | Colors - Neutral - 600 | #475569 | Body text |
| Neutral-700 | Colors - Neutral - 700 | #334155 | Labels |
| Neutral-800 | Colors - Neutral - 800 | #1E293B | Headings |
| Typography - xl | Typography - xl | 20px Semibold (600) | Card titles, headers |
| Typography - lg | Typography - lg | 18px Semibold (600) | Section titles |
| Typography - base | Typography - base | 16px Regular (400) | Body text |
| Typography - sm | Typography - sm | 14px Regular (400) | Labels, secondary text |
| Spacing - xs | Spacing - xs | 4px | Text-icon spacing |
| Spacing - sm | Spacing - sm | 8px | Component internal spacing |
| Spacing - md | Spacing - md | 16px | Default element spacing |
| Spacing - lg | Spacing - lg | 24px | Section spacing |
| Spacing - xl | Spacing - xl | 32px | Major section gaps |
| Border Radius - sm | Border Radius - sm | 8px | Buttons, inputs, containers |
| Border Radius - md | Border Radius - md | 12px | Cards, modals |
| Border Width - Thin | Border Widths - Thin | 1px | Dividers, borders |
| Border Width - Medium | Border Widths - Medium | 2px | Button borders |
| Border Width - Thick | Border Widths - Thick | 4px | Accent borders |
| Shadow - sm | Shadow Levels - sm | 0 2px 4px rgba(15, 23, 42, 0.06), 0 1px 2px rgba(15, 23, 42, 0.04) | Cards, buttons |
| Shadow - md | Shadow Levels - md | 0 4px 8px rgba(15, 23, 42, 0.08), 0 2px 4px rgba(15, 23, 42, 0.04) | Interactive elements |
| Button Height - Medium | Component Heights - Button Medium | 44px | Standard buttons |
| Button Height - Small | Component Heights - Button Small | 36px | Secondary/feedback buttons |
| App Bar Height | Component Heights - App Bar | 56px | Header |
| Icon Size - base | Icon Sizes - base | 24px | Standard icons |
| Touch Target Min | Touch Targets | 44x44px | All interactive elements |

---

## Component Specifications

### Change 1: Align Severity Warning Banner to Design System

**Component Type:** ValidationAlert (reused from onboarding)

**Current Implementation Issue:**
- Uses hardcoded `Colors.red.shade100` and `Colors.red.shade900`
- Flat design without visual depth
- Inconsistent with design system semantic colors

**Proposed Implementation:**

**Visual Specifications:**
- **Background:** #FEF2F2 (Error-50)
- **Left Border:** 4px solid #EF4444 (Error)
- **Text Color:** #991B1B (Error Dark)
- **Text Font Size:** 16px (base, Regular 400)
- **Text Font Weight:** 400
- **Padding:** 16px horizontal, 12px vertical (md spacing)
- **Border Radius:** 8px (sm)
- **Shadow:** 0 2px 4px rgba(15, 23, 42, 0.06), 0 1px 2px rgba(15, 23, 42, 0.04) (sm shadow)

**Sizing:**
- Width: 100% of container (full width within card padding)
- Height: Auto (based on text content + padding)
- Min Height: 56px (accommodate icon + text + padding)

**Interactive States:**
- Default: As specified above
- Hover: No hover state (informational banner)
- Disabled: Not applicable
- Focus: Not applicable (not interactive)

**Accessibility:**
- ARIA label: `alert` role implicit in ValidationAlert
- Color not sole differentiator: Icon + border + text color combination
- Text contrast: #991B1B on #FEF2F2 = 7.8:1 (WCAG AAA)
- Icon Size: 24px (base)

**Implementation Notes:**
- Replace `SeverityWarningBanner` widget with `ValidationAlert(type: error)`
- Component source: `lib/features/onboarding/presentation/widgets/validation_alert.dart`
- Props: `type: ValidationAlertType.error`, `message: String`, `icon: IconData (optional)`

---

### Change 2: Replace ElevatedButtons with Gabium Design System Buttons

**Component Type:** GabiumButton (primary & secondary variants)

**Current Implementation Issue:**
- Uses Material ElevatedButton defaults
- No variant system or semantic color mapping
- Buttons lack proper loading and success states

**Part A: Main CTA Buttons (Detail View, Symptom Check)**

**Button Variant:** Primary

**Visual Specifications:**
- **Background:** #4ADE80 (Primary)
- **Text Color:** #FFFFFF (White)
- **Text Font Size:** 16px (base)
- **Text Font Weight:** 600 (Semibold)
- **Padding:** 24px horizontal, 8px vertical (44px total height with text)
- **Border Radius:** 8px (sm)
- **Shadow:** 0 2px 4px rgba(15, 23, 42, 0.06), 0 1px 2px rgba(15, 23, 42, 0.04) (sm shadow)
- **Border:** None

**Sizing:**
- Width: 100% of container (full-width button within card)
- Height: 44px (medium)
- Min Width: None (full width preferred)

**Interactive States:**
- **Default:** Background #4ADE80
- **Hover:** Background #22C55E (Primary Hover), Shadow md (0 4px 8px rgba(15, 23, 42, 0.08), 0 2px 4px rgba(15, 23, 42, 0.04))
- **Active/Pressed:** Background #16A34A (Primary Active), Shadow xs
- **Disabled:** Background #4ADE80 at 40% opacity (0.4), Text opacity 50%, Cursor not-allowed
- **Loading:** Background #4ADE80 + 16px spinner (white color), Text hidden, maintain 44px height

**Accessibility:**
- ARIA label: Not needed (text is descriptive)
- Touch target: 44x44px minimum (meets WCAG AAA)
- Focus outline: 2px solid #4ADE80, 2px offset
- Color contrast: White text on #4ADE80 = 4.5:1 (WCAG AA)

**Implementation Notes:**
- Replace `ElevatedButton` with `GabiumButton(variant: GabiumButtonVariant.primary, size: GabiumButtonSize.medium)`
- Component source: `lib/features/authentication/presentation/widgets/gabium_button.dart`
- Use for: "더 자세한 가이드 보기" (Detail view button), Symptom check button
- Margin-bottom: 16px (md spacing)

---

**Part B: Feedback Buttons (Yes/No)**

**Button Variant:** Secondary

**Visual Specifications:**
- **Background:** Transparent
- **Text Color:** #4ADE80 (Primary)
- **Text Font Size:** 16px (base)
- **Text Font Weight:** 600 (Semibold)
- **Border:** 2px solid #4ADE80 (Primary)
- **Padding:** 16px horizontal, 6px vertical (36px total height with text)
- **Border Radius:** 8px (sm)
- **Shadow:** None

**Sizing:**
- Width: Auto or 48% of container (if side-by-side, 16px gap between)
- Height: 36px (small)
- Display: 2 buttons in row with 16px (md spacing) between them

**Interactive States:**
- **Default:** Transparent background, #4ADE80 border and text
- **Hover:** Background #4ADE80 at 8% opacity, Border #22C55E
- **Active/Pressed:** Background #4ADE80 at 12% opacity, Border #16A34A
- **Disabled:** Border at 40% opacity, Text at 40% opacity, Cursor not-allowed
- **Selected (after user clicks):** Transition to success state (see Change 4)

**Accessibility:**
- ARIA label: Not needed (text is descriptive)
- Touch target: 36x44px minimum (height less, but width allows 44px tap area when considering padding)
- Focus outline: 2px solid #4ADE80, 2px offset
- Color contrast: #4ADE80 on transparent white background = 4.5:1 (WCAG AA)

**Implementation Notes:**
- Replace secondary buttons with `GabiumButton(variant: GabiumButtonVariant.secondary, size: GabiumButtonSize.small)`
- Component source: `lib/features/authentication/presentation/widgets/gabium_button.dart`
- Use for: "도움이 되었나요?" feedback Yes/No buttons
- Layout: Row with MainAxisAlignment.spaceEvenly or MainAxisAlignment.center with spacing

---

### Change 3: Upgrade Card Structure with Design System Styling

**Component Type:** Material Card with custom styling (not a new component)

**Current Implementation Issue:**
- Generic Material Card without semantic styling
- No visual hierarchy or color accent
- Missing subtle depth with shadows
- No clear visual separation between cards

**Visual Specifications:**

**Card Container:**
- **Background:** #FFFFFF (White)
- **Border:** 1px solid #E2E8F0 (Neutral-200)
- **Top Accent Border:** 3px solid #4ADE80 (Primary) - positioned at top edge
- **Border Radius:** 12px (md)
- **Shadow:** 0 2px 4px rgba(15, 23, 42, 0.06), 0 1px 2px rgba(15, 23, 42, 0.04) (sm shadow)
- **Padding:** 16px (md spacing) - all sides
- **Margin Between Cards:** 16px (md spacing)

**Sizing:**
- Width: 100% of container minus safe area/screen padding
- Height: Auto (content-driven)
- Min Height: None

**Internal Card Spacing:**
- **Top Section (Warning Banner if present):** Margin-bottom 16px
- **Title Section:** Margin-bottom 16px
- **Description Section:** Margin-bottom 16px
- **Divider (if present):** Margin 16px top/bottom
- **Button Section:** Margin-bottom 16px
- **Feedback Section:** No margin-bottom on last element

**Interactive States:**
- **Default:** As specified above
- **Hover:** Shadow md (0 4px 8px rgba(15, 23, 42, 0.08), 0 2px 4px rgba(15, 23, 42, 0.04)), Transform translateY(-2px) optional
- **Focus:** Not applicable (card itself not focusable)

**Accessibility:**
- Semantic structure: Card acts as container for related content
- No specific ARIA needed if children are properly labeled
- Sufficient color contrast maintained for all text within card

**Layout on Different Screens:**
- Mobile (< 768px): 100% width with 16px side padding in ListView
- Tablet (768px - 1024px): 100% width with 16px side padding
- Desktop (> 1024px): Not primary target, but 100% width with max-width 640px recommended

**Implementation Notes:**
- Use Material Card with custom decoration
- Can be extracted to custom `GabiumCard` widget for reusability
- Currently done inline in `coping_guide_card.dart`
- Top border accent provides visual interest without cluttering design

---

### Change 4: Implement Feedback Widget with Clear State Feedback

**Component Type:** New widget `CopingGuideFeedbackResult` + integration with GabiumToast

**Current Implementation Issue:**
- Simple text feedback without visual confirmation
- No loading state during submission
- No success state animation
- Unclear next steps for user

**Visual Specifications - Feedback Question Section:**

**Before Feedback:**
- **Text:** "도움이 되었나요?" (base, Regular 400, Neutral-600 #475569)
- **Margin-bottom:** 12px (sm spacing)
- **Buttons:** Two GabiumButton Secondary (36px height, see Change 2 Part B)
- **Button Layout:** Row with 16px (md) spacing between buttons

**During Submission (Loading State):**
- Buttons disabled (visual feedback)
- Optional: Spinner in main CTA area
- Overlay fade (optional opacity 0.6)

**After Feedback Submission (Success State):**
- **Duration:** 2000ms display, then auto-dismiss or persist with "다시 평가하기" option
- **Animation:** Fade-in + scale-up (200ms ease)

**Success State Visual:**
- **Icon:** Checkmark circle (24px)
- **Icon Color:** #10B981 (Success)
- **Message:** "피드백을 주셔서 감사합니다!"
- **Message Color:** #065F46 (Success Dark)
- **Message Font:** 16px (base), Semibold (600)
- **Background (optional):** #ECFDF5 (Success-50)
- **Padding:** 16px (md)
- **Border Radius:** 8px (sm)
- **Border Left:** 4px solid #10B981 (Success)

**Toast Notification (Concurrent):**
- **Variant:** Success
- **Background:** #ECFDF5 (Success-50)
- **Border Left:** 4px solid #10B981
- **Text Color:** #065F46 (Success Dark)
- **Message:** "피드백이 저장되었습니다" or "감사합니다!"
- **Duration:** 3000ms (3 seconds)
- **Position:** Bottom-center (mobile), Top-right (desktop)
- **Shadow:** 0 8px 16px rgba(15, 23, 42, 0.10), 0 4px 8px rgba(15, 23, 42, 0.06) (lg shadow)

**Interactive States:**
- **Default (before click):** Buttons visible, interactive
- **Hovering over Yes/No:** Button hover state (Change 2 Part B)
- **Selected:** Button becomes disabled, success state appears
- **After success:** Optional "다시 평가하기" button appears (Secondary variant, small)

**Accessibility:**
- ARIA label: Success state announces "feedback submitted successfully"
- Icon conveys success (checkmark shape)
- Text message provides explicit confirmation
- Color not sole indicator (icon + text + color)
- Focus management: After success, focus moves to "다시 평가하기" button or card container

**Implementation Notes:**
- Create new `CopingGuideFeedbackResult` widget
- Integrate with `GabiumToast` for notification
- Notifier already handles feedback submission logic (no changes to state management)
- Animation: Use Flutter's `AnimatedOpacity` + `ScaleTransition` for fade-in/scale-up
- Success state can replace feedback button section entirely

---

### Change 5: Add Dividers and Improve List Visual Separation

**Component Type:** Dividers (visual separators, not interactive)

**Current Implementation Issue:**
- No dividers between card items
- Inconsistent spacing makes visual scanning difficult
- Cards blend together in dense lists

**Visual Specifications - Between Cards:**

**List Item Divider (between Card 1 and Card 2):**
- **Line Style:** 1px solid #E2E8F0 (Neutral-200)
- **Full Width:** Extends full width of parent (ListView)
- **Margin Top:** 8px after Card 1 (sm spacing)
- **Margin Bottom:** 8px before Card 2 (sm spacing)
- **Opacity:** 100% (full opacity, not faded)

**Effective Spacing Between Cards:**
- Card 1 bottom padding: 16px
- Divider margins: 8px + 8px = 16px
- Card 2 top padding: 16px
- Total visual gap: ~32px of spacing (16px margin + divider + 16px margin)

---

**Visual Specifications - Internal Card Divider (if needed):**

**Internal Section Divider (between description and buttons):**
- **Line Style:** 1px solid #E2E8F0 (Neutral-200)
- **Width:** Container width (full width within card padding)
- **Margin:** 16px (md spacing) above and below divider
- **Usage:** After description/content, before action buttons
- **Optional:** Can be implemented or omitted based on visual testing

---

**List Container Padding:**
- **Left/Right Padding:** 16px (md spacing)
- **Top Padding:** 16px (after AppBar 56px)
- **Bottom Padding:** 16px (before BottomNavigation 56px)

**Implementation Notes:**
- Dividers are simple Divider() widgets in Flutter
- Parent ListView.builder handles spacing with itemExtent or itemBuilder logic
- Can use `Padding` + `Divider` for controlled spacing
- Color matches Neutral-200 exactly (#E2E8F0)

---

### Change 6: Enhance Typography Hierarchy with Explicit Design System Mapping

**Component Type:** Text styling (Flutter TextStyle mapping)

**Current Implementation Issue:**
- Relies on Theme.of(context).textTheme without explicit design system alignment
- Inconsistent heading levels
- No explicit color mapping for hierarchy

**Visual Specifications:**

**AppBar Title:**
- **Text:** "부작용 대처 가이드"
- **Font Size:** 20px (xl)
- **Font Weight:** 700 (Bold)
- **Color:** #1E293B (Neutral-800)
- **Line Height:** 28px
- **Letter Spacing:** 0
- **Font Family:** Pretendard Variable

**Card Title (Guide Title):**
- **Font Size:** 18px (lg)
- **Font Weight:** 600 (Semibold)
- **Color:** #1E293B (Neutral-800)
- **Line Height:** 26px
- **Letter Spacing:** 0
- **Font Family:** Pretendard Variable
- **Margin-bottom:** 16px (md spacing)
- **Example:** "복부팽만감 대처 가이드"

**Symptom Name (in detail guide):**
- **Font Size:** 20px (xl)
- **Font Weight:** 700 (Bold)
- **Color:** #1E293B (Neutral-800)
- **Line Height:** 28px
- **Letter Spacing:** 0
- **Font Family:** Pretendard Variable
- **Margin-bottom:** 24px (lg spacing)
- **Optional:** Can add Primary color accent (#4ADE80) for visual interest
- **Example:** "복부팽만감"

**Description/Body Text:**
- **Font Size:** 16px (base)
- **Font Weight:** 400 (Regular)
- **Color:** #475569 (Neutral-600)
- **Line Height:** 24px
- **Letter Spacing:** 0
- **Font Family:** Pretendard Variable
- **Margin-bottom:** 16px (md spacing)
- **Max Width:** 600px recommended for readability
- **Example:** "복부팽만감은 약물의 부작용으로 나타날 수 있습니다..."

**Section Title (in detailed guide):**
- **Font Size:** 18px (lg)
- **Font Weight:** 600 (Semibold)
- **Color:** #1E293B (Neutral-800)
- **Line Height:** 26px
- **Letter Spacing:** 0
- **Font Family:** Pretendard Variable
- **Margin-bottom:** 8px (sm spacing)
- **Margin-top:** 24px (lg spacing, for section separation)
- **Example:** "증상 완화 방법"

**Label/Helper Text:**
- **Font Size:** 14px (sm)
- **Font Weight:** 400 (Regular)
- **Color:** #64748B (Neutral-500)
- **Line Height:** 20px
- **Letter Spacing:** 0
- **Font Family:** Pretendard Variable
- **Usage:** Labels, secondary text, feedback question
- **Example:** "도움이 되었나요?"

**Button Text:**
- **Font Size:** 16px (base)
- **Font Weight:** 600 (Semibold)
- **Color:** Inherited from button component (see Change 2)
- **Line Height:** 24px
- **Letter Spacing:** 0
- **Font Family:** Pretendard Variable

**Validation Alert Text:**
- **Font Size:** 16px (base)
- **Font Weight:** 400 (Regular)
- **Color:** #991B1B (Error Dark)
- **Line Height:** 24px
- **Letter Spacing:** 0
- **Font Family:** Pretendard Variable

**Implementation Notes:**
- Create TextStyle constants in a theme file or constants file
- Use `Theme.of(context).textTheme` + custom extension if available
- Pretendard Variable fallback to system fonts for compatibility
- Ensure line-height (line-spacing in Flutter: Height property) is maintained at specified values

---

### Change 7: Improve AppBar Styling and Consistency

**Component Type:** AppBar with custom styling (Material AppBar)

**Current Implementation Issue:**
- Default Material AppBar without design system styling
- No visual connection to Gabium Design System
- Missing Primary color accent

**Visual Specifications:**

**AppBar Container:**
- **Height:** 56px (fixed)
- **Background Color:** #FFFFFF (White)
- **Elevation:** 0 (no shadow by default)
- **Border Bottom:** 1px solid #E2E8F0 (Neutral-200)
- **Bottom Accent Border (optional):** 3px solid #4ADE80 (Primary) - positioned below main border

**Title:**
- **Text:** "부작용 대처 가이드"
- **Font Size:** 20px (xl)
- **Font Weight:** 700 (Bold)
- **Color:** #1E293B (Neutral-800)
- **Font Family:** Pretendard Variable
- **Alignment:** Left-aligned
- **Padding:** 0 (padding handled by AppBar)

**Back Button:**
- **Size:** 44x44px (touch area)
- **Icon Size:** 24x24px (icon visual size)
- **Icon Color:** #475569 (Neutral-600)
- **Background:** Transparent
- **Alignment:** Left-aligned
- **Padding:** 10px (centered within 44x44 area)
- **Left Padding (from edge):** 16px (md spacing)

**Actions (if any):**
- **Buttons:** 44x44px (touch area)
- **Icon Size:** 24x24px
- **Icon Color:** #475569 (Neutral-600)
- **Right Padding (from edge):** 16px (md spacing)
- **Spacing Between Actions:** 8px (sm spacing)

**Interactive States:**
- **Back Button Hover:** Background #F1F5F9 (Neutral-100)
- **Back Button Active:** Background #E2E8F0 (Neutral-200)
- **Focus:** 2px solid #4ADE80 outline, 2px offset

**SafeArea Integration:**
- **Top Padding:** Respects safe area inset (notch/status bar)
- **Left/Right Padding:** Respects safe area inset

**Responsive Behavior:**
- Mobile (< 768px): Full width, 16px side padding
- Tablet (768px+): Full width, 16px side padding

**Accessibility:**
- Back button has semantic "back" meaning
- Title is large enough (20px minimum) for readability
- Touch targets minimum 44x44px (meets WCAG AAA)
- Color contrast: #1E293B text on #FFFFFF background = 13.5:1 (WCAG AAA)

**Implementation Notes:**
- Use Material AppBar with custom styling
- `elevation: 0` removes default shadow
- Add bottom border via `decoration: BoxDecoration(border: Border(bottom: BorderSide(...)))`
- Can create custom AppBar widget `GabiumAppBar` for reusability
- Back button typically auto-generated by Navigator (no custom implementation needed)

---

## Layout Specification

### CopingGuideScreen Overall Layout

```
┌─────────────────────────────────────┐
│ AppBar (56px, Change 7)             │
│ "부작용 대처 가이드" (xl, Bold)      │
│ Background: White                   │
│ Border-bottom: Neutral-200          │
├─────────────────────────────────────┤
│ SafeArea + ListView.builder          │
│ Padding: 16px (md) horizontal       │
│ Spacing between items: 8px          │
│                                     │
│ ┌─ Card 1 (Change 3 - 5) ─────────┐│
│ │ ╔ Top border (3px Primary) ╗    ││
│ │ ║ Background: White         ║    ││
│ │ ║ Border: Neutral-200       ║    ││
│ │ ║ Radius: md (12px)         ║    ││
│ │ ║ Shadow: sm                ║    ││
│ │ ║ Padding: md (16px)        ║    ││
│ │ ║                           ║    ││
│ │ ║ [Conditional] Warning    ║    ││
│ │ ║ ValidationAlert(error)   ║    ││
│ │ ║ Margin-bottom: md         ║    ││
│ │ ║                           ║    ││
│ │ ║ Title: "증상 대처 가이드" ║    ││
│ │ ║ (lg, Semibold #1E293B)   ║    ││
│ │ ║ Margin-bottom: md         ║    ││
│ │ ║                           ║    ││
│ │ ║ Description: [Text]       ║    ││
│ │ ║ (base, Regular #475569)  ║    ││
│ │ ║ Margin-bottom: md         ║    ││
│ │ ║                           ║    ││
│ │ ║ ─ Divider (Change 5) ─   ║    ││
│ │ ║ 1px Neutral-200           ║    ││
│ │ ║ Margin: md top/bottom     ║    ││
│ │ ║                           ║    ││
│ │ ║ Button: "더 자세한 가이드" ║   ││
│ │ ║ GabiumButton Primary      ║    ││
│ │ ║ Height: 44px              ║    ││
│ │ ║ Full width                ║    ││
│ │ ║ Margin-bottom: md         ║    ││
│ │ ║                           ║    ││
│ │ ║ [Optional] Feedback       ║    ││
│ │ ║ Question: "도움이 되었..."  ║   ││
│ │ ║ Buttons: Yes/No           ║    ││
│ │ ║ (Secondary, small, 36px)  ║    ││
│ │ ║ Spacing: md between       ║    ││
│ │ ║                           ║    ││
│ │ ║ [After select] Success    ║    ││
│ │ ║ CopingGuideFeedbackResult ║    ││
│ │ ║ Animation: Fade+Scale     ║    ││
│ │ ║ Duration: 200ms           ║    ││
│ │ ║                           ║    ││
│ │ ╚═══════════════════════════╝    ││
│ └─────────────────────────────────┘│
│                                     │
│ ─ Divider (Change 5) ──────────    │
│ 1px Neutral-200, full width         │
│ Margin: sm (8px) top/bottom         │
│                                     │
│ ┌─ Card 2 (next guide) ───────────┐│
│ │ [Same structure as Card 1]      ││
│ └─────────────────────────────────┘│
│ [... more cards ...]                │
│                                     │
├─────────────────────────────────────┤
│ GabiumBottomNavigation (56px)       │
│ Existing - no changes needed        │
└─────────────────────────────────────┘
```

**Responsive Breakpoints:**
- **Mobile (< 768px):**
  - Full width cards
  - 16px side padding
  - 56px AppBar height
  - 56px BottomNavigation height

- **Tablet (768px - 1024px):**
  - Full width cards
  - 24px side padding (optional)
  - Same heights

- **Desktop (> 1024px):**
  - Not primary target
  - Can constrain max-width 640px with center alignment
  - Same padding/height rules

---

### DetailedGuideScreen Layout

```
┌─────────────────────────────────────┐
│ AppBar (56px, Change 7)             │
│ Title: "{Symptom} 대처 가이드"      │
│ Back Button (44x44px)               │
│ (No bottom accent border needed)    │
├─────────────────────────────────────┤
│ SingleChildScrollView                │
│ Padding: md (16px) horizontal       │
│ Padding: lg (24px) top/bottom       │
│                                     │
│ Symptom Name: "{Symptom}"           │
│ (xl, Bold, Neutral-800)             │
│ Margin-bottom: lg (24px)            │
│                                     │
│ ┌─ Section 1 ────────────────────┐ │
│ │ Title: "[Section Title]"        │ │
│ │ (lg, Semibold, Neutral-800)     │ │
│ │ Margin-bottom: sm (8px)         │ │
│ │                                 │ │
│ │ Content: "[Text]"               │ │
│ │ (base, Regular, Neutral-600)    │ │
│ │ Line-height: 24px               │ │
│ └─────────────────────────────────┘ │
│ Margin-bottom: lg (24px)            │
│                                     │
│ ┌─ Section 2 ────────────────────┐ │
│ │ [Same structure as Section 1]  │ │
│ └─────────────────────────────────┘ │
│ [... more sections ...]              │
│                                     │
└─────────────────────────────────────┘
```

---

## Interaction Specifications

### Severity Warning Banner (Change 1)

**Display Condition:** If `coping_guide.severity_level == "high"` or similar

**Interactions:**
- Static display (not interactive)
- Always visible when condition met
- No dismissal option (critical information)

---

### Main CTA Button - "더 자세한 가이드 보기" (Change 2 Part A)

**Click/Tap:**
- Trigger: Navigate to DetailedGuideScreen with guide data
- Visual feedback: Button transitions to active state (#16A34A background)
- Duration: Instant (navigation immediate)
- Navigation: `Navigator.push(context, MaterialPageRoute(...))`

**Loading State (if applicable):**
- Not typically needed for navigation
- Can show if data fetch required: Button shows 16px spinner (white), text hidden
- Duration: Until navigation completes

**Disabled State:**
- Button disabled if guide data unavailable
- Visual: #4ADE80 at 40% opacity
- Cursor: not-allowed
- Not tappable

---

### Feedback Buttons - Yes/No (Change 2 Part B + Change 4)

**Before Selection:**
- Both buttons interactive
- Primary color styling (Change 2 Part B)
- Spacing: 16px (md) between buttons

**Click/Tap - User Selects Yes or No:**
- **Visual feedback:**
  1. Button transitions to active state (#4ADE80 at 12% background)
  2. Opposite button becomes disabled (if needed)
  3. Notifier processes feedback (async call)
  4. Loading spinner appears in button or overlay (200ms)

- **Duration:** 2000ms for spinner

- **After Success:**
  1. Success state animation (fade-in + scale-up, 200ms ease)
  2. Shows checkmark icon (#10B981, 24px)
  3. Success message appears: "피드백을 주셔서 감사합니다!"
  4. Optional: GabiumToast notification (3 seconds)
  5. Optional: "다시 평가하기" button appears (Secondary variant)
  6. Auto-dismiss after 3000ms or persist with re-rate option

- **On Error:**
  1. Error toast appears (GabiumToast with error variant)
  2. Buttons become interactive again
  3. User can retry

---

### Card Hover State (Change 3)

**Hover (Desktop):**
- Card transitions to shadow md
- Slight lift: transform translateY(-2px) optional
- Duration: 200ms ease
- On mouse leave: Returns to default shadow sm

**Mobile:**
- No hover state (touch-based interaction)
- Active state shows when tapped (not typically cards)

---

### Visual Feedback - Success State (Change 4)

**Animation Sequence:**
1. **T=0ms:** Feedback buttons disappear (fade out optional)
2. **T=0ms:** Success widget appears (fade in + scale from 0.8 to 1.0)
3. **T=200ms:** Full opacity, scale 1.0, user sees success message
4. **T=2000ms:** If auto-dismiss: fade out (200ms)
5. **T=2200ms:** Widget removed from tree

**Concurrent Toast Notification:**
1. Appears at T=0ms (or T=500ms if delayed)
2. Slides in from bottom-center (mobile) or top-right (desktop)
3. Displays for 3000ms
4. Auto-dismisses with fade-out (200ms)

---

## Implementation by Framework

### Flutter Implementation

**File Structure:**
```
lib/features/coping_guide/presentation/
├── screens/
│   ├── coping_guide_screen.dart (Modify - Apply Changes 1-7)
│   ├── detailed_guide_screen.dart (Modify - Apply Changes 6-7 AppBar)
├── widgets/
│   ├── coping_guide_card.dart (Modify - Apply Changes 2-3, 5-6)
│   ├── severity_warning_banner.dart (Modify/Delete - Replace with ValidationAlert)
│   ├── feedback_widget.dart (Modify - Apply Change 4)
│   ├── coping_guide_feedback_result.dart (Create - New widget for Change 4)
├── application/
│   └── notifiers/
│       └── coping_guide_notifier.dart (No changes - state management)
├── domain/
│   └── entities/
│       └── coping_guide.dart (No changes)
└── infrastructure/
    └── repositories/ (No changes)
```

**Change 1: Replace Severity Warning Banner**

```dart
// OLD (in coping_guide_card.dart)
if (guide.severity.isHigh) {
  SeverityWarningBanner(severity: guide.severity)
}

// NEW
if (guide.severity.isHigh) {
  ValidationAlert(
    type: ValidationAlertType.error,
    message: 'This is a high-severity symptom requiring attention',
    icon: Icons.warning_rounded,
  )
}
```

**Component Integration:**
- Import: `import 'package:your_app/features/onboarding/presentation/widgets/validation_alert.dart';`
- Props: `type`, `message`, `icon` (optional)
- Container padding: 16px
- Margin-bottom: 16px

---

**Change 2 Part A: Main CTA Button**

```dart
// OLD (in coping_guide_card.dart)
ElevatedButton(
  onPressed: () => Navigator.push(context, ...),
  child: Text('더 자세한 가이드 보기'),
)

// NEW
GabiumButton(
  variant: GabiumButtonVariant.primary,
  size: GabiumButtonSize.medium,
  onPressed: () => Navigator.push(context, ...),
  isLoading: false,
  child: Text('더 자세한 가이드 보기'),
)
```

**Styling (automatic via GabiumButton):**
- Height: 44px
- Background: #4ADE80
- Text: White, 16px, Semibold
- Padding: 24px horizontal
- Radius: 8px
- Shadow: sm
- Full width via `SizedBox.expand(child: GabiumButton(...))`

---

**Change 2 Part B: Feedback Buttons**

```dart
// OLD (in feedback_widget.dart)
Row(
  children: [
    ElevatedButton(onPressed: () => handleFeedback(true), child: Text('네')),
    ElevatedButton(onPressed: () => handleFeedback(false), child: Text('아니요')),
  ],
)

// NEW
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    Expanded(
      child: GabiumButton(
        variant: GabiumButtonVariant.secondary,
        size: GabiumButtonSize.small,
        onPressed: () => handleFeedback(true),
        child: Text('네'),
      ),
    ),
    SizedBox(width: 16), // md spacing
    Expanded(
      child: GabiumButton(
        variant: GabiumButtonVariant.secondary,
        size: GabiumButtonSize.small,
        onPressed: () => handleFeedback(false),
        child: Text('아니요'),
      ),
    ),
  ],
)
```

**Sizing:**
- Height: 36px (automatic via GabiumButtonSize.small)
- Text: 16px, Semibold
- Width: 50% each (via Expanded)
- Spacing: 16px (SizedBox width)

---

**Change 3: Card Styling**

```dart
// OLD (in coping_guide_card.dart)
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(...),
  ),
)

// NEW
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    border: Border(
      top: BorderSide(color: Color(0xFF4ADE80), width: 3),
      bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
      left: BorderSide(color: Color(0xFFE2E8F0), width: 1),
      right: BorderSide(color: Color(0xFFE2E8F0), width: 1),
    ),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 2,
        offset: Offset(0, 1),
      ),
    ],
  ),
  padding: EdgeInsets.all(16),
  margin: EdgeInsets.only(bottom: 16),
  child: Column(...),
)
```

**Extract to Custom Widget (Recommended):**
```dart
class GabiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;

  const GabiumCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 16),
  });

  @override
  Widget build(BuildContext context) {
    // [Container with decoration as above]
  }
}

// Usage:
GabiumCard(
  child: Column(...),
)
```

---

**Change 4: Feedback Widget with Success State**

```dart
// Create new file: coping_guide_feedback_result.dart

class CopingGuideFeedbackResult extends StatefulWidget {
  final VoidCallback? onRetry;

  const CopingGuideFeedbackResult({this.onRetry});

  @override
  State<CopingGuideFeedbackResult> createState() => _CopingGuideFeedbackResultState();
}

class _CopingGuideFeedbackResultState extends State<CopingGuideFeedbackResult>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    // Auto-dismiss after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFFECFDF5), // Success-50
            border: Border(
              left: BorderSide(color: Color(0xFF10B981), width: 4),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF10B981), size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '피드백을 주셔서 감사합니다!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF065F46),
                      ),
                    ),
                    if (widget.onRetry != null) ...[
                      SizedBox(height: 12),
                      GabiumButton(
                        variant: GabiumButtonVariant.secondary,
                        size: GabiumButtonSize.small,
                        onPressed: widget.onRetry,
                        child: Text('다시 평가하기'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Usage (in feedback_widget.dart):**
```dart
if (_feedbackSubmitted) {
  CopingGuideFeedbackResult(
    onRetry: () => setState(() => _feedbackSubmitted = false),
  )
} else {
  // Show feedback buttons
}

// Also show toast concurrently
GabiumToast.show(
  context,
  message: '피드백이 저장되었습니다',
  variant: GabiumToastVariant.success,
  duration: Duration(seconds: 3),
);
```

---

**Change 5: Dividers**

```dart
// In coping_guide_card.dart - internal divider

Column(
  children: [
    // Description text
    Text(...),

    // Divider
    Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Divider(
        color: Color(0xFFE2E8F0),
        height: 1,
        thickness: 1,
      ),
    ),

    // Button
    GabiumButton(...),
  ],
)

// In coping_guide_screen.dart - between cards

ListView.separated(
  itemCount: guides.length,
  separatorBuilder: (context, index) => Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: Divider(
      color: Color(0xFFE2E8F0),
      height: 1,
      thickness: 1,
    ),
  ),
  itemBuilder: (context, index) => CopingGuideCard(
    guide: guides[index],
  ),
)
```

---

**Change 6: Typography**

```dart
// Create constants file: lib/core/presentation/constants/text_styles.dart

class GabiumTextStyles {
  // AppBar & Main Headings
  static const appBarTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700, // Bold
    color: Color(0xFF1E293B), // Neutral-800
    height: 1.4, // 28px line-height / 20px font
    letterSpacing: 0,
    fontFamily: 'Pretendard',
  );

  // Card Titles
  static const cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600, // Semibold
    color: Color(0xFF1E293B),
    height: 1.44, // 26px / 18px
    letterSpacing: 0,
    fontFamily: 'Pretendard',
  );

  // Section Titles
  static const sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1E293B),
    height: 1.44,
    letterSpacing: 0,
    fontFamily: 'Pretendard',
  );

  // Body Text
  static const bodyText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    color: Color(0xFF475569), // Neutral-600
    height: 1.5, // 24px / 16px
    letterSpacing: 0,
    fontFamily: 'Pretendard',
  );

  // Labels & Secondary Text
  static const label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFF64748B), // Neutral-500
    height: 1.43, // 20px / 14px
    letterSpacing: 0,
    fontFamily: 'Pretendard',
  );
}

// Usage:
Text(
  '더 자세한 가이드 보기',
  style: GabiumTextStyles.bodyText,
)
```

---

**Change 7: AppBar Styling**

```dart
// OLD (in coping_guide_screen.dart)
AppBar(
  title: Text('부작용 대처 가이드'),
)

// NEW
AppBar(
  title: Text(
    '부작용 대처 가이드',
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: Color(0xFF1E293B),
      fontFamily: 'Pretendard',
    ),
  ),
  backgroundColor: Colors.white,
  elevation: 0,
  bottom: PreferredSize(
    preferredSize: Size.fromHeight(4), // Accent border height
    child: Column(
      children: [
        Divider(
          color: Color(0xFFE2E8F0),
          height: 1,
          thickness: 1,
        ),
        Container(
          height: 3,
          color: Color(0xFF4ADE80), // Primary accent
        ),
      ],
    ),
  ),
  leading: BackButton(
    color: Color(0xFF475569),
  ),
  iconTheme: IconThemeData(
    color: Color(0xFF475569),
    size: 24,
  ),
)
```

**Extract to Custom Widget (Recommended):**
```dart
class GabiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showAccentBorder;
  final List<Widget>? actions;

  const GabiumAppBar({
    required this.title,
    this.showAccentBorder = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: GabiumTextStyles.appBarTitle,
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(showAccentBorder ? 4 : 1),
        child: showAccentBorder
            ? Column(
                children: [
                  Divider(...),
                  Container(height: 3, color: Color(0xFF4ADE80)),
                ],
              )
            : Divider(...),
      ),
      leading: BackButton(color: Color(0xFF475569)),
      actions: actions,
      iconTheme: IconThemeData(color: Color(0xFF475569), size: 24),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (showAccentBorder ? 4 : 1));
}

// Usage:
GabiumAppBar(title: '부작용 대처 가이드')
```

---

## Component Library Additions

### New Component: CopingGuideFeedbackResult

**File Location:** `.claude/skills/ui-renewal/component-library/flutter/coping_guide_feedback_result.dart`

**Component Details:**
- **Type:** Animated feedback confirmation widget
- **Purpose:** Show success state after feedback submission
- **Dependencies:** Flutter animations, GabiumButton
- **Props:**
  - `onRetry`: VoidCallback (optional) - callback for re-rate button
- **States:**
  - Initial (hidden)
  - Animating in (scale 0.8→1.0, opacity 0→1, 200ms)
  - Display (full opacity, scale 1.0)
  - Animating out (reverse, 200ms, auto-triggered at 3000ms)
- **Styling:**
  - Background: #ECFDF5 (Success-50)
  - Border-left: 4px #10B981 (Success)
  - Icon: Checkmark, 24px, #10B981
  - Text: "피드백을 주셔서 감사합니다!", 16px, #065F46, Semibold
  - Optional: "다시 평가하기" button (Secondary variant)

**Registry Entry:**
```json
{
  "name": "CopingGuideFeedbackResult",
  "created_date": "2025-11-23",
  "used_in": ["CopingGuideScreen"],
  "notes": "Animated success state for feedback submission. Can be reused in other feedback flows."
}
```

---

## Component Registry Updates

**Add to Component Registry (`.claude/skills/ui-renewal/design-systems/gabium-design-system.md` Section 8):**

```
| CopingGuideFeedbackResult | 2025-11-23 | Coping Guide Screen | Animated success state with checkmark. Auto-dismisses after 3s. Optional re-rate button. |
```

**Note:** Other components (ValidationAlert, GabiumButton, GabiumToast) already exist in registry and will be reused.

---

## Testing Checklist

### Visual Testing
- [ ] All colors match token values exactly (hex codes verified)
- [ ] Typography sizes and weights match specification (test on real devices)
- [ ] Spacing between elements matches token values (md=16px, etc.)
- [ ] Border radius matches specification (sm=8px, md=12px)
- [ ] Shadows display correctly and match specification
- [ ] Card top border accent (3px Primary) visible
- [ ] Dividers (1px Neutral-200) render correctly
- [ ] ValidationAlert displays with correct colors and layout
- [ ] GabiumButtons match primary/secondary styling
- [ ] AppBar accent border appears below main border
- [ ] All text colors have sufficient contrast

### Interactive Testing
- [ ] Primary button (Detail view) navigates to detailed guide
- [ ] Secondary buttons (Feedback Yes/No) are clickable
- [ ] Button hover states work (desktop/web only)
- [ ] Button active states show correct color
- [ ] Disabled buttons are visually distinct
- [ ] Feedback success animation plays (fade-in, scale-up)
- [ ] Success message displays after feedback submission
- [ ] "다시 평가하기" button appears and works
- [ ] GabiumToast notification shows and auto-dismisses
- [ ] Loading state shows spinner (if fetching data)
- [ ] Error handling shows error toast
- [ ] Back button navigates back correctly
- [ ] AppBar title text is readable

### Responsive Testing
- [ ] Mobile (< 768px): Full-width cards, correct padding
- [ ] Tablet (768px - 1024px): Layout scaling correct
- [ ] Portrait vs Landscape: Layout adapts properly
- [ ] SafeArea respected (notches, status bar)
- [ ] BottomNavigation not obscured by content

### Accessibility Testing
- [ ] Color contrast meets WCAG AA (4.5:1 minimum for text)
- [ ] Touch targets minimum 44x44px
- [ ] Keyboard navigation works (Tab order correct)
- [ ] Focus indicators visible (outline on interactive elements)
- [ ] ARIA labels present on non-obvious elements
- [ ] Screen reader announces success state correctly
- [ ] Error messages are announced
- [ ] Form labels associated with inputs (if applicable)
- [ ] All icons have descriptive labels or context

### Cross-Device Testing
- [ ] iPhone 12/13/14/15 (various sizes)
- [ ] iPad (tablet layout)
- [ ] Android phones (various sizes)
- [ ] Android tablets
- [ ] Landscape orientation on all devices
- [ ] Different system font sizes (accessibility settings)

---

## Accessibility Checklist

- [ ] **Color Contrast:**
  - [ ] Headings (#1E293B on white): 13.5:1 (WCAG AAA)
  - [ ] Body text (#475569 on white): 8.2:1 (WCAG AAA)
  - [ ] Primary buttons (white on #4ADE80): 4.5:1 (WCAG AA)
  - [ ] Error text (#991B1B on #FEF2F2): 7.8:1 (WCAG AAA)
  - [ ] Success text (#065F46 on #ECFDF5): 11.5:1 (WCAG AAA)

- [ ] **Touch Targets:**
  - [ ] All buttons: 44x44px minimum
  - [ ] Back button: 44x44px
  - [ ] Card interactive area: 44px min height

- [ ] **Keyboard Navigation:**
  - [ ] Tab order: AppBar → Cards → Buttons → BottomNav
  - [ ] All interactive elements reachable via Tab key
  - [ ] Enter/Space activates buttons
  - [ ] Escape closes dialogs/back navigation

- [ ] **Focus Indicators:**
  - [ ] Focus outline visible on all interactive elements
  - [ ] Outline color: #4ADE80 (Primary)
  - [ ] Outline width: 2px
  - [ ] Outline offset: 2px

- [ ] **Screen Reader Support:**
  - [ ] AppBar title announced
  - [ ] Card structure clear (semantic grouping)
  - [ ] Buttons labeled descriptively ("더 자세한 가이드 보기" not "Button")
  - [ ] Icons have alternative text where necessary
  - [ ] Success state announced ("Feedback submitted successfully")
  - [ ] Error messages announced

- [ ] **Motion & Animation:**
  - [ ] Animations respect `prefers-reduced-motion` (optional - can disable animations)
  - [ ] Auto-dismiss timings sufficient (3+ seconds for users to read)

---

## Files to Create/Modify

### New Files to Create

1. **`.claude/skills/ui-renewal/component-library/flutter/coping_guide_feedback_result.dart`**
   - CopingGuideFeedbackResult widget implementation
   - With animations (scale + opacity)
   - Optional re-rate button

### Modified Files

1. **`lib/features/coping_guide/presentation/screens/coping_guide_screen.dart`**
   - Apply Change 7 (AppBar styling) OR create custom GabiumAppBar
   - Apply Change 5 (dividers between cards)
   - Update ListView.builder to use ListView.separated

2. **`lib/features/coping_guide/presentation/screens/detailed_guide_screen.dart`**
   - Apply Change 7 (AppBar styling)
   - Apply Change 6 (typography hierarchy)
   - Update text styles to use GabiumTextStyles

3. **`lib/features/coping_guide/presentation/widgets/coping_guide_card.dart`**
   - Apply Change 1 (replace SeverityWarningBanner with ValidationAlert)
   - Apply Change 2 Part A (replace ElevatedButton with GabiumButton Primary)
   - Apply Change 3 (card container styling - top border, radius, shadow)
   - Apply Change 5 (internal divider)
   - Apply Change 6 (typography)
   - OR extract to custom GabiumCard widget

4. **`lib/features/coping_guide/presentation/widgets/feedback_widget.dart`**
   - Apply Change 2 Part B (secondary buttons)
   - Apply Change 4 (success state logic)
   - Integrate CopingGuideFeedbackResult widget
   - Show GabiumToast on success

5. **`lib/features/coping_guide/presentation/widgets/severity_warning_banner.dart`**
   - DELETE this file (replaced by ValidationAlert)

6. **`lib/core/presentation/constants/text_styles.dart` (Create if not exists)**
   - GabiumTextStyles class with all typography specifications
   - Reusable across app

7. **`lib/core/presentation/widgets/gabium_app_bar.dart` (Optional - for reuse)**
   - GabiumAppBar custom widget
   - Encapsulates AppBar + accent border styling

8. **`lib/core/presentation/widgets/gabium_card.dart` (Optional - for reuse)**
   - GabiumCard custom widget
   - Encapsulates card container styling

### No Changes Required
- `lib/features/coping_guide/application/notifiers/coping_guide_notifier.dart` (state management unchanged)
- `lib/features/coping_guide/domain/entities/coping_guide.dart` (entities unchanged)
- `lib/features/coping_guide/infrastructure/repositories/` (data layer unchanged)

### Assets Needed
- No new assets (all components use existing icons and colors)
- Ensure Pretendard font is available in pubspec.yaml

---

## Implementation Order

**Phase 1: Foundation (No User Interaction)**
1. [ ] Create `text_styles.dart` with GabiumTextStyles
2. [ ] Create custom GabiumCard widget (optional)
3. [ ] Create custom GabiumAppBar widget (optional)
4. [ ] Apply Change 6 (typography) to all text elements
5. [ ] Apply Change 7 (AppBar styling)

**Phase 2: Visual Design (Static UI)**
6. [ ] Apply Change 3 (card container styling)
7. [ ] Apply Change 1 (ValidationAlert integration)
8. [ ] Apply Change 5 (dividers and spacing)
9. [ ] Update ListView to use ListView.separated

**Phase 3: Interactive Components**
10. [ ] Apply Change 2 Part A (Primary button replacement)
11. [ ] Apply Change 2 Part B (Secondary button replacement)
12. [ ] Create CopingGuideFeedbackResult widget
13. [ ] Apply Change 4 (success state logic)
14. [ ] Integrate GabiumToast for notifications

**Phase 4: Testing**
15. [ ] Visual testing (all devices)
16. [ ] Interactive testing (all interactions)
17. [ ] Accessibility testing
18. [ ] Cross-device testing

---

## Validation Steps

### Pre-Implementation Validation

Before starting implementation, verify:
- [ ] All design tokens are available in design system file
- [ ] GabiumButton component exists and has primary/secondary variants
- [ ] ValidationAlert component exists and accepts error type
- [ ] GabiumToast component exists and has success variant
- [ ] Pretendard font is available in app (pubspec.yaml)

### During Implementation Validation

As you implement each change:
- [ ] Code compiles without errors
- [ ] No warnings in analyzer output
- [ ] All token hex values match specification exactly
- [ ] All spacing values use md/sm/lg scale
- [ ] All typography uses GabiumTextStyles
- [ ] All colors use token names, not hardcoded values (if possible)

### Post-Implementation Validation

Before submitting for review:
- [ ] All 7 changes implemented
- [ ] Visual appearance matches specification
- [ ] All tokens used correctly
- [ ] Accessibility requirements met
- [ ] Tests pass (if applicable)
- [ ] No regressions on other screens
- [ ] Performance acceptable (no jank on animations)

---

## Rollback Plan

If implementation encounters issues:

### Critical Issue (Build Failure)
1. Revert all changes to previous git commit
2. Identify failing code
3. Fix issue in isolation
4. Re-apply changes incrementally (change by change)

### Visual Issue (Appearance Incorrect)
1. Compare visual output to specification document
2. Identify mismatched token (color, size, spacing)
3. Update specific token value
4. Re-test on multiple devices

### Logic Issue (State Management, Interaction)
1. Check notifier and state management logic
2. Verify async/await patterns
3. Test with mock data
4. Check console for errors

### Accessibility Issue
1. Run accessibility audit (device accessibility settings)
2. Use contrast checker for color contrast
3. Use screen reader (VoiceOver/TalkBack)
4. Test keyboard navigation

### Incremental Rollback by Change
If specific change is problematic, revert just that change:
- Change 1: Revert ValidationAlert integration, restore SeverityWarningBanner
- Change 2: Revert GabiumButton, restore ElevatedButton
- Change 3: Revert card styling, restore Material Card defaults
- Change 4: Revert success state logic, keep simple feedback
- Change 5: Remove dividers, rely on card spacing
- Change 6: Revert typography, use Theme.of(context).textTheme
- Change 7: Revert AppBar styling, restore defaults

---

## Notes for Developers

### Gotchas & Tips

1. **SafeArea Integration:**
   - Ensure ListView respects safe area inset (notches, home indicators)
   - Use SafeArea wrapper or MediaQuery.of(context).padding

2. **BottomNavigation Overlap:**
   - ListView padding-bottom should prevent overlap with 56px BottomNav
   - Test on devices with safe area inset (notch, rounded corners)

3. **Animations Performance:**
   - CopingGuideFeedbackResult uses SingleTickerProviderStateMixin
   - Dispose AnimationController in dispose() to prevent memory leaks
   - Test on lower-end devices for jank

4. **GabiumButton Loading State:**
   - If using loading state, ensure button remains 44px height
   - Spinner should be 16px (small)

5. **Divider Colors:**
   - Use exact hex #E2E8F0 (Neutral-200)
   - On white background (#FFFFFF), should be subtle but visible

6. **Pretendard Font:**
   - If font not loading, check pubspec.yaml and assets folder
   - Can fall back to system font, but design system specifies Pretendard

7. **Dark Mode (Future Consideration):**
   - Current implementation light mode only
   - Dark mode would require color token adjustments
   - Success state colors might need adjustment for dark background

---

## Phase 2C Readiness

This implementation guide is **ready for Phase 2C (Automated Implementation)** when:
- ✅ User approves all specifications
- ✅ All design tokens verified in design system
- ✅ All component dependencies available
- ✅ No blocking questions or missing information

**Next Steps (User Confirmation Required):**
1. Review this implementation guide
2. Confirm all specifications align with design system
3. Approve proceeding to Phase 2C (automatic code generation/implementation)
4. Provide feedback if any specifications need clarification

---

**Document Status**: Ready for Implementation
**Last Updated**: 2025-11-23
**Version**: 1.0
**Framework**: Flutter
**Design System**: Gabium v1.0
