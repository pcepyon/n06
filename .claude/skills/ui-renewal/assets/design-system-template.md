# [Product Name] Design System

**Version:** 1.0  
**Last Updated:** [Date]  
**Status:** Draft | Active

---

## 1. Brand Foundation

### Brand Values
[Core values that drive design decisions]

### Target Audience
[Primary user demographic and characteristics]

### Design Principles
[3-5 key principles guiding all design decisions]

---

## 2. Color System

### Brand Colors

#### Primary
- **Color:** `#000000`
- **Usage:** Primary CTAs, key brand moments
- **Accessibility:** WCAG AA compliant when used on white

#### Secondary
- **Color:** `#000000`
- **Usage:** Supporting elements, accents

### Semantic Colors

#### Success
- **Color:** `#000000`
- **Usage:** Success states, positive feedback

#### Error
- **Color:** `#000000`
- **Usage:** Error states, destructive actions

#### Warning
- **Color:** `#000000`
- **Usage:** Warning states, cautionary feedback

#### Info
- **Color:** `#000000`
- **Usage:** Informational messages, neutral notifications

### Neutral Scale

| Level | Hex | Usage |
|-------|-----|-------|
| 50 | `#FAFAFA` | Background, lightest surface |
| 100 | `#F5F5F5` | Secondary background |
| 200 | `#EEEEEE` | Subtle borders |
| 300 | `#E0E0E0` | Dividers |
| 400 | `#BDBDBD` | Disabled elements |
| 500 | `#9E9E9E` | Placeholder text |
| 600 | `#757575` | Secondary text |
| 700 | `#616161` | Body text |
| 800 | `#424242` | Heading text |
| 900 | `#212121` | Highest emphasis |

### Interactive States

For each brand/semantic color, define:
- **Default:** Base color
- **Hover:** [+10% darkness or specific hex]
- **Active/Pressed:** [+20% darkness or specific hex]
- **Disabled:** [50% opacity or specific hex]

---

## 3. Typography

### Font Family
- **Primary:** [Font name], fallback: sans-serif
- **Secondary (optional):** [Font name for headings/accents]
- **Monospace (optional):** [Font for code]

### Type Scale

| Name | Size | Weight | Line Height | Usage |
|------|------|--------|-------------|-------|
| 2xl | 32px | Bold | 40px | Page titles |
| xl | 24px | Bold | 32px | Section headings |
| lg | 20px | Semibold | 28px | Subsection headings |
| base | 16px | Regular | 24px | Body text |
| sm | 14px | Regular | 20px | Supporting text |
| xs | 12px | Regular | 16px | Captions, labels |

### Usage Guidelines
- **Headings:** Use 2xl-lg with appropriate hierarchy
- **Body:** Use base for main content
- **UI Elements:** Use sm for labels, xs for metadata
- **Line length:** Max 75 characters for optimal readability

---

## 4. Spacing & Sizing

### Spacing Scale
Use multiples of 4px for consistency:

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | Tight spacing within components |
| sm | 8px | Component internal padding |
| md | 16px | Default spacing between elements |
| lg | 24px | Section spacing |
| xl | 32px | Major section breaks |
| 2xl | 48px | Page-level spacing |
| 3xl | 64px | Hero sections, major divisions |

### Component Heights
- **Input fields:** 40px
- **Buttons (default):** 40px
- **Buttons (small):** 32px
- **Buttons (large):** 48px

### Container Widths
- **Mobile:** 100% (with 16px side padding)
- **Tablet:** 768px max
- **Desktop:** 1200px max
- **Wide:** 1440px max

---

## 5. Visual Effects

### Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| sm | 4px | Buttons, inputs |
| md | 8px | Cards, containers |
| lg | 16px | Modals, large cards |
| full | 999px | Pills, circular elements |

### Shadow Levels

| Level | Shadow | Usage |
|-------|--------|-------|
| xs | 0 1px 2px rgba(0,0,0,0.05) | Subtle depth |
| sm | 0 2px 4px rgba(0,0,0,0.08) | Buttons, inputs |
| md | 0 4px 8px rgba(0,0,0,0.12) | Cards |
| lg | 0 8px 16px rgba(0,0,0,0.15) | Modals, popovers |
| xl | 0 16px 32px rgba(0,0,0,0.2) | Overlays |

### Opacity Scale
- **Disabled:** 0.4
- **Muted:** 0.6
- **Subtle:** 0.8

---

## 6. Core Components

### Buttons

#### Variants

**Primary**
- **Background:** Primary color
- **Text:** White
- **Border:** None
- **Usage:** Main CTAs, primary actions

**Secondary**
- **Background:** Transparent
- **Text:** Primary color
- **Border:** 1px solid Primary
- **Usage:** Secondary actions

**Tertiary**
- **Background:** Neutral-100
- **Text:** Neutral-800
- **Border:** None
- **Usage:** Less emphasis actions

**Ghost**
- **Background:** Transparent
- **Text:** Primary color
- **Border:** None
- **Usage:** Minimal emphasis

#### Sizes
- **Small:** 32px height, sm text, 12px horizontal padding
- **Medium:** 40px height, base text, 16px horizontal padding
- **Large:** 48px height, lg text, 24px horizontal padding

#### States
- **Hover:** [Specify for each variant]
- **Active:** [Specify for each variant]
- **Disabled:** 0.4 opacity, cursor not-allowed
- **Loading:** Show spinner, disable interaction

### Form Elements

#### Text Input
- **Height:** 40px
- **Padding:** 12px 16px
- **Border:** 1px solid Neutral-300
- **Border Radius:** sm
- **Font:** base size
- **States:**
  - Default: Neutral-300 border
  - Focus: Primary border, outline
  - Error: Error border, error message below
  - Disabled: Neutral-200 background, 0.6 opacity

#### Select
- Similar to text input
- Include dropdown icon (right-aligned)

#### Checkbox/Radio
- **Size:** 20px × 20px
- **Border:** 1px solid Neutral-400
- **Checked:** Primary background, white checkmark
- **Border Radius:** sm (checkbox), full (radio)

#### Label
- **Font:** sm size, Neutral-700
- **Spacing:** 8px below label, 4px above helper text

#### Helper Text
- **Font:** xs size, Neutral-600
- **Spacing:** 4px below input

#### Error Message
- **Font:** xs size, Error color
- **Icon:** Error icon (optional)

### Feedback Components

#### Toast/Snackbar
- **Width:** 320px (mobile: 90% viewport)
- **Padding:** 16px
- **Border Radius:** md
- **Shadow:** lg
- **Variants:** Success, Error, Warning, Info (use semantic colors)
- **Position:** Bottom-center (mobile), top-right (desktop)
- **Duration:** 3-5 seconds

#### Modal/Dialog
- **Max Width:** 600px
- **Padding:** 24px
- **Border Radius:** lg
- **Shadow:** xl
- **Backdrop:** rgba(0,0,0,0.5)
- **Structure:**
  - Header (title + close button)
  - Body (content)
  - Footer (actions, right-aligned)

#### Loading Indicator
- **Type:** Spinner or skeleton
- **Color:** Primary
- **Size:** 24px (small), 32px (medium), 48px (large)

### Layout Patterns

#### Card Container
- **Background:** White
- **Border:** 1px solid Neutral-200 (or no border with shadow)
- **Border Radius:** md
- **Shadow:** sm or md
- **Padding:** 16px (mobile), 24px (desktop)

#### Section Divider
- **Line:** 1px solid Neutral-200
- **Spacing:** lg above and below

#### Header Pattern
- **Height:** 64px
- **Background:** White
- **Border Bottom:** 1px solid Neutral-200
- **Padding:** 0 16px (mobile), 0 24px (desktop)

#### Footer Pattern
- **Background:** Neutral-50
- **Padding:** 48px 16px (mobile), 64px 24px (desktop)
- **Border Top:** 1px solid Neutral-200

---

## 7. Component Registry

This section tracks all designed components for reuse and consistency.

| Component | Created Date | Used In | Notes |
|-----------|--------------|---------|-------|
| [Component name] | [Date] | [Page/Feature] | [Special considerations] |

**Add new components here as they are created in Phase 2.**

---

## 8. Design Tokens Export

This Design System can be exported to various formats:
- CSS Variables
- Tailwind Config
- Flutter Theme
- JSON/YAML

See `scripts/export_design_tokens.py` for conversion.

---

## 9. Notes & Decisions

Track key design decisions and rationale:

- **[Date]** [Decision]: [Rationale]
- Example: "2024-11-22 Chose 16px base font: Better mobile readability"
