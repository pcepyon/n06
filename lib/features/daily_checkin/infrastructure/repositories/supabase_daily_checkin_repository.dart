import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/daily_checkin.dart';
import '../../domain/repositories/daily_checkin_repository.dart';
import '../dtos/daily_checkin_dto.dart';

/// Supabase implementation of DailyCheckinRepository
///
/// Manages daily check-in records in the daily_checkins table.
/// Implements consecutive days calculation logic as per spec 7.2.
class SupabaseDailyCheckinRepository implements DailyCheckinRepository {
  final SupabaseClient _supabase;

  SupabaseDailyCheckinRepository(this._supabase);

  @override
  Future<DailyCheckin> save(DailyCheckin checkin) async {
    final dto = DailyCheckinDto.fromEntity(checkin);

    // UPSERT: If checkin exists for the same date, update it
    // UNIQUE(user_id, checkin_date) constraint ensures this works correctly
    final response = await _supabase
        .from('daily_checkins')
        .upsert(
          dto.toJson(),
          onConflict: 'user_id,checkin_date',
        )
        .select()
        .single();

    return DailyCheckinDto.fromJson(response).toEntity();
  }

  @override
  Future<DailyCheckin?> getByDate(String userId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];

    final response = await _supabase
        .from('daily_checkins')
        .select()
        .eq('user_id', userId)
        .eq('checkin_date', dateStr)
        .maybeSingle();

    if (response == null) return null;
    return DailyCheckinDto.fromJson(response).toEntity();
  }

  @override
  Future<List<DailyCheckin>> getByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final startStr = start.toIso8601String().split('T')[0];
    final endStr = end.toIso8601String().split('T')[0];

    final response = await _supabase
        .from('daily_checkins')
        .select()
        .eq('user_id', userId)
        .gte('checkin_date', startStr)
        .lte('checkin_date', endStr)
        .order('checkin_date', ascending: false);

    return (response as List)
        .map((json) => DailyCheckinDto.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<DailyCheckin?> getLatest(String userId) async {
    final response = await _supabase
        .from('daily_checkins')
        .select()
        .eq('user_id', userId)
        .order('checkin_date', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return DailyCheckinDto.fromJson(response).toEntity();
  }

  @override
  Future<int> getConsecutiveDays(String userId) async {
    // Fetch all checkins for the user, ordered by date descending
    final response = await _supabase
        .from('daily_checkins')
        .select('checkin_date')
        .eq('user_id', userId)
        .order('checkin_date', ascending: false);

    if (response.isEmpty) return 0;

    // Extract unique dates
    final checkinDates = (response as List)
        .map((item) => DateTime.parse(item['checkin_date'] as String))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Sort descending (most recent first)

    // Calculate consecutive days from today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int consecutiveDays = 0;
    for (var i = 0; i < checkinDates.length; i++) {
      final expectedDate = today.subtract(Duration(days: i));
      final checkinDate = DateTime(
        checkinDates[i].year,
        checkinDates[i].month,
        checkinDates[i].day,
      );

      if (checkinDate == expectedDate) {
        consecutiveDays++;
      } else {
        // Gap found, stop counting
        break;
      }
    }

    return consecutiveDays;
  }

  @override
  Future<void> delete(String id) async {
    await _supabase.from('daily_checkins').delete().eq('id', id);
  }
}
