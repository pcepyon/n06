import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';

/// Repository interface for DoseSchedule persistence
///
/// Defines the contract for dose schedule data access operations.
/// Implementations must handle Isar or Supabase storage.
abstract class DoseScheduleRepository {
  /// Get all schedules for a specific dosage plan
  ///
  /// Returns a list of schedules for the given [dosagePlanId],
  /// typically ordered by scheduled date.
  Future<List<DoseSchedule>> getSchedulesByPlanId(String dosagePlanId);

  /// Save multiple schedules in a batch operation
  ///
  /// Efficiently inserts multiple schedules at once.
  /// Useful after dosage plan changes require recalculation.
  Future<void> saveBatchSchedules(List<DoseSchedule> schedules);

  /// Delete all schedules after a specific date for a plan
  ///
  /// Removes future schedules from [fromDate] onwards for [dosagePlanId].
  /// Used during plan updates to clear outdated schedules.
  /// Past schedules are preserved to maintain historical accuracy.
  Future<void> deleteFutureSchedules(
    String dosagePlanId,
    DateTime fromDate,
  );

  /// Watch schedules for real-time updates
  ///
  /// Returns a stream that emits updates whenever schedules change
  /// for the given [dosagePlanId].
  /// Useful for keeping schedule views in sync.
  Stream<List<DoseSchedule>> watchSchedulesByPlanId(String dosagePlanId);
}
