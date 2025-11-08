import 'package:equatable/equatable.dart';

class ValidationResult extends Equatable {
  final bool isSuccess;
  final bool isFailure;
  final bool isConflict;
  final String? error;
  final String? warning;
  final String? existingRecordId;

  const ValidationResult({
    required this.isSuccess,
    this.isFailure = false,
    this.isConflict = false,
    this.error,
    this.warning,
    this.existingRecordId,
  });

  factory ValidationResult.success({String? warning}) {
    return ValidationResult(
      isSuccess: true,
      warning: warning,
    );
  }

  factory ValidationResult.error(String message) {
    return ValidationResult(
      isSuccess: false,
      isFailure: true,
      error: message,
    );
  }

  factory ValidationResult.conflict({required String existingRecordId}) {
    return ValidationResult(
      isSuccess: false,
      isConflict: true,
      existingRecordId: existingRecordId,
    );
  }

  @override
  List<Object?> get props => [isSuccess, isFailure, isConflict, error, warning, existingRecordId];
}
