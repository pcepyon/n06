import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/audit_log.dart';
import '../../domain/repositories/audit_repository.dart';
import '../dtos/audit_log_dto.dart';

/// Supabase implementation of AuditRepository
///
/// Manages audit logs for tracking data changes in Supabase database.
class SupabaseAuditRepository implements AuditRepository {
  final SupabaseClient _supabase;

  SupabaseAuditRepository(this._supabase);

  @override
  Future<void> logChange(AuditLog log) async {
    final dto = AuditLogDto.fromEntity(log);
    await _supabase.from('audit_logs').insert(dto.toJson());
  }

  @override
  Future<List<AuditLog>> getChangeLogs(String userId, String recordId) async {
    final response = await _supabase
        .from('audit_logs')
        .select()
        .eq('user_id', userId)
        .eq('record_id', recordId)
        .order('timestamp', ascending: false);

    return (response as List)
        .map((json) => AuditLogDto.fromJson(json).toEntity())
        .toList();
  }
}
