import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/features/authentication/presentation/screens/login_screen.dart';
import 'package:n06/features/dashboard/presentation/screens/home_dashboard_screen.dart';
import 'package:n06/features/settings/presentation/screens/settings_screen.dart';
import 'package:n06/features/profile/presentation/screens/profile_edit_screen.dart';
import 'package:n06/features/profile/presentation/screens/weekly_goal_settings_screen.dart';
import 'package:n06/features/tracking/presentation/screens/edit_dosage_plan_screen.dart';
import 'package:n06/features/notification/presentation/screens/notification_settings_screen.dart';
import 'package:n06/features/tracking/presentation/screens/emergency_check_screen.dart';
import 'package:n06/features/tracking/presentation/screens/weight_record_screen.dart';
import 'package:n06/features/tracking/presentation/screens/symptom_record_screen.dart';
import 'package:n06/features/coping_guide/presentation/screens/coping_guide_screen.dart';
import 'package:n06/features/data_sharing/presentation/screens/data_sharing_screen.dart';
import 'package:n06/features/onboarding/presentation/screens/onboarding_screen.dart';

/// GoRouter configuration for the application
final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    /// Authentication
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    /// Onboarding (F000)
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    /// Home/Dashboard (F006)
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeDashboardScreen(),
    ),

    /// Root path redirects to home
    GoRoute(
      path: '/',
      redirect: (context, state) => '/home',
    ),

    /// Settings (UF-SETTINGS / 009)
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),

    /// Profile Management (UF-008)
    GoRoute(
      path: '/profile/edit',
      name: 'profile_edit',
      builder: (context, state) => const ProfileEditScreen(),
    ),

    /// Dosage Plan Edit (UF-009)
    GoRoute(
      path: '/dose-plan/edit',
      name: 'dose_plan_edit',
      builder: (context, state) => const EditDosagePlanScreen(),
    ),

    /// Weekly Goal Settings (UF-013/015)
    GoRoute(
      path: '/weekly-goal/edit',
      name: 'weekly_goal_edit',
      builder: (context, state) => const WeeklyGoalSettingsScreen(),
    ),

    /// Notification Settings (UF-012)
    GoRoute(
      path: '/notification/settings',
      name: 'notification_settings',
      builder: (context, state) => const NotificationSettingsScreen(),
    ),

    /// Emergency Symptoms Check (UF-005)
    GoRoute(
      path: '/emergency/check',
      name: 'emergency_check',
      builder: (context, state) => const EmergencyCheckScreen(),
    ),

    /// Tracking - Weight Record (F002)
    GoRoute(
      path: '/tracking/weight',
      name: 'weight_record',
      builder: (context, state) => const WeightRecordScreen(),
    ),

    /// Tracking - Symptom Record (F002)
    GoRoute(
      path: '/tracking/symptom',
      name: 'symptom_record',
      builder: (context, state) => const SymptomRecordScreen(),
    ),

    /// Coping Guide (F004)
    GoRoute(
      path: '/coping-guide',
      name: 'coping_guide',
      builder: (context, state) => const CopingGuideScreen(),
    ),

    /// Data Sharing (F003)
    GoRoute(
      path: '/data-sharing',
      name: 'data_sharing',
      builder: (context, state) => const DataSharingScreen(),
    ),
  ],

  /// Error handling
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: Center(
      child: Text('Page not found: ${state.uri}'),
    ),
  ),
);
