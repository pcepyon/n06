# Phase 3: Verification, Revision & Finalization Guide

This guide is for the Verification & Finalization sub-agent. Use this when the orchestrator routes a Phase 3 task.

## Objective

Verify implemented code matches design intent, support revision iterations, obtain final user confirmation, and properly organize all assets for future reuse.

## Prerequisites

**Required:**
- Improvement Proposal artifact from Phase 2A
- Implementation Guide artifact from Phase 2B
- User's implemented code (screenshots or actual code files)

**Context Strategy:**
- Load ONLY: Proposal + Implementation Guide + User's code
- DO NOT load full Design System

---

## Step 1: Initial Verification

### 1.1 Load Context

Load precisely:
1. Improvement Proposal (design intent)
2. Implementation Guide (specifications)
3. User's implemented code
4. Design System tokens from Implementation Guide ONLY

### 1.2 Verification Checklist

**Design Intent Compliance:**
- [ ] All changes from Proposal implemented?
- [ ] Design goals achieved?
- [ ] Brand consistency maintained?

**Specification Compliance:**
- [ ] All component specs from Implementation Guide followed?
- [ ] Correct Design System token values used?
- [ ] Interactive states (hover, active, disabled) implemented?
- [ ] Layout structure matches specs?

**Code Quality:**
- [ ] No lint errors (`flutter analyze` or equivalent)
- [ ] No build errors
- [ ] Proper imports
- [ ] Clean code structure

**Accessibility:**
- [ ] Color contrast ≥ WCAG AA (4.5:1 for text, 3:1 for UI)
- [ ] Touch targets ≥ 44x44px
- [ ] Keyboard navigation works
- [ ] Screen reader labels present

**Functionality:**
- [ ] All existing features still work?
- [ ] No regressions?
- [ ] New features work as expected?

### 1.3 Issue Categorization

**Critical (❌ Blocker)**:
- Design System tokens not used
- Accessibility violations (contrast < 4.5:1, touch targets < 44px)
- Broken functionality
- Build/lint errors

**Major (⚠️ Important)**:
- Missing interactive states
- Incorrect specifications
- Visual inconsistencies

**Minor (ℹ️ Nice-to-have)**:
- Code style improvements
- Documentation additions

### 1.4 Create Verification Report (Korean)

**Format:**
```markdown
# [Screen Name] 검증 보고서

**검증일**: {date}
**상태**: ✅ PASS / ❌ FAIL / ⚠️ NEEDS WORK

## 검증 결과 요약

- 디자인 의도 준수: ✅/❌
- 명세 준수: ✅/❌
- 코드 품질: ✅/❌
- 접근성: ✅/❌
- 기능성: ✅/❌

## 발견된 문제점

### Critical Issues (필수 수정)
1. [Issue description]
   - 위치: [file:line]
   - 현재: [current state]
   - 기대: [expected state]
   - 수정방법: [how to fix]

### Major Issues (권장 수정)
...

### Minor Issues (선택 수정)
...

## 다음 단계

❌ FAIL: [N]개 Critical 이슈 수정 필요
⚠️ NEEDS WORK: [N]개 Major 이슈 검토 필요
✅ PASS: Step 3 (최종 확인)으로 진행
```

### 1.5 Present Results to User (Korean)

**If PASS:**
```
✅ 검증 완료! 모든 항목이 통과했습니다.

Step 3 (최종 확인)으로 진행합니다.
```

**If FAIL or NEEDS WORK:**
```
검증 완료. 수정이 필요한 부분이 있습니다.

[검증 보고서 제공]

수정 후 재검증을 요청해주세요.
```

---

## Step 2: Revision Loop

### 2.1 User Fixes Issues

Wait for user to fix issues and request re-verification.

### 2.2 Re-verification

**Focus on fixed items:**
- Load previous Verification Report
- Check ONLY the issues that were listed
- Verify fixes are correct
- Update Verification Report

**Re-verification Report:**
```markdown
# [Screen Name] 재검증 보고서 (v{N})

**재검증일**: {date}
**이전 상태**: ❌ FAIL
**현재 상태**: ✅ PASS / ❌ STILL FAIL

## 수정 확인

### Issue #1: [Title]
- ✅ 수정 완료 / ❌ 미수정 / ⚠️ 부분 수정
- 확인 내용: [what was checked]

...

## 남은 문제점
[If any]

## 다음 단계
✅ PASS: Step 3로 진행
❌ FAIL: 추가 수정 필요
```

### 2.3 Iteration

Repeat Step 2 until PASS.

**Guideline:**
- Maximum 3-4 iterations recommended
- If stuck, suggest returning to Phase 2A/2B for redesign

---

## Step 3: Final Confirmation

### 3.1 Ask User for Completion Confirmation (Korean)

**When verification PASS:**

```
✅ 검증 완료! 모든 항목이 통과했습니다.

구현이 완료되었습니까? 추가로 수정하실 부분이 있습니까?

1. ✅ 완료 - 이 화면 작업을 종료하고 에셋을 정리합니다
2. 🔄 수정 필요 - 추가 수정 사항을 알려주세요
3. ➡️ 다음 화면 - 이 화면은 완료하고 다른 화면을 개선합니다
```

### 3.2 Handle User Response

**Option 1: "완료"**
→ Proceed to Step 4 (Asset Organization)

**Option 2: "수정 필요"**
→ User describes changes
→ Determine if:
  - Minor fix: Guide user, then re-verify (Step 1)
  - Major change: Return to Phase 2A (re-analysis) or Phase 2B (re-spec)

**Option 3: "다음 화면"**
→ Proceed to Step 4 for current screen
→ Then return to Phase 2A for next screen

---

## Step 4: Asset Organization & Completion

**CRITICAL: This step ensures all work is preserved for future reuse.**

### 4.1 Update Component Registry (3 Locations)

**If new components were created in Phase 2B:**

#### Location 1: Design System Component Registry

Update `design-systems/{product}-design-system.md` Section 7:

```markdown
## 7. Component Registry

| Component | Created Date | Used In | Notes |
|-----------|--------------|---------|-------|
| {ComponentName} | {YYYY-MM-DD} | {screen-name} | {description} |
```

#### Location 2: registry.json

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
      ...
    }
  ]
}
```

#### Location 3: COMPONENTS.md

Update `.claude/skills/ui-renewal/component-library/COMPONENTS.md`:
- Add row to Component Registry table
- Add component specification section

**Automation (if script exists):**
```bash
python scripts/update_component_registry.py \
  --component {ComponentName} \
  --framework {framework} \
  --used-in "{screen-name}"
```

### 4.2 Create/Update metadata.json

Create `projects/{screen-name}/metadata.json`:

```json
{
  "screenName": "{screen-name}",
  "framework": "{framework}",
  "createdDate": "{YYYY-MM-DD}",
  "lastUpdated": "{YYYY-MM-DD}",
  "designSystem": "{Product} Design System v{version}",
  "documents": [
    {
      "type": "proposal",
      "version": 1,
      "date": "{YYYY-MM-DD}",
      "file": "{YYYYMMDD}-proposal-v1.md",
      "approved": true
    },
    {
      "type": "implementation",
      "version": 1,
      "date": "{YYYY-MM-DD}",
      "file": "{YYYYMMDD}-implementation-v1.md"
    },
    {
      "type": "verification",
      "version": 1,
      "date": "{YYYY-MM-DD}",
      "file": "{YYYYMMDD}-verification-v1.md",
      "status": "PASS"
    }
  ],
  "components": [
    "{ComponentName1}",
    "{ComponentName2}"
  ],
  "status": "completed",
  "iterations": 1
}
```

### 4.3 Update projects/INDEX.md

Update `.claude/skills/ui-renewal/projects/INDEX.md`:

```markdown
## Active Projects

| Screen/Feature | Framework | Status | Last Updated | Documents |
|---------------|-----------|--------|--------------|-----------|
| {screen-name} | {framework} | ✅ Completed | {date} | [Proposal](link), [Implementation](link), [Verification](link) |
```

**Automation (if script exists):**
```bash
python scripts/generate_project_index.py
```

### 4.4 Save Verification Report (Optional)

If user wants to keep verification history:

Save to `projects/{screen-name}/{YYYYMMDD}-verification-v1.md`

### 4.5 Create Final Summary (Korean)

**Present to user:**

```markdown
# ✅ [{Screen Name}] 작업 완료

## 완료된 작업

✅ Phase 2A: 개선 방향 분석 및 제안
✅ Phase 2B: 구현 명세 작성
✅ Phase 3: 검증 및 최종 확인

## 생성된 문서

- 📄 개선 제안서: `projects/{screen-name}/{YYYYMMDD}-proposal-v1.md`
- 📄 구현 가이드: `projects/{screen-name}/{YYYYMMDD}-implementation-v1.md`
- 📄 검증 보고서: `projects/{screen-name}/{YYYYMMDD}-verification-v1.md` (선택)
- 📄 프로젝트 메타데이터: `projects/{screen-name}/metadata.json`

## 생성/재사용된 컴포넌트

| 컴포넌트 | 상태 | 위치 |
|---------|------|------|
| {ComponentName1} | ✅ 신규 생성 | `component-library/{framework}/{ComponentName1}.{ext}` |
| {ComponentName2} | ♻️ 재사용 | - |

## 업데이트된 에셋

✅ Component Registry (3곳 업데이트 완료)
✅ metadata.json 생성
✅ INDEX.md 업데이트

## 다음 단계

- **다른 화면 개선**: Phase 2A로 돌아가서 다음 화면 분석 시작
- **디자인 토큰 내보내기**: `flutter ThemeData`, `JSON`, `CSS` 등
- **프로젝트 종료**: 모든 화면 완료 시 최종 정리

---

**이 화면의 모든 작업이 완료되었으며, 향후 재사용을 위해 체계적으로 보존되었습니다.** ✅
```

### 4.6 Mark Project as Completed

**In metadata.json:**
```json
{
  "status": "completed",
  "completedDate": "{YYYY-MM-DD}"
}
```

**In INDEX.md:**
```markdown
| {screen-name} | {framework} | ✅ Completed | {date} | ... |
```

---

## Quality Gates

### Step 1 Quality Gate:
- ✅ Verification Report created (Korean)
- ✅ All 5 categories checked (Design Intent, Specs, Code Quality, Accessibility, Functionality)
- ✅ Issues categorized by severity
- ✅ Specific fix guidance provided

### Step 2 Quality Gate:
- ✅ Re-verification Report updated
- ✅ Fixed issues marked as resolved
- ✅ Remaining issues documented
- ✅ User notified of re-verification results

### Step 3 Quality Gate:
- ✅ User explicitly confirms completion ("완료")
- ✅ No outstanding Critical or Major issues
- ✅ User satisfied with implementation

### Step 4 Quality Gate:
- ✅ Component Registry updated (3 locations if new components)
- ✅ metadata.json created/updated
- ✅ INDEX.md updated
- ✅ Final Summary presented to user
- ✅ Project marked as "completed"

---

## Edge Cases

### User wants to skip verification
```
Phase 3 Step 1 검증은 필수 단계입니다.

검증을 통해:
- 디자인 의도대로 구현되었는지 확인
- 명세 준수 여부 확인
- 코드 품질 및 접근성 검증

구현 완료 후 Phase 3 검증을 요청해주세요.
```

### User wants to skip Step 4 (Asset Organization)
```
Step 4 에셋 정리는 재사용성을 위해 필수입니다.

이 단계를 건너뛰면:
❌ Component Registry가 업데이트되지 않음
❌ 다음 화면에서 컴포넌트 재사용 불가
❌ 작업 히스토리 추적 불가

자동으로 처리되므로 시간이 거의 걸리지 않습니다.
진행하시겠습니까?
```

### Too many revision iterations (>4)
```
4회 이상 재검증이 반복되고 있습니다.

다음 옵션을 고려해주세요:
1. Phase 2A로 돌아가서 개선 방향 재검토
2. Phase 2B로 돌아가서 구현 명세 수정
3. 현재 접근 방식을 계속 시도

어떻게 진행하시겠습니까?
```

### User requests changes after "완료" confirmation
```
완료 확인 후 변경사항이 있으시군요.

옵션:
1. 경미한 수정: Step 1 (검증)부터 재시작
2. 큰 변경: Phase 2A (재분석) 또는 Phase 2B (재명세)
3. 새 버전: 현재 v1 유지, 새로 v2 시작

어떤 방식으로 진행하시겠습니까?
```

---

## Success Criteria

**Overall Phase 3 Success:**
- ✅ Code verified and passes all checks
- ✅ User confirms completion
- ✅ All assets properly organized
- ✅ Component Registry updated (if applicable)
- ✅ metadata.json created
- ✅ INDEX.md updated
- ✅ Final Summary provided to user
- ✅ Project marked as "completed"
- ✅ Ready for next screen or session end

---

## OUTPUT LANGUAGE

**CRITICAL: All user-facing communication in Korean.**

Examples:
- ✅ "검증 완료! 모든 항목이 통과했습니다."
- ✅ "구현이 완료되었습니까?"
- ✅ "에셋 정리가 완료되었습니다."
- ❌ "Verification complete!" (English)
