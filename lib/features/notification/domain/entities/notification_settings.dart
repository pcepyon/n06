import 'package:flutter/material.dart';

/// 알림 설정을 나타내는 불변 엔터티
class NotificationSettings {
  final String userId;
  final TimeOfDay notificationTime;
  final bool notificationEnabled;

  NotificationSettings({
    required this.userId,
    required this.notificationTime,
    required this.notificationEnabled,
  });

  /// 일부 필드를 변경한 새 인스턴스 반환 (Immutable Pattern)
  NotificationSettings copyWith({
    String? userId,
    TimeOfDay? notificationTime,
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
        other.notificationTime.hour == notificationTime.hour &&
        other.notificationTime.minute == notificationTime.minute &&
        other.notificationEnabled == notificationEnabled;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        notificationTime.hour.hashCode ^
        notificationTime.minute.hashCode ^
        notificationEnabled.hashCode;
  }

  @override
  String toString() {
    return 'NotificationSettings('
        'userId: $userId, '
        'notificationTime: ${notificationTime.hour}:${notificationTime.minute.toString().padLeft(2, '0')}, '
        'notificationEnabled: $notificationEnabled)';
  }
}
