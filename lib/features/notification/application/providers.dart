import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:n06/core/providers.dart';
import 'package:n06/features/notification/domain/repositories/notification_repository.dart';
import 'package:n06/features/notification/domain/services/notification_scheduler.dart';
import 'package:n06/features/notification/infrastructure/repositories/supabase_notification_repository.dart';
import 'package:n06/features/notification/infrastructure/services/local_notification_scheduler.dart';
import 'package:n06/features/notification/infrastructure/services/permission_service.dart';

part 'providers.g.dart';

/// Repository Provider
@riverpod
NotificationRepository notificationRepository(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseNotificationRepository(supabase);
}

/// Scheduler Instance Provider (싱글톤)
/// 초기화 전에도 인스턴스에 접근 가능
@Riverpod(keepAlive: true)
LocalNotificationScheduler notificationSchedulerInstance(Ref ref) {
  return LocalNotificationScheduler(PermissionService());
}

/// Scheduler Provider (초기화 완료 보장)
/// 알림 스케줄링 작업에 사용
@Riverpod(keepAlive: true)
Future<NotificationScheduler> notificationScheduler(Ref ref) async {
  final scheduler = ref.watch(notificationSchedulerInstanceProvider);
  if (!scheduler.isInitialized) {
    await scheduler.initialize();
  }
  return scheduler;
}
