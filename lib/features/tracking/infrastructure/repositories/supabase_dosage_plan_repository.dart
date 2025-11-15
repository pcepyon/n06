import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/dosage_plan.dart';
import '../../domain/entities/plan_change_history.dart';
import '../../domain/repositories/dosage_plan_repository.dart';
import '../dtos/dosage_plan_dto.dart';
import '../dtos/plan_change_history_dto.dart';

/// Supabase implementation of DosagePlanRepository
///
/// Provides persistent storage and retrieval of dosage plans and their change history
/// using Supabase PostgreSQL database.
class SupabaseDosagePlanRepository implements DosagePlanRepository {
  final SupabaseClient _supabase;

  SupabaseDosagePlanRepository(this._supabase);

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
  Future<DosagePlan?> getDosagePlan(String planId) async {
    final response = await _supabase
        .from('dosage_plans')
        .select()
        .eq('id', planId)
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

  @override
  Future<void> savePlanChangeHistory(PlanChangeHistory history) async {
    final dto = PlanChangeHistoryDto.fromEntity(history);
    await _supabase.from('plan_change_history').insert(dto.toJson());
  }

  @override
  Future<void> updatePlanWithHistory(
    DosagePlan plan,
    PlanChangeHistory history,
  ) async {
    final planDto = DosagePlanDto.fromEntity(plan);
    final historyDto = PlanChangeHistoryDto.fromEntity(history);

    // Supabase doesn't support multi-table transactions directly,
    // so we use RPC for atomic operation
    // For now, we'll do sequential operations
    // TODO: Consider creating a PostgreSQL function for true atomicity

    // Update plan first
    await _supabase
        .from('dosage_plans')
        .update(planDto.toJson())
        .eq('id', plan.id);

    // Then save history
    await _supabase.from('plan_change_history').insert(historyDto.toJson());
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
}
