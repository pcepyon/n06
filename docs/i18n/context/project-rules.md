# i18n 관련 프로젝트 규칙

> 출처: CLAUDE.md

## 레이어 의존성

```
Presentation → Application → Domain ← Infrastructure
```

**Violation = Immediate rejection**

---

## 레이어 책임 (i18n 관점)

```
Presentation Layer ONLY:
  - UI 렌더링, 네비게이션 (context.go, context.push), 로컬 UI 상태
  - ✅ context.l10n 사용 가능

Application Layer ONLY:
  - 비즈니스 로직, 상태 관리 (Riverpod Notifier), UseCase 오케스트레이션
  - ❌ context 접근 불가 → l10n 직접 사용 불가

❌ NEVER in Application Layer:
  - context.go() / ref.read(goRouterProvider).go()
  - showDialog() / showModalBottomSheet() / ScaffoldMessenger
  - context.l10n (BuildContext 접근 불가)
```

---

## i18n에서 레이어 규칙 적용

### 올바른 패턴

```dart
// ✅ Presentation Layer에서 L10n 사용
class SomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(someNotifierProvider);

    return Text(context.l10n.someKey);  // ✅ OK
  }
}
```

### 잘못된 패턴

```dart
// ❌ Application Layer에서 L10n 접근 시도
class SomeNotifier extends Notifier<SomeState> {
  void doSomething(BuildContext context) {  // ❌ context 파라미터 금지
    final message = context.l10n.someKey;   // ❌ 레이어 위반
  }
}
```

### 해결 방법: 키만 전달

```dart
// Application Layer
class SomeNotifier extends Notifier<SomeState> {
  void doSomething() {
    state = SomeState(messageKey: 'someKey');  // ✅ 키만 전달
  }
}

// Presentation Layer에서 변환
Text(_getMessage(context, state.messageKey))  // ✅

String _getMessage(BuildContext context, String key) {
  return switch (key) {
    'someKey' => context.l10n.someKey,
    _ => '',
  };
}
```

---

## 파일 위치

```
features/{feature}/
  presentation/screens/{feature}_screen.dart    # context.l10n 사용
  application/notifiers/{feature}_notifier.dart # l10n 직접 사용 금지
  domain/entities/{entity}.dart                 # 언어 무관
  infrastructure/repositories/...               # 언어 무관
```

---

## 핵심 원칙

| 레이어 | L10n 사용 | 이유 |
|-------|----------|------|
| Presentation | ✅ 가능 | BuildContext 접근 가능 |
| Application | ❌ 불가 | BuildContext 없음 |
| Domain | ❌ 불가 + 불필요 | 순수 비즈니스 로직 |
| Infrastructure | ❌ 불가 + 불필요 | 데이터 레이어 |
