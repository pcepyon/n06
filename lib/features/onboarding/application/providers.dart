import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:n06/core/providers.dart';
import 'package:n06/core/encryption/application/providers.dart';
import 'package:n06/features/onboarding/domain/repositories/user_repository.dart';
import 'package:n06/features/onboarding/domain/repositories/profile_repository.dart';
import 'package:n06/features/onboarding/domain/repositories/medication_repository.dart';
import 'package:n06/features/onboarding/domain/repositories/schedule_repository.dart';
import 'package:n06/features/onboarding/domain/usecases/check_onboarding_status_usecase.dart';
import 'package:n06/features/onboarding/infrastructure/repositories/supabase_user_repository.dart';
import 'package:n06/features/onboarding/infrastructure/repositories/supabase_profile_repository.dart';
import 'package:n06/features/onboarding/infrastructure/repositories/onboarding_medication_repository_adapter.dart';
import 'package:n06/features/onboarding/infrastructure/repositories/onboarding_schedule_repository_adapter.dart';

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
  final encryptionService = ref.watch(encryptionServiceProvider);
  return SupabaseProfileRepository(supabase, encryptionService);
}

/// MedicationRepository Provider (uses tracking's Supabase repository)
@riverpod
MedicationRepository medicationRepository(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  final encryptionService = ref.watch(encryptionServiceProvider);
  return OnboardingMedicationRepositoryAdapter(supabase, encryptionService);
}

/// ScheduleRepository Provider (uses tracking's Supabase repository)
@riverpod
ScheduleRepository scheduleRepository(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  return OnboardingScheduleRepositoryAdapter(supabase);
}

/// CheckOnboardingStatusUseCase Provider
@riverpod
CheckOnboardingStatusUseCase checkOnboardingStatusUseCase(Ref ref) {
  final profileRepo = ref.watch(profileRepositoryProvider);
  return CheckOnboardingStatusUseCase(profileRepo);
}
