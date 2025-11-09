import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:n06/core/providers.dart';
import 'package:n06/features/tracking/application/notifiers/emergency_check_notifier.dart';
import 'package:n06/features/tracking/application/notifiers/medication_notifier.dart';
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
import 'package:n06/features/tracking/infrastructure/repositories/isar_tracking_repository.dart';
import 'package:n06/features/tracking/infrastructure/repositories/isar_medication_repository.dart';
import 'package:n06/features/tracking/infrastructure/repositories/isar_dosage_plan_repository.dart';
import 'package:n06/features/tracking/infrastructure/repositories/isar_dose_schedule_repository.dart';
import 'package:n06/features/tracking/infrastructure/repositories/isar_emergency_check_repository.dart';
import 'package:n06/features/tracking/infrastructure/repositories/isar_audit_repository.dart';

part 'providers.g.dart';

// Repository Providers with Code Generation
@riverpod
MedicationRepository medicationRepository(MedicationRepositoryRef ref) {
  final isar = ref.watch(isarProvider);
  return IsarMedicationRepository(isar);
}

@riverpod
DosagePlanRepository dosagePlanRepository(DosagePlanRepositoryRef ref) {
  final isar = ref.watch(isarProvider);
  return IsarDosagePlanRepository(isar);
}

@riverpod
DoseScheduleRepository doseScheduleRepository(DoseScheduleRepositoryRef ref) {
  final isar = ref.watch(isarProvider);
  return IsarDoseScheduleRepository(isar);
}

@riverpod
TrackingRepository trackingRepository(TrackingRepositoryRef ref) {
  final isar = ref.watch(isarProvider);
  return IsarTrackingRepository(isar);
}

@riverpod
EmergencyCheckRepository emergencyCheckRepository(EmergencyCheckRepositoryRef ref) {
  final isar = ref.watch(isarProvider);
  return IsarEmergencyCheckRepository(isar);
}

@riverpod
IsarAuditRepository auditRepository(AuditRepositoryRef ref) {
  final isar = ref.watch(isarProvider);
  return IsarAuditRepository(isar);
}

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

@riverpod
UpdateDosagePlanUseCase updateDosagePlanUseCase(UpdateDosagePlanUseCaseRef ref) {
  final medicationRepository = ref.watch(medicationRepositoryProvider);
  final validateUseCase = ref.watch(validateDosagePlanUseCaseProvider);
  final analyzeImpactUseCase = ref.watch(analyzePlanChangeImpactUseCaseProvider);
  final recalculateScheduleUseCase = ref.watch(recalculateDoseScheduleUseCaseProvider);

  return UpdateDosagePlanUseCase(
    medicationRepository: medicationRepository,
    validateUseCase: validateUseCase,
    analyzeImpactUseCase: analyzeImpactUseCase,
    recalculateScheduleUseCase: recalculateScheduleUseCase,
  );
}

// Service Providers with Code Generation
@riverpod
NotificationService notificationService(NotificationServiceRef ref) {
  return NotificationService();
}

// Notifier Provider - requires userId from auth state
final medicationNotifierProvider = StateNotifierProvider.autoDispose<
    MedicationNotifier,
    MedicationState>((ref) {
  final repository = ref.watch(medicationRepositoryProvider);
  final scheduleGenerator = ref.watch(scheduleGeneratorUseCaseProvider);
  final injectionSiteRotation = ref.watch(injectionSiteRotationUseCaseProvider);
  final missedDoseAnalyzer = ref.watch(missedDoseAnalyzerUseCaseProvider);
  final notificationService = ref.watch(notificationServiceProvider);

  return MedicationNotifier(
    repository: repository,
    scheduleGeneratorUseCase: scheduleGenerator,
    injectionSiteRotationUseCase: injectionSiteRotation,
    missedDoseAnalyzerUseCase: missedDoseAnalyzer,
    notificationService: notificationService,
  );
});

// Tracking Notifier Provider
final trackingNotifierProvider =
    StateNotifierProvider.autoDispose<TrackingNotifier, AsyncValue<TrackingState>>(
  (ref) {
    final repository = ref.watch(trackingRepositoryProvider);
    // userId는 AuthNotifier에서 가져와야 함
    // 현재는 null로 설정
    return TrackingNotifier(
      repository: repository,
      userId: null,
    );
  },
);

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
