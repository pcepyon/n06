import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/onboarding/infrastructure/dtos/user_profile_dto.dart';
import 'package:n06/features/onboarding/domain/entities/user_profile.dart';
import 'package:n06/features/onboarding/domain/value_objects/weight.dart';

void main() {
  group('UserProfileDto', () {
    group('toJson - 스키마 검증', () {
      test('toJson()에 user_name 필드가 포함되지 않아야 함', () {
        // Arrange
        final dto = UserProfileDto(
          userId: 'test-user-id',
          targetWeightKg: 70.0,
          weeklyWeightRecordGoal: 7,
          weeklySymptomRecordGoal: 7,
        );

        // Act
        final json = dto.toJson();

        // Assert
        expect(json.containsKey('user_name'), isFalse,
            reason: 'user_name은 users 테이블에만 존재하므로 user_profiles INSERT에 포함되면 안됨');
      });

      test('toJson()에 current_weight_kg 필드가 포함되지 않아야 함', () {
        // Arrange
        final dto = UserProfileDto(
          userId: 'test-user-id',
          targetWeightKg: 70.0,
          weeklyWeightRecordGoal: 7,
          weeklySymptomRecordGoal: 7,
        );

        // Act
        final json = dto.toJson();

        // Assert
        expect(json.containsKey('current_weight_kg'), isFalse,
            reason: 'current_weight_kg는 weight_logs 테이블에만 존재하므로 user_profiles INSERT에 포함되면 안됨');
      });

      test('toJson()에 user_profiles 스키마에 존재하는 필드만 포함되어야 함', () {
        // Arrange
        final dto = UserProfileDto(
          userId: 'test-user-id',
          targetWeightKg: 70.0,
          targetPeriodWeeks: 12,
          weeklyLossGoalKg: 0.5,
          weeklyWeightRecordGoal: 7,
          weeklySymptomRecordGoal: 7,
        );

        // Act
        final json = dto.toJson();

        // Assert - Supabase user_profiles 테이블 스키마와 일치
        expect(json.keys.toSet(), {
          'user_id',
          'target_weight_kg',
          'target_period_weeks',
          'weekly_loss_goal_kg',
          'weekly_weight_record_goal',
          'weekly_symptom_record_goal',
        });
      });
    });

    group('toEntity - 매개변수 검증', () {
      test('toEntity()가 userName 매개변수를 받아야 함', () {
        // Arrange
        final dto = UserProfileDto(
          userId: 'test-user-id',
          targetWeightKg: 70.0,
          weeklyWeightRecordGoal: 7,
          weeklySymptomRecordGoal: 7,
        );

        // Act & Assert
        expect(
          () => dto.toEntity(
            userName: '홍길동',
            currentWeightKg: 80.0,
          ),
          returnsNormally,
          reason: 'toEntity()는 userName을 매개변수로 받아야 함 (users 테이블에서 조인 조회)',
        );
      });

      test('toEntity()가 currentWeightKg 매개변수를 받아야 함', () {
        // Arrange
        final dto = UserProfileDto(
          userId: 'test-user-id',
          targetWeightKg: 70.0,
          weeklyWeightRecordGoal: 7,
          weeklySymptomRecordGoal: 7,
        );

        // Act & Assert
        expect(
          () => dto.toEntity(
            userName: '홍길동',
            currentWeightKg: 80.0,
          ),
          returnsNormally,
          reason: 'toEntity()는 currentWeightKg를 매개변수로 받아야 함 (weight_logs 테이블에서 조인 조회)',
        );
      });

      test('toEntity()가 매개변수로 받은 값을 Entity에 반영해야 함', () {
        // Arrange
        final dto = UserProfileDto(
          userId: 'test-user-id',
          targetWeightKg: 70.0,
          weeklyWeightRecordGoal: 7,
          weeklySymptomRecordGoal: 7,
        );

        // Act
        final entity = dto.toEntity(
          userName: '홍길동',
          currentWeightKg: 80.0,
        );

        // Assert
        expect(entity.userName, '홍길동');
        expect(entity.currentWeight.value, 80.0);
      });
    });

    group('fromEntity - SSoT 원칙 검증', () {
      test('fromEntity()가 userName을 포함하지 않아야 함', () {
        // Arrange
        final entity = UserProfile(
          userId: 'test-user-id',
          userName: '홍길동',
          targetWeight: Weight.create(70.0),
          currentWeight: Weight.create(80.0),
          weeklyWeightRecordGoal: 7,
          weeklySymptomRecordGoal: 7,
        );

        // Act
        final dto = UserProfileDto.fromEntity(entity);

        // Assert - DTO 필드에 userName이 존재하지 않아야 함
        // (toJson()에서 제외되는지는 별도 테스트)
        expect(
          dto.toJson().containsKey('user_name'),
          isFalse,
          reason: 'userName은 users 테이블에만 저장되어야 함 (SSoT 원칙)',
        );
      });

      test('fromEntity()가 currentWeight를 포함하지 않아야 함', () {
        // Arrange
        final entity = UserProfile(
          userId: 'test-user-id',
          userName: '홍길동',
          targetWeight: Weight.create(70.0),
          currentWeight: Weight.create(80.0),
          weeklyWeightRecordGoal: 7,
          weeklySymptomRecordGoal: 7,
        );

        // Act
        final dto = UserProfileDto.fromEntity(entity);

        // Assert
        expect(
          dto.toJson().containsKey('current_weight_kg'),
          isFalse,
          reason: 'currentWeight는 weight_logs 테이블에만 저장되어야 함 (SSoT 원칙)',
        );
      });
    });
  });
}
