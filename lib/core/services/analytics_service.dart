import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

/// Analytics and Crashlytics service for monitoring app usage and errors.
///
/// This service respects App Tracking Transparency (ATT) on iOS.
/// Analytics collection is enabled only after user consent.
///
/// Usage:
/// ```dart
/// // Initialize first (usually in main.dart)
/// await AnalyticsService.initialize();
///
/// // Log screen view
/// AnalyticsService.logScreenView('home_screen');
///
/// // Log custom event
/// AnalyticsService.logEvent('button_clicked', {'button_name': 'submit'});
///
/// // Log error (non-fatal)
/// AnalyticsService.logError(exception, stackTrace);
///
/// // Set user ID for tracking
/// AnalyticsService.setUserId('user_123');
/// ```
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// Whether analytics collection is enabled based on ATT status
  static bool _isAnalyticsEnabled = false;

  // Private constructor to prevent instantiation
  AnalyticsService._();

  /// Initialize analytics service and request ATT permission on iOS
  ///
  /// This method should be called once during app initialization.
  /// On iOS, it requests App Tracking Transparency permission.
  /// On Android, analytics is automatically enabled.
  static Future<void> initialize() async {
    if (kDebugMode) {
      debugPrint('[AnalyticsService] Initializing...');
    }

    try {
      if (Platform.isIOS) {
        // Request ATT permission on iOS
        final status = await AppTrackingTransparency.requestTrackingAuthorization();

        if (kDebugMode) {
          debugPrint('[AnalyticsService] ATT Status: $status');
        }

        // Enable analytics only if user authorized tracking
        _isAnalyticsEnabled = status == TrackingStatus.authorized;
      } else {
        // On Android, analytics is enabled by default
        _isAnalyticsEnabled = true;
      }

      // Configure Firebase Analytics based on consent
      await _analytics.setAnalyticsCollectionEnabled(_isAnalyticsEnabled);

      if (kDebugMode) {
        debugPrint('[AnalyticsService] Analytics enabled: $_isAnalyticsEnabled');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[AnalyticsService] Failed to initialize: $e');
        debugPrint('[AnalyticsService] StackTrace: $stackTrace');
      }
      // Disable analytics on error
      _isAnalyticsEnabled = false;
    }
  }

  /// Get current ATT status (iOS only)
  ///
  /// Returns null on Android or if ATT is not available.
  static Future<TrackingStatus?> getTrackingStatus() async {
    if (!Platform.isIOS) return null;

    try {
      return await AppTrackingTransparency.trackingAuthorizationStatus;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AnalyticsService] Failed to get tracking status: $e');
      }
      return null;
    }
  }

  // ============================================================
  // Analytics Methods
  // ============================================================

  /// Log screen view event
  static Future<void> logScreenView(String screenName) async {
    if (kDebugMode) {
      debugPrint('📊 [Analytics] Screen: $screenName');
      return;
    }
    if (!_isAnalyticsEnabled) return;
    await _analytics.logScreenView(screenName: screenName);
  }

  /// Log custom event with optional parameters
  static Future<void> logEvent(
    String name, [
    Map<String, Object>? parameters,
  ]) async {
    if (kDebugMode) {
      debugPrint('📊 [Analytics] Event: $name, params: $parameters');
      return;
    }
    if (!_isAnalyticsEnabled) return;
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  /// Set user ID for analytics tracking
  static Future<void> setUserId(String? userId) async {
    if (kDebugMode) {
      debugPrint('📊 [Analytics] Set userId: $userId');
      return;
    }
    if (_isAnalyticsEnabled) {
      await _analytics.setUserId(id: userId);
    }
    // Always set Crashlytics user ID (crash reporting is separate from analytics)
    await _crashlytics.setUserIdentifier(userId ?? '');
  }

  /// Set user property
  static Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    if (kDebugMode) {
      debugPrint('📊 [Analytics] Set property: $name = $value');
      return;
    }
    if (!_isAnalyticsEnabled) return;
    await _analytics.setUserProperty(name: name, value: value);
  }

  // ============================================================
  // Predefined Events (Common Actions)
  // ============================================================

  /// Log user login event
  static Future<void> logLogin(String method) async {
    await logEvent('login', {'method': method});
  }

  /// Log user sign up event
  static Future<void> logSignUp(String method) async {
    await logEvent('sign_up', {'method': method});
  }

  /// Log injection recorded event
  static Future<void> logInjectionRecorded({
    required String medicationType,
    required double dosage,
  }) async {
    await logEvent('injection_recorded', {
      'medication_type': medicationType,
      'dosage': dosage,
    });
  }

  /// Log side effect recorded event
  static Future<void> logSideEffectRecorded({
    required String sideEffectType,
    required int severity,
  }) async {
    await logEvent('side_effect_recorded', {
      'side_effect_type': sideEffectType,
      'severity': severity,
    });
  }

  /// Log weight recorded event
  static Future<void> logWeightRecorded({
    required double weight,
  }) async {
    await logEvent('weight_recorded', {
      'weight': weight,
    });
  }

  // ============================================================
  // Crashlytics Methods
  // ============================================================

  /// Log non-fatal error to Crashlytics
  static Future<void> logError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    if (kDebugMode) {
      debugPrint('🚨 [Crashlytics] Error: $exception');
      debugPrint('🚨 [Crashlytics] Reason: $reason');
      debugPrint('🚨 [Crashlytics] StackTrace: $stackTrace');
      return;
    }
    await _crashlytics.recordError(
      exception,
      stackTrace,
      reason: reason,
      fatal: fatal,
    );
  }

  /// Log a message to Crashlytics (breadcrumb)
  static Future<void> log(String message) async {
    if (kDebugMode) {
      debugPrint('📝 [Crashlytics] Log: $message');
      return;
    }
    await _crashlytics.log(message);
  }

  /// Set custom key-value pair for crash reports
  static Future<void> setCustomKey(String key, Object value) async {
    if (kDebugMode) {
      debugPrint('🔑 [Crashlytics] Custom key: $key = $value');
      return;
    }
    await _crashlytics.setCustomKey(key, value);
  }
}
