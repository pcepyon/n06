import 'package:isar/isar.dart';
import 'package:n06/features/dashboard/domain/entities/badge_definition.dart';
import 'package:n06/features/dashboard/domain/entities/user_badge.dart';
import 'package:n06/features/dashboard/domain/repositories/badge_repository.dart';
import 'package:n06/features/dashboard/infrastructure/dtos/badge_definition_dto.dart';
import 'package:n06/features/dashboard/infrastructure/dtos/user_badge_dto.dart';

class IsarBadgeRepository implements BadgeRepository {
  final Isar isar;

  IsarBadgeRepository(this.isar);

  @override
  Future<List<BadgeDefinition>> getBadgeDefinitions() async {
    final dtos = await isar.badgeDefinitionDtos.where().findAll();
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<List<UserBadge>> getUserBadges(String userId) async {
    final dtos = await isar.userBadgeDtos.where().filter().userIdEqualTo(userId).findAll();
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<void> updateBadgeProgress(UserBadge badge) async {
    final dto = UserBadgeDto.fromEntity(badge);
    await isar.writeTxn(() async {
      await isar.userBadgeDtos.put(dto);
    });
  }

  @override
  Future<void> achieveBadge(String userId, String badgeId) async {
    final badge = await isar.userBadgeDtos
        .where()
        .filter()
        .userIdEqualTo(userId)
        .and()
        .badgeIdEqualTo(badgeId)
        .findFirst();

    if (badge != null) {
      final updated = badge.copyWith(
        status: 'achieved',
        progressPercentage: 100,
        achievedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await isar.writeTxn(() async {
        await isar.userBadgeDtos.put(updated);
      });
    }
  }

  @override
  Future<void> initializeUserBadges(String userId) async {
    final badgeDefs = await getBadgeDefinitions();
    final now = DateTime.now();

    await isar.writeTxn(() async {
      for (final badgeDef in badgeDefs) {
        final badge = UserBadgeDto()
          ..id = '${userId}_${badgeDef.id}'
          ..userId = userId
          ..badgeId = badgeDef.id
          ..status = 'locked'
          ..progressPercentage = 0
          ..achievedAt = null
          ..createdAt = now
          ..updatedAt = now;

        await isar.userBadgeDtos.put(badge);
      }
    });
  }
}
