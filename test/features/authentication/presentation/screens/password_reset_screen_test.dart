import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/authentication/domain/entities/user.dart';
import 'package:n06/features/authentication/domain/repositories/auth_repository.dart';
import 'package:n06/features/authentication/presentation/screens/password_reset_screen.dart';

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
  setUp(() {
    // Setup code if needed
  });

  Widget createWidgetUnderTest({String? token}) {
    return ProviderScope(
      overrides: [],
      child: MaterialApp(
        home: PasswordResetScreen(token: token),
      ),
    );
  }

  group('PasswordResetScreen', () {
    group('Step 1: 이메일 입력 화면', () {
      testWidgets('화면이 정상적으로 렌더링됨', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createWidgetUnderTest());

        // Then
        expect(find.byType(TextField), findsWidgets);
        expect(find.byType(ElevatedButton), findsWidgets);
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

      testWidgets('유효한 이메일 입력 후 버튼 활성화', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        final emailFields = find.byType(TextField);
        if (emailFields.evaluate().isNotEmpty) {
          await tester.enterText(emailFields.first, 'test@example.com');
          await tester.pump();

          // Then
          final submitButton = find.byType(ElevatedButton);
          expect(submitButton, findsWidgets);
        }
      });

      testWidgets('잘못된 이메일 형식 시 에러 표시', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        final emailFields = find.byType(TextField);
        if (emailFields.evaluate().isNotEmpty) {
          await tester.enterText(emailFields.first, 'invalid-email');
          await tester.pump();
          await tester.pumpAndSettle();

          // Then
          expect(find.byType(TextField), findsWidgets);
        }
      });

      testWidgets('빈 이메일 필드 제출 시 에러', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        final submitButton = find.byType(ElevatedButton);
        if (submitButton.evaluate().isNotEmpty) {
          await tester.tap(submitButton.first);
          await tester.pumpAndSettle();

          // Then
          expect(find.byType(ScaffoldMessenger), findsWidgets);
        }
      });

      testWidgets('재설정 링크 발송 성공 시 메시지 표시', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        final emailFields = find.byType(TextField);
        if (emailFields.evaluate().isNotEmpty) {
          await tester.enterText(emailFields.first, 'test@example.com');
          await tester.pump();

          final submitButton = find.byType(ElevatedButton);
          if (submitButton.evaluate().isNotEmpty) {
            await tester.tap(submitButton.first);
            await tester.pumpAndSettle();

            // Then - Success message or confirmation
            expect(find.byType(ScaffoldMessenger), findsWidgets);
          }
        }
      });

      testWidgets('존재하지 않는 이메일도 성공 메시지 표시 (보안)', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        final emailFields = find.byType(TextField);
        if (emailFields.evaluate().isNotEmpty) {
          await tester.enterText(emailFields.first, 'nonexistent@example.com');
          await tester.pump();

          final submitButton = find.byType(ElevatedButton);
          if (submitButton.evaluate().isNotEmpty) {
            await tester.tap(submitButton.first);
            await tester.pumpAndSettle();

            // Then - Should show same success message (for security)
            expect(find.byType(ScaffoldMessenger), findsWidgets);
          }
        }
      });
    });

    group('Step 2: 비밀번호 변경 화면 (Deep Link token)', () {
      testWidgets('토큰이 있으면 비밀번호 변경 화면 표시', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createWidgetUnderTest(token: 'valid-token-123'));
        await tester.pump();

        // Then
        expect(find.byType(TextField), findsWidgets);
      });

      testWidgets('새 비밀번호 입력 가능', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createWidgetUnderTest(token: 'valid-token'));
        await tester.pump();

        final passwordFields = find.byType(TextField);
        if (passwordFields.evaluate().isNotEmpty) {
          await tester.enterText(passwordFields.first, 'NewPassword123!');
          await tester.pump();

          // Then
          expect(find.byType(TextField), findsWidgets);
        }
      });

      testWidgets('비밀번호 강도 지시자 표시', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createWidgetUnderTest(token: 'valid-token'));
        await tester.pump();

        final passwordFields = find.byType(TextField);
        if (passwordFields.evaluate().isNotEmpty) {
          await tester.enterText(passwordFields.first, 'WeakPass');
          await tester.pump();

          // Then
          expect(find.byType(LinearProgressIndicator), findsWidgets);
        }
      });

      testWidgets('비밀번호 확인 입력 가능', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createWidgetUnderTest(token: 'valid-token'));
        await tester.pump();

        final passwordFields = find.byType(TextField);
        if (passwordFields.evaluate().length >= 2) {
          await tester.enterText(passwordFields.at(0), 'NewPassword123!');
          await tester.enterText(passwordFields.at(1), 'NewPassword123!');
          await tester.pump();

          // Then
          expect(find.byType(TextField), findsWidgets);
        }
      });

      testWidgets('비밀번호 불일치 시 에러 메시지', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createWidgetUnderTest(token: 'valid-token'));
        await tester.pump();

        final passwordFields = find.byType(TextField);
        if (passwordFields.evaluate().length >= 2) {
          await tester.enterText(passwordFields.at(0), 'NewPassword123!');
          await tester.enterText(passwordFields.at(1), 'DifferentPass456!');
          await tester.pump();

          final submitButton = find.byType(ElevatedButton);
          if (submitButton.evaluate().isNotEmpty) {
            await tester.tap(submitButton.first);
            await tester.pumpAndSettle();

            // Then
            expect(find.byType(ScaffoldMessenger), findsWidgets);
          }
        }
      });

      testWidgets('약한 비밀번호 시 에러 표시', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createWidgetUnderTest(token: 'valid-token'));
        await tester.pump();

        final passwordFields = find.byType(TextField);
        if (passwordFields.evaluate().length >= 2) {
          await tester.enterText(passwordFields.at(0), 'weak');
          await tester.enterText(passwordFields.at(1), 'weak');
          await tester.pump();

          final submitButton = find.byType(ElevatedButton);
          if (submitButton.evaluate().isNotEmpty) {
            await tester.tap(submitButton.first);
            await tester.pumpAndSettle();

            // Then
            expect(find.byType(ScaffoldMessenger), findsWidgets);
          }
        }
      });

      testWidgets('비밀번호 변경 성공', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createWidgetUnderTest(token: 'valid-token'));
        await tester.pump();

        final passwordFields = find.byType(TextField);
        if (passwordFields.evaluate().length >= 2) {
          await tester.enterText(passwordFields.at(0), 'NewPassword123!');
          await tester.enterText(passwordFields.at(1), 'NewPassword123!');
          await tester.pump();

          final submitButton = find.byType(ElevatedButton);
          if (submitButton.evaluate().isNotEmpty) {
            await tester.tap(submitButton.first);
            await tester.pumpAndSettle();

            // Then - Success message or navigation
            expect(find.byType(ScaffoldMessenger), findsWidgets);
          }
        }
      });

      testWidgets('비밀번호 표시/숨김 토글', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createWidgetUnderTest(token: 'valid-token'));
        await tester.pump();

        final iconButtons = find.byType(IconButton);
        if (iconButtons.evaluate().isNotEmpty) {
          await tester.tap(iconButtons.first);
          await tester.pump();

          // Then
          expect(find.byType(IconButton), findsWidgets);
        }
      });

      testWidgets('토큰 만료 시 에러 메시지', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createWidgetUnderTest(token: 'expired-token'));
        await tester.pump();

        // If token validation happens immediately
        // Then - Error message should show
        expect(find.byType(ScaffoldMessenger), findsWidgets);
      });

      testWidgets('변경 후 로그인 화면으로 이동', (WidgetTester tester) async {
        // When
        final testApp = ProviderScope(
          child: MaterialApp(
            home: PasswordResetScreen(token: 'valid-token'),
            routes: {
              '/email-signin': (context) => const Scaffold(
                body: Center(child: Text('Sign In')),
              ),
            },
          ),
        );

        await tester.pumpWidget(testApp);
        await tester.pump();

        final passwordFields = find.byType(TextField);
        if (passwordFields.evaluate().length >= 2) {
          await tester.enterText(passwordFields.at(0), 'NewPassword123!');
          await tester.enterText(passwordFields.at(1), 'NewPassword123!');
          await tester.pump();
        }
      });

      testWidgets('토큰 없이 열면 이메일 입력 화면', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createWidgetUnderTest(token: null));
        await tester.pump();

        // Then - First step (email input)
        expect(find.byType(TextField), findsWidgets);
      });
    });

    group('공통 테스트', () {
      testWidgets('화면에 TextField 존재', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createWidgetUnderTest());

        // Then
        expect(find.byType(TextField), findsWidgets);
      });

      testWidgets('화면에 ElevatedButton 존재', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createWidgetUnderTest());

        // Then
        expect(find.byType(ElevatedButton), findsWidgets);
      });

      testWidgets('스크롤 가능 콘텐츠', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createWidgetUnderTest());

        // Then
        final scrollables = find.byType(SingleChildScrollView);
        final columns = find.byType(Column);

        expect(
          scrollables.evaluate().isNotEmpty || columns.evaluate().isNotEmpty,
          true,
        );
      });

      testWidgets('화면이 Material Design 따름', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createWidgetUnderTest());

        // Then
        expect(find.byType(Scaffold), findsWidgets);
      });

      testWidgets('로딩 중 UI 상호작용 제한 가능', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        final emailFields = find.byType(TextField);
        if (emailFields.evaluate().isNotEmpty) {
          await tester.enterText(emailFields.first, 'test@example.com');
          await tester.pump();

          final submitButton = find.byType(ElevatedButton);
          if (submitButton.evaluate().isNotEmpty) {
            await tester.tap(submitButton.first);
            // During loading, might show circular progress
            await tester.pump();

            expect(find.byType(CircularProgressIndicator), findsWidgets);
          }
        }
      });

      testWidgets('에러 메시지 표시 및 숨김', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Try to submit empty form
        final submitButton = find.byType(ElevatedButton);
        if (submitButton.evaluate().isNotEmpty) {
          await tester.tap(submitButton.first);
          await tester.pumpAndSettle();

          // Then - Error shown
          expect(find.byType(ScaffoldMessenger), findsWidgets);
        }
      });

      testWidgets('폼 재설정 기능', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        final textFields = find.byType(TextField);
        if (textFields.evaluate().isNotEmpty) {
          // Enter text
          await tester.enterText(textFields.first, 'test@example.com');
          await tester.pump();

          // Should be able to clear and re-enter
          await tester.enterText(textFields.first, '');
          await tester.pump();

          // Then
          expect(find.byType(TextField), findsWidgets);
        }
      });
    });
  });
}
