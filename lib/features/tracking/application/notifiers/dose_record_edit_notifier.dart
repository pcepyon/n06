import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/tracking/domain/entities/audit_log.dart';
import 'package:n06/features/tracking/domain/usecases/log_record_change_usecase.dart';
import 'package:n06/features/tracking/application/providers.dart';
import 'package:n06/features/tracking/application/notifiers/medication_notifier.dart';
import 'package:n06/features/dashboard/application/notifiers/dashboard_notifier.dart';
import 'package:uuid/uuid.dart';

class DoseRecordEditNotifier extends AsyncNotifier<void> {
  late LogRecordChangeUseCase _logUseCase;

  @override
  Future<void> build() async {
    _logUseCase = LogRecordChangeUseCase(
      ref.watch(auditRepositoryProvider),
    );
  }

  Future<void> updateDoseRecord({
    required String recordId,
    required double newDoseMg,
    required String injectionSite,
    String? note,
    required String userId,
  }) async {
    // ✅ 작업 완료 보장을 위한 keepAlive
    final link = ref.keepAlive();

    state = const AsyncValue.loading();

    try {
      state = await AsyncValue.guard(() async {
        // Validate dose is positive
        if (newDoseMg <= 0) {
          throw Exception('투여량은 0보다 커야 합니다');
        }

        final medicationRepo = ref.read(medicationRepositoryProvider);

        // Get original record for audit
        final originalRecord = await medicationRepo.getDoseRecord(recordId);
        if (originalRecord == null) {
          throw Exception('Record not found');
        }

        // Update
        await medicationRepo.updateDoseRecord(
          recordId,
          newDoseMg,
          injectionSite,
          note,
        );

        // Log change
        await _logUseCase.execute(AuditLog(
          id: const Uuid().v4(),
          userId: userId,
          recordId: recordId,
          recordType: 'dose',
          changeType: 'update',
          oldValue: {
            'doseMg': originalRecord.actualDoseMg,
            'injectionSite': originalRecord.injectionSite,
            'note': originalRecord.note,
          },
          newValue: {
            'doseMg': newDoseMg,
            'injectionSite': injectionSite,
            'note': note,
          },
          timestamp: DateTime.now(),
        ));

        // ✅ async gap 후 mounted 체크
        if (!ref.mounted) {
          return;
        }

        // Invalidate providers to trigger UI refresh
        ref.invalidate(dashboardNotifierProvider);
        ref.invalidate(medicationNotifierProvider);
      });
    } finally {
      link.close();
    }
  }

  Future<void> deleteDoseRecord({
    required String recordId,
    required String userId,
  }) async {
    // ✅ 작업 완료 보장을 위한 keepAlive
    final link = ref.keepAlive();

    state = const AsyncValue.loading();

    try {
      state = await AsyncValue.guard(() async {
        final medicationRepo = ref.read(medicationRepositoryProvider);

        // Get original record for audit
        final originalRecord = await medicationRepo.getDoseRecord(recordId);
        if (originalRecord == null) {
          throw Exception('Record not found');
        }

        // Delete (note: schedule is NOT affected)
        await medicationRepo.deleteDoseRecord(recordId);

        // Log deletion
        await _logUseCase.execute(AuditLog(
          id: const Uuid().v4(),
          userId: userId,
          recordId: recordId,
          recordType: 'dose',
          changeType: 'delete',
          oldValue: {
            'doseMg': originalRecord.actualDoseMg,
            'injectionSite': originalRecord.injectionSite,
            'note': originalRecord.note,
            'administeredAt': originalRecord.administeredAt.toIso8601String(),
          },
          newValue: null,
          timestamp: DateTime.now(),
        ));

        // ✅ async gap 후 mounted 체크
        if (!ref.mounted) {
          return;
        }

        // Invalidate providers to trigger UI refresh
        ref.invalidate(dashboardNotifierProvider);
        ref.invalidate(medicationNotifierProvider);
      });
    } finally {
      link.close();
    }
  }
}
