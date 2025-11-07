import 'package:isar/isar.dart';
import 'package:n06/features/authentication/domain/entities/user.dart';

part 'user_dto.g.dart';

/// Isar DTO for User entity.
///
/// Stores user account information in Isar local database.
@collection
class UserDto {
  UserDto();

  Id id = Isar.autoIncrement;

  @Index(unique: true, composite: [CompositeIndex('oauthUserId')])
  late String oauthProvider;

  late String oauthUserId;
  late String name;
  late String email;
  String? profileImageUrl;
  late DateTime lastLoginAt;

  /// Converts DTO to Domain Entity.
  User toEntity() {
    return User(
      id: id.toString(),
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
    return UserDto()
      ..id = entity.id.isNotEmpty ? int.tryParse(entity.id) ?? Isar.autoIncrement : Isar.autoIncrement
      ..oauthProvider = entity.oauthProvider
      ..oauthUserId = entity.oauthUserId
      ..name = entity.name
      ..email = entity.email
      ..profileImageUrl = entity.profileImageUrl
      ..lastLoginAt = entity.lastLoginAt;
  }
}
