import 'package:n06/features/authentication/domain/repositories/auth_repository.dart';
import 'package:n06/features/authentication/domain/repositories/secure_storage_repository.dart';

/// Logout use case
///
/// Handles the complete logout process:
/// 1. Clears tokens from secure storage (with retry logic)
/// 2. Clears session from auth repository
///
/// The logout process is designed to be resilient:
/// - Token deletion will retry up to 3 times
/// - Session clearing always happens, even if token deletion fails
/// - Network errors are handled gracefully
class LogoutUseCase {
  final SecureStorageRepository _storageRepository;
  final AuthRepository _authRepository;

  static const int _maxRetries = 3;
  static const int _retryDelayMs = 100;

  LogoutUseCase({
    required SecureStorageRepository storageRepository,
    required AuthRepository authRepository,
  })  : _storageRepository = storageRepository,
        _authRepository = authRepository;

  /// Execute logout process
  ///
  /// Returns successfully when:
  /// - Tokens are cleared (with retries)
  /// - Session is cleared
  ///
  /// Throws exception only if critical operations fail
  Future<void> execute() async {
    // Step 1: Clear tokens from secure storage (with retry)
    await _clearTokensWithRetry();

    // Step 2: Clear session (always happens, even if token clearing fails)
    await _authRepository.logout();
  }

  /// Clear tokens with retry logic
  ///
  /// Retries up to 3 times before giving up
  /// After all retries exhausted, continues with session clearing
  /// (per EC3: Even if token deletion fails, session must be cleared)
  Future<void> _clearTokensWithRetry() async {
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        await _storageRepository.clearTokens();
        return; // Success
      } catch (e) {
        if (attempt < _maxRetries) {
          // Wait before retrying
          await Future.delayed(Duration(milliseconds: _retryDelayMs));
        }
        // If last attempt, silently fail and continue to session clearing
      }
    }
  }
}
