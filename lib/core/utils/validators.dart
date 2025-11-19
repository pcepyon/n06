// Email validation function using simple pattern matching
bool _isValidEmailFormat(String email) {
  // Simple email validation
  if (!email.contains('@')) return false;

  final parts = email.split('@');
  if (parts.length != 2) return false;

  final local = parts[0];
  final domain = parts[1];

  if (local.isEmpty || domain.isEmpty) return false;
  if (!domain.contains('.')) return false;

  final domainParts = domain.split('.');
  if (domainParts.any((p) => p.isEmpty)) return false;

  return true;
}

/// Special characters check for password
bool _containsSpecialChar(String password) {
  const specialChars = '!@#%^&*()_+-=[]{}:,.<>?`~';
  return password.split('').any((char) => specialChars.contains(char));
}

/// Maximum email length according to RFC 5321
const int _maxEmailLength = 254;

/// Password strength enumeration
enum PasswordStrength {
  /// Weak: Less than 3 condition criteria met
  weak,

  /// Medium: 3 condition criteria met
  medium,

  /// Strong: 4 or more condition criteria met
  strong,
}

/// Validates email address format
///
/// Checks:
/// - Valid email format (has @, local and domain parts)
/// - Length <= 254 characters
///
/// Returns true if valid, false otherwise
bool isValidEmail(String email) {
  if (email.isEmpty) return false;
  if (email.length > _maxEmailLength) return false;
  return _isValidEmailFormat(email);
}

/// Validates password strength
///
/// Requirements:
/// - Minimum 8 characters
/// - At least one uppercase letter (A-Z)
/// - At least one lowercase letter (a-z)
/// - At least one digit (0-9)
/// - At least one special character (!@#$%^&*, etc.)
///
/// Returns true if all requirements met, false otherwise
bool isValidPassword(String password) {
  if (password.length < 8) return false;

  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasDigit = false;

  for (var char in password.split('')) {
    if (char.compareTo('A') >= 0 && char.compareTo('Z') <= 0) hasUppercase = true;
    if (char.compareTo('a') >= 0 && char.compareTo('z') <= 0) hasLowercase = true;
    if (char.compareTo('0') >= 0 && char.compareTo('9') <= 0) hasDigit = true;
  }

  if (!hasUppercase || !hasLowercase || !hasDigit) return false;
  if (!_containsSpecialChar(password)) return false;

  return true;
}

/// Calculates password strength level
///
/// Scoring:
/// - Length >= 8: +1 point
/// - Length >= 12: +1 point
/// - Contains uppercase: +1 point
/// - Contains lowercase: +1 point
/// - Contains digit: +1 point
/// - Contains special char: +1 point
///
/// Levels:
/// - Weak: < 3 criteria met
/// - Medium: 3 criteria met
/// - Strong: >= 4 criteria met
PasswordStrength getPasswordStrength(String password) {
  if (password.length < 8) return PasswordStrength.weak;

  int score = 0;

  // Length criteria
  if (password.length >= 8) score++;
  if (password.length >= 12) score++;

  // Character type criteria
  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasDigit = false;

  for (var char in password.split('')) {
    if (char.compareTo('A') >= 0 && char.compareTo('Z') <= 0) hasUppercase = true;
    if (char.compareTo('a') >= 0 && char.compareTo('z') <= 0) hasLowercase = true;
    if (char.compareTo('0') >= 0 && char.compareTo('9') <= 0) hasDigit = true;
  }

  if (hasUppercase) score++;
  if (hasLowercase) score++;
  if (hasDigit) score++;
  if (_containsSpecialChar(password)) score++;

  if (score < 3) return PasswordStrength.weak;
  if (score < 4) return PasswordStrength.medium;
  return PasswordStrength.strong;
}

/// Validates user consent to required terms
///
/// Parameters:
/// - [termsOfService]: Required consent (must be true)
/// - [privacyPolicy]: Required consent (must be true)
/// - [marketingEmail]: Optional consent (default false)
///
/// Returns true if both required consents are given
bool isValidConsent({
  required bool termsOfService,
  required bool privacyPolicy,
  bool marketingEmail = false,
}) {
  return termsOfService && privacyPolicy;
}
