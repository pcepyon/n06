import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';
import 'package:n06/features/authentication/domain/entities/user.dart';
import 'package:n06/features/authentication/domain/repositories/auth_repository.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';

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
  group('AuthNotifier - Email Authentication', () {
    late ProviderContainer container;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    group('signUpWithEmail', () {
      test('[BUG-2025-1119-003] 회원가입 성공 시 User 객체를 직접 반환', () async {
        // Given
        final testUser = FakeUser(
          id: 'new-user-id',
          email: 'newuser@example.com',
        );

        when(() => mockRepository.signUpWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => testUser);

        // When
        final authNotifier = container.read(authProvider.notifier);
        final result = await authNotifier.signUpWithEmail(
          email: 'newuser@example.com',
          password: 'Password123!',
          agreedToTerms: true,
          agreedToPrivacy: true,
        );

        // Then
        expect(result, isA<User>()); // User 객체 반환
        expect(result.id, 'new-user-id');
        expect(result.email, 'newuser@example.com');

        // State도 업데이트되어야 함
        final state = container.read(authProvider);
        expect(state.hasValue, true);
        expect(state.asData?.value?.email, 'newuser@example.com');
      });

      test('회원가입 성공 시 state가 AsyncData<User>로 변경', () async {
        // Given
        final testUser = FakeUser(
          email: 'newuser@example.com',
        );

        when(() => mockRepository.signUpWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => testUser);

        // When
        final authNotifier = container.read(authProvider.notifier);
        final result = await authNotifier.signUpWithEmail(
          email: 'newuser@example.com',
          password: 'Password123!',
          agreedToTerms: true,
          agreedToPrivacy: true,
        );

        // Then
        expect(result, isA<User>()); // bool → User 변경
        final state = container.read(authProvider);
        expect(state.hasValue, true);
        expect(state.asData?.value?.email, 'newuser@example.com');
      });

      test('회원가입 실패 시 예외 발생 및 state가 AsyncError로 변경', () async {
        // Given
        when(() => mockRepository.signUpWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(Exception('Email already exists'));

        // When
        final authNotifier = container.read(authProvider.notifier);

        // Then - 예외가 발생해야 함
        expect(
          () => authNotifier.signUpWithEmail(
            email: 'duplicate@example.com',
            password: 'Password123!',
            agreedToTerms: true,
            agreedToPrivacy: true,
          ),
          throwsException,
        );

        // State는 AsyncError여야 함
        await Future.delayed(Duration.zero); // 비동기 처리 대기
        final state = container.read(authProvider);
        expect(state.hasError, true);
      });

      test('회원가입 시 Repository의 signUpWithEmail 호출', () async {
        // Given
        final testUser = FakeUser();

        when(() => mockRepository.signUpWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => testUser);

        when(() => mockRepository.isFirstLogin())
            .thenAnswer((_) async => false);

        // When
        final authNotifier = container.read(authProvider.notifier);
        await authNotifier.signUpWithEmail(
          email: 'test@example.com',
          password: 'ValidPass123!',
          agreedToTerms: true,
          agreedToPrivacy: true,
        );

        // Then
        verify(() => mockRepository.signUpWithEmail(
          email: 'test@example.com',
          password: 'ValidPass123!',
        )).called(1);
      });

      test('약관 미동의 상태에서도 저장 시도 (Notifier는 검증 안함)', () async {
        // Given
        final testUser = FakeUser();

        when(() => mockRepository.signUpWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => testUser);

        // When
        final authNotifier = container.read(authProvider.notifier);
        final result = await authNotifier.signUpWithEmail(
          email: 'test@example.com',
          password: 'Password123!',
          agreedToTerms: false, // 미동의
          agreedToPrivacy: true,
        );

        // Then
        // Notifier는 약관 검증을 하지 않음 (Presentation에서 처리)
        expect(result, isA<User>()); // User 객체 반환
      });

      test('회원가입 항상 User 객체 반환 (isFirstLogin 체크 제거)', () async {
        // Given
        final testUser = FakeUser(id: 'user-123');

        when(() => mockRepository.signUpWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => testUser);

        // When
        final authNotifier = container.read(authProvider.notifier);
        final result = await authNotifier.signUpWithEmail(
          email: 'test@example.com',
          password: 'Password123!',
          agreedToTerms: true,
          agreedToPrivacy: true,
        );

        // Then - isFirstLogin 체크 없이 항상 User 반환
        expect(result, isA<User>());
        expect(result.id, 'user-123');

        // isFirstLogin 호출되지 않아야 함
        verifyNever(() => mockRepository.isFirstLogin());
      });
    });

    group('signInWithEmail', () {
      test('로그인 성공 시 state가 AsyncData<User>로 변경', () async {
        // Given
        final testUser = FakeUser(
          email: 'existing@example.com',
        );

        when(() => mockRepository.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => testUser);

        // When
        final authNotifier = container.read(authProvider.notifier);
        final result = await authNotifier.signInWithEmail(
          email: 'existing@example.com',
          password: 'Password123!',
        );

        // Then
        expect(result, true);
        final state = container.read(authProvider);
        expect(state.hasValue, true);
        expect(state.asData?.value?.email, 'existing@example.com');
      });

      test('로그인 실패 시 state가 AsyncError로 변경', () async {
        // Given
        when(() => mockRepository.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(Exception('Invalid credentials'));

        // When
        final authNotifier = container.read(authProvider.notifier);
        final result = await authNotifier.signInWithEmail(
          email: 'test@example.com',
          password: 'WrongPassword!',
        );

        // Then
        expect(result, false);
        final state = container.read(authProvider);
        expect(state.hasError, true);
      });

      test('존재하지 않는 계정 로그인 시 실패', () async {
        // Given
        when(() => mockRepository.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(Exception('Invalid email or password'));

        // When
        final authNotifier = container.read(authProvider.notifier);
        final result = await authNotifier.signInWithEmail(
          email: 'nonexistent@example.com',
          password: 'Password123!',
        );

        // Then
        expect(result, false);
      });

      test('로그인 시 Repository의 signInWithEmail 호출', () async {
        // Given
        final testUser = FakeUser();

        when(() => mockRepository.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => testUser);

        // When
        final authNotifier = container.read(authProvider.notifier);
        await authNotifier.signInWithEmail(
          email: 'test@example.com',
          password: 'Password123!',
        );

        // Then
        verify(() => mockRepository.signInWithEmail(
          email: 'test@example.com',
          password: 'Password123!',
        )).called(1);
      });
    });

    group('resetPasswordForEmail', () {
      test('재설정 이메일 발송 성공', () async {
        // Given
        when(() => mockRepository.resetPasswordForEmail(any()))
            .thenAnswer((_) async {});

        // When
        final authNotifier = container.read(authProvider.notifier);
        await authNotifier.resetPasswordForEmail('test@example.com');

        // Then
        verify(() => mockRepository.resetPasswordForEmail('test@example.com'))
            .called(1);
      });

      test('존재하지 않는 이메일도 성공 (보안)', () async {
        // Given
        when(() => mockRepository.resetPasswordForEmail(any()))
            .thenAnswer((_) async {});

        // When & Then
        final authNotifier = container.read(authProvider.notifier);
        await authNotifier.resetPasswordForEmail('nonexistent@example.com');
      });

      test('네트워크 오류 시 예외 발생', () async {
        // Given
        when(() => mockRepository.resetPasswordForEmail(any()))
            .thenThrow(Exception('Network error'));

        // When & Then
        final authNotifier = container.read(authProvider.notifier);
        expect(
          () => authNotifier.resetPasswordForEmail('test@example.com'),
          throwsException,
        );
      });
    });

    group('updatePassword', () {
      test('비밀번호 변경 성공', () async {
        // Given
        final updatedUser = FakeUser(
          id: 'user-id',
        );

        when(() => mockRepository.updatePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        )).thenAnswer((_) async => updatedUser);

        // When
        final authNotifier = container.read(authProvider.notifier);
        await authNotifier.updatePassword(
          currentPassword: 'OldPassword123!',
          newPassword: 'NewPassword456!',
        );

        // Then
        final state = container.read(authProvider);
        expect(state.hasValue, true);
        expect(state.asData?.value?.id, 'user-id');
      });

      test('현재 비밀번호 오류 시 예외 발생', () async {
        // Given
        when(() => mockRepository.updatePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        )).thenThrow(Exception('Current password is incorrect'));

        // When & Then
        final authNotifier = container.read(authProvider.notifier);
        expect(
          () => authNotifier.updatePassword(
            currentPassword: 'WrongPassword!',
            newPassword: 'NewPassword456!',
          ),
          throwsException,
        );
      });

      test('비밀번호 변경 시 state가 AsyncError로 변경', () async {
        // Given
        when(() => mockRepository.updatePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        )).thenThrow(Exception('Update failed'));

        // When
        final authNotifier = container.read(authProvider.notifier);
        try {
          await authNotifier.updatePassword(
            currentPassword: 'Password123!',
            newPassword: 'NewPassword456!',
          );
        } catch (_) {
          // Expected to throw
        }

        // Then
        final state = container.read(authProvider);
        expect(state.hasError, true);
      });

      test('Repository의 updatePassword 호출 확인', () async {
        // Given
        final updatedUser = FakeUser();

        when(() => mockRepository.updatePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        )).thenAnswer((_) async => updatedUser);

        // When
        final authNotifier = container.read(authProvider.notifier);
        await authNotifier.updatePassword(
          currentPassword: 'OldPassword123!',
          newPassword: 'NewPassword456!',
        );

        // Then
        verify(() => mockRepository.updatePassword(
          currentPassword: 'OldPassword123!',
          newPassword: 'NewPassword456!',
        )).called(1);
      });
    });
  });
}
