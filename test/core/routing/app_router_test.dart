import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/core/routing/app_router.dart' show appRouter;

void main() {
  group('GoRouter Navigation Tests', () {
    test('TC-GR-01: should start at login route', () {
      // Arrange
      final router = appRouter;
      final namedRoutes = _extractNamedRoutes(router);

      // Act
      final hasLoginRoute = namedRoutes.containsKey('login');

      // Assert
      expect(
        hasLoginRoute,
        isTrue,
        reason: 'Initial route should be /login',
      );
    });

    test('TC-GR-02: should have /settings route available', () {
      // Arrange
      final router = appRouter;
      final namedRoutes = _extractNamedRoutes(router);

      // Act
      final hasSettingsRoute = namedRoutes.containsKey('settings');

      // Assert
      expect(
        hasSettingsRoute,
        isTrue,
        reason: 'Should be able to navigate to /settings',
      );
    });

    test('TC-GR-03: should have /profile/edit route available', () {
      // Arrange
      final router = appRouter;
      final namedRoutes = _extractNamedRoutes(router);

      // Act
      final hasProfileRoute = namedRoutes.containsKey('profile_edit');

      // Assert
      expect(
        hasProfileRoute,
        isTrue,
        reason: 'Should be able to navigate to /profile/edit',
      );
    });

    test('TC-GR-04: should have /dose-plan/edit route available', () {
      // Arrange
      final router = appRouter;
      final namedRoutes = _extractNamedRoutes(router);

      // Act
      final hasDosePlanRoute = namedRoutes.containsKey('dose_plan_edit');

      // Assert
      expect(
        hasDosePlanRoute,
        isTrue,
        reason: 'Should be able to navigate to /dose-plan/edit',
      );
    });

    test('TC-GR-05: should have /weekly-goal/edit route available', () {
      // Arrange
      final router = appRouter;
      final namedRoutes = _extractNamedRoutes(router);

      // Act
      final hasWeeklyGoalRoute = namedRoutes.containsKey('weekly_goal_edit');

      // Assert
      expect(
        hasWeeklyGoalRoute,
        isTrue,
        reason: 'Should be able to navigate to /weekly-goal/edit',
      );
    });

    test('TC-GR-06: should have /notification/settings route available', () {
      // Arrange
      final router = appRouter;
      final namedRoutes = _extractNamedRoutes(router);

      // Act
      final hasNotificationRoute = namedRoutes.containsKey('notification_settings');

      // Assert
      expect(
        hasNotificationRoute,
        isTrue,
        reason: 'Should be able to navigate to /notification/settings',
      );
    });

    test('TC-GR-07: should have /emergency/check route available', () {
      // Arrange
      final router = appRouter;
      final namedRoutes = _extractNamedRoutes(router);

      // Act
      final hasEmergencyRoute = namedRoutes.containsKey('emergency_check');

      // Assert
      expect(
        hasEmergencyRoute,
        isTrue,
        reason: 'Should be able to navigate to /emergency/check',
      );
    });

    test('TC-GR-08: should have /tracking/weight route available', () {
      // Arrange
      final router = appRouter;
      final namedRoutes = _extractNamedRoutes(router);

      // Act
      final hasWeightRoute = namedRoutes.containsKey('weight_record');

      // Assert
      expect(
        hasWeightRoute,
        isTrue,
        reason: 'Should be able to navigate to /tracking/weight',
      );
    });

    test('TC-GR-09: should have /tracking/symptom route available', () {
      // Arrange
      final router = appRouter;
      final namedRoutes = _extractNamedRoutes(router);

      // Act
      final hasSymptomRoute = namedRoutes.containsKey('symptom_record');

      // Assert
      expect(
        hasSymptomRoute,
        isTrue,
        reason: 'Should be able to navigate to /tracking/symptom',
      );
    });

    test('TC-GR-10: should have /coping-guide route available', () {
      // Arrange
      final router = appRouter;
      final namedRoutes = _extractNamedRoutes(router);

      // Act
      final hasCopingGuideRoute = namedRoutes.containsKey('coping_guide');

      // Assert
      expect(
        hasCopingGuideRoute,
        isTrue,
        reason: 'Should be able to navigate to /coping-guide',
      );
    });

    test('TC-GR-11: should have /data-sharing route available', () {
      // Arrange
      final router = appRouter;
      final namedRoutes = _extractNamedRoutes(router);

      // Act
      final hasDataSharingRoute = namedRoutes.containsKey('data_sharing');

      // Assert
      expect(
        hasDataSharingRoute,
        isTrue,
        reason: 'Should be able to navigate to /data-sharing',
      );
    });

    test('TC-GR-12: should have /home route available', () {
      // Arrange
      final router = appRouter;
      final namedRoutes = _extractNamedRoutes(router);

      // Act
      final hasHomeRoute = namedRoutes.containsKey('home');

      // Assert
      expect(
        hasHomeRoute,
        isTrue,
        reason: 'Should have /home route available',
      );
    });

    test('TC-GR-13: should have all expected routes configured', () {
      // Arrange
      final router = appRouter;
      final namedRoutes = _extractNamedRoutes(router);
      final expectedRoutes = [
        'login',
        'settings',
        'profile_edit',
        'dose_plan_edit',
        'weekly_goal_edit',
        'notification_settings',
        'emergency_check',
        'weight_record',
        'symptom_record',
        'coping_guide',
        'data_sharing',
        'home',
        'onboarding',
      ];

      // Act
      final missingRoutes = expectedRoutes
          .where((route) => !namedRoutes.containsKey(route))
          .toList();

      // Assert
      expect(
        missingRoutes,
        isEmpty,
        reason: 'All expected routes should be configured',
      );
    });
  });

  group('GoRouter Route Configuration Tests', () {
    test('should have login route defined', () {
      // Arrange
      final router = appRouter;
      final namedRoutes = _extractNamedRoutes(router);

      // Act
      final hasLoginRoute = namedRoutes.containsKey('login');

      // Assert
      expect(hasLoginRoute, isTrue, reason: 'Login route should be defined');
    });

    test('should have settings route defined', () {
      // Arrange
      final router = appRouter;
      final namedRoutes = _extractNamedRoutes(router);

      // Act
      final hasSettingsRoute = namedRoutes.containsKey('settings');

      // Assert
      expect(hasSettingsRoute, isTrue, reason: 'Settings route should be defined');
    });

    test('should have profile edit route defined', () {
      // Arrange
      final router = appRouter;
      final namedRoutes = _extractNamedRoutes(router);

      // Act
      final hasProfileRoute = namedRoutes.containsKey('profile_edit');

      // Assert
      expect(hasProfileRoute, isTrue, reason: 'Profile edit route should be defined');
    });

    test('should have dose plan edit route defined', () {
      // Arrange
      final router = appRouter;
      final namedRoutes = _extractNamedRoutes(router);

      // Act
      final hasDosePlanRoute = namedRoutes.containsKey('dose_plan_edit');

      // Assert
      expect(hasDosePlanRoute, isTrue, reason: 'Dose plan edit route should be defined');
    });

    test('should have weekly goal edit route defined', () {
      // Arrange
      final router = appRouter;
      final namedRoutes = _extractNamedRoutes(router);

      // Act
      final hasWeeklyGoalRoute = namedRoutes.containsKey('weekly_goal_edit');

      // Assert
      expect(hasWeeklyGoalRoute, isTrue, reason: 'Weekly goal edit route should be defined');
    });

    test('should have notification settings route defined', () {
      // Arrange
      final router = appRouter;
      final namedRoutes = _extractNamedRoutes(router);

      // Act
      final hasNotificationRoute = namedRoutes.containsKey('notification_settings');

      // Assert
      expect(hasNotificationRoute, isTrue, reason: 'Notification settings route should be defined');
    });

    test('should have emergency check route defined', () {
      // Arrange
      final router = appRouter;
      final namedRoutes = _extractNamedRoutes(router);

      // Act
      final hasEmergencyRoute = namedRoutes.containsKey('emergency_check');

      // Assert
      expect(hasEmergencyRoute, isTrue, reason: 'Emergency check route should be defined');
    });

    test('should have weight record route defined', () {
      // Arrange
      final router = appRouter;
      final namedRoutes = _extractNamedRoutes(router);

      // Act
      final hasWeightRoute = namedRoutes.containsKey('weight_record');

      // Assert
      expect(hasWeightRoute, isTrue, reason: 'Weight record route should be defined');
    });

    test('should have symptom record route defined', () {
      // Arrange
      final router = appRouter;
      final namedRoutes = _extractNamedRoutes(router);

      // Act
      final hasSymptomRoute = namedRoutes.containsKey('symptom_record');

      // Assert
      expect(hasSymptomRoute, isTrue, reason: 'Symptom record route should be defined');
    });

    test('should have coping guide route defined', () {
      // Arrange
      final router = appRouter;
      final namedRoutes = _extractNamedRoutes(router);

      // Act
      final hasCopingGuideRoute = namedRoutes.containsKey('coping_guide');

      // Assert
      expect(hasCopingGuideRoute, isTrue, reason: 'Coping guide route should be defined');
    });

    test('should have data sharing route defined', () {
      // Arrange
      final router = appRouter;
      final namedRoutes = _extractNamedRoutes(router);

      // Act
      final hasDataSharingRoute = namedRoutes.containsKey('data_sharing');

      // Assert
      expect(hasDataSharingRoute, isTrue, reason: 'Data sharing route should be defined');
    });

    test('should have home route defined', () {
      // Arrange
      final router = appRouter;
      final namedRoutes = _extractNamedRoutes(router);

      // Act
      final hasHomeRoute = namedRoutes.containsKey('home');

      // Assert
      expect(hasHomeRoute, isTrue, reason: 'Home route should be defined');
    });

    test('should have onboarding route defined', () {
      // Arrange
      final router = appRouter;
      final namedRoutes = _extractNamedRoutes(router);

      // Act
      final hasOnboardingRoute = namedRoutes.containsKey('onboarding');

      // Assert
      expect(hasOnboardingRoute, isTrue, reason: 'Onboarding route should be defined');
    });
  });
}

/// Helper function to extract named routes from GoRouter configuration
Map<String, String> _extractNamedRoutes(GoRouter router) {
  final routes = <String, String>{};

  void extractFromRouteBase(RouteBase route) {
    if (route is GoRoute && route.name != null) {
      routes[route.name!] = route.path;
    }

    // Handle ShellRoute - recursively extract child routes
    if (route is ShellRoute) {
      for (final childRoute in route.routes) {
        extractFromRouteBase(childRoute);
      }
    }

    // Handle nested GoRoute routes
    if (route is GoRoute && route.routes.isNotEmpty) {
      for (final childRoute in route.routes) {
        extractFromRouteBase(childRoute);
      }
    }
  }

  for (final route in router.configuration.routes) {
    extractFromRouteBase(route);
  }

  return routes;
}
