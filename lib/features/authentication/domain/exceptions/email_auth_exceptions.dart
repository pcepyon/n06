// Exception thrown when email already exists
class EmailAlreadyExists implements Exception {
  final String email;
  final String message;

  EmailAlreadyExists(this.email)
      : message = 'Email $email is already registered';

  @override
  String toString() => message;
}

/// Exception thrown when password is invalid
class InvalidPassword implements Exception {
  final String reason;
  final String message;

  InvalidPassword(this.reason)
      : message = 'Invalid password: $reason';

  @override
  String toString() => message;
}

/// Exception thrown when email format is invalid
class InvalidEmail implements Exception {
  final String email;
  final String message;

  InvalidEmail(this.email)
      : message = 'Invalid email format: $email';

  @override
  String toString() => message;
}

/// Exception thrown when password reset token is expired
class PasswordResetTokenExpired implements Exception {
  final String message = 'Password reset link has expired. Please request a new one.';

  @override
  String toString() => message;
}

/// Exception thrown when required consents are not provided
class ConsentNotProvided implements Exception {
  final List<String> missingConsents;
  late final String message;

  ConsentNotProvided(this.missingConsents) {
    message = 'Required consent(s) missing: ${missingConsents.join(", ")}';
  }

  @override
  String toString() => message;
}

/// Exception thrown when account is locked due to multiple failed attempts
class AccountLocked implements Exception {
  final DateTime unlockedAt;
  late final String message;

  AccountLocked(this.unlockedAt) {
    final minutesRemaining = unlockedAt.difference(DateTime.now()).inMinutes;
    message = 'Account is temporarily locked. Try again in $minutesRemaining minutes.';
  }

  @override
  String toString() => message;
}

/// Exception thrown when user not found
class UserNotFound implements Exception {
  final String email;
  final String message;

  UserNotFound(this.email)
      : message = 'User with email $email not found';

  @override
  String toString() => message;
}

/// Exception thrown when credentials are invalid
class InvalidCredentials implements Exception {
  final String message = 'Invalid email or password';

  @override
  String toString() => message;
}
