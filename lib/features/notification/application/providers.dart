import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/core/providers.dart';
import 'package:n06/features/notification/domain/repositories/notification_repository.dart';
import 'package:n06/features/notification/domain/services/notification_scheduler.dart';
import 'package:n06/features/notification/infrastructure/repositories/supabase_notification_repository.dart';
// import 'package:n06/features/notification/infrastructure/repositories/isar_notification_repository.dart';  // Phase 1.8에서 제거
import 'package:n06/features/notification/infrastructure/services/local_notification_scheduler.dart';
import 'package:n06/features/notification/infrastructure/services/permission_service.dart';

part 'providers.g.dart';

/// Repository Provider
@riverpod
NotificationRepository notificationRepository(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseNotificationRepository(supabase);
}

/// Scheduler Provider
@riverpod
NotificationScheduler notificationScheduler(Ref ref) {
  return LocalNotificationScheduler(PermissionService());
}
