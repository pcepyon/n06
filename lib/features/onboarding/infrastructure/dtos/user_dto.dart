import 'package:isar/isar.dart';
import 'package:n06/features/onboarding/domain/entities/user.dart';

part 'user_dto.g.dart';

@collection
class UserDto {
  Id isarId = Isar.autoIncrement;

  late String id;
  late String name;
  late DateTime createdAt;

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
    return UserDto()
      ..id = entity.id
      ..name = entity.name
      ..createdAt = entity.createdAt;
  }
}
