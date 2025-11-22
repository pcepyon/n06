# Phase 1: Design System Creation Guide

This guide is for the Design System Creation sub-agent. Use this when the orchestrator routes a Phase 1 task.

## Objective

Create a comprehensive, reusable Design System that establishes visual consistency and brand identity across the entire product.

## Input Requirements

Required inputs from user:
1. **Brand information** (logo, existing colors, guidelines if available)
2. **Product goals** (target audience, industry, positioning)
3. **Current UI samples** (screenshots or representative screens)

Optional inputs:
4. Technical constraints (platform, accessibility requirements)

## Process

### Step 1: Brand Analysis

Analyze provided materials to understand:

**Brand Identity:**
- What emotions should the design evoke? (trust, excitement, calm, energy)
- What industry standards apply? (healthcare = trust, fintech = security, consumer = delight)
- What differentiates this product? (luxury vs accessible, professional vs casual)

**Target Audience:**
- Age range and tech savviness
- Usage context (desktop work app vs mobile casual)
- Cultural considerations

**Existing Visual Language:**
- Extract colors from logos/screenshots
- Identify current typography patterns
- Note existing UI patterns to preserve continuity

### Step 2: Design System Generation

Use the template at `assets/design-system-template.md` as the base structure.

Fill out EACH section with specific, ready-to-use values:

#### 2.1 Brand Foundation
- Write 3-5 core design principles based on analysis
- Document target audience clearly
- Articulate brand values in design context

#### 2.2 Color System

**Approach:**
- Start with brand colors (from logo/existing materials)
- Generate complementary secondary colors
- Create semantic colors (success = green, error = red, etc.)
- Build neutral scale (9 levels from white to black)
- Define interactive states for each color

**Quality Checks:**
- Ensure WCAG AA contrast (4.5:1 for text)
- Test color combinations for harmony
- Verify semantic colors are distinct and recognizable

#### 2.3 Typography

**Approach:**
- Select 1-2 font families (consider platform availability)
- Create 6-level type scale with harmonious ratios
- Define weights and line heights for readability
- Write clear usage guidelines

**Quality Checks:**
- Mobile readability (min 16px for body text)
- Clear hierarchy (size differences should be noticeable)
- Line height accommodates descenders/ascenders

#### 2.4 Spacing & Sizing

**Approach:**
- Use 4px base unit for mathematical consistency
- Create scale: 4, 8, 12, 16, 24, 32, 48, 64px
- Define standard component heights
- Set container max-widths for different viewports

**Rationale:**
- 4px grid ensures pixel-perfect alignment
- Exponential scale provides clear hierarchy
- Standard heights improve consistency

#### 2.5 Visual Effects

**Border Radius:**
- sm (4px): Subtle rounding for inputs/buttons
- md (8px): Standard cards/containers
- lg (16px): Prominent containers
- full (999px): Pills and circular elements

**Shadows:**
- Start subtle, increase for elevation
- Use low opacity black (0.05-0.2)
- Match shadow intensity to component importance

#### 2.6 Core Components

Define specifications for each component type:

**Buttons:**
- 4 variants (Primary, Secondary, Tertiary, Ghost)
- 3 sizes (sm, md, lg)
- All states (default, hover, active, disabled, loading)
- Exact padding, text size, border values

**Form Elements:**
- Input, textarea, select, checkbox, radio
- Label, helper text, error message styles
- Consistent heights and padding
- Clear focus/error states

**Feedback Components:**
- Toast/snackbar specifications
- Modal structure and sizing
- Loading indicator styles

**Layout Patterns:**
- Card container specs
- Section divider style
- Header/footer patterns

### Step 3: Create Design System Document

**Critical: Use Artifact**
- Create the Design System as an **artifact**
- Use markdown format
- Follow the template structure exactly
- Replace ALL placeholder values with specific ones
- Title the artifact: "[Product Name] Design System v1.0"

**Document Quality:**
- Every color must be a specific hex value
- Every size must be a specific px/rem value
- Every component must have complete specifications
- No TODOs or placeholders in final output

### Step 4: Generate Proposal

After creating the Design System artifact, provide a **concise proposal** to the user:

**Proposal Structure:**

```markdown
# Design System Proposal

## Overview
[2-3 sentences summarizing the design direction and rationale]

## Key Design Decisions

### Color Palette
[Primary color choice and reasoning]
[Color psychology and brand alignment]

### Typography
[Font selection rationale]
[Readability and platform considerations]

### Visual Style
[Border radius, shadows, overall feel]
[Why these choices support brand/UX goals]

## Design Principles
[List 3-5 principles that guided all decisions]

## Next Steps
1. Review the complete Design System (see artifact)
2. Provide feedback or approve
3. Export design tokens if approved (optional)
```

**Keep proposal focused:**
- Explain WHY, not WHAT (what is in the artifact)
- Highlight 3-5 most important decisions
- Provide clear next steps

### Step 5: Handle Feedback

User may:
- **Approve:** Proceed to export tokens (optional)
- **Request changes:** Update specific sections
- **Reject direction:** Rethink approach with new guidance

**For changes:**
- Ask clarifying questions if needed
- Update the artifact (not create new one)
- Show what changed in a brief summary

**For rejections:**
- Understand what didn't work
- Ask for specific direction preferences
- Create revised version

## Quality Standards

Before presenting the Design System, verify:

✅ **Completeness:**
- No placeholder values (all #000000 replaced)
- Every section filled with specific values
- Component Registry initialized (even if empty)

✅ **Consistency:**
- Colors work together harmoniously
- Spacing uses the defined scale
- Typography follows the type scale
- All components reference defined tokens

✅ **Usability:**
- Clear usage guidelines for each element
- Examples show practical application
- Accessibility considerations documented

✅ **Brand Alignment:**
- Colors reflect brand identity
- Typography matches brand personality
- Visual effects support brand positioning

## Export Design Tokens (Optional)

After approval, offer to export design tokens:

```
Would you like me to export the design tokens in a specific format?
- JSON (universal)
- CSS Variables
- Tailwind Config
- Flutter Theme
```

If user agrees, run:
```bash
python scripts/export_design_tokens.py [design-system-artifact.md] --format [chosen-format]
```

## Common Pitfalls to Avoid

❌ **Generic/template values:** Every value must be intentionally chosen
❌ **Incomplete specs:** Components need ALL states and variants
❌ **Accessibility ignorance:** Check color contrast, font sizes
❌ **Platform mismatch:** Don't suggest fonts unavailable on target platform
❌ **Over-complication:** Start with essentials, can expand later
❌ **Inconsistency:** Use defined tokens, don't introduce random values

## Example Workflow

```
User: "Healthcare app for 30-40 year old women. Want trust + warmth. [logo attached]"

Agent:
1. Analyze logo colors (extract blue #2E5C8A)
2. Research healthcare design patterns (soft, accessible)
3. Create Design System artifact with:
   - Primary: Calming blue (#2E5C8A)
   - Secondary: Warm coral (#FF8B6A) for accent
   - Neutral: Soft grays for comfort
   - Typography: Open Sans (friendly, professional)
   - Rounded corners (approachable)
   - Gentle shadows (soft, not harsh)
4. Present proposal explaining choices
5. User: "Make primary lighter"
6. Update artifact: Primary #4A7BA7
7. User: "Approved"
8. Offer token export
```

## Success Criteria

The Design System is successful when:
- ✅ User approves the direction
- ✅ All values are specific and ready to use
- ✅ Artifact can be referenced in Phase 2
- ✅ Design tokens can be exported to code
- ✅ Component Registry is initialized

## Output Language Rule

**CRITICAL: All user-facing output MUST be in Korean.**

### Korean Output (사용자 대면):
- ✅ Design System Proposal summary
- ✅ Key design decisions explanation
- ✅ Questions to user
- ✅ Feedback responses
- ✅ Next steps

### English OK (Internal):
- ✅ Design System artifact content (markdown document)
- ✅ Token names and technical terms
- ✅ Code examples
- ✅ Internal processing notes

### Example:

**Good (Korean summary for user):**
```
# 디자인 시스템 제안

## 주요 디자인 결정

### 컬러 팔레트
차분한 블루-그린 계열로 신뢰감을 전달하면서도...

## 다음 단계
1. 전체 디자인 시스템 검토 (아티팩트 참조)
2. 피드백 또는 승인
```

**Bad (English):**
```
# Design System Proposal

## Key Design Decisions

### Color Palette
Calm blue-green palette to convey trust...
```
