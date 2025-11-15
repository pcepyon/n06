import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:isar/isar.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:n06/core/providers.dart';
import 'package:n06/core/routing/app_router.dart';
import 'package:n06/core/services/secure_storage_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:n06/features/authentication/infrastructure/dtos/consent_record_dto.dart';
import 'package:n06/features/authentication/infrastructure/dtos/user_dto.dart';
import 'package:n06/features/tracking/infrastructure/dtos/dosage_plan_dto.dart';
import 'package:n06/features/tracking/infrastructure/dtos/dose_schedule_dto.dart';
import 'package:n06/features/tracking/infrastructure/dtos/dose_record_dto.dart';
import 'package:n06/features/tracking/infrastructure/dtos/plan_change_history_dto.dart';
import 'package:n06/features/tracking/infrastructure/dtos/weight_log_dto.dart';
import 'package:n06/features/tracking/infrastructure/dtos/symptom_log_dto.dart';
import 'package:n06/features/tracking/infrastructure/dtos/symptom_context_tag_dto.dart';
import 'package:n06/features/tracking/infrastructure/dtos/emergency_symptom_check_dto.dart';
import 'package:n06/features/dashboard/infrastructure/dtos/user_badge_dto.dart';
import 'package:n06/features/dashboard/infrastructure/dtos/badge_definition_dto.dart';
import 'package:n06/features/onboarding/infrastructure/dtos/user_profile_dto.dart';
import 'package:n06/features/coping_guide/infrastructure/dtos/guide_feedback_dto.dart';
import 'package:n06/features/notification/infrastructure/dtos/notification_settings_dto.dart';

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
      _logError('Uncaught error in root zone', error, stackTrace);
    },
  );
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

    // Initialize Korean locale for DateFormat
    if (kDebugMode) {
      developer.log('🌐 Initializing Korean locale...', name: 'Main');
    }
    await initializeDateFormatting('ko_KR', null);

    // Initialize Isar with all required collection schemas
    if (kDebugMode) {
      developer.log('💾 Opening Isar database...', name: 'Main');
    }
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [
        UserDtoSchema,
        ConsentRecordDtoSchema,
        DosagePlanDtoSchema,
        DoseScheduleDtoSchema,
        DoseRecordDtoSchema,
        PlanChangeHistoryDtoSchema,
        WeightLogDtoSchema,
        SymptomLogDtoSchema,
        SymptomContextTagDtoSchema,
        EmergencySymptomCheckDtoSchema,
        UserBadgeDtoSchema,
        BadgeDefinitionDtoSchema,
        UserProfileDtoSchema,
        GuideFeedbackDtoSchema,
        NotificationSettingsDtoSchema,
      ],
      directory: dir.path,
      inspector: true,
    );

    if (kDebugMode) {
      developer.log('✅ Isar database initialized', name: 'Main');
      developer.log('🎯 Launching app...', name: 'Main');
    }

    runApp(
      ProviderScope(
        observers: kDebugMode ? [_ProviderLogger()] : null,
        overrides: [
          // Override isarProvider with initialized instance
          isarProvider.overrideWithValue(isar),
          // authRepositoryProvider는 providers.dart에서 자동으로 Supabase 사용
          // Phase 1.3: override 제거 (기본 SupabaseAuthRepository 사용)
        ],
        child: const MyApp(),
      ),
    );
  } catch (error, stackTrace) {
    _logError('Initialization error', error, stackTrace);
    rethrow;
  }
}

// Riverpod logger for debugging
class _ProviderLogger extends ProviderObserver {
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
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
    return MaterialApp.router(
      title: 'GLP-1 치료 관리',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
