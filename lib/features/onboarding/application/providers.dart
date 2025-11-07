import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import 'package:n06/features/onboarding/domain/repositories/user_repository.dart';
import 'package:n06/features/onboarding/domain/repositories/profile_repository.dart';
import 'package:n06/features/onboarding/domain/repositories/medication_repository.dart';
import 'package:n06/features/onboarding/domain/repositories/tracking_repository.dart';
import 'package:n06/features/onboarding/domain/repositories/schedule_repository.dart';
import 'package:n06/features/onboarding/domain/usecases/check_onboarding_status_usecase.dart';
import 'package:n06/features/onboarding/infrastructure/repositories/isar_user_repository.dart';
import 'package:n06/features/onboarding/infrastructure/repositories/isar_profile_repository.dart';
import 'package:n06/features/onboarding/infrastructure/repositories/isar_medication_repository.dart';
import 'package:n06/features/onboarding/infrastructure/repositories/isar_tracking_repository.dart';
import 'package:n06/features/onboarding/infrastructure/repositories/isar_schedule_repository.dart';
import 'package:n06/features/onboarding/infrastructure/services/transaction_service.dart';

part 'providers.g.dart';

/// Isar 인스턴스 Provider (from core)
@riverpod
Isar isar(IsarRef ref) {
  throw UnimplementedError('isarProvider must be implemented in core');
}

/// UserRepository Provider
@riverpod
UserRepository userRepository(UserRepositoryRef ref) {
  final isarInstance = ref.watch(isarProvider);
  return IsarUserRepository(isarInstance);
}

/// ProfileRepository Provider
@riverpod
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  final isarInstance = ref.watch(isarProvider);
  return IsarProfileRepository(isarInstance);
}

/// MedicationRepository Provider
@riverpod
MedicationRepository medicationRepository(MedicationRepositoryRef ref) {
  final isarInstance = ref.watch(isarProvider);
  return IsarMedicationRepository(isarInstance);
}

/// TrackingRepository Provider
@riverpod
TrackingRepository trackingRepository(TrackingRepositoryRef ref) {
  final isarInstance = ref.watch(isarProvider);
  return IsarTrackingRepository(isarInstance);
}

/// ScheduleRepository Provider
@riverpod
ScheduleRepository scheduleRepository(ScheduleRepositoryRef ref) {
  final isarInstance = ref.watch(isarProvider);
  return IsarScheduleRepository(isarInstance);
}

/// TransactionService Provider
@riverpod
TransactionService transactionService(TransactionServiceRef ref) {
  final isarInstance = ref.watch(isarProvider);
  return TransactionService(isarInstance);
}

/// CheckOnboardingStatusUseCase Provider
@riverpod
CheckOnboardingStatusUseCase checkOnboardingStatusUseCase(
  CheckOnboardingStatusUseCaseRef ref,
) {
  final profileRepo = ref.watch(profileRepositoryProvider);
  return CheckOnboardingStatusUseCase(profileRepo);
}
