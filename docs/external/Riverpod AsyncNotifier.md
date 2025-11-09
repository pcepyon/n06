# Riverpod AsyncNotifier 상태 업데이트 타이밍 문제 해결 가이드

> **대상**: Flutter + Riverpod 코드 생성 방식 사용 중 AsyncNotifier의 state 업데이트가 즉시 반영되지 않는 문제  
> **버전**: Riverpod 2.x (riverpod_generator 사용)  
> **최종 업데이트**: 2025-01-09

---

## 문제 상황

### 증상
```dart
// AuthNotifier에서 state 설정
state = AsyncValue.data(user);  // ✅ 설정 완료

// LoginScreen에서 즉시 읽기
final authState = ref.read(authNotifierProvider);  // ❌ AsyncLoading 반환
```

**기대**: `AsyncValue.data(user)` 반환  
**실제**: `AsyncLoading<User?>()` 반환

---

## 근본 원인

### 1. AsyncNotifier의 생명주기와 build() 메서드

AsyncNotifier의 `build()` 메서드는 provider 초기화 시 **자동으로 실행**됩니다:

```dart
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<User?> build() async {
    // 🔄 provider가 처음 watch되거나 read될 때 자동 실행
    // 이 메서드가 완료될 때까지 state는 AsyncLoading 상태
    return null;
  }
}
```

**핵심**: `build()`가 async라면 완료될 때까지 state는 `AsyncLoading` 상태를 유지합니다.

### 2. ref.read() 타이밍 문제

```dart
// notifier 메서드 내부에서
state = AsyncValue.data(user);  // state 즉시 업데이트

// 다른 위치에서 (예: LoginScreen)
ref.read(authNotifierProvider);  // ⚠️ build()가 재실행되면 AsyncLoading 반환
```

문제의 원인:
- `state` 업데이트는 **동기적**으로 발생
- 하지만 provider가 dispose되고 재생성되면 `build()`가 다시 실행됨
- `build()`가 async이면 즉시 AsyncLoading 상태가 됨

### 3. autoDispose 기본 동작

Riverpod 코드 생성에서는 **기본적으로 autoDispose가 활성화**됩니다:

```dart
@riverpod  // ⚠️ autoDispose: true가 기본값
class AuthNotifier extends _$AuthNotifier {
  // ...
}
```

이는 다음을 의미합니다:
- 리스너(ref.watch/ref.listen)가 없으면 provider가 자동으로 dispose됨
- dispose 후 다시 접근하면 `build()`가 재실행됨
- async build()는 즉시 AsyncLoading을 반환

---

## 해결 방법

### 방법 1: keepAlive 사용 (권장)

인증 상태처럼 앱 전체에서 유지되어야 하는 상태는 `keepAlive: true`를 설정:

```dart
@Riverpod(keepAlive: true)  // ✅ provider가 dispose되지 않음
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<User?> build() async {
    // 초기화 로직
    return null;
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    
    try {
      final user = await _authRepository.signIn(email, password);
      state = AsyncValue.data(user);  // ✅ 즉시 반영됨
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
```

**장점**:
- state 업데이트가 즉시 반영됨
- dispose/재생성 사이클이 없음
- 글로벌 상태 관리에 적합

**단점**:
- 메모리에 계속 유지됨 (큰 상태에는 부적합)

### 방법 2: future 속성 사용

state의 완료를 기다려야 할 때는 `future` 속성 활용:

```dart
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<User?> build() async {
    return null;
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    
    state = await AsyncValue.guard(() async {
      return await _authRepository.signIn(email, password);
    });
  }
}

// 사용 위치
class LoginScreen extends ConsumerWidget {
  void _handleLogin(WidgetRef ref) async {
    await ref.read(authNotifierProvider.notifier).signIn(email, password);
    
    // ✅ future를 사용하여 완료된 상태 확인
    final user = await ref.read(authNotifierProvider.future);
    if (user != null) {
      // 로그인 성공
    }
  }
}
```

**장점**:
- autoDispose 동작 유지
- 비동기 완료 보장

**단점**:
- Future를 await해야 함
- 동기적 접근 불가

### 방법 3: ref.watch 사용

UI에서 상태를 반응적으로 구독:

```dart
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ ref.watch로 구독하면 state 변경 시 자동 리빌드
    final authState = ref.watch(authNotifierProvider);
    
    return authState.when(
      data: (user) => user != null 
          ? HomeScreen() 
          : LoginForm(),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => ErrorWidget(err),
    );
  }
}
```

**장점**:
- 반응형 UI
- state 변경 자동 추적

**단점**:
- 이벤트 핸들러에서 즉시 값 확인 불가

### 방법 4: 동기 build() 사용

초기 상태가 동기적이면 즉시 사용 가능:

```dart
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  User? build() {  // ✅ async 제거
    // 동기적 초기화만 수행
    return null;
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    
    state = await AsyncValue.guard(() async {
      return await _authRepository.signIn(email, password);
    });
  }
}
```

**주의**: build()는 순수 초기화만 담당해야 함

---

## 패턴별 권장 사용처

### keepAlive: true 사용

```dart
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier { ... }
```

**사용처**:
- ✅ 인증 상태 (auth)
- ✅ 앱 설정 (settings)
- ✅ 사용자 프로필 (global profile)
- ✅ 테마/로케일 설정

### autoDispose (기본값) 유지

```dart
@riverpod
class TodoListNotifier extends _$TodoListNotifier { ... }
```

**사용처**:
- ✅ 화면별 데이터 (screen-specific state)
- ✅ 폼 상태 (form state)
- ✅ 목록 필터 (list filters)
- ✅ 임시 UI 상태 (temporary UI state)

---

## 실전 예제: 소셜 로그인 구현

### Before (문제 있는 코드)

```dart
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<User?> build() async {
    // 토큰 확인 등 비동기 초기화
    final token = await _storage.read('token');
    if (token != null) {
      return await _authRepository.getCurrentUser();
    }
    return null;
  }

  Future<void> signInWithKakao() async {
    try {
      final user = await _authRepository.signInWithKakao();
      state = AsyncValue.data(user);  // ⚠️ 설정
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// LoginScreen
class LoginScreen extends ConsumerWidget {
  void _handleKakaoLogin(WidgetRef ref) async {
    await ref.read(authNotifierProvider.notifier).signInWithKakao();
    
    // ❌ 문제: build()가 재실행되어 AsyncLoading 반환
    final authState = ref.read(authNotifierProvider);
    if (authState is AsyncData) {  // false
      // 로그인 성공 처리
    }
  }
}
```

### After (해결된 코드)

```dart
@Riverpod(keepAlive: true)  // ✅ 해결 1: keepAlive 설정
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<User?> build() async {
    final token = await _storage.read('token');
    if (token != null) {
      return await _authRepository.getCurrentUser();
    }
    return null;
  }

  Future<void> signInWithKakao() async {
    state = const AsyncLoading();
    
    state = await AsyncValue.guard(() async {
      return await _authRepository.signInWithKakao();
    });
  }
}

// LoginScreen - 방법 A: future 사용
class LoginScreen extends ConsumerWidget {
  void _handleKakaoLogin(WidgetRef ref) async {
    await ref.read(authNotifierProvider.notifier).signInWithKakao();
    
    // ✅ future로 완료된 상태 확인
    final user = await ref.read(authNotifierProvider.future);
    if (user != null) {
      Navigator.pushReplacement(context, HomeScreen());
    }
  }
}

// LoginScreen - 방법 B: ref.listen 사용
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ 상태 변화 감지
    ref.listen(authNotifierProvider, (previous, next) {
      next.whenData((user) {
        if (user != null) {
          Navigator.pushReplacement(context, HomeScreen());
        }
      });
    });
    
    return LoginForm(
      onKakaoLogin: () {
        ref.read(authNotifierProvider.notifier).signInWithKakao();
      },
    );
  }
}
```

---

## 디버깅 체크리스트

state 업데이트가 즉시 반영되지 않을 때:

1. **[ ]** `@Riverpod(keepAlive: true)` 설정 확인
   ```dart
   @Riverpod(keepAlive: true)  // 글로벌 상태에 필수
   ```

2. **[ ]** build() 메서드가 async인지 확인
   ```dart
   @override
   FutureOr<User?> build() async { ... }  // async이면 즉시 AsyncLoading
   ```

3. **[ ]** ref.read() 대신 ref.watch() 사용 고려
   ```dart
   final state = ref.watch(provider);  // 반응형
   final state = ref.read(provider);   // 일회성
   ```

4. **[ ]** future 속성 사용 확인
   ```dart
   final user = await ref.read(provider.future);  // 완료 대기
   ```

5. **[ ]** provider가 dispose되지 않았는지 확인
   ```dart
   // 로그 추가
   @override
   FutureOr<User?> build() async {
     print('🔄 AuthNotifier build() called');
     return null;
   }
   ```

---

## 참고 자료

- [Riverpod 공식 문서 - (Async)NotifierProvider](https://docs-v2.riverpod.dev/docs/providers/notifier_provider)
- [Riverpod Generator](https://riverpod.dev/docs/concepts/about_code_generation)
- [AsyncNotifier 클래스 API](https://pub.dev/documentation/riverpod/latest/riverpod/AsyncNotifier-class.html)
- [keepAlive 관련 논의](https://github.com/rrousselGit/riverpod/discussions/1876)

---

## 요약

| 상황 | 해결 방법 | 코드 |
|------|----------|------|
| 글로벌 상태 (auth, settings) | keepAlive 사용 | `@Riverpod(keepAlive: true)` |
| 비동기 완료 대기 | future 속성 | `await ref.read(provider.future)` |
| 반응형 UI | ref.watch | `ref.watch(provider)` |
| 동기적 초기화 | build()를 sync로 | `User? build() { return null; }` |

**핵심 원칙**: 
- AsyncNotifier의 `build()`가 async이면 초기 state는 AsyncLoading
- autoDispose provider는 리스너가 없으면 dispose됨
- 글로벌 상태는 `keepAlive: true` 필수