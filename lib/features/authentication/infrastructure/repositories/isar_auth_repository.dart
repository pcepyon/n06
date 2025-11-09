import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:n06/core/services/secure_storage_service.dart';
import 'package:n06/features/authentication/domain/entities/user.dart';
import 'package:n06/features/authentication/domain/exceptions/auth_exceptions.dart';
import 'package:n06/features/authentication/domain/repositories/auth_repository.dart';
import 'package:n06/features/authentication/infrastructure/datasources/kakao_auth_datasource.dart';
import 'package:n06/features/authentication/infrastructure/datasources/naver_auth_datasource.dart';
import 'package:n06/features/authentication/infrastructure/dtos/consent_record_dto.dart';
import 'package:n06/features/authentication/infrastructure/dtos/user_dto.dart';
import 'package:n06/features/onboarding/infrastructure/dtos/user_profile_dto.dart';

/// Isar implementation of AuthRepository.
///
/// Integrates KakaoAuthDataSource, NaverAuthDataSource, and SecureStorageService
/// to provide complete authentication functionality with:
/// - OAuth 2.0 login flow
/// - Token management
/// - User persistence
/// - Consent record tracking
/// - Automatic retry logic (up to 3 times, except for user cancellation)
class IsarAuthRepository implements AuthRepository {
  final Isar _isar;
  final KakaoAuthDataSource _kakaoDataSource;
  final NaverAuthDataSource _naverDataSource;
  final SecureStorageService _secureStorage;

  static const int _maxRetries = 3;
  static const int _retryDelayMs = 100;

  IsarAuthRepository(
    this._isar,
    this._kakaoDataSource,
    this._naverDataSource,
    this._secureStorage,
  );

  @override
  Future<User> loginWithKakao({
    required bool agreedToTerms,
    required bool agreedToPrivacy,
  }) async {
    if (kDebugMode) {
      developer.log(
        '📱 loginWithKakao called in repository',
        name: 'IsarAuthRepository',
      );
    }

    return await _retryOnNetworkError(() async {
      if (kDebugMode) {
        developer.log('1️⃣ Starting Kakao datasource login...', name: 'IsarAuthRepository');
      }

      // 1. DataSource에서 로그인
      final token = await _kakaoDataSource.login();

      if (kDebugMode) {
        developer.log(
          '✅ Token received (expires: ${token.expiresAt})',
          name: 'IsarAuthRepository',
        );
      }

      // 2. 토큰 저장
      if (kDebugMode) {
        developer.log('2️⃣ Saving tokens to secure storage...', name: 'IsarAuthRepository');
      }

      await _secureStorage.saveAccessToken(token.accessToken, token.expiresAt);
      await _secureStorage.saveRefreshToken(token.refreshToken!);

      // 3. 사용자 정보 가져오기
      if (kDebugMode) {
        developer.log('3️⃣ Fetching user info...', name: 'IsarAuthRepository');
      }

      final kakaoUser = await _kakaoDataSource.getUser();

      if (kDebugMode) {
        developer.log(
          '✅ User info received (id: ${kakaoUser.id})',
          name: 'IsarAuthRepository',
        );
      }

      // 4. Domain Entity로 변환
      final user = User(
        id: kakaoUser.id.toString(),
        oauthProvider: 'kakao',
        oauthUserId: kakaoUser.id.toString(),
        name: kakaoUser.kakaoAccount?.profile?.nickname ?? '',
        email: kakaoUser.kakaoAccount?.email ?? '',
        profileImageUrl: kakaoUser.kakaoAccount?.profile?.profileImageUrl,
        lastLoginAt: DateTime.now(),
      );

      // 5. Isar에 저장
      if (kDebugMode) {
        developer.log('4️⃣ Saving user to Isar...', name: 'IsarAuthRepository');
      }

      await _saveUserToIsar(user);
      await _saveConsentToIsar(user.id, agreedToTerms, agreedToPrivacy);

      if (kDebugMode) {
        developer.log(
          '✅ Login completed successfully (user: ${user.id})',
          name: 'IsarAuthRepository',
        );
      }

      return user;
    });
  }

  @override
  Future<User> loginWithNaver({
    required bool agreedToTerms,
    required bool agreedToPrivacy,
  }) async {
    return await _retryOnNetworkError(() async {
      // 1. DataSource에서 로그인
      final result = await _naverDataSource.login();

      // 2. 토큰 가져오기
      final token = await _naverDataSource.getCurrentToken();

      // 3. 토큰 저장
      // NaverAccessToken.expiresAt is String, need to parse it
      DateTime expiresAt;
      try {
        expiresAt = DateTime.parse(token.expiresAt);
      } catch (e) {
        // If parsing fails, set expiry to 2 hours from now as fallback
        expiresAt = DateTime.now().add(const Duration(hours: 2));
      }
      await _secureStorage.saveAccessToken(token.accessToken, expiresAt);
      await _secureStorage.saveRefreshToken(token.refreshToken);

      // 4. 사용자 정보 가져오기 (result.account 사용)
      final account = result.account;
      if (account == null) {
        throw Exception('Failed to get Naver account information');
      }

      // 5. Domain Entity로 변환
      final user = User(
        id: account.id ?? '',
        oauthProvider: 'naver',
        oauthUserId: account.id ?? '',
        name: account.name ?? '',
        email: account.email ?? '',
        profileImageUrl: account.profileImage,
        lastLoginAt: DateTime.now(),
      );

      // 6. Isar에 저장
      await _saveUserToIsar(user);
      await _saveConsentToIsar(user.id, agreedToTerms, agreedToPrivacy);

      return user;
    });
  }

  @override
  Future<void> logout() async {
    try {
      // 현재 사용자 확인 후 적절한 DataSource 호출
      final user = await getCurrentUser();
      if (user?.oauthProvider == 'kakao') {
        await _kakaoDataSource.logout();
      } else if (user?.oauthProvider == 'naver') {
        await _naverDataSource.logout();
      }
    } catch (error) {
      // 네트워크 오류 무시
      if (kDebugMode) {
        developer.log(
          'Logout network error ignored (local cleanup will still proceed)',
          name: 'IsarAuthRepository',
          error: error,
          level: 900,
        );
      }
    } finally {
      // 로컬 토큰은 반드시 삭제
      await _secureStorage.deleteAllTokens();
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    final userDto = await _isar.userDtos.where().findFirst();
    return userDto?.toEntity();
  }

  @override
  Future<bool> isFirstLogin() async {
    // UserProfile이 있는지 확인 (온보딩 완료 여부)
    final user = await getCurrentUser();
    if (user == null) return true;

    // UserProfileDto 확인
    final profileCount = await _isar.userProfileDtos
        .filter()
        .userIdEqualTo(user.id)
        .count();

    return profileCount == 0;
  }

  @override
  Future<bool> isAccessTokenValid() async {
    return !(await _secureStorage.isAccessTokenExpired());
  }

  @override
  Future<String> refreshAccessToken(String refreshToken) async {
    // Phase 0에서는 토큰 갱신 미구현
    // Phase 1에서 Supabase와 함께 구현 예정
    throw UnimplementedError('Token refresh will be implemented in Phase 1');
  }

  /// 사용자를 Isar에 저장 (기존 사용자면 업데이트)
  Future<void> _saveUserToIsar(User user) async {
    await _isar.writeTxn(() async {
      // 기존 사용자 확인 (oauthProvider + oauthUserId로 검색)
      final existing = await _isar.userDtos
          .filter()
          .oauthProviderEqualTo(user.oauthProvider)
          .and()
          .oauthUserIdEqualTo(user.oauthUserId)
          .findFirst();

      if (existing != null) {
        // 기존 사용자 업데이트
        existing.name = user.name;
        existing.email = user.email;
        existing.profileImageUrl = user.profileImageUrl;
        existing.lastLoginAt = user.lastLoginAt;
        await _isar.userDtos.put(existing);
      } else {
        // 신규 사용자 생성
        final dto = UserDto.fromEntity(user);
        await _isar.userDtos.put(dto);
      }
    });
  }

  /// 동의 정보를 Isar에 저장
  Future<void> _saveConsentToIsar(
    String userId,
    bool agreedToTerms,
    bool agreedToPrivacy,
  ) async {
    await _isar.writeTxn(() async {
      final consent = ConsentRecordDto()
        ..userId = userId
        ..termsOfService = agreedToTerms
        ..privacyPolicy = agreedToPrivacy
        ..agreedAt = DateTime.now();

      await _isar.consentRecordDtos.put(consent);
    });
  }

  /// 재시도 로직 헬퍼 메서드
  ///
  /// [operation] 실행할 비동기 작업
  /// [shouldRetry] 에러 발생 시 재시도 여부를 판단하는 함수 (null이면 항상 재시도)
  /// [maxRetries] 최대 재시도 횟수 (기본값: 3)
  ///
  /// 재시도 시 exponential backoff 적용
  Future<T> _retryOnNetworkError<T>(
    Future<T> Function() operation, {
    bool Function(dynamic)? shouldRetry,
    int maxRetries = _maxRetries,
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        return await operation();
      } catch (error, stackTrace) {
        if (kDebugMode) {
          developer.log(
            'Retry attempt ${i + 1}/$maxRetries failed',
            name: 'IsarAuthRepository',
            error: error,
            stackTrace: stackTrace,
            level: 900,
          );
        }

        // PlatformException CANCELED는 즉시 전파
        if (error is PlatformException && error.code == 'CANCELED') {
          if (kDebugMode) {
            developer.log(
              '🚫 User cancelled - not retrying',
              name: 'IsarAuthRepository',
              error: error,
              level: 1000,
            );
          }
          throw OAuthCancelledException('User cancelled OAuth login');
        }

        // MissingPluginException은 플랫폼 설정 문제 - 재시도 불가
        if (error.toString().contains('MissingPluginException')) {
          if (kDebugMode) {
            developer.log(
              '❌ CRITICAL: Kakao SDK not configured for macOS',
              name: 'IsarAuthRepository',
              error: error,
              stackTrace: stackTrace,
              level: 1000,
            );
            developer.log(
              'Please check: https://github.com/kakao/kakao_flutter_sdk',
              name: 'IsarAuthRepository',
              level: 1000,
            );
          }
          rethrow;
        }

        // shouldRetry가 false를 반환하면 즉시 전파
        if (shouldRetry != null && !shouldRetry(error)) {
          if (kDebugMode) {
            developer.log(
              '⛔ Retry not allowed for this error type',
              name: 'IsarAuthRepository',
              error: error,
              level: 1000,
            );
          }
          rethrow;
        }

        // 마지막 재시도에서 실패하면 예외 발생
        if (i == maxRetries - 1) {
          if (kDebugMode) {
            developer.log(
              '❌ Max retries exceeded',
              name: 'IsarAuthRepository',
              error: error,
              stackTrace: stackTrace,
              level: 1000,
            );
          }
          throw MaxRetriesExceededException('Max retries exceeded: $error');
        }

        // Exponential backoff
        if (kDebugMode) {
          developer.log(
            '🔄 Retrying in ${_retryDelayMs * (i + 1)}ms...',
            name: 'IsarAuthRepository',
            level: 900,
          );
        }
        await Future.delayed(Duration(milliseconds: _retryDelayMs * (i + 1)));
      }
    }

    throw MaxRetriesExceededException('Max retries exceeded');
  }
}
