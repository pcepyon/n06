import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:n06/features/notification/domain/entities/notification_settings.dart';

part 'notification_settings_dto.g.dart';

@collection
class NotificationSettingsDto {
  Id id = Isar.autoIncrement;
  late String userId;
  late int notificationHour; // 0-23
  late int notificationMinute; // 0-59
  late bool notificationEnabled;

  /// DTO를 Domain Entity로 변환
  NotificationSettings toEntity() {
    return NotificationSettings(
      userId: userId,
      notificationTime: TimeOfDay(hour: notificationHour, minute: notificationMinute),
      notificationEnabled: notificationEnabled,
    );
  }

  /// Domain Entity를 DTO로 변환
  static NotificationSettingsDto fromEntity(NotificationSettings entity) {
    return NotificationSettingsDto()
      ..userId = entity.userId
      ..notificationHour = entity.notificationTime.hour
      ..notificationMinute = entity.notificationTime.minute
      ..notificationEnabled = entity.notificationEnabled;
  }
}
