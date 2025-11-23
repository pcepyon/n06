---
name: ui-renewal
description: Orchestrates 5-phase UI renewal workflow with automated implementation. Creates Design System, analyzes UI, generates implementation specs, auto-implements in Presentation layer only, and organizes reusable assets. User approves/rejects, agent executes. Maintains Clean Architecture. All communication in Korean.
---

# UI Renewal Skill

Fully automated professional UI renewal with systematic design system creation, automatic code implementation, and asset organization.

## When to Use This Skill

Trigger this skill when users request:
- "Redesign my [app/website/interface]"
- "Improve the UI of [screen/feature]"
- "Create a design system for my product"
- "Make this look better/more professional/more modern"
- "Fix the UX of [feature]"
- Any request to improve visual design or user experience

## Workflow Overview

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
Phase 2C: Automated Implementation
   ↓
[Agent implements code automatically]
   ↓
Phase 3: Asset Organization & Completion
   ↓
[Complete]
   ↓
[Repeat 2A→2B→2C→3 for next screen/feature]
```

## Phase 1: Design System Creation

**Trigger:** User has no design system OR requests complete redesign/rebrand

**Execute:** Task tool with general-purpose agent (model: sonnet)
- Read: `.claude/skills/ui-renewal/references/phase1-design-system.md`
- Input: Brand info, product goals, UI samples (user-provided)
- Output: Design System → `design-systems/{product}-design-system-v1.0.md`
- Output: Version History → `design-systems/VERSION_HISTORY.md`
- Output: Component Registry → `component-library/registry.json`

**Next:** User approves → Phase 2A

## Phase 2A: Analysis & Direction

**Trigger:** Design System exists AND user requests specific screen/feature improvement

**Execute:** Task tool with general-purpose agent (model: haiku)
- Read: `.claude/skills/ui-renewal/references/phase2a-analysis.md`
- Input: Design System, target screen, current UI (user-provided)
- Output: Proposal → `projects/{screen_name}/{date}-proposal-v{n}.md`
- Output: Metadata → `projects/{screen_name}/metadata.json`
- Update: `projects/INDEX.md`

**Next:** User approves → Phase 2B

## Phase 2B: Implementation Specification

**Trigger:** Proposal approved by user

**Execute:** Task tool with general-purpose agent (model: haiku)
- Read: `.claude/skills/ui-renewal/references/phase2b-implementation.md`
- Input: Proposal, Design System (token reference only)
- Output: Implementation → `projects/{screen_name}/{date}-implementation-v{n}.md`
- Update: Metadata

**Next:** User approves → Phase 2C

## Phase 2C: Automated Implementation

**Trigger:** Implementation specification approved by user

**Execute:** Task tool with general-purpose agent (model: sonnet)
- Read: `.claude/skills/ui-renewal/references/phase2c-implementation.md`
- Input: Implementation Guide, Design System
- Output: Modified files → `lib/features/{feature}/presentation/**/*.dart` (Presentation ONLY)
- Output: Implementation Log → `projects/{screen_name}/{date}-implementation-log-v{n}.md`
- Update: Metadata

**CRITICAL Constraints:**
- ONLY modify: `lib/features/*/presentation/**`, `lib/core/presentation/**`
- NEVER modify: Application/Domain/Infrastructure layers
- Validate: `bash scripts/validate_presentation_layer.sh check`

**Next:** Auto-transition to Phase 3

## Phase 3: Asset Organization & Completion

**Trigger:** Phase 2C completes (automatic) OR user confirms completion

**Execute:** Task tool with general-purpose agent (model: haiku)
- Read: `.claude/skills/ui-renewal/references/phase3-asset-organization.md`
- Input: Implementation Log, modified files
- Output: Updated component registry, metadata, project index

**Tasks:**
1. Update Component Registry (`registry.json`)
2. Generate documentation (COMPONENTS.md, Design System Section 7)
3. Create/Update metadata.json
4. Update projects/INDEX.md
5. Present completion summary to user

**Next:** Project complete OR next screen/feature

## Directory Structure

```
ui-renewal/
├── design-systems/              # Design System documents (Phase 1)
│   ├── [product]-design-system.md      # → Symlink to latest version
│   ├── [product]-design-system-v1.0.md # Version 1.0
│   └── VERSION_HISTORY.md               # Design System change log
│
├── projects/                    # Screen-specific work (Phase 2A/2B/2C/3)
│   ├── INDEX.md                 # Master project index
│   └── {screen-name}/           # Project directory
│       ├── metadata.json        # Project metadata
│       ├── {date}-proposal-v{n}.md
│       ├── {date}-implementation-v{n}.md
│       └── {date}-implementation-log-v{n}.md
│
├── component-library/           # Reusable components (Phase 3)
│   ├── registry.json            # Component registry (SSOT)
│   ├── COMPONENTS.md            # Generated documentation
│   └── flutter/                 # Framework-specific components
│
├── references/                  # Phase-specific guides (read-only)
│   ├── phase1-design-system.md
│   ├── phase2a-analysis.md
│   ├── phase2b-implementation.md
│   ├── phase2c-implementation.md
│   └── phase3-asset-organization.md
│
└── scripts/                     # Automation tools
    ├── validate_presentation_layer.sh
    ├── validate_artifact.sh
    ├── git_workflow_helper.sh
    ├── generate_components_docs.py
    ├── update_component_registry.py
    └── version_design_system.sh
```

### File Paths

All file operations use full paths: `.claude/skills/ui-renewal/{projects|design-systems|component-library}/...`

Never use relative paths (`projects/...`) - they create files in the wrong location.

### metadata.json Schema

Required: `project_name`, `status`, `current_phase`, `created_date`, `last_updated`, `framework`, `design_system_version`

Optional: `versions`, `dependencies`, `components_created`

See references/phase2a-analysis.md for full schema.

## Document Naming Convention

Format: `{YYYYMMDD}-{type}-v{version}.md`

Types: `proposal`, `implementation`, `implementation-log`

## Component Registry Management

**SSOT:** `component-library/registry.json`

**Generated (do not edit):** `COMPONENTS.md`, Design System Section 7

**Update:** Edit `registry.json` → run `python scripts/manage_components.py --sync`

## Scripts

- `validate_presentation_layer.sh` - Validates Presentation layer only modifications
- `validate_artifact.sh` - Validates artifacts before phase transitions
- `git_workflow_helper.sh` - Manages Git branches for safe rollback
- `generate_components_docs.py` - Generates docs from registry.json (SSOT)
- `version_design_system.sh` - Manages Design System versions

## Success Criteria

- **Phase 1:** Design System artifact created, approved, saved
- **Phase 2A:** Improvement Proposal created, approved, saved
- **Phase 2B:** Implementation Guide created, approved, saved
- **Phase 2C:** Code implemented in Presentation layer only, validated, log saved
- **Phase 3:** Assets organized, registry updated, metadata created, completion summary provided
- **Overall:** Consistent improved UI, reusable design system, Clean Architecture maintained, all communication in Korean
