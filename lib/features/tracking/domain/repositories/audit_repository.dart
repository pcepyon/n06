import 'package:n06/features/tracking/domain/entities/audit_log.dart';

abstract class AuditRepository {
  Future<void> logChange(AuditLog log);
  Future<List<AuditLog>> getChangeLogs(String userId, String recordId);
}
