import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' as legacy;
import 'package:riverpod_annotation/riverpod_annotation.dart';
// TODO: Isar removed - imports will be replaced with Supabase
// import 'package:n06/core/providers.dart';
// import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/tracking/application/notifiers/emergency_check_notifier.dart';
import 'package:n06/features/tracking/application/notifiers/tracking_notifier.dart';
import 'package:n06/features/tracking/application/notifiers/weight_record_edit_notifier.dart';
import 'package:n06/features/tracking/application/notifiers/symptom_record_edit_notifier.dart';
import 'package:n06/features/tracking/application/notifiers/dose_record_edit_notifier.dart';
import 'package:n06/features/tracking/application/usecases/update_dosage_plan_usecase.dart';
import 'package:n06/features/tracking/domain/entities/emergency_symptom_check.dart';
import 'package:n06/features/tracking/domain/repositories/dosage_plan_repository.dart';
import 'package:n06/features/tracking/domain/repositories/dose_schedule_repository.dart';
import 'package:n06/features/tracking/domain/repositories/emergency_check_repository.dart';
import 'package:n06/features/tracking/domain/repositories/medication_repository.dart';
import 'package:n06/features/tracking/domain/repositories/tracking_repository.dart';
import 'package:n06/features/tracking/domain/usecases/analyze_plan_change_impact_usecase.dart';
import 'package:n06/features/tracking/domain/usecases/injection_site_rotation_usecase.dart';
import 'package:n06/features/tracking/domain/usecases/missed_dose_analyzer_usecase.dart';
import 'package:n06/features/tracking/domain/usecases/recalculate_dose_schedule_usecase.dart';
import 'package:n06/features/tracking/domain/usecases/schedule_generator_usecase.dart';
import 'package:n06/features/tracking/domain/usecases/validate_dosage_plan_usecase.dart';
import 'package:n06/features/tracking/infrastructure/services/notification_service.dart';
// import 'package:n06/features/tracking/infrastructure/repositories/isar_tracking_repository.dart';
// import 'package:n06/features/tracking/infrastructure/repositories/isar_medication_repository.dart';
// import 'package:n06/features/tracking/infrastructure/repositories/isar_dosage_plan_repository.dart';
// import 'package:n06/features/tracking/infrastructure/repositories/isar_dose_schedule_repository.dart';
// import 'package:n06/features/tracking/infrastructure/repositories/isar_emergency_check_repository.dart';
// import 'package:n06/features/tracking/infrastructure/repositories/isar_audit_repository.dart';

part 'providers.g.dart';

// TODO: Repository Providers - will be replaced with Supabase implementations
// @riverpod
// MedicationRepository medicationRepository(Ref ref) {
//   final isar = ref.watch(isarProvider);
//   return IsarMedicationRepository(isar);
// }

// @riverpod
// DosagePlanRepository dosagePlanRepository(Ref ref) {
//   final isar = ref.watch(isarProvider);
//   return IsarDosagePlanRepository(isar);
// }

// @riverpod
// DoseScheduleRepository doseScheduleRepository(Ref ref) {
//   final isar = ref.watch(isarProvider);
//   return IsarDoseScheduleRepository(isar);
// }

// @riverpod
// TrackingRepository trackingRepository(Ref ref) {
//   final isar = ref.watch(isarProvider);
//   return IsarTrackingRepository(isar);
// }

// @riverpod
// EmergencyCheckRepository emergencyCheckRepository(Ref ref) {
//   final isar = ref.watch(isarProvider);
//   return IsarEmergencyCheckRepository(isar);
// }

// @riverpod
// IsarAuditRepository auditRepository(Ref ref) {
//   final isar = ref.watch(isarProvider);
//   return IsarAuditRepository(isar);
// }

// UseCase Providers with Code Generation
@riverpod
ScheduleGeneratorUseCase scheduleGeneratorUseCase(ScheduleGeneratorUseCaseRef ref) {
  return ScheduleGeneratorUseCase();
}

@riverpod
InjectionSiteRotationUseCase injectionSiteRotationUseCase(InjectionSiteRotationUseCaseRef ref) {
  return InjectionSiteRotationUseCase();
}

@riverpod
MissedDoseAnalyzerUseCase missedDoseAnalyzerUseCase(MissedDoseAnalyzerUseCaseRef ref) {
  return MissedDoseAnalyzerUseCase();
}

// UF-009: UpdateDosagePlan UseCase Providers
@riverpod
ValidateDosagePlanUseCase validateDosagePlanUseCase(ValidateDosagePlanUseCaseRef ref) {
  return ValidateDosagePlanUseCase();
}

@riverpod
RecalculateDoseScheduleUseCase recalculateDoseScheduleUseCase(RecalculateDoseScheduleUseCaseRef ref) {
  return RecalculateDoseScheduleUseCase();
}

@riverpod
AnalyzePlanChangeImpactUseCase analyzePlanChangeImpactUseCase(AnalyzePlanChangeImpactUseCaseRef ref) {
  return AnalyzePlanChangeImpactUseCase();
}

// TODO: UpdateDosagePlanUseCase - temporarily disabled until Supabase migration
// @riverpod
// UpdateDosagePlanUseCase updateDosagePlanUseCase(Ref ref) {
//   final medicationRepository = ref.watch(medicationRepositoryProvider);
//   final validateUseCase = ref.watch(validateDosagePlanUseCaseProvider);
//   final analyzeImpactUseCase = ref.watch(analyzePlanChangeImpactUseCaseProvider);
//   final recalculateScheduleUseCase = ref.watch(recalculateDoseScheduleUseCaseProvider);

//   return UpdateDosagePlanUseCase(
//     medicationRepository: medicationRepository,
//     validateUseCase: validateUseCase,
//     analyzeImpactUseCase: analyzeImpactUseCase,
//     recalculateScheduleUseCase: recalculateScheduleUseCase,
//   );
// }

// Service Providers with Code Generation
@riverpod
NotificationService notificationService(NotificationServiceRef ref) {
  return NotificationService();
}

// MedicationNotifier Provider는 medication_notifier.dart에서 @riverpod으로 자동 생성됨

// TODO: Tracking Notifier Provider - temporarily disabled until Supabase migration
// final trackingNotifierProvider =
//     legacy.StateNotifierProvider.autoDispose<TrackingNotifier, AsyncValue<TrackingState>>(
//   (ref) {
//     final repository = ref.watch(trackingRepositoryProvider);
//     // AuthNotifier에서 userId 추출
//     final userId = ref.watch(authNotifierProvider).value?.id;

//     return TrackingNotifier(
//       repository: repository,
//       userId: userId,
//     );
//   },
// );

// Emergency Check Notifier Provider (F005)
final emergencyCheckNotifierProvider =
    AsyncNotifierProvider.autoDispose<EmergencyCheckNotifier, List<EmergencySymptomCheck>>(
  () => EmergencyCheckNotifier(),
);

// UF-011: Weight Record Edit Notifier Provider
final weightRecordEditNotifierProvider = AsyncNotifierProvider<WeightRecordEditNotifier, void>(
  () => WeightRecordEditNotifier(),
);

// UF-011: Symptom Record Edit Notifier Provider
final symptomRecordEditNotifierProvider = AsyncNotifierProvider<SymptomRecordEditNotifier, void>(
  () => SymptomRecordEditNotifier(),
);

// UF-011: Dose Record Edit Notifier Provider
final doseRecordEditNotifierProvider = AsyncNotifierProvider<DoseRecordEditNotifier, void>(
  () => DoseRecordEditNotifier(),
);
