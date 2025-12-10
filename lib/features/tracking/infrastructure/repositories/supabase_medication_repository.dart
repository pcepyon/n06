import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:n06/core/encryption/domain/encryption_service.dart';
import 'package:n06/features/notification/domain/value_objects/notification_time.dart';
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
/// Encrypts sensitive fields: actual_dose_mg, injection_site, note (dose_records)
/// and medication_name, initial_dose_mg, escalation_plan (dosage_plans)
class SupabaseMedicationRepository implements MedicationRepository {
  final SupabaseClient _supabase;
  final EncryptionService _encryptionService;

  SupabaseMedicationRepository(this._supabase, this._encryptionService);

  // ============================================
  // Helper: Initialize encryption with userId from planId
  // ============================================
  Future<void> _ensureEncryptionInitialized(String planId) async {
    final plan = await _supabase
        .from('dosage_plans')
        .select('user_id')
        .eq('id', planId)
        .single();
    await _encryptionService.initialize(plan['user_id'] as String);
  }

  // ============================================
  // DoseRecord Operations
  // ============================================

  @override
  Future<List<DoseRecord>> getDoseRecords(String planId) async {
    // 암호화 서비스 초기화
    await _ensureEncryptionInitialized(planId);
    final response = await _supabase
        .from('dose_records')
        .select()
        .eq('dosage_plan_id', planId)
        .order('administered_at', ascending: false);

    return (response as List)
        .map((json) => _decryptDoseRecordFromJson(json))
        .toList();
  }

  @override
  Future<List<DoseRecord>> getRecentDoseRecords(String planId, int days) async {
    // 암호화 서비스 초기화
    await _ensureEncryptionInitialized(planId);

    final since = DateTime.now().subtract(Duration(days: days));

    final response = await _supabase
        .from('dose_records')
        .select()
        .eq('dosage_plan_id', planId)
        .gte('administered_at', since.toIso8601String())
        .order('administered_at', ascending: false);

    return (response as List)
        .map((json) => _decryptDoseRecordFromJson(json))
        .toList();
  }

  @override
  Future<void> saveDoseRecord(DoseRecord record) async {
    // 암호화 서비스 초기화
    await _ensureEncryptionInitialized(record.dosagePlanId);
    final dto = DoseRecordDto.fromEntity(record);
    final json = dto.toJson();

    // 암호화: actual_dose_mg, injection_site, note
    json['actual_dose_mg'] = _encryptionService.encryptDouble(record.actualDoseMg);
    json['injection_site'] = _encryptionService.encrypt(record.injectionSite);
    json['note'] = _encryptionService.encrypt(record.note);

    await _supabase.from('dose_records').insert(json);
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
    // Note: 이 메서드는 암호화된 데이터를 사용하지 않으므로 초기화 불필요
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
    // 암호화 서비스 초기화
    await _ensureEncryptionInitialized(planId);
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
    return _decryptDoseRecordFromJson(response);
  }

  @override
  Future<DoseRecord?> getDoseRecord(String recordId) async {
    final response = await _supabase
        .from('dose_records')
        .select('*, dosage_plans!inner(user_id)')
        .eq('id', recordId)
        .maybeSingle();

    if (response == null) return null;

    // 암호화 서비스 초기화 (응답에서 user_id 추출)
    final userId = response['dosage_plans']['user_id'] as String;
    await _encryptionService.initialize(userId);

    return _decryptDoseRecordFromJson(response);
  }

  @override
  Future<void> updateDoseRecord(
    String recordId,
    double doseMg,
    String injectionSite,
    String? note,
  ) async {
    // 암호화 서비스 초기화 (JOIN으로 userId 조회)
    final record = await _supabase
        .from('dose_records')
        .select('dosage_plans!inner(user_id)')
        .eq('id', recordId)
        .single();
    final userId = record['dosage_plans']['user_id'] as String;
    await _encryptionService.initialize(userId);

    // 직접 update 쿼리 - 암호화 필요
    await _supabase.from('dose_records').update({
      'actual_dose_mg': _encryptionService.encryptDouble(doseMg),
      'injection_site': _encryptionService.encrypt(injectionSite),
      'note': _encryptionService.encrypt(note),
    }).eq('id', recordId);
  }

  /// DoseRecord JSON 복호화 (평문 fallback 지원)
  DoseRecord _decryptDoseRecordFromJson(Map<String, dynamic> json) {
    return DoseRecord(
      id: json['id'] as String,
      doseScheduleId: json['dose_schedule_id'] as String?,
      dosagePlanId: json['dosage_plan_id'] as String,
      administeredAt: DateTime.parse(json['administered_at'] as String).toLocal(),
      // 마이그레이션된 평문 데이터와 암호화된 데이터 모두 처리
      actualDoseMg: _encryptionService.decryptDoubleWithFallback(json['actual_dose_mg'] as String?) ?? 0.0,
      injectionSite: _encryptionService.decryptWithFallback(json['injection_site'] as String?),
      isCompleted: json['is_completed'] as bool,
      note: _encryptionService.decryptWithFallback(json['note'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  // ============================================
  // DoseSchedule Operations (Backward Compatibility)
  // ============================================

  @override
  Future<List<DoseSchedule>> getDoseSchedules(String planId) async {
    // 암호화 서비스 초기화
    await _ensureEncryptionInitialized(planId);

    final response = await _supabase
        .from('dose_schedules')
        .select()
        .eq('dosage_plan_id', planId)
        .order('scheduled_date', ascending: true);

    return (response as List)
        .map((json) => _decryptDoseScheduleFromJson(json))
        .toList();
  }

  @override
  Future<void> saveDoseSchedules(List<DoseSchedule> schedules) async {
    if (schedules.isEmpty) return;

    // 암호화 서비스 초기화
    await _ensureEncryptionInitialized(schedules.first.dosagePlanId);

    final encryptedDtos = schedules.map((s) {
      final dto = DoseScheduleDto.fromEntity(s);
      final json = dto.toJson();
      // 암호화: scheduled_dose_mg
      json['scheduled_dose_mg'] = _encryptionService.encryptDouble(s.scheduledDoseMg);
      return json;
    }).toList();

    await _supabase.from('dose_schedules').insert(encryptedDtos);
  }

  @override
  Future<void> deleteDoseSchedulesFrom(String planId, DateTime fromDate) async {
    await _supabase
        .from('dose_schedules')
        .delete()
        .eq('dosage_plan_id', planId)
        .gte('scheduled_date', fromDate.toIso8601String());
  }

  @override
  Future<void> deleteDoseSchedule(String scheduleId) async {
    await _supabase.from('dose_schedules').delete().eq('id', scheduleId);
  }

  @override
  Future<void> updateDoseSchedule(DoseSchedule schedule) async {
    // 암호화 서비스 초기화
    await _ensureEncryptionInitialized(schedule.dosagePlanId);

    final dto = DoseScheduleDto.fromEntity(schedule);
    final json = dto.toJson();
    // 암호화: scheduled_dose_mg
    json['scheduled_dose_mg'] = _encryptionService.encryptDouble(schedule.scheduledDoseMg);

    await _supabase
        .from('dose_schedules')
        .update(json)
        .eq('id', schedule.id);
  }

  /// DoseSchedule JSON 복호화
  DoseSchedule _decryptDoseScheduleFromJson(Map<String, dynamic> json) {
    // notification_time 파싱
    NotificationTime? notificationTime;
    if (json['notification_time'] != null) {
      final timeStr = json['notification_time'] as String;
      final parts = timeStr.split(':');
      notificationTime = NotificationTime(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    return DoseSchedule(
      id: json['id'] as String,
      dosagePlanId: json['dosage_plan_id'] as String,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String).toLocal(),
      // 마이그레이션된 평문 데이터와 암호화된 데이터 모두 처리
      scheduledDoseMg: _encryptionService.decryptDoubleWithFallback(json['scheduled_dose_mg'] as String?) ?? 0.0,
      notificationTime: notificationTime,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  // ============================================
  // DosagePlan Operations (Backward Compatibility)
  // ============================================

  @override
  Future<DosagePlan?> getActiveDosagePlan(String userId) async {
    // 암호화 서비스 초기화
    await _encryptionService.initialize(userId);

    final response = await _supabase
        .from('dosage_plans')
        .select()
        .eq('user_id', userId)
        .eq('is_active', true)
        .maybeSingle();

    if (response == null) return null;
    return _decryptDosagePlanFromJson(response);
  }

  @override
  Future<void> saveDosagePlan(DosagePlan plan) async {
    // 암호화 서비스 초기화
    await _encryptionService.initialize(plan.userId);

    final dto = DosagePlanDto.fromEntity(plan);
    final json = dto.toJson();

    // 암호화: medication_name, initial_dose_mg, escalation_plan
    json['medication_name'] = _encryptionService.encrypt(plan.medicationName);
    json['initial_dose_mg'] = _encryptionService.encryptDouble(plan.initialDoseMg);
    if (plan.escalationPlan != null) {
      final escalationJson = plan.escalationPlan!.map((step) => {
        'weeks_from_start': step.weeksFromStart,
        'dose_mg': step.doseMg,
      }).toList();
      json['escalation_plan'] = _encryptionService.encryptJsonList(escalationJson);
    } else {
      json['escalation_plan'] = null;
    }

    await _supabase.from('dosage_plans').insert(json);
  }

  @override
  Future<void> updateDosagePlan(DosagePlan plan) async {
    // 암호화 서비스 초기화
    await _encryptionService.initialize(plan.userId);

    final dto = DosagePlanDto.fromEntity(plan);
    final json = dto.toJson();

    // 암호화: medication_name, initial_dose_mg, escalation_plan
    json['medication_name'] = _encryptionService.encrypt(plan.medicationName);
    json['initial_dose_mg'] = _encryptionService.encryptDouble(plan.initialDoseMg);
    if (plan.escalationPlan != null) {
      final escalationJson = plan.escalationPlan!.map((step) => {
        'weeks_from_start': step.weeksFromStart,
        'dose_mg': step.doseMg,
      }).toList();
      json['escalation_plan'] = _encryptionService.encryptJsonList(escalationJson);
    } else {
      json['escalation_plan'] = null;
    }

    await _supabase
        .from('dosage_plans')
        .update(json)
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

    // 암호화 서비스 초기화 (응답에서 user_id 추출)
    final userId = response['user_id'] as String;
    await _encryptionService.initialize(userId);

    return _decryptDosagePlanFromJson(response);
  }

  /// DosagePlan JSON 복호화 (평문 fallback 지원)
  DosagePlan _decryptDosagePlanFromJson(Map<String, dynamic> json) {
    // escalation_plan 복호화 (평문 fallback)
    List<EscalationStep>? escalationPlan;
    final encryptedEscalation = json['escalation_plan'] as String?;
    if (encryptedEscalation != null) {
      final decryptedList = _encryptionService.decryptJsonListWithFallback(encryptedEscalation);
      if (decryptedList != null) {
        escalationPlan = decryptedList.map((item) {
          final map = item as Map<String, dynamic>;
          return EscalationStep(
            weeksFromStart: map['weeks_from_start'] as int,
            doseMg: (map['dose_mg'] as num).toDouble(),
          );
        }).toList();
      }
    }

    return DosagePlan(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      // 마이그레이션된 평문 데이터와 암호화된 데이터 모두 처리
      medicationName: _encryptionService.decryptWithFallback(json['medication_name'] as String?) ?? '',
      startDate: DateTime.parse(json['start_date'] as String).toLocal(),
      cycleDays: json['cycle_days'] as int,
      initialDoseMg: _encryptionService.decryptDoubleWithFallback(json['initial_dose_mg'] as String?) ?? 0.0,
      escalationPlan: escalationPlan,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
    );
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
    // 암호화 서비스 초기화
    await _ensureEncryptionInitialized(planId);

    final history = PlanChangeHistory(
      id: const Uuid().v4(),
      dosagePlanId: planId,
      changedAt: DateTime.now(),
      oldPlan: oldPlan,
      newPlan: newPlan,
    );

    final dto = PlanChangeHistoryDto.fromEntity(history);
    final json = dto.toJson();

    // 암호화: old_plan, new_plan
    json['old_plan'] = _encryptionService.encryptJson(oldPlan);
    json['new_plan'] = _encryptionService.encryptJson(newPlan);

    await _supabase.from('plan_change_history').insert(json);
  }

  @override
  Future<List<PlanChangeHistory>> getPlanChangeHistory(String planId) async {
    // 암호화 서비스 초기화
    await _ensureEncryptionInitialized(planId);

    final response = await _supabase
        .from('plan_change_history')
        .select()
        .eq('dosage_plan_id', planId)
        .order('changed_at', ascending: false);

    return (response as List)
        .map((json) => _decryptPlanChangeHistoryFromJson(json))
        .toList();
  }

  /// PlanChangeHistory JSON 복호화
  PlanChangeHistory _decryptPlanChangeHistoryFromJson(Map<String, dynamic> json) {
    return PlanChangeHistory(
      id: json['id'] as String,
      dosagePlanId: json['dosage_plan_id'] as String,
      changedAt: DateTime.parse(json['changed_at'] as String).toLocal(),
      oldPlan: _encryptionService.decryptJson(json['old_plan'] as String?) ?? {},
      newPlan: _encryptionService.decryptJson(json['new_plan'] as String?) ?? {},
    );
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
        .asyncMap((data) async {
      // 암호화 서비스 초기화 (Stream에서는 asyncMap 사용)
      await _ensureEncryptionInitialized(planId);
      return data.map((json) => _decryptDoseRecordFromJson(json)).toList();
    });
  }

  @override
  Stream<DosagePlan?> watchActiveDosagePlan(String userId) {
    return _supabase
        .from('dosage_plans')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .asyncMap((data) async {
      // 암호화 서비스 초기화 (Stream에서는 asyncMap 사용)
      await _encryptionService.initialize(userId);

      // Filter for active plans
      final activePlans = data.where((json) => json['is_active'] == true).toList();
      return activePlans.isEmpty
          ? null
          : _decryptDosagePlanFromJson(activePlans.first);
    });
  }

  @override
  Stream<List<DoseSchedule>> watchDoseSchedules(String planId) {
    return _supabase
        .from('dose_schedules')
        .stream(primaryKey: ['id'])
        .eq('dosage_plan_id', planId)
        .order('scheduled_date', ascending: true)
        .asyncMap((data) async {
      // 암호화 서비스 초기화 (Stream에서는 asyncMap 사용)
      await _ensureEncryptionInitialized(planId);
      return data.map((json) => _decryptDoseScheduleFromJson(json)).toList();
    });
  }
}
