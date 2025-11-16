import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../dtos/user_profile_dto.dart';

/// Supabase implementation of ProfileRepository
class SupabaseProfileRepository implements ProfileRepository {
  final SupabaseClient _supabase;

  SupabaseProfileRepository(this._supabase);

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    final dto = UserProfileDto.fromEntity(profile);
    await _supabase.from('user_profiles').insert(dto.toJson());
  }

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
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
    final weightResponse = await _supabase
        .from('weight_logs')
        .select('weight_kg')
        .eq('user_id', userId)
        .order('log_date', ascending: false)
        .limit(1)
        .maybeSingle();

    // 4. DTO → Entity 변환 (조회한 데이터 조합)
    final dto = UserProfileDto.fromJson(profileResponse);
    return dto.toEntity(
      userName: userResponse['name'] as String,
      currentWeightKg: weightResponse != null
          ? (weightResponse['weight_kg'] as num).toDouble()
          : 70.0, // 체중 기록이 없을 경우 기본값 (실제로는 온보딩에서 항상 입력)
    );
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    final dto = UserProfileDto.fromEntity(profile);
    await _supabase
        .from('user_profiles')
        .update(dto.toJson())
        .eq('user_id', profile.userId);

    // ⚠️ 참고: currentWeight는 업데이트하지 않음!
    // 체중 변경은 TrackingRepository.saveWeightLog() 사용
  }

  @override
  Stream<UserProfile> watchUserProfile(String userId) {
    // TODO: 실시간 스트림에서 3개 테이블 JOIN 구현 필요
    // 현재는 user_profiles만 스트림 (userName, currentWeight는 null/0.0)
    return _supabase
        .from('user_profiles')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .asyncMap((data) async {
      if (data.isEmpty) {
        throw Exception('User profile not found for user: $userId');
      }

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

      return UserProfileDto.fromJson(data.first).toEntity(
        userName: userResponse?['name'] as String? ?? '',
        currentWeightKg: weightResponse != null
            ? (weightResponse['weight_kg'] as num).toDouble()
            : 70.0, // 기본값
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

    // Update goals
    await _supabase.from('user_profiles').update({
      'weekly_weight_record_goal': weeklyWeightRecordGoal,
      'weekly_symptom_record_goal': weeklySymptomRecordGoal,
    }).eq('user_id', userId);
  }
}
