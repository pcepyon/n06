import 'package:n06/features/dashboard/domain/entities/user_badge.dart';

/// Supabase DTO for UserBadge entity.
///
/// Stores user badge information in Supabase database.
class UserBadgeDto {
  final String id;
  final String userId;
  final String badgeId;
  final String status;
  final int progressPercentage;
  final DateTime? achievedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserBadgeDto({
    required this.id,
    required this.userId,
    required this.badgeId,
    required this.status,
    required this.progressPercentage,
    this.achievedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates DTO from Supabase JSON.
  factory UserBadgeDto.fromJson(Map<String, dynamic> json) {
    return UserBadgeDto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      badgeId: json['badge_id'] as String,
      status: json['status'] as String,
      progressPercentage: json['progress_percentage'] as int,
      achievedAt: json['achieved_at'] != null
          ? DateTime.parse(json['achieved_at'] as String).toLocal()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
    );
  }

  /// Converts DTO to Supabase JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'badge_id': badgeId,
      'status': status,
      'progress_percentage': progressPercentage,
      'achieved_at': achievedAt?.toUtc().toIso8601String(),
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }

  /// Converts DTO to Domain Entity.
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

  /// Creates DTO from Domain Entity.
  factory UserBadgeDto.fromEntity(UserBadge entity) {
    return UserBadgeDto(
      id: entity.id,
      userId: entity.userId,
      badgeId: entity.badgeId,
      status: _statusToString(entity.status),
      progressPercentage: entity.progressPercentage,
      achievedAt: entity.achievedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Dart enum (camelCase) → DB string (snake_case)
  static String _statusToString(BadgeStatus status) {
    switch (status) {
      case BadgeStatus.locked:
        return 'locked';
      case BadgeStatus.inProgress:
        return 'in_progress';
      case BadgeStatus.achieved:
        return 'achieved';
    }
  }

  /// DB string (snake_case) → Dart enum (camelCase)
  static BadgeStatus _stringToStatus(String value) {
    switch (value) {
      case 'locked':
        return BadgeStatus.locked;
      case 'in_progress':
        return BadgeStatus.inProgress;
      case 'achieved':
        return BadgeStatus.achieved;
      default:
        return BadgeStatus.locked;
    }
  }
}
