import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/notification_settings.dart';
import '../../domain/repositories/notification_repository.dart';
import '../dtos/notification_settings_dto.dart';

/// Supabase implementation of NotificationRepository
///
/// Manages notification settings in Supabase database.
class SupabaseNotificationRepository implements NotificationRepository {
  final SupabaseClient _supabase;

  SupabaseNotificationRepository(this._supabase);

  @override
  Future<NotificationSettings?> getNotificationSettings(String userId) async {
    final response = await _supabase
        .from('notification_settings')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return NotificationSettingsDto.fromJson(response).toEntity();
  }

  @override
  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    final dto = NotificationSettingsDto.fromEntity(settings);
    await _supabase.from('notification_settings').upsert(
      dto.toJson(),
      onConflict: 'user_id',
    );
  }
}
