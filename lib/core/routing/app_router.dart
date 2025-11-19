import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/features/authentication/presentation/screens/login_screen.dart';
import 'package:n06/features/dashboard/presentation/screens/home_dashboard_screen.dart';
import 'package:n06/features/settings/presentation/screens/settings_screen.dart';
import 'package:n06/features/profile/presentation/screens/profile_edit_screen.dart';
import 'package:n06/features/profile/presentation/screens/weekly_goal_settings_screen.dart';
import 'package:n06/features/tracking/presentation/screens/edit_dosage_plan_screen.dart';
import 'package:n06/features/tracking/presentation/screens/dose_schedule_screen.dart';
import 'package:n06/features/notification/presentation/screens/notification_settings_screen.dart';
import 'package:n06/features/tracking/presentation/screens/emergency_check_screen.dart';
import 'package:n06/features/tracking/presentation/screens/weight_record_screen.dart';
import 'package:n06/features/tracking/presentation/screens/symptom_record_screen.dart';
import 'package:n06/features/coping_guide/presentation/screens/coping_guide_screen.dart';
import 'package:n06/features/data_sharing/presentation/screens/data_sharing_screen.dart';
import 'package:n06/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:n06/features/record_management/presentation/screens/record_list_screen.dart';
import 'package:n06/features/authentication/presentation/screens/email_signup_screen.dart';
import 'package:n06/features/authentication/presentation/screens/email_signin_screen.dart';
import 'package:n06/features/authentication/presentation/screens/password_reset_screen.dart';

/// GoRouter configuration for the application
final appRouter = GoRouter(
  initialLocation: '/login',
  // Handle errors from Kakao OAuth callbacks gracefully
  onException: (context, state, router) {
    final uri = state.uri;
    if (kDebugMode) {
      developer.log('GoRouter exception for: $uri', name: 'AppRouter');
    }

    // If it's a Kakao OAuth callback error, just ignore it
    // The Kakao SDK will handle the callback
    if (uri.scheme.startsWith('kakao')) {
      if (kDebugMode) {
        developer.log('Ignoring Kakao OAuth callback error in GoRouter', name: 'AppRouter');
      }
      return; // Don't navigate anywhere
    }

    // For other errors, go to login
    router.go('/login');
  },
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
      builder: (context, state) {
        final userId = state.extra as String?;
        return OnboardingScreen(userId: userId);
      },
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

    /// Dose Schedule Management (003)
    GoRoute(
      path: '/dose-schedule',
      name: 'dose_schedule',
      builder: (context, state) => const DoseScheduleScreen(),
    ),

    /// Record Management (013)
    GoRoute(
      path: '/records',
      name: 'record_list',
      builder: (context, state) => const RecordListScreen(),
    ),

    /// Email Authentication (F-016)
    GoRoute(
      path: '/email-signup',
      name: 'email_signup',
      builder: (context, state) => const EmailSignupScreen(),
    ),

    GoRoute(
      path: '/email-signin',
      name: 'email_signin',
      builder: (context, state) => const EmailSigninScreen(),
    ),

    GoRoute(
      path: '/password-reset',
      name: 'password_reset',
      builder: (context, state) {
        final token = state.uri.queryParameters['token'];
        return PasswordResetScreen(token: token);
      },
    ),

    /// Deep Link: Password reset from email
    GoRoute(
      path: '/reset-password',
      builder: (context, state) {
        final token = state.uri.queryParameters['token'];
        final type = state.uri.queryParameters['type'];
        if (kDebugMode) {
          developer.log(
            'Deep link received: /reset-password (token: $token, type: $type)',
            name: 'AppRouter',
          );
        }
        return PasswordResetScreen(token: token);
      },
    ),

    /// Deep Link: Email confirmation (P1)
    GoRoute(
      path: '/email-confirmation',
      builder: (context, state) {
        final token = state.uri.queryParameters['token'];
        if (kDebugMode) {
          developer.log(
            'Deep link received: /email-confirmation (token: $token)',
            name: 'AppRouter',
          );
        }
        // TODO: Implement EmailConfirmationScreen (P1)
        return const Scaffold(
          body: Center(child: Text('Email Confirmation')),
        );
      },
    ),
  ],
);