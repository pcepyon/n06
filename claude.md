# GLP-1 MVP - Development Orchestration

## When to Use This Guide

**Before coding**: Read this document first to understand the workflow
**During development**: Use as navigation map to relevant documentation
**When stuck**: Check decision trees and critical rules

---


## Critical Rules (Non-negotiable)

### Layer Dependency
```
Presentation → Application → Domain ← Infrastructure
```

**Violation = Immediate rejection**

### Repository Pattern
```
Application/Presentation → Repository Interface (Domain)
                        → Repository Implementation (Infrastructure)
```

**Why**: Phase 1 transition depends on this (1-line change)

---

## Decision Trees

### "Where should this code go?"

```
Is it UI rendering?
  → Presentation Layer (features/{feature}/presentation/)

Is it state management or UseCase orchestration?
  → Application Layer (features/{feature}/application/)

Is it business logic or data model?
  → Domain Layer (features/{feature}/domain/)

Is it database access or DTO conversion?
  → Infrastructure Layer (features/{feature}/infrastructure/)
```

### "What Provider type should I use?"

```
CRUD operations with async?
  → AsyncNotifierProvider (see state-management.md)

Real-time Isar watch?
  → StreamProvider (see state-management.md)

Immutable service or repository?
  → Provider (see state-management.md)

Derived calculation from other providers?
  → Provider (see state-management.md)
```

### "How should I get userId in screens?"

```
New screen needs userId?
  → Use authNotifierProvider.read/watch (ALWAYS)
  ✅ final userId = ref.read(authNotifierProvider).value?.id;

External parameter (userId param)?
  → Only for special cases:
    - Onboarding flow (first login)
    - Dialog/Sheet components (caller already has userId)
  → Ensure caller passes userId + router receives it
  ⚠️ NEVER leave optional userId parameter without passing it
```

---


## Common Mistakes

### ❌ NEVER
```dart
// Application accessing Isar directly
final isar = ref.watch(isarProvider); // WRONG

// Skipping Repository interface
class ConcreteRepository { } // WRONG (no interface)

// Domain importing Flutter
import 'package:flutter/material.dart'; // in domain/ folder

// Writing code before test
// (Violates TDD - see docs/tdd.md)

// autoDispose Provider + async 저장 후 즉시 모달 표시
await notifier.save(data);
await showDialog(...); // WRONG: Provider 조기 해제 가능

// userId 하드코딩 (authNotifier에서 가져와야 함)
const userId = 'current-user-id'; // WRONG

// 외부 userId 파라미터 받지만 전달 안함
class SomeScreen extends ConsumerWidget {
  final String? userId; // WRONG: 파라미터만 선언하고 전달 안함
  const SomeScreen({this.userId});
}
// Router
builder: (context, state) => const SomeScreen(), // WRONG: userId 미전달

// Notifier에서 null 체크 없이 state 접근
return state.asData!.value; // WRONG: asData가 null일 수 있음
```

### ✅ ALWAYS
```dart
// Use Repository interface
final repo = ref.read(medicationRepositoryProvider);

// Domain defines interface
abstract class MedicationRepository { }

// Infrastructure implements
class IsarMedicationRepository implements MedicationRepository { }

// Test first
test('should...', () { }); // Then write code

// 저장 완료 후 mounted 체크하고 모달 표시
await notifier.save(data);
if (!mounted) return;
await showDialog(...); // Safe

// userId는 authNotifier에서 가져오기 (표준 패턴)
final userId = ref.read(authNotifierProvider).value?.id;
if (userId != null) {
  // 데이터 로딩
} else {
  // 명시적 에러 처리
}

// 외부 파라미터는 특수 케이스만 허용
// 1. Onboarding: context.go('/onboarding', extra: user.id)
// 2. Dialog/Sheet: MyDialog(userId: userId) with required parameter

// Notifier에서 state 백업 후 접근
final prev = state.asData?.value ?? defaultState;
return prev; // Safe
```

**Details**: See `docs/code_structure.md` (DO/DON'T sections)

---

## Quick Reference

### File Location Patterns
```
features/{feature}/
  presentation/screens/{feature}_screen.dart
  application/notifiers/{feature}_notifier.dart
  domain/entities/{entity}.dart
  domain/repositories/{feature}_repository.dart
  infrastructure/repositories/isar_{feature}_repository.dart
  infrastructure/dtos/{entity}_dto.dart
```

### Naming Conventions
```
Entity: DoseRecord (domain/entities/)
DTO: DoseRecordDto (infrastructure/dtos/)
Repository Interface: MedicationRepository (domain/repositories/)
Repository Impl: IsarMedicationRepository (infrastructure/repositories/)
Notifier: MedicationNotifier (application/notifiers/)
Provider: medicationNotifierProvider
```

**Full structure**: See `docs/code_structure.md`

---

## Phase 0 → Phase 1 Transition

**Impact**: Infrastructure Layer ONLY (1-line change per repository)

```dart
// Phase 0
@riverpod
MedicationRepository medicationRepository(ref) =>
  IsarMedicationRepository(ref.watch(isarProvider));

// Phase 1
@riverpod
MedicationRepository medicationRepository(ref) =>
  SupabaseMedicationRepository(ref.watch(supabaseProvider));
```

**Zero changes**: Domain, Application, Presentation

**Requirement**: Repository Pattern strictly enforced

**Details**: See `docs/techstack.md` (Phase Transition section)

---

## Before Committing

```
[ ] Tests pass (flutter test)
[ ] No warnings (flutter analyze)
[ ] TDD cycle completed (docs/tdd.md)
[ ] Repository pattern maintained (docs/code_structure.md)
[ ] No layer violations (check imports)
[ ] Performance constraints met (docs/requirements.md)
```

---

## When Stuck

### Architecture questions
→ `docs/code_structure.md`

### State management questions
→ `docs/state-management.md`

### Business logic questions
→ `docs/requirements.md` or `docs/userflow.md`

### Data model questions
→ `docs/database.md`

### Testing questions
→ `docs/tdd.md`

### Technology choice questions
→ `docs/techstack.md`

---

## Core Principles

1. **Separation of Concerns**: Each layer has ONE responsibility (see code_structure.md)
2. **Dependency Inversion**: Depend on interfaces, not implementations (Repository Pattern)
3. **Test-Driven**: Test first, code second (see tdd.md)
4. **Phase Flexibility**: Infrastructure-only changes for Phase 1 (see techstack.md)

## Test Maintenance

테스트 유지보수 관련 문서:
- `docs/test/test-maintenance.md`: 테스트 유지보수 프로세스 및 원칙
- `docs/test/test-maintenance-final-report.md`: 최근 테스트 정리 작업 결과 (2025-11-16)
- `docs/test/integration-test-backlog.md`: Integration 테스트 작성 대기 목록
- `docs/test/test-audit-report.md`: 테스트 감사 보고서
- `docs/test/test-cleanup-analysis.md`: 테스트 정리 상세 분석
- `docs/test/test-cleanup-final-summary.md`: 테스트 정리 실행 계획

### Test Coverage 목표
- Domain: 95%+
- Application: 85%+
- Infrastructure: 70%+
- Presentation: 60%+

### AI Agent 테스트 규칙

**새 기능 작성 시**:
1. Test-First (TDD) 원칙 준수
2. Behavior 테스트, Implementation 테스트 금지
3. Mock보다 Fake 선호 (복잡한 시나리오)

**테스트 삭제 기준**:
1. ROI 분석: 가치 vs 유지보수 비용
2. 삭제 전 문서화 (rationale 기록)
3. Integration 테스트로 대체 가능 여부 검토

**Mock 사용 지침**:
- Mocktail 사용 시 `registerFallbackValue()` 필수
- 복잡한 Provider 의존성은 Fake Repository 사용
- Platform channel (알림 등)은 Mock 설정 필요

**층별 테스트 전략**:
- Domain: Entity + UseCase 단위 테스트 (높은 커버리지)
- Application: 핵심 비즈니스 로직 흐름 테스트
- Infrastructure: Repository 인터페이스 테스트
- Presentation: 핵심 사용자 흐름만 테스트 (brittle UI test 지양)

---

## rules
- sot 문서를 작성할 때는 한글로 작성하라.
