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

### Riverpod AsyncNotifier 안전 패턴 (BUG-20251205)
```dart
// ⚠️ "Cannot use Ref after disposed" 에러 방지 필수 패턴

class MyNotifier extends _$MyNotifier {
  // ✅ 1. 의존성을 late final 필드로 선언 (getter 사용 금지)
  late final MyRepository _repository;

  @override
  Future<MyState> build() async {
    // ✅ 2. build() 시작부에서 모든 ref 의존성 캡처
    _repository = ref.read(myRepositoryProvider);
    // ... 이후 async 작업에서 _repository 사용
  }

  Future<void> mutation() async {
    final link = ref.keepAlive();  // ✅ 3. 작업 완료 보장
    try {
      await _repository.save();  // 캡처된 의존성 사용
      if (!ref.mounted) return;  // ✅ 4. async gap 후 mounted 체크
      state = AsyncData(newState);
    } finally {
      link.close();  // ✅ 5. 메모리 누수 방지
    }
  }
}

// ❌ 금지 패턴
MyRepository get _repository => ref.read(provider);  // async 중 disposed ref 접근
```

### Repository Pattern
```
Application/Presentation → Repository Interface (Domain)
                        → Repository Implementation (Infrastructure)
```

### Flutter 레이아웃 제약 조건
```
[원칙] Constraints 흐름: 부모 → 자식 (크기 제한), 자식 → 부모 (크기 결정)

1. Unbounded 컨텍스트 (Row, Column, ListView, AppBar.actions)
   ❌ Expanded/Flexible 직접 사용 → RenderFlex overflow
   ✅ SizedBox로 명시적 크기 제공

2. Bounded 컨테이너 + 가변 콘텐츠
   ❌ SizedBox(height: N) 내 Column 직접 배치 → overflow 위험
   ✅ SingleChildScrollView 감싸기 또는 Flexible 사용

3. AlertDialog.actions
   ❌ Expanded 사용 → OverflowBar 타입 충돌
   ✅ Dialog + Row + Expanded로 대체

4. Container
   ❌ color + decoration 동시 사용
   ✅ decoration: BoxDecoration(color: X, ...)
```

### Widget Lifecycle 내 Provider 수정 (BUG-20251202-153023)
```
initState/didChangeDependencies/build 내에서 Provider 수정 시:
❌ ref.read(provider.notifier).method()  // 직접 호출 금지
✅ Future.microtask(() { ref.read(provider.notifier).method(); })
✅ WidgetsBinding.instance.addPostFrameCallback((_) { ... })
```

### void async 안티패턴 (BUG-20251202-231014)
```dart
상태 업데이트 후 UI 동기화가 필요한 콜백:
❌ void _handler() async { await updateState(); }  // 호출부에서 await 불가
✅ Future<void> _handler() async { await updateState(); }
✅ 호출부: await _handler();
```

### copyWith nullable 필드 (BUG-20251202-231014)
```dart
Dart의 ?? 연산자는 null을 "값 미전달"로 해석:
❌ copyWith(field: null)  // 기존 값 유지됨 (버그!)
✅ copyWith에 clearField 플래그 추가:
   field: clearField ? null : (field ?? this.field)
```

### Commit (커밋 요청 시)
```
❌ changelog 없이 커밋 완료 금지
✅ docs/changelog.md 항목 추가 → amend → 완료 보고
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

### "How to get userId?" (BUG-20251210)
```dart
// ⚠️ AsyncNotifier build()에서 다른 AsyncNotifier 의존 시 반드시 .future 사용

// ✅ AsyncNotifier.build() 내부 (ref.watch + .future 필수)
@override
Future<MyState> build() async {
  final user = await ref.watch(authNotifierProvider.future);  // 로딩 완료 대기
  final userId = user?.id;
  if (userId == null) throw Exception('Not authenticated');
  // ...
}

// ✅ 일반 메서드 내부 (ref.read 사용)
Future<void> someMethod() async {
  final userId = ref.read(authNotifierProvider).value?.id;
  // ...
}

// ❌ 금지: build()에서 .value?.id 직접 접근
@override
Future<MyState> build() async {
  final userId = ref.watch(authNotifierProvider).value?.id;  // 로딩 중 항상 null!
  // → 무한 루프 또는 errorNotAuthenticated 발생
}
```
**이유**: `authNotifierProvider`가 `AsyncLoading` 상태일 때 `.value`는 `null` 반환.
`await ref.watch(provider.future)`는 로딩 완료까지 대기 후 값 반환.

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