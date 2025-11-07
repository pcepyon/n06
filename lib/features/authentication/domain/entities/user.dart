import 'package:equatable/equatable.dart';

/// User entity representing authenticated user account information
class User extends Equatable {
  final String id;
  final String oauthProvider;
  final String oauthUserId;
  final String name;
  final String email;
  final String? profileImageUrl;
  final DateTime lastLoginAt;

  const User({
    required this.id,
    required this.oauthProvider,
    required this.oauthUserId,
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.lastLoginAt,
  });

  User copyWith({
    String? id,
    String? oauthProvider,
    String? oauthUserId,
    String? name,
    String? email,
    String? profileImageUrl,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      oauthProvider: oauthProvider ?? this.oauthProvider,
      oauthUserId: oauthUserId ?? this.oauthUserId,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        oauthProvider,
        oauthUserId,
        name,
        email,
        profileImageUrl,
        lastLoginAt,
      ];
}
