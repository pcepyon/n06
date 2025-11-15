import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/weight_log.dart';
import '../../domain/entities/symptom_log.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../dtos/weight_log_dto.dart';
import '../dtos/symptom_log_dto.dart';

/// Supabase implementation of TrackingRepository
///
/// Manages weight logs and symptom logs with context tags.
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
  // Symptom Logs
  // ============================================

  @override
  Future<void> saveSymptomLog(SymptomLog log) async {
    final dto = SymptomLogDto.fromEntity(log);

    // 1. Insert symptom_log
    final symptomResponse = await _supabase
        .from('symptom_logs')
        .insert(dto.toJson())
        .select()
        .single();

    // 2. Insert context_tags if any
    if (log.tags.isNotEmpty) {
      final tags = log.tags.map((tag) => {
        'symptom_log_id': symptomResponse['id'],
        'tag_name': tag,
      }).toList();

      await _supabase.from('symptom_context_tags').insert(tags);
    }
  }

  @override
  Future<SymptomLog?> getSymptomLogById(String id) async {
    final response = await _supabase
        .from('symptom_logs')
        .select('*, symptom_context_tags(tag_name)')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;

    // Extract tags
    final tags = (response['symptom_context_tags'] as List?)
        ?.map((tag) => tag['tag_name'] as String)
        .toList() ?? [];

    // Remove nested data before DTO parsing
    final symptomJson = Map<String, dynamic>.from(response);
    symptomJson.remove('symptom_context_tags');

    final dto = SymptomLogDto.fromJson(symptomJson);
    return dto.toEntity(tags: tags);
  }

  @override
  Future<List<SymptomLog>> getSymptomLogs(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    PostgrestFilterBuilder query = _supabase
        .from('symptom_logs')
        .select('*, symptom_context_tags(tag_name)')
        .eq('user_id', userId);

    if (startDate != null) {
      query = query.gte('log_date', startDate.toIso8601String().split('T')[0]);
    }
    if (endDate != null) {
      query = query.lte('log_date', endDate.toIso8601String().split('T')[0]);
    }

    final response = await query.order('log_date', ascending: false);

    return (response as List).map((json) {
      // Extract tags
      final tags = (json['symptom_context_tags'] as List?)
          ?.map((tag) => tag['tag_name'] as String)
          .toList() ?? [];

      // Remove nested data before DTO parsing
      final symptomJson = Map<String, dynamic>.from(json);
      symptomJson.remove('symptom_context_tags');

      final dto = SymptomLogDto.fromJson(symptomJson);
      return dto.toEntity(tags: tags);
    }).toList();
  }

  @override
  Future<void> deleteSymptomLog(String id, {bool cascade = true}) async {
    // CASCADE DELETE will automatically delete context_tags
    await _supabase.from('symptom_logs').delete().eq('id', id);
  }

  @override
  Future<void> updateSymptomLog(String id, SymptomLog updatedLog) async {
    final dto = SymptomLogDto.fromEntity(updatedLog);

    // 1. Update symptom_log
    await _supabase
        .from('symptom_logs')
        .update(dto.toJson())
        .eq('id', id);

    // 2. Delete old tags and insert new ones
    await _supabase.from('symptom_context_tags').delete().eq('symptom_log_id', id);

    if (updatedLog.tags.isNotEmpty) {
      final tags = updatedLog.tags.map((tag) => {
        'symptom_log_id': id,
        'tag_name': tag,
      }).toList();

      await _supabase.from('symptom_context_tags').insert(tags);
    }
  }

  @override
  Stream<List<SymptomLog>> watchSymptomLogs(String userId) {
    return _supabase
        .from('symptom_logs')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('log_date', ascending: false)
        .asyncMap((data) async {
      // For each symptom log, fetch its tags
      final logs = <SymptomLog>[];
      for (final json in data) {
        final symptomLogId = json['id'] as String;

        // Fetch tags for this symptom log
        final tagsResponse = await _supabase
            .from('symptom_context_tags')
            .select('tag_name')
            .eq('symptom_log_id', symptomLogId);

        final tags = (tagsResponse as List)
            .map((tag) => tag['tag_name'] as String)
            .toList();

        final dto = SymptomLogDto.fromJson(json);
        logs.add(dto.toEntity(tags: tags));
      }
      return logs;
    });
  }

  // ============================================
  // Tag-based Queries
  // ============================================

  @override
  Future<List<SymptomLog>> getSymptomLogsByTag(String tagName) async {
    final response = await _supabase
        .from('symptom_context_tags')
        .select('symptom_log_id, symptom_logs!inner(*, symptom_context_tags(tag_name))')
        .eq('tag_name', tagName);

    return (response as List).map((json) {
      final symptomJson = json['symptom_logs'] as Map<String, dynamic>;

      // Extract all tags
      final tags = (symptomJson['symptom_context_tags'] as List?)
          ?.map((tag) => tag['tag_name'] as String)
          .toList() ?? [];

      // Remove nested data
      symptomJson.remove('symptom_context_tags');

      final dto = SymptomLogDto.fromJson(symptomJson);
      return dto.toEntity(tags: tags);
    }).toList();
  }

  @override
  Future<List<String>> getAllTags(String userId) async {
    final response = await _supabase
        .from('symptom_logs')
        .select('id, symptom_context_tags(tag_name)')
        .eq('user_id', userId);

    final tagSet = <String>{};
    for (final json in response as List) {
      final tags = (json['symptom_context_tags'] as List?)
          ?.map((tag) => tag['tag_name'] as String)
          .toList() ?? [];
      tagSet.addAll(tags);
    }

    return tagSet.toList();
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
    return DateTime.parse(response['changed_at'] as String);
  }
}
