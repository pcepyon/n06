import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:n06/core/providers.dart';
import 'package:n06/core/routing/app_router.dart';
import 'package:n06/core/services/secure_storage_service.dart';
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
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Kakao SDK
  // Replace with your actual Kakao Native App Key
  KakaoSdk.init(nativeAppKey: 'YOUR_KAKAO_NATIVE_APP_KEY');

  // Initialize Isar with all required collection schemas
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
    directory: '', // Will use default directory
    inspector: true,
  );

  runApp(
    ProviderScope(
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
