# Kakao Login with GoRouter - Flutter Implementation Guide

## Context
- **Service:** Kakao Flutter SDK
- **Integration Goal:** Kakao/Naver social login with GoRouter deep link handling
- **Integration Type:** SDK + Custom URL Scheme + Deep Linking
- **Last Updated:** November 9, 2025
- **SDK Version:** kakao_flutter_sdk 1.9.5+
- **Flutter Version:** 3.x
- **Target OS:** Android 13+ (API 33+), iOS 11+

---

## Overview

**What you're integrating:** Kakao social login SDK for Flutter with proper deep link handling via GoRouter.

**Why you need it:** GLP-1 치료 관리 앱의 F-001 기능 구현 - 소셜 로그인을 통한 사용자 인증. Repository Pattern을 준수하며 Phase 0(로컬 DB)에서 Phase 1(Supabase)로 전환 가능한 구조 유지.

**What you'll set up:**
- [x] Kakao Flutter SDK installation
- [x] Android Custom URL Scheme with AuthCodeCustomTabsActivity
- [x] iOS Custom URL Scheme configuration
- [x] GoRouter deep link routing
- [x] ProGuard/R8 rules for release builds

---

## Prerequisites

Before starting, ensure you have:
- [x] Kakao Developers account created at [developers.kakao.com](https://developers.kakao.com)
- [x] Application registered in Kakao Developers Console
- [x] Native App Key obtained from console
- [x] Platform registered (Android package name + key hash, iOS bundle ID)
- [x] GoRouter already configured in your Flutter project

---

## Part 1: Kakao Developers Console Setup

### Step 1: Create Application & Get Native App Key

1. Login to [Kakao Developers](https://developers.kakao.com)
2. Navigate to **내 애플리케이션** → **애플리케이션 추가하기**
3. Create new application
4. Go to **앱 설정** → **요약 정보**
5. Copy your **네이티브 앱 키 (Native App Key)**

**Save this key - you'll use it as:**
- `KAKAO_NATIVE_APP_KEY` in your code
- Part of your custom URL scheme: `kakao${KAKAO_NATIVE_APP_KEY}`

### Step 2: Register Android Platform

1. Go to **앱 설정** → **플랫폼** → **Android 플랫폼 등록**
2. Enter your package name from `android/app/src/main/AndroidManifest.xml`
3. Generate and register Key Hash:

```bash
# Debug Key Hash (for development)
keytool -exportcert -alias androiddebugkey \
  -keystore ~/.android/debug.keystore \
  -storepass android -keypass android | \
  openssl sha1 -binary | openssl base64

# Release Key Hash (for production)
keytool -exportcert -alias YOUR_KEY_ALIAS \
  -keystore path/to/your/keystore.jks | \
  openssl sha1 -binary | openssl base64
```

4. Register the generated hash in Kakao Console

### Step 3: Register iOS Platform

1. Go to **앱 설정** → **플랫폼** → **iOS 플랫폼 등록**
2. Enter Bundle ID from `ios/Runner/Info.plist`
3. Save configuration

### Step 4: Enable Kakao Login

1. Navigate to **제품 설정** → **카카오 로그인**
2. **활성화 설정** → ON
3. **OpenID Connect 활성화** → ON (if using with Firebase)
4. **Redirect URI** → `kakao${YOUR_NATIVE_APP_KEY}://oauth` (auto-configured by SDK)

---

## Part 2: SDK Installation

### pubspec.yaml

```yaml
dependencies:
  # Kakao SDK - only user module for login
  kakao_flutter_sdk_user: ^1.9.5
  
  # Navigation (already in your project)
  go_router: ^13.0.0
  
  # Secure storage for tokens (Phase 0)
  flutter_secure_storage: ^9.0.0
  
  # Riverpod (already in your project)
  flutter_riverpod: ^2.4.0
```

**Note:** Install only needed modules. For login-only use case, `kakao_flutter_sdk_user` is sufficient.

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

    <!-- Internet permission for Kakao API -->
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
                <!-- Your app's custom scheme for deep linking -->
                <data android:scheme="glp1tracker" />
            </intent-filter>
        </activity>

        <!-- Kakao Login Custom Tabs Activity -->
        <!-- CRITICAL: This handles OAuth callback from Kakao -->
        <activity
            android:name="com.kakao.sdk.flutter.AuthCodeCustomTabsActivity"
            android:exported="true"
            android:launchMode="singleTop">
            <intent-filter android:label="flutter_web_auth">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                
                <!-- REPLACE ${YOUR_NATIVE_APP_KEY} with actual key -->
                <data
                    android:scheme="kakao${YOUR_NATIVE_APP_KEY}"
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

1. **android:exported="true"** is REQUIRED for Android 12+ (API 31+) for activities with intent-filters
2. **AuthCodeCustomTabsActivity** must be declared separately from MainActivity
3. Replace `${YOUR_NATIVE_APP_KEY}` with your actual Kakao Native App Key
4. **launchMode="singleTop"** prevents multiple instances when returning from Custom Tabs

### Step 2: ProGuard/R8 Rules

**File:** `android/app/proguard-rules.pro`

```proguard
# Kakao SDK
-keep class com.kakao.sdk.**.model.* { <fields>; }
-keep class * extends com.google.gson.TypeAdapter

# Keep all Kakao SDK classes from being obfuscated
-keep class com.kakao.sdk.** { *; }
-keepclassmembers class com.kakao.sdk.** { *; }

# Gson (used by Kakao SDK)
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

    <!-- Custom URL Schemes for Kakao Login -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLName</key>
            <string>com.yourcompany.glp1tracker</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <!-- REPLACE with your actual Native App Key -->
                <string>kakao${YOUR_NATIVE_APP_KEY}</string>
                <!-- Your app's deep link scheme -->
                <string>glp1tracker</string>
            </array>
        </dict>
    </array>

    <!-- Allow Kakao apps to be opened (for Login with KakaoTalk) -->
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <!-- Kakao Login via KakaoTalk -->
        <string>kakaokompassauth</string>
        <!-- Kakao Talk Share (if needed later) -->
        <string>kakaolink</string>
        <!-- Kakao Channel (if needed later) -->
        <string>kakaoplus</string>
    </array>
</dict>
</plist>
```

### Step 2: Podfile Minimum Version

**File:** `ios/Podfile`

```ruby
platform :ios, '11.0'

# ... rest of your Podfile
```

Kakao Flutter SDK requires iOS 11.0 minimum.

---

## Part 5: GoRouter Deep Link Integration

### How GoRouter Handles Deep Links

GoRouter automatically processes deep links when:
1. User clicks a deep link (e.g., `glp1tracker://onboarding`)
2. Kakao OAuth redirects to `kakao${YOUR_KEY}://oauth`
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
      // Kakao redirects to kakao{KEY}://oauth
      // GoRouter can catch this if you want custom handling
      GoRoute(
        path: '/oauth',
        name: 'oauth',
        builder: (context, state) {
          // Extract query parameters if needed
          final code = state.uri.queryParameters['code'];
          // Handle OAuth callback
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
  // Check if user has valid Kakao token
  try {
    final tokenManager = await TokenManagerProvider.instance.manager.getToken();
    return tokenManager.refreshToken != null;
  } catch (e) {
    return false;
  }
}
```

### Deep Link Testing

**Android:**
```bash
# Test deep link to onboarding
adb shell am start -a android.intent.action.VIEW \
  -c android.intent.category.BROWSABLE \
  -d "glp1tracker://onboarding" \
  com.yourcompany.glp1_tracker

# Test Kakao OAuth callback (simulated)
adb shell am start -a android.intent.action.VIEW \
  -c android.intent.category.BROWSABLE \
  -d "kakao${YOUR_KEY}://oauth?code=test_code" \
  com.yourcompany.glp1_tracker
```

**iOS:**
```bash
xcrun simctl openurl booted "glp1tracker://onboarding"
xcrun simctl openurl booted "kakao${YOUR_KEY}://oauth?code=test_code"
```

---

## Part 6: Kakao Login Implementation

### Repository Pattern Structure

Following your 4-Layer Architecture:

```
features/authentication/
├── presentation/
│   ├── screens/
│   │   └── login_screen.dart
│   └── widgets/
│       └── kakao_login_button.dart
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
│       └── login_with_kakao_usecase.dart
└── infrastructure/
    ├── repositories/
    │   ├── kakao_auth_repository.dart  # Phase 0
    │   └── supabase_auth_repository.dart  # Phase 1 (future)
    ├── datasources/
    │   └── kakao_auth_datasource.dart
    └── dtos/
        └── kakao_user_dto.dart
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

### Infrastructure Layer (Kakao Implementation)

**File:** `lib/features/authentication/infrastructure/repositories/kakao_auth_repository.dart`

```dart
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../dtos/kakao_user_dto.dart';

class KakaoAuthRepository implements AuthRepository {
  final FlutterSecureStorage _secureStorage;

  KakaoAuthRepository(this._secureStorage);

  @override
  Future<UserProfile> loginWithKakao() async {
    try {
      OAuthToken token;

      // 1. Try login with KakaoTalk app first
      if (await isKakaoTalkInstalled()) {
        try {
          token = await UserApi.instance.loginWithKakaoTalk();
        } catch (error) {
          // If KakaoTalk login fails, fall back to web login
          token = await UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        // If KakaoTalk not installed, use web login
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      // 2. Store tokens securely (Phase 0)
      await _storeTokens(token);

      // 3. Fetch user info
      final kakaoUser = await UserApi.instance.me();

      // 4. Convert to domain entity
      return KakaoUserDto.fromKakaoAccount(kakaoUser).toEntity();
    } catch (error) {
      throw _handleKakaoError(error);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await UserApi.instance.logout();
      await _clearTokens();
    } catch (error) {
      throw Exception('Logout failed: $error');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final hasToken = await TokenManagerProvider.instance.manager.getToken();
      return hasToken.refreshToken != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    try {
      if (!await isLoggedIn()) return null;

      final kakaoUser = await UserApi.instance.me();
      return KakaoUserDto.fromKakaoAccount(kakaoUser).toEntity();
    } catch (e) {
      return null;
    }
  }

  // Phase 0: Store tokens in FlutterSecureStorage
  Future<void> _storeTokens(OAuthToken token) async {
    await _secureStorage.write(
      key: 'kakao_access_token',
      value: token.accessToken,
    );
    if (token.refreshToken != null) {
      await _secureStorage.write(
        key: 'kakao_refresh_token',
        value: token.refreshToken!,
      );
    }
  }

  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: 'kakao_access_token');
    await _secureStorage.delete(key: 'kakao_refresh_token');
  }

  Exception _handleKakaoError(dynamic error) {
    if (error is KakaoException) {
      return Exception('Kakao Error: ${error.message}');
    }
    return Exception('Unexpected error: $error');
  }

  @override
  Future<UserProfile> loginWithNaver() {
    throw UnimplementedError('Naver login not implemented yet');
  }
}
```

**File:** `lib/features/authentication/infrastructure/dtos/kakao_user_dto.dart`

```dart
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import '../../domain/entities/user_profile.dart';

class KakaoUserDto {
  final String id;
  final String? email;
  final String? nickname;
  final String? profileImageUrl;

  KakaoUserDto({
    required this.id,
    this.email,
    this.nickname,
    this.profileImageUrl,
  });

  factory KakaoUserDto.fromKakaoAccount(User kakaoUser) {
    return KakaoUserDto(
      id: kakaoUser.id.toString(),
      email: kakaoUser.kakaoAccount?.email,
      nickname: kakaoUser.kakaoAccount?.profile?.nickname,
      profileImageUrl: kakaoUser.kakaoAccount?.profile?.profileImageUrl,
    );
  }

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      email: email,
      nickname: nickname,
      profileImageUrl: profileImageUrl,
      provider: AuthProvider.kakao,
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
import '../infrastructure/repositories/kakao_auth_repository.dart';

// Secure Storage Provider
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// Auth Repository Provider
// PHASE 0: Using KakaoAuthRepository
// PHASE 1: Switch to SupabaseAuthRepository (just change this line)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return KakaoAuthRepository(ref.watch(secureStorageProvider));
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

  Future<void> loginWithKakao() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _repository.loginWithKakao();
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

              // Kakao Login Button
              ElevatedButton(
                onPressed: authState.isLoading
                    ? null
                    : () => ref.read(authNotifierProvider.notifier).loginWithKakao(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEE500),
                  foregroundColor: Colors.black87,
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: authState.isLoading
                    ? const CircularProgressIndicator()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Kakao logo
                          Image.asset('assets/kakao_logo.png', height: 24),
                          const SizedBox(width: 12),
                          const Text(
                            '카카오 로그인',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 16),

              // Naver Login Button (placeholder)
              ElevatedButton(
                onPressed: null, // TODO: Implement Naver login
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF03C75A),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text('네이버 로그인'),
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

### Initialize Kakao SDK

**File:** `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'core/routing/app_router.dart';

void main() {
  // Initialize Kakao SDK
  KakaoSdk.init(
    nativeAppKey: 'YOUR_NATIVE_APP_KEY',
    // javaScriptAppKey: 'YOUR_JAVASCRIPT_KEY', // Optional for web
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
- Ensure `android:exported="true"` on AuthCodeCustomTabsActivity
- Verify intent-filter data scheme matches `kakao${YOUR_KEY}`
- Check if `flutter_deeplinking_enabled` meta-data is present

### Issue 2: Custom Tabs Returning to Wrong Activity

**Cause:** Multiple activities with same intent-filter or incorrect launchMode

**Solution:**
- Use `launchMode="singleTop"` on both MainActivity and AuthCodeCustomTabsActivity
- Keep intent-filters separate - don't duplicate Kakao scheme in MainActivity

### Issue 3: GoRouter Not Catching Deep Links

**Cause:** Missing FlutterDeepLinkingEnabled in Info.plist (iOS) or meta-data (Android)

**Solution:**
```xml
<!-- iOS: Info.plist -->
<key>FlutterDeepLinkingEnabled</key>
<true/>

<!-- Android: AndroidManifest.xml -->
<meta-data
    android:name="flutter_deeplinking_enabled"
    android:value="true" />
```

### Issue 4: ProGuard Removing Kakao SDK Classes

**Cause:** Missing ProGuard rules for Kakao SDK

**Solution:** Add rules from Part 3, Step 2

### Issue 5: iOS Universal Link Not Working

**Cause:** Missing LSApplicationQueriesSchemes for KakaoTalk

**Solution:** Add kakaokompassauth to Info.plist (see Part 4)

### Issue 6: Android 13+ Intent Filter Matching Failure

**Root Cause:** Android 13 (API 33+) introduced stricter intent-filter matching rules. Explicit intents from external apps now MUST match the declared intent-filter exactly.

**Symptoms:**
- Kakao login works on Android 12 but fails on Android 13+
- OAuth redirect doesn't trigger AuthCodeCustomTabsActivity
- Chrome Custom Tabs can't return to app

**Solution:**
Ensure your intent-filter matches EXACTLY what Kakao SDK sends:

```xml
<activity
    android:name="com.kakao.sdk.flutter.AuthCodeCustomTabsActivity"
    android:exported="true"
    android:launchMode="singleTop">
    <intent-filter android:label="flutter_web_auth">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        
        <!-- EXACT match required -->
        <data
            android:scheme="kakao${YOUR_NATIVE_APP_KEY}"
            android:host="oauth" />
    </intent-filter>
</activity>
```

**Key Points:**
- `android:exported="true"` is MANDATORY
- Scheme must be EXACTLY `kakao${YOUR_KEY}` (no typos)
- Host must be EXACTLY `oauth` (no variations)
- Don't add pathPrefix or other data attributes unless Kakao SDK uses them

---

## Testing Checklist

### Development Testing
- [ ] Kakao SDK initialized successfully (check logs)
- [ ] Login button triggers Kakao login flow
- [ ] KakaoTalk app opens for login (if installed)
- [ ] Web login works when KakaoTalk not available
- [ ] OAuth redirect returns to app correctly
- [ ] User info fetched after login
- [ ] Tokens stored securely in FlutterSecureStorage
- [ ] Deep links work (test with adb/xcrun)
- [ ] GoRouter navigation works after login
- [ ] Logout clears tokens and returns to login screen

### Android-Specific
- [ ] Debug key hash registered in Kakao Console
- [ ] AuthCodeCustomTabsActivity declared in AndroidManifest
- [ ] android:exported="true" on all activities with intent-filters
- [ ] Intent filter scheme matches `kakao${YOUR_KEY}`
- [ ] ProGuard rules applied for release build
- [ ] Release build works with release key hash

### iOS-Specific
- [ ] Bundle ID matches Kakao Console registration
- [ ] CFBundleURLSchemes includes `kakao${YOUR_KEY}`
- [ ] LSApplicationQueriesSchemes includes kakaokompassauth
- [ ] FlutterDeepLinkingEnabled is true
- [ ] Minimum iOS version is 11.0

### Phase Transition (Phase 0 → Phase 1)
- [ ] Repository interface remains unchanged
- [ ] Only authRepositoryProvider DI line changes
- [ ] Application and Presentation layers work without modification
- [ ] Tokens migrate from FlutterSecureStorage to Supabase

---

## Error Handling

### Common Errors

#### Error 1: `KakaoAuthException: INVALID_TOKEN`
**Cause:** Access token expired and refresh token also invalid
**Solution:**
```dart
try {
  final user = await UserApi.instance.me();
} on KakaoAuthException catch (e) {
  if (e.code == ApiErrorCause.INVALID_TOKEN) {
    // Clear tokens and redirect to login
    await authRepository.logout();
    context.go('/login');
  }
}
```

#### Error 2: `PlatformException: Error while launching`
**Cause:** Intent filter mismatch or missing configuration
**Solution:**
- Double-check AndroidManifest.xml intent-filter
- Verify iOS Info.plist CFBundleURLSchemes
- Ensure native app key is correct

#### Error 3: Login succeeds but app doesn't redirect
**Cause:** GoRouter redirect logic preventing navigation
**Solution:** Check your `redirect` callback in GoRouter - make sure it allows navigation after login

---

## Phase Transition: Local to Cloud

### Current (Phase 0): Local Storage
```dart
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return KakaoAuthRepository(ref.watch(secureStorageProvider));
});
```

### Future (Phase 1): Supabase Integration
```dart
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository(ref.watch(supabaseClientProvider));
});
```

---

### Phase 1 Implementation Details

**Implementation of SupabaseAuthRepository:**

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _supabase;

  SupabaseAuthRepository(this._supabase);

  @override
  Future<UserProfile> loginWithKakao() async {
    try {
      OAuthToken kakaoToken;

      // 1. Get Kakao OAuth token using native SDK
      // Try KakaoTalk app login first, fall back to web
      if (await isKakaoTalkInstalled()) {
        try {
          kakaoToken = await UserApi.instance.loginWithKakaoTalk();
        } catch (error) {
          kakaoToken = await UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        kakaoToken = await UserApi.instance.loginWithKakaoAccount();
      }

      // 2. Sign in to Supabase using Kakao token
      // Supabase will verify the token with Kakao and create a session
      final authResponse = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.kakao,
        idToken: kakaoToken.idToken!,
        accessToken: kakaoToken.accessToken,
      );

      if (authResponse.user == null) {
        throw Exception('Supabase authentication failed');
      }

      // 3. Fetch Kakao user info (optional - for additional profile data)
      final kakaoUser = await UserApi.instance.me();

      // 4. Update Supabase user metadata with Kakao profile
      await _supabase.from('users').upsert({
        'id': authResponse.user!.id,
        'name': kakaoUser.kakaoAccount?.profile?.nickname ??
                authResponse.user!.email?.split('@')[0] ?? 'User',
        'profile_image_url': kakaoUser.kakaoAccount?.profile?.profileImageUrl,
        'last_login_at': DateTime.now().toIso8601String(),
      });

      // 5. Map to domain entity
      return UserProfile(
        id: authResponse.user!.id,
        email: kakaoUser.kakaoAccount?.email ?? authResponse.user!.email,
        nickname: kakaoUser.kakaoAccount?.profile?.nickname,
        profileImageUrl: kakaoUser.kakaoAccount?.profile?.profileImageUrl,
        provider: AuthProvider.kakao,
      );
    } catch (e) {
      throw Exception('Kakao login with Supabase failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      // 1. Logout from Kakao SDK
      await UserApi.instance.logout();

      // 2. Sign out from Supabase
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      // Check Supabase session (single source of truth)
      final session = _supabase.auth.currentSession;
      return session != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      // Fetch full profile from database
      final profile = await _supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      return UserProfile(
        id: user.id,
        email: user.email,
        nickname: profile['name'] as String?,
        profileImageUrl: profile['profile_image_url'] as String?,
        provider: AuthProvider.kakao,
      );
    } catch (e) {
      return null;
    }
  }
}
```

---

### Key Points for Phase 1 Transition

**1. Authentication Flow:**
```
User clicks "Kakao Login"
   ↓
Kakao Native SDK login (KakaoTalk app or web)
   ↓
Get Kakao OAuth tokens (idToken, accessToken)
   ↓
Send to Supabase: signInWithIdToken()
   ↓
Supabase verifies token with Kakao servers
   ↓
Supabase creates JWT session
   ↓
All subsequent DB queries use Supabase JWT (NOT Kakao token!)
```

**2. Token Management:**
- ❌ Kakao tokens are NOT stored or used for DB access
- ✅ Supabase automatically manages JWT tokens (access + refresh)
- ✅ Supabase handles automatic token refresh
- ✅ All DB queries authenticated via Supabase JWT

**3. Database Access Control:**
```sql
-- RLS policies use Supabase auth.uid(), NOT Kakao ID
CREATE POLICY "Users can view own records"
ON dose_records FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM dosage_plans
    WHERE id = dosage_plan_id
    AND user_id = auth.uid()  -- ⭐ Supabase user ID
  )
);
```

**4. Benefits of This Approach:**
- ✅ Native app UX (KakaoTalk quick login)
- ✅ Supabase handles ALL authentication & authorization
- ✅ Automatic session management & token refresh
- ✅ RLS policies work seamlessly
- ✅ Single source of truth (Supabase session)

**5. Migration Path:**
- Domain layer: **No changes**
- Application layer: **No changes**
- Presentation layer: **No changes**
- Infrastructure layer: **Only change DI line** in `providers.dart`

```dart
// Change this ONE line:
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // return KakaoAuthRepository(ref.watch(secureStorageProvider));  // Phase 0
  return SupabaseAuthRepository(ref.watch(supabaseClientProvider));  // Phase 1
});
```

---

### Supabase Configuration Required

**1. Enable Kakao Provider in Supabase Dashboard:**
```
Authentication → Providers → Kakao
  ✅ Enable Kakao provider
  Client ID: (not needed for native SDK flow)
  Client Secret: (not needed for native SDK flow)
```

**2. Supabase automatically handles:**
- Token verification with Kakao
- User creation in `auth.users` table
- Session management (JWT tokens)
- Automatic token refresh
- RLS policy enforcement

**3. No additional server-side code needed!**
- Supabase's `signInWithIdToken()` does all the work
- Just pass the Kakao tokens from native SDK

---

**Benefits of Repository Pattern:**
- Domain, Application, Presentation layers unchanged
- Only 1 line in DI provider changes
- Easy A/B testing between Phase 0 and Phase 1
- Seamless migration with zero downtime

---

## References

### Official Documentation
- [Kakao Developers - Flutter SDK](https://developers.kakao.com/docs/latest/ko/flutter/getting-started)
- [Kakao Login API Guide](https://developers.kakao.com/docs/latest/ko/kakaologin/flutter)
- [GoRouter Documentation](https://pub.dev/documentation/go_router/latest/)
- [Flutter Deep Linking](https://docs.flutter.dev/ui/navigation/deep-linking)

### Package Documentation
- [kakao_flutter_sdk_user on pub.dev](https://pub.dev/packages/kakao_flutter_sdk_user)
- [go_router on pub.dev](https://pub.dev/packages/go_router)
- [flutter_secure_storage on pub.dev](https://pub.dev/packages/flutter_secure_storage)

### Android-Specific
- [Android 13 Intent Filter Changes](https://medium.com/androiddevelopers/making-sense-of-intent-filters-in-android-13-8f6656903dde)
- [Chrome Custom Tabs Guide](https://developer.chrome.com/docs/android/custom-tabs)

### iOS-Specific
- [iOS Custom URL Schemes](https://developer.apple.com/documentation/xcode/defining-a-custom-url-scheme-for-your-app)
- [Universal Links Guide](https://developer.apple.com/ios/universal-links/)

---

## Production Checklist

Before going live:
- [ ] Release key hash registered in Kakao Console
- [ ] ProGuard/R8 rules tested in release build
- [ ] iOS App Store review prepared (explain social login usage)
- [ ] Privacy policy includes Kakao login data handling
- [ ] Error tracking set up (Firebase Crashlytics)
- [ ] Token refresh flow tested
- [ ] Network error handling implemented
- [ ] User logout flow tested
- [ ] Deep link fallback for unsupported scenarios
- [ ] Android App Bundle size verified (<20MB recommended)

---

## Additional Notes for Your GLP-1 App

### Integration with F-001 (소셜 로그인)

This implementation directly supports your F-001 feature requirements:

1. **Kakao Login** ✅ Implemented
2. **Naver Login** - Use same pattern, different SDK
3. **Token Storage** ✅ FlutterSecureStorage (Phase 0)
4. **User Profile** ✅ Domain entity ready for database storage

### Next Steps After Login

After successful login, user should proceed to:
1. **F000 (온보딩)** - Initial profile and medication plan setup
2. Store user profile in local Isar database
3. Generate initial DoseSchedule based on dosage plan
4. Navigate to F006 (홈 대시보드)

### Code Organization Alignment

This guide follows your exact folder structure:
- `features/authentication/` (matches code_structure.md)
- 4-Layer Architecture (Domain, Infrastructure, Application, Presentation)
- Repository Pattern for Phase transition
- Riverpod for state management

---

**End of Implementation Guide**

This guide provides everything needed to implement Kakao login with GoRouter in your Flutter app while maintaining architectural consistency with your existing codebase.