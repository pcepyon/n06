import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/tracking/domain/entities/audit_log.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';
import 'package:n06/features/tracking/domain/usecases/validate_symptom_edit_usecase.dart';
import 'package:n06/features/tracking/domain/usecases/log_record_change_usecase.dart';
import 'package:n06/features/tracking/application/providers.dart';
import 'package:n06/features/dashboard/application/notifiers/dashboard_notifier.dart';
import 'package:uuid/uuid.dart';

class SymptomRecordEditNotifier extends AsyncNotifier<void> {
  late ValidateSymptomEditUseCase _validateUseCase;
  late LogRecordChangeUseCase _logUseCase;

  @override
  Future<void> build() async {
    _validateUseCase = ValidateSymptomEditUseCase();
    _logUseCase = LogRecordChangeUseCase(
      ref.watch(auditRepositoryProvider),
    );
  }

  Future<void> updateSymptom({
    required String recordId,
    required SymptomLog updatedLog,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final trackingRepo = ref.read(trackingRepositoryProvider);

      // Validate symptom
      final validation = _validateUseCase.execute(
        severity: updatedLog.severity,
        symptomName: updatedLog.symptomName,
      );
      if (validation.isFailure) {
        throw Exception(validation.error ?? 'Invalid symptom');
      }

      // Get original log for audit
      final originalLog = await trackingRepo.getSymptomLogById(recordId);
      if (originalLog == null) {
        throw Exception('Record not found');
      }

      // Update
      await trackingRepo.updateSymptomLog(recordId, updatedLog);

      // Log change
      await _logUseCase.execute(AuditLog(
        id: const Uuid().v4(),
        userId: updatedLog.userId,
        recordId: recordId,
        recordType: 'symptom',
        changeType: 'update',
        oldValue: {
          'symptomName': originalLog.symptomName,
          'severity': originalLog.severity,
          'tags': originalLog.tags,
          'note': originalLog.note,
        },
        newValue: {
          'symptomName': updatedLog.symptomName,
          'severity': updatedLog.severity,
          'tags': updatedLog.tags,
          'note': updatedLog.note,
        },
        timestamp: DateTime.now(),
      ));

      // Invalidate dashboard to trigger statistics recalculation
      ref.invalidate(dashboardNotifierProvider);
    });
  }

  Future<void> deleteSymptom({
    required String recordId,
    required String userId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final trackingRepo = ref.read(trackingRepositoryProvider);

      // Get original log for audit
      final originalLog = await trackingRepo.getSymptomLogById(recordId);
      if (originalLog == null) {
        throw Exception('Record not found');
      }

      // Delete (cascade: true means related tags and feedback are also deleted)
      await trackingRepo.deleteSymptomLog(recordId, cascade: true);

      // Log deletion
      await _logUseCase.execute(AuditLog(
        id: const Uuid().v4(),
        userId: userId,
        recordId: recordId,
        recordType: 'symptom',
        changeType: 'delete',
        oldValue: {
          'symptomName': originalLog.symptomName,
          'severity': originalLog.severity,
          'tags': originalLog.tags,
          'note': originalLog.note,
          'logDate': originalLog.logDate.toIso8601String(),
        },
        newValue: null,
        timestamp: DateTime.now(),
      ));

      // Invalidate dashboard to trigger statistics recalculation
      ref.invalidate(dashboardNotifierProvider);
    });
  }
}
