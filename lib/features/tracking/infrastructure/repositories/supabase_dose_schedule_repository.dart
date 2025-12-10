import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:n06/core/encryption/domain/encryption_service.dart';
import 'package:n06/features/notification/domain/value_objects/notification_time.dart';
import '../../domain/entities/dose_schedule.dart';
import '../../domain/repositories/dose_schedule_repository.dart';
import '../dtos/dose_schedule_dto.dart';

/// Supabase implementation of DoseScheduleRepository
///
/// Provides persistent storage and retrieval of dose schedules
/// using Supabase PostgreSQL database.
/// 암호화: scheduled_dose_mg 필드
class SupabaseDoseScheduleRepository implements DoseScheduleRepository {
  final SupabaseClient _supabase;
  final EncryptionService _encryptionService;

  SupabaseDoseScheduleRepository(this._supabase, this._encryptionService);

  /// planId로 userId를 조회하여 암호화 서비스 초기화
  Future<void> _ensureEncryptionInitialized(String planId) async {
    final plan = await _supabase
        .from('dosage_plans')
        .select('user_id')
        .eq('id', planId)
        .single();
    await _encryptionService.initialize(plan['user_id'] as String);
  }

  @override
  Future<List<DoseSchedule>> getSchedulesByPlanId(String dosagePlanId) async {
    await _ensureEncryptionInitialized(dosagePlanId);

    final response = await _supabase
        .from('dose_schedules')
        .select()
        .eq('dosage_plan_id', dosagePlanId)
        .order('scheduled_date', ascending: true);

    return (response as List)
        .map((json) => _decryptDoseScheduleFromJson(json))
        .toList();
  }

  @override
  Future<void> saveBatchSchedules(List<DoseSchedule> schedules) async {
    if (schedules.isEmpty) return;

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
  Future<void> deleteFutureSchedules(
    String dosagePlanId,
    DateTime fromDate,
  ) async {
    await _supabase
        .from('dose_schedules')
        .delete()
        .eq('dosage_plan_id', dosagePlanId)
        .gt('scheduled_date', fromDate.toIso8601String());
  }

  @override
  Stream<List<DoseSchedule>> watchSchedulesByPlanId(String dosagePlanId) {
    // Note: Stream에서는 동기적으로 암호화 서비스를 사용할 수 없으므로
    // fallback 메서드 사용
    return _supabase
        .from('dose_schedules')
        .stream(primaryKey: ['id'])
        .eq('dosage_plan_id', dosagePlanId)
        .order('scheduled_date', ascending: true)
        .map((data) => data
            .map((json) => _decryptDoseScheduleFromJson(json))
            .toList());
  }

  /// DoseSchedule JSON 복호화 (평문 fallback 지원)
  DoseSchedule _decryptDoseScheduleFromJson(Map<String, dynamic> json) {
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
}
