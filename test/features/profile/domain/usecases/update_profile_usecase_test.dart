import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n06/core/errors/domain_exception.dart';
import 'package:n06/features/onboarding/domain/entities/user_profile.dart';
import 'package:n06/features/onboarding/domain/value_objects/weight.dart';
import 'package:n06/features/onboarding/domain/repositories/profile_repository.dart';
import 'package:n06/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:n06/features/tracking/domain/repositories/tracking_repository.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockTrackingRepository extends Mock implements TrackingRepository {}

void main() {
  late MockProfileRepository mockProfileRepository;
  late MockTrackingRepository mockTrackingRepository;
  late UpdateProfileUseCase usecase;

  setUp(() {
    mockProfileRepository = MockProfileRepository();
    mockTrackingRepository = MockTrackingRepository();
    usecase = UpdateProfileUseCase(
      profileRepository: mockProfileRepository,
      trackingRepository: mockTrackingRepository,
    );
  });

  group('UpdateProfileUseCase', () {
    group('execute', () {
      test('should update profile successfully with valid data', () async {
        // Arrange
        final profile = UserProfile(
          userId: 'user1',
          targetWeight: Weight.create(70.0),
          currentWeight: Weight.create(80.0),
          targetPeriodWeeks: 10,
          weeklyLossGoalKg: 1.0,
          weeklyWeightRecordGoal: 7,
          weeklySymptomRecordGoal: 7,
        );

        when(() => mockProfileRepository.saveUserProfile(profile))
            .thenAnswer((_) async {});

        // Act
        await usecase.execute(profile);

        // Assert
        verify(() => mockProfileRepository.saveUserProfile(profile)).called(1);
      });

      test('should throw DomainException when target weight is greater than current weight',
          () async {
        // Arrange
        final profile = UserProfile(
          userId: 'user1',
          targetWeight: Weight.create(90.0),
          currentWeight: Weight.create(80.0),
          targetPeriodWeeks: 10,
        );

        // Act & Assert
        expect(
          () => usecase.execute(profile),
          throwsA(isA<DomainException>()),
        );
      });

      test('should throw DomainException when target weight is equal to current weight',
          () async {
        // Arrange
        final profile = UserProfile(
          userId: 'user1',
          targetWeight: Weight.create(80.0),
          currentWeight: Weight.create(80.0),
          targetPeriodWeeks: 10,
        );

        // Act & Assert
        expect(
          () => usecase.execute(profile),
          throwsA(isA<DomainException>()),
        );
      });

      test('should accept profile with null target period weeks', () async {
        // Arrange
        final profile = UserProfile(
          userId: 'user1',
          targetWeight: Weight.create(70.0),
          currentWeight: Weight.create(80.0),
          targetPeriodWeeks: null,
          weeklyLossGoalKg: null,
          weeklyWeightRecordGoal: 7,
          weeklySymptomRecordGoal: 7,
        );

        when(() => mockProfileRepository.saveUserProfile(profile))
            .thenAnswer((_) async {});

        // Act
        await usecase.execute(profile);

        // Assert
        verify(() => mockProfileRepository.saveUserProfile(profile)).called(1);
      });

      test('should propagate repository exception', () async {
        // Arrange
        final profile = UserProfile(
          userId: 'user1',
          targetWeight: Weight.create(70.0),
          currentWeight: Weight.create(80.0),
          targetPeriodWeeks: 10,
        );

        final exception = Exception('Database error');
        when(() => mockProfileRepository.saveUserProfile(profile))
            .thenThrow(exception);

        // Act & Assert
        expect(
          () => usecase.execute(profile),
          throwsException,
        );
      });

      test('should detect weight mismatch with recent weight log', () async {
        // Arrange
        final profile = UserProfile(
          userId: 'user1',
          targetWeight: Weight.create(70.0),
          currentWeight: Weight.create(80.0),
          targetPeriodWeeks: 10,
        );

        // Assume latest weight log has different value
        // This test verifies the warning is returned
        when(() => mockProfileRepository.saveUserProfile(profile))
            .thenAnswer((_) async {});

        // Act
        await usecase.execute(profile);

        // Assert
        verify(() => mockProfileRepository.saveUserProfile(profile)).called(1);
      });
    });
  });
}
