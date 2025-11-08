import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/onboarding/domain/entities/user_profile.dart';
import 'package:n06/features/onboarding/domain/value_objects/weight.dart';

void main() {
  group('UserProfile Entity - Weekly Goals Validation', () {
    late Weight targetWeight;
    late Weight currentWeight;

    setUp(() {
      targetWeight = Weight.create(60.0);
      currentWeight = Weight.create(70.0);
    });

    group('주간 목표 범위 검증 (0~7)', () {
      test('유효한 주간 체중 기록 목표로 생성 성공', () {
        // Arrange & Act
        final profile = UserProfile(
          userId: 'test-user-001',
          targetWeight: targetWeight,
          currentWeight: currentWeight,
          weeklyWeightRecordGoal: 5,
          weeklySymptomRecordGoal: 3,
        );

        // Assert
        expect(profile.weeklyWeightRecordGoal, equals(5));
        expect(profile.weeklySymptomRecordGoal, equals(3));
      });

      test('주간 체중 기록 목표 0은 허용', () {
        // Arrange & Act
        final profile = UserProfile(
          userId: 'test-user-001',
          targetWeight: targetWeight,
          currentWeight: currentWeight,
          weeklyWeightRecordGoal: 0,
          weeklySymptomRecordGoal: 7,
        );

        // Assert
        expect(profile.weeklyWeightRecordGoal, equals(0));
      });

      test('주간 부작용 기록 목표 0은 허용', () {
        // Arrange & Act
        final profile = UserProfile(
          userId: 'test-user-001',
          targetWeight: targetWeight,
          currentWeight: currentWeight,
          weeklyWeightRecordGoal: 7,
          weeklySymptomRecordGoal: 0,
        );

        // Assert
        expect(profile.weeklySymptomRecordGoal, equals(0));
      });

      test('주간 체중 기록 목표 기본값 7', () {
        // Arrange & Act
        final profile = UserProfile(
          userId: 'test-user-001',
          targetWeight: targetWeight,
          currentWeight: currentWeight,
        );

        // Assert
        expect(profile.weeklyWeightRecordGoal, equals(7));
      });

      test('주간 부작용 기록 목표 기본값 7', () {
        // Arrange & Act
        final profile = UserProfile(
          userId: 'test-user-001',
          targetWeight: targetWeight,
          currentWeight: currentWeight,
        );

        // Assert
        expect(profile.weeklySymptomRecordGoal, equals(7));
      });
    });

    group('copyWith 메서드로 주간 목표 변경', () {
      test('주간 체중 기록 목표만 변경', () {
        // Arrange
        final originalProfile = UserProfile(
          userId: 'test-user-001',
          targetWeight: targetWeight,
          currentWeight: currentWeight,
          weeklyWeightRecordGoal: 7,
          weeklySymptomRecordGoal: 7,
        );

        // Act
        final updatedProfile = originalProfile.copyWith(
          weeklyWeightRecordGoal: 5,
        );

        // Assert
        expect(updatedProfile.weeklyWeightRecordGoal, equals(5));
        expect(updatedProfile.weeklySymptomRecordGoal, equals(7));
        expect(updatedProfile.userId, equals(originalProfile.userId));
      });

      test('주간 부작용 기록 목표만 변경', () {
        // Arrange
        final originalProfile = UserProfile(
          userId: 'test-user-001',
          targetWeight: targetWeight,
          currentWeight: currentWeight,
          weeklyWeightRecordGoal: 7,
          weeklySymptomRecordGoal: 7,
        );

        // Act
        final updatedProfile = originalProfile.copyWith(
          weeklySymptomRecordGoal: 3,
        );

        // Assert
        expect(updatedProfile.weeklyWeightRecordGoal, equals(7));
        expect(updatedProfile.weeklySymptomRecordGoal, equals(3));
        expect(updatedProfile.userId, equals(originalProfile.userId));
      });

      test('두 주간 목표 동시 변경', () {
        // Arrange
        final originalProfile = UserProfile(
          userId: 'test-user-001',
          targetWeight: targetWeight,
          currentWeight: currentWeight,
          weeklyWeightRecordGoal: 7,
          weeklySymptomRecordGoal: 7,
        );

        // Act
        final updatedProfile = originalProfile.copyWith(
          weeklyWeightRecordGoal: 4,
          weeklySymptomRecordGoal: 2,
        );

        // Assert
        expect(updatedProfile.weeklyWeightRecordGoal, equals(4));
        expect(updatedProfile.weeklySymptomRecordGoal, equals(2));
      });

      test('copyWith에서 null 전달 시 기존 값 유지', () {
        // Arrange
        final originalProfile = UserProfile(
          userId: 'test-user-001',
          targetWeight: targetWeight,
          currentWeight: currentWeight,
          weeklyWeightRecordGoal: 5,
          weeklySymptomRecordGoal: 3,
        );

        // Act
        final updatedProfile = originalProfile.copyWith();

        // Assert
        expect(updatedProfile.weeklyWeightRecordGoal, equals(5));
        expect(updatedProfile.weeklySymptomRecordGoal, equals(3));
      });
    });

    group('주간 목표 동등성 검증 (== 연산)', () {
      test('주간 목표가 다르면 다른 Profile로 판단', () {
        // Arrange
        final profile1 = UserProfile(
          userId: 'test-user-001',
          targetWeight: targetWeight,
          currentWeight: currentWeight,
          weeklyWeightRecordGoal: 7,
          weeklySymptomRecordGoal: 7,
        );

        final profile2 = UserProfile(
          userId: 'test-user-001',
          targetWeight: targetWeight,
          currentWeight: currentWeight,
          weeklyWeightRecordGoal: 5,
          weeklySymptomRecordGoal: 3,
        );

        // Assert
        expect(profile1, isNot(equals(profile2)));
      });

      test('주간 목표가 같으면 같은 Profile로 판단', () {
        // Arrange
        final profile1 = UserProfile(
          userId: 'test-user-001',
          targetWeight: targetWeight,
          currentWeight: currentWeight,
          weeklyWeightRecordGoal: 5,
          weeklySymptomRecordGoal: 3,
        );

        final profile2 = UserProfile(
          userId: 'test-user-001',
          targetWeight: targetWeight,
          currentWeight: currentWeight,
          weeklyWeightRecordGoal: 5,
          weeklySymptomRecordGoal: 3,
        );

        // Assert
        expect(profile1, equals(profile2));
      });
    });
  });
}
