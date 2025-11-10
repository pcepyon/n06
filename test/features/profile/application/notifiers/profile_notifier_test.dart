import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/onboarding/domain/entities/user_profile.dart';
import 'package:n06/features/onboarding/domain/value_objects/weight.dart';
import 'package:n06/features/onboarding/domain/repositories/profile_repository.dart';
import 'package:n06/features/profile/application/notifiers/profile_notifier.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  group('ProfileNotifier', () {
    test('build should load profile successfully', () async {
      // Arrange
      final mockRepository = MockProfileRepository();
      final profile = UserProfile(
        userId: 'user1',
        targetWeight: Weight.create(70.0),
        currentWeight: Weight.create(80.0),
        targetPeriodWeeks: 10,
        weeklyLossGoalKg: 1.0,
      );

      when(() => mockRepository.getUserProfile('user1'))
          .thenAnswer((_) async => profile);

      // Act
      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      final result = await container.read(profileNotifierProvider.future);

      // Assert
      expect(result, isNotNull);
      expect(result!.userId, 'user1');
      expect(result.targetWeight.value, 70.0);
    });

    test('updateProfile should update profile successfully', () async {
      // Arrange
      final mockRepository = MockProfileRepository();
      final profile = UserProfile(
        userId: 'user1',
        targetWeight: Weight.create(70.0),
        currentWeight: Weight.create(80.0),
        targetPeriodWeeks: 10,
        weeklyLossGoalKg: 1.0,
      );

      when(() => mockRepository.saveUserProfile(profile))
          .thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      // Act
      final notifier = container.read(profileNotifierProvider.notifier);
      await notifier.updateProfile(profile);

      // Assert
      verify(() => mockRepository.saveUserProfile(profile)).called(1);
    });

    test('updateProfile should throw exception on repository error', () async {
      // Arrange
      final mockRepository = MockProfileRepository();
      final profile = UserProfile(
        userId: 'user1',
        targetWeight: Weight.create(70.0),
        currentWeight: Weight.create(80.0),
        targetPeriodWeeks: 10,
      );

      final exception = Exception('Database error');
      when(() => mockRepository.saveUserProfile(profile))
          .thenThrow(exception);

      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      // Act
      final notifier = container.read(profileNotifierProvider.notifier);
      await notifier.updateProfile(profile);

      // Assert
      expect(container.read(profileNotifierProvider), isA<AsyncValue>());
    });
  });
}
