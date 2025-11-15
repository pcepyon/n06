# Naver Login with GoRouter - Flutter Implementation Guide

## Context
- **Service:** Naver Developers OAuth 2.0
- **Integration Goal:** Naver social login with GoRouter deep link handling
- **Integration Type:** SDK + Custom URL Scheme + Deep Linking
- **Last Updated:** November 15, 2025
- **SDK Version:** flutter_naver_login 1.8.0+
- **Flutter Version:** 3.x
- **Target OS:** Android 13+ (API 33+), iOS 11+

---

## Overview

**What you're integrating:** Naver social login SDK for Flutter with proper deep link handling via GoRouter.

**Why you need it:** GLP-1 치료 관리 앱의 F-001 기능 구현 - 소셜 로그인을 통한 사용자 인증. Repository Pattern을 준수하며 Phase 0(로컬 DB)에서 Phase 1(Supabase)로 전환 가능한 구조 유지.

**What you'll set up:**
- [x] Naver Flutter SDK installation
- [x] Android Custom URL Scheme configuration
- [x] iOS Custom URL Scheme configuration
- [x] GoRouter deep link routing
- [x] ProGuard/R8 rules for release builds

---

## Prerequisites

Before starting, ensure you have:
- [x] Naver Developers account created at [developers.naver.com](https://developers.naver.com)
- [x] Application registered in Naver Developers Console
- [x] Client ID and Client Secret obtained
- [x] Platform registered (Android package name, iOS bundle ID)
- [x] GoRouter already configured in your Flutter project

---

## Part 1: Naver Developers Console Setup

### Step 1: Create Application & Get Client ID/Secret

1. Login to [Naver Developers](https://developers.naver.com)
2. Navigate to **Application** → **애플리케이션 등록**
3. Fill in application details:
   - **애플리케이션 이름**: Your app name
   - **사용 API**: 네이버 로그인 선택
4. After creation, go to **API 설정**
5. Copy your **Client ID** and **Client Secret**

**Save these keys - you'll use them as:**
- `NAVER_CLIENT_ID` in your code
- `NAVER_CLIENT_SECRET` for server-side token verification
- Part of your custom URL scheme: `naverlogin`

### Step 2: Register Android Platform

1. Go to **API 설정** → **Android**
2. Enter your package name from `android/app/src/main/AndroidManifest.xml`
3. Click **추가**

### Step 3: Register iOS Platform

1. Go to **API 설정** → **iOS**
2. Enter Bundle ID from `ios/Runner/Info.plist`
3. Enter URL Scheme: `naverlogin`
4. Click **추가**

### Step 4: Set Service URL & Callback URL

1. **서비스 URL**: Your app's main URL (e.g., `https://yourapp.com`)
2. **Callback URL**:
   ```
   naverlogin://oauth
   ```
   - This is the custom URL scheme for deep linking
   - Must match your app's configured scheme

---

## Part 2: SDK Installation

### pubspec.yaml

```yaml
dependencies:
  # Naver Login SDK
  flutter_naver_login: ^1.8.0

  # Navigation (already in your project)
  go_router: ^13.0.0

  # Secure storage for tokens (Phase 0)
  flutter_secure_storage: ^9.0.0

  # Riverpod (already in your project)
  flutter_riverpod: ^2.4.0
```

```bash
flutter pub get
```

---

## Part 3: Android Configuration

### Step 1: AndroidManifest.xml Setup

**File:** `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.yourcompany.glp1_tracker">

    <!-- Internet permission for Naver API -->
    <uses-permission android:name="android.permission.INTERNET" />

    <application
        android:label="GLP-1 Tracker"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">

        <!-- Main Activity -->
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <!-- Main launcher intent -->
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>

            <!-- Deep link for GoRouter -->
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <!-- Naver OAuth callback scheme -->
                <data
                    android:scheme="naverlogin"
                    android:host="oauth" />
            </intent-filter>
        </activity>

        <!-- Don't forget FlutterDeepLinkingEnabled meta-data -->
        <meta-data
            android:name="flutter_deeplinking_enabled"
            android:value="true" />
    </application>
</manifest>
```

**⚠️ CRITICAL POINTS:**

1. **android:exported="true"** is REQUIRED for Android 12+ (API 31+)
2. **launchMode="singleTop"** prevents multiple instances
3. Custom scheme must be **naverlogin://oauth**

### Step 2: ProGuard/R8 Rules

**File:** `android/app/proguard-rules.pro`

```proguard
# Naver SDK
-keep public class com.nhn.android.naverlogin.** {
    public protected *;
}

# Gson (used by Naver SDK)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
```

**File:** `android/app/build.gradle`

```gradle
android {
    // ... other config

    buildTypes {
        release {
            // Enable ProGuard/R8
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'

            signingConfig signingConfigs.release
        }
    }
}
```

---

## Part 4: iOS Configuration

### Step 1: Info.plist Setup

**File:** `ios/Runner/Info.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- ... other config ... -->

    <!-- Enable Flutter Deep Linking -->
    <key>FlutterDeepLinkingEnabled</key>
    <true/>

    <!-- Custom URL Schemes for Naver Login -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLName</key>
            <string>com.yourcompany.glp1tracker</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <!-- Naver OAuth callback scheme -->
                <string>naverlogin</string>
            </array>
        </dict>
    </array>

    <!-- Allow Naver app to be opened -->
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <!-- Naver Login via Naver App -->
        <string>naversearchapp</string>
        <string>naversearchthirdlogin</string>
    </array>

    <!-- Naver SDK Configuration -->
    <key>NaverThirdPartyConstantsForApp</key>
    <dict>
        <key>kConsumerKey</key>
        <string>YOUR_NAVER_CLIENT_ID</string>
        <key>kConsumerSecret</key>
        <string>YOUR_NAVER_CLIENT_SECRET</string>
        <key>kServiceAppName</key>
        <string>GLP-1 Tracker</string>
        <key>kServiceAppUrlScheme</key>
        <string>naverlogin</string>
    </dict>
</dict>
</plist>
```

**⚠️ IMPORTANT**: Replace `YOUR_NAVER_CLIENT_ID` and `YOUR_NAVER_CLIENT_SECRET` with actual values from Naver Developers Console.

### Step 2: Podfile Minimum Version

**File:** `ios/Podfile`

```ruby
platform :ios, '11.0'

# ... rest of your Podfile
```

Naver Flutter SDK requires iOS 11.0 minimum.

---

## Part 5: GoRouter Deep Link Integration

### How GoRouter Handles Deep Links

GoRouter automatically processes deep links when:
1. User clicks a deep link (e.g., `naverlogin://oauth`)
2. Naver OAuth redirects to `naverlogin://oauth`
3. Flutter detects the incoming URI and GoRouter matches it to a route

**Key Insight:** You don't need `uni_links` or `app_links` packages. GoRouter handles everything if configured correctly.

### Router Configuration

**File:** `lib/core/routing/app_router.dart`

```dart
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    debugLogDiagnostics: true,

    // Enable deep link handling
    initialLocation: '/',

    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // OAuth callback route (optional - for explicit handling)
      // Naver redirects to naverlogin://oauth
      // GoRouter can catch this if you want custom handling
      GoRoute(
        path: '/oauth',
        name: 'oauth',
        builder: (context, state) {
          // Naver SDK handles this automatically
          // You typically don't need custom handling here
          return const OAuthCallbackScreen();
        },
      ),
    ],

    // Redirect unauthenticated users
    redirect: (context, state) async {
      final hasToken = await _checkAuthToken(ref);

      final isAuthRoute = state.matchedLocation == '/login' ||
                         state.matchedLocation == '/onboarding';

      if (!hasToken && !isAuthRoute) {
        return '/login';
      }

      return null; // No redirect
    },
  );
});

Future<bool> _checkAuthToken(Ref ref) async {
  // Check if user has valid Naver token
  try {
    final token = await FlutterNaverLogin.currentAccessToken;
    return token.accessToken.isNotEmpty;
  } catch (e) {
    return false;
  }
}
```

### Deep Link Testing

**Android:**
```bash
# Test Naver OAuth callback
adb shell am start -a android.intent.action.VIEW \
  -c android.intent.category.BROWSABLE \
  -d "naverlogin://oauth" \
  com.yourcompany.glp1_tracker
```

**iOS:**
```bash
xcrun simctl openurl booted "naverlogin://oauth"
```

---

## Part 6: Naver Login Implementation

### Repository Pattern Structure

Following your 4-Layer Architecture:

```
features/authentication/
├── presentation/
│   ├── screens/
│   │   └── login_screen.dart
│   └── widgets/
│       └── naver_login_button.dart
├── application/
│   ├── notifiers/
│   │   └── auth_notifier.dart
│   └── providers.dart
├── domain/
│   ├── entities/
│   │   └── user_profile.dart
│   ├── repositories/
│   │   └── auth_repository.dart  # Interface
│   └── usecases/
│       └── login_with_naver_usecase.dart
└── infrastructure/
    ├── repositories/
    │   ├── naver_auth_repository.dart  # Phase 0
    │   └── supabase_auth_repository.dart  # Phase 1 (future)
    ├── datasources/
    │   └── naver_auth_datasource.dart
    └── dtos/
        └── naver_user_dto.dart
```

### Domain Layer (Interface)

**File:** `lib/features/authentication/domain/repositories/auth_repository.dart`

```dart
import '../entities/user_profile.dart';

abstract class AuthRepository {
  Future<UserProfile> loginWithKakao();
  Future<UserProfile> loginWithNaver();
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<UserProfile?> getCurrentUser();
}
```

**File:** `lib/features/authentication/domain/entities/user_profile.dart`

```dart
class UserProfile {
  final String id;
  final String? email;
  final String? nickname;
  final String? profileImageUrl;
  final AuthProvider provider;

  UserProfile({
    required this.id,
    this.email,
    this.nickname,
    this.profileImageUrl,
    required this.provider,
  });
}

enum AuthProvider { kakao, naver }
```

### Infrastructure Layer (Naver Implementation)

**File:** `lib/features/authentication/infrastructure/repositories/naver_auth_repository.dart`

```dart
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../dtos/naver_user_dto.dart';

class NaverAuthRepository implements AuthRepository {
  final FlutterSecureStorage _secureStorage;

  NaverAuthRepository(this._secureStorage);

  @override
  Future<UserProfile> loginWithNaver() async {
    try {
      // 1. Naver SDK로 로그인
      final NaverLoginResult result = await FlutterNaverLogin.logIn();

      if (result.status != NaverLoginStatus.loggedIn) {
        throw Exception('Naver login was cancelled or failed');
      }

      // 2. Access Token 저장 (Phase 0)
      await _storeTokens(result.accessToken, result.refreshToken);

      // 3. 사용자 정보 가져오기
      final NaverAccountResult account = await FlutterNaverLogin.currentAccount();

      // 4. DTO를 통해 Entity로 변환
      return NaverUserDto.fromNaverAccount(account).toEntity();
    } catch (e) {
      throw Exception('Naver login failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await FlutterNaverLogin.logOut();
      await _clearTokens();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final token = await FlutterNaverLogin.currentAccessToken;
      return token.accessToken.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    try {
      if (!await isLoggedIn()) return null;

      final account = await FlutterNaverLogin.currentAccount();
      return NaverUserDto.fromNaverAccount(account).toEntity();
    } catch (e) {
      return null;
    }
  }

  // Phase 0: Store tokens in FlutterSecureStorage
  Future<void> _storeTokens(NaverAccessToken accessToken, String? refreshToken) async {
    await _secureStorage.write(
      key: 'naver_access_token',
      value: accessToken.accessToken,
    );
    if (refreshToken != null) {
      await _secureStorage.write(
        key: 'naver_refresh_token',
        value: refreshToken,
      );
    }
  }

  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: 'naver_access_token');
    await _secureStorage.delete(key: 'naver_refresh_token');
  }

  @override
  Future<UserProfile> loginWithKakao() {
    throw UnimplementedError('Kakao login not implemented in NaverAuthRepository');
  }
}
```

**File:** `lib/features/authentication/infrastructure/dtos/naver_user_dto.dart`

```dart
import 'package:flutter_naver_login/flutter_naver_login.dart';
import '../../domain/entities/user_profile.dart';

class NaverUserDto {
  final String id;
  final String? email;
  final String? nickname;
  final String? profileImageUrl;

  NaverUserDto({
    required this.id,
    this.email,
    this.nickname,
    this.profileImageUrl,
  });

  factory NaverUserDto.fromNaverAccount(NaverAccountResult account) {
    return NaverUserDto(
      id: account.id,
      email: account.email,
      nickname: account.nickname,
      profileImageUrl: account.profileImage,
    );
  }

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      email: email,
      nickname: nickname,
      profileImageUrl: profileImageUrl,
      provider: AuthProvider.naver,
    );
  }
}
```

### Application Layer (State Management)

**File:** `lib/features/authentication/application/providers.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/repositories/auth_repository.dart';
import '../infrastructure/repositories/naver_auth_repository.dart';

// Secure Storage Provider
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// Auth Repository Provider
// PHASE 0: Using NaverAuthRepository
// PHASE 1: Switch to SupabaseAuthRepository (just change this line)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return NaverAuthRepository(ref.watch(secureStorageProvider));
});
```

**File:** `lib/features/authentication/application/notifiers/auth_notifier.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../providers.dart';

class AuthState {
  final UserProfile? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserProfile? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState()) {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final user = await _repository.getCurrentUser();
    state = state.copyWith(user: user);
  }

  Future<void> loginWithNaver() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _repository.loginWithNaver();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _repository.logout();
      state = AuthState();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
```

### Presentation Layer

**File:** `lib/features/authentication/presentation/screens/login_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/notifiers/auth_notifier.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    // Navigate to onboarding after successful login
    ref.listen(authNotifierProvider, (previous, next) {
      if (next.user != null && previous?.user == null) {
        context.go('/onboarding');
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              const Text(
                'GLP-1 치료 관리',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),

              // Naver Login Button
              ElevatedButton(
                onPressed: authState.isLoading
                    ? null
                    : () => ref.read(authNotifierProvider.notifier).loginWithNaver(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF03C75A),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: authState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Naver logo
                          Image.asset('assets/naver_logo.png', height: 24),
                          const SizedBox(width: 12),
                          const Text(
                            '네이버 로그인',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
              ),

              if (authState.error != null) ...[
                const SizedBox(height: 16),
                Text(
                  authState.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

### Initialize Naver SDK

**File:** `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';

import 'core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Naver SDK
  await FlutterNaverLogin.initSdk(
    clientId: 'YOUR_NAVER_CLIENT_ID',
    clientSecret: 'YOUR_NAVER_CLIENT_SECRET',
    clientName: 'GLP-1 치료 관리',
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'GLP-1 치료 관리',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
```

---

## Part 7: Known Issues & Solutions

### Issue 1: "No Activity found to handle Intent"

**Cause:** Intent filter not properly configured or exported=false on Android 12+

**Solution:**
- Ensure `android:exported="true"` on MainActivity
- Verify intent-filter data scheme matches `naverlogin`
- Check if `flutter_deeplinking_enabled` meta-data is present

### Issue 2: iOS Build Error - "NaverThirdPartyLogin not found"

**Cause:** Pods not installed or outdated

**Solution:**
```bash
cd ios
pod install --repo-update
cd ..
flutter clean
flutter pub get
```

### Issue 3: Deep Link Not Working

**Cause:** URL Scheme mismatch

**Solution:**
- Android: Check `android:scheme="naverlogin"` in AndroidManifest.xml
- iOS: Check `CFBundleURLSchemes` includes `naverlogin` in Info.plist
- Verify Naver Developers Console has matching callback URL

---

## Testing Checklist

### Development Testing
- [ ] Naver SDK initialized successfully (check logs)
- [ ] Login button triggers Naver login flow
- [ ] Naver app opens for login (if installed)
- [ ] Web login works when Naver app not available
- [ ] OAuth redirect returns to app correctly
- [ ] User info fetched after login
- [ ] Tokens stored securely in FlutterSecureStorage
- [ ] Deep links work (test with adb/xcrun)
- [ ] GoRouter navigation works after login
- [ ] Logout clears tokens and returns to login screen

### Android-Specific
- [ ] Package name registered in Naver Developers Console
- [ ] Intent filter configured in AndroidManifest
- [ ] android:exported="true" on MainActivity
- [ ] Intent filter scheme matches `naverlogin`
- [ ] ProGuard rules applied for release build

### iOS-Specific
- [ ] Bundle ID matches Naver Developers Console registration
- [ ] CFBundleURLSchemes includes `naverlogin`
- [ ] LSApplicationQueriesSchemes includes Naver apps
- [ ] FlutterDeepLinkingEnabled is true
- [ ] NaverThirdPartyConstantsForApp configured
- [ ] Minimum iOS version is 11.0

### Phase Transition (Phase 0 → Phase 1)
- [ ] Repository interface remains unchanged
- [ ] Only authRepositoryProvider DI line changes
- [ ] Application and Presentation layers work without modification
- [ ] Tokens migrate from FlutterSecureStorage to Supabase

---

## Error Handling

### Common Errors

#### Error 1: `NaverLoginStatus.error`
**Cause:** User cancelled login or network error
**Solution:**
```dart
try {
  final result = await FlutterNaverLogin.logIn();
  if (result.status == NaverLoginStatus.loggedIn) {
    // Success
  } else {
    // Handle cancellation or error
    print('Login cancelled or failed: ${result.errorMessage}');
  }
} catch (e) {
  print('Login error: $e');
}
```

#### Error 2: `PlatformException: Invalid client credentials`
**Cause:** Client ID or Secret mismatch
**Solution:**
- Double-check Client ID and Secret in `main.dart`
- Verify they match Naver Developers Console
- For iOS, also check Info.plist configuration

---

## Phase Transition: Local to Cloud

### Current (Phase 0): Local Storage
```dart
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return NaverAuthRepository(ref.watch(secureStorageProvider));
});
```

### Future (Phase 1): Supabase Integration
```dart
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository(ref.watch(supabaseClientProvider));
});
```

**Implementation of SupabaseAuthRepository:**

```dart
class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _supabase;

  SupabaseAuthRepository(this._supabase);

  @override
  Future<UserProfile> loginWithNaver() async {
    // 1. Get Naver OAuth token using native SDK
    final result = await FlutterNaverLogin.logIn();

    if (result.status != NaverLoginStatus.loggedIn) {
      throw Exception('Naver login failed');
    }

    // 2. Use Supabase signInWithIdToken
    final authResponse = await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.kakao, // Naver uses generic provider
      idToken: result.accessToken.accessToken,
      accessToken: result.accessToken.accessToken,
    );

    // 3. Map to domain entity
    return UserProfile(
      id: authResponse.user!.id,
      email: authResponse.user!.email,
      provider: AuthProvider.naver,
    );
  }

  // ... other methods
}
```

**Benefits of Repository Pattern:**
- Domain, Application, Presentation layers unchanged
- Only 1 line in DI provider changes
- Easy A/B testing between Phase 0 and Phase 1

---

## References

### Official Documentation
- [Naver Developers - Login API](https://developers.naver.com/docs/login/overview/)
- [flutter_naver_login Package](https://pub.dev/packages/flutter_naver_login)
- [GoRouter Documentation](https://pub.dev/documentation/go_router/latest/)
- [Flutter Deep Linking](https://docs.flutter.dev/ui/navigation/deep-linking)

### Package Documentation
- [flutter_naver_login on pub.dev](https://pub.dev/packages/flutter_naver_login)
- [go_router on pub.dev](https://pub.dev/packages/go_router)
- [flutter_secure_storage on pub.dev](https://pub.dev/packages/flutter_secure_storage)

---

## Production Checklist

Before going live:
- [ ] Client ID and Secret configured correctly
- [ ] ProGuard/R8 rules tested in release build
- [ ] iOS App Store review prepared (explain social login usage)
- [ ] Privacy policy includes Naver login data handling
- [ ] Error tracking set up (Firebase Crashlytics)
- [ ] Token refresh flow tested
- [ ] Network error handling implemented
- [ ] User logout flow tested
- [ ] Deep link fallback for unsupported scenarios

---

**End of Implementation Guide**

This guide provides everything needed to implement Naver login with GoRouter in your Flutter app while maintaining architectural consistency with your existing codebase.
