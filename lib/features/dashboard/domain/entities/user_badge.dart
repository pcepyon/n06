import 'package:equatable/equatable.dart';

enum BadgeStatus {
  locked,
  inProgress,
  achieved,
}

class UserBadge extends Equatable {
  final String id;
  final String userId;
  final String badgeId;
  final BadgeStatus status;
  final int progressPercentage;
  final DateTime? achievedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserBadge({
    required this.id,
    required this.userId,
    required this.badgeId,
    required this.status,
    required this.progressPercentage,
    this.achievedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  UserBadge copyWith({
    String? id,
    String? userId,
    String? badgeId,
    BadgeStatus? status,
    int? progressPercentage,
    DateTime? achievedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserBadge(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      badgeId: badgeId ?? this.badgeId,
      status: status ?? this.status,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      achievedAt: achievedAt ?? this.achievedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        badgeId,
        status,
        progressPercentage,
        achievedAt,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() =>
      'UserBadge(badgeId: $badgeId, status: $status, progress: $progressPercentage%)';
}
