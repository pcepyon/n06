# 009 UF-SETTINGS 구현 검토 보고서

**검토 일시**: 2025-11-08
**상태**: 부분완료 (중요 문제 있음)

---

## 요약

009 기능 (UF-SETTINGS: 설정 화면)은 **프로덕션 레벨로 완성되지 않았습니다**.

- **구현 상태**: 부분완료 (50%)
- **핵심 문제**: 라우팅 미설정, 대상 화면 미구현, 테스트 케이스 미흡

---

## 1. 구현된 항목

### 1.1. Presentation Layer

#### SettingsScreen (프로덕션 레벨 구현)
- **파일**: `/Users/pro16/Desktop/project/n06/lib/features/settings/presentation/screens/settings_screen.dart`
- **구현 상태**: 완료
- **검증 사항**:
  - ✅ 로그인 상태 검증 (AuthNotifier 사용)
  - ✅ 프로필 데이터 표시 (ProfileNotifier 사용)
  - ✅ 5개 메뉴 항목 렌더링 (레이블 + 설명 포함)
  - ✅ 로그아웃 다이얼로그 구현
  - ✅ 에러 상태 처리 (세션 만료, 네트워크 오류)
  - ✅ 재시도 기능 구현
  - ✅ 로딩 상태 표시

**코드 스니펫 - Spec 준수 확인**:
```dart
// Business Rule 1: 로그인 검증
return authState.when(
  loading: () => Scaffold(...),
  error: (error, stackTrace) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.go('/login');
      }
    });
    return const SizedBox.shrink();
  },
  data: (user) {
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go('/login');
        }
      });
      return const SizedBox.shrink();
    }
    // ...
  },
);

// Business Rule 5: 확인 다이얼로그
Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('로그아웃 하시겠습니까?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('확인'),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    await ref.read(authNotifierProvider.notifier).logout();
    if (context.mounted) {
      context.go('/login');
    }
  }
}
```

#### SettingsMenuItem (프로덕션 레벨 구현)
- **파일**: `/Users/pro16/Desktop/project/n06/lib/features/settings/presentation/widgets/settings_menu_item.dart`
- **구현 상태**: 완료
- **검증 사항**:
  - ✅ 제목, 부제목, 아이콘 표시
  - ✅ 탭 처리

**코드 스니펫**:
```dart
class SettingsMenuItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SettingsMenuItem({
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
    );
  }
}
```

### 1.2. Application Layer

#### ProfileNotifier (프로덕션 레벨 구현)
- **파일**: `/Users/pro16/Desktop/project/n06/lib/features/profile/application/notifiers/profile_notifier.dart`
- **구현 상태**: 완료
- **검증 사항**:
  - ✅ 프로필 데이터 로드
  - ✅ 프로필 업데이트
  - ✅ 캐싱 지원
  - ✅ 에러 처리

**코드 스니펫**:
```dart
@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  Future<UserProfile?> build() async {
    final authState = ref.watch(authNotifierProvider);

    if (!authState.hasValue || authState.value == null) {
      return null;
    }

    try {
      final repository = ref.read(profileRepositoryProvider);
      return await repository.getUserProfile(authState.value!.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadProfile(String userId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(profileRepositoryProvider);
      return await repository.getUserProfile(userId);
    });
  }
}
```

### 1.3. 테스트

#### 구현된 테스트
- **파일**: `/Users/pro16/Desktop/project/n06/test/features/settings/presentation/settings_screen_test.dart`
- **구현 상태**: 부분완료
- **구현된 테스트** (2개):
  1. ✅ SettingsMenuItem 제목, 부제목 표시 테스트
  2. ✅ SettingsMenuItem 탭 가능성 테스트

**코드 스니펫**:
```dart
testWidgets('SettingsMenuItem should display title and subtitle',
    (WidgetTester tester) async {
  // Arrange
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SettingsMenuItem(
          title: 'Test Title',
          subtitle: 'Test Subtitle',
          onTap: () {},
        ),
      ),
    ),
  );

  // Assert
  expect(find.text('Test Title'), findsOneWidget);
  expect(find.text('Test Subtitle'), findsOneWidget);
  expect(find.byIcon(Icons.chevron_right), findsOneWidget);
});
```

---

## 2. 미구현 항목

### 2.1. 라우팅 (Critical)

**문제**: GoRouter가 설정되지 않음
- **파일**: `/Users/pro16/Desktop/project/n06/lib/main.dart`
- **현재 상태**: MaterialApp 사용 (GoRouter 미설정)
- **영향도**: 치명적 (Critical)

**현재 코드**:
```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GLP-1 치료 관리',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
```

**문제점**: SettingsScreen에서 `context.push()`, `context.go()`를 호출하지만 GoRouter가 없어서 작동하지 않음

### 2.2. 대상 화면 미구현 (Critical)

SettingsScreen에서 네비게이션하려는 화면들이 미구현:

1. **UF-008: 프로필 및 목표 수정**
   - 대상: `/profile/edit`
   - 상태: 미구현
   - 영향도: Critical

2. **UF-009: 투여 계획 수정**
   - 대상: `/dose-plan/edit`
   - 상태: 미구현
   - 영향도: Critical

3. **UF-012: 푸시 알림 설정**
   - 대상: `/notification/settings`
   - 상태: 미구현
   - 영향도: Critical

4. **UF-013: 주간 기록 목표 조정**
   - 대상: `/weekly-goal/edit`
   - 상태: 미구현
   - 영향도: Critical

**SettingsScreen의 네비게이션 코드**:
```dart
SettingsMenuItem(
  title: '프로필 및 목표 수정',
  subtitle: '이름과 목표 체중을 변경할 수 있습니다',
  onTap: () => context.push('/profile/edit'),  // UF-008 미구현
),
SettingsMenuItem(
  title: '투여 계획 수정',
  subtitle: '약물 투여 계획을 변경할 수 있습니다',
  onTap: () => context.push('/dose-plan/edit'),  // UF-009 미구현
),
SettingsMenuItem(
  title: '주간 기록 목표 조정',
  subtitle: '주간 체중 및 증상 기록 목표를 설정합니다',
  onTap: () => context.push('/weekly-goal/edit'),  // UF-013 미구현
),
SettingsMenuItem(
  title: '푸시 알림 설정',
  subtitle: '알림 시간과 방식을 설정합니다',
  onTap: () => context.push('/notification/settings'),  // UF-012 미구현
),
```

### 2.3. Plan 요구 테스트 케이스 미흡 (High)

Plan에서 요구한 13개 테스트 중 2개만 구현:

**구현되지 않은 테스트** (11개):
1. ❌ 로그인 검증 테스트 (미인증 시 리다이렉트)
2. ❌ 설정 화면 렌더링 테스트 (5개 메뉴 항목)
3. ❌ 사용자 정보 표시 테스트
4. ❌ 로딩 상태 테스트 (로딩 인디케이터)
5. ❌ 에러 상태 및 재시도 테스트
6. ❌ 세션 만료 처리 테스트
7. ❌ 네비게이션 테스트 - 프로필 수정
8. ❌ 네비게이션 테스트 - 투여 계획
9. ❌ 네비게이션 테스트 - 주간 목표
10. ❌ 네비게이션 테스트 - 알림 설정
11. ❌ 로그아웃 다이얼로그 및 실행 테스트

**현재 테스트 파일 라인**: 50줄 (의도: 매우 짧음)

---

## 3. 개선 필요사항

### 3.1. 1순위 (Blocking)

#### 1. GoRouter 설정 필수
- **작업**: main.dart에서 GoRouter 설정
- **예상 노력**: 2-3시간
- **예상 코드**:
```dart
final router = GoRouter(
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    GoRoute(path: '/profile/edit', builder: (_, __) => const ProfileEditScreen()),
    GoRoute(path: '/dose-plan/edit', builder: (_, __) => const DosePlanScreen()),
    GoRoute(path: '/weekly-goal/edit', builder: (_, __) => const WeeklyGoalScreen()),
    GoRoute(path: '/notification/settings', builder: (_, __) => const NotificationSettingsScreen()),
  ],
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GLP-1 치료 관리',
      theme: ThemeData(...),
      routerConfig: router,
    );
  }
}
```

#### 2. 대상 화면 구현
- **UF-008**: ProfileEditScreen (프로필 수정)
- **UF-009**: DosePlanScreen (투여 계획 수정)
- **UF-012**: NotificationSettingsScreen (알림 설정)
- **UF-013**: WeeklyGoalScreen (주간 목표 조정)

각 화면의 spec/plan 문서 생성 필요

### 3.2. 2순위 (Must Have)

#### 1. 테스트 케이스 추가 (11개)
- **파일**: `test/features/settings/presentation/settings_screen_test.dart`
- **필요한 테스트**:
  - 로그인 검증 (AuthNotifier 목킹)
  - 메뉴 렌더링 (프로필 데이터 표시)
  - 에러 상태 (재시도 포함)
  - 네비게이션 (5개 화면)
  - 로그아웃 다이얼로그

**예상 테스트 구조**:
```dart
group('SettingsScreen - 로그인 검증', () {
  testWidgets('should redirect to login when not authenticated', ...);
});

group('SettingsScreen - 메뉴 렌더링', () {
  testWidgets('should display settings menu items', ...);
  testWidgets('should display user information', ...);
});

group('SettingsScreen - 상태 관리', () {
  testWidgets('should show loading indicator', ...);
  testWidgets('should show error with retry', ...);
  testWidgets('should handle session expired', ...);
});

group('SettingsScreen - 네비게이션', () {
  testWidgets('should navigate to profile edit', ...);
  testWidgets('should navigate to dose plan', ...);
  testWidgets('should navigate to weekly goal', ...);
  testWidgets('should navigate to notification', ...);
});

group('SettingsScreen - 로그아웃', () {
  testWidgets('should show logout dialog', ...);
  testWidgets('should execute logout on confirm', ...);
  testWidgets('should cancel logout on dismiss', ...);
});
```

#### 2. Integration 테스트
- 설정 화면 → 다른 화면 전환 테스트
- 라우팅 플로우 검증

---

## 4. 코드 검증 결과

### 4.1. Spec 준수 확인

| 요구사항 | 구현 | 검증 |
|---------|------|------|
| 로그인 상태 확인 | ✅ 완료 | AuthNotifier 통합 |
| 사용자 정보 표시 | ✅ 완료 | ProfileNotifier 통합 |
| 5개 메뉴 항목 렌더링 | ✅ 완료 | 레이블+설명 포함 |
| 로그아웃 다이얼로그 | ✅ 완료 | AlertDialog 구현 |
| 로딩 상태 처리 | ✅ 완료 | CircularProgressIndicator |
| 세션 만료 처리 | ✅ 완료 | Unauthorized 감지 |
| 네트워크 오류 + 재시도 | ✅ 완료 | ElevatedButton 제공 |

### 4.2. Architecture 검증

```
SettingsScreen (Presentation)
  ├── AuthNotifier (Application, Auth Feature)
  ├── ProfileNotifier (Application, Profile Feature)
  └── GoRouter (Infrastructure, Core)
       └── Navigation Targets (미구현)
```

**Layer Dependency 준수**: ✅ 완료
**Repository Pattern 준수**: ✅ 완료 (Profile, Auth)

---

## 5. 테스트 결과

```bash
$ flutter test test/features/settings/presentation/settings_screen_test.dart

00:01 +2: All tests passed!

SettingsScreen Widget Tests
  ✓ SettingsMenuItem should display title and subtitle
  ✓ SettingsMenuItem should be tappable
```

**통과**: 2개 / **실패**: 0개 / **미구현**: 11개

---

## 6. 프로덕션 레벨 평가

### 현재 상태: 부분완료 (프로덕션 배포 불가)

**가능한 부분**:
- SettingsScreen UI 렌더링
- 프로필 데이터 표시
- 로그아웃 기능
- 에러 처리

**불가능한 부분**:
- 실제 네비게이션 (GoRouter 미설정)
- 대상 화면 전환 (4개 화면 미구현)
- 완전한 테스트 커버리지 (13개 중 2개만 구현)

---

## 7. 마이그레이션 계획 (Phase 0→1)

**영향도**: 미미 (GoRouter 설정 후 1줄 변경만 필요)

```dart
// Phase 0 (현재)
// main.dart에서 GoRouter 설정 필요

// Phase 1 전환 시
// ProfileNotifier는 변경 없음
// SettingsScreen도 변경 없음
// 라우팅만 변경
```

---

## 8. 결론

009 기능은 **UI 및 비즈니스 로직은 완성되었으나, 라우팅 인프라와 대상 화면이 미구현되어 프로덕션 배포 불가능**합니다.

### 완료 체크리스트

- [x] SettingsScreen 위젯 구현
- [x] SettingsMenuItem 위젯 구현
- [x] 로그인 검증 로직
- [x] 프로필 데이터 연동
- [x] 에러 처리 및 재시도
- [x] 로그아웃 다이얼로그
- [ ] GoRouter 설정
- [ ] 4개 대상 화면 구현
- [ ] 13개 테스트 케이스 구현
- [ ] Integration 테스트

### 다음 단계

1. **즉시** (1-2일): GoRouter 설정 + main.dart 수정
2. **병행** (3-5일): 4개 대상 화면 구현 (UF-008, 009, 012, 013)
3. **완성** (2-3일): 11개 테스트 케이스 추가 + Integration 테스트

**예상 소요 시간**: 1-2주

---

## 부록: 파일 목록

### 구현된 파일
- `/Users/pro16/Desktop/project/n06/lib/features/settings/presentation/screens/settings_screen.dart` (239줄)
- `/Users/pro16/Desktop/project/n06/lib/features/settings/presentation/widgets/settings_menu_item.dart` (27줄)
- `/Users/pro16/Desktop/project/n06/lib/features/profile/application/notifiers/profile_notifier.dart` (64줄)
- `/Users/pro16/Desktop/project/n06/lib/features/profile/domain/repositories/profile_repository.dart` (16줄)
- `/Users/pro16/Desktop/project/n06/test/features/settings/presentation/settings_screen_test.dart` (50줄)

### 미구현 파일
- `lib/features/profile/presentation/screens/profile_edit_screen.dart` (UF-008)
- `lib/features/tracking/presentation/screens/dose_plan_screen.dart` (UF-009)
- `lib/features/[notification]/presentation/screens/notification_settings_screen.dart` (UF-012)
- `lib/features/[weekly-goal]/presentation/screens/weekly_goal_screen.dart` (UF-013)

### 미설정 구성 파일
- `lib/core/routing/app_router.dart` (GoRouter 설정 필요)
- `lib/main.dart` (MaterialApp.router 설정 필요)
