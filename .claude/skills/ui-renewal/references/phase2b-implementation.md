# Phase 2B: Implementation Specification Guide

This guide is for the Implementation sub-agent. Use this when the orchestrator routes a Phase 2B task.

## Objective

Convert approved Improvement Proposal into precise, developer-ready implementation specifications. Follow the Proposal as **Single Source of Truth** with minimal additional interpretation.

## Prerequisites

**Required:**
- Improvement Proposal artifact from Phase 2A (MUST be in context)
- User has approved the proposal

**Context Strategy:**
- Load ONLY the Improvement Proposal
- Reference ONLY the Design System tokens listed in the Proposal's "Design System Token Reference" table
- Do NOT load full Design System (to save context)
- Do NOT load original UI screenshots/code (already analyzed in Phase 2A)

## Process

### Step 1: Load Context (Precisely)

**CRITICAL: Load only what's necessary:**

1. **Improvement Proposal artifact** (entire document)
2. **Design System tokens** - ONLY those listed in Proposal's "Design System Token Reference" table

**Do NOT load:**
- ❌ Full Design System document
- ❌ Original UI screenshots/code
- ❌ Analysis notes from Phase 2A
- ❌ Unrelated Design System sections

**Verify checklist:**
```
✅ Improvement Proposal loaded
✅ Token Reference table identified
✅ Required token values extracted
✅ Platform/framework noted from Proposal
```

### Step 2: Extract Design System Tokens from Proposal

**Use ONLY the "Design System Token Reference" table in the Proposal.**

Example extraction:
```
From Proposal Token Reference:
- Button BG: Primary (#2E5C8A)
- Button Text: base (16px, Regular)
- Button Padding: md (16px)
- Border Radius: sm (4px)
- Shadow: sm (0 2px 4px rgba(0,0,0,0.08))
```

**These are the ONLY tokens you can use. No additional lookups.**

### Step 3: For Each Change in Proposal

The Proposal lists changes like "Change 1", "Change 2", etc.

For each change, create detailed implementation spec:

#### 3.1 Component Specification

**Structure:**
```markdown
### [Change Title from Proposal]

**Component Type:** [From Proposal's Design System Mapping]

**Visual Specifications:**
- Background: [Token value from Reference table]
- Text Color: [Token value]
- Font Size: [Token value]
- Font Weight: [Token value]
- Padding: [Token value - be specific: "16px horizontal, 12px vertical"]
- Border: [If applicable, token value]
- Border Radius: [Token value]
- Shadow: [Token value with full CSS]

**Sizing:**
- Width: [Specific value or "100% of container" or "auto"]
- Height: [Specific value, e.g., "40px"]
- Min/Max Width: [If applicable]

**Interactive States:**
[Use values from Proposal's Design System Mapping]
- Default: [All specs above]
- Hover:
  - Background: [From Proposal or token value]
  - Cursor: pointer
  - [Any other changes]
- Active/Pressed:
  - Background: [From Proposal or token value]
  - [Any other changes]
- Disabled:
  - Background: [Token value or opacity]
  - Cursor: not-allowed
  - Opacity: [From Proposal or 0.4]
- Focus: [Keyboard navigation]
  - Outline: [Color + width]
  - Outline Offset: [e.g., 2px]

**Accessibility:**
- ARIA label: [If needed]
- Role: [If non-standard element]
- Keyboard navigation: [Tab order, enter/space behavior]
- Color contrast: [Ratio, e.g., 4.5:1]
```

#### 3.2 Layout Specification

**Based on Proposal's "Layout Structure" section:**

```markdown
### Layout

**Container:**
- Max Width: [From token or Proposal]
- Margin: [Centering, e.g., "0 auto"]
- Padding: [From token reference]

**Grid/Flexbox:**
- Display: [flex/grid]
- Gap: [From token reference]
- Columns: [If grid, e.g., "3 columns, 1fr each"]
- Alignment: [justify/align properties]

**Responsive Breakpoints:**
- Mobile (< 768px): [Layout changes]
- Tablet (768px - 1024px): [Layout changes]
- Desktop (> 1024px): [Layout as specified]

**Element Hierarchy:**
[Based on Proposal's layout structure]
```
Parent Container
├── Header Section
│   ├── Title (Typography: xl, Color: Neutral-900)
│   └── Subtitle (Typography: base, Color: Neutral-600)
├── Content Section
│   ├── Card 1 (Background: Neutral-50, Padding: md, Radius: md, Shadow: sm)
│   ├── Card 2
│   └── Card 3
└── Footer Section
```

#### 3.3 Interaction Specification

**For each interactive element:**

```markdown
### Interactions

**[Element Name]:**

**Click/Tap:**
- Trigger: [Action, e.g., "Submit form"]
- Visual feedback: Active state (see states above)
- Duration: Instant OR [animation duration]

**Loading State:**
[If applicable from Proposal]
- Replace button text with spinner
- Spinner: [Size, color]
- Disable interaction
- Maintain button size

**Success State:**
[If applicable]
- Visual: [Icon, color change, message]
- Duration: [How long shown]
- Auto-dismiss: [Yes/No, timing]

**Error State:**
[If applicable]
- Visual: [Error color from tokens, shake animation]
- Message: [Below element, color from Error semantic]
- Persist until: [User corrects or dismissed]

**Animations:**
[Only if specified in Proposal]
- Transition: [Property, duration, easing]
  Example: "all 200ms ease-in-out"
```

### Step 4: Create Complete Implementation Guide

**Document Storage:**
Save to: `projects/{screen-name}/{YYYYMMDD}-implementation-v1.md`

**Naming Convention:**
- Format: `{YYYYMMDD}-{document-type}-v{version}.md`
- Example: `20251122-implementation-v1.md`
- Version increments if revisions needed

**Directory Structure:**
All documents for a screen/feature go in `projects/{screen-name}/`:
- `{YYYYMMDD}-proposal-v1.md` (Phase 2A)
- `{YYYYMMDD}-implementation-v1.md` (Phase 2B)
- `metadata.json` (auto-generated in Phase 3)

**Structure the full guide as follows:**

```markdown
# [Feature/Screen Name] Implementation Guide

## Implementation Summary

Based on the approved Improvement Proposal, this guide provides exact specifications for implementation.

**Changes to Implement:**
[Brief list from Proposal]

## Design Token Values

[Copy the exact table from Proposal's "Design System Token Reference"]

| Element | Token Path | Value | Usage |
|---------|-----------|-------|-------|
| ... | ... | ... | ... |

## Component Specifications

[For each Change from Proposal, provide complete spec as in Step 3.1]

### Change 1: [Title]
[Complete component specification]

### Change 2: [Title]
[Complete component specification]

## Layout Specification

[Complete layout spec as in Step 3.2]

## Interaction Specifications

[Complete interaction specs as in Step 3.3]

## Implementation by Framework

### React/Next.js

**Component Structure:**
```jsx
// [ComponentName].jsx
import { useState } from 'react';

export default function ComponentName() {
  const [state, setState] = useState();

  return (
    <div className="container">
      {/* Structure from Layout Specification */}
      <button
        className="primary-button"
        onClick={handleClick}
        disabled={isDisabled}
      >
        Button Text
      </button>
    </div>
  );
}
```

**Styles (Tailwind or CSS):**
```css
/* Using exact token values */
.primary-button {
  background: #2E5C8A;  /* Primary from tokens */
  color: #FFFFFF;
  font-size: 16px;      /* base from tokens */
  padding: 16px;        /* md from tokens */
  border-radius: 4px;   /* sm from tokens */
  box-shadow: 0 2px 4px rgba(0,0,0,0.08);  /* sm from tokens */
}

.primary-button:hover {
  background: #254A6E;  /* Primary +10% darker */
}

.primary-button:active {
  background: #1C3952;  /* Primary +20% darker */
}

.primary-button:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}
```

### Flutter

**Widget Structure:**
```dart
// component_name.dart
import 'package:flutter/material.dart';

class ComponentName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),  // md from tokens
      decoration: BoxDecoration(
        color: Color(0xFF2E5C8A),  // Primary from tokens
        borderRadius: BorderRadius.circular(4.0),  // sm from tokens
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),  // sm shadow from tokens
        ],
      ),
      child: Column(
        children: [
          // Structure from Layout Specification
        ],
      ),
    );
  }
}

// Button widget
ElevatedButton(
  onPressed: _handlePress,
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF2E5C8A),  // Primary
    foregroundColor: Colors.white,
    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),  // base
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),  // md
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),  // sm
    ),
    elevation: 2,  // sm shadow approximation
  ),
  child: Text('Button Text'),
)
```

### Vue/Nuxt

**Component Structure:**
```vue
<!-- ComponentName.vue -->
<template>
  <div class="container">
    <!-- Structure from Layout Specification -->
    <button
      class="primary-button"
      @click="handleClick"
      :disabled="isDisabled"
    >
      Button Text
    </button>
  </div>
</template>

<script setup>
import { ref } from 'vue';

const isDisabled = ref(false);

const handleClick = () => {
  // Action
};
</script>

<style scoped>
/* Using exact token values */
.primary-button {
  background: #2E5C8A;  /* Primary */
  color: #FFFFFF;
  font-size: 16px;      /* base */
  padding: 16px;        /* md */
  border-radius: 4px;   /* sm */
  box-shadow: 0 2px 4px rgba(0,0,0,0.08);  /* sm */
}

.primary-button:hover {
  background: #254A6E;
}

.primary-button:active {
  background: #1C3952;
}

.primary-button:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}
</style>
```

### Other Frameworks

[Adapt pattern above for user's specific framework]

## Accessibility Checklist

[From Proposal and component specs]

- [ ] Color contrast meets WCAG AA (4.5:1 minimum)
- [ ] Keyboard navigation fully functional
- [ ] Focus indicators visible
- [ ] ARIA labels present where needed
- [ ] Touch targets minimum 44×44px (mobile)
- [ ] Screen reader tested

## Testing Checklist

- [ ] All interactive states working (hover, active, disabled)
- [ ] Responsive behavior verified on all breakpoints
- [ ] Accessibility requirements met
- [ ] Matches Design System tokens exactly
- [ ] No visual regressions on other screens

## Files to Create/Modify

**New Files:**
- [List component files to create]

**Modified Files:**
- [List existing files to update]

**Assets Needed:**
- [Icons, images, fonts if any]

## Component Registry Update

Add to Design System Section 7:

| Component | Created Date | Used In | Notes |
|-----------|--------------|---------|-------|
| [Component Name] | [Today's date] | [This feature] | [Special notes] |

[Include complete component spec summary for registry]
```

### Step 5: Quality Verification

**Before presenting, verify:**

✅ **Token Accuracy:**
- Every value matches Token Reference table
- No invented values
- No assumptions beyond Proposal

✅ **Completeness:**
- Every Change from Proposal has implementation spec
- All interactive states defined
- All accessibility requirements met
- Framework-specific code provided

✅ **Precision:**
- No vague descriptions ("make it look good" ❌)
- Exact px/rem values
- Exact hex colors
- Exact timing/easing

✅ **No Additions:**
- Did not add features not in Proposal
- Did not make design decisions
- Stayed within Proposal scope

### Step 6: Save Implementation Guide Document

**Save the Implementation Guide to the project directory:**

**Path:** `projects/{screen-name}/{YYYYMMDD}-implementation-v1.md`

**Examples:**
- `projects/email-signup-screen/20251122-implementation-v1.md`
- `projects/password-reset-screen/20251123-implementation-v1.md`

**The screen directory should already exist from Phase 2A.**

### Step 7: Save Components & Update Registry

#### 7.1 Save Component Code to Library

For each new component created, save to component library:

```bash
# Component files go to project directory
# Example: lib/features/authentication/presentation/widgets/

# For backup/documentation, also copy to component-library:
cp [project-component-file] .claude/skills/ui-renewal/component-library/[framework]/
```

#### 7.2 Update Component Registry (Automated)

**Use the automation script:**

```bash
python .claude/skills/ui-renewal/scripts/update_component_registry.py \
  --component "[ComponentName]" \
  --framework "[framework]" \
  --used-in "[screen-name]" \
  --category "[category]" \
  --description "[description]" \
  --file "[relative-path-to-file]"
```

**Example:**
```bash
# Update registry for GabiumButton component
python .claude/skills/ui-renewal/scripts/update_component_registry.py \
  --component "GabiumButton" \
  --framework "flutter" \
  --used-in "email-signup-screen" \
  --category "Form" \
  --description "Branded primary button with states" \
  --file "flutter/GabiumButton.dart"
```

**This automatically updates:**
1. Design System Component Registry (Section 7)
2. `component-library/registry.json`
3. `component-library/COMPONENTS.md`

**For multiple components, run script for each one.**

#### 7.3 Korean Message to User

```
✅ 컴포넌트가 라이브러리에 저장되었습니다!

저장된 컴포넌트:
- [ComponentName1] ([framework])
  위치: ./component-library/[framework]/[ComponentName1].[ext]
  
- [ComponentName2] ([framework])
  위치: ./component-library/[framework]/[ComponentName2].[ext]

📚 전체 컴포넌트 목록: ./component-library/COMPONENTS.md

다음 Phase 2A 작업 시 이 컴포넌트들을 재사용할 수 있습니다.
```

### Step 8: Present to User

**Concise summary (Korean):**

```markdown
# 구현 가이드 완성

## 산출물
- ✅ 전체 컴포넌트 명세
- ✅ 레이아웃 구조 상세
- ✅ 인터랙션 동작 정의
- ✅ [Framework] 구현 코드
- ✅ 접근성 체크리스트
- ✅ Component Registry 업데이트 완료

## 주요 명세
- [X]개 컴포넌트 완전 명세
- 모든 값은 Design System 토큰 사용
- [Framework] 코드 제공

## 문서 저장 위치
- 구현 가이드: `projects/{screen-name}/{YYYYMMDD}-implementation-v1.md`

## 다음 단계
1. 구현 가이드 검토
2. 개발 시작
3. 완료 후 Phase 3 검증 요청

전체 구현 가이드는 artifact를 확인하세요.
```

## Critical Guidelines

### Phase 2B DOES:
✅ Convert Proposal to exact implementation specs
✅ Provide framework-specific code
✅ Define every interactive state
✅ Update Component Registry
✅ Create developer-ready guide

### Phase 2B DOES NOT:
❌ Make new design decisions
❌ Add features not in Proposal
❌ Guess at missing values
❌ Load unnecessary context
❌ Re-analyze original UI

**If something is missing from Proposal:**
```
⚠️ Proposal does not specify [X]. 
Cannot proceed without this information.
Please update Proposal or approve default: [suggestion]
```

## Context Efficiency Rules

**To keep context minimal:**

1. **Load ONLY:**
   - Improvement Proposal (complete)
   - Token values listed in Proposal's Reference table
   - Platform/framework from Proposal

2. **Do NOT load:**
   - Full Design System document
   - Original UI analysis
   - Unrelated Design System sections
   - Previous Phase 2A work notes

3. **If token value not in Reference table:**
   - Flag it as missing
   - Request addition to Proposal OR
   - Suggest alternative from available tokens

## Quality Checklist

✅ **Accuracy:**
- Every value from Token Reference table
- No invented values
- Matches Proposal exactly

✅ **Completeness:**
- Every Change has full spec
- All states defined
- Framework code provided
- Accessibility met

✅ **Usability:**
- Developer can implement without questions
- Code examples are complete and correct
- Clear file structure

✅ **Registry:**
- Component Registry updated
- New components documented
- Reused components noted

## Success Criteria

Phase 2B succeeds when:
- ✅ Complete Implementation Guide created
- ✅ All specifications precise and developer-ready
- ✅ Only used tokens from Proposal
- ✅ Component Registry updated
- ✅ Framework-specific code provided
- ✅ User confirms guide is complete
- ✅ Minimal context consumed

## Output Language Rule

**CRITICAL: All user-facing output MUST be in Korean.**

### Korean Output (사용자 대면):
- ✅ Implementation guide summary
- ✅ Key specifications overview
- ✅ Questions to user
- ✅ Missing information warnings
- ✅ Next steps

### English OK (Internal):
- ✅ Implementation Guide artifact content (technical specs)
- ✅ Code examples (React/Flutter/Vue)
- ✅ Token names and technical terms
- ✅ CSS/styling code
- ✅ Framework-specific terminology

### Example:

**Good (Korean summary):**
```
# 구현 가이드 완성

## 산출물
- ✅ 전체 컴포넌트 명세
- ✅ 레이아웃 구조 상세
- ✅ 인터랙션 동작 정의
- ✅ React 구현 코드
- ✅ 접근성 체크리스트
- ✅ Component Registry 업데이트

## 다음 단계
1. 구현 가이드 검토
2. 개발 시작 가능
3. 완료 후 Phase 3 검증 요청
```

**Implementation Guide artifact itself can be in English** (technical document)

**Bad (User-facing in English):**
```
# Implementation Guide Complete

## Deliverables
- ✅ Complete component specifications...
```
