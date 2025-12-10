import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:n06/core/encryption/domain/encryption_service.dart';
import 'package:n06/features/onboarding/domain/value_objects/weight.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../dtos/user_profile_dto.dart';

/// Supabase implementation of ProfileRepository
///
/// Encrypts sensitive fields:
/// - target_weight_kg (user_profiles)
/// - weight_kg (when reading from weight_logs for currentWeight)
class SupabaseProfileRepository implements ProfileRepository {
  final SupabaseClient _supabase;
  final EncryptionService _encryptionService;

  SupabaseProfileRepository(this._supabase, this._encryptionService);

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    // 암호화 서비스 초기화
    await _encryptionService.initialize(profile.userId);

    final dto = UserProfileDto.fromEntity(profile);
    final json = dto.toJson();

    // 암호화: target_weight_kg
    json['target_weight_kg'] = _encryptionService.encryptDouble(profile.targetWeight.value);

    await _supabase.from('user_profiles').insert(json);
  }

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    // 암호화 서비스 초기화
    await _encryptionService.initialize(userId);

    // 1. user_profiles 테이블에서 프로필 조회
    final profileResponse = await _supabase
        .from('user_profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (profileResponse == null) return null;

    // 2. users 테이블에서 이름 조회 (SSoT)
    final userResponse = await _supabase
        .from('users')
        .select('name')
        .eq('id', userId)
        .maybeSingle();

    if (userResponse == null) {
      throw Exception('User not found in users table for userId: $userId');
    }

    // 3. weight_logs 테이블에서 최신 체중 조회 (SSoT)
    // 체중도 암호화되어 있으므로 복호화 필요
    final weightResponse = await _supabase
        .from('weight_logs')
        .select('weight_kg')
        .eq('user_id', userId)
        .order('log_date', ascending: false)
        .limit(1)
        .maybeSingle();

    // 4. 복호화 및 Entity 변환 (평문 fallback 지원)
    final encryptedTargetWeight = profileResponse['target_weight_kg'] as String;
    final targetWeightKg = _encryptionService.decryptDoubleWithFallback(encryptedTargetWeight) ?? 70.0;

    double currentWeightKg = 70.0;
    if (weightResponse != null) {
      final encryptedCurrentWeight = weightResponse['weight_kg'] as String;
      currentWeightKg = _encryptionService.decryptDoubleWithFallback(encryptedCurrentWeight) ?? 70.0;
    }

    return UserProfile(
      userId: profileResponse['user_id'] as String,
      userName: userResponse['name'] as String,
      targetWeight: Weight.create(targetWeightKg),
      currentWeight: Weight.create(currentWeightKg),
      targetPeriodWeeks: profileResponse['target_period_weeks'] as int?,
      weeklyLossGoalKg: profileResponse['weekly_loss_goal_kg'] != null
          ? (profileResponse['weekly_loss_goal_kg'] as num).toDouble()
          : null,
      weeklyWeightRecordGoal: profileResponse['weekly_weight_record_goal'] as int,
      weeklySymptomRecordGoal: profileResponse['weekly_symptom_record_goal'] as int,
    );
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    // 암호화 서비스 초기화
    await _encryptionService.initialize(profile.userId);

    final dto = UserProfileDto.fromEntity(profile);
    final json = dto.toJson();

    // 암호화: target_weight_kg
    json['target_weight_kg'] = _encryptionService.encryptDouble(profile.targetWeight.value);

    await _supabase
        .from('user_profiles')
        .update(json)
        .eq('user_id', profile.userId);

    // ⚠️ 참고: currentWeight는 업데이트하지 않음!
    // 체중 변경은 TrackingRepository.saveWeightLog() 사용
  }

  @override
  Stream<UserProfile> watchUserProfile(String userId) {
    return _supabase
        .from('user_profiles')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .asyncMap((data) async {
      if (data.isEmpty) {
        throw Exception('User profile not found for user: $userId');
      }

      // 암호화 서비스 초기화 (Stream에서는 asyncMap 사용)
      await _encryptionService.initialize(userId);

      // users, weight_logs 조회
      final userResponse = await _supabase
          .from('users')
          .select('name')
          .eq('id', userId)
          .maybeSingle();

      final weightResponse = await _supabase
          .from('weight_logs')
          .select('weight_kg')
          .eq('user_id', userId)
          .order('log_date', ascending: false)
          .limit(1)
          .maybeSingle();

      // 복호화 (평문 fallback 지원)
      final profileData = data.first;
      final encryptedTargetWeight = profileData['target_weight_kg'] as String;
      final targetWeightKg = _encryptionService.decryptDoubleWithFallback(encryptedTargetWeight) ?? 70.0;

      double currentWeightKg = 70.0;
      if (weightResponse != null) {
        final encryptedCurrentWeight = weightResponse['weight_kg'] as String;
        currentWeightKg = _encryptionService.decryptDoubleWithFallback(encryptedCurrentWeight) ?? 70.0;
      }

      return UserProfile(
        userId: profileData['user_id'] as String,
        userName: userResponse?['name'] as String? ?? '',
        targetWeight: Weight.create(targetWeightKg),
        currentWeight: Weight.create(currentWeightKg),
        targetPeriodWeeks: profileData['target_period_weeks'] as int?,
        weeklyLossGoalKg: profileData['weekly_loss_goal_kg'] != null
            ? (profileData['weekly_loss_goal_kg'] as num).toDouble()
            : null,
        weeklyWeightRecordGoal: profileData['weekly_weight_record_goal'] as int,
        weeklySymptomRecordGoal: profileData['weekly_symptom_record_goal'] as int,
      );
    });
  }

  @override
  Future<void> updateWeeklyGoals(
    String userId,
    int weeklyWeightRecordGoal,
    int weeklySymptomRecordGoal,
  ) async {
    // Validate goals are in range 0-7
    if (weeklyWeightRecordGoal < 0 || weeklyWeightRecordGoal > 7) {
      throw Exception('weeklyWeightRecordGoal must be between 0 and 7');
    }
    if (weeklySymptomRecordGoal < 0 || weeklySymptomRecordGoal > 7) {
      throw Exception('weeklySymptomRecordGoal must be between 0 and 7');
    }

    // Check if profile exists
    final existing = await _supabase
        .from('user_profiles')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();

    if (existing == null) {
      throw Exception('User profile not found for user: $userId');
    }

    // Update goals (암호화 대상 아님)
    await _supabase.from('user_profiles').update({
      'weekly_weight_record_goal': weeklyWeightRecordGoal,
      'weekly_symptom_record_goal': weeklySymptomRecordGoal,
    }).eq('user_id', userId);
  }
}
