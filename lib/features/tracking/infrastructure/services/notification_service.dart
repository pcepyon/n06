import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:n06/features/tracking/domain/usecases/dose_notification_usecase.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late NotificationDetails _notificationDetails;

  NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  Future<void> initialize() async {
    const androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    _notificationDetails = const NotificationDetails(
      android: AndroidNotificationDetails(
        'dose_notification_channel',
        'Dose Notifications',
        channelDescription: 'Notifications for medication dose reminders',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    final result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    return result ?? false;
  }

  /// Schedule notification for dose
  Future<void> scheduleNotification({
    required String id,
    required String title,
    required String message,
    required DateTime scheduledDate,
    required int? hour,
    required int? minute,
  }) async {
    if (hour == null || minute == null) {
      return;
    }

    try {
      final scheduledDateTime = tz.TZDateTime.from(
        DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day,
            hour, minute),
        tz.local,
      );

      // Only schedule if not in the past
      if (scheduledDateTime.isBefore(tz.TZDateTime.now(tz.local))) {
        return;
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        int.parse(id.replaceAll('-', '').replaceAll('_', '').substring(0, 8)),
        title,
        message,
        scheduledDateTime,
        _notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print('Failed to schedule notification: $e');
    }
  }

  /// Schedule notification from payload
  Future<void> scheduleNotificationFromPayload(
    NotificationPayload payload, {
    required int? hour,
    required int? minute,
    required DateTime scheduledDate,
  }) async {
    await scheduleNotification(
      id: payload.id,
      title: payload.title,
      message: payload.message,
      scheduledDate: scheduledDate,
      hour: hour,
      minute: minute,
    );
  }

  /// Cancel notification
  Future<void> cancelNotification(String id) async {
    try {
      final notificationId =
          int.parse(id.replaceAll('-', '').replaceAll('_', '').substring(0, 8));
      await flutterLocalNotificationsPlugin.cancel(notificationId);
    } catch (e) {
      print('Failed to cancel notification: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Show test notification (for testing)
  Future<void> showTestNotification({
    required String title,
    required String message,
  }) async {
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      message,
      _notificationDetails,
    );
  }
}
