import 'package:n06/features/dashboard/domain/entities/badge_definition.dart';
import 'package:n06/features/dashboard/domain/entities/user_badge.dart';

abstract class BadgeRepository {
  /// 모든 뱃지 정의를 조회합니다.
  Future<List<BadgeDefinition>> getBadgeDefinitions();

  /// 사용자의 뱃지 획득 상태를 조회합니다.
  Future<List<UserBadge>> getUserBadges(String userId);

  /// 뱃지 진행도를 업데이트합니다.
  Future<void> updateBadgeProgress(UserBadge badge);

  /// 뱃지를 획득 처리합니다.
  Future<void> achieveBadge(String userId, String badgeId);

  /// 사용자의 모든 뱃지를 초기화합니다.
  Future<void> initializeUserBadges(String userId);
}
