import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';
import 'package:n06/features/tracking/domain/entities/plan_change_history.dart';

/// Repository interface for DosagePlan persistence
///
/// Defines the contract for dosage plan data access operations.
/// Implementations must handle Isar or Supabase storage.
abstract class DosagePlanRepository {
  /// Get the active dosage plan for a specific user
  ///
  /// Returns the first plan where [isActive] is true for the given [userId].
  /// Returns null if no active plan exists.
  Future<DosagePlan?> getActiveDosagePlan(String userId);

  /// Get a specific dosage plan by ID
  ///
  /// Returns the plan with the given [planId], or null if not found.
  Future<DosagePlan?> getDosagePlan(String planId);

  /// Save a new dosage plan
  ///
  /// Inserts a new plan into storage.
  /// The plan should not exist yet (use update for existing plans).
  Future<void> saveDosagePlan(DosagePlan plan);

  /// Update an existing dosage plan
  ///
  /// Updates all fields of the plan with the given ID.
  /// The plan must already exist in storage.
  Future<void> updateDosagePlan(DosagePlan plan);

  /// Get change history for a specific plan
  ///
  /// Returns all historical changes for the given [planId],
  /// ordered by most recent first.
  Future<List<PlanChangeHistory>> getPlanChangeHistory(String planId);

  /// Save a plan change history record
  ///
  /// Records a change to the plan for audit trail purposes.
  /// Typically called together with [updateDosagePlan] in a transaction.
  Future<void> savePlanChangeHistory(PlanChangeHistory history);

  /// Update plan and save history in a single transaction
  ///
  /// Ensures atomicity: both operations succeed or both are rolled back.
  /// This is critical for data integrity when plan changes are recorded.
  Future<void> updatePlanWithHistory(
    DosagePlan plan,
    PlanChangeHistory history,
  );

  /// Watch active dosage plan for real-time updates
  ///
  /// Returns a stream that emits updates whenever the active plan changes.
  /// Useful for keeping UI in sync with database changes.
  Stream<DosagePlan?> watchActiveDosagePlan(String userId);
}
