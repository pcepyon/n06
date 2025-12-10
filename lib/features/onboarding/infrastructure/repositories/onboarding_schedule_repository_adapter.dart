import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:n06/core/encryption/domain/encryption_service.dart';
import 'package:n06/features/onboarding/domain/repositories/schedule_repository.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';
import 'package:n06/features/tracking/infrastructure/repositories/supabase_dose_schedule_repository.dart';

/// Adapter that bridges onboarding ScheduleRepository interface
/// to tracking's SupabaseDoseScheduleRepository implementation.
///
/// This adapter exists because onboarding defines its own simplified
/// ScheduleRepository interface with `saveAll`, while tracking uses
/// `saveBatchSchedules`. Both do the same thing.
class OnboardingScheduleRepositoryAdapter implements ScheduleRepository {
  final SupabaseDoseScheduleRepository _trackingRepo;

  OnboardingScheduleRepositoryAdapter(SupabaseClient supabase, EncryptionService encryptionService)
      : _trackingRepo = SupabaseDoseScheduleRepository(supabase, encryptionService);

  @override
  Future<void> saveAll(List<DoseSchedule> schedules) {
    // Delegate to tracking repo's saveBatchSchedules
    return _trackingRepo.saveBatchSchedules(schedules);
  }

  @override
  Future<List<DoseSchedule>> getSchedulesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    // Note: This method is not used in onboarding flow,
    // but required by interface. If needed in future,
    // implement filtering logic here.
    throw UnimplementedError(
      'getSchedulesByDateRange not needed for onboarding. '
      'If you need this, add filtering to tracking repo.',
    );
  }
}
