# i18n 오케스트레이션 가이드

## 개요

이 디렉토리는 i18n 작업을 에이전트가 수행할 때 필요한 컨텍스트를 분할하여 제공합니다.

**원본 문서**: `docs/i18n-plan.md`

---

## 디렉토리 구조

```
docs/i18n/
├── README.md                 # 이 파일 (오케스트레이션 가이드)
├── common/                   # 모든 Phase 공통 규칙
│   ├── conventions.md        # 키 네이밍 컨벤션 (§3)
│   └── patterns.md           # 코드 변환 패턴 (§6)
├── context/                  # 프로젝트 컨텍스트
│   ├── project-rules.md      # CLAUDE.md 발췌 (레이어 규칙)
│   └── phase-dependencies.md # Phase 간 의존성
├── phases/                   # Phase별 작업 지시서
│   ├── phase-0-infra.md
│   ├── phase-1-common.md
│   ├── phase-2-settings.md
│   ├── phase-3-auth.md
│   ├── phase-4-dashboard.md
│   ├── phase-5-checkin.md
│   ├── phase-6-tracking.md
│   ├── phase-7-onboarding.md
│   ├── phase-8-coping.md
│   ├── phase-9-notification.md
│   └── phase-10-records.md
├── special/                  # 특수 도메인
│   ├── medical-terms.md      # 의료 용어 번역 가이드 (§4)
│   ├── testing.md            # 테스트 전략 (§14)
│   └── edge-cases.md         # 에지 케이스 처리 (§15)
├── examples/                 # Phase 0 구현 후 생성
│   └── (Phase 0 완료 후 실제 결과물 추가)
├── snapshots/                # 수정 대상 파일 현재 상태
│   └── (Phase별 대상 파일 스냅샷)
└── checklists/               # Phase 0 구현 후 생성
    └── (실제 경험 기반 체크리스트)
```

---

## 에이전트 호출 시 컨텍스트 번들

### 필수 공통 (모든 Phase)

```
- common/conventions.md
- common/patterns.md
- context/project-rules.md
```

### Phase별 추가

| Phase | 추가 컨텍스트 |
|-------|-------------|
| 0 | phases/phase-0-infra.md |
| 1 | phases/phase-1-common.md |
| 2 | phases/phase-2-settings.md |
| 3 | phases/phase-3-auth.md |
| 4 | phases/phase-4-dashboard.md |
| 5 | phases/phase-5-checkin.md, special/medical-terms.md |
| 6 | phases/phase-6-tracking.md, special/medical-terms.md |
| 7 | phases/phase-7-onboarding.md |
| 8 | phases/phase-8-coping.md, special/medical-terms.md |
| 9 | phases/phase-9-notification.md, special/edge-cases.md |
| 10 | phases/phase-10-records.md |

---

## 작업 순서

```
[Step 1] 문서 분할 완료 (현재)
  ↓
[Step 2] Phase 0 실제 구현
  - l10n.yaml, pubspec.yaml, MaterialApp 설정
  - flutter gen-l10n 성공 확인
  - 빌드 검증
  ↓
[Step 3] 검증된 결과물로 examples/, checklists/ 생성
  ↓
[Step 4] Phase 1-10 순차 진행
```

---

## 할루시네이션 방지 원칙

| 문서 유형 | 생성 방식 | 검증 |
|----------|----------|------|
| conventions.md | i18n-plan.md §3 그대로 추출 | 원본 대조 |
| patterns.md | i18n-plan.md §6 그대로 추출 | 원본 대조 |
| project-rules.md | CLAUDE.md 그대로 발췌 | 원본 대조 |
| phases/*.md | i18n-plan.md §5 분할 | 원본 대조 |
| examples/ | Phase 0 실제 구현 결과 | 빌드/테스트 통과 |
| checklists/ | 실제 구현 경험 기반 | 실행 검증 |
