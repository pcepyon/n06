import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n06/features/authentication/domain/repositories/auth_repository.dart';
import 'package:n06/features/authentication/domain/repositories/secure_storage_repository.dart';
import 'package:n06/features/authentication/domain/usecases/logout_usecase.dart';

class MockSecureStorageRepository extends Mock
    implements SecureStorageRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockSecureStorageRepository mockStorageRepo;
  late MockAuthRepository mockAuthRepo;
  late LogoutUseCase useCase;

  setUp(() {
    mockStorageRepo = MockSecureStorageRepository();
    mockAuthRepo = MockAuthRepository();
    useCase = LogoutUseCase(
      storageRepository: mockStorageRepo,
      authRepository: mockAuthRepo,
    );
  });

  group('LogoutUseCase', () {
    group('execute', () {
      test('should clear tokens from secure storage', () async {
        // Arrange
        when(() => mockStorageRepo.clearTokens()).thenAnswer(
          (_) => Future.value(),
        );
        when(() => mockAuthRepo.logout()).thenAnswer(
          (_) => Future.value(),
        );

        // Act
        await useCase.execute();

        // Assert
        verify(() => mockStorageRepo.clearTokens()).called(1);
      });

      test('should clear session from auth repository', () async {
        // Arrange
        when(() => mockStorageRepo.clearTokens()).thenAnswer(
          (_) => Future.value(),
        );
        when(() => mockAuthRepo.logout()).thenAnswer(
          (_) => Future.value(),
        );

        // Act
        await useCase.execute();

        // Assert
        verify(() => mockAuthRepo.logout()).called(1);
      });

      test('should call clearTokens before logout', () async {
        // Arrange
        final callOrder = <String>[];

        when(() => mockStorageRepo.clearTokens()).thenAnswer((_) {
          callOrder.add('clearTokens');
          return Future.value();
        });

        when(() => mockAuthRepo.logout()).thenAnswer((_) {
          callOrder.add('logout');
          return Future.value();
        });

        // Act
        await useCase.execute();

        // Assert
        expect(callOrder[0], 'clearTokens');
        expect(callOrder[1], 'logout');
      });

      test('should retry token deletion up to 3 times on failure', () async {
        // Arrange
        var attempt = 0;
        when(() => mockStorageRepo.clearTokens()).thenAnswer((_) {
          attempt++;
          if (attempt < 3) {
            throw Exception('Storage error');
          }
          return Future.value();
        });

        when(() => mockAuthRepo.logout()).thenAnswer(
          (_) => Future.value(),
        );

        // Act
        await useCase.execute();

        // Assert
        expect(attempt, 3);
      });

      test('should clear session even if token deletion fails after 3 retries',
          () async {
        // Arrange
        when(() => mockStorageRepo.clearTokens()).thenThrow(
          Exception('Storage error'),
        );

        when(() => mockAuthRepo.logout()).thenAnswer(
          (_) => Future.value(),
        );

        // Act
        await useCase.execute();

        // Assert
        verify(() => mockAuthRepo.logout()).called(1);
      });

      test('should clear all tokens without touching Isar database', () async {
        // Arrange
        when(() => mockStorageRepo.clearTokens()).thenAnswer(
          (_) => Future.value(),
        );
        when(() => mockAuthRepo.logout()).thenAnswer(
          (_) => Future.value(),
        );

        // Act
        await useCase.execute();

        // Assert
        // Verify that only storageRepository.clearTokens and authRepository.logout are called
        verify(() => mockStorageRepo.clearTokens()).called(1);
        verify(() => mockAuthRepo.logout()).called(1);
        verifyNoMoreInteractions(mockStorageRepo);
        verifyNoMoreInteractions(mockAuthRepo);
      });

      test('should complete successfully when all operations succeed', () async {
        // Arrange
        when(() => mockStorageRepo.clearTokens()).thenAnswer(
          (_) => Future.value(),
        );
        when(() => mockAuthRepo.logout()).thenAnswer(
          (_) => Future.value(),
        );

        // Act & Assert
        expect(useCase.execute(), completes);
      });

      test('should throw exception if logout fails after tokens are cleared',
          () async {
        // Arrange
        when(() => mockStorageRepo.clearTokens()).thenAnswer(
          (_) => Future.value(),
        );
        when(() => mockAuthRepo.logout()).thenThrow(
          Exception('Logout error'),
        );

        // Act & Assert
        expect(() => useCase.execute(), throwsException);
      });

      test('should handle network errors gracefully', () async {
        // Arrange
        when(() => mockStorageRepo.clearTokens()).thenAnswer(
          (_) => Future.value(),
        );
        when(() => mockAuthRepo.logout()).thenThrow(
          Exception('Network error'),
        );

        // Act & Assert
        expect(() => useCase.execute(), throwsException);
      });

      test('should succeed if token clearing fails but logout succeeds',
          () async {
        // Arrange
        var attempt = 0;
        when(() => mockStorageRepo.clearTokens()).thenAnswer((_) {
          attempt++;
          if (attempt < 3) {
            throw Exception('Storage error');
          }
          return Future.value();
        });

        when(() => mockAuthRepo.logout()).thenAnswer(
          (_) => Future.value(),
        );

        // Act & Assert
        expect(useCase.execute(), completes);
      });
    });
  });
}
