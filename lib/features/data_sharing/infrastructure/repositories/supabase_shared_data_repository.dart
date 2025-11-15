import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/shared_data_report.dart';
import '../../domain/repositories/date_range.dart';
import '../../domain/repositories/shared_data_repository.dart';
import '../../../tracking/domain/entities/dose_record.dart';
import '../../../tracking/domain/entities/weight_log.dart';
import '../../../tracking/domain/entities/symptom_log.dart';
import '../../../tracking/domain/entities/dose_schedule.dart';
import '../../../tracking/domain/entities/emergency_symptom_check.dart';
import '../../../tracking/infrastructure/dtos/dose_record_dto.dart';
import '../../../tracking/infrastructure/dtos/weight_log_dto.dart';
import '../../../tracking/infrastructure/dtos/symptom_log_dto.dart';
import '../../../tracking/infrastructure/dtos/dose_schedule_dto.dart';
import '../../../tracking/infrastructure/dtos/emergency_symptom_check_dto.dart';

/// Supabase implementation of SharedDataRepository
///
/// Provides read-only access to user's data for sharing purposes.
/// Aggregates data from multiple tables for export/sharing.
class SupabaseSharedDataRepository implements SharedDataRepository {
  final SupabaseClient _supabase;

  SupabaseSharedDataRepository(this._supabase);

  @override
  Future<SharedDataReport> getReportData(
    String userId,
    DateRange dateRange,
  ) async {
    final now = DateTime.now();
    final endDate = now;
    final startDate = dateRange.getStartDate(endDate);

    // Fetch all data in parallel
    final weightLogs = await _fetchWeightLogs(userId, startDate, endDate);
    final symptomLogs = await _fetchSymptomLogs(userId, startDate, endDate);
    final doseRecords = await _fetchDoseRecords(userId, startDate, endDate);
    final emergencyChecks = await _fetchEmergencyChecks(userId, startDate, endDate);
    final doseSchedules = await _fetchDoseSchedules(userId, startDate, endDate);

    return SharedDataReport(
      dateRangeStart: startDate,
      dateRangeEnd: endDate,
      weightLogs: weightLogs,
      symptomLogs: symptomLogs,
      doseRecords: doseRecords,
      emergencyChecks: emergencyChecks,
      doseSchedules: doseSchedules,
    );
  }

  Future<List<WeightLog>> _fetchWeightLogs(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final response = await _supabase
        .from('weight_logs')
        .select()
        .eq('user_id', userId)
        .gte('log_date', startDate.toIso8601String().split('T')[0])
        .lte('log_date', endDate.toIso8601String().split('T')[0])
        .order('log_date', ascending: false);

    return (response as List)
        .map((json) => WeightLogDto.fromJson(json).toEntity())
        .toList();
  }

  Future<List<SymptomLog>> _fetchSymptomLogs(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final response = await _supabase
        .from('symptom_logs')
        .select('*, symptom_context_tags(tag_name)')
        .eq('user_id', userId)
        .gte('log_date', startDate.toIso8601String().split('T')[0])
        .lte('log_date', endDate.toIso8601String().split('T')[0])
        .order('log_date', ascending: false);

    return (response as List).map((json) {
      // Extract tags
      final tags = (json['symptom_context_tags'] as List?)
              ?.map((tag) => tag['tag_name'] as String)
              .toList() ??
          [];

      // Remove nested data before DTO parsing
      final symptomJson = Map<String, dynamic>.from(json);
      symptomJson.remove('symptom_context_tags');

      final dto = SymptomLogDto.fromJson(symptomJson);
      return dto.toEntity(tags: tags);
    }).toList();
  }

  Future<List<DoseRecord>> _fetchDoseRecords(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Need to join with dosage_plans to filter by user_id
    final response = await _supabase
        .from('dose_records')
        .select('*, dosage_plans!inner(user_id)')
        .eq('dosage_plans.user_id', userId)
        .gte('administered_at', startDate.toIso8601String())
        .lte('administered_at', endDate.toIso8601String())
        .order('administered_at', ascending: false);

    return (response as List).map((json) {
      // Remove nested dosage_plans data before DTO parsing
      final recordJson = Map<String, dynamic>.from(json);
      recordJson.remove('dosage_plans');

      return DoseRecordDto.fromJson(recordJson).toEntity();
    }).toList();
  }

  Future<List<EmergencySymptomCheck>> _fetchEmergencyChecks(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final response = await _supabase
        .from('emergency_symptom_checks')
        .select()
        .eq('user_id', userId)
        .gte('checked_at', startDate.toIso8601String())
        .lte('checked_at', endDate.toIso8601String())
        .order('checked_at', ascending: false);

    return (response as List)
        .map((json) => EmergencySymptomCheckDto.fromJson(json).toEntity())
        .toList();
  }

  Future<List<DoseSchedule>> _fetchDoseSchedules(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Need to join with dosage_plans to filter by user_id
    final response = await _supabase
        .from('dose_schedules')
        .select('*, dosage_plans!inner(user_id)')
        .eq('dosage_plans.user_id', userId)
        .gte('scheduled_date', startDate.toIso8601String().split('T')[0])
        .lte('scheduled_date', endDate.toIso8601String().split('T')[0])
        .order('scheduled_date', ascending: false);

    return (response as List).map((json) {
      // Remove nested dosage_plans data before DTO parsing
      final scheduleJson = Map<String, dynamic>.from(json);
      scheduleJson.remove('dosage_plans');

      return DoseScheduleDto.fromJson(scheduleJson).toEntity();
    }).toList();
  }
}
