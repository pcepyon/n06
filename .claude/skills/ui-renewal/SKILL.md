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
Phase 3: Verification, Revision & Finalization
   ↓ Step 1: Verify → Step 2: Revise (if needed) → Step 3: Confirm → Step 4: Organize
   ↓
[Complete: Assets organized] [Revise: Fix and re-verify]
   ↓
[Repeat 2A→2B→3 for next screen/feature]
```

## Document Naming Convention

All documents created by this skill follow a strict naming convention:

### Format
```
{YYYYMMDD}-{document-type}-v{version}.md
```

### Document Types
- **proposal**: Improvement Proposal (Phase 2A output)
- **implementation**: Implementation Specification (Phase 2B output)
- **verification**: Verification Report (Phase 3 output)

### Examples
```
20251122-proposal-v1.md          (First proposal, created Nov 22, 2025)
20251122-proposal-v2.md          (Revised proposal, same day)
20251122-implementation-v1.md    (Implementation spec)
20251123-verification-v1.md      (First verification)
20251123-verification-v2.md      (Re-verification after fixes)
```

### Version Incrementing
- Same day, same document type → increment version (v1, v2, v3...)
- Different day → reset to v1 with new date
- Different document type → always start at v1

### Where Applied
- **Phase 2A**: Saves proposal as `{date}-proposal-v{n}.md` in `projects/{screen-name}/`
- **Phase 2B**: Saves implementation as `{date}-implementation-v{n}.md` in `projects/{screen-name}/`
- **Phase 3**: Saves verification as `{date}-verification-v{n}.md` in `projects/{screen-name}/`

## Directory Structure

### Root Structure
```
ui-renewal/
├── design-systems/              # Design System documents (Phase 1)
│   ├── [product]-design-system.md
│   └── design-tokens.*          # Exported tokens (optional)
│
├── projects/                    # Screen-specific work (Phase 2A/2B/3)
│   ├── INDEX.md                 # Master project index
│   │
│   ├── login-screen/            # Example project directory
│   │   ├── metadata.json        # Project metadata
│   │   ├── 20251122-proposal-v1.md
│   │   ├── 20251122-implementation-v1.md
│   │   ├── 20251123-verification-v1.md
│   │   └── screenshots/         # Optional visual references
│   │
│   ├── dashboard/
│   │   ├── metadata.json
│   │   ├── 20251123-proposal-v1.md
│   │   └── ...
│   │
│   └── profile-screen/
│       └── ...
│
├── component-library/           # Reusable components (Phase 2B)
│   ├── COMPONENTS.md            # Component documentation
│   ├── registry.json            # Component registry
│   │
│   ├── react/
│   │   ├── Button.tsx
│   │   ├── Input.tsx
│   │   └── ...
│   │
│   └── flutter/
│       ├── custom_button.dart
│       └── ...
│
├── references/                  # Phase-specific guides (read-only)
│   ├── phase1-design-system.md
│   ├── phase2a-analysis.md
│   ├── phase2b-implementation.md
│   └── phase3-verification.md
│
└── scripts/                     # Automation tools
    ├── export_design_tokens.py
    └── manage_components.py
```

### Project Directory Structure

Each screen/feature gets its own subdirectory in `projects/`:

```
projects/{screen-name}/
├── metadata.json                # Project metadata
├── {date}-proposal-v{n}.md      # Improvement proposals (Phase 2A)
├── {date}-implementation-v{n}.md # Implementation specs (Phase 2B)
├── {date}-verification-v{n}.md  # Verification reports (Phase 3)
└── screenshots/                 # Optional visual references
```

### metadata.json Format
```json
{
  "project_name": "login-screen",
  "status": "completed",
  "created_date": "2025-11-22",
  "last_updated": "2025-11-23",
  "phase": "completed",
  "framework": "React",
  "design_system_version": "v1.0",
  "versions": {
    "proposal": "v1",
    "implementation": "v1",
    "verification": "v2"
  },
  "dependencies": [],
  "components_created": [
    "PrimaryButton",
    "EmailInput"
  ]
}
```

### projects/INDEX.md Format
```markdown
# UI Renewal Projects Index

## Active Projects
- **login-screen** (Phase 3 - Verification) - Last updated: 2025-11-23
- **dashboard** (Phase 2B - Implementation) - Last updated: 2025-11-22

## Completed Projects
- **profile-screen** (Completed) - Finished: 2025-11-21

## Pending Projects
- **settings-screen** (Planned)
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
   - **Check Component Registry for reusable elements**
   - Analyze current UI (brand, visual, UX)
   - Determine improvement direction (WHAT to change, not HOW)
   - Map every change to Design System tokens
   - Create **Improvement Proposal artifact** (structured, complete)
   - **Save proposal to: `projects/{screen-name}/{date}-proposal-v{n}.md`**
   - **Create/update `projects/{screen-name}/metadata.json`**
   - Present proposal to user

5. **Completion Criteria:**
   - Improvement Proposal artifact created
   - All changes mapped to Design System tokens
   - Dependencies documented
   - **Proposal saved to projects directory with proper naming**
   - User approves the direction

**Orchestrator's Role:**
- Route to Phase 2A guide
- Ensure sub-agent reads `references/phase2a-analysis.md`
- Ensure Design System artifact stays in context
- **Ensure Component Registry is checked for reusable components**
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
   - **Update Component Registry (3 locations - see Component Registry Management)**
   - Create Implementation Guide artifact
   - **Save implementation to: `projects/{screen-name}/{date}-implementation-v{n}.md`**
   - **Update `projects/{screen-name}/metadata.json`**

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
- **Ensure implementation is saved to projects directory with proper naming**
- After implementation guide is complete, inform user about Phase 3

## Component Registry Management

The Component Registry must be maintained in **THREE locations**:

### 1. Design System Artifact (Section 7)
```markdown
## 7. Component Registry

### Button Components
- **PrimaryButton**: Main CTA actions (Login, Submit, etc.)
  - Variants: Default, Hover, Pressed, Disabled
  - Used in: Login, Registration, Checkout
  - File: `component-library/react/Button.tsx`
```

### 2. component-library/registry.json
```json
{
  "components": [
    {
      "name": "PrimaryButton",
      "category": "button",
      "framework": "react",
      "file_path": "component-library/react/Button.tsx",
      "used_in": ["login", "registration", "checkout"],
      "created_date": "2025-11-22",
      "design_tokens": ["color.primary", "spacing.md"]
    }
  ]
}
```

### 3. component-library/COMPONENTS.md
```markdown
# Component Library

## Button Components

### PrimaryButton
- **Purpose**: Main CTA actions
- **Framework**: React
- **File**: `react/Button.tsx`
- **Used in**: Login, Registration, Checkout
- **Tokens**: color.primary, spacing.md
```

### Update Responsibility

**Phase 2A (Check Registry):**
- Read all 3 locations to find reusable components
- Recommend reuse in Improvement Proposal

**Phase 2B (Update Registry):**
- When creating new components, update all 3 locations:
  1. Design System artifact (Section 7)
  2. `component-library/registry.json`
  3. `component-library/COMPONENTS.md`
- Can be done automatically via script or manually

**Phase 3 Step 4 (Final Update):**
- Verify all 3 locations are synchronized
- Add any missing components
- Update "used_in" fields

### Automation (Optional)
```bash
# Update all 3 registries from component files
python scripts/manage_components.py --sync

# Add new component to all registries
python scripts/manage_components.py --add PrimaryButton \
  --framework react \
  --file component-library/react/Button.tsx
```

## Phase 3: Verification, Revision & Finalization

**Objective:** Verify implementation, handle revisions, and organize final assets.

### Four-Step Process

```
Step 1: Initial Verification
   ↓
Step 2: Revision Loop (if issues found)
   ↓
Step 3: Final Confirmation
   ↓
Step 4: Asset Organization (when complete)
```

### Step 1: Initial Verification

**When:** User completes implementation and shares code/screenshots

**Process:**
1. **User Signals Readiness:**
   ```
   [User says]: "구현 완료했습니다" or shares code/screenshots
   ```

2. **Invoke Phase 3 Sub-Agent:**
   ```
   [Internal]: Read references/phase3-verification.md for detailed instructions.

   [To user]: 구현하신 코드를 검증하겠습니다.
   ```

3. **Provide Minimal Context to Sub-Agent:**
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

4. **Sub-Agent Verification:**
   The Phase 3 sub-agent will:
   - Load Proposal (design intent) and Implementation Guide (spec)
   - Verify design intent is met
   - Check specification compliance
   - Run lint/build quality checks
   - Verify accessibility requirements
   - Categorize issues by severity (Critical/Major/Minor)
   - Create Verification Report (in Korean)
   - **Save verification to: `projects/{screen-name}/{date}-verification-v{n}.md`**
   - **Update `projects/{screen-name}/metadata.json`**
   - Provide specific fix guidance

5. **Report Results:**

   **If PASS (✅):**
   ```
   [To user]:
   ✅ 검증 완료! 문제가 없습니다.

   구현이 완료되었습니까? 수정할 부분이 있습니까?
   (이제 Step 3: Final Confirmation으로 진행합니다)
   ```

   **If FAIL (❌ or ⚠️):**
   ```
   [To user]:
   검증 완료. 수정이 필요한 부분이 있습니다.

   [검증 보고서 제공 - 한글]

   수정 후 다시 검증을 요청해주세요.
   (Step 2: Revision Loop으로 진행합니다)
   ```

### Step 2: Revision Loop (If Issues Found)

**When:** Verification found issues that need fixing

**Process:**
1. **User Fixes Issues:**
   - User applies fixes based on verification report
   - User may ask clarifying questions

2. **User Requests Re-verification:**
   ```
   [User says]: "수정했습니다" or "다시 검증해주세요"
   ```

3. **Run Verification Again:**
   - Return to Step 1: Initial Verification
   - Focus on previously failed items
   - Create new verification report with incremented version
   - Save as `{date}-verification-v{n+1}.md`

4. **Iterate Until Pass:**
   - Repeat Step 2 until verification passes
   - Each iteration creates new versioned report

### Step 3: Final Confirmation

**When:** Verification has passed (✅)

**Process:**
1. **Agent Asks User:**
   ```
   [To user]:
   ✅ 검증을 통과했습니다!

   구현이 완료되었습니까? 수정할 부분이 있습니까?

   - "완료" → 프로젝트를 마무리하고 에셋을 정리하겠습니다
   - "수정 필요" → 어떤 부분을 수정하실지 알려주세요
   ```

2. **User Responses:**

   **If "완료" or confirms completion:**
   → Proceed to Step 4: Asset Organization

   **If requests changes:**
   → Ask what to change
   → Determine if Phase 2A, 2B, or just re-implementation needed
   → Return to appropriate phase

### Step 4: Asset Organization (When User Confirms Completion)

**When:** User confirms "완료" in Step 3

**Process:**
1. **Update Component Registry (All 3 Locations):**
   ```
   [Agent updates]:
   1. Design System artifact (Section 7)
   2. component-library/registry.json
   3. component-library/COMPONENTS.md

   Adds/updates:
   - Components created in this project
   - "used_in" field with this screen name
   - File paths and design tokens
   ```

2. **Generate/Update metadata.json:**
   ```json
   {
     "project_name": "login-screen",
     "status": "completed",
     "created_date": "2025-11-22",
     "last_updated": "2025-11-23",
     "phase": "completed",
     "framework": "React",
     "design_system_version": "v1.0",
     "versions": {
       "proposal": "v1",
       "implementation": "v1",
       "verification": "v2"
     },
     "dependencies": [],
     "components_created": [
       "PrimaryButton",
       "EmailInput"
     ]
   }
   ```

3. **Update projects/INDEX.md:**
   ```markdown
   ## Completed Projects
   - **login-screen** (Completed) - Finished: 2025-11-23
   ```

4. **Create Final Summary:**
   ```
   [To user in Korean]:
   🎉 login-screen 프로젝트가 완료되었습니다!

   생성된 파일:
   - projects/login-screen/20251122-proposal-v1.md
   - projects/login-screen/20251122-implementation-v1.md
   - projects/login-screen/20251123-verification-v2.md
   - projects/login-screen/metadata.json

   생성된 컴포넌트:
   - PrimaryButton (component-library/react/Button.tsx)
   - EmailInput (component-library/react/Input.tsx)

   다음 단계:
   - 다른 화면/기능 개선? (→ Phase 2A로)
   - 디자인 토큰 내보내기?
   - 세션 종료?
   ```

5. **Mark Project as COMPLETED:**
   - Set `metadata.json` status to "completed"
   - Move project from "Active" to "Completed" in INDEX.md
   - Ensure all assets are preserved

**Orchestrator's Role:**
- Verify all 3 Component Registry locations are updated
- Verify metadata.json is created/updated
- Verify projects/INDEX.md is updated
- Provide clear completion summary
- Ask user about next steps

## Session Completion

When user wants to end the session:

### Completion Checklist
```
[To user]:
세션을 종료하기 전 확인:

✅ 모든 프로젝트가 Phase 3 Step 4를 완료했습니까?
✅ Component Registry가 업데이트되었습니까?
✅ projects/INDEX.md가 최신 상태입니까?
✅ metadata.json이 모든 프로젝트에 생성되었습니까?

미완료 프로젝트:
- [list any projects not in "completed" status]

이대로 세션을 종료하시겠습니까?
```

### Asset Preservation
- All documents saved in `projects/` directories
- Component Registry synchronized (3 locations)
- Design System saved in `design-systems/`
- Components saved in `component-library/`
- INDEX.md reflects current status

### Next Session Resumption
```
[To user]:
다음 세션에서 재개하려면:

1. Design System 위치 알려주기:
   design-systems/[product]-design-system.md

2. 이어서 작업할 프로젝트 알려주기:
   projects/[screen-name]/

3. 또는 projects/INDEX.md를 보고 선택

모든 진행 상황이 저장되어 있습니다!
```

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
   - Updated when new components are added (in Phase 2B & Phase 3 Step 4)
   - Never recreate, only update

2. **Improvement Proposal Artifact:**
   - Created in Phase 2A
   - **Saved to: `projects/{screen-name}/{date}-proposal-v{n}.md`**
   - Used as Single Source of Truth in Phase 2B
   - Contains all context Phase 2B needs

3. **Implementation Guide Artifact:**
   - Created in Phase 2B
   - **Saved to: `projects/{screen-name}/{date}-implementation-v{n}.md`**
   - Used in Phase 3 for verification

4. **Verification Reports:**
   - Created in Phase 3 Step 1
   - **Saved to: `projects/{screen-name}/{date}-verification-v{n}.md`**
   - Versioned for each re-verification

5. **Component Registry (3 Locations):**
   - Initialized in Phase 1 (empty)
   - Checked in Phase 2A for reuse
   - Updated in Phase 2B when components are implemented
   - **Final update in Phase 3 Step 4**
   - Lives in:
     - Design System artifact (Section 7)
     - `component-library/registry.json`
     - `component-library/COMPONENTS.md`

6. **Component Library Files:**
   - **Location: `./component-library/[framework]/[Component].[ext]`**
   - Created in Phase 2B when new components are implemented
   - Searched in Phase 2A for reusability
   - Managed by `scripts/manage_components.py`

7. **Project Metadata:**
   - **Location: `projects/{screen-name}/metadata.json`**
   - Created/updated in Phase 2A
   - Updated throughout Phase 2B and Phase 3
   - Final update in Phase 3 Step 4

8. **Project Index:**
   - **Location: `projects/INDEX.md`**
   - Updated when projects are created (Phase 2A)
   - Updated when projects are completed (Phase 3 Step 4)
   - Shows status of all projects

9. **Session Flow:**
   ```
   Phase 1 → [Approval + Save Design System File] →
   Phase 2A (Screen A) → [Check Component Library] → [Approval] → [Save Proposal] →
   Phase 2B (Screen A) → [Save Components to Library] → [Save Implementation] → [User implements] →
   Phase 3 Step 1 (Screen A) → [Verify + Save Report] →
   Phase 3 Step 2 (if issues) → [Fix + Re-verify + Save v2 Report] →
   Phase 3 Step 3 (Screen A) → [User confirms "완료"] →
   Phase 3 Step 4 (Screen A) → [Update Registry + metadata + INDEX] → [COMPLETED] →
   Phase 2A (Screen B) → [Reuse Components from Library] → ...
   ```

**Never:**
- Start over or lose Design System
- Create duplicate Design Systems
- Skip Phase 2A and go directly to Phase 2B
- Load full Design System in Phase 2B or Phase 3 (use Proposal/Guide references)
- Skip Phase 3 verification (quality assurance)
- **Skip Phase 3 Step 4 asset organization (loses Component Registry updates)**
- **Forget to save documents with proper naming convention**
- **Mark project complete before user confirms in Step 3**

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

Output will be `design-tokens.[ext]` in `design-systems/` directory.

## Quality Gates

### Phase 1 Quality Gate:
- ✅ Design System artifact created (not just text)
- ✅ All sections have specific values (no #000000 placeholders)
- ✅ Component Registry section exists
- ✅ User has approved
- ✅ Artifact can be referenced in Phase 2A
- ✅ **Design System saved to `design-systems/` directory**
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
- ✅ **Proposal saved to `projects/{screen-name}/{date}-proposal-v{n}.md`**
- ✅ **metadata.json created/updated**
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
- ✅ **Components saved to `component-library/[framework]/`**
- ✅ Implementation Guide artifact created
- ✅ **Implementation saved to `projects/{screen-name}/{date}-implementation-v{n}.md`**
- ✅ **metadata.json updated**
- ✅ User confirms guide is complete
- ✅ All user-facing communication in Korean

**Do not proceed to Phase 3 until implementation is complete.**

### Phase 3 Quality Gate (per screen):

**Step 1: Initial Verification**
- ✅ User has implemented code ready
- ✅ Improvement Proposal and Implementation Guide loaded
- ✅ Design intent verification completed
- ✅ Specification compliance checked
- ✅ Code quality verified (lint/build)
- ✅ Accessibility requirements checked
- ✅ Issues categorized by severity
- ✅ Verification Report created (in Korean)
- ✅ **Verification saved to `projects/{screen-name}/{date}-verification-v{n}.md`**
- ✅ Specific fix guidance provided (in Korean)
- ✅ Pass/Fail determination clear

**Step 2: Revision Loop**
- ✅ Each re-verification creates new versioned report
- ✅ Focused on previously failed items
- ✅ Clear progress tracking

**Step 3: Final Confirmation**
- ✅ User explicitly confirms "완료" or completion
- ✅ All requested changes addressed
- ✅ No outstanding issues

**Step 4: Asset Organization**
- ✅ Component Registry updated in all 3 locations
- ✅ metadata.json updated with "completed" status
- ✅ projects/INDEX.md updated (moved to "Completed")
- ✅ Final summary provided to user
- ✅ All assets preserved and organized

**If PASS Step 3:** Proceed to Step 4 Asset Organization.
**If FAIL Step 1/2:** User fixes issues, re-run verification (Step 2).
**If changes requested in Step 3:** Return to appropriate phase.

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
1. 보고서의 수정 사항 적용 후 재검증 (권장) → Step 2
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

### User says "완료" but verification hasn't passed:
```
아직 검증을 통과하지 못했습니다.

수정이 필요한 부분:
[List issues from last verification]

옵션:
1. 이슈를 수정하고 재검증 받기 (권장)
2. 이슈를 알고 있지만 일단 완료 처리
3. Phase 2A로 돌아가서 방향 수정

어떻게 하시겠어요?
```

### User wants to skip Phase 3 Step 4:
```
Phase 3 Step 4 (Asset Organization)는 필수입니다.

이 단계에서:
- Component Registry 최종 업데이트 (3곳)
- metadata.json 완료 표시
- projects/INDEX.md 업데이트
- 재사용 가능한 에셋 정리

이 단계를 건너뛰면 다음 프로젝트에서 컴포넌트를 재사용할 수 없습니다.

잠시만 기다려주시면 빠르게 완료하겠습니다.
```

## Success Criteria

**Phase 1 Success:**
- Complete, usable Design System artifact exists
- User is satisfied with design direction
- Foundation is ready for Phase 2A
- **Design System saved to file**
- All communication in Korean

**Phase 2A Success:**
- Improvement Proposal artifact created
- User approves the direction
- All changes mapped to Design System tokens
- Dependencies clear
- **Proposal saved with proper naming convention**
- **metadata.json created/updated**
- Ready for Phase 2B
- All communication in Korean

**Phase 2B Success:**
- Implementation Guide artifact created
- Specifications are precise and developer-ready
- Only used tokens from Proposal (minimal context)
- Component Registry updated
- **Implementation saved with proper naming convention**
- **Components saved to component-library/**
- **metadata.json updated**
- User confirms guide is complete
- All communication in Korean

**Phase 3 Success:**
- **Step 1:** Verification Report created (in Korean), design intent verified, specification compliance checked, code quality verified
- **Step 2:** All issues resolved through revision loop (if needed)
- **Step 3:** User explicitly confirms completion
- **Step 4:** Component Registry synchronized (3 locations), metadata.json marked "completed", INDEX.md updated, final summary provided
- Clear pass/fail determination
- Actionable fix guidance provided (in Korean)
- **All documents saved with proper naming convention**

**Overall Success:**
- User has consistent, improved UI across product
- Reusable design system enables future work
- Clear implementation path for developers
- Efficient context usage throughout process
- Quality assurance through verification
- **All assets organized and preserved for future sessions**
- **Component Registry enables component reuse**
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
- ✅ Step 3 confirmation questions
- ✅ Step 4 completion summary

### English OK (Internal):

- ✅ Artifact content (Design System, Proposal, Implementation Guide)
- ✅ Code examples (React/Flutter/Vue/etc.)
- ✅ Token names and technical terms
- ✅ CSS/styling code
- ✅ Framework-specific terminology
- ✅ Internal processing notes
- ✅ File names and paths

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
