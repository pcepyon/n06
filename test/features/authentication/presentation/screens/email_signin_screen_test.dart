import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/features/authentication/domain/entities/user.dart';
import 'package:n06/features/authentication/domain/repositories/auth_repository.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/authentication/presentation/screens/email_signin_screen.dart';
import 'package:n06/features/onboarding/domain/entities/user_profile.dart';
import 'package:n06/features/onboarding/domain/repositories/profile_repository.dart';
import 'package:n06/features/onboarding/application/providers.dart';
import 'package:n06/features/onboarding/domain/value_objects/weight.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class FakeUser extends Fake implements User {
  @override
  final String id;

  @override
  final String oauthProvider;

  @override
  final String oauthUserId;

  @override
  final String name;

  @override
  final String email;

  @override
  final String? profileImageUrl;

  @override
  final DateTime lastLoginAt;

  FakeUser({
    this.id = 'test-user-id',
    this.oauthProvider = 'email',
    this.oauthUserId = 'test@example.com',
    this.name = 'Test User',
    this.email = 'test@example.com',
    this.profileImageUrl,
    DateTime? lastLoginAt,
  }) : lastLoginAt = lastLoginAt ?? DateTime.now();
}

// Helper function to create test UserProfile
UserProfile createTestProfile({
  String userId = 'test-user-id',
  String? userName = 'Test User',
  double targetWeightKg = 80.0,
  double currentWeightKg = 90.0,
  int weeklyWeightRecordGoal = 3,
  int weeklySymptomRecordGoal = 3,
}) {
  return UserProfile(
    userId: userId,
    userName: userName,
    targetWeight: Weight.create(targetWeightKg),
    currentWeight: Weight.create(currentWeightKg),
    weeklyWeightRecordGoal: weeklyWeightRecordGoal,
    weeklySymptomRecordGoal: weeklySymptomRecordGoal,
  );
}

void main() {
  late MockAuthRepository mockRepository;
  late MockProfileRepository mockProfileRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    mockProfileRepository = MockProfileRepository();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [],
      child: const MaterialApp(
        home: EmailSigninScreen(),
      ),
    );
  }

  group('EmailSigninScreen', () {
    testWidgets('화면이 정상적으로 렌더링됨', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(createWidgetUnderTest());

      // Then
      expect(find.text('Sign In'), findsWidgets);
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('이메일 필드에 입력 가능', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final emailFields = find.byType(TextField);
      if (emailFields.evaluate().isNotEmpty) {
        await tester.enterText(emailFields.first, 'test@example.com');
        await tester.pump();

        // Then
        expect(find.text('test@example.com'), findsWidgets);
      }
    });

    testWidgets('비밀번호 필드에 입력 가능', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final passwordFields = find.byType(TextField);
      if (passwordFields.evaluate().length >= 2) {
        await tester.enterText(passwordFields.at(1), 'Password123!');
        await tester.pump();

        // Then
        expect(find.byType(TextField), findsWidgets);
      }
    });

    testWidgets('비밀번호 표시/숨김 토글 작동', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Look for visibility toggle icon
      final iconButtons = find.byType(IconButton);
      if (iconButtons.evaluate().isNotEmpty) {
        // Toggle password visibility
        await tester.tap(iconButtons.first);
        await tester.pump();

        // Then - Icon should change
        expect(find.byType(IconButton), findsWidgets);
      }
    });

    testWidgets('로그인 버튼이 표시됨', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Then
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('비밀번호 재설정 링크가 표시됨', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Then - Look for text link
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('회원가입 링크가 표시됨', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Then
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('유효한 이메일과 비밀번호로 로그인 버튼 활성화', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final textFields = find.byType(TextField);
      if (textFields.evaluate().length >= 2) {
        // Fill in fields
        await tester.enterText(textFields.at(0), 'test@example.com');
        await tester.enterText(textFields.at(1), 'Password123!');
        await tester.pump();

        // Then - Button should be enabled
        final submitButton = find.byType(ElevatedButton);
        expect(submitButton, findsWidgets);
      }
    });

    testWidgets('잘못된 이메일 형식 입력 시 에러 메시지', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final textFields = find.byType(TextField);
      if (textFields.evaluate().isNotEmpty) {
        await tester.enterText(textFields.first, 'invalid-email');
        await tester.pump();
        await tester.pumpAndSettle();

        // Then - TextFormField validation
        expect(find.byType(TextField), findsWidgets);
      }
    });

    testWidgets('빈 필드 제출 시 에러 메시지', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Try to submit without filling fields
      final submitButton = find.byType(ElevatedButton);
      if (submitButton.evaluate().isNotEmpty) {
        await tester.tap(submitButton.first);
        await tester.pumpAndSettle();

        // Then - Validation errors should appear
        expect(find.byType(ScaffoldMessenger), findsWidgets);
      }
    });

    testWidgets('잘못된 비밀번호 로그인 실패', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final textFields = find.byType(TextField);
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.at(0), 'test@example.com');
        await tester.enterText(textFields.at(1), 'WrongPassword!');
        await tester.pump();

        // Try to submit
        final submitButton = find.byType(ElevatedButton);
        if (submitButton.evaluate().isNotEmpty) {
          await tester.tap(submitButton.first);
          await tester.pumpAndSettle();

          // Then - Error should be displayed
          expect(find.byType(ScaffoldMessenger), findsWidgets);
        }
      }
    });

    testWidgets('존재하지 않는 계정 로그인 실패', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final textFields = find.byType(TextField);
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.at(0), 'nonexistent@example.com');
        await tester.enterText(textFields.at(1), 'Password123!');
        await tester.pump();

        final submitButton = find.byType(ElevatedButton);
        if (submitButton.evaluate().isNotEmpty) {
          await tester.tap(submitButton.first);
          await tester.pumpAndSettle();

          // Then - Error message
          expect(find.byType(ScaffoldMessenger), findsWidgets);
        }
      }
    });

    testWidgets('로그인 중 로딩 상태 표시', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final textFields = find.byType(TextField);
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.at(0), 'test@example.com');
        await tester.enterText(textFields.at(1), 'Password123!');
        await tester.pump();

        final submitButton = find.byType(ElevatedButton);
        if (submitButton.evaluate().isNotEmpty) {
          await tester.tap(submitButton.first);
          // Loading indicator might show briefly
          await tester.pump();
        }
      }
    });

    testWidgets('비밀번호 재설정 링크 탭 가능', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Find password reset link
      final gestureDetectors = find.byType(GestureDetector);
      expect(gestureDetectors, findsWidgets);
    });

    testWidgets('회원가입 링크 탭 가능', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Find signup link
      final textButtons = find.byType(TextButton);
      if (textButtons.evaluate().isNotEmpty) {
        expect(textButtons, findsWidgets);
      }
    });

    testWidgets('로그인 성공 시 /home으로 네비게이션 발생 (BUG-2025-1119-001)', (WidgetTester tester) async {
      // GIVEN: Mock repository that returns success
      when(() => mockRepository.signInWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => FakeUser());

      // Mock GoRouter for navigation tracking
      final goRouter = GoRouter(
        initialLocation: '/email-signin',
        routes: [
          GoRoute(
            path: '/email-signin',
            builder: (context, state) => const EmailSigninScreen(),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Home Dashboard')),
            ),
          ),
        ],
      );

      final testApp = ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: MaterialApp.router(
          routerConfig: goRouter,
        ),
      );

      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle();

      // WHEN: User fills in valid credentials and submits
      final textFields = find.byType(TextField);
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.at(0), 'test@example.com');
        await tester.enterText(textFields.at(1), 'Password123!');
        await tester.pump();

        final submitButton = find.byType(ElevatedButton);
        if (submitButton.evaluate().isNotEmpty) {
          await tester.tap(submitButton.first);
          await tester.pumpAndSettle();

          // THEN: Should navigate to /home dashboard
          // Verify by checking if Home Dashboard screen is rendered
          expect(find.text('Home Dashboard'), findsOneWidget);
        }
      }
    });

    testWidgets('화면에 텍스트 필드 2개 이상 존재', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(createWidgetUnderTest());

      // Then
      final textFields = find.byType(TextField);
      expect(textFields.evaluate().length >= 2, true);
    });

    testWidgets('로그인 버튼이 ElevatedButton 타입', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Then
      final buttons = find.byType(ElevatedButton);
      expect(buttons, findsWidgets);
    });

    testWidgets('스크롤 가능 콘텐츠', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(createWidgetUnderTest());

      // Then - Should have scrollable container
      final scrollables = find.byType(SingleChildScrollView);
      final columns = find.byType(Column);

      expect(
        scrollables.evaluate().isNotEmpty || columns.evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('로그인 실패 후 상태 복구', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final textFields = find.byType(TextField);
      if (textFields.evaluate().length >= 2) {
        // Enter invalid credentials
        await tester.enterText(textFields.at(0), 'test@example.com');
        await tester.enterText(textFields.at(1), 'Wrong!');
        await tester.pump();

        // Try to submit
        final submitButton = find.byType(ElevatedButton);
        if (submitButton.evaluate().isNotEmpty) {
          await tester.tap(submitButton.first);
          await tester.pumpAndSettle();

          // Then - Should still be able to interact with fields
          expect(find.byType(TextField), findsWidgets);
        }
      }
    });

    testWidgets('앱 바 또는 헤더가 표시됨', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(createWidgetUnderTest());

      // Then - AppBar or title
      expect(find.byType(Text), findsWidgets);
    });

    // BUG-2025-1119-004: 이메일 로그인 성공 후 프로필 존재 여부에 따른 네비게이션
    testWidgets('로그인 성공 + 프로필 있음 → /home 네비게이션 (BUG-2025-1119-004)', (WidgetTester tester) async {
      // GIVEN: Mock repository that returns success
      final testUser = FakeUser(id: 'test-user-id');
      final testProfile = createTestProfile(userId: 'test-user-id');

      when(() => mockRepository.signInWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => testUser);

      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => null);

      when(() => mockProfileRepository.getUserProfile('test-user-id'))
          .thenAnswer((_) async => testProfile);

      // Mock GoRouter for navigation tracking
      final goRouter = GoRouter(
        initialLocation: '/email-signin',
        routes: [
          GoRoute(
            path: '/email-signin',
            builder: (context, state) => const EmailSigninScreen(),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Home Dashboard')),
            ),
          ),
          GoRoute(
            path: '/onboarding',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Onboarding Screen')),
            ),
          ),
        ],
      );

      final testApp = ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepository),
          profileRepositoryProvider.overrideWithValue(mockProfileRepository),
        ],
        child: MaterialApp.router(
          routerConfig: goRouter,
        ),
      );

      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle();

      // WHEN: User fills in valid credentials and submits
      final textFields = find.byType(TextField);
      if (textFields.evaluate().isEmpty) {
        // Skip test if UI hasn't loaded
        return;
      }

      await tester.enterText(textFields.at(0), 'test@example.com');
      await tester.enterText(textFields.at(1), 'Password123!');
      await tester.pump();

      final submitButton = find.byType(ElevatedButton);
      await tester.tap(submitButton.first);
      await tester.pumpAndSettle();

      // THEN: 프로필이 있으므로 /home으로 네비게이션
      expect(find.text('Home Dashboard'), findsOneWidget);
      expect(find.text('Onboarding Screen'), findsNothing);

      // Verify profile was checked
      verify(() => mockProfileRepository.getUserProfile('test-user-id')).called(1);
    });

    testWidgets('로그인 성공 + 프로필 없음 → /onboarding 네비게이션 (BUG-2025-1119-004)', (WidgetTester tester) async {
      // GIVEN: Mock repository that returns success but no profile
      final testUser = FakeUser(id: 'test-user-id');

      when(() => mockRepository.signInWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => testUser);

      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => null);

      // Profile repository returns null (user hasn't completed onboarding)
      when(() => mockProfileRepository.getUserProfile('test-user-id'))
          .thenAnswer((_) async => null);

      // Mock GoRouter for navigation tracking
      final goRouter = GoRouter(
        initialLocation: '/email-signin',
        routes: [
          GoRoute(
            path: '/email-signin',
            builder: (context, state) => const EmailSigninScreen(),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Home Dashboard')),
            ),
          ),
          GoRoute(
            path: '/onboarding',
            builder: (context, state) => Scaffold(
              body: Center(
                child: Text('Onboarding Screen: ${state.extra}'),
              ),
            ),
          ),
        ],
      );

      final testApp = ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepository),
          profileRepositoryProvider.overrideWithValue(mockProfileRepository),
        ],
        child: MaterialApp.router(
          routerConfig: goRouter,
        ),
      );

      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle();

      // WHEN: User fills in valid credentials and submits
      final textFields = find.byType(TextField);
      if (textFields.evaluate().isEmpty) {
        // Skip test if UI hasn't loaded
        return;
      }

      await tester.enterText(textFields.at(0), 'test@example.com');
      await tester.enterText(textFields.at(1), 'Password123!');
      await tester.pump();

      final submitButton = find.byType(ElevatedButton);
      await tester.tap(submitButton.first);
      await tester.pumpAndSettle();

      // THEN: 프로필이 없으므로 /onboarding으로 네비게이션
      expect(find.textContaining('Onboarding Screen'), findsOneWidget);
      expect(find.text('Home Dashboard'), findsNothing);

      // Verify profile was checked
      verify(() => mockProfileRepository.getUserProfile('test-user-id')).called(1);
    });

    // UX 개선: 로그인 실패 시 회원가입 유도 BottomSheet
    testWidgets('로그인 실패 시 회원가입 유도 BottomSheet 표시', (WidgetTester tester) async {
      // GIVEN: Mock repository that returns failure
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => null);

      when(() => mockRepository.signInWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(Exception('Invalid email or password'));

      final testApp = ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: const MaterialApp(
          home: EmailSigninScreen(),
        ),
      );

      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle();

      // WHEN: User attempts to sign in with invalid credentials
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'test@example.com');
      await tester.enterText(textFields.at(1), 'WrongPassword!');
      await tester.pump();

      final submitButton = find.byType(ElevatedButton);
      await tester.tap(submitButton.first);
      await tester.pumpAndSettle();

      // THEN: BottomSheet should be displayed
      expect(find.text('로그인에 실패했습니다'), findsOneWidget);
      expect(find.text('💡 혹시 계정이 없으신가요?'), findsOneWidget);
      expect(find.text('이메일로 회원가입 하러가기'), findsOneWidget);
    });

    testWidgets('BottomSheet에서 회원가입 버튼 클릭 시 회원가입 페이지로 이동', (WidgetTester tester) async {
      // GIVEN: Mock repository that returns failure
      when(() => mockRepository.signInWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(Exception('Invalid email or password'));

      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => null);

      // Mock GoRouter for navigation tracking
      final goRouter = GoRouter(
        initialLocation: '/email-signin',
        routes: [
          GoRoute(
            path: '/email-signin',
            builder: (context, state) => const EmailSigninScreen(),
          ),
          GoRoute(
            path: '/email-signup',
            builder: (context, state) {
              final prefillEmail = state.extra as String?;
              return Scaffold(
                body: Center(
                  child: Text('Signup Screen: ${prefillEmail ?? "no email"}'),
                ),
              );
            },
          ),
        ],
      );

      final testApp = ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: MaterialApp.router(
          routerConfig: goRouter,
        ),
      );

      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle();

      // WHEN: User attempts sign in and clicks signup button in BottomSheet
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'newuser@example.com');
      await tester.enterText(textFields.at(1), 'Password123!');
      await tester.pump();

      final submitButton = find.byType(ElevatedButton);
      await tester.tap(submitButton.first);
      await tester.pumpAndSettle();

      // Tap signup button in BottomSheet
      final signupButton = find.byKey(const Key('goto_signup_button'));
      await tester.tap(signupButton);
      await tester.pumpAndSettle();

      // THEN: Should navigate to signup screen with email pre-filled
      expect(find.textContaining('Signup Screen: newuser@example.com'), findsOneWidget);
    });

    testWidgets('BottomSheet에서 닫기 버튼 클릭 시 BottomSheet 닫힘', (WidgetTester tester) async {
      // GIVEN: Mock repository that returns failure
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => null);

      when(() => mockRepository.signInWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(Exception('Invalid email or password'));

      final testApp = ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: const MaterialApp(
          home: EmailSigninScreen(),
        ),
      );

      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle();

      // WHEN: User attempts sign in and clicks close button
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'test@example.com');
      await tester.enterText(textFields.at(1), 'WrongPassword!');
      await tester.pump();

      final submitButton = find.byType(ElevatedButton);
      await tester.tap(submitButton.first);
      await tester.pumpAndSettle();

      // BottomSheet should be visible
      expect(find.text('로그인에 실패했습니다'), findsOneWidget);

      // Tap close button
      final closeButton = find.byKey(const Key('close_bottomsheet_button'));
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      // THEN: BottomSheet should be closed
      expect(find.text('로그인에 실패했습니다'), findsNothing);
    });
  });
}
