import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:n06/features/tracking/domain/entities/medication.dart';
import 'package:n06/features/tracking/domain/repositories/medication_master_repository.dart';
import 'package:n06/features/tracking/infrastructure/dtos/medication_master_dto.dart';

/// Supabase 구현체 for MedicationMasterRepository
///
/// medications 마스터 테이블에서 약물 정보를 조회합니다.
class SupabaseMedicationMasterRepository implements MedicationMasterRepository {
  final SupabaseClient _supabase;

  SupabaseMedicationMasterRepository(this._supabase);

  @override
  Future<List<Medication>> getActiveMedications() async {
    final response = await _supabase
        .from('medications')
        .select()
        .eq('is_active', true)
        .order('display_order', ascending: true);

    return (response as List)
        .map((json) => MedicationMasterDto.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<Medication?> getMedicationById(String id) async {
    final response = await _supabase
        .from('medications')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return MedicationMasterDto.fromJson(response).toEntity();
  }

  @override
  Future<Medication?> getMedicationByDisplayName(String displayName) async {
    // displayName 형식: "Wegovy (세마글루타이드)"
    // name_en과 generic_name을 조합하여 매칭
    final medications = await getActiveMedications();

    try {
      return medications.firstWhere((m) => m.displayName == displayName);
    } catch (_) {
      // 정확히 일치하는 것이 없으면 name_en만으로 시도
      final nameEn = displayName.split(' (').first;
      try {
        return medications.firstWhere(
          (m) => m.nameEn.toLowerCase() == nameEn.toLowerCase(),
        );
      } catch (_) {
        return null;
      }
    }
  }
}
