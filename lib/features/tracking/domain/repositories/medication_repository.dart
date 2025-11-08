import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';
import 'package:n06/features/tracking/domain/entities/plan_change_history.dart';

/// Repository interface for medication-related data
///
/// This repository handles:
/// - Dose records (actual medication administration)
/// - Dose schedules (scheduled medication times)
/// - Dosage plans (medication plans)
/// - Plan change history (audit trail)
///
/// Note: For cleaner separation of concerns, consider using:
/// - DosagePlanRepository for dosage plan-specific operations
/// - DoseScheduleRepository for schedule-specific operations
abstract class MedicationRepository {
  // DoseRecord operations
  Future<List<DoseRecord>> getDoseRecords(String planId);
  Future<List<DoseRecord>> getRecentDoseRecords(String planId, int days);
  Future<void> saveDoseRecord(DoseRecord record);
  Future<void> deleteDoseRecord(String recordId);
  Future<bool> isDuplicateDoseRecord(String planId, DateTime scheduledDate);
  Future<DoseRecord?> getDoseRecordByDate(String planId, DateTime date);
  Future<DoseRecord?> getDoseRecord(String recordId);
  Future<void> updateDoseRecord(String recordId, double doseMg, String injectionSite, String? note);

  // DoseSchedule operations
  Future<List<DoseSchedule>> getDoseSchedules(String planId);
  Future<void> saveDoseSchedules(List<DoseSchedule> schedules);
  Future<void> deleteDoseSchedulesFrom(String planId, DateTime fromDate);
  Future<void> updateDoseSchedule(DoseSchedule schedule);

  // DosagePlan operations (backward compatibility)
  Future<DosagePlan?> getActiveDosagePlan(String userId);
  Future<void> saveDosagePlan(DosagePlan plan);
  Future<void> updateDosagePlan(DosagePlan plan);
  Future<DosagePlan?> getDosagePlan(String planId);

  // Plan Change History operations (backward compatibility)
  Future<void> savePlanChangeHistory(
    String planId,
    Map<String, dynamic> oldPlan,
    Map<String, dynamic> newPlan,
  );
  Future<List<PlanChangeHistory>> getPlanChangeHistory(String planId);

  // Streams (real-time)
  Stream<List<DoseRecord>> watchDoseRecords(String planId);
  Stream<DosagePlan?> watchActiveDosagePlan(String userId);
  Stream<List<DoseSchedule>> watchDoseSchedules(String planId);
}
