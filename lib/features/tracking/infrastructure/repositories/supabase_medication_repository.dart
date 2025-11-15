import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/dosage_plan.dart';
import '../../domain/entities/dose_record.dart';
import '../../domain/entities/dose_schedule.dart';
import '../../domain/entities/plan_change_history.dart';
import '../../domain/repositories/medication_repository.dart';
import '../dtos/dosage_plan_dto.dart';
import '../dtos/dose_record_dto.dart';
import '../dtos/dose_schedule_dto.dart';
import '../dtos/plan_change_history_dto.dart';

/// Supabase implementation of MedicationRepository
///
/// Handles dose records, dose schedules, dosage plans, and change history.
/// For cleaner separation of concerns, consider using the dedicated repositories:
/// - SupabaseDosagePlanRepository for dosage plan operations
/// - SupabaseDoseScheduleRepository for schedule operations
class SupabaseMedicationRepository implements MedicationRepository {
  final SupabaseClient _supabase;

  SupabaseMedicationRepository(this._supabase);

  // ============================================
  // DoseRecord Operations
  // ============================================

  @override
  Future<List<DoseRecord>> getDoseRecords(String planId) async {
    final response = await _supabase
        .from('dose_records')
        .select()
        .eq('dosage_plan_id', planId)
        .order('administered_at', ascending: false);

    return (response as List)
        .map((json) => DoseRecordDto.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<List<DoseRecord>> getRecentDoseRecords(String planId, int days) async {
    final since = DateTime.now().subtract(Duration(days: days));

    final response = await _supabase
        .from('dose_records')
        .select()
        .eq('dosage_plan_id', planId)
        .gte('administered_at', since.toIso8601String())
        .order('administered_at', ascending: false);

    return (response as List)
        .map((json) => DoseRecordDto.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<void> saveDoseRecord(DoseRecord record) async {
    final dto = DoseRecordDto.fromEntity(record);
    await _supabase.from('dose_records').insert(dto.toJson());
  }

  @override
  Future<void> deleteDoseRecord(String recordId) async {
    await _supabase
        .from('dose_records')
        .delete()
        .eq('id', recordId);
  }

  @override
  Future<bool> isDuplicateDoseRecord(
    String planId,
    DateTime scheduledDate,
  ) async {
    final date = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
    );
    final endDate = date.add(const Duration(days: 1));

    final response = await _supabase
        .from('dose_records')
        .select('id')
        .eq('dosage_plan_id', planId)
        .gte('administered_at', date.toIso8601String())
        .lt('administered_at', endDate.toIso8601String())
        .limit(1)
        .maybeSingle();

    return response != null;
  }

  @override
  Future<DoseRecord?> getDoseRecordByDate(
    String planId,
    DateTime date,
  ) async {
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = startDate.add(const Duration(days: 1));

    final response = await _supabase
        .from('dose_records')
        .select()
        .eq('dosage_plan_id', planId)
        .gte('administered_at', startDate.toIso8601String())
        .lt('administered_at', endDate.toIso8601String())
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return DoseRecordDto.fromJson(response).toEntity();
  }

  @override
  Future<DoseRecord?> getDoseRecord(String recordId) async {
    final response = await _supabase
        .from('dose_records')
        .select()
        .eq('id', recordId)
        .maybeSingle();

    if (response == null) return null;
    return DoseRecordDto.fromJson(response).toEntity();
  }

  @override
  Future<void> updateDoseRecord(
    String recordId,
    double doseMg,
    String injectionSite,
    String? note,
  ) async {
    await _supabase.from('dose_records').update({
      'actual_dose_mg': doseMg,
      'injection_site': injectionSite,
      'note': note,
    }).eq('id', recordId);
  }

  // ============================================
  // DoseSchedule Operations (Backward Compatibility)
  // ============================================

  @override
  Future<List<DoseSchedule>> getDoseSchedules(String planId) async {
    final response = await _supabase
        .from('dose_schedules')
        .select()
        .eq('dosage_plan_id', planId)
        .order('scheduled_date', ascending: true);

    return (response as List)
        .map((json) => DoseScheduleDto.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<void> saveDoseSchedules(List<DoseSchedule> schedules) async {
    final dtos = schedules.map((s) => DoseScheduleDto.fromEntity(s).toJson()).toList();
    await _supabase.from('dose_schedules').insert(dtos);
  }

  @override
  Future<void> deleteDoseSchedulesFrom(String planId, DateTime fromDate) async {
    await _supabase
        .from('dose_schedules')
        .delete()
        .eq('dosage_plan_id', planId)
        .gt('scheduled_date', fromDate.toIso8601String());
  }

  @override
  Future<void> updateDoseSchedule(DoseSchedule schedule) async {
    final dto = DoseScheduleDto.fromEntity(schedule);
    await _supabase
        .from('dose_schedules')
        .update(dto.toJson())
        .eq('id', schedule.id);
  }

  // ============================================
  // DosagePlan Operations (Backward Compatibility)
  // ============================================

  @override
  Future<DosagePlan?> getActiveDosagePlan(String userId) async {
    final response = await _supabase
        .from('dosage_plans')
        .select()
        .eq('user_id', userId)
        .eq('is_active', true)
        .maybeSingle();

    if (response == null) return null;
    return DosagePlanDto.fromJson(response).toEntity();
  }

  @override
  Future<void> saveDosagePlan(DosagePlan plan) async {
    final dto = DosagePlanDto.fromEntity(plan);
    await _supabase.from('dosage_plans').insert(dto.toJson());
  }

  @override
  Future<void> updateDosagePlan(DosagePlan plan) async {
    final dto = DosagePlanDto.fromEntity(plan);
    await _supabase
        .from('dosage_plans')
        .update(dto.toJson())
        .eq('id', plan.id);
  }

  @override
  Future<DosagePlan?> getDosagePlan(String planId) async {
    final response = await _supabase
        .from('dosage_plans')
        .select()
        .eq('id', planId)
        .maybeSingle();

    if (response == null) return null;
    return DosagePlanDto.fromJson(response).toEntity();
  }

  // ============================================
  // Plan Change History Operations
  // ============================================

  @override
  Future<void> savePlanChangeHistory(
    String planId,
    Map<String, dynamic> oldPlan,
    Map<String, dynamic> newPlan,
  ) async {
    final history = PlanChangeHistory(
      id: 'history_${DateTime.now().millisecondsSinceEpoch}',
      dosagePlanId: planId,
      changedAt: DateTime.now(),
      oldPlan: oldPlan,
      newPlan: newPlan,
    );

    final dto = PlanChangeHistoryDto.fromEntity(history);
    await _supabase.from('plan_change_history').insert(dto.toJson());
  }

  @override
  Future<List<PlanChangeHistory>> getPlanChangeHistory(String planId) async {
    final response = await _supabase
        .from('plan_change_history')
        .select()
        .eq('dosage_plan_id', planId)
        .order('changed_at', ascending: false);

    return (response as List)
        .map((json) => PlanChangeHistoryDto.fromJson(json).toEntity())
        .toList();
  }

  // ============================================
  // Streams (Real-time)
  // ============================================

  @override
  Stream<List<DoseRecord>> watchDoseRecords(String planId) {
    return _supabase
        .from('dose_records')
        .stream(primaryKey: ['id'])
        .eq('dosage_plan_id', planId)
        .order('administered_at', ascending: false)
        .map((data) => data
            .map((json) => DoseRecordDto.fromJson(json).toEntity())
            .toList());
  }

  @override
  Stream<DosagePlan?> watchActiveDosagePlan(String userId) {
    return _supabase
        .from('dosage_plans')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) {
      // Filter for active plans
      final activePlans = data.where((json) => json['is_active'] == true).toList();
      return activePlans.isEmpty
          ? null
          : DosagePlanDto.fromJson(activePlans.first).toEntity();
    });
  }

  @override
  Stream<List<DoseSchedule>> watchDoseSchedules(String planId) {
    return _supabase
        .from('dose_schedules')
        .stream(primaryKey: ['id'])
        .eq('dosage_plan_id', planId)
        .order('scheduled_date', ascending: true)
        .map((data) => data
            .map((json) => DoseScheduleDto.fromJson(json).toEntity())
            .toList());
  }
}
