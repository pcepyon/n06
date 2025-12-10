import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:n06/core/encryption/domain/encryption_service.dart';
import 'package:n06/features/onboarding/domain/repositories/medication_repository.dart';
import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';
import 'package:n06/features/tracking/infrastructure/repositories/supabase_medication_repository.dart';

/// Adapter that bridges onboarding MedicationRepository interface
/// to tracking's SupabaseMedicationRepository implementation.
///
/// This adapter exists because onboarding defines its own simplified
/// MedicationRepository interface, while the actual implementation
/// is in tracking feature's SupabaseMedicationRepository.
class OnboardingMedicationRepositoryAdapter implements MedicationRepository {
  final SupabaseMedicationRepository _trackingRepo;

  OnboardingMedicationRepositoryAdapter(
    SupabaseClient supabase,
    EncryptionService encryptionService,
  ) : _trackingRepo = SupabaseMedicationRepository(supabase, encryptionService);

  @override
  Future<void> saveDosagePlan(DosagePlan plan) {
    return _trackingRepo.saveDosagePlan(plan);
  }

  @override
  Future<DosagePlan?> getActiveDosagePlan(String userId) {
    return _trackingRepo.getActiveDosagePlan(userId);
  }

  @override
  Future<void> updateDosagePlan(DosagePlan plan) {
    return _trackingRepo.updateDosagePlan(plan);
  }
}
