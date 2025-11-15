import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:n06/core/providers.dart';
import 'package:n06/features/onboarding/domain/repositories/user_repository.dart';
import 'package:n06/features/onboarding/domain/repositories/profile_repository.dart';
import 'package:n06/features/onboarding/domain/repositories/medication_repository.dart';
import 'package:n06/features/onboarding/domain/repositories/schedule_repository.dart';
import 'package:n06/features/onboarding/domain/usecases/check_onboarding_status_usecase.dart';
import 'package:n06/features/onboarding/infrastructure/repositories/supabase_user_repository.dart';
import 'package:n06/features/onboarding/infrastructure/repositories/supabase_profile_repository.dart';
// import 'package:n06/features/onboarding/infrastructure/repositories/isar_user_repository.dart';  // Phase 1.8에서 제거
// import 'package:n06/features/onboarding/infrastructure/repositories/isar_profile_repository.dart';  // Phase 1.8에서 제거
import 'package:n06/features/onboarding/infrastructure/repositories/isar_medication_repository.dart';
import 'package:n06/features/onboarding/infrastructure/repositories/isar_schedule_repository.dart';
import 'package:n06/features/onboarding/infrastructure/services/transaction_service.dart';

part 'providers.g.dart';

/// UserRepository Provider
@riverpod
UserRepository userRepository(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseUserRepository(supabase);
}

/// ProfileRepository Provider
@riverpod
ProfileRepository profileRepository(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseProfileRepository(supabase);
}

/// MedicationRepository Provider
@riverpod
MedicationRepository medicationRepository(MedicationRepositoryRef ref) {
  final isarInstance = ref.watch(isarProvider);
  return IsarMedicationRepository(isarInstance);
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
