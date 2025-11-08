import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:n06/features/onboarding/domain/entities/user_profile.dart';
import 'package:n06/features/onboarding/domain/value_objects/weight.dart';
import 'package:n06/features/profile/application/notifiers/profile_notifier.dart';
import 'package:n06/features/profile/domain/repositories/profile_repository.dart';

/// Simple mock ProfileRepository for testing
class _MockProfileRepository implements ProfileRepository {
  UserProfile? _mockProfile;
  bool _shouldThrowOnUpdate = false;

  void setMockProfile(UserProfile profile) {
    _mockProfile = profile;
  }

  void setShouldThrowOnUpdate(bool value) {
    _shouldThrowOnUpdate = value;
  }

  @override
  Future<UserProfile> getUserProfile(String userId) async {
    if (_mockProfile == null) {
      throw Exception('Profile not found');
    }
    return _mockProfile!;
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    _mockProfile = profile;
  }

  @override
  Stream<UserProfile> watchUserProfile(String userId) {
    if (_mockProfile == null) {
      throw Exception('Profile not found');
    }
    return Stream.value(_mockProfile!);
  }

  @override
  Future<void> updateWeeklyGoals(
    String userId,
    int weeklyWeightRecordGoal,
    int weeklySymptomRecordGoal,
  ) async {
    if (_shouldThrowOnUpdate) {
      throw Exception('DB error');
    }
    if (_mockProfile == null) {
      throw Exception('Profile not found');
    }
    // Update the mock profile
    _mockProfile = _mockProfile!.copyWith(
      weeklyWeightRecordGoal: weeklyWeightRecordGoal,
      weeklySymptomRecordGoal: weeklySymptomRecordGoal,
    );
  }
}

void main() {
  group('ProfileNotifier.updateWeeklyGoals', () {
    late ProviderContainer container;
    late _MockProfileRepository mockRepository;

    setUp(() {
      mockRepository = _MockProfileRepository();

      // Create provider override for testing
      container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('주간 목표 업데이트 성공', () async {
      // Arrange
      const userId = 'test-user-001';
      final originalProfile = UserProfile(
        userId: userId,
        targetWeight: Weight.create(60.0),
        currentWeight: Weight.create(70.0),
        weeklyWeightRecordGoal: 7,
        weeklySymptomRecordGoal: 7,
      );

      mockRepository.setMockProfile(originalProfile);

      // Initialize notifier with original profile
      final notifier = container.read(profileNotifierProvider.notifier);
      await container.read(profileNotifierProvider.future);

      // Act
      await notifier.updateWeeklyGoals(5, 3);

      // Assert
      final state = container.read(profileNotifierProvider);
      expect(state.value?.weeklyWeightRecordGoal, equals(5));
      expect(state.value?.weeklySymptomRecordGoal, equals(3));
    });

    test('주간 목표 업데이트 실패 시 에러 상태', () async {
      // Arrange
      const userId = 'test-user-002';
      final profile = UserProfile(
        userId: userId,
        targetWeight: Weight.create(60.0),
        currentWeight: Weight.create(70.0),
        weeklyWeightRecordGoal: 7,
        weeklySymptomRecordGoal: 7,
      );

      mockRepository.setMockProfile(profile);
      mockRepository.setShouldThrowOnUpdate(true);

      // Initialize notifier
      final notifier = container.read(profileNotifierProvider.notifier);
      await container.read(profileNotifierProvider.future);

      // Act
      await notifier.updateWeeklyGoals(5, 3);

      // Assert
      final state = container.read(profileNotifierProvider);
      expect(state.hasError, isTrue);
    });

    test('주간 목표 0 업데이트 허용', () async {
      // Arrange
      const userId = 'test-user-003';
      final originalProfile = UserProfile(
        userId: userId,
        targetWeight: Weight.create(60.0),
        currentWeight: Weight.create(70.0),
        weeklyWeightRecordGoal: 7,
        weeklySymptomRecordGoal: 7,
      );

      mockRepository.setMockProfile(originalProfile);

      final notifier = container.read(profileNotifierProvider.notifier);
      await container.read(profileNotifierProvider.future);

      // Act
      await notifier.updateWeeklyGoals(0, 7);

      // Assert
      final state = container.read(profileNotifierProvider);
      expect(state.value?.weeklyWeightRecordGoal, equals(0));
    });

    test('프로필이 로드되지 않았을 때 예외 발생', () async {
      // Arrange - Don't set mock profile
      final notifier = container.read(profileNotifierProvider.notifier);

      // Act & Assert
      expect(
        () => notifier.updateWeeklyGoals(5, 3),
        throwsException,
      );
    });

    test('여러 번의 목표 업데이트', () async {
      // Arrange
      const userId = 'test-user-004';
      final originalProfile = UserProfile(
        userId: userId,
        targetWeight: Weight.create(60.0),
        currentWeight: Weight.create(70.0),
        weeklyWeightRecordGoal: 7,
        weeklySymptomRecordGoal: 7,
      );

      mockRepository.setMockProfile(originalProfile);

      final notifier = container.read(profileNotifierProvider.notifier);
      await container.read(profileNotifierProvider.future);

      // Act - First update
      await notifier.updateWeeklyGoals(5, 3);

      var state = container.read(profileNotifierProvider);
      expect(state.value?.weeklyWeightRecordGoal, equals(5));
      expect(state.value?.weeklySymptomRecordGoal, equals(3));

      // Act - Second update
      await notifier.updateWeeklyGoals(2, 4);

      // Assert
      state = container.read(profileNotifierProvider);
      expect(state.value?.weeklyWeightRecordGoal, equals(2));
      expect(state.value?.weeklySymptomRecordGoal, equals(4));
    });
  });
}
