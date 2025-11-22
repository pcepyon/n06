# UI Renewal Skill v3.1 - 사용 가이드

## 주요 업데이트 (v3.1)

✅ **파일 관리 시스템 추가**
- Design System을 실제 .md 파일로 자동 저장
- 컴포넌트 코드를 라이브러리에 저장 및 관리
- 재사용 가능한 컴포넌트 검색 및 활용

✅ **컴포넌트 라이브러리**
- 생성된 모든 컴포넌트 자동 저장
- 프레임워크별 분류 (React/Flutter/Vue)
- 컴포넌트 검색 및 재사용
- 자동 문서화 (COMPONENTS.md)

## 전체 워크플로우

```
Phase 1: Design System 생성
   ↓
[사용자 승인]
   ↓
Phase 2A: 분석 및 방향 도출
   ↓
[사용자 방향 승인]
   ↓
Phase 2B: 구현 명세 작성
   ↓
[사용자 구현]
   ↓
Phase 3: 검증 및 품질 체크
   ↓
[통과: 완료 / 실패: 수정 후 재검증]
   ↓
[다음 화면 → Phase 2A로...]
```

## 각 Phase 설명

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
- **Design System 파일 저장: `./design-systems/[제품명]-design-system.md`**
- Component Registry 초기화
- **디자인 토큰 내보내기 (선택): `./design-systems/design-tokens.*`**

**예시:**
```
사용자: "헬스케어 앱 디자인 시스템 만들어줘. 타겟은 30-40대 여성."

AI: 디자인 시스템을 생성하겠습니다.

[Design System 생성]

주요 디자인 결정:
- Primary 컬러: 차분한 블루(#2E5C8A) - 신뢰감 전달
- Typography: Open Sans - 친근하고 전문적
- Border Radius: 중간 크기(8px) - 부드러운 느낌

[전체 Design System artifact 제공]

✅ 디자인 시스템이 승인되었습니다!

저장 위치: ./design-systems/healthcare-app-design-system.md

디자인 토큰을 내보낼까요? (JSON/CSS/Tailwind/Flutter)
```

---

### Phase 2A: 분석 및 방향 도출

**목적:** 개선 방향 결정 (구현 전)

**입력:**
- Design System
- 현재 UI (스크린샷 또는 코드)
- 개선 요구사항

**과정:**
1. 의존성 분석
   - 선행 작업 필요성 체크
   - 영향받는 화면 파악
2. **컴포넌트 라이브러리 검색**
   - 재사용 가능한 컴포넌트 확인
   - `python scripts/manage_components.py list`
3. Component Registry 체크
4. 현재 UI 분석
   - 브랜드 일관성
   - 시각적 품질
   - UX 품질
5. 개선 방향 도출
6. Design System 토큰 매핑

**출력:**
- **Improvement Proposal artifact**
  - 변경사항 목록
  - 각 변경의 근거
  - Design System Token Reference 테이블
  - 의존성 및 영향 범위

**예시:**
```
사용자: "로그인 화면 개선해줘 [스크린샷]"

AI: 로그인 화면을 분석하겠습니다.

[분석 결과]

발견된 문제:
1. CTA 버튼이 너무 작고 강조가 약함
2. 입력 필드 간격이 불규칙함
3. 에러 메시지가 보이지 않음

제안하는 변경사항:
1. CTA 버튼 강조
   - Component: Button - Primary, Large
   - Color: Primary (#2E5C8A)
   - Size: 48px height
   
2. 입력 필드 간격 조정
   - Spacing: lg (24px)
   
3. 에러 메시지 위치 개선
   - 입력 필드 바로 아래 배치
   - Color: Error (#DC2626)

[전체 Improvement Proposal artifact 제공]

승인하시겠어요?
```

---

### Phase 2B: 구현 명세 작성

**목적:** 정확한 구현 스펙 제공

**입력:**
- Improvement Proposal (승인됨)
- Proposal의 Token Reference 테이블

**컨텍스트 최적화:**
```
✅ 로드: Improvement Proposal
✅ 로드: Token Reference의 토큰만
❌ 로드 안함: Design System 전체
❌ 로드 안함: 원본 UI
❌ 로드 안함: 분석 노트
```

**과정:**
1. Proposal 기준으로 상세 스펙 작성
2. 컴포넌트별 완전한 명세
3. 레이아웃 구조 정의
4. 인터랙션 동작 명세
5. 프레임워크별 코드 예시
6. **컴포넌트를 라이브러리에 저장**
   - `./component-library/[framework]/[Component].[ext]`
   - `python scripts/manage_components.py add`
7. Component Registry 업데이트

**출력:**
- **Implementation Guide artifact**
  - 완전한 컴포넌트 스펙
  - 정확한 값 (px, hex 등)
  - 모든 인터랙션 상태
  - React/Flutter/Vue 코드
  - 접근성 체크리스트
- **컴포넌트 파일 저장**
  - `./component-library/react/[Component].jsx`
  - `./component-library/flutter/[Component].dart`
  - `./component-library/vue/[Component].vue`
- **컴포넌트 문서**
  - `./component-library/COMPONENTS.md` (자동 생성)

**예시:**
```
AI: 승인된 제안을 기반으로 구현 가이드를 작성하겠습니다.

[Implementation Guide 생성]

산출물:
✅ 전체 컴포넌트 명세
✅ 레이아웃 구조 상세
✅ 인터랙션 동작 정의
✅ React 구현 코드
✅ 접근성 체크리스트

### CTA 버튼 명세
- 배경색: #2E5C8A
- 텍스트: 16px, Regular, White
- 패딩: 16px 좌우, 12px 상하
- Border Radius: 4px
- Shadow: 0 2px 4px rgba(0,0,0,0.08)

상태:
- Hover: #254A6E
- Active: #1C3952
- Disabled: opacity 0.4

[React 코드 예시]
[Flutter 코드 예시]

구현을 시작하세요. 완료 후 Phase 3 검증을 요청해주세요.
```

---

### Phase 3: 검증 및 품질 체크 ⭐ NEW

**목적:** 구현 품질 보장

**입력:**
- Improvement Proposal (기획 의도)
- Implementation Guide (명세)
- 사용자의 구현 코드

**과정:**
1. **기획 의도 충족도 검증**
   - Success Criteria 달성 확인
   - 각 변경사항 의도 검증

2. **명세 준수도 확인**
   - 컴포넌트 스펙 일치 확인
   - 레이아웃 구조 검증
   - 인터랙션 상태 확인

3. **코드 품질 검사**
   - 린트 오류 체크
   - 빌드 오류 확인
   - 하드코딩 여부 (토큰 사용)
   - 코드 구조

4. **접근성 검증**
   - 색상 대비 (WCAG AA)
   - 키보드 네비게이션
   - ARIA 레이블
   - 터치 타겟 크기

**출력:**
- **검증 보고서 (한글)**
  - 기획 의도 충족도
  - 명세 준수도
  - 발견된 문제점 (심각/중요/경미)
  - 구체적 수정 방법
  - 종합 평가 및 판정

**판정:**
- ✅ **승인**: 문제없음, 배포 가능
- ⚠️ **조건부 승인**: 경미한 문제, 개선 권장
- ❌ **재작업 필요**: 수정 후 재검증

**예시:**
```
사용자: "구현 완료했어. 검증해줘 [코드 첨부]"

AI: 구현하신 코드를 검증하겠습니다.

# 로그인 화면 검증 보고서

## 검증 개요
전체 평가: ⚠️ 수정 필요

## 1. 기획 의도 충족도

| 성공 기준 | 달성 여부 | 평가 |
|----------|----------|------|
| CTA 버튼 강조 | ✅ | 크기와 색상 모두 정확히 구현 |
| 입력 필드 간격 | ❌ | 16px 사용됨 (명세: 24px) |
| 에러 메시지 표시 | ✅ | 위치와 색상 정확 |

## 2. 명세 준수도

### CTA 버튼
| 항목 | 명세 | 구현 | 일치 |
|-----|------|------|------|
| 배경색 | #2E5C8A | #2E5C8A | ✅ |
| 높이 | 48px | 48px | ✅ |
| Hover 상태 | ✅ | ❌ | 미구현 |

## 3. 코드 품질

✅ 빌드 성공
⚠️ ESLint 경고 1개
✅ 토큰 사용 (하드코딩 없음)
❌ Hover 상태 누락

## 4. 발견된 문제점

### 🟡 중요 (수정 권장)

1. **입력 필드 간격 불일치**
   - 위치: LoginForm.jsx:45
   - 상세: margin-bottom: 16px 사용됨
   - 수정 방법:
     ```jsx
     // 현재
     <input style={{ marginBottom: '16px' }} />
     
     // 수정
     <input style={{ marginBottom: '24px' }} />  // lg spacing
     ```

2. **버튼 Hover 상태 누락**
   - 위치: Button.css:12
   - 수정 방법:
     ```css
     .primary-button:hover {
       background: #254A6E;
     }
     ```

### 🟢 경미

1. **ESLint 경고**
   - 사용하지 않는 import 제거 권장

## 5. 수정 우선순위

1순위:
- [ ] 입력 필드 간격 수정 (16px → 24px)
- [ ] 버튼 Hover 상태 추가

2순위:
- [ ] ESLint 경고 해결

## 6. 종합 평가

점수: 85/100
- 기획 의도 충족: 32/40
- 명세 준수: 24/30
- 코드 품질: 19/20
- 접근성: 10/10

최종 판정: ⚠️ **조건부 승인**
중요 문제 2개 수정 후 재검증을 권장합니다.

## 다음 단계
1. 위의 수정사항 적용
2. 재검증 요청
```

---

## Skill 구조

```
ui-renewal.skill
├── SKILL.md                          # 오케스트레이터
├── references/
│   ├── phase1-design-system.md
│   ├── phase2a-analysis.md
│   ├── phase2b-implementation.md
│   └── phase3-verification.md       # NEW
├── scripts/
│   └── export_design_tokens.py
└── assets/
    └── design-system-template.md
```

## 핵심 설계 원칙

### 1. Phase 분리를 통한 명확성
```
Phase 2A: WHAT (무엇을 바꿀지)
Phase 2B: HOW (어떻게 구현할지)
Phase 3: VERIFY (제대로 되었는지)
```

### 2. 컨텍스트 효율성
각 Phase는 필요한 최소한의 컨텍스트만 로드
- Phase 2B: Proposal의 Token Reference만
- Phase 3: Proposal + Implementation Guide만

### 3. Single Source of Truth
- Phase 2B → Improvement Proposal 기준
- Phase 3 → Proposal + Implementation Guide 기준

### 4. 한글 사용자 경험
모든 사용자 대면 출력은 한글로 제공

## 한글 출력 규칙

### 한글로 출력 (필수):
✅ 사용자 질문
✅ 설명 및 근거
✅ 제안 및 요약
✅ 경고 및 오류 메시지
✅ 다음 단계 안내
✅ **검증 보고서 전체**

### 영어 허용:
✅ Artifact 내용 (기술 문서)
✅ 코드 예시
✅ 토큰명, 기술 용어
✅ CSS/스타일 코드

## 사용 시나리오

### 시나리오 1: 새 프로젝트 디자인 시스템 구축

```
1. "헬스케어 앱 디자인 시스템 만들어줘"
   → Phase 1 실행
   → Design System artifact 생성
   → 파일 저장: ./design-systems/healthcare-app-design-system.md
   → 토큰 내보내기: ./design-systems/design-tokens.json
   → 승인

2. "로그인 화면 만들어줘"
   → Phase 2A: 분석 및 제안
   → Phase 2B: 구현 가이드 + 컴포넌트 저장
     - ./component-library/react/PrimaryButton.jsx
     - ./component-library/react/LoginForm.jsx
   → 사용자 구현
   → Phase 3: 검증
   → ✅ 통과

3. "대시보드 화면 만들어줘"
   → Phase 2A: 
     ✅ 재사용 가능 컴포넌트 발견!
     - PrimaryButton (로그인 화면에서 사용)
     - 그대로 재사용 가능
   → Phase 2B: 
     - PrimaryButton 재사용
     - DashboardCard (새 컴포넌트) 생성 및 저장
   → 사용자 구현
   → Phase 3: 검증
   → ✅ 통과

4. "설정 화면 만들어줘"
   → Phase 2A:
     ✅ 재사용 가능 컴포넌트:
     - PrimaryButton
     - LoginForm의 Input 컴포넌트
   → Phase 2B: 대부분 재사용, 일부만 새로 생성
   → 개발 시간 50% 단축!
```

### 시나리오 2: 기존 UI 개선

```
1. "기존 UI 개선하고 싶어. 일단 디자인 시스템 만들어줘"
   → Phase 1 실행
   
2. "현재 로그인 화면 개선해줘 [스크린샷]"
   → Phase 2A: 문제점 분석 및 개선 방향
   → Phase 2B: 구현 가이드
   → 사용자 구현
   → Phase 3: 검증
```

## Design Token 내보내기

Phase 1 완료 후 언제든지:

```bash
python scripts/export_design_tokens.py ./design-systems/[제품명]-design-system.md --format json
python scripts/export_design_tokens.py ./design-systems/[제품명]-design-system.md --format css
python scripts/export_design_tokens.py ./design-systems/[제품명]-design-system.md --format tailwind
python scripts/export_design_tokens.py ./design-systems/[제품명]-design-system.md --format flutter
```

출력: `./design-systems/design-tokens.[확장자]`

## 컴포넌트 라이브러리 관리

### 컴포넌트 목록 보기

```bash
# 전체 컴포넌트 목록
python scripts/manage_components.py list

# 특정 프레임워크만
python scripts/manage_components.py list react
python scripts/manage_components.py list flutter
python scripts/manage_components.py list vue
```

### 특정 컴포넌트 조회

```bash
# 컴포넌트 정보만
python scripts/manage_components.py get PrimaryButton

# 특정 프레임워크 코드 포함
python scripts/manage_components.py get PrimaryButton react
python scripts/manage_components.py get LoginForm flutter
```

### 수동으로 컴포넌트 추가

```bash
python scripts/manage_components.py add \
  "ComponentName" \
  "react" \
  "./path/to/component.jsx" \
  "Used in Login Screen" \
  "Large variant with icon"
```

### 컴포넌트 문서 내보내기

```bash
python scripts/manage_components.py export
```

출력: `./component-library/COMPONENTS.md`

### 디렉토리 구조

```
project/
├── design-systems/
│   ├── [제품명]-design-system.md      # Design System 파일
│   ├── design-tokens.json              # 내보낸 토큰
│   ├── design-tokens.css
│   ├── design-tokens.tailwind.config.js
│   └── design-tokens.app_theme.dart
│
└── component-library/
    ├── registry.json                   # 컴포넌트 메타데이터
    ├── COMPONENTS.md                   # 컴포넌트 문서
    ├── react/
    │   ├── PrimaryButton.jsx
    │   ├── LoginForm.jsx
    │   └── DashboardCard.jsx
    ├── flutter/
    │   ├── PrimaryButton.dart
    │   └── LoginForm.dart
    └── vue/
        └── PrimaryButton.vue
```

## 품질 게이트

각 Phase는 엄격한 품질 기준을 충족해야 다음 단계로 진행:

| Phase | 주요 검증 항목 | 통과 기준 |
|-------|--------------|---------|
| 1 | Design System 완성도 | 모든 값 구체화, 사용자 승인 |
| 2A | 토큰 매핑, 의존성 분석 | 모든 변경사항 토큰 매핑, 사용자 승인 |
| 2B | 명세 완전성 | 모든 상태 정의, Component Registry 업데이트 |
| 3 | 구현 품질 | 기획 의도/명세 충족, 코드 품질 |

## 기대 효과

✅ **품질 보장**
- Phase 3를 통한 자동 검증
- 린트/빌드 오류 사전 발견
- 접근성 요구사항 자동 체크

✅ **명확한 책임 분리**
- 분석 → 명세 → 구현 → 검증
- 각 단계의 목적이 명확

✅ **컨텍스트 효율성**
- 각 Phase가 필요한 최소 컨텍스트만 사용
- 대규모 프로젝트도 안정적 처리

✅ **한글 사용자 경험**
- 일관된 한글 커뮤니케이션
- 기술 문서와 사용자 대면 구분

✅ **반복 가능한 프로세스**
- 표준화된 검증 절차
- 재사용 가능한 디자인 시스템

✅ **파일 기반 관리** ⭐
- Design System 파일로 저장 및 버전 관리
- 컴포넌트 라이브러리 체계적 관리
- 팀 간 공유 및 협업 용이

✅ **재사용성 극대화** ⭐
- 생성된 모든 컴포넌트 자동 저장
- 프레임워크별 분류 및 검색
- 다음 작업 시 즉시 재사용
- **개발 시간 30-50% 단축 가능**

## 설치 및 사용

1. `ui-renewal.skill` 파일을 Claude Code에 업로드
2. "디자인 시스템 만들어줘" 또는 "UI 개선해줘"로 시작
3. Skill이 자동으로 적절한 Phase 선택 및 진행

## 버전 히스토리

**v3.1 (현재)**
- 파일 관리 시스템 추가
  - Design System 자동 파일 저장
  - 디자인 토큰 자동 내보내기
- 컴포넌트 라이브러리 관리
  - 생성된 컴포넌트 자동 저장
  - 프레임워크별 분류 (React/Flutter/Vue)
  - 컴포넌트 검색 및 재사용 (`manage_components.py`)
  - 자동 문서화 (COMPONENTS.md)

**v3.0**
- Phase 3: 검증 및 품질 체크 추가
- 한글 출력 규칙 적용
- 린트/빌드 검사 기능

**v2.0**
- Phase 2를 2A/2B로 분리
- 컨텍스트 효율성 극대화

**v1.0**
- Phase 1, 2 기본 구현
- Design System 기반 개선

## 문의

이 skill은 Choi님의 SDD 방법론, Context Engineering 철학, TDD 통합 접근을 완벽히 구현합니다.