# Phase 3: Asset Organization & Completion Guide

This guide is for agents executing Phase 3 of the UI Renewal workflow.

## Objective

Properly organize all implementation artifacts for future reuse, maintain project documentation, and provide a clear completion summary to the user.

## Table of Contents

1. [Objective](#objective)
2. [Prerequisites](#prerequisites)
3. [Step 1: Update Component Registry](#step-1-update-component-registry-ssot)
4. [Step 2: Generate Documentation](#step-2-generate-documentation-automated)
5. [Step 3: Create/Update metadata.json](#step-3-createupdate-metadatajson)
6. [Step 4: Update projects/INDEX.md](#step-4-update-projectsindexmd)
7. [Step 5: Create Completion Summary](#step-5-create-completion-summary-korean)
8. [Quality Gates](#quality-gates)
9. [Edge Cases](#edge-cases)
10. [Success Criteria](#success-criteria)
11. [Output Language](#output-language)

---

## Prerequisites

**Required:**
- Implementation Log from Phase 2C
- Modified files in Presentation layer
- User confirmation of completion (implicit or explicit)

**Context Strategy:**
- Load ONLY: Implementation Log + Component information (if new components created)
- DO NOT load full Design System or Proposal documents

---

## Step 1: Update Component Registry (SSOT)

**IMPORTANT: This step is performed ONLY in Phase 3, after implementation is complete.**

**If new components were created in Phase 2C:**

### Step 1.1: Update registry.json (Single Source of Truth)

Update `.claude/skills/ui-renewal/component-library/registry.json`:

```json
{
  "components": [
    {
      "name": "{ComponentName}",
      "createdDate": "{YYYY-MM-DD}",
      "framework": "{framework}",
      "file": "{framework}/{ComponentName}.{ext}",
      "projectFile": "lib/.../widgets/{component_name}.{ext}",
      "usedIn": ["{screen-name}"],
      "category": "{category}",
      "description": "{description}",
      "designTokens": {
        "colors": ["Primary", "Neutral-900"],
        "typography": ["base", "lg"],
        "spacing": ["md", "lg"],
        "borderRadius": ["sm"],
        "shadows": ["sm"]
      },
      "props": [
        {
          "name": "text",
          "type": "String",
          "required": true,
          "description": "Button text"
        }
      ]
    }
  ]
}
```

**Categories:**
- `button` - Interactive buttons
- `input` - Form inputs and text fields
- `card` - Content containers
- `layout` - Layout components (headers, footers, containers)
- `navigation` - Navigation elements
- `feedback` - Alerts, toasts, modals
- `display` - Data display components

---

## Step 2: Generate Documentation (Automated)

Run the generation script to update COMPONENTS.md and Design System section:

```bash
python .claude/skills/ui-renewal/scripts/generate_components_docs.py \
  --output-components-md \
  --output-design-system-section
```

This will:
- Update `.claude/skills/ui-renewal/component-library/COMPONENTS.md` (Component Registry table + specs)
- Generate `design-system-section-7.md` (for Design System artifact)

### Step 2.1: Update Design System Artifact

Copy content from generated `design-system-section-7.md` and paste into Design System artifact Section 7.

**Process:**
1. ✅ ONLY edit `registry.json` manually (SSOT)
2. ✅ Run generation script to update COMPONENTS.md
3. ✅ Copy generated content to Design System artifact
4. ❌ DO NOT edit COMPONENTS.md or Design System manually

**Why SSOT Pattern:**
- Single source ensures consistency
- Automation prevents manual errors
- Easy to maintain and update
- Scripts handle formatting and cross-references

---

## Step 3: Create/Update metadata.json

**CRITICAL - Use exact path below:**

`.claude/skills/ui-renewal/projects/{screen-name}/metadata.json`

**Example:**
- ✅ `.claude/skills/ui-renewal/projects/email-signup-screen/metadata.json`

Create the metadata file:

```json
{
  "project_name": "{screen-name}",
  "status": "completed",
  "current_phase": "completed",
  "created_date": "{YYYY-MM-DD}",
  "last_updated": "{now}",
  "framework": "{framework}",
  "design_system_version": "v1.0",
  "versions": {
    "proposal": "v1",
    "implementation": "v1",
    "implementation_log": "v1"
  },
  "dependencies": [],
  "components_created": [
    "{ComponentName1}",
    "{ComponentName2}"
  ]
}
```

**Field Descriptions:**

- `project_name`: Screen or feature name (kebab-case)
- `status`: `"completed"` (always for Phase 3)
- `current_phase`: `"completed"` (always for Phase 3)
- `created_date`: Initial project start date (YYYY-MM-DD)
- `last_updated`: Current timestamp (YYYY-MM-DD HH:MM:SS)
- `framework`: `"flutter"`, `"react"`, etc.
- `design_system_version`: Design System version used (e.g., `"v1.0"`)
- `versions`: Document versions for this project
- `dependencies`: Other screens/features this depends on (empty array if none)
- `components_created`: List of new component names created in this project

---

## Step 4: Update projects/INDEX.md

Update `.claude/skills/ui-renewal/projects/INDEX.md`:

```markdown
## Active Projects

| Screen/Feature | Framework | Status | Last Updated | Documents |
|---------------|-----------|--------|--------------|-----------|
| {screen-name} | {framework} | ✅ Completed | {date} | [Proposal](link), [Implementation](link), [Log](link) |
```

**Document Links:**
- Proposal: `./{screen-name}/{YYYYMMDD}-proposal-v1.md`
- Implementation: `./{screen-name}/{YYYYMMDD}-implementation-v1.md`
- Log: `./{screen-name}/{YYYYMMDD}-implementation-log-v1.md`

**Automation (if script exists):**

```bash
python scripts/generate_project_index.py
```

---

## Step 5: Create Completion Summary (Korean)

**Present to user:**

```markdown
# ✅ [{Screen Name}] 작업 완료

## 완료된 작업

✅ Phase 2A: 개선 방향 분석 및 제안
✅ Phase 2B: 구현 명세 작성
✅ Phase 2C: 코드 자동 구현
✅ Phase 3: 에셋 정리 및 문서화

## 생성된 문서

- 📄 개선 제안서: `.claude/skills/ui-renewal/projects/{screen-name}/{YYYYMMDD}-proposal-v1.md`
- 📄 구현 가이드: `.claude/skills/ui-renewal/projects/{screen-name}/{YYYYMMDD}-implementation-v1.md`
- 📄 구현 로그: `.claude/skills/ui-renewal/projects/{screen-name}/{YYYYMMDD}-implementation-log-v1.md`
- 📄 프로젝트 메타데이터: `.claude/skills/ui-renewal/projects/{screen-name}/metadata.json`

## 생성/재사용된 컴포넌트

| 컴포넌트 | 상태 | 위치 |
|---------|------|------|
| {ComponentName1} | ✅ 신규 생성 | `component-library/{framework}/{ComponentName1}.{ext}` |
| {ComponentName2} | ♻️ 재사용 | - |

## 업데이트된 에셋

✅ Component Registry 업데이트 완료
✅ metadata.json 생성 완료
✅ INDEX.md 업데이트 완료

## 다음 단계

- **다른 화면 개선**: Phase 2A로 돌아가서 다음 화면 분석 시작
- **디자인 토큰 내보내기**: `flutter ThemeData`, `JSON`, `CSS` 등
- **프로젝트 종료**: 모든 화면 완료 시 최종 정리

---

**이 화면의 모든 작업이 완료되었으며, 향후 재사용을 위해 체계적으로 보존되었습니다.** ✅
```

**Customization:**
- Replace `{Screen Name}` with actual screen name (e.g., "온보딩 화면")
- Replace `{screen-name}` with kebab-case screen name
- Replace `{YYYYMMDD}` with actual dates from file names
- Replace `{ComponentName1}`, `{ComponentName2}` with actual component names
- Replace `{framework}` with actual framework (e.g., "flutter")
- Include only components that were actually created (remove table if none)

---

## Quality Gates

### Step 1 Quality Gate:
- ✅ registry.json updated with new components (or confirmed no new components)
- ✅ Component entries include all required fields
- ✅ Design tokens accurately reflect component usage

### Step 2 Quality Gate:
- ✅ COMPONENTS.md generated successfully
- ✅ design-system-section-7.md generated successfully
- ✅ Design System artifact updated with Section 7 content

### Step 3 Quality Gate:
- ✅ metadata.json created at correct path
- ✅ All required fields present and accurate
- ✅ Status set to "completed"
- ✅ components_created list matches actual components

### Step 4 Quality Gate:
- ✅ INDEX.md updated with project entry
- ✅ Status marked as "✅ Completed"
- ✅ Document links are correct and accessible

### Step 5 Quality Gate:
- ✅ Completion summary presented to user
- ✅ All document paths are correct
- ✅ Component table reflects actual components created
- ✅ Summary is in Korean

---

## Edge Cases

### No new components created

```
이 프로젝트에서는 새로운 컴포넌트가 생성되지 않았습니다.

기존 컴포넌트를 재사용하여 구현되었습니다.

Component Registry 업데이트는 건너뜁니다.
```

Skip Step 1 and Step 2. Proceed to Step 3.

### User wants to modify completed project

```
완료된 프로젝트를 수정하시겠습니까?

옵션:
1. 경미한 수정: Phase 2C로 돌아가서 일부 수정
2. 큰 변경: Phase 2A (재분석) 또는 Phase 2B (재명세)
3. 새 버전: 현재 v1 유지, 새로 v2 시작

어떤 방식으로 진행하시겠습니까?
```

**If user chooses new version (v2):**
- Increment version numbers in metadata.json
- Create new dated files with `-v2` suffix
- Keep v1 files as history

### Script fails to generate documentation

```
문서 생성 스크립트가 실패했습니다.

에러: {error message}

대안:
1. registry.json 수동 확인 (형식 오류 가능성)
2. Python 환경 확인
3. 수동으로 COMPONENTS.md 업데이트 (권장하지 않음)

계속 진행하시겠습니까?
```

If script fails, ask user if they want to:
- Fix the error and retry
- Skip documentation generation (not recommended)
- Manual intervention

### Multiple screens completed in single session

For each screen, run Phase 3 separately:

```
2개 화면이 완료되었습니다:
1. {screen-1}: Phase 3 완료 ✅
2. {screen-2}: Phase 3 시작 중...

각 화면마다 별도의 메타데이터와 Component Registry 업데이트가 필요합니다.
```

---

## Success Criteria

**Overall Phase 3 Success:**
- ✅ Component Registry updated (if new components created)
- ✅ Documentation generated (COMPONENTS.md, Design System Section 7)
- ✅ metadata.json created with status: "completed"
- ✅ INDEX.md updated with project entry
- ✅ Completion summary presented to user in Korean
- ✅ All file paths are correct (`.claude/skills/ui-renewal/...`)
- ✅ Project ready for future reference and component reuse

---

## Output Language

**CRITICAL: All user-facing communication in Korean.**

Examples:
- ✅ "에셋 정리가 완료되었습니다."
- ✅ "Component Registry 업데이트 완료"
- ✅ "이 화면의 모든 작업이 완료되었습니다."
- ❌ "Asset organization complete!" (English)

**Internal artifacts (metadata.json, registry.json, etc.) use English field names but Korean descriptions where applicable.**
