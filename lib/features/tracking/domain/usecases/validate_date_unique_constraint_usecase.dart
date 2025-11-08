import 'package:n06/features/tracking/domain/entities/validation_result.dart';
import 'package:n06/features/tracking/domain/repositories/tracking_repository.dart';

class ValidateDateUniqueConstraintUseCase {
  final TrackingRepository repository;

  ValidateDateUniqueConstraintUseCase(this.repository);

  Future<ValidationResult> execute({
    required String userId,
    required DateTime date,
    String? editingRecordId,
  }) async {
    // Check if date is in the future
    if (date.isAfter(DateTime.now())) {
      return ValidationResult.error('미래 날짜는 선택할 수 없습니다');
    }

    // Normalize date to remove time component
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final normalizedNow = DateTime.now();
    final normalizedToday = DateTime(normalizedNow.year, normalizedNow.month, normalizedNow.day);

    if (normalizedDate.isAfter(normalizedToday)) {
      return ValidationResult.error('미래 날짜는 선택할 수 없습니다');
    }

    // Check for existing weight log on this date
    final existing = await repository.getWeightLog(userId, normalizedDate);

    if (existing != null) {
      // If editing the same record, allow it
      if (editingRecordId != null && existing.id == editingRecordId) {
        return ValidationResult.success();
      }

      // Otherwise, it's a conflict
      return ValidationResult.conflict(existingRecordId: existing.id);
    }

    return ValidationResult.success();
  }
}
