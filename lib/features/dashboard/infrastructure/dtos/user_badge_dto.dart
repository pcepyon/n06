import 'package:isar/isar.dart';
import 'package:n06/features/dashboard/domain/entities/user_badge.dart';

part 'user_badge_dto.g.dart';

@collection
class UserBadgeDto {
  Id? isarId;
  late String id;
  late String userId;
  late String badgeId;
  late String status; // enum string: locked, inProgress, achieved
  late int progressPercentage;
  DateTime? achievedAt;
  late DateTime createdAt;
  late DateTime updatedAt;

  UserBadgeDto();

  UserBadge toEntity() {
    return UserBadge(
      id: id,
      userId: userId,
      badgeId: badgeId,
      status: _stringToStatus(status),
      progressPercentage: progressPercentage,
      achievedAt: achievedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory UserBadgeDto.fromEntity(UserBadge entity) {
    return UserBadgeDto()
      ..id = entity.id
      ..userId = entity.userId
      ..badgeId = entity.badgeId
      ..status = entity.status.toString().split('.').last
      ..progressPercentage = entity.progressPercentage
      ..achievedAt = entity.achievedAt
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt;
  }

  UserBadgeDto copyWith({
    Id? isarId,
    String? id,
    String? userId,
    String? badgeId,
    String? status,
    int? progressPercentage,
    DateTime? achievedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserBadgeDto()
      ..isarId = isarId ?? this.isarId
      ..id = id ?? this.id
      ..userId = userId ?? this.userId
      ..badgeId = badgeId ?? this.badgeId
      ..status = status ?? this.status
      ..progressPercentage = progressPercentage ?? this.progressPercentage
      ..achievedAt = achievedAt ?? this.achievedAt
      ..createdAt = createdAt ?? this.createdAt
      ..updatedAt = updatedAt ?? this.updatedAt;
  }

  static BadgeStatus _stringToStatus(String value) {
    return BadgeStatus.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => BadgeStatus.locked,
    );
  }
}
