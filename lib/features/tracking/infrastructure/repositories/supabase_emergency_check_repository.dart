import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/emergency_symptom_check.dart';
import '../../domain/repositories/emergency_check_repository.dart';
import '../dtos/emergency_symptom_check_dto.dart';

/// Supabase implementation of EmergencyCheckRepository
///
/// Manages emergency symptom check records in Supabase database.
class SupabaseEmergencyCheckRepository implements EmergencyCheckRepository {
  final SupabaseClient _supabase;

  SupabaseEmergencyCheckRepository(this._supabase);

  @override
  Future<void> saveEmergencyCheck(EmergencySymptomCheck check) async {
    final dto = EmergencySymptomCheckDto.fromEntity(check);
    await _supabase.from('emergency_symptom_checks').insert(dto.toJson());
  }

  @override
  Future<List<EmergencySymptomCheck>> getEmergencyChecks(String userId) async {
    final response = await _supabase
        .from('emergency_symptom_checks')
        .select()
        .eq('user_id', userId)
        .order('checked_at', ascending: false);

    return (response as List)
        .map((json) => EmergencySymptomCheckDto.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<void> deleteEmergencyCheck(String id) async {
    await _supabase.from('emergency_symptom_checks').delete().eq('id', id);
  }

  @override
  Future<void> updateEmergencyCheck(EmergencySymptomCheck check) async {
    final dto = EmergencySymptomCheckDto.fromEntity(check);
    await _supabase
        .from('emergency_symptom_checks')
        .update(dto.toJson())
        .eq('id', check.id);
  }
}
