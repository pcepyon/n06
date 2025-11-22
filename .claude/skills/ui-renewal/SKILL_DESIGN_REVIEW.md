# UI Renewal Skill 설계 검토 및 개선안

**작성일**: 2025-11-22
**검토자**: Claude Code
**목적**: 재사용성과 일관성 강화를 위한 설계 개선

---

## 1. 현재 설계 분석

### 1.1 설계 의도 (Design Intent)
✅ **잘 설계된 부분**:
1. Design System을 기반으로 모든 작업 진행
2. Component Registry로 재사용 가능한 컴포넌트 추적
3. Phase별 명확한 산출물 정의
4. 컴포넌트 백업 (`component-library/flutter/`)

### 1.2 실제 구현 분석

#### ✅ 잘 작동하는 부분

1. **Design System 관리**
   - 파일 위치: `design-systems/gabium-design-system.md` ✅
   - Component Registry 섹션 존재 ✅
   - Design Tokens 내보내기 ✅

2. **컴포넌트 재사용**
   - Component Library 백업 ✅
   - COMPONENTS.md 문서화 ✅
   - registry.json 생성 ✅ (수동 생성)
   - Phase 2A에서 Component Registry 확인 로직 존재 ✅

3. **Phase별 가이드**
   - `references/phase1-design-system.md` ✅
   - `references/phase2a-analysis.md` ✅
   - `references/phase2b-implementation.md` ✅
   - `references/phase3-verification.md` ✅

---

## 2. 발견된 문제점

### 문제 1: 문서 저장 위치 불일치 ❌

**현황**:
```
proposals/
  └── email-signup-screen-improvement-proposal.md

artifacts/
  ├── email-signin-screen-improvement-proposal.md  ← 같은 종류인데 다른 디렉토리
  └── email-signin-screen-implementation-guide.md

implementation-guides/
  └── email-signup-screen-implementation-guide.md  ← 같은 종류인데 다른 디렉토리
```

**문제**:
- Proposal이 `proposals/`와 `artifacts/`에 분산
- Implementation Guide가 `artifacts/`와 `implementation-guides/`에 분산
- 화면별 문서를 찾기 어려움
- 아카이빙 불가능 (어디에 뭐가 있는지 추적 불가)

**원인**:
- SKILL.md에 명확한 저장 위치 규칙 없음
- Phase 2A/2B 가이드에 "artifact 생성" 명시만 있고 저장 위치 불명확

---

### 문제 2: 명명 규칙 불명확 ❌

**현황**:
```
email-signup-screen-improvement-proposal.md
email-signin-screen-improvement-proposal.md
email-signup-screen-implementation-guide.md
email-signin-screen-implementation-guide.md
```

**문제**:
- 날짜/버전 정보 없음 (여러 버전 관리 불가)
- Phase 정보 없음 (Phase 2A인지 Phase 2B인지 파일명만으로 알 수 없음)
- 프레임워크 정보 없음 (Flutter인지 React인지 파일명에 없음)

**원인**:
- SKILL.md에 파일명 규칙 미정의
- Phase 가이드에 파일명 규칙 미정의

---

### 문제 3: Component Registry 자동 업데이트 없음 ⚠️

**현황**:
- Phase 2B에서 "Update Component Registry" 명시됨 ✅
- 하지만 실제로는 수동 업데이트 필요 ❌
- registry.json도 수동 생성 ❌

**문제**:
- 컴포넌트 생성 후 Registry 업데이트 누락 가능성
- registry.json과 Design System Registry 불일치 가능성

**원인**:
- 자동화 스크립트 없음 (`scripts/manage_components.py` 참조만 있음)
- Phase 2B 가이드에 수동 업데이트 절차 불명확

---

### 문제 4: 화면별 문서 추적 어려움 ❌

**현황**:
하나의 화면(예: Email Signup)에 대해:
```
proposals/email-signup-screen-improvement-proposal.md
implementation-guides/email-signup-screen-implementation-guide.md
component-library/flutter/AuthHeroSection.dart
component-library/flutter/GabiumTextField.dart
...
```

**문제**:
- 화면별로 어떤 문서/컴포넌트가 있는지 한눈에 파악 불가
- 히스토리 추적 불가 (언제 어떤 변경이 있었는지)

**원인**:
- 화면별 메타데이터 파일 없음
- 프로젝트 인덱스 파일 없음

---

## 3. 개선안

### 개선안 1: 통일된 디렉토리 구조 ✅

**제안하는 새 구조**:
```
.claude/skills/ui-renewal/
├── design-systems/
│   ├── {product}-design-system.md           # Design System (v1.0, v1.1...)
│   └── design-tokens.{format}               # 내보낸 토큰
├── component-library/
│   ├── COMPONENTS.md                        # 컴포넌트 문서
│   ├── registry.json                        # 컴포넌트 레지스트리 (자동 생성)
│   └── {framework}/
│       └── {ComponentName}.{ext}            # 컴포넌트 백업
├── projects/                                # 📁 신규: 화면별 프로젝트 디렉토리
│   └── {screen-name}/                       # 예: email-signup-screen/
│       ├── {YYYYMMDD}-proposal-v{N}.md     # Phase 2A 산출물
│       ├── {YYYYMMDD}-implementation-v{N}.md # Phase 2B 산출물
│       ├── {YYYYMMDD}-verification-v{N}.md  # Phase 3 산출물 (선택)
│       └── metadata.json                    # 프로젝트 메타데이터
├── references/                              # Phase 가이드 (변경 없음)
├── scripts/                                 # 자동화 스크립트
└── ASSET_VERIFICATION_REPORT.md
```

**장점**:
- ✅ 화면별로 모든 문서가 한 곳에 모임 (`projects/{screen-name}/`)
- ✅ 날짜/버전으로 히스토리 추적 가능
- ✅ 일관된 저장 위치 (proposals/, artifacts/, implementation-guides/ 폐지)

---

### 개선안 2: 명명 규칙 표준화 ✅

**파일명 규칙**:
```
{YYYYMMDD}-{document-type}-v{version}.md

document-type:
  - proposal              (Phase 2A)
  - implementation        (Phase 2B)
  - verification          (Phase 3, 선택)

예시:
  20251122-proposal-v1.md
  20251122-implementation-v1.md
  20251123-proposal-v2.md    (재작업 시)
```

**메타데이터 파일** (`projects/{screen-name}/metadata.json`):
```json
{
  "screenName": "email-signup-screen",
  "framework": "Flutter",
  "createdDate": "2025-11-22",
  "lastUpdated": "2025-11-22",
  "designSystem": "Gabium Design System v1.0",
  "documents": [
    {
      "type": "proposal",
      "version": 1,
      "date": "2025-11-22",
      "file": "20251122-proposal-v1.md",
      "approved": true
    },
    {
      "type": "implementation",
      "version": 1,
      "date": "2025-11-22",
      "file": "20251122-implementation-v1.md"
    }
  ],
  "components": [
    "AuthHeroSection",
    "GabiumTextField",
    "GabiumButton",
    "PasswordStrengthIndicator",
    "ConsentCheckbox",
    "GabiumToast"
  ],
  "status": "completed"
}
```

**장점**:
- ✅ 날짜순 정렬 가능
- ✅ 버전 관리 가능 (재작업 시 v2, v3...)
- ✅ 메타데이터로 빠른 검색/필터링

---

### 개선안 3: Component Registry 자동 업데이트 ✅

**Phase 2B 완료 시 자동 실행**:
```python
# scripts/update_component_registry.py
def update_registry(component_info):
    # 1. registry.json 업데이트
    # 2. Design System의 Component Registry 테이블 업데이트
    # 3. COMPONENTS.md 업데이트
    pass
```

**Phase 2B 가이드 수정**:
```markdown
### Step 7: Update Component Registry (AUTOMATED)

After saving component files, automatically run:

```bash
python scripts/update_component_registry.py \
  --component {ComponentName} \
  --framework {framework} \
  --used-in "{screen-name}" \
  --file "component-library/{framework}/{ComponentName}.{ext}"
```

This will:
1. ✅ Update registry.json
2. ✅ Update Design System Component Registry table
3. ✅ Update COMPONENTS.md
```

**장점**:
- ✅ 수동 업데이트 실수 방지
- ✅ 항상 최신 상태 유지
- ✅ 세 곳(registry.json, Design System, COMPONENTS.md) 자동 동기화

---

### 개선안 4: 프로젝트 인덱스 파일 ✅

**프로젝트 인덱스** (`projects/INDEX.md`):
```markdown
# UI Renewal Projects Index

## Active Projects

| Screen/Feature | Framework | Status | Last Updated | Documents |
|---------------|-----------|--------|--------------|-----------|
| Email Signup Screen | Flutter | ✅ Completed | 2025-11-22 | [Proposal](email-signup-screen/20251122-proposal-v1.md), [Implementation](email-signup-screen/20251122-implementation-v1.md) |
| Email Signin Screen | Flutter | ✅ Completed | 2025-11-22 | [Proposal](email-signin-screen/20251122-proposal-v1.md), [Implementation](email-signin-screen/20251122-implementation-v1.md) |

## Planned Projects

| Screen/Feature | Priority | Framework | Notes |
|---------------|----------|-----------|-------|
| Password Reset Screen | High | Flutter | 기존 컴포넌트 재사용 가능 |
| Onboarding Screen | Medium | Flutter | - |
```

**자동 생성**:
```bash
python scripts/generate_project_index.py
```

**장점**:
- ✅ 전체 프로젝트 한눈에 파악
- ✅ 진행 상태 추적
- ✅ 컴포넌트 재사용 기회 발견

---

### 개선안 5: Phase 2A에서 Component Registry 확인 강화 ✅

**Phase 2A 가이드 수정**:
```markdown
### Step 3: Component Registry & Library Check (MANDATORY)

**CRITICAL: This step is MANDATORY before proposing new components.**

#### 3.1 Load Component Registry
```bash
# Read from registry.json
cat component-library/registry.json

# Or from Design System
grep -A 20 "## 7. Component Registry" design-systems/{product}-design-system.md
```

#### 3.2 Search for Reusable Components
For each UI element you plan to propose:
1. Check if similar component exists
2. Check if it can be reused as-is
3. Check if it can be adapted (variant)
4. Only propose NEW component if no reuse possible

**Output in Proposal:**
```
### Component Reuse Plan

| UI Element | Existing Component | Reuse Strategy |
|------------|-------------------|----------------|
| Hero Section | AuthHeroSection | ✅ Reuse as-is |
| Input Field | GabiumTextField | ✅ Reuse as-is |
| Button | GabiumButton | ✅ Reuse (Primary variant) |
| Checkbox | ConsentCheckbox | ❌ Not applicable, create new |
```
```

**장점**:
- ✅ 불필요한 중복 컴포넌트 생성 방지
- ✅ 재사용률 극대화
- ✅ 개발 시간 단축

---

## 4. 우선순위별 개선 계획

### Phase 1 (즉시 실행) 🔥
1. **디렉토리 구조 개선**
   - `projects/` 디렉토리 생성
   - 기존 문서 이동 (proposals/, artifacts/, implementation-guides/ → projects/)
   - metadata.json 생성

2. **명명 규칙 적용**
   - 기존 문서 리네임 (날짜-타입-버전 형식)
   - SKILL.md에 명명 규칙 문서화

3. **프로젝트 인덱스 생성**
   - `projects/INDEX.md` 수동 생성
   - 현재 완료된 2개 프로젝트 등록

### Phase 2 (단기) 📅
4. **자동화 스크립트 작성**
   - `scripts/update_component_registry.py` 생성
   - `scripts/generate_project_index.py` 생성
   - Phase 2B 가이드에 자동화 추가

5. **Phase 2A 가이드 강화**
   - Component Registry 확인 단계 MANDATORY로 변경
   - 재사용 계획 섹션 추가

### Phase 3 (중장기) 🔮
6. **버전 관리 시스템**
   - Design System 버전 관리 (v1.0 → v1.1)
   - 변경 이력 추적

7. **검색/필터링 기능**
   - 컴포넌트 검색 (`scripts/search_components.py`)
   - 화면별 문서 검색

---

## 5. SKILL.md 수정 제안

### 추가할 섹션

#### 5.1 Document Naming Convention

```markdown
## Document Naming Convention

All documents follow this pattern:
`{YYYYMMDD}-{document-type}-v{version}.md`

**Document Types:**
- `proposal`: Phase 2A Improvement Proposal
- `implementation`: Phase 2B Implementation Guide
- `verification`: Phase 3 Verification Report (optional)

**Examples:**
- `20251122-proposal-v1.md` (Phase 2A, first version)
- `20251122-implementation-v1.md` (Phase 2B, first version)
- `20251123-proposal-v2.md` (Phase 2A, revised version)

**Version Increment:**
- v1, v2, v3... when re-doing the same screen/feature
- Date changes when created on different days
```

#### 5.2 Directory Structure

```markdown
## Directory Structure

```
.claude/skills/ui-renewal/
├── design-systems/
│   └── {product}-design-system.md
├── component-library/
│   ├── registry.json (auto-generated)
│   └── {framework}/
├── projects/                    # Screen/feature projects
│   ├── INDEX.md                # Auto-generated index
│   └── {screen-name}/
│       ├── {YYYYMMDD}-proposal-v{N}.md
│       ├── {YYYYMMDD}-implementation-v{N}.md
│       └── metadata.json       # Auto-generated
├── references/
└── scripts/
```

**Project Directory:**
Each screen/feature gets its own directory under `projects/`:
- All documents for that screen are stored together
- metadata.json tracks versions and components
- Easy to find and archive
```

#### 5.3 Component Registry Management

```markdown
## Component Registry Management

**Phase 2A (Analysis):**
- MUST check Component Registry before proposing new components
- MUST document reuse plan in Proposal

**Phase 2B (Implementation):**
- Automatically updates Component Registry when creating new components
- Updates three sources:
  1. registry.json
  2. Design System Component Registry table
  3. COMPONENTS.md

**Manual Update (if needed):**
```bash
python scripts/update_component_registry.py \
  --component {ComponentName} \
  --framework {framework} \
  --used-in "{screen-name}"
```
```

---

## 6. 즉시 실행 가능한 조치

### 조치 1: 기존 문서 재구성

```bash
# 1. projects 디렉토리 생성
mkdir -p .claude/skills/ui-renewal/projects/{email-signup-screen,email-signin-screen}

# 2. 문서 이동 및 리네임
mv .claude/skills/ui-renewal/proposals/email-signup-screen-improvement-proposal.md \
   .claude/skills/ui-renewal/projects/email-signup-screen/20251122-proposal-v1.md

mv .claude/skills/ui-renewal/implementation-guides/email-signup-screen-implementation-guide.md \
   .claude/skills/ui-renewal/projects/email-signup-screen/20251122-implementation-v1.md

mv .claude/skills/ui-renewal/artifacts/email-signin-screen-improvement-proposal.md \
   .claude/skills/ui-renewal/projects/email-signin-screen/20251122-proposal-v1.md

mv .claude/skills/ui-renewal/artifacts/email-signin-screen-implementation-guide.md \
   .claude/skills/ui-renewal/projects/email-signin-screen/20251122-implementation-v1.md

# 3. 기존 디렉토리 삭제 (비어있으면)
rmdir .claude/skills/ui-renewal/proposals
rmdir .claude/skills/ui-renewal/artifacts
rmdir .claude/skills/ui-renewal/implementation-guides
```

### 조치 2: metadata.json 생성

각 프로젝트 디렉토리에 metadata.json 생성 (위 예시 참조)

### 조치 3: INDEX.md 생성

`projects/INDEX.md` 생성 (위 예시 참조)

---

## 7. 결론

### 현재 상태 평가

| 항목 | 상태 | 점수 |
|-----|------|------|
| Design System 기반 작업 | ✅ 잘 됨 | 10/10 |
| Component Registry 존재 | ✅ 잘 됨 | 9/10 |
| 컴포넌트 재사용 로직 | ✅ 잘 됨 | 8/10 |
| 문서 저장 위치 일관성 | ❌ 문제 | 3/10 |
| 명명 규칙 표준화 | ❌ 문제 | 2/10 |
| 화면별 문서 추적 | ❌ 문제 | 2/10 |
| Registry 자동 업데이트 | ⚠️ 부분적 | 5/10 |
| 프로젝트 인덱스 | ❌ 없음 | 0/10 |

**종합 점수: 6.1/10**

### 개선 후 예상 점수

| 항목 | 개선 후 상태 | 점수 |
|-----|------------|------|
| Design System 기반 작업 | ✅ 유지 | 10/10 |
| Component Registry 존재 | ✅ 유지 + 자동화 | 10/10 |
| 컴포넌트 재사용 로직 | ✅ 강화 | 10/10 |
| 문서 저장 위치 일관성 | ✅ 개선 | 10/10 |
| 명명 규칙 표준화 | ✅ 개선 | 10/10 |
| 화면별 문서 추적 | ✅ 개선 | 10/10 |
| Registry 자동 업데이트 | ✅ 자동화 | 10/10 |
| 프로젝트 인덱스 | ✅ 신규 | 10/10 |

**종합 점수: 10/10**

---

## 8. 권장 사항

### 즉시 실행 (오늘)
1. ✅ 디렉토리 구조 재구성 (조치 1)
2. ✅ metadata.json 생성 (조치 2)
3. ✅ INDEX.md 생성 (조치 3)
4. ✅ SKILL.md에 명명 규칙/디렉토리 구조 문서화

### 단기 (이번 주)
5. ✅ update_component_registry.py 스크립트 작성
6. ✅ generate_project_index.py 스크립트 작성
7. ✅ Phase 2A/2B 가이드 업데이트

### 중장기 (다음 프로젝트)
8. ✅ Design System 버전 관리 시스템 구축
9. ✅ 컴포넌트 검색 스크립트 작성

---

**검토 완료일**: 2025-11-22
**검토자**: Claude Code
