# External Authentication Implementation Guide

This document provides a guide for implementing Kakao and Naver social logins for the GLP-1 management app, following the project's architecture and tech stack.

## 1. Project Context

- **Tech Stack**: Flutter, Riverpod, Isar, `kakao_flutter_sdk`, `flutter_naver_login`, `flutter_secure_storage`.
- **Architecture**: 4-Layer (Presentation, Application, Domain, Infrastructure). Authentication logic resides in `features/authentication/`.
- **Goal**: Implement social login, retrieve user profile (name, email, profile image), and securely store OAuth tokens.

## 2. Kakao Login Implementation

**Library**: `kakao_flutter_sdk`

### Step 1: Configuration

1.  **Kakao Developers**:
    *   Create a new application.
    *   Enable "Kakao Login" in the product settings.
    *   Register the platform (Android/iOS) and set up package name/bundle ID.
    *   Obtain the **Native App Key**.

2.  **Android (`android/app/src/main/AndroidManifest.xml`)**:
    *   Add a `meta-data` tag with the Native App Key.
    *   Add an `intent-filter` for the custom URL scheme (`kakao${NATIVE_APP_KEY}://oauth`).

3.  **iOS (`ios/Runner/Info.plist`)**:
    *   Add `LSApplicationQueriesSchemes` for `kakaokompassauth`, `kakaolink`.
    *   Add a `CFBundleURLTypes` entry with the custom URL scheme (`kakao${NATIVE_APP_KEY}`).

### Step 2: Implementation (`features/authentication/infrastructure/datasources/`)

Create a `KakaoAuthDataSource` class.

```dart
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class KakaoAuthDataSource {
  Future<OAuthToken?> login() async {
    if (await isKakaoTalkInstalled()) {
      try {
        return await UserApi.instance.loginWithKakaoTalk();
      } catch (error) {
        // Fallback to account login if KakaoTalk login fails
        return await UserApi.instance.loginWithKakaoAccount();
      }
    } else {
      return await UserApi.instance.loginWithKakaoAccount();
    }
  }

  Future<void> logout() async {
    await UserApi.instance.logout();
  }

  Future<User?> getUser() async {
    try {
      return await UserApi.instance.me();
    } catch (error) {
      return null;
    }
  }
}
```

## 3. Naver Login Implementation

**Library**: `flutter_naver_login`

### Step 1: Configuration

1.  **Naver Developers**:
    *   Create a new application.
    *   Enable "Naver Login".
    *   Register the platform (Android/iOS) and get the **Client ID** and **Client Secret**.
    *   Define the callback URL.

2.  **Android**:
    *   No specific manifest configuration is required by the library itself, but ensure your build settings are correct.

3.  **iOS (`ios/Runner/Info.plist`)**:
    *   Add `LSApplicationQueriesSchemes` for `naversearchapp`, `naversearchthirdlogin`.
    *   Add a `CFBundleURLTypes` entry with your URL scheme.

### Step 2: Implementation (`features/authentication/infrastructure/datasources/`)

Create a `NaverAuthDataSource` class.

```dart
import 'package:flutter_naver_login/flutter_naver_login.dart';

class NaverAuthDataSource {
  Future<NaverLoginResult?> login() async {
    return await FlutterNaverLogin.logIn();
  }

  Future<void> logout() async {
    await FlutterNaverLogin.logOut();
  }

  Future<NaverAccountResult?> getUser(NaverAccessToken token) async {
     return await FlutterNaverLogin.currentAccount();
  }
}
```

## 4. Token Storage

**Library**: `flutter_secure_storage`

Create a `TokenStorage` service in `core/` to handle secure storage of tokens.

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final _storage = const FlutterSecureStorage();

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: 'ACCESS_TOKEN', value: accessToken);
    await _storage.write(key: 'REFRESH_TOKEN', value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'ACCESS_TOKEN');
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'REFRESH_TOKEN');
  }

  Future<void> deleteAllTokens() async {
    await _storage.deleteAll();
  }
}
```

## 5. Architectural Integration

1.  **Domain Layer (`features/authentication/domain/`)**:
    *   Define an `AuthRepository` interface.
    *   Define `User` and `AuthToken` entities.

    ```dart
    // domain/repositories/auth_repository.dart
    abstract class AuthRepository {
      Future<User?> login(AuthProvider provider);
      Future<void> logout();
      Future<User?> getLoggedInUser();
    }

    enum AuthProvider { kakao, naver }
    ```

2.  **Infrastructure Layer (`features/authentication/infrastructure/`)**:
    *   Implement `AuthRepository` in `AuthRepositoryImpl`.
    *   This implementation will use the `KakaoAuthDataSource` and `NaverAuthDataSource`.
    *   It will also use the `TokenStorage` to save/retrieve tokens.
    *   Map the DTOs from the data sources to the domain `User` entity.

3.  **Application Layer (`features/authentication/application/`)**:
    *   Create a `Notifier` (e.g., `AuthNotifier`) that uses the `AuthRepository`.
    *   The notifier will manage the authentication state (e.g., logged in, logged out, loading).
    *   Expose methods like `login(AuthProvider)` and `logout`.

4.  **Presentation Layer (`features/authentication/presentation/`)**:
    *   The UI will call the methods on the `AuthNotifier`.
    *   Display login buttons and react to state changes from the notifier.

This structure ensures that the UI is decoupled from the specific implementation of Kakao or Naver login, and that token management is handled securely and centrally.
