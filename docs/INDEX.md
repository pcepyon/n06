# 문서 인덱스 (Docs Index)

> 작업 시작 전 이 파일을 읽고 필요한 문서만 로드할 것.
> 각 문서의 Frontmatter(첫 6줄)에서 keywords, read_when, related 확인 가능.

---

## 핵심 문서

| ID | 문서 | Keywords | 읽을 시점 |
|----|------|----------|----------|
| prd | `docs/prd.md` | product, vision, scope, mvp | 제품 비전, MVP 범위 질문 |
| requirements | `docs/requirements.md` | feature, scenario, business, spec | 기능 요구사항, 비즈니스 로직 |
| userflow | `docs/userflow.md` | flow, screen, navigation, ux | 화면 흐름, UX, 프로세스 |
| code-structure | `docs/code_structure.md` | layer, architecture, folder, import | 레이어 구조, 파일 위치 |
| state-management | `docs/state-management.md` | riverpod, provider, notifier, asyncvalue | Provider, Notifier 패턴 |
| database | `docs/database.md` | schema, table, rls, migration | 테이블, 스키마, RLS |
| techstack | `docs/techstack.md` | flutter, supabase, library, package | 기술 스택, 라이브러리 |
| tdd | `docs/tdd.md` | test, mock, fake, red-green-refactor | 테스트 작성, TDD |
| spec-guide | `docs/spec-writing-guide.md` | agent, prompt, context, spec | AI 에이전트용 문서 작성 |

---

## 문서 관계도

```
prd ─────┬───→ requirements ───→ userflow
         │
         └───→ techstack ───→ database
                    │
                    └───→ code-structure ───→ state-management
                                   │
                                   └───→ tdd
```

---

## 기능별 명세

> 각 기능은 `docs/{번호}/` 폴더에 spec.md, plan.md 포함
> 기능 구현 시: spec.md → plan.md 순서로 읽기

| 번호 | 기능명 | spec 경로 |
|-----|-------|----------|
| 001 | 소셜 로그인 | `docs/001/spec.md` |
| 002 | 온보딩 | `docs/002/spec.md` |
| 003 | 투약 스케줄 | `docs/003/spec.md` |
| 004 | 투약 기록 | `docs/004/spec.md` |
| 005 | 증상 기록 | `docs/005/spec.md` |
| 006 | 홈 대시보드 | `docs/006/spec.md` |
| 007 | 체중 기록 | `docs/007/spec.md` |
| 008 | 리포트 생성 | `docs/008/spec.md` |
| 009 | 설정 | `docs/009/spec.md` |
| 010 | 투약 알림 | `docs/010/spec.md` |
| 011 | 데이터 공유 | `docs/011/spec.md` |
| 012 | 인사이트 | `docs/012/spec.md` |
| 013 | 프로필 | `docs/013/spec.md` |
| 014 | 응급 증상 | `docs/014/spec.md` |
| 015 | 성취 시스템 | `docs/015/spec.md` |
| 016 | 교육 온보딩 | `docs/016/spec.md` |
| 017 | 교육 온보딩 플로우 | `docs/017-education-onboarding/spec.md` |
| 018 | 비로그인 홈 | `docs/018-guest-home/spec.md` |
| 019 | 데모 모드 | `docs/019-demo-mode/spec.md` |
| 020 | 대시보드 개선 | `docs/020-dashboard-renewal/spec.md` |

---

## 최근 변경 사항

### 2024-12: 게스트홈 + 온보딩 통합 개선

**관련 문서**:
- `docs/019-demo-mode/spec.md` - 데모 모드 상세 스펙 (신규)
- `docs/002/spec.md` - 온보딩 간소화 (14단계 → 6단계)
- `docs/018-guest-home/spec.md` - 게스트홈 (참조)

**주요 변경**:
1. **게스트홈**: 정보 전달 → 실제 앱 체험(데모 모드)
2. **온보딩**: 14단계 → 6단계로 간소화 (교육 콘텐츠 삭제)
3. **부작용 가이드**: 별도 섹션 → 데일리 체크인 즉각 대처로 변경
4. **체험 데이터 이관**: 데모 → 실제 계정 자동 이관

**아키텍처 변경**:
```
[이전] 게스트홈(정보) → 로그인 → 온보딩(교육 + 설정)
[현재] 게스트홈(체험) → 로그인 → 온보딩(설정 Only)
```
