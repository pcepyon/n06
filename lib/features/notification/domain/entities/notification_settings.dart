import 'package:n06/features/notification/domain/value_objects/notification_time.dart';

/// 알림 설정을 나타내는 불변 엔터티
class NotificationSettings {
  final String userId;
  final NotificationTime notificationTime;
  final bool notificationEnabled;

  const NotificationSettings({
    required this.userId,
    required this.notificationTime,
    required this.notificationEnabled,
  });

  /// 일부 필드를 변경한 새 인스턴스 반환 (Immutable Pattern)
  NotificationSettings copyWith({
    String? userId,
    NotificationTime? notificationTime,
    bool? notificationEnabled,
  }) {
    return NotificationSettings(
      userId: userId ?? this.userId,
      notificationTime: notificationTime ?? this.notificationTime,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationSettings &&
        other.userId == userId &&
        other.notificationTime == notificationTime &&
        other.notificationEnabled == notificationEnabled;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        notificationTime.hashCode ^
        notificationEnabled.hashCode;
  }

  @override
  String toString() {
    return 'NotificationSettings('
        'userId: $userId, '
        'notificationTime: $notificationTime, '
        'notificationEnabled: $notificationEnabled)';
  }
}
