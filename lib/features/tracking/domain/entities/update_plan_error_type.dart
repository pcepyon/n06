/// Error type for dosage plan update failures
///
/// This enum represents different types of errors that can occur
/// when updating a dosage plan. Application Layer returns this type,
/// and Presentation Layer converts it to localized messages using l10n.
enum UpdatePlanErrorType {
  /// Generic error during plan update
  updateFailed,

  /// Network or connectivity error
  networkError,

  /// Validation error (invalid plan data)
  validationError,

  /// Permission error (user not authorized)
  permissionError,
}
