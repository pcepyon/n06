import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:n06/core/providers.dart';
import 'package:n06/core/encryption/application/providers.dart';
import 'package:n06/features/tracking/application/notifiers/weight_record_edit_notifier.dart';
import 'package:n06/features/tracking/application/notifiers/dose_record_edit_notifier.dart';
import 'package:n06/features/tracking/application/usecases/update_dosage_plan_usecase.dart';
import 'package:n06/features/tracking/domain/entities/medication.dart';
import 'package:n06/features/tracking/domain/repositories/audit_repository.dart';
import 'package:n06/features/tracking/domain/repositories/dosage_plan_repository.dart';
import 'package:n06/features/tracking/domain/repositories/dose_schedule_repository.dart';
import 'package:n06/features/tracking/domain/repositories/medication_repository.dart';
import 'package:n06/features/tracking/domain/repositories/medication_master_repository.dart';
import 'package:n06/features/tracking/domain/repositories/tracking_repository.dart';
import 'package:n06/features/tracking/domain/usecases/analyze_plan_change_impact_usecase.dart';
import 'package:n06/features/tracking/domain/usecases/injection_site_rotation_usecase.dart';
import 'package:n06/features/tracking/domain/usecases/missed_dose_analyzer_usecase.dart';
import 'package:n06/features/tracking/domain/usecases/recalculate_dose_schedule_usecase.dart';
import 'package:n06/features/tracking/domain/usecases/schedule_generator_usecase.dart';
import 'package:n06/features/tracking/infrastructure/services/notification_service.dart';
import 'package:n06/features/tracking/infrastructure/repositories/supabase_tracking_repository.dart';
import 'package:n06/features/tracking/infrastructure/repositories/supabase_medication_repository.dart';
import 'package:n06/features/tracking/infrastructure/repositories/supabase_medication_master_repository.dart';
import 'package:n06/features/tracking/infrastructure/repositories/supabase_dosage_plan_repository.dart';
import 'package:n06/features/tracking/infrastructure/repositories/supabase_dose_schedule_repository.dart';
import 'package:n06/features/tracking/infrastructure/repositories/supabase_audit_repository.dart';

// Re-export tracking notifier provider (Code Generated)
// NOTE: trackingProvider is the new Code Generated provider name
export 'package:n06/features/tracking/application/notifiers/tracking_notifier.dart' show trackingProvider;

part 'providers.g.dart';

// Repository Providers - Supabase implementations
@riverpod
MedicationRepository medicationRepository(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  final encryptionService = ref.watch(encryptionServiceProvider);
  return SupabaseMedicationRepository(supabase, encryptionService);
}

@riverpod
DosagePlanRepository dosagePlanRepository(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseDosagePlanRepository(supabase);
}

@riverpod
DoseScheduleRepository doseScheduleRepository(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseDoseScheduleRepository(supabase);
}

@riverpod
TrackingRepository trackingRepository(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  final encryptionService = ref.watch(encryptionServiceProvider);
  return SupabaseTrackingRepository(supabase, encryptionService);
}

@riverpod
AuditRepository auditRepository(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseAuditRepository(supabase);
}

// Medication Master Repository (마스터 테이블 조회)
@riverpod
MedicationMasterRepository medicationMasterRepository(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseMedicationMasterRepository(supabase);
}

// Active Medications Provider (활성화된 약물 목록)
@riverpod
Future<List<Medication>> activeMedications(Ref ref) async {
  final repo = ref.watch(medicationMasterRepositoryProvider);
  return repo.getActiveMedications();
}

// UseCase Providers with Code Generation
@riverpod
ScheduleGeneratorUseCase scheduleGeneratorUseCase(Ref ref) {
  return ScheduleGeneratorUseCase();
}

@riverpod
InjectionSiteRotationUseCase injectionSiteRotationUseCase(Ref ref) {
  return InjectionSiteRotationUseCase();
}

@riverpod
MissedDoseAnalyzerUseCase missedDoseAnalyzerUseCase(Ref ref) {
  return MissedDoseAnalyzerUseCase();
}

// UF-009: UpdateDosagePlan UseCase Providers
@riverpod
RecalculateDoseScheduleUseCase recalculateDoseScheduleUseCase(Ref ref) {
  return RecalculateDoseScheduleUseCase();
}

@riverpod
AnalyzePlanChangeImpactUseCase analyzePlanChangeImpactUseCase(Ref ref) {
  return AnalyzePlanChangeImpactUseCase();
}

// UpdateDosagePlanUseCase Provider
@riverpod
UpdateDosagePlanUseCase updateDosagePlanUseCase(Ref ref) {
  final medicationRepository = ref.watch(medicationRepositoryProvider);
  final analyzeImpactUseCase = ref.watch(analyzePlanChangeImpactUseCaseProvider);
  final recalculateScheduleUseCase = ref.watch(recalculateDoseScheduleUseCaseProvider);

  return UpdateDosagePlanUseCase(
    medicationRepository: medicationRepository,
    analyzeImpactUseCase: analyzeImpactUseCase,
    recalculateScheduleUseCase: recalculateScheduleUseCase,
  );
}

// Service Providers with Code Generation
@riverpod
NotificationService notificationService(Ref ref) {
  return NotificationService();
}

// MedicationNotifier Provider는 medication_notifier.dart에서 @riverpod으로 자동 생성됨
// TrackingNotifier Provider는 tracking_notifier.dart에서 @riverpod으로 자동 생성됨

// UF-011: Weight Record Edit Notifier Provider
final weightRecordEditNotifierProvider = AsyncNotifierProvider<WeightRecordEditNotifier, void>(
  () => WeightRecordEditNotifier(),
);

// UF-011: Dose Record Edit Notifier Provider
final doseRecordEditNotifierProvider = AsyncNotifierProvider<DoseRecordEditNotifier, void>(
  () => DoseRecordEditNotifier(),
);
