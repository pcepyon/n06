# GLP-1 MVP - Development Orchestration

## Critical Rules (Non-negotiable)

### Layer Dependency
```
Presentation → Application → Domain ← Infrastructure
```
**Violation = Immediate rejection**

### Layer Responsibility (BUG-20251124-001)
```
Presentation Layer ONLY:
  - UI 렌더링, 네비게이션 (context.go, context.push), 로컬 UI 상태

Application Layer ONLY:
  - 비즈니스 로직, 상태 관리 (Riverpod Notifier), UseCase 오케스트레이션

❌ NEVER in Application Layer:
  - context.go() / ref.read(goRouterProvider).go()
  - showDialog() / showModalBottomSheet() / ScaffoldMessenger
```

### Async Mutation 안전 패턴 (BUG-20251125-223741)
```dart
Future<void> anyMutation() async {
  final link = ref.keepAlive();  // 작업 완료 보장
  try {
    state = await AsyncValue.guard(() async {
      await repository.save();
      if (!ref.mounted) return previousState;
      return newState;
    });
  } finally {
    link.close();  // 메모리 누수 방지
  }
}
```

### Repository Pattern
```
Application/Presentation → Repository Interface (Domain)
                        → Repository Implementation (Infrastructure)
```

### Dialog 버튼 레이아웃 (BUG-20251130-152000)
```
❌ AlertDialog.actions + Expanded → OverflowBar 타입 충돌
✅ Dialog + Row + Expanded → 정상 동작
```

### Container 스타일링 (BUG-20251130-110218)
```
❌ Container(color: X, decoration: BoxDecoration(...))
✅ Container(decoration: BoxDecoration(color: X, ...))
```

### Widget Lifecycle 내 Provider 수정 (BUG-20251202-153023)
```
initState/didChangeDependencies/build 내에서 Provider 수정 시:
❌ ref.read(provider.notifier).method()  // 직접 호출 금지
✅ Future.microtask(() { ref.read(provider.notifier).method(); })
✅ WidgetsBinding.instance.addPostFrameCallback((_) { ... })
```

---

## Decision Trees

### "Where should this code go?"
```
UI rendering? → Presentation (features/{feature}/presentation/)
State/UseCase? → Application (features/{feature}/application/)
Business logic/model? → Domain (features/{feature}/domain/)
Database/DTO? → Infrastructure (features/{feature}/infrastructure/)
```

### "What Provider type?"
```
CRUD async? → AsyncNotifierProvider
Real-time? → StreamProvider
Immutable service? → Provider
Derived calculation? → Provider
```

### "How to get userId?"
```
Standard: ref.read(authNotifierProvider).value?.id
Special cases only: Onboarding flow, Dialog/Sheet components
```

---

## Quick Reference

### File Location & Naming
```
features/{feature}/
  presentation/screens/{feature}_screen.dart
  application/notifiers/{feature}_notifier.dart
  domain/entities/{entity}.dart
  domain/repositories/{feature}_repository.dart
  infrastructure/repositories/supabase_{feature}_repository.dart
  infrastructure/dtos/{entity}_dto.dart
```

---

## Commit Process
```
[ ] flutter test && flutter analyze
[ ] git commit
[ ] changelog: `docs/changelog.md` 읽고 규칙대로 추가, amend
[ ] git push
```

---

## Docs Navigation
> 작업 시작 전 `docs/INDEX.md`를 먼저 읽고 필요한 문서만 로드할 것
> 각 문서 Frontmatter에서 keywords, read_when, related 확인 가능

| ID | 문서 | Keywords | 읽을 시점 |
|----|------|----------|----------|
| prd | `docs/prd.md` | vision, scope, mvp | 제품 비전, 범위 |
| requirements | `docs/requirements.md` | feature, scenario, spec | 기능 요구사항 |
| userflow | `docs/userflow.md` | flow, screen, ux | 화면 흐름, UX |
| code-structure | `docs/code_structure.md` | layer, folder, import | 레이어, 파일 위치 |
| state-management | `docs/state-management.md` | provider, notifier | Provider, Notifier |
| database | `docs/database.md` | schema, table, rls | 테이블, 스키마 |
| techstack | `docs/techstack.md` | flutter, supabase | 기술 스택 |
| tdd | `docs/tdd.md` | test, mock, fake | 테스트 작성 |
| 기능 명세 | `docs/{번호}/spec.md` | - | 기능 구현 시 |

---

## Test Rules
- Test-First (TDD), Behavior 테스트 only
- Mock보다 Fake 선호
- Mocktail: `registerFallbackValue()` 필수

---

## rules
- sot 문서를 작성할 때는 한글로 작성하라.