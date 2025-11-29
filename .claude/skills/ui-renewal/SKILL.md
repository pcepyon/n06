---
name: ui-renewal
description: |
  UI 리뉴얼 워크플로우 오케스트레이션. 두 가지 모드 지원:

  (1) 화면별 순차 리뉴얼 (Phase 1→2A→2B→2C→3): 디자인 시스템 생성 후 각 화면을 분석→스펙→구현→정리 순으로 진행. "이 화면 개선해줘", "UI 분석해줘" 등 요청 시 사용.

  (2) 전체 앱 일괄 적용 (Phase F: Foundation): 디자인 시스템이 이미 존재할 때, 분석/제안 없이 ThemeData + 폰트를 전체 앱에 바로 적용. "전체 테마 적용해줘", "폰트 적용해줘", "앱 전체 스타일 통일해줘" 등 요청 시 사용.

  Clean Architecture의 Presentation 레이어만 수정. 모든 커뮤니케이션은 한글.
---

# UI Renewal Skill

## Workflow Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Phase 1: Design System                    │
│              (디자인 시스템이 없을 때만 실행)                   │
└─────────────────────────────────────────────────────────────┘
                              ↓
        ┌─────────────────────┴─────────────────────┐
        ↓                                           ↓
┌───────────────────┐                   ┌───────────────────────┐
│  Phase F:         │                   │  Phase 2A→2B→2C→3:    │
│  Foundation       │                   │  화면별 순차 리뉴얼      │
│                   │                   │                       │
│  전체 앱 일괄 적용   │                   │  분석→스펙→구현→정리    │
│  (ThemeData+폰트)  │                   │  (화면마다 반복)        │
└───────────────────┘                   └───────────────────────┘
```

**Phase F 선택 기준:** 디자인 시스템 존재 + 전체 앱 스타일 통일 요청
**Phase 2A~3 선택 기준:** 특정 화면 개선 요청 또는 세부 분석 필요

---

## Phase F: Foundation (전체 앱 일괄 적용)

**Trigger:** 디자인 시스템 존재 + "전체 테마 적용", "폰트 적용", "앱 스타일 통일" 요청

**Purpose:** 분석/제안 단계 없이 디자인 시스템을 ThemeData + 폰트로 전체 앱에 즉시 적용

**Execute:** 직접 실행 (Task agent 불필요)
- Read: `.claude/skills/ui-renewal/references/phase-f-foundation.md`
- Read: Design System (`design-systems/{product}-design-system-v*.md`)

**Tasks:**
1. 폰트 설치 (pubspec.yaml + assets/fonts/)
2. AppTheme 클래스 생성 (`lib/core/presentation/theme/app_theme.dart`)
3. ThemeData + ThemeExtension 정의
4. main.dart에 테마 적용
5. 빌드 확인

**Output:**
- `lib/core/presentation/theme/app_theme.dart` (ThemeData + Extension)
- `lib/core/presentation/theme/app_colors.dart` (색상 상수)
- `lib/core/presentation/theme/app_typography.dart` (타이포그래피)
- Updated `pubspec.yaml` (폰트 등록)
- Updated `main.dart` (테마 적용)

**CRITICAL Constraints:**
- ONLY modify: `lib/core/presentation/**`, `pubspec.yaml`, `main.dart`
- NEVER modify: 개별 위젯의 하드코딩된 스타일 (이후 Phase 2A~3에서 처리)

**Next:** 완료 또는 Phase 2A~3로 화면별 세부 작업

---

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
