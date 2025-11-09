import 'package:isar/isar.dart';
import 'package:n06/features/tracking/domain/entities/audit_log.dart';
import 'package:n06/features/tracking/domain/repositories/audit_repository.dart';

class IsarAuditRepository implements AuditRepository {
  final Isar _isar;

  IsarAuditRepository(this._isar);

  // For Phase 0 MVP, audit logs are kept in memory
  // In Phase 1, these will be persisted to Supabase or Isar
  final List<AuditLog> _auditLogs = [];

  @override
  Future<void> logChange(AuditLog log) async {
    // Store in memory (Phase 0)
    _auditLogs.add(log);
  }

  @override
  Future<List<AuditLog>> getChangeLogs(String userId, String recordId) async {
    return _auditLogs
        .where((log) => log.userId == userId && log.recordId == recordId)
        .toList();
  }
}
