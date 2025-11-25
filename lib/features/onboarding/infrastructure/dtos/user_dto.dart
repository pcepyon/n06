import 'package:n06/features/onboarding/domain/entities/user.dart';

/// Supabase DTO for User entity.
///
/// Stores user information in Supabase database.
class UserDto {
  final String id;
  final String name;
  final DateTime createdAt;

  const UserDto({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  /// Creates DTO from Supabase JSON.
  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  /// Converts DTO to Supabase JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  /// DTO를 Domain Entity로 변환한다.
  User toEntity() {
    return User(
      id: id,
      name: name,
      createdAt: createdAt,
    );
  }

  /// Domain Entity를 DTO로 변환한다.
  static UserDto fromEntity(User entity) {
    return UserDto(
      id: entity.id,
      name: entity.name,
      createdAt: entity.createdAt,
    );
  }
}
