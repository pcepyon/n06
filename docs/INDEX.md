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
