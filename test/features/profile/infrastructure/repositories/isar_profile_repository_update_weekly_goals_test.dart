import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:n06/features/onboarding/domain/entities/user_profile.dart';
import 'package:n06/features/onboarding/domain/value_objects/weight.dart';
import 'package:n06/features/profile/infrastructure/dtos/user_profile_dto.dart';
import 'package:n06/features/profile/infrastructure/repositories/isar_profile_repository.dart';

void main() {
  group('IsarProfileRepository.updateWeeklyGoals', () {
    late Isar isar;
    late IsarProfileRepository repository;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() async {
      final dir = Directory.systemTemp.createTempSync('isar_test_profile_');
      isar = await Isar.open(
        [UserProfileDtoSchema],
        directory: dir.path,
        name: 'test_profile_${DateTime.now().millisecondsSinceEpoch}',
      );
      repository = IsarProfileRepository(isar);
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('주간 목표 업데이트 성공', () async {
      // Arrange
      final dto = UserProfileDto()
        ..userId = 'test-user-001'
        ..targetWeightValue = 60.0
        ..currentWeightValue = 70.0
        ..weeklyWeightRecordGoal = 7
        ..weeklySymptomRecordGoal = 7;

      await isar.writeTxn(() async {
        await isar.userProfileDtos.put(dto);
      });

      // Act
      await repository.updateWeeklyGoals('test-user-001', 5, 3);

      // Assert
      final updatedProfile = await repository.getUserProfile('test-user-001');
      expect(updatedProfile.weeklyWeightRecordGoal, equals(5));
      expect(updatedProfile.weeklySymptomRecordGoal, equals(3));
    });

    test('주간 체중 기록 목표 0으로 업데이트', () async {
      // Arrange
      final dto = UserProfileDto()
        ..userId = 'test-user-002'
        ..targetWeightValue = 60.0
        ..currentWeightValue = 70.0
        ..weeklyWeightRecordGoal = 7
        ..weeklySymptomRecordGoal = 7;

      await isar.writeTxn(() async {
        await isar.userProfileDtos.put(dto);
      });

      // Act
      await repository.updateWeeklyGoals('test-user-002', 0, 7);

      // Assert
      final updatedProfile = await repository.getUserProfile('test-user-002');
      expect(updatedProfile.weeklyWeightRecordGoal, equals(0));
      expect(updatedProfile.weeklySymptomRecordGoal, equals(7));
    });

    test('존재하지 않는 사용자 업데이트 시 예외 발생', () async {
      // Act & Assert
      expect(
        () => repository.updateWeeklyGoals('non-existent-user', 5, 3),
        throwsException,
      );
    });

    test('주간 목표만 변경되고 다른 필드는 유지', () async {
      // Arrange
      final originalDto = UserProfileDto()
        ..userId = 'test-user-003'
        ..targetWeightValue = 60.0
        ..currentWeightValue = 70.0
        ..targetPeriodWeeks = 12
        ..weeklyLossGoalKg = 0.83
        ..weeklyWeightRecordGoal = 7
        ..weeklySymptomRecordGoal = 7;

      await isar.writeTxn(() async {
        await isar.userProfileDtos.put(originalDto);
      });

      // Act
      await repository.updateWeeklyGoals('test-user-003', 5, 3);

      // Assert
      final updatedProfile = await repository.getUserProfile('test-user-003');
      expect(updatedProfile.weeklyWeightRecordGoal, equals(5));
      expect(updatedProfile.weeklySymptomRecordGoal, equals(3));
      expect(updatedProfile.targetPeriodWeeks, equals(12));
      expect(updatedProfile.weeklyLossGoalKg, equals(0.83));
    });

    test('여러 번의 업데이트 작업 수행', () async {
      // Arrange
      final dto = UserProfileDto()
        ..userId = 'test-user-004'
        ..targetWeightValue = 60.0
        ..currentWeightValue = 70.0
        ..weeklyWeightRecordGoal = 7
        ..weeklySymptomRecordGoal = 7;

      await isar.writeTxn(() async {
        await isar.userProfileDtos.put(dto);
      });

      // Act - First update
      await repository.updateWeeklyGoals('test-user-004', 5, 3);

      // Assert
      var profile = await repository.getUserProfile('test-user-004');
      expect(profile.weeklyWeightRecordGoal, equals(5));
      expect(profile.weeklySymptomRecordGoal, equals(3));

      // Act - Second update
      await repository.updateWeeklyGoals('test-user-004', 2, 4);

      // Assert
      profile = await repository.getUserProfile('test-user-004');
      expect(profile.weeklyWeightRecordGoal, equals(2));
      expect(profile.weeklySymptomRecordGoal, equals(4));
    });

    test('다른 사용자의 데이터는 영향받지 않음', () async {
      // Arrange
      final dto1 = UserProfileDto()
        ..userId = 'test-user-005'
        ..targetWeightValue = 60.0
        ..currentWeightValue = 70.0
        ..weeklyWeightRecordGoal = 7
        ..weeklySymptomRecordGoal = 7;

      final dto2 = UserProfileDto()
        ..userId = 'test-user-006'
        ..targetWeightValue = 65.0
        ..currentWeightValue = 75.0
        ..weeklyWeightRecordGoal = 7
        ..weeklySymptomRecordGoal = 7;

      await isar.writeTxn(() async {
        await isar.userProfileDtos.put(dto1);
        await isar.userProfileDtos.put(dto2);
      });

      // Act
      await repository.updateWeeklyGoals('test-user-005', 5, 3);

      // Assert
      final profile1 = await repository.getUserProfile('test-user-005');
      final profile2 = await repository.getUserProfile('test-user-006');

      expect(profile1.weeklyWeightRecordGoal, equals(5));
      expect(profile1.weeklySymptomRecordGoal, equals(3));
      expect(profile2.weeklyWeightRecordGoal, equals(7));
      expect(profile2.weeklySymptomRecordGoal, equals(7));
    });
  });
}
