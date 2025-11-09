/// Exception thrown when OAuth authentication is cancelled by the user
class OAuthCancelledException implements Exception {
  final String message;

  OAuthCancelledException(this.message);

  @override
  String toString() => 'OAuthCancelledException: $message';
}

/// Exception thrown when maximum retry attempts are exceeded
class MaxRetriesExceededException implements Exception {
  final String message;

  MaxRetriesExceededException(this.message);

  @override
  String toString() => 'MaxRetriesExceededException: $message';
}
