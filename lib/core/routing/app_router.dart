import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/core/presentation/widgets/scaffold_with_bottom_nav.dart';
import 'package:n06/features/authentication/presentation/screens/login_screen.dart';
import 'package:n06/features/dashboard/presentation/screens/home_dashboard_screen.dart';
import 'package:n06/features/settings/presentation/screens/settings_screen.dart';
import 'package:n06/features/profile/presentation/screens/profile_edit_screen.dart';
import 'package:n06/features/profile/presentation/screens/weekly_goal_settings_screen.dart';
import 'package:n06/features/tracking/presentation/screens/edit_dosage_plan_screen.dart';
import 'package:n06/features/tracking/presentation/screens/dose_calendar_screen.dart';
import 'package:n06/features/notification/presentation/screens/notification_settings_screen.dart';
import 'package:n06/features/tracking/presentation/screens/emergency_check_screen.dart';
import 'package:n06/features/coping_guide/presentation/screens/coping_guide_screen.dart';
import 'package:n06/features/data_sharing/presentation/screens/data_sharing_screen.dart';
import 'package:n06/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:n06/features/record_management/presentation/screens/record_list_screen.dart';
import 'package:n06/features/authentication/presentation/screens/email_signup_screen.dart';
import 'package:n06/features/authentication/presentation/screens/email_signin_screen.dart';
import 'package:n06/features/authentication/presentation/screens/password_reset_screen.dart';
import 'package:n06/features/tracking/presentation/screens/trend_dashboard_screen.dart';
import 'package:n06/features/daily_checkin/presentation/screens/daily_checkin_screen.dart';
import 'package:n06/features/daily_checkin/presentation/screens/share_report_screen.dart';

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
    /// Authentication routes (without Bottom Nav)
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: '/email-signup',
      name: 'email_signup',
      builder: (context, state) {
        final prefillEmail = state.extra as String?;
        return EmailSignupScreen(prefillEmail: prefillEmail);
      },
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

    /// Onboarding (F000) - without Bottom Nav
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) {
        final userId = state.extra as String?;
        return OnboardingScreen(
          userId: userId,
          onComplete: () => context.go('/home'),
        );
      },
    ),

    /// Onboarding Review (다시 보기) - without Bottom Nav
    GoRoute(
      path: '/onboarding/review',
      name: 'onboarding_review',
      builder: (context, state) {
        return OnboardingScreen(
          isReviewMode: true,
          onComplete: () => context.pop(),
        );
      },
    ),

    /// Root path redirects to home
    GoRoute(
      path: '/',
      redirect: (context, state) => '/home',
    ),

    /// Main app routes with Bottom Navigation (using ShellRoute)
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithBottomNav(child: child);
      },
      routes: [
        /// Home/Dashboard (F006)
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeDashboardScreen(),
        ),

        /// Daily Check-in (F007) - 데일리 체크인 (체중 + 6개 질문)
        GoRoute(
          path: '/daily-checkin',
          name: 'daily_checkin',
          builder: (context, state) => const DailyCheckinScreen(),
        ),

        /// Dose Schedule Management (003)
        GoRoute(
          path: '/dose-schedule',
          name: 'dose_schedule',
          builder: (context, state) => const DoseCalendarScreen(),
        ),

        /// Coping Guide (F004)
        GoRoute(
          path: '/coping-guide',
          name: 'coping_guide',
          builder: (context, state) => const CopingGuideScreen(),
        ),

        /// Settings (UF-SETTINGS / 009)
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),

    /// Detail routes without Bottom Nav
    GoRoute(
      path: '/data-sharing',
      name: 'data_sharing',
      builder: (context, state) => const DataSharingScreen(),
    ),

    GoRoute(
      path: '/profile/edit',
      name: 'profile_edit',
      builder: (context, state) => const ProfileEditScreen(),
    ),

    GoRoute(
      path: '/dose-plan/edit',
      name: 'dose_plan_edit',
      builder: (context, state) => const EditDosagePlanScreen(),
    ),

    GoRoute(
      path: '/weekly-goal/edit',
      name: 'weekly_goal_edit',
      builder: (context, state) => const WeeklyGoalSettingsScreen(),
    ),

    GoRoute(
      path: '/notification/settings',
      name: 'notification_settings',
      builder: (context, state) => const NotificationSettingsScreen(),
    ),

    GoRoute(
      path: '/emergency/check',
      name: 'emergency_check',
      builder: (context, state) => const EmergencyCheckScreen(),
    ),

    GoRoute(
      path: '/records',
      name: 'record_list',
      builder: (context, state) => const RecordListScreen(),
    ),

    GoRoute(
      path: '/trend-dashboard',
      name: 'trend_dashboard',
      builder: (context, state) => const TrendDashboardScreen(),
    ),

    /// Legacy redirect: /tracking/daily → /daily-checkin
    GoRoute(
      path: '/tracking/daily',
      redirect: (context, state) => '/daily-checkin',
    ),

    /// Share Report (주간 리포트 공유)
    GoRoute(
      path: '/share-report',
      name: 'share_report',
      builder: (context, state) => const ShareReportScreen(),
    ),
  ],
);