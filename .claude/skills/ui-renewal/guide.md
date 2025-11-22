# UI Renewal Skill v4.0 - 사용 가이드

## 주요 업데이트 (v4.0)

✅ **통일된 프로젝트 관리 구조**
- `projects/` 기반 화면별 디렉토리 구조
- 표준화된 명명 규칙: `{YYYYMMDD}-{type}-v{N}.md`
- 프로젝트별 메타데이터 관리 (metadata.json)
- 전체 프로젝트 현황 추적 (INDEX.md)

✅ **Phase 3 4단계 프로세스 (완전 재설계)**
- Step 1: Initial Verification (검증)
- Step 2: Revision Loop (수정 루프)
- Step 3: Final Confirmation (사용자 최종 확인)
- Step 4: Asset Organization (에셋 정리 자동화)

✅ **Component Registry 관리 자동화**
- 3곳 동기화: Design System, registry.json, COMPONENTS.md
- 자동화 스크립트: update_component_registry.py
- Phase 2A에서 재사용 가능 컴포넌트 자동 탐색

✅ **프로젝트 인덱스 자동 생성**
- INDEX.md 자동 생성: generate_project_index.py
- 컴포넌트 재사용 통계 자동 계산
- Active/Completed Projects 관리

---

## 전체 워크플로우

```
Phase 1: Design System 생성
   ↓
[사용자 승인 + 파일 저장]
   ↓
Phase 2A: 분석 및 방향 도출
   ↓ (Component Registry 확인 → 재사용 가능 컴포넌트 탐색)
   ↓ (Proposal 작성 → projects/{screen-name}/{date}-proposal-v1.md 저장)
   ↓
[사용자 방향 승인]
   ↓
Phase 2B: 구현 명세 작성
   ↓ (Implementation 작성 → projects/{screen-name}/{date}-implementation-v1.md 저장)
   ↓ (Component 생성 → Component Registry 업데이트)
   ↓
[사용자 구현]
   ↓
Phase 3 Step 1: Initial Verification
   ↓ (검증 → Verification Report 생성 → projects/{screen-name}/{date}-verification-v1.md 저장)
   ↓
Phase 3 Step 2: Revision Loop (이슈 발견 시)
   ↓ (수정 → 재검증 → v2, v3... 버전 증가)
   ↓
Phase 3 Step 3: Final Confirmation
   ↓ ("완료" / "수정 필요" / "다음 화면")
   ↓
Phase 3 Step 4: Asset Organization (사용자 "완료" 확인 후)
   ↓ (Registry 동기화 → metadata.json 업데이트 → INDEX.md 업데이트)
   ↓
[완료 또는 다음 화면으로 → Phase 2A]
```

---

## 디렉토리 구조

```
.claude/skills/ui-renewal/
├── SKILL.md                          # 오케스트레이터
│
├── design-systems/                   # Design System 파일
│   ├── gabium-design-system.md
│   └── design-tokens.app_theme.dart  # 내보낸 토큰
│
├── projects/                         # 화면별 작업 디렉토리 ⭐
│   ├── INDEX.md                      # 전체 프로젝트 현황
│   │
│   ├── email-signup-screen/
│   │   ├── metadata.json             # 프로젝트 메타데이터
│   │   ├── 20251122-proposal-v1.md
│   │   ├── 20251122-implementation-v1.md
│   │   └── 20251123-verification-v2.md
│   │
│   ├── email-signin-screen/
│   │   ├── metadata.json
│   │   ├── 20251122-proposal-v1.md
│   │   └── 20251122-implementation-v1.md
│   │
│   └── password-reset-screen/
│       ├── metadata.json
│       └── 20251123-proposal-v1.md
│
├── component-library/                # 재사용 가능 컴포넌트
│   ├── COMPONENTS.md                 # 컴포넌트 문서
│   ├── registry.json                 # 컴포넌트 메타데이터
│   │
│   ├── flutter/
│   │   ├── AuthHeroSection.dart
│   │   ├── GabiumTextField.dart
│   │   ├── GabiumButton.dart
│   │   └── GabiumToast.dart
│   │
│   ├── react/
│   │   └── (React 컴포넌트들)
│   │
│   └── vue/
│       └── (Vue 컴포넌트들)
│
├── references/                       # Phase별 가이드
│   ├── phase1-design-system.md
│   ├── phase2a-analysis.md
│   ├── phase2b-implementation.md
│   └── phase3-verification.md
│
└── scripts/                          # 자동화 스크립트
    ├── export_design_tokens.py
    ├── update_component_registry.py  ⭐ NEW
    └── generate_project_index.py     ⭐ NEW
```

---

## 문서 명명 규칙

### 형식
```
{YYYYMMDD}-{document-type}-v{version}.md
```

### 문서 타입
- `proposal`: Improvement Proposal (Phase 2A)
- `implementation`: Implementation Specification (Phase 2B)
- `verification`: Verification Report (Phase 3)

### 예시
```
20251122-proposal-v1.md          # 2025년 11월 22일, 제안서 버전 1
20251122-proposal-v2.md          # 같은 날 수정 시 버전 증가
20251122-implementation-v1.md    # 구현 가이드
20251123-verification-v1.md      # 다음 날 검증
20251123-verification-v2.md      # 재검증
```

### 저장 위치
```
projects/{screen-name}/{YYYYMMDD}-{type}-v{N}.md
```

---

## 각 Phase 상세 설명

### Phase 1: Design System 생성

**목적:** 전체 제품의 디자인 기반 확립

**입력:**
- 브랜드 정보 (로고, 컬러, 가이드라인)
- 제품 목표 (타겟 사용자, 산업, 포지셔닝)
- 현재 UI 샘플

**과정:**
1. 브랜드 분석
2. Design System 생성
   - 색상 체계
   - 타이포그래피
   - 간격 및 크기
   - 핵심 컴포넌트
3. 제안서 작성 (한글)
4. 사용자 승인

**출력:**
- Design System artifact
- **파일 저장**: `./design-systems/[제품명]-design-system.md`
- Component Registry 초기화
- **디자인 토큰 내보내기** (선택): `./design-systems/design-tokens.*`

**예시:**
```
사용자: "헬스케어 앱 '가비움' 디자인 시스템 만들어줘. 밝은 녹색, 신뢰감 있고 친근한 느낌."

AI: 가비움 디자인 시스템을 생성하겠습니다.

[Design System 생성]

주요 디자인 결정:
- Primary 컬러: 밝은 녹색(#4ADE80) - 생기와 친근함
- Typography: Pretendard Variable - 한글 가독성과 현대적 느낌
- Border Radius: 중간 크기(8px) - 부드럽고 친근한 느낌

[전체 Design System artifact 제공]

✅ 디자인 시스템이 승인되었습니다!

저장 위치: ./design-systems/gabium-design-system.md

디자인 토큰을 Flutter ThemeData로 내보낼까요?
```

---

### Phase 2A: 분석 및 방향 도출

**목적:** 개선 방향 결정 (구현 전)

**입력:**
- Design System
- 현재 UI (스크린샷 또는 코드)
- 개선 요구사항

**과정:**
1. Design System 로드
2. 의존성 분석
   - 선행 작업 필요성 체크
   - 영향받는 화면 파악
3. **Component Registry 확인** ⭐
   - Design System Section 7
   - registry.json
   - COMPONENTS.md
   - 재사용 가능한 컴포넌트 탐색
4. 현재 UI 분석
   - 브랜드 일관성
   - 시각적 품질
   - UX 품질
5. 개선 방향 도출
6. Design System 토큰 매핑
7. **Proposal 저장**: `projects/{screen-name}/{date}-proposal-v1.md`
8. **metadata.json 생성/업데이트**

**출력:**
- **Improvement Proposal artifact**
  - 변경사항 목록
  - 각 변경의 근거
  - Design System Token Reference 테이블
  - 의존성 및 영향 범위
  - **재사용 가능한 컴포넌트 목록**

**예시:**
```
사용자: "이메일 회원가입 화면 개선해줘 [코드 첨부]"

AI: 이메일 회원가입 화면을 분석하겠습니다.

✅ 재사용 가능한 컴포넌트 확인 중...
   - Component Registry에 등록된 컴포넌트 없음
   - 새로운 컴포넌트 6개 필요

[분석 결과]

발견된 문제:
1. 브랜드 아이덴티티 부족 - Primary 컬러 미사용
2. 입력 필드 일관성 없음 - 다양한 스타일 혼재
3. 비밀번호 강도 표시 없음 - UX 개선 필요

제안하는 변경사항:
1. Hero Section 추가
   - Component: AuthHeroSection (NEW)
   - 브랜드 강조 및 환영 메시지

2. 통일된 입력 필드
   - Component: GabiumTextField (NEW)
   - Design System 토큰 사용

3. 비밀번호 강도 인디케이터
   - Component: PasswordStrengthIndicator (NEW)
   - 실시간 피드백

[전체 Improvement Proposal artifact 제공]

저장 위치: projects/email-signup-screen/20251122-proposal-v1.md

승인하시겠어요?
```

---

### Phase 2B: 구현 명세 작성

**목적:** 정확한 구현 스펙 제공

**입력:**
- Improvement Proposal (승인됨)
- Proposal의 Token Reference 테이블

**과정:**
1. Proposal 기준으로 상세 스펙 작성
2. 컴포넌트별 완전한 명세
3. 레이아웃 구조 정의
4. 인터랙션 동작 명세
5. 프레임워크별 코드 예시
6. **컴포넌트 저장**: `./component-library/[framework]/[Component].[ext]`
7. **Component Registry 업데이트** (자동화 스크립트)
8. **Implementation 저장**: `projects/{screen-name}/{date}-implementation-v1.md`
9. **metadata.json 업데이트**

**출력:**
- **Implementation Guide artifact**
  - 완전한 컴포넌트 스펙
  - 정확한 값 (px, hex 등)
  - 모든 인터랙션 상태
  - Flutter/React/Vue 코드
  - 접근성 체크리스트
- **컴포넌트 파일 저장**
- **Component Registry 업데이트** (3곳)

**자동화 스크립트 사용:**
```bash
python .claude/skills/ui-renewal/scripts/update_component_registry.py \
  --component "AuthHeroSection" \
  --framework "flutter" \
  --used-in "email-signup-screen" \
  --category "Authentication" \
  --description "Hero section with welcome message"
```

**예시:**
```
AI: 승인된 제안을 기반으로 구현 가이드를 작성하겠습니다.

[Implementation Guide 생성]

산출물:
✅ 전체 컴포넌트 명세 (6개)
✅ 레이아웃 구조 상세
✅ 인터랙션 동작 정의
✅ Flutter 구현 코드
✅ 접근성 체크리스트
✅ Component Registry 업데이트 완료

생성된 컴포넌트:
- AuthHeroSection (flutter/auth_hero_section.dart)
- GabiumTextField (flutter/gabium_text_field.dart)
- GabiumButton (flutter/gabium_button.dart)
- PasswordStrengthIndicator (flutter/password_strength_indicator.dart)
- ConsentCheckbox (flutter/consent_checkbox.dart)
- GabiumToast (flutter/gabium_toast.dart)

저장 위치:
- 구현 가이드: projects/email-signup-screen/20251122-implementation-v1.md
- 컴포넌트: component-library/flutter/

구현을 시작하세요. 완료 후 Phase 3 검증을 요청해주세요.
```

---

### Phase 3: 검증, 수정, 확인 및 정리 (4단계 프로세스)

#### Step 1: Initial Verification

**목적:** 구현 코드 검증

**입력:**
- Improvement Proposal (기획 의도)
- Implementation Guide (명세)
- 사용자의 구현 코드

**과정:**
1. 기획 의도 충족도 검증
2. 명세 준수도 확인
3. 코드 품질 검사 (lint/build)
4. 접근성 검증 (WCAG AA)
5. 이슈 분류 (Critical/Major/Minor)
6. **Verification Report 생성** (한글)
7. **저장**: `projects/{screen-name}/{date}-verification-v1.md`

**출력:**
- **검증 보고서 (한글)**
  - 검증 결과 요약
  - 발견된 문제점
  - 구체적 수정 방법
  - 종합 평가 및 판정

**판정:**
- ✅ **PASS**: 문제없음 → Step 3으로
- ❌ **FAIL**: 수정 필요 → Step 2로

**예시:**
```
사용자: "구현 완료했어. 검증해줘 [코드 첨부]"

AI: 구현하신 코드를 검증하겠습니다.

# 이메일 회원가입 화면 검증 보고서

**검증일**: 2025-11-22
**상태**: ✅ PASS

## 검증 결과 요약

- 디자인 의도 준수: ✅
- 명세 준수: ✅
- 코드 품질: ✅
- 접근성: ✅
- 기능성: ✅

## 발견된 문제점

없음 - 모든 항목 통과!

저장 위치: projects/email-signup-screen/20251122-verification-v1.md

✅ 검증을 통과했습니다!

구현이 완료되었습니까? 수정할 부분이 있습니까?
(Step 3: Final Confirmation으로 진행합니다)
```

---

#### Step 2: Revision Loop

**목적:** 발견된 이슈 수정

**과정:**
1. 사용자가 이슈 수정
2. 재검증 요청
3. 이전 보고서 기준으로 재검증
4. **새 Verification Report 생성** (버전 증가)
5. **저장**: `projects/{screen-name}/{date}-verification-v2.md`
6. PASS까지 반복

**예시:**
```
AI: 검증 완료. 수정이 필요한 부분이 있습니다.

### Critical Issues (필수 수정)

1. **입력 필드 간격 불일치**
   - 위치: email_signup_screen.dart:45
   - 현재: 16.0 사용
   - 기대: 24.0 (Design System lg spacing)
   - 수정방법: SizedBox(height: 24.0)

수정 후 재검증을 요청해주세요.

---

[사용자 수정 후]

사용자: "수정했어. 다시 검증해줘"

AI: 재검증하겠습니다.

✅ 검증 통과!

저장 위치: projects/email-signup-screen/20251122-verification-v2.md

구현이 완료되었습니까?
```

---

#### Step 3: Final Confirmation

**목적:** 사용자 최종 확인

**과정:**
1. Agent가 사용자에게 확인 요청
2. 사용자 응답 대기

**사용자 옵션:**
1. **"완료"** → Step 4 (Asset Organization)로
2. **"수정 필요"** → Step 1로 돌아감
3. **"다음 화면"** → Step 4 후 Phase 2A로

**예시:**
```
AI: ✅ 검증을 통과했습니다!

구현이 완료되었습니까? 수정할 부분이 있습니까?

- "완료" → 프로젝트를 마무리하고 에셋을 정리하겠습니다
- "수정 필요" → 어떤 부분을 수정하실지 알려주세요

사용자: "완료"

AI: 프로젝트를 마무리하겠습니다.
(Step 4: Asset Organization으로 진행)
```

---

#### Step 4: Asset Organization

**목적:** 모든 에셋 정리 및 재사용 준비

**과정:**
1. **Component Registry 동기화** (3곳)
   - Design System Section 7
   - registry.json
   - COMPONENTS.md
2. **metadata.json 업데이트**
   - status: "completed"
   - components 목록
   - 문서 버전 추적
3. **INDEX.md 업데이트**
   - Active → Completed Projects로 이동
   - 통계 자동 갱신
4. 최종 요약 제공

**자동화 실행:**
```bash
# Component Registry 업데이트 (각 컴포넌트마다)
python scripts/update_component_registry.py --component "AuthHeroSection" ...

# INDEX.md 재생성
python scripts/generate_project_index.py
```

**예시:**
```
AI: 🎉 email-signup-screen 프로젝트가 완료되었습니다!

생성된 파일:
- 📄 개선 제안서: projects/email-signup-screen/20251122-proposal-v1.md
- 📄 구현 가이드: projects/email-signup-screen/20251122-implementation-v1.md
- 📄 검증 보고서: projects/email-signup-screen/20251122-verification-v2.md
- 📄 프로젝트 메타데이터: projects/email-signup-screen/metadata.json

생성된 컴포넌트 (6개):
- AuthHeroSection (component-library/flutter/auth_hero_section.dart)
- GabiumTextField (component-library/flutter/gabium_text_field.dart)
- GabiumButton (component-library/flutter/gabium_button.dart)
- PasswordStrengthIndicator (component-library/flutter/password_strength_indicator.dart)
- ConsentCheckbox (component-library/flutter/consent_checkbox.dart)
- GabiumToast (component-library/flutter/gabium_toast.dart)

✅ Component Registry 업데이트 완료 (3곳 동기화)
✅ metadata.json 생성 완료
✅ INDEX.md 업데이트 완료

다음 단계:
- 다른 화면/기능 개선? (→ Phase 2A로)
- 디자인 토큰 내보내기?
- 세션 종료?
```

---

## 프로젝트 메타데이터 (metadata.json)

### 형식
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
    },
    {
      "type": "verification",
      "version": 2,
      "date": "2025-11-22",
      "file": "20251122-verification-v2.md"
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
  "status": "completed",
  "completedDate": "2025-11-22",
  "iterations": 2
}
```

---

## 프로젝트 인덱스 (INDEX.md)

### 자동 생성
```bash
python scripts/generate_project_index.py
```

### 내용
- Active Projects 테이블
- Completed Projects 테이블
- Summary Statistics
- Component Reusability Matrix

### 예시
```markdown
# UI Renewal Projects Index

**Last Updated**: 2025-11-22

## Active Projects

| Screen/Feature | Framework | Status | Last Updated | Documents |
|---------------|-----------|--------|--------------|-----------|
| Password Reset Screen | Flutter | 🔄 In Progress | 2025-11-23 | [Proposal](password-reset-screen/20251123-proposal-v1.md) |

## Completed Projects

| Screen/Feature | Framework | Status | Last Updated | Documents | Components |
|---------------|-----------|--------|--------------|-----------|------------|
| Email Signup Screen | Flutter | ✅ Completed | 2025-11-22 | [Proposal](email-signup-screen/20251122-proposal-v1.md), [Implementation](email-signup-screen/20251122-implementation-v1.md) | 6 (AuthHeroSection, GabiumTextField, GabiumButton...) |
| Email Signin Screen | Flutter | ✅ Completed | 2025-11-22 | [Proposal](email-signin-screen/20251122-proposal-v1.md), [Implementation](email-signin-screen/20251122-implementation-v1.md) | 4 (AuthHeroSection, GabiumTextField, GabiumButton, GabiumToast) |

## Summary Statistics

- **Total Completed Projects**: 2
- **Total Components Created**: 6
- **Component Reuse Rate**: 67% (4/6 components reused in Email Signin)

## Component Reusability Matrix

| Component | Created In | Also Used In | Reuse Count |
|-----------|-----------|--------------|-------------|
| AuthHeroSection | Email Signup | Email Signin | 2 |
| GabiumTextField | Email Signup | Email Signin | 2 |
| GabiumButton | Email Signup | Email Signin | 2 |
| GabiumToast | Email Signup | Email Signin | 2 |
| PasswordStrengthIndicator | Email Signup | - | 1 |
| ConsentCheckbox | Email Signup | - | 1 |
```

---

## Component Registry 관리

### 3곳 동기화 ⭐

1. **Design System (Section 7)**
   ```markdown
   ## 7. Component Registry

   | Component | Created Date | Used In | Notes |
   |-----------|--------------|---------|-------|
   | AuthHeroSection | 2025-11-22 | Email Signup, Email Signin | Hero with title, subtitle, icon |
   ```

2. **registry.json**
   ```json
   {
     "components": [
       {
         "name": "AuthHeroSection",
         "framework": "flutter",
         "createdDate": "2025-11-22",
         "usedIn": ["email-signup-screen", "email-signin-screen"],
         "category": "Authentication",
         "file": "flutter/auth_hero_section.dart"
       }
     ]
   }
   ```

3. **COMPONENTS.md**
   ```markdown
   ## Component Registry

   | Component | Created Date | Used In | Framework | File | Notes |
   |-----------|--------------|---------|-----------|------|-------|
   | AuthHeroSection | 2025-11-22 | Email Signup, Email Signin | Flutter | `flutter/auth_hero_section.dart` | Hero section |
   ```

### 자동 업데이트 스크립트

```bash
python .claude/skills/ui-renewal/scripts/update_component_registry.py \
  --component "AuthHeroSection" \
  --framework "flutter" \
  --used-in "email-signup-screen" \
  --category "Authentication" \
  --description "Hero section with welcome message" \
  --file "flutter/auth_hero_section.dart"
```

**자동으로 3곳 모두 업데이트됩니다!**

---

## 자동화 스크립트

### 1. Component Registry 업데이트

```bash
python scripts/update_component_registry.py \
  --component "ComponentName" \
  --framework "flutter" \
  --used-in "screen-name" \
  --category "Form" \
  --description "Component description"
```

### 2. Project Index 생성

```bash
python scripts/generate_project_index.py
```

### 3. Design Token 내보내기

```bash
python scripts/export_design_tokens.py \
  ./design-systems/gabium-design-system.md \
  --format flutter
```

---

## 사용 시나리오

### 시나리오 1: 새 프로젝트 디자인 시스템 구축

```
1. "헬스케어 앱 '가비움' 디자인 시스템 만들어줘"
   → Phase 1 실행
   → Design System 생성 및 저장
   → 파일: design-systems/gabium-design-system.md
   → 토큰 내보내기: design-systems/design-tokens.app_theme.dart

2. "이메일 회원가입 화면 개선해줘"
   → Phase 2A: Component Registry 확인 (재사용 가능 컴포넌트 없음)
   → Phase 2A: Proposal 저장 (projects/email-signup-screen/20251122-proposal-v1.md)
   → Phase 2B: Implementation 저장 + 6개 컴포넌트 생성
   → Phase 2B: Component Registry 업데이트 (3곳)
   → 사용자 구현
   → Phase 3 Step 1: 검증
   → Phase 3 Step 3: 사용자 "완료" 확인
   → Phase 3 Step 4: 에셋 정리 (metadata.json, INDEX.md)
   → ✅ 완료

3. "이메일 로그인 화면도 개선해줘"
   → Phase 2A: Component Registry 확인
     ✅ 재사용 가능 컴포넌트 발견!
     - AuthHeroSection (Email Signup에서 생성)
     - GabiumTextField (Email Signup에서 생성)
     - GabiumButton (Email Signup에서 생성)
     - GabiumToast (Email Signup에서 생성)
   → Phase 2A: 4개 재사용, 신규 컴포넌트 0개
   → Phase 2B: 재사용 컴포넌트만 사용
   → 개발 시간 60% 단축! 🚀
   → Phase 3: 검증 및 완료
```

---

## 핵심 설계 원칙

### 1. Phase 분리를 통한 명확성
```
Phase 2A: WHAT (무엇을 바꿀지)
Phase 2B: HOW (어떻게 구현할지)
Phase 3 Step 1-2: VERIFY (제대로 되었는지)
Phase 3 Step 3: CONFIRM (사용자 최종 확인)
Phase 3 Step 4: ORGANIZE (에셋 정리)
```

### 2. 통일된 프로젝트 관리
- `projects/{screen-name}/` 구조
- 명명 규칙: `{YYYYMMDD}-{type}-v{N}.md`
- metadata.json으로 상태 추적
- INDEX.md로 전체 현황 파악

### 3. Component Registry 관리
- Phase 2A에서 확인 → 재사용 가능 컴포넌트 탐색
- Phase 2B에서 업데이트 → 새 컴포넌트 등록
- Phase 3 Step 4에서 최종 검증 → 3곳 동기화

### 4. 자동화
- Component Registry 자동 업데이트
- INDEX.md 자동 생성
- 통계 자동 계산

### 5. 한글 사용자 경험
모든 사용자 대면 출력은 한글로 제공

---

## 한글 출력 규칙

### 한글로 출력 (필수):
✅ 사용자 질문
✅ 설명 및 근거
✅ 제안 및 요약
✅ 경고 및 오류 메시지
✅ 다음 단계 안내
✅ **검증 보고서 전체**
✅ **Phase 3 Step 3 확인 메시지**
✅ **Phase 3 Step 4 완료 요약**

### 영어 허용:
✅ Artifact 내용 (기술 문서)
✅ 코드 예시
✅ 토큰명, 기술 용어
✅ CSS/스타일 코드

---

## 품질 게이트

각 Phase는 엄격한 품질 기준을 충족해야 다음 단계로 진행:

| Phase | 주요 검증 항목 | 통과 기준 |
|-------|--------------|---------|
| 1 | Design System 완성도 | 모든 값 구체화, 파일 저장, 사용자 승인 |
| 2A | 토큰 매핑, Registry 확인 | 재사용 컴포넌트 탐색, Proposal 저장, 사용자 승인 |
| 2B | 명세 완전성, Registry 업데이트 | 모든 상태 정의, 컴포넌트 저장, Implementation 저장 |
| 3-1 | 구현 품질 | 기획/명세 충족, 코드 품질, Verification Report 저장 |
| 3-2 | 수정 완료 | 모든 이슈 해결, 재검증 통과 |
| 3-3 | 사용자 확인 | 명시적 "완료" 응답 |
| 3-4 | 에셋 정리 | Registry 동기화, metadata.json, INDEX.md 업데이트 |

---

## 기대 효과

✅ **품질 보장**
- Phase 3 4단계 프로세스를 통한 철저한 검증
- 사용자 최종 확인 후에만 완료 처리
- 모든 에셋 자동 정리 및 재사용 준비

✅ **재사용성 극대화** ⭐
- Component Registry 자동 관리
- Phase 2A에서 자동 탐색
- 컴포넌트 재사용으로 개발 시간 30-70% 단축

✅ **프로젝트 관리**
- 화면별 디렉토리 구조
- metadata.json으로 상태 추적
- INDEX.md로 전체 현황 파악

✅ **명확한 책임 분리**
- 분석 → 명세 → 구현 → 검증 → 확인 → 정리
- 각 단계의 목적이 명확

✅ **자동화**
- Component Registry 자동 업데이트
- INDEX.md 자동 생성
- 통계 자동 계산

✅ **한글 사용자 경험**
- 일관된 한글 커뮤니케이션
- 기술 문서와 사용자 대면 구분

---

## 버전 히스토리

**v4.0 (현재)** ⭐
- 통일된 프로젝트 관리 구조 (projects/ 기반)
- 표준화된 명명 규칙 ({YYYYMMDD}-{type}-v{N}.md)
- Phase 3 4단계 프로세스 (검증→수정→확인→정리)
- Component Registry 관리 자동화 (3곳 동기화)
- 프로젝트 인덱스 자동 생성 (INDEX.md)
- metadata.json 프로젝트 메타데이터 관리
- 자동화 스크립트: update_component_registry.py, generate_project_index.py

**v3.1**
- 파일 관리 시스템 추가
- 컴포넌트 라이브러리 관리

**v3.0**
- Phase 3: 검증 및 품질 체크 추가
- 한글 출력 규칙 적용

**v2.0**
- Phase 2를 2A/2B로 분리
- 컨텍스트 효율성 극대화

**v1.0**
- Phase 1, 2 기본 구현
- Design System 기반 개선

---

## 설치 및 사용

1. ui-renewal skill이 Claude Code에 설치되어 있는지 확인
2. "디자인 시스템 만들어줘" 또는 "UI 개선해줘"로 시작
3. Skill이 자동으로 적절한 Phase 선택 및 진행
4. Phase 3 Step 3에서 반드시 "완료" 확인
5. Phase 3 Step 4에서 모든 에셋이 자동으로 정리됨

---

**이 skill은 체계적인 UI 개선, 컴포넌트 재사용, 품질 보장을 위한 완벽한 워크플로우를 제공합니다.**
