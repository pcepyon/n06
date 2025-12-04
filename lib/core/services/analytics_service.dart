import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Analytics and Crashlytics service for monitoring app usage and errors.
///
/// Usage:
/// ```dart
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

  // Private constructor to prevent instantiation
  AnalyticsService._();

  // ============================================================
  // Analytics Methods
  // ============================================================

  /// Log screen view event
  static Future<void> logScreenView(String screenName) async {
    if (kDebugMode) {
      debugPrint('📊 [Analytics] Screen: $screenName');
      return;
    }
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
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  /// Set user ID for analytics tracking
  static Future<void> setUserId(String? userId) async {
    if (kDebugMode) {
      debugPrint('📊 [Analytics] Set userId: $userId');
      return;
    }
    await _analytics.setUserId(id: userId);
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
