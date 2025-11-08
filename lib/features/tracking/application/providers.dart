import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// Repository Providers
final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  // This should be provided by core/providers if Isar is available
  // For now, we'll create a simple implementation
  throw UnimplementedError(
      'medicationRepositoryProvider must be provided by app initialization');
});

final dosagePlanRepositoryProvider = Provider<DosagePlanRepository>((ref) {
  // This should be provided by core/providers if Isar is available
  // For now, we'll create a simple implementation
  throw UnimplementedError(
      'dosagePlanRepositoryProvider must be provided by app initialization');
});

final doseScheduleRepositoryProvider = Provider<DoseScheduleRepository>((ref) {
  // This should be provided by core/providers if Isar is available
  // For now, we'll create a simple implementation
  throw UnimplementedError(
      'doseScheduleRepositoryProvider must be provided by app initialization');
});

final trackingRepositoryProvider = Provider<TrackingRepository>((ref) {
  throw UnimplementedError(
      'trackingRepositoryProvider must be provided by app initialization');
});

final emergencyCheckRepositoryProvider = Provider<EmergencyCheckRepository>((ref) {
  throw UnimplementedError(
      'emergencyCheckRepositoryProvider must be provided by app initialization');
});

final auditRepositoryProvider = Provider((ref) {
  throw UnimplementedError(
      'auditRepositoryProvider must be provided by app initialization');
});

// UseCase Providers
final scheduleGeneratorUseCaseProvider = Provider((ref) {
  return ScheduleGeneratorUseCase();
});

final injectionSiteRotationUseCaseProvider = Provider((ref) {
  return InjectionSiteRotationUseCase();
});

final missedDoseAnalyzerUseCaseProvider = Provider((ref) {
  return MissedDoseAnalyzerUseCase();
});

// UF-009: UpdateDosagePlan UseCase Providers
final validateDosagePlanUseCaseProvider = Provider((ref) {
  return ValidateDosagePlanUseCase();
});

final recalculateDoseScheduleUseCaseProvider = Provider((ref) {
  return RecalculateDoseScheduleUseCase();
});

final analyzePlanChangeImpactUseCaseProvider = Provider((ref) {
  return AnalyzePlanChangeImpactUseCase();
});

final updateDosagePlanUseCaseProvider = Provider((ref) {
  final medicationRepository = ref.watch(medicationRepositoryProvider);
  final validateUseCase = ref.watch(validateDosagePlanUseCaseProvider);
  final analyzeImpactUseCase = ref.watch(analyzePlanChangeImpactUseCaseProvider);
  final recalculateScheduleUseCase =
      ref.watch(recalculateDoseScheduleUseCaseProvider);

  return UpdateDosagePlanUseCase(
    medicationRepository: medicationRepository,
    validateUseCase: validateUseCase,
    analyzeImpactUseCase: analyzeImpactUseCase,
    recalculateScheduleUseCase: recalculateScheduleUseCase,
  );
});

// Service Providers
final notificationServiceProvider = Provider((ref) {
  return NotificationService();
});

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
