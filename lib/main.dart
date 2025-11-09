import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:n06/core/providers.dart';
import 'package:n06/core/routing/app_router.dart';
import 'package:n06/core/services/secure_storage_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/authentication/infrastructure/datasources/kakao_auth_datasource.dart';
import 'package:n06/features/authentication/infrastructure/datasources/naver_auth_datasource.dart';
import 'package:n06/features/authentication/infrastructure/dtos/consent_record_dto.dart';
import 'package:n06/features/authentication/infrastructure/dtos/user_dto.dart';
import 'package:n06/features/authentication/infrastructure/repositories/isar_auth_repository.dart';
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
    // Initialize Kakao SDK
    if (kDebugMode) {
      developer.log('📱 Initializing Kakao SDK...', name: 'Main');
    }
    KakaoSdk.init(nativeAppKey: '32dfc3999b53af153dbcefa7014093bc');

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
          // Override authRepositoryProvider with IsarAuthRepository
          authRepositoryProvider.overrideWithValue(
            IsarAuthRepository(
              isar,
              KakaoAuthDataSource(),
              NaverAuthDataSource(),
              SecureStorageService(),
            ),
          ),
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
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    developer.log(
      '${provider.name ?? provider.runtimeType} updated: $newValue',
      name: 'Riverpod',
    );
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    _logError(
      'Provider Error: ${provider.name ?? provider.runtimeType}',
      error,
      stackTrace,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
