import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:n06/core/providers.dart';
import 'package:n06/features/notification/domain/repositories/notification_repository.dart';
import 'package:n06/features/notification/domain/services/notification_scheduler.dart';
import 'package:n06/features/notification/infrastructure/repositories/isar_notification_repository.dart';
import 'package:n06/features/notification/infrastructure/services/local_notification_scheduler.dart';
import 'package:n06/features/notification/infrastructure/services/permission_service.dart';

part 'providers.g.dart';

/// Repository Provider
@riverpod
NotificationRepository notificationRepository(
  NotificationRepositoryRef ref,
) {
  final isar = ref.watch(isarProvider);
  return IsarNotificationRepository(isar);
}

/// Scheduler Provider
@riverpod
NotificationScheduler notificationScheduler(
  NotificationSchedulerRef ref,
) {
  return LocalNotificationScheduler(PermissionService());
}
