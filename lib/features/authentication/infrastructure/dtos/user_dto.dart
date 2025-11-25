import 'package:n06/features/authentication/domain/entities/user.dart';

/// Supabase DTO for User entity.
///
/// Stores user account information in Supabase database.
class UserDto {
  final String id;
  final String oauthProvider;
  final String oauthUserId;
  final String name;
  final String email;
  final String? profileImageUrl;
  final DateTime lastLoginAt;

  const UserDto({
    required this.id,
    required this.oauthProvider,
    required this.oauthUserId,
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.lastLoginAt,
  });

  /// Creates DTO from Supabase JSON.
  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String,
      oauthProvider: json['oauth_provider'] as String,
      oauthUserId: json['oauth_user_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profileImageUrl: json['profile_image_url'] as String?,
      lastLoginAt: DateTime.parse(json['last_login_at'] as String).toLocal(),
    );
  }

  /// Converts DTO to Supabase JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'oauth_provider': oauthProvider,
      'oauth_user_id': oauthUserId,
      'name': name,
      'email': email,
      'profile_image_url': profileImageUrl,
      'last_login_at': lastLoginAt.toUtc().toIso8601String(),
    };
  }

  /// Converts DTO to Domain Entity.
  User toEntity() {
    return User(
      id: id,
      oauthProvider: oauthProvider,
      oauthUserId: oauthUserId,
      name: name,
      email: email,
      profileImageUrl: profileImageUrl,
      lastLoginAt: lastLoginAt,
    );
  }

  /// Creates DTO from Domain Entity.
  factory UserDto.fromEntity(User entity) {
    return UserDto(
      id: entity.id,
      oauthProvider: entity.oauthProvider,
      oauthUserId: entity.oauthUserId,
      name: entity.name,
      email: entity.email,
      profileImageUrl: entity.profileImageUrl,
      lastLoginAt: entity.lastLoginAt,
    );
  }
}
