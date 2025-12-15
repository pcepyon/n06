# SDD 문서 작성 가이드라인 (2025년 12월)

> 코딩 에이전트가 정확하게 이해하고 구현할 수 있는 명세 문서 작성법

---

## 1. 핵심 원칙

### 1.1 "명확한 의도가 모호한 코드보다 낫다"

> AI 에이전트는 패턴 완성에 뛰어나지만, 마음 읽기는 불가능합니다.

**원칙:**
- **Why(목적)** + **What(요구사항)**을 명확히 기술
- 반복적인 구현 패턴은 **의도로** 설명
- 핵심 아키텍처 패턴은 **코드로** 명시 (특히 정적 타입 언어)

```markdown
❌ 나쁜 예: "앱에 사진 공유 추가해줘"

✅ 좋은 예:
## 목적
사용자가 운동 진행 사진을 촬영하여 기록에 첨부할 수 있게 한다.

## 요구사항
- 카메라 직접 촬영 또는 갤러리 선택
- 이미지 압축 (max 1MB)
- 기록당 최대 3장

## 제약사항
- EXIF 데이터 제거 (개인정보)
- 업로드 실패 시 로컬 저장 후 재시도
```

### 1.2 컨텍스트 엔지니어링 핵심 공식

> "원하는 결과의 가능성을 최대화하는 **최소한의 고신호(high-signal) 토큰** 집합을 찾아라"
> — Anthropic Engineering

**학술적 근거 (강하게 검증됨):**
- **"Lost in the Middle" (Liu et al., 2024)**: 중간에 위치한 정보는 성능 저하
- **Context Rot 연구 (2025)**: 32k 토큰에서 12개 모델 중 11개가 50% 이하 성능
- **실용적 임계치**: 100k 토큰 이상에서 대부분 모델 불안정

---

## 2. 문서 구조화

### 2.1 계층적 구성

```
프로젝트 루트/
├── CLAUDE.md                    ← 전역 규칙, Decision Trees, 안티패턴
├── docs/
│   ├── INDEX.md                 ← 문서 네비게이션 (키워드, 읽을 시점)
│   ├── {번호}/
│   │   └── spec.md              ← 기능 명세 + Implementation Context
│   └── lessons-learned.md       ← 에러 피드백 루프
└── lib/features/{feature}/      ← 실제 구현
```

### 2.2 문서 유형 분류

| 유형 | 목적 | 권장 크기 | 예시 |
|-----|-----|----------|-----|
| 전역 규칙 (CLAUDE.md) | 아키텍처, 안티패턴, Decision Trees | < 15,000 토큰 | Critical Rules, Layer Dependency |
| 기능 명세 (spec.md) | Use Case, Scenario, Edge Cases | < 6,000 토큰 | UC-F-001: 소셜 로그인 |
| 문서 인덱스 (INDEX.md) | Just-in-Time 검색 가이드 | < 2,000 토큰 | keywords, read_when 테이블 |
| 에러 피드백 (lessons-learned) | 재발 방지 규칙 | 100-200 토큰/항목 | BUG-YYYYMMDD |

### 2.3 필수 섹션 구분 (spec.md)

```yaml
---
id: UC-F-001
title: 소셜 로그인 및 인증
keywords: [auth, oauth, kakao, token]
read_when: [인증 관련 작업, 토큰 관리]
related: [docs/002/spec.md, docs/database.md]
---
```

```markdown
## 1. Overview (배경/목적)
## 2. Preconditions (사전 조건)
## 3. Main Scenario (주요 흐름)
## 4. Edge Cases (필수 3-5개만)
## 5. Implementation Context (SDD 핵심)
   ### Constraints (위반 불가 규칙)
   ### Pattern (핵심 구현 패턴 - 코드 포함)
   ### Decision Tree (상황별 결정)
```

---

## 3. 컨텍스트 크기 관리

### 3.1 "적게 넣을수록 더 잘 작동"

| 신호 | 조치 |
|-----|-----|
| 전체 CLAUDE.md > 200줄 | 분리 검토 |
| spec.md > 150줄 | 범위 축소 |
| 시퀀스 다이어그램 > 50줄 | 과잉 명세 |
| Edge Cases > 5개 | 포괄 규칙으로 통합 |

### 3.2 Just-in-Time 검색 패턴

```markdown
❌ 모든 요구사항을 한 파일에:
[10,000 토큰의 전체 요구사항 나열]

✅ 검색 가능한 참조 제공:
## 문서 네비게이션
> 작업 시작 전 `docs/INDEX.md`를 먼저 읽고 필요한 문서만 로드할 것

| 문서 | Keywords | 읽을 시점 |
|-----|----------|----------|
| docs/001/spec.md | auth, oauth | 인증 관련 작업 시 |
| docs/003/spec.md | record, injection | 기록 관리 구현 시 |
```

### 3.3 KV-Cache 효율 극대화 (Manus 교훈)

- **프롬프트 프리픽스 안정화**: 초 단위 타임스탬프 금지
- **추가 전용(append-only) 구조**: 중간 삭제/수정 최소화
- **결정론적 직렬화**: JSON 키 순서 고정

---

## 4. 의도 명확화 기법

### 4.1 테스트 케이스 = 의도 표현

```markdown
## 테스트 시나리오

### 정상 케이스
Given: 유효한 카카오 계정으로 인증
When: 로그인 버튼 클릭
Then: 홈 화면으로 이동, 사용자 정보 표시

### 예외 케이스
Given: 네트워크 연결 없음
When: 로그인 시도
Then: "네트워크 연결을 확인해주세요" 메시지 표시
```

### 4.2 구조화된 Chain-of-Thought (SCoT)

> **학술적 근거**: 일반 CoT보다 **구조화된 도메인 특화 CoT**가 코드 생성에 효과적 (ACM TOSEM 2024)

```markdown
## 구현 순서 (SCoT)

### 1단계: 데이터 흐름 분석
- Input: OAuth 인증 코드
- Process: 토큰 교환 → 사용자 정보 조회
- Output: User 엔티티

### 2단계: 분기 처리
- if (신규 사용자) → 온보딩 플로우
- if (기존 사용자) → 홈 화면

### 3단계: 반복/에러 처리
- 토큰 갱신 실패 시 3회 재시도
- 최종 실패 시 로그아웃 처리
```

### 4.3 Edge Cases 작성 원칙

**필수 (비즈니스 크리티컬):**
- 데이터 손실 위험 (예: Refresh Token 만료)
- 보안 취약점 (예: 동의 체크박스 미선택)
- 사용자 혼란 초래 (예: OAuth 취소)

**포괄 규칙으로 대체 가능:**
- 네트워크 오류 → "모든 네트워크 요청은 3회 재시도 + 에러 메시지"
- 동시성 문제 → "세션 독립 보장" 원칙

**권장 개수: 기능당 3-5개**

---

## 5. 규칙 작성 패턴 (CLAUDE.md)

### 5.1 효과적인 규칙 구조

```markdown
## Critical Rules (Non-negotiable)
[절대 위반 불가 - 짧고 명확하게, 버그 ID 포함]

## Decision Trees
[상황별 결정 트리 - 1-2단계 깊이만]

## Anti-patterns
[하지 말아야 할 것 - 코드 예시와 함께]

## Common Patterns
[핵심 구현 패턴 템플릿]
```

### 5.2 Decision Trees 원칙

**깊이 제한:**
- 1단계: 80%의 결정 커버 (권장)
- 2단계: 복잡한 도메인만
- 3단계 이상: 금지 (별도 문서 분리)

```markdown
### "Where should this code go?"
UI rendering? → Presentation (features/{feature}/presentation/)
  → 재사용? → shared/widgets/
  → 기능 전용? → features/{feature}/presentation/widgets/
State/UseCase? → Application (features/{feature}/application/)
```

### 5.3 기술 스택별 안티패턴 (코드 필수)

> **실무 검증 결과**: 정적 타입 언어에서는 **핵심 패턴을 코드로 명시**해야 함

```dart
// ⚠️ "Cannot use Ref after disposed" 에러 방지 필수 패턴 (BUG-20251205)
class MyNotifier extends _$MyNotifier {
  // ✅ 의존성을 late final 필드로 선언
  late final MyRepository _repository;

  @override
  Future<MyState> build() async {
    // ✅ build() 시작부에서 모든 ref 의존성 캡처
    _repository = ref.read(myRepositoryProvider);
  }
}

// ❌ 금지 패턴
MyRepository get _repository => ref.read(provider);  // async 중 disposed ref 접근
```

---

## 6. 에러 피드백 루프

### 6.1 Lessons Learned 기록 형식

| 날짜 | 버그 ID | 문제 | 근본 원인 | 해결책 | 규칙화 |
|-----|--------|-----|---------|-------|-------|
| 2025-12-05 | BUG-20251205 | Ref disposed 에러 | async 중 ref 접근 | late final 캡처 | AsyncNotifier 안전 패턴 |

### 6.2 규칙 업데이트 원칙

**트리거:** 동일 근본 원인 **3회 이상** 기록 시

**절차:**
1. 근본 원인 진단 (표면적 증상이 아닌 패턴 분석)
2. Critical Rules 또는 Anti-patterns에 추가
3. **버그 ID를 규칙에 명시** (추적성)
4. 기존 규칙과 **최소 충돌**

---

## 7. 실패 방지 패턴

### 7.1 흔한 실패 원인과 대응

| 실패 원인 | 증상 | 대응 |
|----------|-----|-----|
| **과잉 명세** | 취약하고 유지보수 어려운 로직 | 핵심 패턴만 코드, 나머지 의도로 |
| **모호함** | 일관성 없는 구현 | Decision Trees로 명확화 |
| **컨텍스트 과부하** | 성능 저하, 무시되는 지시 | 문서 분리, Just-in-Time 검색 |
| **엣지 케이스 나열** | 핵심 요구사항 묻힘 | 포괄 규칙으로 통합 |

### 7.2 컨텍스트 리셋 전략

- 긴 세션 중 `/clear` 또는 새 대화 시작
- 핵심 결정사항은 **외부 파일로 보존**
- 파일 시스템을 무한한 외부 메모리로 활용

---

## 8. Few-Shot 예시 가이드

> **학술적 근거**: "다양하고 대표적인 사례"가 권장됨 (실무자 합의).
> 복잡한 예시가 단순/엣지케이스보다 정보량 높음 (일부 연구)

### 8.1 원칙

- **대표적인 정상 케이스 2-3개** 우선
- 예시 **순서가 성능에 영향** (중요한 것 먼저)
- **다양성 확보** (서로 다른 시나리오)
- 엣지 케이스는 포괄 규칙으로 대체

### 8.2 Common Patterns 템플릿 (중앙 관리)

```markdown
## Common Patterns

### P1: AsyncNotifier CRUD
[전체 템플릿 코드]

### P2: Repository Interface + Implementation
[전체 템플릿 코드]

### P3: Screen + Widget 분리
[전체 템플릿 코드]
```

---

## 9. 워크플로우 명세

### 9.1 커밋 워크플로우

```markdown
### Commit (커밋 요청 시)
❌ changelog 없이 커밋 완료 금지
✅ docs/changelog.md 항목 추가 → amend → 완료 보고
```

### 9.2 테스트 우선 워크플로우

```markdown
## Test Rules
- Test-First (TDD), Behavior 테스트 only
- Mock보다 Fake 선호
- Mocktail: `registerFallbackValue()` 필수
```

---

## 10. 학술적 근거 요약

| 원칙 | 검증 수준 | 핵심 연구 |
|-----|---------|----------|
| Context Rot (컨텍스트 과부하) | ✅ 강함 | Liu et al. 2024, Chroma 2025 |
| 구조화된 CoT | ⚠️ 조건부 | ACM TOSEM 2024 (SCoT) |
| 대표적 Few-Shot | ⚠️ 합의 기반 | 실무자 경험 + 일부 연구 |
| 의도 중심 명세 | ⚠️ 신흥 | GitHub, Red Hat, Anthropic |

---

## 참고 자료

### 핵심 문서
- [Effective Context Engineering for AI Agents - Anthropic](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [Context Engineering for AI Agents: Lessons from Building Manus](https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus)
- [Understanding Spec-Driven-Development - Martin Fowler](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html)
- [Spec-Driven Development: 10 Things - AI Native Dev](https://ainativedev.io/news/spec-driven-development-10-things-you-need-to-know-about-specs)
- [How Spec-Driven Development Improves AI Coding Quality - Red Hat](https://developers.redhat.com/articles/2025/10/22/how-spec-driven-development-improves-ai-coding-quality)
- [Optimizing Coding Agent Rules - Arize AI](https://arize.com/blog/optimizing-coding-agent-rules-claude-md-agents-md-clinerules-cursor-rules-for-improved-accuracy/)
- [Agentic Coding Best Practices - Softcery](https://softcery.com/lab/softcerys-guide-agentic-coding-best-practices)
- [Agent Rules Repository - GitHub](https://github.com/steipete/agent-rules)

### 학술 연구
- [Lost in the Middle - Liu et al. (TACL 2024)](https://direct.mit.edu/tacl/article/doi/10.1162/tacl_a_00638/119630/Lost-in-the-Middle-How-Language-Models-Use-Long)
- [Structured Chain-of-Thought Prompting for Code Generation - ACM TOSEM 2024](https://dl.acm.org/doi/10.1145/3690635)
- [A Systematic Survey of Prompt Engineering in LLMs - arXiv 2024](https://arxiv.org/abs/2402.07927)
- [Context Rot Research - Chroma 2025](https://research.trychroma.com/context-rot)
