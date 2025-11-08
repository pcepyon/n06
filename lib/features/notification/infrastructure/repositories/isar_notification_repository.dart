import 'package:isar/isar.dart';
import 'package:n06/features/notification/domain/entities/notification_settings.dart';
import 'package:n06/features/notification/domain/repositories/notification_repository.dart';
import 'package:n06/features/notification/infrastructure/dtos/notification_settings_dto.dart';

/// Isar 기반 NotificationRepository 구현체
class IsarNotificationRepository implements NotificationRepository {
  final Isar isar;

  IsarNotificationRepository(this.isar);

  @override
  Future<NotificationSettings?> getNotificationSettings(String userId) async {
    final dto = await isar.notificationSettingsDtos
        .filter()
        .userIdEqualTo(userId)
        .findFirst();

    return dto?.toEntity();
  }

  @override
  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    final dto = NotificationSettingsDto.fromEntity(settings);

    // 기존 설정 확인
    final existing = await isar.notificationSettingsDtos
        .filter()
        .userIdEqualTo(settings.userId)
        .findFirst();

    await isar.writeTxn(() async {
      if (existing != null) {
        // 기존 ID 유지하고 업데이트
        dto.id = existing.id;
      }
      await isar.notificationSettingsDtos.put(dto);
    });
  }
}
