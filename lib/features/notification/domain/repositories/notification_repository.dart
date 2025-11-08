import 'package:n06/features/notification/domain/entities/notification_settings.dart';

/// 알림 설정 데이터 접근 계약
abstract class NotificationRepository {
  /// 사용자의 알림 설정 조회
  Future<NotificationSettings?> getNotificationSettings(String userId);

  /// 알림 설정 저장
  Future<void> saveNotificationSettings(NotificationSettings settings);
}
