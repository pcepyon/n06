# UF-SETTINGS Plan Review

## 검토 결과 요약

**상태**: ⚠️ 수정 필요

**주요 이슈**:
1. 설정 화면의 기능 범위와 프로필 관리 혼재
2. Feature 구조 불명확 (settings vs profile)
3. AuthNotifier 의존성 명확화 필요
4. 네비게이션 처리 누락
5. Business Rules 미반영

---

## 1. Feature 구조 문제

### 이슈
plan.md에서 `features/profile/` 과 `features/settings/`를 혼용:
- `SettingsScreen` → `features/settings/presentation/`
- `UserProfile`, `ProfileRepository` → `features/profile/domain/`
- `UserProfileNotifier` → `features/profile/application/`

spec.md는 **UF-SETTINGS (설정 화면)** 유스케이스인데, plan은 **프로필 관리** 중심으로 설계됨.

### 수정 방안
```
Option 1: Settings Feature로 통합
features/settings/
  presentation/screens/settings_screen.dart
  application/notifiers/user_profile_notifier.dart  # settings 내로 이동
  domain/entities/user_profile.dart                  # settings 내로 이동
  domain/repositories/profile_repository.dart        # settings 내로 이동
  infrastructure/repositories/isar_profile_repository.dart
  infrastructure/dtos/user_profile_dto.dart

Option 2: Profile Feature 분리 (권장)
features/profile/                        # 프로필 데이터 관리
  domain/entities/user_profile.dart
  domain/repositories/profile_repository.dart
  infrastructure/repositories/isar_profile_repository.dart
  infrastructure/dtos/user_profile_dto.dart
  application/notifiers/user_profile_notifier.dart

features/settings/                       # 설정 화면 UI
  presentation/screens/settings_screen.dart
  presentation/widgets/settings_menu_item.dart
```

**권장**: Option 2 - 프로필은 다른 기능에서도 사용되므로 독립 Feature로 분리.

---

## 2. 네비게이션 처리 누락

### 이슈
spec.md의 Main Scenario Step 5에서 다음 화면으로 이동:
- UF-008 (프로필 및 목표 수정)
- UF-009 (투여 계획 수정)
- UF-013 (주간 기록 목표 조정)
- UF-012 (푸시 알림 설정)
- UF-007 (로그아웃)

plan.md의 SettingsScreen 테스트에서는 네비게이션 검증이 불완전:
```dart
// 5. 메뉴 항목 탭 테스트
testWidgets('should navigate when menu item is tapped', (tester) async {
  // Assert
  // 네비게이션 검증  ← 구체적인 검증 로직 없음
});
```

### 수정 방안
각 메뉴 항목별 네비게이션 테스트 추가:
```dart
testWidgets('should navigate to profile edit screen when tapped', (tester) async {
  // Act
  await tester.tap(find.text('프로필 및 목표 수정'));
  await tester.pumpAndSettle();

  // Assert
  expect(find.byType(ProfileEditScreen), findsOneWidget);
});

testWidgets('should navigate to dose plan screen when tapped', (tester) async {
  await tester.tap(find.text('투여 계획 수정'));
  await tester.pumpAndSettle();
  expect(find.byType(DosePlanScreen), findsOneWidget);
});

// 각 UF별 네비게이션 테스트 5개 추가 필요
```

---

## 3. AuthNotifier 의존성 불명확

### 이슈
Architecture Diagram에서:
```mermaid
SettingsScreen --> AuthNotifier
AuthNotifier --> ProfileRepository
```

**문제점**:
1. `AuthNotifier`가 `ProfileRepository`에 의존하는 이유 불명확
2. spec.md의 "로그인 세션 만료" 처리가 AuthNotifier의 책임인지 불명확
3. 로그아웃 (UF-007) 처리 로직이 plan에 없음

### 수정 방안
```dart
// AuthNotifier는 인증 상태만 관리
abstract class AuthNotifier {
  Future<void> logout();
  bool get isAuthenticated;
}

// SettingsScreen에서 로그아웃 처리
class SettingsScreen extends ConsumerWidget {
  void _handleLogout(WidgetRef ref) async {
    final confirmed = await showDialog<bool>(...);
    if (confirmed == true) {
      await ref.read(authNotifierProvider.notifier).logout();
      context.go('/login');
    }
  }
}
```

**AuthNotifier → ProfileRepository 의존성 제거 필요**.

---

## 4. Business Rules 미반영

### 이슈
spec.md Business Rules:
```
1. 설정 화면은 로그인된 사용자만 접근 가능
2. 사용자 정보는 실시간으로 조회하여 최신 상태 유지
3. 각 설정 메뉴는 명확한 레이블과 설명 제공
4. 로그아웃 메뉴는 목록 하단에 배치
5. 설정 변경 시 사용자 확인 단계 필요
```

plan.md에서 누락:
- Rule 1: 로그인 검증 로직 없음
- Rule 2: 실시간 조회 전략 없음 (캐시 vs 매번 조회)
- Rule 3: 메뉴 설명 UI 계획 없음
- Rule 5: 확인 다이얼로그 테스트 없음

### 수정 방안
```dart
// Rule 1: 로그인 검증
class SettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(authNotifierProvider).isAuthenticated;

    if (!isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const SizedBox.shrink();
    }
    // ...
  }
}

// Rule 2: 실시간 조회 전략
class UserProfileNotifier extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() async {
    // 매번 새로 조회 (실시간 최신 상태 유지)
    final userId = ref.read(authNotifierProvider).currentUserId;
    return await ref.read(profileRepositoryProvider).getUserProfile(userId);
  }
}

// Rule 3: 메뉴 설명 추가
ListTile(
  title: Text('프로필 및 목표 수정'),
  subtitle: Text('이름과 목표 체중을 변경할 수 있습니다.'),  // ← 설명 추가
  onTap: () => context.push('/profile/edit'),
);

// Rule 5: 확인 다이얼로그 테스트
testWidgets('should show confirmation dialog before logout', (tester) async {
  await tester.tap(find.text('로그아웃'));
  await tester.pumpAndSettle();

  expect(find.text('로그아웃 하시겠습니까?'), findsOneWidget);
  expect(find.text('취소'), findsOneWidget);
  expect(find.text('확인'), findsOneWidget);
});
```

---

## 5. Edge Cases 처리 불완전

### 이슈
spec.md의 Edge Cases:
1. **로그인 세션 만료**: UnauthorizedException 처리 테스트만 있음 → 실제 로그인 화면 이동 로직 없음
2. **네트워크 오류**: 캐시 사용 전략 테스트만 있음 → 캐시 구현 계획 없음
3. **데이터 로딩 지연**: 로딩 UI 테스트만 있음 → Timeout 처리 없음

### 수정 방안
```dart
// 1. 세션 만료 처리
class UserProfileNotifier extends AsyncNotifier<UserProfile> {
  Future<void> loadProfile(String userId) async {
    state = const AsyncValue.loading();

    try {
      final profile = await ref.read(profileRepositoryProvider).getUserProfile(userId);
      state = AsyncValue.data(profile);
    } on UnauthorizedException {
      // 로그아웃 처리
      await ref.read(authNotifierProvider.notifier).logout();
      // SettingsScreen에서 네비게이션 감지
      state = AsyncValue.error('세션이 만료되었습니다', StackTrace.current);
    }
  }
}

// 2. 캐시 전략 (Isar 자동 캐시 활용)
class IsarProfileRepository implements ProfileRepository {
  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      // 원격 조회 시도
      final dto = await _isar.userProfileDtos.get(userId);
      return dto?.toEntity();
    } catch (e) {
      // 실패 시 로컬 캐시 반환
      final cachedDto = _isar.userProfileDtos.getSync(userId);
      if (cachedDto != null) {
        return cachedDto.toEntity();
      }
      rethrow;
    }
  }
}

// 3. Timeout 처리
test('should timeout after 5 seconds', () async {
  when(() => mockRepo.getUserProfile(any()))
    .thenAnswer((_) => Future.delayed(Duration(seconds: 10)));

  await expectLater(
    notifier.loadProfile('user-1').timeout(Duration(seconds: 5)),
    throwsA(isA<TimeoutException>()),
  );
});
```

---

## 6. 모듈 간 상호작용 불명확

### 이슈
plan.md에서 다음 상호작용 누락:
- SettingsScreen → 다른 UF 화면 (UF-007, UF-008, UF-009, UF-012, UF-013)
- UserProfileNotifier ↔ AuthNotifier (userId 공유)
- ProfileRepository ↔ 다른 Feature의 Repository (데이터 일관성)

### 수정 방안
**Dependency Injection 명확화**:
```dart
// UserProfileNotifier는 AuthNotifier에서 userId 가져옴
@riverpod
class UserProfileNotifier extends _$UserProfileNotifier {
  @override
  Future<UserProfile> build() async {
    final authState = ref.watch(authNotifierProvider);
    if (!authState.isAuthenticated) {
      throw UnauthorizedException();
    }

    final userId = authState.currentUserId!;
    return await ref.read(profileRepositoryProvider).getUserProfile(userId);
  }
}

// SettingsScreen은 go_router 사용
class SettingsScreen extends ConsumerWidget {
  final Map<String, String> _menuRoutes = {
    '프로필 및 목표 수정': '/profile/edit',
    '투여 계획 수정': '/dose-plan/edit',
    '주간 기록 목표 조정': '/weekly-goal/edit',
    '푸시 알림 설정': '/notification/settings',
  };
}
```

---

## 7. 테스트 커버리지 누락

### 이슈
plan.md의 QA Sheet에서:
- "각 메뉴 항목 탭 시 올바른 화면 이동" → 자동화 테스트 없음
- "로그아웃 버튼 탭 시 확인 다이얼로그 표시" → 위젯 테스트 없음
- "네트워크 오류 시 재시도 옵션 표시" → 재시도 로직 구현 계획 없음

### 수정 방안
위젯 테스트에 추가:
```dart
// 재시도 로직 테스트
testWidgets('should show retry button on network error', (tester) async {
  when(() => mockNotifier.build())
    .thenReturn(AsyncValue.error(NetworkException(), StackTrace.empty));

  await tester.pumpWidget(...);

  expect(find.text('프로필 정보를 불러올 수 없습니다'), findsOneWidget);
  expect(find.text('다시 시도'), findsOneWidget);

  // 재시도 버튼 탭
  await tester.tap(find.text('다시 시도'));
  await tester.pumpAndSettle();

  verify(() => mockNotifier.loadProfile(any())).called(2);
});

// 확인 다이얼로그 → 로그아웃 플로우
testWidgets('should logout when confirmed', (tester) async {
  await tester.tap(find.text('로그아웃'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('확인'));
  await tester.pumpAndSettle();

  verify(() => mockAuthNotifier.logout()).called(1);
  expect(find.byType(LoginScreen), findsOneWidget);
});
```

---

## 수정 우선순위

### 높음 (구현 차단)
1. ✅ Feature 구조 결정 (settings vs profile 분리)
2. ✅ AuthNotifier 의존성 명확화
3. ✅ 네비게이션 라우팅 계획 추가

### 중간 (기능 완성도)
4. ✅ Business Rules 반영 (로그인 검증, 확인 다이얼로그)
5. ✅ Edge Cases 구체적 구현 (캐시, 세션 만료, Timeout)

### 낮음 (개선 사항)
6. ⚠️ QA Sheet 자동화 테스트 전환
7. ⚠️ 메뉴 설명 UI 추가

---

## 제안 사항

### 1. Feature 분리 (권장)
```
features/profile/          # 재사용 가능한 프로필 관리
features/settings/         # 설정 화면 전용 UI
```

### 2. 네비게이션 중앙화
```dart
// lib/core/router/app_router.dart
final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/settings', builder: (_, __) => SettingsScreen()),
    GoRoute(path: '/profile/edit', builder: (_, __) => ProfileEditScreen()),
    GoRoute(path: '/dose-plan/edit', builder: (_, __) => DosePlanEditScreen()),
    // ...
  ],
);
```

### 3. 통합 테스트 추가
```dart
// test/features/settings/integration/settings_flow_test.dart
testWidgets('complete settings navigation flow', (tester) async {
  // 1. 설정 화면 진입
  await tester.tap(find.byIcon(Icons.settings));
  await tester.pumpAndSettle();

  // 2. 프로필 수정 화면 이동
  await tester.tap(find.text('프로필 및 목표 수정'));
  await tester.pumpAndSettle();

  // 3. 수정 완료 후 설정 화면 복귀
  // ...
});
```

---

## 결론

**plan.md는 프로필 데이터 관리 구현에는 적합하지만, spec.md의 설정 화면 유스케이스를 완전히 반영하지 못함.**

**핵심 수정 사항**:
1. Settings Feature와 Profile Feature 분리
2. 네비게이션 처리 구체화
3. AuthNotifier 의존성 제거
4. Business Rules 전체 반영
5. Edge Cases 구현 로직 추가

수정 후 재검토 필요.
