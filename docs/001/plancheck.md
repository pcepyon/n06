# UF-F-001: 소셜 로그인 및 인증 Plan 검토 결과

## 검토 일자
2025-11-07

## 검토 개요
spec.md의 요구사항과 plan.md의 구현 계획을 비교하여 누락되거나 불일치하는 부분을 식별

---

## 🔴 Critical Issues (즉시 수정 필요)

### 1. 최초 로그인 여부 판단 로직 누락

**Spec 요구사항**:
- Main Scenario #13: "앱이 최초 로그인임을 확인하고 온보딩 화면으로 전환"
- Main Scenario 재방문 플로우: "홈 대시보드 화면으로 직접 이동"

**Plan 현황**:
- LoginScreen 테스트에 "should navigate to onboarding on first login" 있음
- 그러나 **판단 기준이 명시되지 않음**

**수정 방안**:
```dart
// Domain Layer에 추가
abstract class AuthRepository {
  Future<bool> isFirstLogin(); // 추가 필요
}

// IsarAuthRepository 구현
Future<bool> isFirstLogin() async {
  final user = await getCurrentUser();
  if (user == null) return true;

  // 사용자 테이블에 lastLoginAt 필드 확인
  final userDto = await isar.userDtos.get(user.id);
  return userDto?.lastLoginAt == null;
}

// AuthNotifier에 추가
Future<void> loginWithKakao() async {
  final user = await _repository.loginWithKakao();
  final isFirst = await _repository.isFirstLogin();

  state = AsyncData(user);

  // Navigation은 Presentation에서 처리
  if (isFirst) {
    // 온보딩으로 이동 신호
  } else {
    // 홈 대시보드로 이동 신호
  }
}
```

**추가 필요 테스트**:
```dart
// AuthRepository Test
test('should return true for first login', () async {});
test('should return false for returning user', () async {});

// AuthNotifier Test
test('should set isFirstLogin flag on successful login', () async {});
```

---

### 2. 동의 정보 저장 시점 및 통합 로직 불명확

**Spec 요구사항**:
- Main Scenario #5: "사용자가 이용약관 및 개인정보처리방침 동의 체크박스 선택"
- Main Scenario #12: "앱이 동의 정보를 내부 DB에 기록"
- BR3: "이용약관 및 개인정보처리방침 동의 여부 및 일시를 내부 DB에 영구 기록"

**Plan 현황**:
- ConsentRecord Entity 정의됨
- `saveConsentRecord` 메서드 있음
- 그러나 **로그인 플로우에서 호출 시점이 명시되지 않음**

**수정 방안**:
```dart
// AuthNotifier에 통합
Future<void> loginWithKakao({
  required bool agreedToTerms,
  required bool agreedToPrivacy,
}) async {
  state = const AsyncLoading();

  try {
    final user = await _repository.loginWithKakao();

    // 동의 정보 저장 (로그인 직후)
    final consent = ConsentRecord(
      id: uuid.v4(),
      userId: user.id,
      termsOfService: agreedToTerms,
      privacyPolicy: agreedToPrivacy,
      agreedAt: DateTime.now(),
    );
    await _repository.saveConsentRecord(consent);

    state = AsyncData(user);
  } catch (e) {
    state = AsyncError(e, StackTrace.current);
  }
}
```

**추가 필요 테스트**:
```dart
// AuthNotifier Test
test('should save consent record after successful login', () async {
  // Arrange
  when(mockRepo.loginWithKakao()).thenAnswer((_) async => mockUser);

  // Act
  await notifier.loginWithKakao(
    agreedToTerms: true,
    agreedToPrivacy: true,
  );

  // Assert
  verify(mockRepo.saveConsentRecord(any)).called(1);
});

test('should not proceed login if consent not agreed', () async {});
```

---

### 3. 네이버 OAuth 테스트 시나리오 부족

**Spec 요구사항**:
- BR1: "네이버 OAuth 2.0과 카카오 OAuth 2.0만 지원"
- Main Scenario: 카카오와 네이버 동등하게 지원

**Plan 현황**:
- 대부분의 테스트 케이스가 카카오 중심
- 네이버 관련 테스트는 "should authenticate with Naver and return tokens" 정도

**수정 방안**:
```dart
// OAuthService - 네이버 전용 테스트 추가
test('should authenticate with Naver and return tokens', () async {
  final service = OAuthService();
  final result = await service.authenticateWithNaver();

  expect(result.accessToken, isNotEmpty);
  expect(result.refreshToken, isNotEmpty);
  expect(result.userInfo['name'], isNotEmpty);
});

test('should handle Naver-specific OAuth errors', () async {});
test('should refresh Naver access token', () async {});

// IsarAuthRepository - 네이버 통합 테스트
testWidgets('should login with Naver and save user to Isar', () async {
  final isar = await openTestIsar();
  final oauthService = MockOAuthService();
  final secureStorage = MockSecureStorageService();
  final repo = IsarAuthRepository(isar, oauthService, secureStorage);

  when(oauthService.authenticateWithNaver()).thenAnswer((_) async => mockNaverResult);

  final user = await repo.loginWithNaver();

  expect(user.oauthProvider, 'naver');
  verify(secureStorage.saveAccessToken(any)).called(1);
});

// AuthNotifier - 네이버 상태 관리 테스트
test('should login with Naver and update state', () async {
  when(mockRepo.loginWithNaver()).thenAnswer((_) async => mockNaverUser);

  await notifier.loginWithNaver();

  final state = container.read(authNotifierProvider);
  expect(state.value?.oauthProvider, 'naver');
});

// LoginScreen - 네이버 UI 테스트
testWidgets('should call loginWithNaver when button pressed', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith(() => mockNotifier),
      ],
      child: MaterialApp(home: LoginScreen()),
    ),
  );

  await tester.tap(find.byKey(Key('naver_login_button')));
  await tester.pump();

  verify(mockNotifier.loginWithNaver()).called(1);
});
```

---

## 🟡 Medium Priority Issues (수정 권장)

### 4. 토큰 만료 시간 저장 및 검증 로직 누락

**Spec 요구사항**:
- 토큰 갱신 플로우 #2: "앱이 Access Token 만료 감지"
- E2: "API 요청 시 Access Token 만료 응답 수신"

**Plan 현황**:
- SecureStorageService 테스트에 "should save token expiry time" 있음
- 그러나 **구현 세부사항 및 만료 감지 로직 없음**

**수정 방안**:
```dart
// SecureStorageService 확장
class SecureStorageService {
  Future<void> saveAccessToken(String token, DateTime expiresAt) async {
    await _storage.write(key: 'access_token', value: token);
    await _storage.write(key: 'access_token_expiry', value: expiresAt.toIso8601String());
  }

  Future<bool> isAccessTokenExpired() async {
    final expiryStr = await _storage.read(key: 'access_token_expiry');
    if (expiryStr == null) return true;

    final expiry = DateTime.parse(expiryStr);
    return DateTime.now().isAfter(expiry);
  }

  Future<String?> getAccessTokenIfValid() async {
    if (await isAccessTokenExpired()) {
      return null;
    }
    return await getAccessToken();
  }
}

// AuthRepository에 추가
abstract class AuthRepository {
  Future<bool> isAccessTokenValid();
  Future<String> refreshAccessToken(String refreshToken);
}

// AuthNotifier에 자동 갱신 로직
Future<void> ensureValidToken() async {
  if (!await _repository.isAccessTokenValid()) {
    // 자동 갱신 시도
    try {
      await _repository.refreshAccessToken();
    } catch (e) {
      // 갱신 실패 시 재로그인 유도
      await logout();
      throw TokenExpiredException();
    }
  }
}
```

**추가 필요 테스트**:
```dart
// SecureStorageService Test
test('should detect expired access token', () async {
  final service = SecureStorageService();
  await service.saveAccessToken('token123', DateTime.now().subtract(Duration(hours: 1)));

  expect(await service.isAccessTokenExpired(), true);
});

test('should return null for expired token', () async {});
test('should return token if still valid', () async {});

// AuthNotifier Test
test('should refresh token automatically before expiry', () async {});
test('should logout if refresh token is also expired', () async {});
```

---

### 5. 재시도 로직 책임 분리 불명확

**Spec 요구사항**:
- E4: "네트워크 연결 오류 시 최대 3회 재시도"
- BR6: "OAuth 인증 요청 실패 시 최대 3회 자동 재시도"

**Plan 현황**:
- OAuthService에 재시도 로직 언급
- IsarAuthRepository에도 재시도 테스트 있음
- **책임이 중복되거나 불명확**

**수정 방안**:
```dart
// OAuthService: 단순히 OAuth 통신만 수행 (재시도 없음)
class OAuthService {
  Future<OAuthResult> authenticateWithKakao() async {
    // SDK 호출만 수행, 재시도는 상위 레이어에서 처리
  }
}

// IsarAuthRepository: 재시도 로직 구현
class IsarAuthRepository implements AuthRepository {
  static const int _maxRetries = 3;

  Future<User> loginWithKakao() async {
    int attempts = 0;

    while (attempts < _maxRetries) {
      try {
        final result = await _oauthService.authenticateWithKakao();
        // 토큰 저장 및 사용자 저장
        return _saveUserAndReturnEntity(result);
      } on NetworkException catch (e) {
        attempts++;
        if (attempts >= _maxRetries) {
          throw MaxRetriesExceededException('로그인 시도 실패: 네트워크 연결을 확인해주세요', e);
        }
        await Future.delayed(Duration(seconds: attempts)); // Exponential backoff
      }
    }

    throw UnexpectedErrorException('로그인 처리 중 오류 발생');
  }
}
```

**추가 필요 테스트**:
```dart
// IsarAuthRepository Test
testWidgets('should retry exactly 3 times on network error', () async {
  final mockOAuthService = MockOAuthService();
  when(mockOAuthService.authenticateWithKakao())
      .thenThrow(NetworkException('Connection failed'));

  final repo = IsarAuthRepository(isar, mockOAuthService, secureStorage);

  expect(
    () => repo.loginWithKakao(),
    throwsA(isA<MaxRetriesExceededException>()),
  );

  verify(mockOAuthService.authenticateWithKakao()).called(3);
});

testWidgets('should succeed on second retry', () async {
  final mockOAuthService = MockOAuthService();
  when(mockOAuthService.authenticateWithKakao())
      .thenThrow(NetworkException('Connection failed'))
      .thenAnswer((_) async => mockOAuthResult);

  final user = await repo.loginWithKakao();

  expect(user, isNotNull);
  verify(mockOAuthService.authenticateWithKakao()).called(2);
});
```

---

### 6. 로그아웃 Edge Case 처리 누락

**Spec 요구사항**:
- E8: "로그아웃 요청 중 네트워크 오류 시 로컬 토큰 삭제 후 로그인 화면 이동"

**Plan 현황**:
- logout 메서드 있음
- 네트워크 오류 시나리오 없음

**수정 방안**:
```dart
// IsarAuthRepository
Future<void> logout() async {
  try {
    // 원격 로그아웃 시도 (Optional)
    await _oauthService.revokeToken();
  } catch (e) {
    // 네트워크 오류 무시하고 로컬 로그아웃 진행
    print('Remote logout failed, proceeding with local logout: $e');
  } finally {
    // 로컬 토큰 삭제는 반드시 수행
    await _secureStorage.deleteAllTokens();

    // Isar에서 사용자 정보는 유지 (재로그인 시 이력 확인용)
    // 필요시 사용자 정보도 삭제 가능
  }
}
```

**추가 필요 테스트**:
```dart
// IsarAuthRepository Test
testWidgets('should delete local tokens even if remote logout fails', () async {
  final mockOAuthService = MockOAuthService();
  when(mockOAuthService.revokeToken()).thenThrow(NetworkException('Timeout'));

  final repo = IsarAuthRepository(isar, mockOAuthService, secureStorage);

  await repo.logout(); // 예외 발생하지 않아야 함

  verify(secureStorage.deleteAllTokens()).called(1);
});

testWidgets('should complete logout successfully on network success', () async {
  final mockOAuthService = MockOAuthService();
  when(mockOAuthService.revokeToken()).thenAnswer((_) async => {});

  await repo.logout();

  verify(mockOAuthService.revokeToken()).called(1);
  verify(secureStorage.deleteAllTokens()).called(1);
});

// AuthNotifier Test
test('should handle logout gracefully even on network error', () async {
  when(mockRepo.logout()).thenAnswer((_) async {}); // 항상 성공

  await notifier.logout();

  final state = container.read(authNotifierProvider);
  expect(state.value, null);
});
```

---

## 🟢 Low Priority Issues (개선 제안)

### 7. OAuthResult 타입 명시 필요

**Spec 요구사항**:
- Main Scenario #9: "Access Token 및 Refresh Token 수신"
- Main Scenario #10: "사용자 프로필 정보 수신 (이름, 이메일, 프로필 이미지 URL)"

**Plan 현황**:
- OAuthService 테스트에 `result.accessToken`, `result.userInfo` 언급
- 그러나 **OAuthResult 타입 정의 없음**

**수정 방안**:
```dart
// Infrastructure Layer
class OAuthResult {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final Map<String, dynamic> userInfo; // name, email, profileImageUrl 포함

  OAuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.userInfo,
  });
}

// OAuthService
Future<OAuthResult> authenticateWithKakao() async {
  final kakaoToken = await UserApi.instance.loginWithKakaoAccount();
  final kakaoUser = await UserApi.instance.me();

  return OAuthResult(
    accessToken: kakaoToken.accessToken,
    refreshToken: kakaoToken.refreshToken!,
    expiresAt: kakaoToken.accessTokenExpiresAt,
    userInfo: {
      'name': kakaoUser.kakaoAccount?.profile?.nickname ?? '',
      'email': kakaoUser.kakaoAccount?.email ?? '',
      'profileImageUrl': kakaoUser.kakaoAccount?.profile?.profileImageUrl,
    },
  );
}
```

---

### 8. User Entity에 lastLoginAt 필드 추가 권장

**Spec 요구사항**:
- 재방문 자동 로그인 플로우 #4: "마지막 로그인 일시 업데이트"

**Plan 현황**:
- User Entity에 lastLoginAt 필드 없음

**수정 방안**:
```dart
// User Entity
class User extends Equatable {
  final String id;
  final String oauthProvider;
  final String oauthUserId;
  final String name;
  final String email;
  final String? profileImageUrl;
  final DateTime? lastLoginAt; // 추가
  final DateTime createdAt;

  // ...
}

// IsarAuthRepository
Future<User> loginWithKakao() async {
  final result = await _oauthService.authenticateWithKakao();

  // 기존 사용자 조회
  final existingUser = await getCurrentUser();

  final user = User(
    id: existingUser?.id ?? uuid.v4(),
    oauthProvider: 'kakao',
    oauthUserId: result.userInfo['id'],
    name: result.userInfo['name'],
    email: result.userInfo['email'],
    profileImageUrl: result.userInfo['profileImageUrl'],
    lastLoginAt: DateTime.now(), // 업데이트
    createdAt: existingUser?.createdAt ?? DateTime.now(),
  );

  // Isar에 저장
  await _saveUser(user);

  return user;
}
```

---

## 📋 Action Items

### Immediate (Critical)
1. [ ] User Entity에 `lastLoginAt` 필드 추가
2. [ ] AuthRepository에 `isFirstLogin()` 메서드 추가 및 구현
3. [ ] AuthNotifier의 로그인 메서드에 동의 정보 저장 로직 통합
4. [ ] 네이버 OAuth 관련 상세 테스트 케이스 추가 (OAuthService, IsarAuthRepository, AuthNotifier, LoginScreen)

### High Priority
5. [ ] SecureStorageService에 토큰 만료 시간 저장 및 검증 로직 추가
6. [ ] OAuthResult 타입 명시적으로 정의
7. [ ] 재시도 로직을 IsarAuthRepository에 집중 (OAuthService는 단순 통신만)
8. [ ] 로그아웃 Edge Case (네트워크 오류) 처리 로직 및 테스트 추가

### Medium Priority
9. [ ] AuthNotifier에 자동 토큰 갱신 로직 추가
10. [ ] LoginScreen에 최초 로그인 여부에 따른 네비게이션 분기 로직 명확화
11. [ ] ConsentRecord 저장 실패 시 롤백 전략 검토

---

## 📊 수정 후 검증 체크리스트

### Functional
- [ ] 카카오 로그인 성공 후 최초 로그인 여부 정확히 판단
- [ ] 네이버 로그인 성공 후 최초 로그인 여부 정확히 판단
- [ ] 동의 정보가 로그인 직후 DB에 저장됨
- [ ] 토큰 만료 시 자동 갱신 동작
- [ ] 네트워크 오류 시 정확히 3회 재시도
- [ ] 로그아웃 중 네트워크 오류 발생해도 로컬 토큰 삭제

### Non-Functional
- [ ] 모든 Critical/High Priority 테스트 추가 및 통과
- [ ] Layer 간 의존성 규칙 위반 없음
- [ ] Repository Pattern 유지
- [ ] Test Coverage > 80%

---

## 결론

plan.md는 전반적으로 Clean Architecture와 Repository Pattern을 잘 준수하고 있으나, 다음 영역에서 spec.md와 불일치가 발견됨:

1. **최초 로그인 판단 로직 누락** (Critical)
2. **동의 정보 저장 통합 불명확** (Critical)
3. **네이버 OAuth 테스트 부족** (Critical)
4. **토큰 만료 처리 세부사항 누락** (High)
5. **재시도 로직 책임 분리 필요** (High)
6. **로그아웃 Edge Case 미처리** (High)

위 Action Items를 반영하면 spec.md의 모든 요구사항을 충족하는 구현 계획이 완성됨.
