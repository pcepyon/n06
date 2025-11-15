import 'package:n06/features/notification/domain/entities/notification_settings.dart';
import 'package:n06/features/notification/domain/value_objects/notification_time.dart';

/// Supabase DTO for NotificationSettings entity.
///
/// Stores notification settings in Supabase database.
class NotificationSettingsDto {
  final String userId;
  final int notificationHour;
  final int notificationMinute;
  final bool notificationEnabled;

  const NotificationSettingsDto({
    required this.userId,
    required this.notificationHour,
    required this.notificationMinute,
    required this.notificationEnabled,
  });

  /// Creates DTO from Supabase JSON.
  factory NotificationSettingsDto.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsDto(
      userId: json['user_id'] as String,
      notificationHour: json['notification_hour'] as int,
      notificationMinute: json['notification_minute'] as int,
      notificationEnabled: json['notification_enabled'] as bool,
    );
  }

  /// Converts DTO to Supabase JSON.
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'notification_hour': notificationHour,
      'notification_minute': notificationMinute,
      'notification_enabled': notificationEnabled,
    };
  }

  /// DTO를 Domain Entity로 변환
  NotificationSettings toEntity() {
    return NotificationSettings(
      userId: userId,
      notificationTime: NotificationTime(
        hour: notificationHour,
        minute: notificationMinute,
      ),
      notificationEnabled: notificationEnabled,
    );
  }

  /// Domain Entity를 DTO로 변환
  static NotificationSettingsDto fromEntity(NotificationSettings entity) {
    return NotificationSettingsDto(
      userId: entity.userId,
      notificationHour: entity.notificationTime.hour,
      notificationMinute: entity.notificationTime.minute,
      notificationEnabled: entity.notificationEnabled,
    );
  }
}
