import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/tracking/application/notifiers/medication_notifier.dart';
import 'package:n06/features/tracking/application/notifiers/tracking_notifier.dart';
import 'package:n06/features/tracking/domain/repositories/medication_repository.dart';
import 'package:n06/features/tracking/domain/repositories/tracking_repository.dart';
import 'package:n06/features/tracking/domain/usecases/injection_site_rotation_usecase.dart';
import 'package:n06/features/tracking/domain/usecases/missed_dose_analyzer_usecase.dart';
import 'package:n06/features/tracking/domain/usecases/schedule_generator_usecase.dart';
import 'package:n06/features/tracking/infrastructure/services/notification_service.dart';

// Repository Provider
final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  // This should be provided by core/providers if Isar is available
  // For now, we'll create a simple implementation
  throw UnimplementedError(
      'medicationRepositoryProvider must be provided by app initialization');
});

final trackingRepositoryProvider = Provider<TrackingRepository>((ref) {
  throw UnimplementedError(
      'trackingRepositoryProvider must be provided by app initialization');
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
