import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/tracking/domain/entities/audit_log.dart';
import 'package:n06/features/tracking/domain/usecases/validate_weight_edit_usecase.dart';
import 'package:n06/features/tracking/domain/usecases/validate_date_unique_constraint_usecase.dart';
import 'package:n06/features/tracking/domain/usecases/log_record_change_usecase.dart';
import 'package:n06/features/tracking/application/providers.dart';
import 'package:n06/features/dashboard/application/notifiers/dashboard_notifier.dart';
import 'package:uuid/uuid.dart';

class WeightRecordEditNotifier extends AsyncNotifier<void> {
  late ValidateWeightEditUseCase _validateUseCase;
  late ValidateDateUniqueConstraintUseCase _validateDateUseCase;
  late LogRecordChangeUseCase _logUseCase;

  @override
  Future<void> build() async {
    _validateUseCase = ValidateWeightEditUseCase();
    _validateDateUseCase = ValidateDateUniqueConstraintUseCase(
      ref.watch(trackingRepositoryProvider),
    );
    _logUseCase = LogRecordChangeUseCase(
      ref.watch(auditRepositoryProvider),
    );
  }

  Future<void> updateWeight({
    required String recordId,
    required double newWeight,
    required String userId,
    DateTime? newDate,
    bool allowOverwrite = false,
  }) async {
    // ✅ 작업 완료 보장을 위한 keepAlive
    final link = ref.keepAlive();

    state = const AsyncValue.loading();

    try {
      state = await AsyncValue.guard(() async {
        final trackingRepo = ref.read(trackingRepositoryProvider);

        // Validate weight
        final weightValidation = _validateUseCase.execute(newWeight);
        if (weightValidation.isFailure) {
          throw Exception(weightValidation.error ?? 'Invalid weight');
        }

        // Get original log
        final originalLog = await trackingRepo.getWeightLogById(recordId);
        if (originalLog == null) {
          throw Exception('Record not found');
        }

        // Validate date if changed
        if (newDate != null && newDate != originalLog.logDate) {
          final dateValidation = await _validateDateUseCase.execute(
            userId: userId,
            date: newDate,
            editingRecordId: recordId,
          );

          if (dateValidation.isConflict && !allowOverwrite) {
            throw Exception('Date conflict: ${dateValidation.existingRecordId}');
          }

          if (dateValidation.isFailure) {
            throw Exception(dateValidation.error ?? 'Invalid date');
          }

          // Update with new date
          await trackingRepo.updateWeightLogWithDate(recordId, newWeight, newDate);

          // Log change
          await _logUseCase.execute(AuditLog(
            id: const Uuid().v4(),
            userId: userId,
            recordId: recordId,
            recordType: 'weight',
            changeType: 'update',
            oldValue: {
              'weightKg': originalLog.weightKg,
              'logDate': originalLog.logDate.toIso8601String(),
            },
            newValue: {
              'weightKg': newWeight,
              'logDate': newDate.toIso8601String(),
            },
            timestamp: DateTime.now(),
          ));
        } else {
          // Update weight only
          if (originalLog.weightKg != newWeight) {
            await trackingRepo.updateWeightLog(recordId, newWeight);

            // Log change
            await _logUseCase.execute(AuditLog(
              id: const Uuid().v4(),
              userId: userId,
              recordId: recordId,
              recordType: 'weight',
              changeType: 'update',
              oldValue: {'weightKg': originalLog.weightKg},
              newValue: {'weightKg': newWeight},
              timestamp: DateTime.now(),
            ));
          }
        }

        // ✅ async gap 후 mounted 체크
        if (!ref.mounted) {
          return;
        }

        // Invalidate dashboard to trigger statistics recalculation
        ref.invalidate(dashboardNotifierProvider);
      });
    } finally {
      link.close();
    }
  }

  Future<void> deleteWeight({
    required String recordId,
    required String userId,
  }) async {
    // ✅ 작업 완료 보장을 위한 keepAlive
    final link = ref.keepAlive();

    state = const AsyncValue.loading();

    try {
      state = await AsyncValue.guard(() async {
        final trackingRepo = ref.read(trackingRepositoryProvider);

        // Get original log for audit
        final originalLog = await trackingRepo.getWeightLogById(recordId);
        if (originalLog == null) {
          throw Exception('Record not found');
        }

        // Delete
        await trackingRepo.deleteWeightLog(recordId);

        // Log deletion
        await _logUseCase.execute(AuditLog(
          id: const Uuid().v4(),
          userId: userId,
          recordId: recordId,
          recordType: 'weight',
          changeType: 'delete',
          oldValue: {
            'weightKg': originalLog.weightKg,
            'logDate': originalLog.logDate.toIso8601String(),
          },
          newValue: null,
          timestamp: DateTime.now(),
        ));

        // ✅ async gap 후 mounted 체크
        if (!ref.mounted) {
          return;
        }

        // Invalidate dashboard to trigger statistics recalculation
        ref.invalidate(dashboardNotifierProvider);
      });
    } finally {
      link.close();
    }
  }
}
