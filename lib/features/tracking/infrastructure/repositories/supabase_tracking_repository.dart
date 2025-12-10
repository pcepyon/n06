import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:n06/core/encryption/domain/encryption_service.dart';
import '../../domain/entities/weight_log.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../dtos/weight_log_dto.dart';

/// Supabase implementation of TrackingRepository
///
/// Manages weight logs with encryption for sensitive data.
class SupabaseTrackingRepository implements TrackingRepository {
  final SupabaseClient _supabase;
  final EncryptionService _encryptionService;

  SupabaseTrackingRepository(this._supabase, this._encryptionService);

  // ============================================
  // Weight Logs
  // ============================================

  @override
  Future<void> saveWeightLog(WeightLog log) async {
    // 암호화 서비스 초기화
    await _encryptionService.initialize(log.userId);

    final dto = WeightLogDto.fromEntity(log);
    final json = dto.toJson();

    // 암호화: weight_kg
    json['weight_kg'] = _encryptionService.encryptDouble(log.weightKg);

    // UNIQUE (user_id, log_date) constraint will automatically handle duplicates
    await _supabase.from('weight_logs').upsert(
      json,
      onConflict: 'user_id,log_date',
    );
  }

  @override
  Future<WeightLog?> getWeightLog(String userId, DateTime logDate) async {
    // 암호화 서비스 초기화
    await _encryptionService.initialize(userId);

    final response = await _supabase
        .from('weight_logs')
        .select()
        .eq('user_id', userId)
        .eq('log_date', logDate.toIso8601String().split('T')[0])
        .maybeSingle();

    if (response == null) return null;
    return _decryptWeightLogFromJson(response);
  }

  @override
  Future<WeightLog?> getWeightLogById(String id) async {
    final response = await _supabase
        .from('weight_logs')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;

    // 암호화 서비스 초기화 (응답에서 user_id 추출)
    final userId = response['user_id'] as String;
    await _encryptionService.initialize(userId);

    return _decryptWeightLogFromJson(response);
  }

  @override
  Future<List<WeightLog>> getWeightLogs(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // 암호화 서비스 초기화
    await _encryptionService.initialize(userId);

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
        .map((json) => _decryptWeightLogFromJson(json))
        .toList();
  }

  @override
  Future<void> deleteWeightLog(String id) async {
    await _supabase.from('weight_logs').delete().eq('id', id);
  }

  @override
  Future<void> updateWeightLog(String id, double newWeight) async {
    // userId를 먼저 조회
    final existing = await _supabase
        .from('weight_logs')
        .select('user_id')
        .eq('id', id)
        .single();

    final userId = existing['user_id'] as String;
    await _encryptionService.initialize(userId);

    // 직접 update 쿼리 - 암호화 필요
    await _supabase
        .from('weight_logs')
        .update({'weight_kg': _encryptionService.encryptDouble(newWeight)})
        .eq('id', id);
  }

  @override
  Future<void> updateWeightLogWithDate(
    String id,
    double newWeight,
    DateTime newDate,
  ) async {
    // userId를 먼저 조회
    final existing = await _supabase
        .from('weight_logs')
        .select('user_id')
        .eq('id', id)
        .single();

    final userId = existing['user_id'] as String;
    await _encryptionService.initialize(userId);

    // 직접 update 쿼리 - 암호화 필요
    await _supabase.from('weight_logs').update({
      'weight_kg': _encryptionService.encryptDouble(newWeight),
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
        .asyncMap((data) async {
      // 암호화 서비스 초기화 (스트림에서는 asyncMap 사용)
      await _encryptionService.initialize(userId);
      return data.map((json) => _decryptWeightLogFromJson(json)).toList();
    });
  }

  /// JSON 응답에서 weight_kg 복호화 후 WeightLog 엔티티 생성
  WeightLog _decryptWeightLogFromJson(Map<String, dynamic> json) {
    // DB에서 암호화된 TEXT로 오는 weight_kg 복호화
    final encryptedWeight = json['weight_kg'] as String;
    final decryptedWeight = _encryptionService.decryptDouble(encryptedWeight);

    return WeightLog(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      logDate: DateTime.parse(json['log_date'] as String).toLocal(),
      weightKg: decryptedWeight ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
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
