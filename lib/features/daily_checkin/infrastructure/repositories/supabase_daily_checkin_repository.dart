import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/daily_checkin.dart';
import '../../domain/repositories/daily_checkin_repository.dart';
import '../dtos/daily_checkin_dto.dart';

/// Repository 에러 타입
class DailyCheckinRepositoryException implements Exception {
  final String message;
  final String? code;
  final Object? originalError;

  DailyCheckinRepositoryException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'DailyCheckinRepositoryException: $message';
}

/// Supabase implementation of DailyCheckinRepository
///
/// Manages daily check-in records in the daily_checkins table.
/// Implements consecutive days calculation logic as per spec 7.2.
class SupabaseDailyCheckinRepository implements DailyCheckinRepository {
  final SupabaseClient _supabase;

  SupabaseDailyCheckinRepository(this._supabase);

  @override
  Future<DailyCheckin> save(DailyCheckin checkin) async {
    try {
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
    } on PostgrestException catch (e) {
      throw DailyCheckinRepositoryException(
        '체크인 저장 실패',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw DailyCheckinRepositoryException(
        '체크인 저장 중 오류 발생',
        originalError: e,
      );
    }
  }

  @override
  Future<DailyCheckin?> getByDate(String userId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];

      final response = await _supabase
          .from('daily_checkins')
          .select()
          .eq('user_id', userId)
          .eq('checkin_date', dateStr)
          .maybeSingle();

      if (response == null) return null;
      return DailyCheckinDto.fromJson(response).toEntity();
    } on PostgrestException catch (e) {
      throw DailyCheckinRepositoryException(
        '체크인 조회 실패',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw DailyCheckinRepositoryException(
        '체크인 조회 중 오류 발생',
        originalError: e,
      );
    }
  }

  @override
  Future<List<DailyCheckin>> getByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    try {
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
    } on PostgrestException catch (e) {
      throw DailyCheckinRepositoryException(
        '체크인 목록 조회 실패',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw DailyCheckinRepositoryException(
        '체크인 목록 조회 중 오류 발생',
        originalError: e,
      );
    }
  }

  @override
  Future<DailyCheckin?> getLatest(String userId) async {
    try {
      final response = await _supabase
          .from('daily_checkins')
          .select()
          .eq('user_id', userId)
          .order('checkin_date', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return DailyCheckinDto.fromJson(response).toEntity();
    } on PostgrestException catch (e) {
      throw DailyCheckinRepositoryException(
        '최근 체크인 조회 실패',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw DailyCheckinRepositoryException(
        '최근 체크인 조회 중 오류 발생',
        originalError: e,
      );
    }
  }

  @override
  Future<int> getConsecutiveDays(String userId) async {
    try {
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
    } on PostgrestException catch (e) {
      throw DailyCheckinRepositoryException(
        '연속 일수 조회 실패',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw DailyCheckinRepositoryException(
        '연속 일수 조회 중 오류 발생',
        originalError: e,
      );
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _supabase.from('daily_checkins').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw DailyCheckinRepositoryException(
        '체크인 삭제 실패',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw DailyCheckinRepositoryException(
        '체크인 삭제 중 오류 발생',
        originalError: e,
      );
    }
  }
}
