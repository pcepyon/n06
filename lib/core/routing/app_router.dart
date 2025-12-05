import 'dart:async';
import 'dart:developer' as developer;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
import 'package:n06/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:n06/features/record_management/presentation/screens/record_list_screen.dart';
import 'package:n06/features/authentication/presentation/screens/email_signup_screen.dart';
import 'package:n06/features/authentication/presentation/screens/email_signin_screen.dart';
import 'package:n06/features/authentication/presentation/screens/password_reset_screen.dart';
import 'package:n06/features/tracking/presentation/screens/trend_dashboard_screen.dart';
import 'package:n06/features/daily_checkin/presentation/screens/daily_checkin_screen.dart';
import 'package:n06/features/daily_checkin/presentation/screens/share_report_screen.dart';
import 'package:n06/features/guest_home/presentation/screens/guest_home_screen.dart';

/// Listenable that notifies when auth state changes
/// Used by GoRouter to re-evaluate redirect logic
class GoRouterAuthRefreshStream extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  GoRouterAuthRefreshStream() {
    _subscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (AuthState data) {
        if (kDebugMode) {
          developer.log(
            'Auth state changed: ${data.event}, notifying GoRouter',
            name: 'GoRouterAuthRefreshStream',
          );
        }
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Routes that don't require authentication
const _publicRoutes = <String>{
  '/guest',
  '/login',
  '/sign-up',
  '/email-signup',
  '/email-signin',
  '/password-reset',
  '/reset-password',
  '/email-confirmation',
};

/// Check if a route requires authentication
bool _isProtectedRoute(String location) {
  // Check exact match first
  if (_publicRoutes.contains(location)) {
    return false;
  }

  // Check prefix match (for routes with query params)
  for (final publicRoute in _publicRoutes) {
    if (location.startsWith('$publicRoute?') || location.startsWith('$publicRoute/')) {
      return false;
    }
  }

  return true;
}

/// Auth refresh stream instance (singleton)
final _authRefreshStream = GoRouterAuthRefreshStream();

/// BUG-20251205: 세션 만료 여부를 직접 계산
///
/// Supabase SDK의 session.isExpired는 expiresAt이 null이면 true를 반환하지만,
/// 새로 생성된 세션은 expiresAt이 아직 설정되지 않았을 수 있습니다.
/// 따라서 null인 경우는 유효한 것으로 간주합니다.
bool _isSessionExpired(Session? session) {
  if (session == null) return false;

  final expiresAt = session.expiresAt;
  // expiresAt이 null이면 유효한 것으로 간주 (새 세션일 수 있음)
  if (expiresAt == null) return false;

  final expiryDateTime = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
  return DateTime.now().isAfter(expiryDateTime);
}

/// Firebase Analytics observer for screen tracking
final _analyticsObserver = FirebaseAnalyticsObserver(
  analytics: FirebaseAnalytics.instance,
  nameExtractor: (settings) {
    // Extract clean screen name from route
    // e.g., '/home' → 'home', '/profile/edit' → 'profile_edit'
    final name = settings.name;
    if (name != null && name.isNotEmpty) {
      return name.replaceAll('/', '_').replaceAll('-', '_');
    }
    return 'unknown';
  },
);

/// GoRouter configuration for the application
final appRouter = GoRouter(
  initialLocation: '/guest',
  refreshListenable: _authRefreshStream,
  observers: [_analyticsObserver],
  redirect: (BuildContext context, GoRouterState state) {
    final session = Supabase.instance.client.auth.currentSession;
    final location = state.uri.path;

    // BUG-20251205: 세션 유효성 판단 로직 개선
    //
    // 문제: session.isExpired가 너무 엄격하여 정상 로그인 플로우도 방해
    // - expiresAt이 null이면 만료로 판단 (새 세션에서 문제)
    //
    // 해결: 세션이 "확실히" 만료된 경우에만 로그인되지 않은 것으로 처리
    // - expiresAt이 null → 유효한 것으로 간주 (새 세션)
    // - expiresAt이 과거 시간 → 만료된 것으로 처리
    final isExpired = _isSessionExpired(session);
    final isLoggedIn = session != null && !isExpired;

    if (kDebugMode) {
      developer.log(
        'Router redirect check: location=$location, isLoggedIn=$isLoggedIn, '
        'sessionExists=${session != null}, isExpired=$isExpired, expiresAt=${session?.expiresAt}',
        name: 'AppRouter',
      );
    }

    // Case 1: Not logged in (or session expired), trying to access protected route
    if (!isLoggedIn && _isProtectedRoute(location)) {
      if (kDebugMode) {
        developer.log(
          'Redirecting to /guest: not authenticated or session expired',
          name: 'AppRouter',
        );
      }
      return '/guest';
    }

    // Case 2: Logged in with valid session, on guest/login page → redirect to home
    // This handles the case where user opens app while already logged in
    // Exception: Allow preview mode for "앱 소개 다시보기" feature
    final isPreviewMode = state.uri.queryParameters['preview'] == 'true';
    if (isLoggedIn && (location == '/guest' || location == '/login')) {
      if (location == '/guest' && isPreviewMode) {
        // Allow logged-in users to view guest home in preview mode
        return null;
      }
      if (kDebugMode) {
        developer.log(
          'Redirecting to /home: already authenticated with valid session',
          name: 'AppRouter',
        );
      }
      return '/home';
    }

    // No redirect needed
    return null;
  },
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
    /// Guest Home (for non-logged-in users, app store review)
    GoRoute(
      path: '/guest',
      name: 'guest',
      builder: (context, state) => const GuestHomeScreen(),
    ),

    /// Authentication routes (without Bottom Nav)
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    /// Sign-up redirect (from guest home CTA)
    GoRoute(
      path: '/sign-up',
      name: 'sign_up',
      redirect: (context, state) => '/email-signup',
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

        /// Trend Dashboard (트렌드 대시보드)
        GoRoute(
          path: '/trend-dashboard',
          name: 'trend_dashboard',
          builder: (context, state) => const TrendDashboardScreen(),
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
      path: '/profile/edit',
      name: 'profile_edit',
      builder: (context, state) => const ProfileEditScreen(),
    ),

    GoRoute(
      path: '/dose-plan/edit',
      name: 'dose_plan_edit',
      builder: (context, state) {
        final isRestart = state.uri.queryParameters['restart'] == 'true';
        return EditDosagePlanScreen(isRestart: isRestart);
      },
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

    /// Coping Guide (F004) - without Bottom Nav
    GoRoute(
      path: '/coping-guide',
      name: 'coping_guide',
      builder: (context, state) => const CopingGuideScreen(),
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
