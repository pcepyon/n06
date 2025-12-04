import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n06/core/presentation/theme/app_theme.dart';
import 'package:n06/core/routing/app_router.dart';
import 'package:n06/core/providers/shared_preferences_provider.dart';
import 'package:n06/l10n/generated/app_localizations.dart';
import 'package:n06/features/settings/application/notifiers/locale_notifier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';

/// Global ScaffoldMessengerKey for displaying SnackBars above Dialogs/BottomSheets
/// This solves the z-index issue where SnackBars were hidden behind overlays
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  // Run app in error zone to catch all errors
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Setup error handlers
      _setupErrorHandlers();

      await _initializeAndRunApp();
    },
    (error, stackTrace) {
      // BUG-20251205: Supabase SDK의 자동 세션 복구 시 오프라인 에러 무시
      //
      // Supabase.initialize() → recoverSession() → refreshAccessToken()
      // 오프라인 상태에서 AuthRetryableFetchException 발생
      // 이 에러는 치명적이지 않음 (앱은 정상 작동, 로그인 화면으로 이동)
      if (_isSupabaseNetworkError(error)) {
        if (kDebugMode) {
          developer.log(
            '⚠️ Supabase network error (offline) - ignoring: ${error.runtimeType}',
            name: 'ErrorHandler',
          );
        }
        return; // 에러 무시
      }

      _logError('Uncaught error in root zone', error, stackTrace);
      // Send to Crashlytics in release mode
      if (!kDebugMode) {
        FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
      }
    },
  );
}

/// BUG-20251205: Supabase 오프라인 네트워크 에러 판별
///
/// Supabase SDK의 자동 세션 복구(recoverSession) 시 오프라인 상태에서
/// 발생하는 AuthRetryableFetchException을 감지합니다.
///
/// 이 에러는:
/// - 치명적이지 않음 (앱 정상 작동)
/// - 사용자에게 알릴 필요 없음 (로그인 화면으로 자동 이동)
/// - Crashlytics에 보낼 필요 없음 (네트워크 상태 문제)
bool _isSupabaseNetworkError(Object error) {
  final errorString = error.toString();
  // AuthRetryableFetchException with network errors
  return errorString.contains('AuthRetryableFetchException') &&
      (errorString.contains('SocketException') ||
          errorString.contains('Failed host lookup') ||
          errorString.contains('No address associated with hostname'));
}

void _setupErrorHandlers() {
  // Catch Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    // Check if this is a Kakao OAuth callback GoRouter parsing error
    final exception = details.exception;
    if (exception is StateError &&
        exception.message.contains('Origin is only applicable to schemes http and https')) {
      // This is expected - Kakao SDK handles the callback, not GoRouter
      debugPrint('🔍 [HEALTH CHECK] Kakao GoRouter parsing error (expected, ignoring)');
      if (kDebugMode) {
        developer.log(
          '🔍 Kakao OAuth callback caused GoRouter parsing error (expected behavior)',
          name: 'HealthCheck',
        );
      }
      // Don't present this error to user
      return;
    }

    FlutterError.presentError(details);
    _logError(
      'Flutter Error',
      details.exception,
      details.stack,
      context: details.context?.toString(),
    );
  };

  // Catch platform errors
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    _logError('Platform Error', error, stackTrace);
    return true;
  };

  if (kDebugMode) {
    developer.log(
      '🔧 Error handlers initialized',
      name: 'ErrorHandler',
    );
  }
}

void _logError(
  String title,
  Object error,
  StackTrace? stackTrace, {
  String? context,
}) {
  final message = StringBuffer();
  message.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  message.writeln('🚨 $title');
  message.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  if (context != null) {
    message.writeln('Context: $context');
  }
  message.writeln('Error: $error');
  if (stackTrace != null) {
    message.writeln('StackTrace:\n$stackTrace');
  }
  message.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  if (kDebugMode) {
    // Use developer.log for better visibility in DevTools
    developer.log(
      message.toString(),
      name: 'Error',
      error: error,
      stackTrace: stackTrace,
      level: 1000, // Error level
    );
  }

  // Also print to console
  debugPrint(message.toString());
}

Future<void> _initializeAndRunApp() async {
  if (kDebugMode) {
    developer.log('🚀 Initializing app...', name: 'Main');
  }

  try {
    // Load environment variables
    if (kDebugMode) {
      developer.log('📄 Loading environment variables...', name: 'Main');
    }
    await dotenv.load(fileName: ".env");

    // Initialize Firebase
    if (kDebugMode) {
      developer.log('🔥 Initializing Firebase...', name: 'Main');
    }
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Configure Crashlytics
    if (kDebugMode) {
      // Disable Crashlytics in debug mode to avoid noise
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
      developer.log('🔥 Crashlytics disabled in debug mode', name: 'Main');
    } else {
      // Enable Crashlytics in release mode
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      // Pass Flutter errors to Crashlytics
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    }

    // Initialize Supabase
    if (kDebugMode) {
      developer.log('☁️ Initializing Supabase...', name: 'Main');
    }
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );

    // Initialize Kakao SDK with debug logging enabled
    if (kDebugMode) {
      developer.log('📱 Initializing Kakao SDK with debug logging...', name: 'Main');
    }
    KakaoSdk.init(
      nativeAppKey: '32dfc3999b53af153dbcefa7014093bc',
      loggingEnabled: true,  // Enable detailed debug logging
    );

    // Initialize locales for DateFormat
    if (kDebugMode) {
      developer.log('🌐 Initializing locales...', name: 'Main');
    }
    await initializeDateFormatting('ko_KR', null);
    await initializeDateFormatting('en_US', null);

    // Initialize SharedPreferences
    if (kDebugMode) {
      developer.log('💾 Initializing SharedPreferences...', name: 'Main');
    }
    final sharedPreferences = await SharedPreferences.getInstance();

    if (kDebugMode) {
      developer.log('🎯 Launching app...', name: 'Main');
    }

    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        observers: kDebugMode ? [_ProviderLogger()] : null,
        child: const MyApp(),
      ),
    );
  } catch (error, stackTrace) {
    _logError('Initialization error', error, stackTrace);
    rethrow;
  }
}

// Riverpod logger for debugging
final class _ProviderLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    developer.log(
      '${context.provider.name ?? context.provider.runtimeType} updated: $newValue',
      name: 'Riverpod',
    );
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    _logError(
      'Provider Error: ${context.provider.name ?? context.provider.runtimeType}',
      error,
      stackTrace,
    );
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Register as observer to intercept deep links
    WidgetsBinding.instance.addObserver(this);

    // Use debugPrint to ensure visibility
    debugPrint('🔗 Deep link observer registered');
    if (kDebugMode) {
      developer.log('🔗 Deep link observer registered', name: 'MyApp');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) async {
    final uri = routeInformation.uri;

    // Detect Kakao OAuth callbacks and handle them
    if (uri.scheme.startsWith('kakao')) {
      debugPrint('✅ Intercepting Kakao OAuth callback: $uri');
      debugPrint('   Blocking GoRouter and allowing Kakao SDK to handle it');
      if (kDebugMode) {
        developer.log(
          '✅ Kakao OAuth callback intercepted - blocking GoRouter',
          name: 'MyApp',
        );
      }

      // Return true to indicate we've handled it and prevent GoRouter from processing
      // The Kakao SDK will still receive it through the native platform channel
      return true;
    }

    // Let other routes be handled normally
    debugPrint('📍 Allowing route: $uri');
    return await super.didPushRouteInformation(routeInformation);
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'GLP-1 치료 관리',
      theme: AppTheme.lightTheme.copyWith(
        extensions: [AppThemeExtension.light],
      ),
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      routerConfig: appRouter,
      // L10n Configuration
      localizationsDelegates: const [
        L10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: L10n.supportedLocales,
      locale: locale, // null = system default
      localeResolutionCallback: (locale, supportedLocales) {
        // Fallback to Korean if locale is not supported
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return const Locale('ko');
      },
    );
  }
}
