import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n06/features/authentication/infrastructure/repositories/supabase_auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockAuthResponse extends Mock implements AuthResponse {}
class MockUser extends Mock implements User {}
class MockUserResponse extends Mock implements UserResponse {}

// Fallback value for UserAttributes
class FakeUserAttributes extends Fake implements UserAttributes {}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;

  setUpAll(() {
    // Register fallback values for Mocktail
    registerFallbackValue(FakeUserAttributes());
  });

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();

    // Setup default mock behavior
    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);

    // Default: provide empty stream for onAuthStateChange
    when(() => mockGoTrueClient.onAuthStateChange)
        .thenAnswer((_) => const Stream<AuthState>.empty());
  });

  group('Email Authentication - signUpWithEmail', () {
    test('should call Supabase signUp with correct parameters', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'Password123!';
      final mockAuthResponse = MockAuthResponse();
      final mockUser = MockUser();

      when(() => mockUser.id).thenReturn('user-123');
      when(() => mockUser.email).thenReturn(email);
      when(() => mockAuthResponse.user).thenReturn(mockUser);

      when(() => mockGoTrueClient.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        data: any(named: 'data'),
      )).thenAnswer((_) async => mockAuthResponse);

      final repository = SupabaseAuthRepository(mockSupabaseClient);

      // Act & Assert - will fail at DB query, but we only care about signUp call
      try {
        await repository.signUpWithEmail(
          email: email,
          password: password,
        );
      } catch (e) {
        // Expected to fail at DB operations (not mocked)
      }

      // Assert: Verify signUp was called with correct email/password
      verify(() => mockGoTrueClient.signUp(
        email: email,
        password: password,
        data: {'email': email},
      )).called(1);

      repository.dispose();
    });

    test('should throw exception when auth user is null', () async {
      // Arrange
      final mockAuthResponse = MockAuthResponse();
      when(() => mockAuthResponse.user).thenReturn(null);

      when(() => mockGoTrueClient.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        data: any(named: 'data'),
      )).thenAnswer((_) async => mockAuthResponse);

      final repository = SupabaseAuthRepository(mockSupabaseClient);

      // Act & Assert
      expect(
        () => repository.signUpWithEmail(
          email: 'test@example.com',
          password: 'Password123!',
        ),
        throwsA(predicate((e) => e.toString().contains('Sign up failed: user is null'))),
      );

      repository.dispose();
    });

    test('should throw exception when email already exists', () async {
      // Arrange
      when(() => mockGoTrueClient.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        data: any(named: 'data'),
      )).thenThrow(AuthException('User already registered'));

      final repository = SupabaseAuthRepository(mockSupabaseClient);

      // Act & Assert
      expect(
        () => repository.signUpWithEmail(
          email: 'duplicate@example.com',
          password: 'Password123!',
        ),
        throwsA(predicate((e) => e.toString().contains('Email already exists'))),
      );

      repository.dispose();
    });

    test('should throw exception for weak password', () async {
      // Arrange
      when(() => mockGoTrueClient.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        data: any(named: 'data'),
      )).thenThrow(AuthException('Password should be at least 6 characters: weak password'));

      final repository = SupabaseAuthRepository(mockSupabaseClient);

      // Act & Assert
      expect(
        () => repository.signUpWithEmail(
          email: 'test@example.com',
          password: 'weak',
        ),
        throwsA(predicate((e) => e.toString().contains('Password is too weak'))),
      );

      repository.dispose();
    });
  });

  group('Email Authentication - signInWithEmail', () {
    test('should call Supabase signInWithPassword with correct credentials', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'Password123!';
      final mockAuthResponse = MockAuthResponse();
      final mockUser = MockUser();

      when(() => mockUser.id).thenReturn('user-123');
      when(() => mockUser.email).thenReturn(email);
      when(() => mockAuthResponse.user).thenReturn(mockUser);

      when(() => mockGoTrueClient.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => mockAuthResponse);

      final repository = SupabaseAuthRepository(mockSupabaseClient);

      // Act & Assert - will fail at DB query, but we only care about signIn call
      try {
        await repository.signInWithEmail(
          email: email,
          password: password,
        );
      } catch (e) {
        // Expected to fail at DB operations (not mocked)
      }

      // Assert: Verify signInWithPassword was called with correct credentials
      verify(() => mockGoTrueClient.signInWithPassword(
        email: email,
        password: password,
      )).called(1);

      repository.dispose();
    });

    test('should throw exception for invalid credentials', () async {
      // Arrange
      // Note: Supabase uses lowercase "invalid credentials" in error message
      when(() => mockGoTrueClient.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(AuthException('invalid credentials'));

      final repository = SupabaseAuthRepository(mockSupabaseClient);

      // Act & Assert
      await expectLater(
        repository.signInWithEmail(
          email: 'test@example.com',
          password: 'WrongPassword!',
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Invalid email or password'),
        )),
      );

      repository.dispose();
    });

    test('should throw exception when email not confirmed', () async {
      // Arrange
      when(() => mockGoTrueClient.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(AuthException('Email not confirmed'));

      final repository = SupabaseAuthRepository(mockSupabaseClient);

      // Act & Assert
      expect(
        () => repository.signInWithEmail(
          email: 'unconfirmed@example.com',
          password: 'Password123!',
        ),
        throwsA(predicate((e) => e.toString().contains('Email not confirmed'))),
      );

      repository.dispose();
    });
  });

  group('Email Authentication - updatePassword', () {
    test('should verify current password before updating', () async {
      // Arrange
      const currentPassword = 'OldPassword123!';
      const newPassword = 'NewPassword456!';
      final mockUser = MockUser();
      final mockAuthResponse = MockAuthResponse();

      when(() => mockUser.id).thenReturn('user-123');
      when(() => mockUser.email).thenReturn('test@example.com');
      when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);

      // Mock re-authentication with current password
      when(() => mockGoTrueClient.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => mockAuthResponse);

      // Mock password update
      when(() => mockGoTrueClient.updateUser(any())).thenAnswer((_) async => MockUserResponse());

      final repository = SupabaseAuthRepository(mockSupabaseClient);

      // Act - will fail at DB query, but we only care about auth calls
      try {
        await repository.updatePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
      } catch (e) {
        // Expected to fail at DB operations (not mocked)
      }

      // Assert: Verify current password was verified via re-authentication
      verify(() => mockGoTrueClient.signInWithPassword(
        email: 'test@example.com',
        password: currentPassword,
      )).called(1);

      // Verify password update was called
      verify(() => mockGoTrueClient.updateUser(any())).called(1);

      repository.dispose();
    });

    test('should throw exception when current password is incorrect', () async {
      // Arrange
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('user-123');
      when(() => mockUser.email).thenReturn('test@example.com');
      when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);

      // Re-authentication fails
      when(() => mockGoTrueClient.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(AuthException('Invalid login credentials'));

      final repository = SupabaseAuthRepository(mockSupabaseClient);

      // Act & Assert
      expect(
        () => repository.updatePassword(
          currentPassword: 'WrongPassword!',
          newPassword: 'NewPassword123!',
        ),
        throwsA(predicate((e) => e.toString().contains('Current password is incorrect'))),
      );

      repository.dispose();
    });

    test('should throw exception when user not authenticated', () async {
      // Arrange
      when(() => mockGoTrueClient.currentUser).thenReturn(null);

      final repository = SupabaseAuthRepository(mockSupabaseClient);

      // Act & Assert
      expect(
        () => repository.updatePassword(
          currentPassword: 'OldPassword123!',
          newPassword: 'NewPassword456!',
        ),
        throwsA(predicate((e) => e.toString().contains('User not authenticated'))),
      );

      repository.dispose();
    });
  });

  group('Email Authentication - resetPasswordForEmail', () {
    test('should send password reset email successfully', () async {
      // Arrange
      const email = 'test@example.com';

      when(() => mockGoTrueClient.resetPasswordForEmail(
        email,
        redirectTo: any(named: 'redirectTo'),
      )).thenAnswer((_) async => {});

      final repository = SupabaseAuthRepository(mockSupabaseClient);

      // Act
      await repository.resetPasswordForEmail(email);

      // Assert
      verify(() => mockGoTrueClient.resetPasswordForEmail(
        email,
        redirectTo: 'n06://reset-password',
      )).called(1);

      repository.dispose();
    });

    test('should succeed silently even when email does not exist (security)', () async {
      // Arrange
      const email = 'nonexistent@example.com';

      // Supabase returns 422 for non-existent email
      when(() => mockGoTrueClient.resetPasswordForEmail(
        email,
        redirectTo: any(named: 'redirectTo'),
      )).thenThrow(AuthException('Email not found', statusCode: '422'));

      final repository = SupabaseAuthRepository(mockSupabaseClient);

      // Act & Assert - Should NOT throw (for security)
      await expectLater(
        repository.resetPasswordForEmail(email),
        completes,
      );

      repository.dispose();
    });

    test('should handle network errors silently (security)', () async {
      // Arrange
      const email = 'test@example.com';

      when(() => mockGoTrueClient.resetPasswordForEmail(
        email,
        redirectTo: any(named: 'redirectTo'),
      )).thenThrow(Exception('Network error'));

      final repository = SupabaseAuthRepository(mockSupabaseClient);

      // Act & Assert - Should NOT throw (for security)
      await expectLater(
        repository.resetPasswordForEmail(email),
        completes,
      );

      repository.dispose();
    });
  });
}
