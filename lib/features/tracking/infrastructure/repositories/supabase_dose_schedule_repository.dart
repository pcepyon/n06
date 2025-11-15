import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/dose_schedule.dart';
import '../../domain/repositories/dose_schedule_repository.dart';
import '../dtos/dose_schedule_dto.dart';

/// Supabase implementation of DoseScheduleRepository
///
/// Provides persistent storage and retrieval of dose schedules
/// using Supabase PostgreSQL database.
class SupabaseDoseScheduleRepository implements DoseScheduleRepository {
  final SupabaseClient _supabase;

  SupabaseDoseScheduleRepository(this._supabase);

  @override
  Future<List<DoseSchedule>> getSchedulesByPlanId(String dosagePlanId) async {
    final response = await _supabase
        .from('dose_schedules')
        .select()
        .eq('dosage_plan_id', dosagePlanId)
        .order('scheduled_date', ascending: true);

    return (response as List)
        .map((json) => DoseScheduleDto.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<void> saveBatchSchedules(List<DoseSchedule> schedules) async {
    if (schedules.isEmpty) return;

    final dtos = schedules
        .map((schedule) => DoseScheduleDto.fromEntity(schedule).toJson())
        .toList();

    await _supabase.from('dose_schedules').insert(dtos);
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
    return _supabase
        .from('dose_schedules')
        .stream(primaryKey: ['id'])
        .eq('dosage_plan_id', dosagePlanId)
        .order('scheduled_date', ascending: true)
        .map((data) => data
            .map((json) => DoseScheduleDto.fromJson(json).toEntity())
            .toList());
  }
}
