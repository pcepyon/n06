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
    final response = await _supabase
        .from('user_profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserProfileDto.fromJson(response).toEntity();
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    final dto = UserProfileDto.fromEntity(profile);
    await _supabase
        .from('user_profiles')
        .update(dto.toJson())
        .eq('user_id', profile.userId);
  }

  @override
  Stream<UserProfile> watchUserProfile(String userId) {
    return _supabase
        .from('user_profiles')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) {
      if (data.isEmpty) {
        throw Exception('User profile not found for user: $userId');
      }
      return UserProfileDto.fromJson(data.first).toEntity();
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
