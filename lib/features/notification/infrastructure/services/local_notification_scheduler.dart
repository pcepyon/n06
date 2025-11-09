import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:n06/features/notification/domain/services/notification_scheduler.dart';
import 'package:n06/features/notification/infrastructure/services/permission_service.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';
import 'package:timezone/timezone.dart' as tz;

/// flutter_local_notifications를 사용한 알림 스케줄링 구현
class LocalNotificationScheduler implements NotificationScheduler {
  final PermissionService _permissionService;
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  bool _isInitialized = false;

  LocalNotificationScheduler(this._permissionService) {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  /// 플러그인 초기화
  Future<void> initialize() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('app_icon');
    const DarwinInitializationSettings iOSInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iOSInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    _isInitialized = true;
  }

  /// 초기화 여부
  bool get isInitialized => _isInitialized;

  /// 알림 권한 확인
  @override
  Future<bool> checkPermission() async {
    return await _permissionService.checkPermission();
  }

  /// 알림 권한 요청
  @override
  Future<bool> requestPermission() async {
    return await _permissionService.requestPermission();
  }

  /// 투여 스케줄 기반 알림 등록
  @override
  Future<void> scheduleNotifications({
    required List<DoseSchedule> doseSchedules,
    required TimeOfDay notificationTime,
  }) async {
    // 같은 날짜의 중복 제거
    final uniqueDates = <DateTime>{};
    final filteredSchedules = <DoseSchedule>[];

    for (final schedule in doseSchedules) {
      // 과거 날짜 제외
      if (schedule.scheduledDate.isBefore(DateTime.now())) {
        continue;
      }

      final dateOnly = DateTime(
        schedule.scheduledDate.year,
        schedule.scheduledDate.month,
        schedule.scheduledDate.day,
      );

      if (!uniqueDates.contains(dateOnly)) {
        uniqueDates.add(dateOnly);
        filteredSchedules.add(schedule);
      }
    }

    // 각 스케줄에 대해 알림 등록
    for (int i = 0; i < filteredSchedules.length; i++) {
      final schedule = filteredSchedules[i];
      final scheduledDateTime = DateTime(
        schedule.scheduledDate.year,
        schedule.scheduledDate.month,
        schedule.scheduledDate.day,
        notificationTime.hour,
        notificationTime.minute,
      );

      // 알림 시간이 현재보다 이미 지난 경우, 다음날로 설정
      final notificationDateTime = scheduledDateTime.isBefore(DateTime.now())
          ? scheduledDateTime.add(const Duration(days: 1))
          : scheduledDateTime;

      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'dose_notification_channel',
        '투여 알림',
        channelDescription: '투여 예정일 알림',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

      const DarwinNotificationDetails iOSNotificationDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iOSNotificationDetails,
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        i,
        '투여 예정일 알림',
        '오늘은 투여일입니다',
        tz.TZDateTime.from(notificationDateTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  /// 모든 알림 취소
  @override
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// 대기 중인 알림 목록 조회
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  /// 알림 응답 처리
  void _onNotificationResponse(NotificationResponse notificationResponse) {
    // 알림 탭했을 때의 처리 로직
    // 추후 Router를 통해 투여 스케줄러 화면으로 이동하도록 설정 가능
  }
}
