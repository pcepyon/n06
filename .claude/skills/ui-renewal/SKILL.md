---
name: ui-renewal
description: Framework-agnostic UI renewal skill that maintains brand consistency while improving visual quality and UX. Use when users request UI/design improvements, redesign, or design system creation for any platform (web, mobile, desktop). Orchestrates a four-phase workflow - Phase 1 creates Design System, Phase 2A analyzes and proposes improvements, Phase 2B creates implementation specifications, Phase 3 verifies implementation quality. Handles both new design system creation and iterative improvements. All user-facing communication in Korean, internal processing in English.
---

# UI Renewal Skill

Orchestrate professional UI renewal through systematic design system creation and incremental improvements.

## When to Use This Skill

Trigger this skill when users request:
- "Redesign my [app/website/interface]"
- "Improve the UI of [screen/feature]"
- "Create a design system for my product"
- "Make this look better/more professional/more modern"
- "Fix the UX of [feature]"
- Any request to improve visual design or user experience

## Workflow Overview

This skill operates in four phases, executed in a single continuous session:

```
Phase 1: Design System Creation
   ↓
[User approves]
   ↓
Phase 2A: Analysis & Direction (for each screen/feature)
   ↓
[User approves direction]
   ↓
Phase 2B: Implementation Specification
   ↓
[User receives implementation guide]
   ↓
[User implements]
   ↓
Phase 3: Verification & Quality Check
   ↓
[Pass: Complete] [Fail: Fix and re-verify]
   ↓
[Repeat 2A→2B→3 for next screen/feature]
```

## Phase Determination

**At conversation start, determine which phase to begin:**

### Start with Phase 1 if:
- User has no existing design system
- User explicitly requests "create a design system"
- User wants complete redesign/rebrand
- No consistent design language exists

**Ask:**
```
To create the best improvements, I'll first establish a Design System 
that ensures consistency across your product.

I'll need:
1. Brand information (logo, colors, any existing guidelines)
2. Product goals (target audience, industry, positioning)
3. Current UI samples (screenshots or examples)

Do you have these ready?
```

### Start with Phase 2A if:
- User has existing design system (from Phase 1 or elsewhere)
- User requests specific screen/feature improvement
- Design foundation already exists

**Ask:**
```
I can help improve [screen/feature]. 

Do you have a Design System document I should reference? 
If not, I can create one first to ensure consistency.
```

## Phase 1: Design System Creation

**Objective:** Create comprehensive design foundation for entire product.

### Execution

1. **Invoke Phase 1 Sub-Agent:**
   ```
   [Internal]: Read references/phase1-design-system.md for detailed instructions.
   
   [To user]: I'll analyze your brand and create a comprehensive Design System.
   ```

2. **Delegate to Sub-Agent:**
   The Phase 1 sub-agent will:
   - Analyze brand/product context
   - Generate complete Design System using template
   - Create artifact: "[Product Name] Design System v1.0"
   - Present proposal with key decisions explained
   - Handle feedback and iterate
   - Optionally export design tokens

3. **Completion Criteria:**
   - Design System artifact created and approved
   - All sections filled with specific values (no placeholders)
   - Component Registry initialized
   - **Design System saved to file: `./design-systems/[product]-design-system.md`**
   - **Design tokens exported (optional): `./design-systems/design-tokens.*`**
   - Ready for Phase 2A reference

**Orchestrator's Role:**
- Route to Phase 1 guide
- Ensure sub-agent reads `references/phase1-design-system.md`
- Confirm Design System artifact exists before allowing Phase 2
- Maintain Design System artifact in context for Phase 2

## Phase 2A: Analysis & Direction

**Objective:** Analyze current UI and create Improvement Proposal artifact.

### Execution

1. **Verify Design System Availability:**
   ```
   [Check]: Is Design System artifact in context?
   
   If NO → Request it or return to Phase 1
   If YES → Proceed
   ```

2. **Collect Target Information:**
   ```
   [To user]: Which screen or feature should I improve?
   Please provide: screenshots, code, or description of current state.
   Any specific issues or goals?
   ```

3. **Invoke Phase 2A Sub-Agent:**
   ```
   [Internal]: Read references/phase2a-analysis.md for detailed instructions.
   
   [To user]: I'll analyze the current design and determine improvement direction.
   ```

4. **Delegate to Sub-Agent:**
   The Phase 2A sub-agent will:
   - Load Design System from context
   - Analyze dependencies (what must be done first, what else is affected)
   - Check Component Registry for reusable elements
   - Analyze current UI (brand, visual, UX)
   - Determine improvement direction (WHAT to change, not HOW)
   - Map every change to Design System tokens
   - Create **Improvement Proposal artifact** (structured, complete)
   - Present proposal to user

5. **Completion Criteria:**
   - Improvement Proposal artifact created
   - All changes mapped to Design System tokens
   - Dependencies documented
   - User approves the direction

**Orchestrator's Role:**
- Route to Phase 2A guide
- Ensure sub-agent reads `references/phase2a-analysis.md`
- Ensure Design System artifact stays in context
- Verify Improvement Proposal artifact is created
- On approval, proceed to Phase 2B

## Phase 2B: Implementation Specification

**Objective:** Convert approved Proposal into precise implementation guide.

### Execution

1. **Verify Prerequisites:**
   ```
   [Check]: Is Improvement Proposal artifact in context?
   [Check]: Has user approved the proposal?
   
   If NO → Return to Phase 2A
   If YES → Proceed
   ```

2. **Invoke Phase 2B Sub-Agent:**
   ```
   [Internal]: Read references/phase2b-implementation.md for detailed instructions.
   
   [To user]: I'll create detailed implementation specifications based on the approved proposal.
   ```

3. **Provide MINIMAL Context to Sub-Agent:**
   ```
   CRITICAL: Only provide:
   1. Improvement Proposal artifact (complete)
   2. Design System tokens listed in Proposal's "Design System Token Reference" table
   3. Platform/framework info from Proposal
   
   DO NOT provide:
   - Full Design System document
   - Original UI screenshots/code
   - Phase 2A analysis notes
   ```

4. **Delegate to Sub-Agent:**
   The Phase 2B sub-agent will:
   - Load Improvement Proposal as Single Source of Truth
   - Extract token values from Proposal's Token Reference table
   - Create complete component specifications
   - Define layout structure precisely
   - Specify all interactive states
   - Provide framework-specific implementation code
   - **Save component code to library: `./component-library/[framework]/[Component].[ext]`**
   - Update Component Registry in Design System artifact
   - Create Implementation Guide artifact

5. **After Completion:**
   ```
   [To user]: 
   Implementation guide complete!
   
   Would you like to:
   - Improve another screen/feature? (→ Return to Phase 2A)
   - Export design tokens for development?
   - Get additional implementation support?
   ```

**Orchestrator's Role:**
- Route to Phase 2B guide
- Ensure sub-agent reads `references/phase2b-implementation.md`
- **Provide ONLY Improvement Proposal + Token Reference** to sub-agent
- Ensure Component Registry is updated in Design System artifact
- After implementation guide is complete, inform user about Phase 3

## Phase 3: Verification & Quality Check

**Objective:** Verify implemented code matches design intent and specifications, check for lint/build errors.

### Execution

1. **User Implements:**
   ```
   [To user]: 
   구현 가이드를 받으셨습니다.
   
   구현 완료 후:
   - 구현한 코드 또는 스크린샷을 공유해주세요
   - Phase 3 검증을 요청해주세요
   ```

2. **User Requests Verification:**
   ```
   [Check]: Does user have implemented code ready?
   
   If NO → Wait for user to implement
   If YES → Proceed to Phase 3
   ```

3. **Invoke Phase 3 Sub-Agent:**
   ```
   [Internal]: Read references/phase3-verification.md for detailed instructions.
   
   [To user]: 구현하신 코드를 검증하겠습니다.
   ```

4. **Provide Minimal Context to Sub-Agent:**
   ```
   CRITICAL: Only provide:
   1. Improvement Proposal artifact (design intent)
   2. Implementation Guide artifact (specifications)
   3. User's implemented code
   4. Design System tokens referenced in Implementation Guide (not full Design System)
   
   DO NOT provide:
   - Full Design System document
   - Original UI from Phase 2A
   - Analysis notes
   ```

5. **Delegate to Sub-Agent:**
   The Phase 3 sub-agent will:
   - Load Proposal (design intent) and Implementation Guide (spec)
   - Verify design intent is met
   - Check specification compliance
   - Run lint/build quality checks
   - Verify accessibility requirements
   - Categorize issues by severity (Critical/Major/Minor)
   - Create Verification Report (in Korean)
   - Provide specific fix guidance

6. **Handle Verification Results:**

   **If PASS (✅):**
   ```
   [To user]:
   ✅ 검증 완료! 문제가 없습니다.
   
   다음 단계:
   - 다른 화면/기능 개선? (→ Phase 2A로)
   - 디자인 토큰 내보내기?
   - 구현 완료?
   ```

   **If FAIL (❌ or ⚠️):**
   ```
   [To user]:
   검증 완료. 수정이 필요한 부분이 있습니다.
   
   [검증 보고서 제공 - 한글]
   
   다음 단계:
   1. 보고서의 수정 사항 적용
   2. 재검증 요청 (Phase 3 다시)
   3. 또는 특정 부분만 재검증 요청
   ```

7. **Re-verification (if needed):**
   - User fixes issues
   - Requests re-verification
   - Phase 3 runs again (focused on fixed items)
   - Pass → Complete, Fail → Iterate

**Orchestrator's Role:**
- Route to Phase 3 guide
- Ensure sub-agent reads `references/phase3-verification.md`
- Provide ONLY: Proposal + Implementation Guide + User's code
- Ensure Verification Report is in Korean
- Handle pass/fail routing
- Support re-verification loops

## Context Management

**Critical for avoiding context overflow:**

### For Phase 1 Sub-Agent:
```
You are the Design System Creation agent.

Your instructions: Read /home/claude/ui-renewal/references/phase1-design-system.md

Follow those instructions completely.

OUTPUT LANGUAGE: All user-facing content in Korean.
```

### For Phase 2A Sub-Agent:
```
You are the Analysis agent.

Your instructions: Read /home/claude/ui-renewal/references/phase2a-analysis.md

Design System to reference: [Include Design System artifact]

Follow those instructions completely.

OUTPUT LANGUAGE: All user-facing content in Korean.
```

### For Phase 2B Sub-Agent:
```
You are the Implementation Specification agent.

Your instructions: Read /home/claude/ui-renewal/references/phase2b-implementation.md

CRITICAL - Load ONLY these contexts:
1. Improvement Proposal artifact (complete)
2. Design System tokens from Proposal's "Design System Token Reference" table ONLY

DO NOT LOAD:
- Full Design System document
- Original UI screenshots/code  
- Phase 2A analysis notes

Follow those instructions completely.

OUTPUT LANGUAGE: All user-facing content in Korean.
```

### For Phase 3 Sub-Agent:
```
You are the Verification agent.

Your instructions: Read /home/claude/ui-renewal/references/phase3-verification.md

CRITICAL - Load ONLY these contexts:
1. Improvement Proposal artifact (design intent)
2. Implementation Guide artifact (specifications)
3. User's implemented code
4. Design System tokens from Implementation Guide ONLY

DO NOT LOAD:
- Full Design System document
- Original UI from Phase 2A
- Analysis notes

Follow those instructions completely.

OUTPUT LANGUAGE: ALL verification reports and user communication in Korean.
```

**Do NOT load entire skill into sub-agent context.**
Only load the specific reference guide needed for each phase.

## Continuous Session Management

**Maintain state across phases:**

1. **Design System Artifact & File:**
   - Created in Phase 1 as artifact
   - **Saved to file: `./design-systems/[product]-design-system.md`**
   - Referenced in Phase 2A for analysis
   - Specific tokens referenced in Phase 2B (via Proposal)
   - Updated when new components are added (in Phase 2B)
   - Never recreate, only update

2. **Improvement Proposal Artifact:**
   - Created in Phase 2A
   - Used as Single Source of Truth in Phase 2B
   - Contains all context Phase 2B needs

3. **Component Registry:**
   - Initialized in Phase 1 (empty)
   - Checked in Phase 2A for reuse
   - Updated in Phase 2B when components are implemented
   - Lives in section 7 of Design System artifact

4. **Component Library Files:**
   - **Location: `./component-library/[framework]/[Component].[ext]`**
   - Created in Phase 2B when new components are implemented
   - Searched in Phase 2A for reusability
   - Managed by `scripts/manage_components.py`
   - **Documentation: `./component-library/COMPONENTS.md`**
   - **Registry: `./component-library/registry.json`**

5. **Session Flow:**
   ```
   Phase 1 → [Approval + Save Design System File] → 
   Phase 2A (Screen A) → [Check Component Library] → [Approval] → 
   Phase 2B (Screen A) → [Save Components to Library] → [Implementation] →
   Phase 3 (Screen A) → [Pass: Complete / Fail: Fix & Re-verify] →
   Phase 2A (Screen B) → [Reuse Components from Library] → [Approval] → 
   Phase 2B (Screen B) → ...
   ```

**Never:**
- Start over or lose Design System
- Create duplicate Design Systems
- Skip Phase 2A and go directly to Phase 2B
- Load full Design System in Phase 2B or Phase 3 (use Proposal/Guide references)
- Skip Phase 3 verification (quality assurance)
- **Forget to save components to library (loses reusability)**

## Design Token Export (Optional)

After Phase 1 approval or any time during Phase 2:

```
[To user]: Would you like to export design tokens for development?

Available formats:
- JSON (universal)
- CSS Variables
- Tailwind Config
- Flutter Theme
```

If user agrees:
```bash
python /home/claude/ui-renewal/scripts/export_design_tokens.py \
  [path-to-design-system.md] --format [json|css|tailwind|flutter]
```

Output will be `design-tokens.[ext]` in the same directory.

## Quality Gates

### Phase 1 Quality Gate:
- ✅ Design System artifact created (not just text)
- ✅ All sections have specific values (no #000000 placeholders)
- ✅ Component Registry section exists
- ✅ User has approved
- ✅ Artifact can be referenced in Phase 2A
- ✅ All user-facing communication in Korean

**Do not proceed to Phase 2A until these are met.**

### Phase 2A Quality Gate (per screen):
- ✅ Design System artifact loaded
- ✅ Dependencies analyzed and documented
- ✅ Component Registry checked for reuse
- ✅ Current UI analyzed (brand, visual, UX)
- ✅ Improvement direction determined
- ✅ All changes mapped to Design System tokens
- ✅ Improvement Proposal artifact created
- ✅ User has approved the direction
- ✅ All user-facing communication in Korean

**Do not proceed to Phase 2B until these are met.**

### Phase 2B Quality Gate (per screen):
- ✅ Improvement Proposal artifact loaded
- ✅ ONLY tokens from Proposal's Token Reference used
- ✅ Complete specifications provided (components, layout, interactions)
- ✅ Framework-specific code examples included
- ✅ Accessibility requirements met
- ✅ Component Registry updated in Design System
- ✅ Implementation Guide artifact created
- ✅ User confirms guide is complete
- ✅ All user-facing communication in Korean

**Do not proceed to Phase 3 until implementation is complete.**

### Phase 3 Quality Gate (per screen):
- ✅ User has implemented code ready
- ✅ Improvement Proposal and Implementation Guide loaded
- ✅ Design intent verification completed
- ✅ Specification compliance checked
- ✅ Code quality verified (lint/build)
- ✅ Accessibility requirements checked
- ✅ Issues categorized by severity
- ✅ Verification Report created (in Korean)
- ✅ Specific fix guidance provided (in Korean)
- ✅ Pass/Fail determination clear

**If PASS:** Mark screen complete, proceed to next.  
**If FAIL:** User fixes issues, re-run Phase 3.

## Handling Edge Cases

### User wants to skip Phase 1:
```
I understand you want to jump straight to improvements. However, without 
a Design System, we risk inconsistency and multiple rounds of revisions.

Would you like me to create a lightweight Design System first? 
It will take ~10 minutes but ensure all improvements work together.
```

### User provides external design system:
```
Great! Please share your design system document. 

I'll convert it to our artifact format so I can reference it 
consistently during improvements.
```

### Phase 2A reveals Design System gaps:
```
This improvement requires [element] not in the Design System.

Two options:
1. Add [element] to Design System first (recommended)
2. Use a workaround with existing elements

Which would you prefer?
```

### User wants to change approved Design System:
```
I can update the Design System. Note that this may affect 
previously improved screens:

Impacted: [List screens that used the changing element]

Should I proceed with the update?
```

### User wants to skip Phase 2A and go straight to implementation:
```
Phase 2A is essential for determining WHAT to change before HOW.
It creates the Improvement Proposal that Phase 2B uses as its guide.

This separation ensures:
- Clear direction before implementation
- Efficient context usage
- Ability to adjust direction before detailed work

This only takes a few minutes and prevents rework. Shall we proceed with Phase 2A?
```

### Phase 2B finds missing information in Proposal:
```
The Improvement Proposal doesn't specify [X], which is needed for implementation.

Options:
1. Return to Phase 2A to add this to the Proposal
2. I can suggest a default: [suggestion]

Which would you prefer?
```

### User requests changes after Phase 2B starts:
```
디자인 방향을 변경하려면 Phase 2A의 Improvement Proposal을 업데이트해야 합니다.
이렇게 해야 모든 명세가 일관성을 유지합니다.

Phase 2A로 돌아가서 제안서를 수정할까요?
```

### User skips Phase 3:
```
Phase 3 검증은 선택이 아닌 필수 단계입니다.

검증을 통해:
- 기획 의도대로 구현되었는지 확인
- 명세 준수 여부 확인
- 코드 품질 및 접근성 검증
- 린트/빌드 오류 사전 발견

구현 완료 후 Phase 3 검증을 요청해주세요.
```

### Phase 3 reveals major issues:
```
검증 결과 수정이 필요한 부분이 발견되었습니다.

[검증 보고서 제공 - 한글]

옵션:
1. 보고서의 수정 사항 적용 후 재검증 (권장)
2. Phase 2A로 돌아가서 개선 방향 재검토
3. Phase 2B로 돌아가서 구현 가이드 수정

어떻게 진행하시겠어요?
```

### User wants partial verification:
```
특정 부분만 검증하시겠어요?

전체 검증 권장 이유:
- 한 부분의 변경이 다른 부분에 영향
- 전체적인 일관성 확인
- 숨겨진 이슈 발견

그래도 부분 검증을 원하시면 구체적으로 어느 부분인지 알려주세요.
```

### Code only partially matches framework:
```
구현 코드가 Implementation Guide의 프레임워크([Framework A])와 
다른 프레임워크([Framework B])로 작성되었습니다.

현재 코드 기준으로 검증하되,
필요하시면 [Framework B]용 가이드를 새로 제공할 수 있습니다.
```

## Success Criteria

**Phase 1 Success:**
- Complete, usable Design System artifact exists
- User is satisfied with design direction
- Foundation is ready for Phase 2A
- All communication in Korean

**Phase 2A Success:**
- Improvement Proposal artifact created
- User approves the direction
- All changes mapped to Design System tokens
- Dependencies clear
- Ready for Phase 2B
- All communication in Korean

**Phase 2B Success:**
- Implementation Guide artifact created
- Specifications are precise and developer-ready
- Only used tokens from Proposal (minimal context)
- Component Registry updated
- User confirms guide is complete
- All communication in Korean

**Phase 3 Success:**
- Verification Report created (in Korean)
- Design intent verified
- Specification compliance checked
- Code quality verified
- Clear pass/fail determination
- Actionable fix guidance provided (in Korean)

**Overall Success:**
- User has consistent, improved UI across product
- Reusable design system enables future work
- Clear implementation path for developers
- Efficient context usage throughout process
- Quality assurance through verification
- **All user communication in Korean**

## Language Rules

**CRITICAL: All user-facing communication MUST be in Korean.**

### Korean Output (Required):

**All Phases:**
- ✅ Questions to user
- ✅ Explanations and rationales
- ✅ Summaries and proposals
- ✅ Warnings and error messages
- ✅ Next steps and guidance
- ✅ Feedback responses

**Phase 1:**
- ✅ Design System proposal summary
- ✅ Key design decisions explanation

**Phase 2A:**
- ✅ Improvement summary
- ✅ Dependency warnings
- ✅ Impact analysis

**Phase 2B:**
- ✅ Implementation guide summary
- ✅ Deliverables overview

**Phase 3:**
- ✅ **Verification Report (entire document)**
- ✅ Issue descriptions
- ✅ Fix guidance
- ✅ Evaluation comments

### English OK (Internal):

- ✅ Artifact content (Design System, Proposal, Implementation Guide)
- ✅ Code examples (React/Flutter/Vue/etc.)
- ✅ Token names and technical terms
- ✅ CSS/styling code
- ✅ Framework-specific terminology
- ✅ Internal processing notes

### Example Transformations:

**Bad (English to user):**
```
I've analyzed your login screen and found 3 issues.
The CTA button is too small and doesn't match the primary color.
```

**Good (Korean to user):**
```
로그인 화면을 분석했습니다. 3가지 문제점을 발견했습니다.
CTA 버튼이 너무 작고 Primary 컬러와 일치하지 않습니다.
```

**Code examples remain in English:**
```jsx
// This is fine - code can be in English
<button className="primary-button">
  로그인
</button>
```

### Enforcement:

Every sub-agent MUST follow these language rules.
Orchestrator verifies language compliance before passing output to user.
