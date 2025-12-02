import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/weight_log.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../dtos/weight_log_dto.dart';

/// Supabase implementation of TrackingRepository
///
/// Manages weight logs.
class SupabaseTrackingRepository implements TrackingRepository {
  final SupabaseClient _supabase;

  SupabaseTrackingRepository(this._supabase);

  // ============================================
  // Weight Logs
  // ============================================

  @override
  Future<void> saveWeightLog(WeightLog log) async {
    final dto = WeightLogDto.fromEntity(log);

    // UNIQUE (user_id, log_date) constraint will automatically handle duplicates
    await _supabase.from('weight_logs').upsert(
      dto.toJson(),
      onConflict: 'user_id,log_date',
    );
  }

  @override
  Future<WeightLog?> getWeightLog(String userId, DateTime logDate) async {
    final response = await _supabase
        .from('weight_logs')
        .select()
        .eq('user_id', userId)
        .eq('log_date', logDate.toIso8601String().split('T')[0])
        .maybeSingle();

    if (response == null) return null;
    return WeightLogDto.fromJson(response).toEntity();
  }

  @override
  Future<WeightLog?> getWeightLogById(String id) async {
    final response = await _supabase
        .from('weight_logs')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return WeightLogDto.fromJson(response).toEntity();
  }

  @override
  Future<List<WeightLog>> getWeightLogs(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    PostgrestFilterBuilder query = _supabase
        .from('weight_logs')
        .select()
        .eq('user_id', userId);

    if (startDate != null) {
      query = query.gte('log_date', startDate.toIso8601String().split('T')[0]);
    }
    if (endDate != null) {
      query = query.lte('log_date', endDate.toIso8601String().split('T')[0]);
    }

    final response = await query.order('log_date', ascending: false);

    return (response as List)
        .map((json) => WeightLogDto.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<void> deleteWeightLog(String id) async {
    await _supabase.from('weight_logs').delete().eq('id', id);
  }

  @override
  Future<void> updateWeightLog(String id, double newWeight) async {
    await _supabase
        .from('weight_logs')
        .update({'weight_kg': newWeight})
        .eq('id', id);
  }

  @override
  Future<void> updateWeightLogWithDate(
    String id,
    double newWeight,
    DateTime newDate,
  ) async {
    await _supabase.from('weight_logs').update({
      'weight_kg': newWeight,
      'log_date': newDate.toIso8601String().split('T')[0],
    }).eq('id', id);
  }

  @override
  Stream<List<WeightLog>> watchWeightLogs(String userId) {
    return _supabase
        .from('weight_logs')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('log_date', ascending: false)
        .map((data) => data
            .map((json) => WeightLogDto.fromJson(json).toEntity())
            .toList());
  }

  // ============================================
  // Dose Escalation Date
  // ============================================

  @override
  Future<DateTime?> getLatestDoseEscalationDate(String userId) async {
    final response = await _supabase
        .from('plan_change_history')
        .select('changed_at, dosage_plans!inner(user_id)')
        .eq('dosage_plans.user_id', userId)
        .order('changed_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return DateTime.parse(response['changed_at'] as String).toLocal();
  }
}
