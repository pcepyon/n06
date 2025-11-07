import 'package:isar/isar.dart';
import 'package:n06/features/onboarding/domain/entities/user.dart';
import 'package:n06/features/onboarding/domain/repositories/user_repository.dart';
import 'package:n06/features/onboarding/infrastructure/dtos/user_dto.dart';

/// Isar 기반 UserRepository 구현
class IsarUserRepository implements UserRepository {
  final Isar _isar;

  IsarUserRepository(this._isar);

  @override
  Future<void> updateUserName(String userId, String name) async {
    final dto = await _isar.userDtos.filter().idEqualTo(userId).findFirst();
    if (dto == null) {
      throw Exception('사용자를 찾을 수 없습니다: $userId');
    }

    await _isar.writeTxn(() async {
      dto.name = name;
      await _isar.userDtos.put(dto);
    });
  }

  @override
  Future<User?> getUser(String userId) async {
    final dto = await _isar.userDtos.filter().idEqualTo(userId).findFirst();
    return dto?.toEntity();
  }

  @override
  Future<void> saveUser(User user) async {
    final dto = UserDto.fromEntity(user);
    await _isar.writeTxn(() async {
      await _isar.userDtos.put(dto);
    });
  }
}
