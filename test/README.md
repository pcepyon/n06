# Test Structure

이 프로젝트는 test-plan.md에 따라 체계적인 테스트 환경을 구축합니다.

## 폴더 구조

```
test/
├── helpers/        # 테스트 유틸리티 (fake_async, test data builders)
├── fakes/          # Fake Repository 구현체 (메모리 기반)
├── unit/           # Unit 테스트 (Domain Layer 70%)
├── integration/    # Integration 테스트 (Application Layer 20%, Infrastructure 10%)
└── e2e/            # E2E 테스트 (Presentation Layer - Critical Path)
```

## 테스트 원칙

### 1. TDD 필수
- Red → Green → Refactor 사이클 준수
- 테스트 먼저 작성, 실패 확인 후 구현

### 2. Mocking 전략
- **Domain Layer**: Mocking 불필요 (Pure Dart)
- **Application Layer**: Fake Repository 사용
- **Infrastructure Layer**: Isar in-memory 또는 임시 DB 사용
- **Presentation Layer**: Notifier Mocking

### 3. 비동기 테스트
- `fake_async` 패키지 사용
- `Future.delayed` 의존 로직은 반드시 Fake Timers로 테스트

### 4. Repository Pattern
- Application/Presentation은 Domain Interface만 의존
- Infrastructure 구현체 직접 참조 금지
- Fake Repository로 빠른 TDD 사이클 확보

## 테스트 비율

- **Domain (70%)**: 비즈니스 로직 및 검증의 정확성
- **Application (20%)**: 상태 전환 및 오케스트레이션
- **Infrastructure (10%)**: DB 무결성 및 직렬화

## Critical Test Scenarios

test-plan.md의 필수 테스트 시나리오:
- E2E-001: 소셜 로그인 (patrol)
- IT-002: 투여 스케줄 롤백 (isar + fake_async)
- UT-003: 체중 기록 검증 (unit)
- IT-004: 대시보드 실시간 업데이트 (notifier)
- UT-005: 로그아웃 안정성 (unit + fake_async)
