---
name: ui-renewal
description: Fully automated UI renewal skill with end-to-end implementation. Orchestrates a five-phase workflow - Phase 1 creates Design System, Phase 2A analyzes and proposes improvements, Phase 2B creates implementation specifications, Phase 2C automatically implements code in Presentation layer only, Phase 3 verifies and auto-fixes issues. User only makes decisions (approve/reject), agent handles all implementation. Maintains Clean Architecture, modifies only UI layer. All user-facing communication in Korean.
---

# UI Renewal Skill

Fully automated professional UI renewal with systematic design system creation, automatic code implementation, and quality verification.

## ⚠️ File Path Rule (CRITICAL)

**ALL file operations MUST use full path starting with `.claude/skills/ui-renewal/`**

**Correct Path Examples:**
- ✅ `.claude/skills/ui-renewal/projects/login-screen/20251122-proposal-v1.md`
- ✅ `.claude/skills/ui-renewal/design-systems/gabium-design-system.md`
- ✅ `.claude/skills/ui-renewal/component-library/flutter/GabiumButton.dart`

**Wrong Paths (NEVER use these):**
- ❌ `projects/login-screen/...` (WRONG - creates in root/projects/)
- ❌ `./projects/login-screen/...` (WRONG - relative path)
- ❌ `../projects/login-screen/...` (WRONG - unpredictable location)

**Always verify after saving:**
```bash
ls .claude/skills/ui-renewal/projects/{screen-name}/{filename}
```

If file not found, search for it:
```bash
find . -name "{filename}" -type f
```

---

## When to Use This Skill

Trigger this skill when users request:
- "Redesign my [app/website/interface]"
- "Improve the UI of [screen/feature]"
- "Create a design system for my product"
- "Make this look better/more professional/more modern"
- "Fix the UX of [feature]"
- Any request to improve visual design or user experience

## Workflow Overview

This skill operates in five phases, executed in a single continuous session:

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
[User approves specification]
   ↓
Phase 2C: Automated Implementation (NEW)
   ↓
[Agent implements code automatically]
   ↓
Phase 3: Verification, Revision & Finalization
   ↓ Step 1: Verify → Step 2: Revise (if needed) → Step 3: Confirm → Step 4: Organize
   ↓
[Complete: Assets organized in component library] [Revise: Fix and re-verify]
   ↓
[Repeat 2A→2B→2C→3 for next screen/feature]
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
- **implementation-log**: Implementation Log (Phase 2C output)
- **verification**: Verification Report (Phase 3 output)

### Examples
```
20251122-proposal-v1.md          (First proposal, created Nov 22, 2025)
20251122-proposal-v2.md          (Revised proposal, same day)
20251122-implementation-v1.md    (Implementation spec)
20251122-implementation-log-v1.md (Implementation log from Phase 2C)
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
- **Phase 2C**: Saves implementation log as `{date}-implementation-log-v{n}.md` in `projects/{screen-name}/`
- **Phase 3**: Saves verification as `{date}-verification-v{n}.md` in `projects/{screen-name}/`

## Directory Structure

### Root Structure
```
ui-renewal/
├── design-systems/              # Design System documents (Phase 1)
│   ├── [product]-design-system.md      # → Symlink to latest version
│   ├── [product]-design-system-v1.0.md # Version 1.0
│   ├── [product]-design-system-v1.1.md # Version 1.1 (if updated)
│   ├── [product]-design-system-v2.0.md # Version 2.0 (major update)
│   ├── design-tokens.*                  # Exported tokens (optional)
│   └── VERSION_HISTORY.md               # Design System change log
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
│   ├── phase2c-implementation.md
│   └── phase3-verification.md
│
└── scripts/                     # Automation tools
    ├── export_design_tokens.py
    ├── manage_components.py
    ├── update_component_registry.py
    └── generate_project_index.py
```

### Project Directory Structure

Each screen/feature gets its own subdirectory in `projects/`:

```
projects/{screen-name}/
├── metadata.json                # Project metadata
├── {date}-proposal-v{n}.md      # Improvement proposals (Phase 2A)
├── {date}-implementation-v{n}.md # Implementation specs (Phase 2B)
├── {date}-implementation-log-v{n}.md # Implementation logs (Phase 2C)
├── {date}-verification-v{n}.md  # Verification reports (Phase 3)
└── screenshots/                 # Optional visual references
```

### metadata.json Format
```json
{
  "project_name": "login-screen",
  "status": "completed",
  "current_phase": "completed",
  "created_date": "2025-11-22",
  "last_updated": "2025-11-23T14:30:00Z",
  "framework": "React",
  "design_system_version": "v1.0",
  "versions": {
    "proposal": "v1",
    "implementation": "v1",
    "implementation_log": "v2",
    "verification": "v2"
  },
  "dependencies": [],
  "components_created": [
    "PrimaryButton",
    "EmailInput"
  ],
  "retry_count": 1,
  "last_error": null
}
```

### metadata.json Schema

**Required Fields:**
- `project_name` (string): Project directory name
- `status` (enum): Project status
  - `"pending"` - Not started
  - `"in_progress"` - Currently being worked on
  - `"completed"` - Finished successfully
  - `"failed"` - Failed and abandoned
- `current_phase` (enum): Current workflow phase
  - `"phase1"` - Design System Creation
  - `"phase2a"` - Analysis & Direction
  - `"phase2b"` - Implementation Specification
  - `"phase2c"` - Automated Implementation
  - `"phase3_step1"` - Initial Verification
  - `"phase3_step2"` - Revision Loop
  - `"phase3_step3"` - Final Confirmation
  - `"phase3_step4"` - Asset Organization
  - `"completed"` - Project complete
- `created_date` (string): ISO 8601 date (YYYY-MM-DD)
- `last_updated` (string): ISO 8601 datetime with timezone
- `framework` (string): Target framework (React, Flutter, Vue, etc.)
- `design_system_version` (string): Design System version used (e.g., "v1.0", "v1.1")
  - **Important:** Track which DS version each project uses
  - **Purpose:** Enable rollback and migration tracking
  - **Format:** Semantic versioning (vX.Y)

**Optional Fields:**
- `versions` (object): Document version tracking
  - `proposal` (string): Latest Proposal version
  - `implementation` (string): Latest Implementation Guide version
  - `implementation_log` (string): Latest Implementation Log version
  - `verification` (string): Latest Verification Report version
- `dependencies` (array): List of prerequisite projects
- `components_created` (array): Components created in this project
- `retry_count` (number): Number of Phase 3 Step 2 retries (default: 0)
- `last_error` (string|null): Last error message if failed (null if no error)

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

**Execution Guide:** Read `references/phase1-design-system.md` for detailed instructions.

**Quality Gate:**
- ✅ Design System artifact created and approved
- ✅ All sections filled with specific values (no placeholders)
- ✅ Component Registry initialized
- ✅ Design System saved to `design-systems/[product]-design-system.md`
- ✅ All user-facing communication in Korean

**Next Phase:** Phase 2A (Analysis & Direction)

## Phase 2A: Analysis & Direction

**Objective:** Analyze current UI and create Improvement Proposal artifact.

**Execution Guide:** Read `references/phase2a-analysis.md` for detailed instructions.

**Prerequisites:**
- Design System artifact available
- Target screen/feature identified

**Quality Gate:**
- ✅ Improvement Proposal artifact created
- ✅ All changes mapped to Design System tokens
- ✅ Dependencies documented
- ✅ Component Registry checked for reusable components
- ✅ Proposal saved to `projects/{screen-name}/{date}-proposal-v{n}.md`
- ✅ metadata.json created/updated
- ✅ User approves direction
- ✅ All user-facing communication in Korean

**Next Phase:** Phase 2B (Implementation Specification)

## Phase 2B: Implementation Specification

**Objective:** Convert approved Proposal into precise implementation guide.

**Execution Guide:** Read `references/phase2b-implementation.md` for detailed instructions.

**Prerequisites:**
- Improvement Proposal approved
- ONLY load Proposal + Token Reference (minimal context)

**Quality Gate:**
- ✅ Implementation Guide artifact created
- ✅ Complete specifications (components, layout, interactions)
- ✅ Framework-specific code examples
- ✅ Implementation saved to `projects/{screen-name}/{date}-implementation-v{n}.md`
- ✅ metadata.json updated
- ✅ User confirms guide complete
- ✅ All user-facing communication in Korean

**Next Phase:** Phase 2C (Automated Implementation)

## Phase 2C: Automated Implementation

**Objective:** Automatically implement UI code in Presentation layer only.

**Execution Guide:** Read `references/phase2c-implementation.md` for detailed instructions.

**Prerequisites:**
- Implementation Guide approved
- Project architecture understood

**Git Workflow (Recommended):**

For safe rollback and clean change tracking:

```bash
# Before Phase 2C
git checkout -b ui-renewal/{screen-name}

# After Phase 3 passes
git checkout main
git merge ui-renewal/{screen-name}

# If Phase 3 fails (rollback)
git checkout main
git branch -D ui-renewal/{screen-name}
```

**Benefits:**
- Easy rollback if verification fails
- Clean separation of changes
- Review all changes with `git diff main`

---

**CRITICAL Rules:**
- ✅ ONLY modify Presentation layer (`lib/features/{feature}/presentation/`, `lib/core/presentation/`)
- ❌ NEVER modify Application/Domain/Infrastructure layers
- ✅ Use existing providers/notifiers only
- ✅ Follow Clean Architecture strictly

**Automated Validation:**
```bash
# Validate before committing
bash scripts/validate_presentation_layer.sh check
```

This script automatically checks that only Presentation layer files are modified.

**Quality Gate:**
- ✅ Code implemented in Presentation layer only
- ✅ Implementation log saved to `projects/{screen-name}/{date}-implementation-log-v{n}.md`
- ✅ metadata.json updated
- ✅ No architectural violations

**Next Phase:** Phase 3 (Verification)

## Phase 3: Verification, Revision & Finalization

**Objective:** Verify implementation, handle revisions, organize final assets.

**Execution Guide:** Read `references/phase3-verification.md` for detailed instructions.

**Four-Step Process:**

### Step 1: Initial Verification
- Automatically triggered after Phase 2C
- Verify design intent, specification compliance, code quality
- Create verification report (in Korean)
- Save to `projects/{screen-name}/{date}-verification-v{n}.md`

### Step 2: Revision Loop (if issues found)
- Automatically re-invoke Phase 2C to fix issues
- Re-verify until passing
- Each iteration creates versioned reports

### Step 3: Final Confirmation
- User confirms completion or requests changes
- If changes needed, return to appropriate phase

### Step 4: Asset Organization (when user confirms)
- Copy reusable components to component library
- Update Component Registry (all 3 locations)
- Update metadata.json with "completed" status
- Update projects/INDEX.md
- Provide completion summary

**Quality Gate:**
- ✅ Verification passed
- ✅ User confirms "완료"
- ✅ Components copied to component library
- ✅ Component Registry synchronized
- ✅ metadata.json marked "completed"
- ✅ INDEX.md updated
- ✅ All user-facing communication in Korean

## Component Registry Management

The Component Registry uses **Single Source of Truth (SSOT)** pattern:

**SSOT:** `component-library/registry.json`

**Generated Files (Do not edit manually):**
- `component-library/COMPONENTS.md` - Human-readable documentation
- Design System Section 7 - Component summary for design system

**Update Workflow:**
- **Phase 2A:** Check `registry.json` for reusable components
- **Phase 3 Step 4:** Update `registry.json` ONLY, then run generation script

**Automation:**
```bash
# Update registry.json (SSOT)
# Edit component-library/registry.json directly or use:
python scripts/update_component_registry.py --add ComponentName --framework flutter --file path

# Generate documentation from registry.json
python scripts/generate_components_docs.py --output-components-md --output-design-system-section

# Or use all-in-one sync (updates registry + generates docs)
python scripts/manage_components.py --sync
```

**Important:**
- ✅ ONLY edit `registry.json` manually or via scripts
- ❌ DO NOT edit `COMPONENTS.md` manually (auto-generated)
- ❌ DO NOT edit Design System Section 7 directly (copy from generated file)

## Scripts

Available automation tools in `scripts/` directory:

### validate_artifact.sh
Validate artifacts before phase transitions to ensure data integrity.

```bash
# Validate Proposal before Phase 2B
bash scripts/validate_artifact.sh proposal projects/{screen-name}/{date}-proposal-v1.md

# Validate Implementation before Phase 2C
bash scripts/validate_artifact.sh implementation projects/{screen-name}/{date}-implementation-v1.md

# Validate all artifacts before Phase 3
bash scripts/validate_artifact.sh proposal projects/{screen-name}/{date}-proposal-v1.md
bash scripts/validate_artifact.sh implementation projects/{screen-name}/{date}-implementation-v1.md
bash scripts/validate_artifact.sh implementation-log projects/{screen-name}/{date}-implementation-log-v1.md
```

**Validation Types:**
- `proposal` - Checks for required sections and token reference table
- `implementation` - Checks for component specs and layout structure
- `implementation-log` - Checks for files list and changes summary
- `verification` - Checks for Korean sections and PASS/FAIL status

### validate_presentation_layer.sh
Validate that only Presentation layer is modified (Phase 2C constraint).

```bash
# Check current unstaged changes
bash scripts/validate_presentation_layer.sh check

# Check staged changes (for git commit)
bash scripts/validate_presentation_layer.sh stage

# Set up as git pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
bash .claude/skills/ui-renewal/scripts/validate_presentation_layer.sh stage
EOF
chmod +x .git/hooks/pre-commit
```

**Validates:**
- ✅ Only Presentation layer files modified
- ❌ Blocks Application/Domain/Infrastructure changes
- ⚠️ Warns about routing or other non-standard files

**Use:** Run before committing Phase 2C changes to ensure Clean Architecture compliance.

### git_workflow_helper.sh
Manage Git branches for safe Phase 2C implementation with easy rollback.

```bash
# Start Phase 2C with new branch
bash scripts/git_workflow_helper.sh login-screen start

# After Phase 3 passes - merge to main
bash scripts/git_workflow_helper.sh login-screen merge

# If Phase 3 fails - rollback all changes
bash scripts/git_workflow_helper.sh login-screen rollback
```

### export_design_tokens.py
Export Design System to various formats (JSON/CSS/Tailwind/Flutter). Used after Phase 1 (optional).

```bash
python scripts/export_design_tokens.py [design-system.md] --format [json|css|tailwind|flutter]
```

### manage_components.py
Sync Component Registry across all 3 locations. Used in Phase 3 Step 4.

```bash
# Sync all registries
python scripts/manage_components.py --sync

# Add new component
python scripts/manage_components.py --add ComponentName --framework flutter --file path
```

### update_component_registry.py
Update individual registry entries. Used in Phase 3 Step 4.

### generate_components_docs.py
Generate documentation from registry.json (SSOT). Used in Phase 3 Step 4 after updating registry.

```bash
# Generate COMPONENTS.md
python scripts/generate_components_docs.py --output-components-md

# Generate Design System Section 7
python scripts/generate_components_docs.py --output-design-system-section

# Generate both
python scripts/generate_components_docs.py --output-components-md --output-design-system-section
```

### generate_project_index.py
Auto-generate projects/INDEX.md from metadata. Used in Phase 3 Step 4.

### version_design_system.sh
Manage Design System versions with automated versioning workflow.

```bash
# Create new Design System version
bash scripts/version_design_system.sh create v1.1 gabium

# Rollback to previous version
bash scripts/version_design_system.sh rollback v1.0 gabium

# List all available versions
bash scripts/version_design_system.sh list
```

**Use cases:**
- **Create new version:** When updating Design System with new components or breaking changes
- **Rollback:** When new version causes issues in projects
- **List:** Check available versions for migration planning

**After creating new version:**
1. Edit the new versioned file with changes
2. Update VERSION_HISTORY.md with change log
3. Update affected project metadata with new DS version

## Session Completion

Before ending session, verify:
- ✅ All projects completed Phase 3 Step 4
- ✅ Component Registry updated
- ✅ projects/INDEX.md current
- ✅ metadata.json exists for all projects

**Next Session Resumption:**
1. Provide Design System location: `design-systems/[product]-design-system.md`
2. Specify project to continue: `projects/[screen-name]/`
3. Or review `projects/INDEX.md` to choose

All progress is preserved in files.

## Language Rules

**CRITICAL: All user-facing communication MUST be in Korean.**

**Korean Required:**
- Questions, explanations, summaries to user
- Verification reports (entire document)
- Issue descriptions and fix guidance
- All phase outputs to user

**English OK:**
- Artifact content (Design System, Proposal, Implementation)
- Code examples
- Token names, file paths
- Framework-specific terminology

## Success Criteria

**Phase 1:** Design System artifact created, approved, saved to file

**Phase 2A:** Improvement Proposal created, approved, saved with proper naming

**Phase 2B:** Implementation Guide created, approved, saved with proper naming

**Phase 2C:** Code implemented in Presentation layer only, implementation log saved

**Phase 3:** Verification passed, user confirms, assets organized, Component Registry updated

**Overall:** Consistent improved UI, reusable design system, efficient context usage, quality assurance, all assets organized, all communication in Korean

## Handling Edge Cases

### User wants to skip Phase 1
Explain importance of Design System for consistency. Offer lightweight version (~10 min).

### User provides external design system
Convert to skill's artifact format for consistent referencing.

### Phase reveals Design System gaps
Offer to update Design System or use workaround. List impacted screens.

### User requests changes after phase approval
Return to appropriate phase (2A for direction, 2B for specs).

### Verification fails repeatedly (>3 iterations)
Ask user for direction: fix manually, adjust approach, or accept current state.

### User says "완료" but verification hasn't passed
List remaining issues, offer options: fix and re-verify, proceed anyway, or change approach.

For additional edge cases, sub-agents should reference their respective phase guides in `references/`.
