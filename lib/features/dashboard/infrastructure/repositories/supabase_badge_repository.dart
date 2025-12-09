import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/badge_definition.dart';
import '../../domain/entities/user_badge.dart';
import '../../domain/repositories/badge_repository.dart';
import '../dtos/badge_definition_dto.dart';
import '../dtos/user_badge_dto.dart';

/// Supabase implementation of BadgeRepository
///
/// Manages badge definitions and user badge progress in Supabase database.
class SupabaseBadgeRepository implements BadgeRepository {
  final SupabaseClient _supabase;

  SupabaseBadgeRepository(this._supabase);

  @override
  Future<List<BadgeDefinition>> getBadgeDefinitions() async {
    final response = await _supabase
        .from('badge_definitions')
        .select()
        .order('display_order', ascending: true);

    return (response as List)
        .map((json) => BadgeDefinitionDto.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<List<UserBadge>> getUserBadges(String userId) async {
    final response = await _supabase
        .from('user_badges')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => UserBadgeDto.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<void> updateBadgeProgress(UserBadge badge) async {
    final dto = UserBadgeDto.fromEntity(badge);
    await _supabase
        .from('user_badges')
        .update(dto.toJson())
        .eq('id', badge.id);
  }

  @override
  Future<void> achieveBadge(String userId, String badgeId) async {
    final now = DateTime.now();
    await _supabase
        .from('user_badges')
        .update({
          'status': 'achieved',
          'progress_percentage': 100,
          'achieved_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        })
        .eq('user_id', userId)
        .eq('badge_id', badgeId);
  }

  @override
  Future<void> initializeUserBadges(String userId) async {
    // Get all badge definitions
    final badgeDefinitions = await getBadgeDefinitions();

    // Create user badges for all definitions
    // id는 DB에서 UUID 자동 생성 (DEFAULT uuid_generate_v4())
    final now = DateTime.now();
    final userBadges = badgeDefinitions.map((definition) {
      return {
        'user_id': userId,
        'badge_id': definition.id,
        'status': 'locked',
        'progress_percentage': 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };
    }).toList();

    // Upsert to handle cases where some badges might already exist
    // UNIQUE(user_id, badge_id) 제약조건 활용
    await _supabase.from('user_badges').upsert(
      userBadges,
      onConflict: 'user_id,badge_id',
    );
  }
}
