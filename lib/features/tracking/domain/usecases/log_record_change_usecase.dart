import 'package:n06/features/tracking/domain/entities/audit_log.dart';
import 'package:n06/features/tracking/domain/repositories/audit_repository.dart';

class LogRecordChangeUseCase {
  final AuditRepository repository;

  LogRecordChangeUseCase(this.repository);

  Future<void> execute(AuditLog log) async {
    await repository.logChange(log);
  }
}
