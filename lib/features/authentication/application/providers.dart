import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/authentication/domain/repositories/secure_storage_repository.dart';
import 'package:n06/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:n06/features/authentication/infrastructure/repositories/flutter_secure_storage_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';

part 'providers.g.dart';

/// Provider for SecureStorageRepository
@riverpod
SecureStorageRepository secureStorageRepository(Ref ref) {
  final secureStorage = const FlutterSecureStorage();
  return FlutterSecureStorageRepository(secureStorage);
}

/// Provider for LogoutUseCase
@riverpod
LogoutUseCase logoutUseCase(Ref ref) {
  final storageRepository = ref.watch(secureStorageRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(
    storageRepository: storageRepository,
    authRepository: authRepository,
  );
}
