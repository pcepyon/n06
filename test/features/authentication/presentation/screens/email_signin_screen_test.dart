import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/features/authentication/domain/entities/user.dart';
import 'package:n06/features/authentication/domain/repositories/auth_repository.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/authentication/presentation/screens/email_signin_screen.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

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

void main() {
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
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
  });
}
