# Phase 2A: Analysis & Direction Guide

This guide is for the Analysis sub-agent. Use this when the orchestrator routes a Phase 2A task.

## Objective

Analyze current UI and determine improvement direction WITHOUT implementing details. Output a clear, structured **Improvement Proposal artifact** that Phase 2B will use as Single Source of Truth.

## Table of Contents

1. [Objective](#objective)
2. [Prerequisites](#prerequisites)
3. [Process](#process)
   - [Step 1: Load Design System](#step-1-load-design-system)
   - [Step 2: Dependency Analysis](#step-2-dependency-analysis)
   - [Step 3: Component Registry & Library Check](#step-3-component-registry--library-check)
   - [Step 4: Current UI Analysis](#step-4-current-ui-analysis)
   - [Step 5: Determine Improvement Direction](#step-5-determine-improvement-direction)
   - [Step 6: Create Improvement Proposal Artifact](#step-6-create-improvement-proposal-artifact)
   - [Step 7: Save Proposal Document](#step-7-save-proposal-document)
   - [Step 8: Create metadata.json](#step-8-create-metadatajson)
   - [Step 9: Present Proposal to User](#step-9-present-proposal-to-user)
   - [Step 10: Handle Feedback](#step-10-handle-feedback)
4. [Critical Guidelines](#critical-guidelines)
5. [Quality Checklist](#quality-checklist)
6. [Success Criteria](#success-criteria)
7. [Output Language Rule](#output-language-rule)

---

## Prerequisites

**Required:**
- Phase 1 Design System completed and approved
- Design System artifact available in context

**Input from user:**
- Target screen/feature to improve
- Current UI (screenshots, code, or description)
- Any specific requirements or pain points

## Process

### Step 1: Load Design System

Always start by loading the Design System artifact from Phase 1.

### Step 2: Dependency Analysis

#### Prerequisite Check
What needs to exist first?

**Output:**
```
⚠️ Dependencies: [Component] must be designed first
OR
✅ No blocking dependencies
```

#### Impact Analysis
What else will need updating?

**Output:**
```
📊 Impact Scope:
- [Screen 1]: [What needs updating]
- [Screen 2]: [What needs updating]
```

### Step 3: Component Registry & Library Check

**Check both Component Registry AND component library files:**

#### Registry Check
Check Design System Section 7 - Component Registry for documented components.

#### Library Search
```bash
# List all available components
python scripts/manage_components.py list [framework]

# Get specific component
python scripts/manage_components.py get [ComponentName] [framework]
```

**If reusable component found:**
```
✅ 재사용 가능한 컴포넌트 발견!

컴포넌트: [ComponentName]
프레임워크: [framework]
위치: ./component-library/[framework]/[ComponentName].[ext]

재사용 옵션:
- 그대로 사용
- 변형 버전 생성
- 새로 제작
```

**In Improvement Proposal, note:**
- Existing component to reuse (if any)
- Adaptations needed
- Or mark as new component

### Step 4: Current UI Analysis

Analyze systematically:

**Brand Consistency:**
- ✅/❌ Uses Design System colors?
- ✅/❌ Uses Design System typography?
- ✅/❌ Follows spacing scale?
- ✅/❌ Matches visual style?

**Visual Quality:**
- Hierarchy clear?
- Whitespace appropriate?
- Alignment consistent?
- Color harmony?

**UX Excellence:**
- Purpose immediately clear?
- Interaction feedback clear?
- Flow logical?
- Accessibility met?

### Step 5: Determine Improvement Direction

For each change, map to Design System tokens:

**Example:**
```
Change: Make CTA button more prominent
→ Component: Button - Primary, Large
→ Color: Primary (#2E5C8A)
→ Typography: base (16px)
→ Spacing: md (16px) padding
→ Shadow: sm
```

**If token missing:**
```
⚠️ Missing: [description]
Recommendation: Add to Design System OR use [alternative]
```

### Step 6: Create Improvement Proposal Artifact

**CRITICAL: This is the ONLY output Phase 2B will receive.**

**Document Storage:**
Save to: `projects/{screen-name}/{YYYYMMDD}-proposal-v1.md`

**Naming Convention:**
- Format: `{YYYYMMDD}-{document-type}-v{version}.md`
- Example: `20251122-proposal-v1.md`
- Version increments if revisions needed

**Directory Structure:**
All documents for a screen/feature go in `projects/{screen-name}/`:
- `{YYYYMMDD}-proposal-v1.md` (Phase 2A)
- `{YYYYMMDD}-implementation-v1.md` (Phase 2B)
- `metadata.json` (auto-generated in Phase 3)

**Use exact structure below:**

```markdown
# [Feature/Screen Name] Improvement Proposal

## Overview
[1-2 sentence summary]

## Current State Issues

### Brand Consistency Issues
- [Issue]: [Specific problem]

### Visual Quality Issues
- [Issue]: [Specific problem]

### UX Issues
- [Issue]: [Specific problem]

## Improvement Direction

### Change 1: [What will change]
- **Current:** [Brief description]
- **Proposed:** [What it will become]
- **Rationale:** [Why this improves UX/brand]
- **Design System Mapping:**
  - Component: [Section 6 - Buttons - Primary, Large]
  - Color: [Primary (#2E5C8A)]
  - Typography: [base (16px, Regular)]
  - Spacing: [md padding (16px)]
  - Border Radius: [sm (4px)]
  - Shadow: [sm]
  - Interactive States: [Hover: Primary +10%, Active: Primary +20%, Disabled: 0.4 opacity]

### Change 2: [What will change]
[Same structure]

## Design System Token Reference

Complete list of all tokens to be used:

| Element | Token Path | Value | Usage |
|---------|-----------|-------|-------|
| Button BG | Colors - Primary | #2E5C8A | CTA background |
| Button Text | Typography - base | 16px, Regular | CTA label |
| Button Padding | Spacing - md | 16px | Horizontal padding |
| Card BG | Colors - Neutral - 50 | #FAFAFA | Container |
| Heading | Typography - xl | 24px, Bold | Section title |
| Section Spacing | Spacing - lg | 24px | Between sections |
| Border Radius | Border Radius - sm | 4px | Buttons, inputs |
| Shadow | Shadow - sm | 0 2px 4px rgba(0,0,0,0.08) | Cards |

## Preserved Elements

What should NOT change:
- [Element]: [Why it works well]

## Dependencies

### Prerequisites (must do first):
- [Component/Pattern]: [Why needed]
- OR: ✅ None

### Impact (will need updating after):
- [Screen/Feature]: [What needs to change]
- OR: ✅ Isolated change

## Component Reuse

### Existing Components to Reuse:
- [Component Name] (Registry): [How used]
- OR: ✅ None

### New Components to Create:
- [Component Name]: [Description]
- Will be added to Registry in Phase 2B

## Success Criteria

1. [Measurable outcome]
2. [Measurable outcome]
3. [Measurable outcome]

## Technical Context

### Platform/Framework:
[React/Flutter/Vue/etc.]

### Special Constraints:
- [Constraint]
- OR: ✅ None

## Layout Structure (High-Level)

[ASCII or brief description of visual layout]

Example:
```
+----------------------------------+
| Header (Primary color)           |
+----------------------------------+
| Hero Section                     |
|  Title (xl, Bold)                |
|  Subtitle (base, Regular)        |
|  CTA Button (Primary, Large)     |
+----------------------------------+
| Content Cards (3 columns)        |
+----------------------------------+
```

## Approval Required

- [ ] User approves improvement direction
- [ ] All Design System tokens available
- [ ] Dependencies acknowledged
```

**Quality Requirements:**
- ✅ Every change maps to specific Design System token
- ✅ Every token includes exact value
- ✅ Success criteria measurable
- ✅ Dependencies clear
- ✅ No vague descriptions

### Step 7: Save Proposal Document

**Save the Improvement Proposal to the project directory:**

**CRITICAL - Use exact path below:**

`.claude/skills/ui-renewal/projects/{screen-name}/{YYYYMMDD}-proposal-v1.md`

**Examples:**
- ✅ `.claude/skills/ui-renewal/projects/email-signup-screen/20251122-proposal-v1.md`
- ✅ `.claude/skills/ui-renewal/projects/password-reset-screen/20251123-proposal-v1.md`
- ❌ `projects/email-signup-screen/...` (WRONG - saves to root/projects/)

**Before saving:**
```bash
mkdir -p .claude/skills/ui-renewal/projects/{screen-name}
```

**After saving, verify:**
```bash
ls .claude/skills/ui-renewal/projects/{screen-name}/{YYYYMMDD}-proposal-v1.md
```

If file not found, search for it:
```bash
find . -name "{YYYYMMDD}-proposal-v1.md" -type f
```

### Step 8: Create metadata.json

**Create initial project metadata:**

`.claude/skills/ui-renewal/projects/{screen-name}/metadata.json`

```json
{
  "project_name": "{screen-name}",
  "status": "in_progress",
  "current_phase": "phase2a",
  "created_date": "{today}",
  "last_updated": "{now}",
  "framework": "{framework}",
  "design_system_version": "v1.0",
  "versions": {
    "proposal": "v1"
  },
  "dependencies": [],
  "components_created": [],
  "retry_count": 0,
  "last_error": null
}
```

### Step 9: Present Proposal to User

Provide concise summary:

```markdown
# [Screen] Improvement Summary

## Key Changes
1. [Change]: [Benefit]
2. [Change]: [Benefit]
3. [Change]: [Benefit]

## Design System Alignment
- All changes use Design System tokens
- Consistent with existing patterns
- [X] existing components reused

## Dependencies
- Prerequisites: [List or "None"]
- Impact: [List or "Isolated"]

## 문서 저장 위치
- 제안서: `.claude/skills/ui-renewal/projects/{screen-name}/{YYYYMMDD}-proposal-v1.md`

## Next Step
Review full Improvement Proposal (artifact) and approve to proceed to implementation phase.
```

### Step 10: Handle Feedback

**If approved:** Notify orchestrator to proceed to Phase 2B

**If changes requested:**
- Update artifact
- Save as new version (increment version number)
- Example: `20251122-proposal-v2.md`
- Update metadata.json with new proposal version
- Re-present

**If rejected:** Understand concerns, create alternative

## Critical Guidelines

### Phase 2A DOES:
✅ Analyze current UI
✅ Identify issues
✅ Determine WHAT to change
✅ Map to Design System tokens
✅ Create Improvement Proposal artifact
✅ Get user approval

### Phase 2A DOES NOT:
❌ Write implementation specs
❌ Provide code examples
❌ Define exact pixel positions
❌ Make HOW decisions
❌ Create component specifications

**Phase 2B handles all implementation details.**

## Quality Checklist

✅ **Completeness:**
- All changes identified
- Every change mapped to Design System
- Dependencies documented
- Success criteria defined

✅ **Clarity:**
- Specific token references (not "primary" but "Primary #2E5C8A")
- Clear rationale for each change

✅ **Design System Compliance:**
- Only uses existing tokens
- Flags missing tokens
- Reuses components

✅ **Actionability:**
- Phase 2B can implement without questions
- All context provided
- Technical constraints documented

## Success Criteria

Phase 2A succeeds when:
- ✅ Complete Improvement Proposal artifact created
- ✅ User approves direction
- ✅ All tokens mapped
- ✅ Dependencies clear
- ✅ Proposal specific enough for Phase 2B
- ✅ No missing information

## Output Language Rule

**CRITICAL: All user-facing output MUST be in Korean.**

### Korean Output (사용자 대면):
- ✅ Improvement summary for user
- ✅ Key changes explanation
- ✅ Questions to user
- ✅ Dependency warnings
- ✅ Impact analysis
- ✅ Next steps

### English OK (Internal):
- ✅ Improvement Proposal artifact content
- ✅ Token names and technical terms
- ✅ Design System references
- ✅ Internal processing

### Example:

**Good (Korean summary):**
```
# 로그인 화면 개선 요약

## 주요 변경사항
1. CTA 버튼 강조: 사용자 행동 유도 개선
2. 입력 필드 간격 조정: 시각적 그룹핑 명확화
3. 에러 메시지 위치 변경: 즉각적인 피드백

## 다음 단계
전체 개선 제안서(아티팩트)를 검토하시고 승인해주세요.
```

**Bad (English):**
```
# Login Screen Improvement Summary

## Key Changes
1. Emphasize CTA button: Improve user action...
```
