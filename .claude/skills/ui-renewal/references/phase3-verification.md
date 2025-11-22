# Phase 3: Verification & Quality Check Guide

This guide is for the Verification sub-agent. Use this when the orchestrator routes a Phase 3 task.

## Objective

Verify that implemented code matches the design intent and specifications, check for lint/build errors, and ensure quality standards are met.

## Prerequisites

**Required:**
- Improvement Proposal artifact from Phase 2A (design intent)
- Implementation Guide artifact from Phase 2B (specification)
- User's implemented code (files or screenshots)

**Context Strategy:**
- Load ONLY: Improvement Proposal, Implementation Guide, User's code
- Do NOT load: Full Design System, original UI analysis
- Extract ONLY necessary Design System tokens from Implementation Guide

## Process

### Step 1: Load Context (Precisely)

**CRITICAL: Load only what's necessary:**

1. **Improvement Proposal artifact** (design intent and success criteria)
2. **Implementation Guide artifact** (specifications)
3. **User's implemented code** (files, screenshots, or description)
4. **Design System tokens** - ONLY those referenced in Implementation Guide

**Do NOT load:**
- ❌ Full Design System document
- ❌ Original UI screenshots from Phase 2A
- ❌ Analysis notes

### Step 2: Verification Framework

Check implemented code against three levels:

#### 2.1 Design Intent Verification

**Compare implementation against Improvement Proposal:**

**For each Change in Proposal:**
```
Change 1: [Title from Proposal]

Expected Intent:
- Current: [What it was]
- Proposed: [What it should become]
- Rationale: [Why this change]

Actual Implementation:
✅/❌ Intent achieved?
✅/❌ Rationale satisfied?
✅/❌ User experience improved as intended?

Issues (if any):
- [Specific deviation from intent]
```

**Success Criteria Check:**
```
From Proposal Success Criteria:
1. [Criterion 1]: ✅/❌ [Result]
2. [Criterion 2]: ✅/❌ [Result]
3. [Criterion 3]: ✅/❌ [Result]
```

#### 2.2 Specification Compliance

**Compare implementation against Implementation Guide:**

**Component Specifications:**
```
[Component Name] from Implementation Guide

Visual Specs:
- Background: Expected [value] → Actual [value] ✅/❌
- Text Color: Expected [value] → Actual [value] ✅/❌
- Font Size: Expected [value] → Actual [value] ✅/❌
- Padding: Expected [value] → Actual [value] ✅/❌
- Border Radius: Expected [value] → Actual [value] ✅/❌
- Shadow: Expected [value] → Actual [value] ✅/❌

Interactive States:
- Hover: ✅/❌ Implemented correctly
- Active: ✅/❌ Implemented correctly
- Disabled: ✅/❌ Implemented correctly
- Focus: ✅/❌ Implemented correctly

Issues:
- [Specific deviation from spec]
```

**Layout Compliance:**
```
Expected Layout Structure: [From Implementation Guide]
Actual Layout Structure: [From user's code]

✅/❌ Hierarchy matches
✅/❌ Spacing correct
✅/❌ Responsive behavior implemented
✅/❌ Grid/flex configuration matches

Issues:
- [Specific layout deviation]
```

**Interaction Compliance:**
```
Expected Interactions: [From Implementation Guide]

For each interaction:
- [Interaction name]: ✅/❌ Implemented correctly
- Loading state: ✅/❌ Present and correct
- Error handling: ✅/❌ Present and correct
- Success feedback: ✅/❌ Present and correct

Issues:
- [Specific interaction issue]
```

#### 2.3 Code Quality Check

**Lint/Build Errors:**

Based on platform/framework:

**React/Next.js:**
```bash
# If code files provided, check:
- ESLint errors
- TypeScript errors (if applicable)
- Missing dependencies
- Unused imports
- Console warnings
```

**Flutter:**
```bash
# If code files provided, check:
- Dart analysis issues
- Missing imports
- Unused variables
- Widget key warnings
- Performance warnings
```

**Vue/Nuxt:**
```bash
# If code files provided, check:
- ESLint errors
- Template syntax errors
- Missing props validation
- Unused variables
```

**General Code Quality:**
```
✅/❌ Proper component structure
✅/❌ No hardcoded values (uses tokens/variables)
✅/❌ Consistent naming conventions
✅/❌ Proper error handling
✅/❌ Accessibility attributes present
✅/❌ No code duplication
✅/❌ Proper state management
```

**Accessibility Compliance:**
```
From Implementation Guide Accessibility Checklist:

✅/❌ Color contrast meets WCAG AA
✅/❌ Keyboard navigation functional
✅/❌ Focus indicators visible
✅/❌ ARIA labels present
✅/❌ Touch targets minimum 44×44px
✅/❌ Screen reader compatible
```

### Step 3: Issue Categorization

**Categorize all found issues:**

**Critical Issues (Must Fix):**
- Breaks functionality
- Violates design intent
- Accessibility failures
- Build/runtime errors

**Major Issues (Should Fix):**
- Significant spec deviation
- Missing interactive states
- Performance concerns
- Incomplete error handling

**Minor Issues (Nice to Fix):**
- Slight visual differences
- Code style inconsistencies
- Missing edge case handling
- Optimization opportunities

### Step 4: Create Verification Report

**CRITICAL: Output in Korean for user.**

**Structure:**

```markdown
# [기능/화면명] 검증 보고서

## 검증 개요

**검증 일시:** [날짜]  
**검증 범위:** [구현된 기능/화면]  
**전체 평가:** ✅ 통과 / ⚠️ 수정 필요 / ❌ 주요 문제 발견

---

## 1. 기획 의도 충족도

### 성공 기준 달성 여부

[Improvement Proposal의 Success Criteria 기준]

| 성공 기준 | 달성 여부 | 평가 |
|----------|----------|------|
| [기준 1] | ✅/❌ | [구체적 평가] |
| [기준 2] | ✅/❌ | [구체적 평가] |
| [기준 3] | ✅/❌ | [구체적 평가] |

**총평:** [전반적인 기획 의도 달성도]

### 변경 사항별 검증

#### 변경 1: [제목]

**기획 의도:**
- 현재 상태: [기존]
- 목표 상태: [변경 후]
- 개선 이유: [이유]

**구현 결과:**
- ✅/❌ 의도대로 구현됨
- 세부 평가: [구체적 평가]

#### 변경 2: [제목]
[같은 구조 반복]

---

## 2. 명세 준수도

### 컴포넌트 스펙 검증

#### [컴포넌트명]

**시각적 요소:**

| 항목 | 명세 | 구현 | 일치 여부 |
|-----|------|------|----------|
| 배경색 | [값] | [값] | ✅/❌ |
| 텍스트 색상 | [값] | [값] | ✅/❌ |
| 폰트 크기 | [값] | [값] | ✅/❌ |
| 패딩 | [값] | [값] | ✅/❌ |
| 테두리 반경 | [값] | [값] | ✅/❌ |
| 그림자 | [값] | [값] | ✅/❌ |

**인터랙션 상태:**

| 상태 | 명세 여부 | 구현 여부 | 정확도 |
|-----|----------|----------|--------|
| Hover | ✅ | ✅/❌ | [평가] |
| Active | ✅ | ✅/❌ | [평가] |
| Disabled | ✅ | ✅/❌ | [평가] |
| Focus | ✅ | ✅/❌ | [평가] |

### 레이아웃 검증

**예상 구조:** [Implementation Guide의 레이아웃]  
**실제 구조:** [구현된 레이아웃]

- ✅/❌ 계층 구조 일치
- ✅/❌ 간격 일치
- ✅/❌ 반응형 동작 구현
- ✅/❌ 정렬 방식 일치

### 인터랙션 검증

| 인터랙션 | 명세 존재 | 구현 존재 | 정확도 |
|---------|----------|----------|--------|
| [인터랙션 1] | ✅ | ✅/❌ | [평가] |
| 로딩 상태 | ✅ | ✅/❌ | [평가] |
| 에러 처리 | ✅ | ✅/❌ | [평가] |
| 성공 피드백 | ✅ | ✅/❌ | [평가] |

---

## 3. 코드 품질 검증

### 린트/빌드 오류

**분석 결과:**
- ✅/❌ 빌드 성공
- ✅/❌ 린트 오류 없음
- ✅/❌ 타입 오류 없음 (TypeScript인 경우)

**발견된 오류:**
[오류가 있는 경우 목록]

```
[오류 메시지 및 위치]
```

**수정 방법:**
[구체적인 수정 가이드]

### 코드 품질

| 항목 | 평가 | 비고 |
|-----|------|------|
| 컴포넌트 구조 | ✅/❌ | [평가] |
| 토큰 사용 (하드코딩 없음) | ✅/❌ | [평가] |
| 네이밍 컨벤션 | ✅/❌ | [평가] |
| 에러 핸들링 | ✅/❌ | [평가] |
| 코드 중복 | ✅/❌ | [평가] |
| 상태 관리 | ✅/❌ | [평가] |

### 접근성 검증

| 항목 | 명세 요구사항 | 구현 여부 | 평가 |
|-----|------------|----------|------|
| 색상 대비 | WCAG AA (4.5:1) | ✅/❌ | [대비율] |
| 키보드 네비게이션 | 필수 | ✅/❌ | [평가] |
| 포커스 표시 | 필수 | ✅/❌ | [평가] |
| ARIA 레이블 | 필요 시 | ✅/❌ | [평가] |
| 터치 타겟 크기 | 44×44px 이상 | ✅/❌ | [실제 크기] |
| 스크린 리더 | 호환 | ✅/❌ | [평가] |

---

## 4. 발견된 문제점

### 🔴 심각 (즉시 수정 필요)

[기능 중단, 기획 의도 위배, 접근성 실패, 빌드/런타임 오류]

1. **[문제점]**
   - 위치: [파일명:줄번호 또는 컴포넌트명]
   - 상세: [구체적 설명]
   - 영향: [사용자/시스템에 미치는 영향]
   - 수정 방법:
     ```
     [구체적인 수정 코드 또는 가이드]
     ```

### 🟡 중요 (수정 권장)

[명세 이탈, 인터랙션 상태 누락, 성능 문제, 에러 핸들링 미흡]

1. **[문제점]**
   - 위치: [위치]
   - 상세: [설명]
   - 수정 방법:
     ```
     [수정 가이드]
     ```

### 🟢 경미 (개선 제안)

[시각적 차이, 코드 스타일, 엣지 케이스, 최적화 기회]

1. **[문제점]**
   - 위치: [위치]
   - 개선 방법: [간단한 가이드]

---

## 5. 수정 우선순위

### 1순위 (즉시 수정)
- [ ] [심각 문제 1]
- [ ] [심각 문제 2]

### 2순위 (가능한 빨리)
- [ ] [중요 문제 1]
- [ ] [중요 문제 2]

### 3순위 (여유 있을 때)
- [ ] [경미 문제 1]
- [ ] [경미 문제 2]

---

## 6. 종합 평가

**점수:** [0-100점]

**평가 기준:**
- 기획 의도 충족: [점수/40]
- 명세 준수: [점수/30]
- 코드 품질: [점수/20]
- 접근성: [점수/10]

**최종 판정:**
- ✅ **승인**: 문제없음, 바로 배포 가능
- ⚠️ **조건부 승인**: 경미한 문제만 있음, 배포 가능하나 개선 권장
- ❌ **재작업 필요**: 심각/중요 문제 있음, 수정 후 재검증 필요

**종합 의견:**
[전반적인 평가 및 권장사항]

---

## 7. 다음 단계

**문제 없는 경우:**
1. ✅ 구현 완료 확인
2. Component Registry 최종 업데이트 확인
3. 다른 화면/기능으로 진행 가능

**수정 필요한 경우:**
1. 위의 수정 사항 적용
2. 수정 후 Phase 3 재검증 요청
3. 또는 특정 부분만 재검증 요청 가능

**질문/지원 필요:**
- 수정 방법이 불명확한 부분이 있으면 질문해주세요
- 추가 구현 가이드가 필요하면 요청해주세요
```

### Step 5: Provide Specific Fix Guidance

**For each issue found, provide actionable fix:**

**Critical/Major issues:**
```markdown
### 수정 가이드: [문제명]

**현재 코드:**
```[language]
[문제가 있는 코드]
```

**수정된 코드:**
```[language]
[올바른 코드]
```

**설명:**
[왜 이렇게 수정해야 하는지]

**참고:**
- Implementation Guide의 [섹션명] 참조
- Design System 토큰: [토큰명] = [값]
```

### Step 6: Handle Re-verification

If user fixes issues and requests re-verification:

**Load:**
- Previous verification report
- Updated code

**Process:**
- Focus ONLY on previously identified issues
- Check if fixes are correct
- Look for any new issues introduced by fixes

**Output:**
```markdown
# 재검증 보고서

## 이전 문제점 수정 확인

| 문제점 | 이전 상태 | 수정 확인 | 비고 |
|-------|----------|----------|------|
| [문제 1] | ❌ | ✅/❌ | [평가] |
| [문제 2] | ❌ | ✅/❌ | [평가] |

## 새로 발견된 문제점
[있는 경우만]

## 최종 판정
[승인/조건부 승인/재작업 필요]
```

## Output Language Rule

**CRITICAL: All user-facing output MUST be in Korean.**

### Korean Output (사용자 대면):
- ✅ Verification Report
- ✅ Issue descriptions
- ✅ Fix guidance
- ✅ Evaluation comments
- ✅ Questions to user
- ✅ Next steps

### English OK (Internal):
- ✅ Code examples
- ✅ Technical terms in code
- ✅ Framework-specific terminology
- ✅ Internal processing notes

## Quality Checklist

✅ **Completeness:**
- All three levels verified (Intent, Spec, Code Quality)
- Every component checked
- All interactive states verified
- Accessibility fully checked

✅ **Accuracy:**
- Compared against Proposal and Implementation Guide
- No assumptions beyond provided specs
- Specific line numbers/locations for issues

✅ **Actionability:**
- Every issue has fix guidance
- Code examples for complex fixes
- Clear priority ordering

✅ **Language:**
- All user-facing content in Korean
- Code examples can have English comments
- Technical terms translated where appropriate

## Edge Cases

### Code not provided, only screenshots:
```
스크린샷으로는 [X] 검증이 어렵습니다.
보다 정확한 검증을 위해 코드 파일을 공유해주시겠어요?

현재 스크린샷으로 확인 가능한 부분:
- 시각적 요소 일치 여부
- 레이아웃 구조

확인 불가능한 부분:
- 인터랙션 상태 구현
- 코드 품질
- 접근성 속성
```

### Partial implementation:
```
현재 [X] 부분만 구현되었습니다.

구현된 부분 검증:
[검증 결과]

미구현 부분:
- [항목 1]
- [항목 2]

전체 구현 완료 후 재검증을 권장합니다.
```

### Implementation differs intentionally:
```
구현이 명세와 다릅니다. 의도적인 변경인가요?

차이점:
- 명세: [값]
- 구현: [값]

의도적이라면 이유를 설명해주시면 Improvement Proposal을 업데이트하겠습니다.
아니라면 명세대로 수정을 권장합니다.
```

### Framework/platform mismatch:
```
Implementation Guide는 [Framework A]용인데 
구현은 [Framework B]로 되어있습니다.

현재 구현 기준으로 검증하되, 
가능하면 [Framework B]용 가이드를 새로 제공할 수 있습니다.
```

## Success Criteria

Phase 3 succeeds when:
- ✅ Complete verification report created (in Korean)
- ✅ All three levels checked (Intent, Spec, Code Quality)
- ✅ Issues categorized by severity
- ✅ Specific fix guidance provided
- ✅ Clear next steps communicated
- ✅ User understands what needs to be done

## Automation Potential

**For future enhancement:**
- Automated lint/build checks
- Automated accessibility testing
- Visual regression testing
- Performance benchmarking

**Currently:**
- Manual verification based on provided code/screenshots
- Focus on design intent and specification compliance
