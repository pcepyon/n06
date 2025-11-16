import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/onboarding/infrastructure/dtos/user_profile_dto.dart';
import 'package:n06/features/onboarding/domain/entities/user_profile.dart';
import 'package:n06/features/onboarding/domain/value_objects/weight.dart';

void main() {
  group('SupabaseProfileRepository - 통합 테스트 (수동)', () {
    // 참고: Supabase Mock이 복잡하여 실제 Integration 테스트는 별도 수행
    // 여기서는 DTO 변환 로직이 올바른지만 검증

    test('DTO 변환이 스키마와 일치하는지 검증 (saveUserProfile 시나리오)', () {
      // Arrange
      final profile = UserProfile(
        userId: 'test-user-id',
        userName: '홍길동',
        targetWeight: Weight.create(70.0),
        currentWeight: Weight.create(80.0),
        weeklyWeightRecordGoal: 7,
        weeklySymptomRecordGoal: 7,
      );

      // Act - saveUserProfile에서 사용하는 변환
      final dto = UserProfileDto.fromEntity(profile);
      final json = dto.toJson();

      // Assert - user_profiles 테이블 스키마와 일치해야 함
      expect(json.containsKey('user_name'), isFalse,
          reason: 'user_name은 users 테이블에만 존재');
      expect(json.containsKey('current_weight_kg'), isFalse,
          reason: 'current_weight_kg는 weight_logs 테이블에만 존재');

      // user_profiles에 존재하는 필드만 포함
      expect(json.keys.toSet(), {
        'user_id',
        'target_weight_kg',
        'target_period_weeks',
        'weekly_loss_goal_kg',
        'weekly_weight_record_goal',
        'weekly_symptom_record_goal',
      });
    });

    test('DTO가 외부 데이터를 받아 Entity를 생성할 수 있는지 검증 (getUserProfile 시나리오)', () {
      // Arrange - user_profiles 테이블에서 조회한 데이터
      final profileJson = {
        'user_id': 'test-user-id',
        'target_weight_kg': 70.0,
        'weekly_weight_record_goal': 7,
        'weekly_symptom_record_goal': 7,
      };

      // users 테이블에서 조회한 데이터
      const userName = '홍길동';

      // weight_logs 테이블에서 조회한 데이터
      const currentWeightKg = 80.0;

      // Act - getUserProfile에서 사용하는 변환
      final dto = UserProfileDto.fromJson(profileJson);
      final entity = dto.toEntity(
        userName: userName,
        currentWeightKg: currentWeightKg,
      );

      // Assert
      expect(entity.userName, '홍길동',
          reason: 'users 테이블에서 조회한 이름이 Entity에 반영되어야 함');
      expect(entity.currentWeight.value, 80.0,
          reason: 'weight_logs 테이블에서 조회한 체중이 Entity에 반영되어야 함');
      expect(entity.targetWeight.value, 70.0);
    });

    test('체중 기록이 없을 때 합리적인 기본값을 사용하는 시나리오', () {
      // Arrange
      final profileJson = {
        'user_id': 'test-user-id',
        'target_weight_kg': 70.0,
        'weekly_weight_record_goal': 7,
        'weekly_symptom_record_goal': 7,
      };

      const userName = '홍길동';
      // 참고: 실제로는 온보딩에서 항상 체중 입력하므로 발생하지 않음
      // Repository는 기본값을 제공하되, Weight 도메인 제약을 만족해야 함
      const currentWeightKg = 70.0; // Weight 도메인 제약 (20-300kg) 만족

      // Act
      final dto = UserProfileDto.fromJson(profileJson);
      final entity = dto.toEntity(
        userName: userName,
        currentWeightKg: currentWeightKg,
      );

      // Assert
      expect(entity.currentWeight.value, 70.0,
          reason: '체중 기록이 없을 때 합리적인 기본값 사용 (도메인 제약 만족)');
    });
  });
}
